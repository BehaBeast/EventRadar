begin;

-- 1. Геолокация мероприятий (Map)
alter table public.events add column if not exists latitude double precision check (latitude between -90 and 90);
alter table public.events add column if not exists longitude double precision check (longitude between -180 and 180);

-- 2. Категории билетов и тарифы (Ticket Tiers)
create table public.ticket_tiers (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references public.events(id) on delete cascade,
  name text not null check (length(trim(name)) between 1 and 100),
  description text not null default '',
  price bigint not null check (price >= 0),
  currency text not null default 'UZS' references public.currencies(code),
  quantity_total integer not null check (quantity_total >= 0),
  quantity_sold integer not null default 0 check (quantity_sold >= 0 and quantity_sold <= quantity_total),
  created_at timestamptz not null default now()
);
create index ticket_tiers_event on public.ticket_tiers(event_id);

-- 3. Заказы (Orders)
create table public.orders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  event_id uuid not null references public.events(id) on delete cascade,
  tier_id uuid not null references public.ticket_tiers(id) on delete cascade,
  quantity integer not null check (quantity > 0 and quantity <= 20),
  unit_price bigint not null check (unit_price >= 0),
  total_amount bigint not null check (total_amount >= 0),
  platform_fee bigint not null default 0 check (platform_fee >= 0),
  organizer_amount bigint not null default 0 check (organizer_amount >= 0),
  currency text not null default 'UZS' references public.currencies(code),
  status text not null default 'pending' check (status in ('pending', 'paid', 'cancelled', 'refunded')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index orders_user on public.orders(user_id);
create index orders_event on public.orders(event_id);

-- 4. Платежи и транзакции провайдеров (Payments)
create table public.payments (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  provider text not null check (provider in ('payme', 'click', 'stripe', 'card', 'test')),
  provider_tx_id text,
  amount bigint not null check (amount >= 0),
  currency text not null default 'UZS' references public.currencies(code),
  status text not null default 'pending' check (status in ('pending', 'succeeded', 'failed', 'refunded')),
  metadata jsonb not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index payments_order on public.payments(order_id);

-- 5. Электронные билеты с QR-кодом (Tickets)
create table public.tickets (
  id uuid primary key default gen_random_uuid(),
  order_id uuid not null references public.orders(id) on delete cascade,
  user_id uuid not null references public.profiles(id) on delete cascade,
  event_id uuid not null references public.events(id) on delete cascade,
  tier_id uuid not null references public.ticket_tiers(id) on delete cascade,
  ticket_number text not null unique,
  qr_code text not null unique,
  status text not null default 'valid' check (status in ('valid', 'used', 'cancelled', 'refunded')),
  created_at timestamptz not null default now()
);
create index tickets_user on public.tickets(user_id);
create index tickets_event on public.tickets(event_id);

-- 6. Токены Push-уведомлений (Push Tokens)
create table public.user_push_tokens (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  token text not null,
  platform text not null default 'android' check (platform in ('android', 'ios', 'web')),
  updated_at timestamptz not null default now(),
  unique (user_id, token)
);
create index push_tokens_user on public.user_push_tokens(user_id);

-- 7. История Push-уведомлений (Notifications)
create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  title text not null check (length(trim(title)) between 1 and 200),
  body text not null check (length(trim(body)) between 1 and 1000),
  type text not null default 'info' check (type in ('info', 'ticket', 'reminder_24h', 'reminder_1h', 'event_update', 'marketing')),
  payload jsonb not null default '{}',
  is_read boolean not null default false,
  created_at timestamptz not null default now()
);
create index notifications_user on public.notifications(user_id, is_read);

-- 8. Конфигурация провайдеров (для настроек карты и платежей)
create table public.provider_settings (
  key text primary key,
  value jsonb not null,
  updated_at timestamptz not null default now()
);

-- RLS
do $$ declare t text; begin
  foreach t in array array['ticket_tiers', 'orders', 'payments', 'tickets', 'user_push_tokens', 'notifications', 'provider_settings'] loop
    execute format('alter table public.%I enable row level security', t);
    execute format('revoke all on public.%I from anon, authenticated', t);
  end loop;
end $$;

grant select on public.ticket_tiers to anon, authenticated;
grant select on public.orders, public.payments, public.tickets, public.user_push_tokens, public.notifications to authenticated;
grant insert, update, delete on public.user_push_tokens to authenticated;
grant update(is_read) on public.notifications to authenticated;

-- Policies
create policy read_ticket_tiers on public.ticket_tiers for select using (true);
create policy read_own_orders on public.orders for select to authenticated using (user_id = auth.uid());
create policy read_own_payments on public.payments for select to authenticated using (
  exists (select 1 from public.orders o where o.id = payments.order_id and o.user_id = auth.uid())
);
create policy read_own_tickets on public.tickets for select to authenticated using (user_id = auth.uid());
create policy manage_own_push_tokens on public.user_push_tokens for all to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy read_own_notifications on public.notifications for select to authenticated using (user_id = auth.uid());
create policy update_own_notifications on public.notifications for update to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());

-- RPC: Создание заказа билетов
create function public.create_ticket_order(p_event_id uuid, p_tier_id uuid, p_quantity integer, p_provider text)
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  v_tier public.ticket_tiers;
  v_event public.events;
  v_order_id uuid;
  v_payment_id uuid;
  v_total bigint;
  v_fee bigint;
  v_org_amount bigint;
  v_ticket_num text;
  v_qr text;
  v_i integer;
begin
  if not private.active_user() then
    raise exception 'UNAUTHORIZED' using errcode = '42501';
  end if;

  if p_quantity is null or p_quantity < 1 or p_quantity > 10 then
    raise exception 'INVALID_QUANTITY';
  end if;

  select * into v_event from public.events where id = p_event_id and status = 'published';
  if v_event.id is null then
    raise exception 'EVENT_NOT_AVAILABLE';
  end if;

  select * into v_tier from public.ticket_tiers where id = p_tier_id and event_id = p_event_id for update;
  if v_tier.id is null then
    raise exception 'TIER_NOT_FOUND';
  end if;

  if (v_tier.quantity_sold + p_quantity) > v_tier.quantity_total then
    raise exception 'SOLD_OUT';
  end if;

  v_total := v_tier.price * p_quantity;
  -- Комиссия платформы EventRadar: 5% (оплачивает организатор)
  v_fee := (v_total * 5) / 100;
  v_org_amount := v_total - v_fee;

  insert into public.orders(user_id, event_id, tier_id, quantity, unit_price, total_amount, platform_fee, organizer_amount, currency, status)
  values (auth.uid(), p_event_id, p_tier_id, p_quantity, v_tier.price, v_total, v_fee, v_org_amount, v_tier.currency, 'paid')
  returning id into v_order_id;

  insert into public.payments(order_id, provider, amount, currency, status, metadata)
  values (v_order_id, p_provider, v_total, v_tier.currency, 'succeeded', jsonb_build_object('provider', p_provider, 'auto_settled', true))
  returning id into v_payment_id;

  update public.ticket_tiers set quantity_sold = quantity_sold + p_quantity where id = p_tier_id;

  for v_i in 1..p_quantity loop
    v_ticket_num := 'ER-' || upper(substr(md5(random()::text || clock_timestamp()::text), 1, 8));
    v_qr := 'EVENTRADAR:TICKET:' || v_ticket_num || ':' || v_order_id::text;
    insert into public.tickets(order_id, user_id, event_id, tier_id, ticket_number, qr_code, status)
    values (v_order_id, auth.uid(), p_event_id, p_tier_id, v_ticket_num, v_qr, 'valid');
  end loop;

  -- Создание уведомления пользователю
  insert into public.notifications(user_id, title, body, type, payload)
  values (
    auth.uid(),
    'Билеты успешно оформлены',
    'Ваш заказ №' || substr(v_order_id::text, 1, 8) || ' оплачен. Билеты доступны в профиле.',
    'ticket',
    jsonb_build_object('order_id', v_order_id, 'event_id', p_event_id)
  );

  insert into public.audit_logs(actor_id, action, entity_id, details)
  values (auth.uid(), 'order.create', v_order_id, jsonb_build_object('amount', v_total, 'provider', p_provider, 'tickets', p_quantity));

  return jsonb_build_object(
    'order_id', v_order_id,
    'payment_id', v_payment_id,
    'status', 'paid',
    'total_amount', v_total,
    'quantity', p_quantity
  );
end $$;

grant execute on function public.create_ticket_order(uuid, uuid, integer, text) to authenticated;

commit;

