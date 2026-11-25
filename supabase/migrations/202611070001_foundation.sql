begin;
create schema if not exists private;
revoke all on schema private from public;

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default '' check (length(display_name) <= 100),
  created_at timestamptz not null default now()
);
create table public.user_roles (
  user_id uuid not null references public.profiles(id) on delete cascade,
  role text not null check (role in ('admin','organizer')),
  primary key (user_id, role)
);
create table public.account_restrictions (
  user_id uuid primary key references public.profiles(id) on delete cascade,
  reason text not null,
  created_at timestamptz not null default now()
);
create table public.audit_logs (
  id bigint generated always as identity primary key,
  actor_id uuid,
  action text not null,
  entity_id uuid,
  details jsonb not null default '{}',
  created_at timestamptz not null default now()
);
create function private.active_user() returns boolean language sql stable security definer
set search_path = '' as $$
  select auth.uid() is not null and not exists
  (select 1 from public.account_restrictions where user_id = auth.uid())
$$;
create function private.is_admin() returns boolean language sql stable security definer
set search_path = '' as $$
  select private.active_user() and exists
  (select 1 from public.user_roles where user_id = auth.uid() and role = 'admin')
$$;
create function private.new_user() returns trigger language plpgsql security definer
set search_path = '' as $$
begin
  insert into public.profiles(id, display_name)
  values (new.id, left(coalesce(new.raw_user_meta_data->>'display_name',''),100));
  return new;
end $$;
create trigger on_auth_user_created after insert on auth.users
for each row execute function private.new_user();

create table public.currencies (
  code text primary key check (code ~ '^[A-Z]{3}$'),
  minor_units smallint not null check (minor_units between 0 and 4)
);
create table public.countries (
  code text primary key check (code ~ '^[A-Z]{2}$'),
  names jsonb not null,
  currency_code text not null references public.currencies(code)
);
create table public.cities (
  id bigint generated always as identity primary key,
  country_code text not null references public.countries(code),
  names jsonb not null,
  timezone text not null,
  unique (country_code, names)
);
create table public.categories (
  slug text primary key,
  names jsonb not null,
  position integer not null,
  active boolean not null default true
);
create table public.organizer_applications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id),
  name text not null check (length(trim(name)) between 2 and 120),
  contact text not null check (length(trim(contact)) between 5 and 250),
  description text not null check (length(trim(description)) between 20 and 3000),
  accepted_terms_at timestamptz not null default now(),
  status text not null default 'pending' check(status in ('pending','approved','rejected')),
  reviewed_by uuid references public.profiles(id),
  reviewed_at timestamptz,
  created_at timestamptz not null default now()
);
create unique index one_pending_application on public.organizer_applications(user_id) where status = 'pending';
create table public.organizer_profiles (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null unique references public.profiles(id),
  name text not null,
  description text not null,
  approved boolean not null default false
);
create table public.events (
  id uuid primary key default gen_random_uuid(),
  organizer_id uuid not null references public.organizer_profiles(id),
  category_slug text not null references public.categories(slug),
  original_language text not null check(original_language in ('ru','uz','en')),
  status text not null default 'draft' check(status in ('draft','published','hidden','cancelled')),
  city_id bigint not null references public.cities(id),
  format text not null check(format in ('online','offline')),
  address text not null default '',
  age_limit smallint not null default 0 check(age_limit between 0 and 21),
  created_at timestamptz not null default now()
);
create index event_catalog on public.events(status,city_id,category_slug);
create table public.event_translations (
  event_id uuid not null references public.events(id) on delete cascade,
  language text not null check(language in ('ru','uz','en')),
  title text not null check(length(trim(title)) between 2 and 200),
  description text not null check(length(trim(description)) between 20 and 15000),
  primary key(event_id,language)
);
create index event_titles on public.event_translations using gin(to_tsvector('simple',title || ' ' || description));
create table public.event_occurrences (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references public.events(id) on delete cascade,
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  timezone text not null,
  check(ends_at > starts_at)
);
create index occurrence_date on public.event_occurrences(starts_at,event_id);
-- Online admission links deliberately have no public read policy.
create table public.event_access (
  occurrence_id uuid primary key references public.event_occurrences(id) on delete cascade,
  join_url text not null check(join_url like 'https://%')
);
create table public.favorites (
  user_id uuid not null references public.profiles(id) on delete cascade,
  event_id uuid not null references public.events(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key(user_id,event_id)
);
create index favorites_event on public.favorites(event_id);

create function private.owns_organizer(p_id uuid) returns boolean language sql stable security definer
set search_path = '' as $$
  select private.active_user() and exists(select 1 from public.organizer_profiles
  where id = p_id and owner_id = auth.uid() and approved)
$$;
create function private.can_read_event(p_id uuid) returns boolean language sql stable security definer
set search_path = '' as $$
  select exists(select 1 from public.events e where e.id = p_id and
    (e.status = 'published' or private.owns_organizer(e.organizer_id) or private.is_admin()))
$$;
do $$ declare t text; begin
  foreach t in array array['profiles','user_roles','account_restrictions','audit_logs','currencies','countries','cities','categories','organizer_applications','organizer_profiles','events','event_translations','event_occurrences','event_access','favorites'] loop
    execute format('alter table public.%I enable row level security',t);
    execute format('revoke all on public.%I from anon, authenticated',t);
  end loop;
end $$;
grant usage on schema public to anon, authenticated;
grant select on public.currencies,public.countries,public.cities,public.categories,
  public.organizer_profiles,public.events,public.event_translations,public.event_occurrences to anon,authenticated;
grant select on public.profiles,public.user_roles,public.organizer_applications,public.favorites,public.audit_logs to authenticated;
grant update(display_name) on public.profiles to authenticated;
grant insert(user_id,event_id),delete on public.favorites to authenticated;
create policy own_profile on public.profiles for select to authenticated using(id = auth.uid());
create policy edit_profile on public.profiles for update to authenticated using(id = auth.uid() and private.active_user()) with check(id = auth.uid());
create policy own_roles on public.user_roles for select to authenticated using(user_id = auth.uid());
create policy read_currencies on public.currencies for select using(true);
create policy read_countries on public.countries for select using(true);
create policy read_cities on public.cities for select using(true);
create policy read_categories on public.categories for select using(active);
create policy read_organizers on public.organizer_profiles for select using(approved or owner_id = auth.uid() or private.is_admin());
create policy read_events on public.events for select using(status = 'published' or private.owns_organizer(organizer_id) or private.is_admin());
create policy read_translations on public.event_translations for select using(private.can_read_event(event_id));
create policy read_occurrences on public.event_occurrences for select using(private.can_read_event(event_id));
create policy read_applications on public.organizer_applications for select to authenticated using(user_id = auth.uid() or private.is_admin());
create policy read_audit on public.audit_logs for select to authenticated using(private.is_admin());
create policy read_favorites on public.favorites for select to authenticated using(user_id = auth.uid() and private.active_user());
create policy insert_favorites on public.favorites for insert to authenticated with check(user_id = auth.uid() and private.active_user() and exists(select 1 from public.events where id = event_id and status = 'published'));
create policy delete_favorites on public.favorites for delete to authenticated using(user_id = auth.uid() and private.active_user());

create function public.submit_organizer_application(p_name text,p_contact text,p_description text,p_accept_terms boolean)
returns uuid language plpgsql security definer set search_path = '' as $$
declare result uuid;
begin
  if not private.active_user() then raise exception 'UNAUTHORIZED' using errcode='42501'; end if;
  if p_accept_terms is distinct from true then raise exception 'TERMS_REQUIRED'; end if;
  if not exists(select 1 from auth.users where id=auth.uid() and (email_confirmed_at is not null or phone_confirmed_at is not null)) then raise exception 'CONTACT_NOT_VERIFIED'; end if;
  if exists(select 1 from public.organizer_profiles where owner_id=auth.uid() and approved) then raise exception 'ALREADY_ORGANIZER'; end if;
  if (select count(*) from public.organizer_applications where user_id=auth.uid() and created_at>now()-interval '1 day') >= 3 then raise exception 'RATE_LIMIT'; end if;
  insert into public.organizer_applications(user_id,name,contact,description) values(auth.uid(),p_name,p_contact,p_description) returning id into result;
  return result;
end $$;
create function public.review_organizer_application(p_id uuid,p_approve boolean)
returns void language plpgsql security definer set search_path = '' as $$
declare a public.organizer_applications;
begin
  if not private.is_admin() then raise exception 'FORBIDDEN' using errcode='42501'; end if;
  if p_approve is null then raise exception 'DECISION_REQUIRED'; end if;
  select * into a from public.organizer_applications where id=p_id for update;
  if a.id is null or a.status <> 'pending' then raise exception 'NOT_PENDING'; end if;
  if exists(select 1 from public.account_restrictions where user_id=a.user_id) then raise exception 'ACCOUNT_RESTRICTED'; end if;
  update public.organizer_applications set status=case when p_approve then 'approved' else 'rejected' end, reviewed_by=auth.uid(),reviewed_at=now() where id=p_id;
  if p_approve then
    insert into public.organizer_profiles(owner_id,name,description,approved) values(a.user_id,a.name,a.description,true)
    on conflict(owner_id) do update set name=excluded.name,description=excluded.description,approved=true;
    insert into public.user_roles(user_id,role) values(a.user_id,'organizer') on conflict do nothing;
  end if;
  insert into public.audit_logs(actor_id,action,entity_id,details) values(auth.uid(),'organizer.review',p_id,jsonb_build_object('approved',p_approve));
end $$;
create function public.create_event_draft(p_category text,p_city bigint,p_language text,p_title text,p_description text,p_format text,p_address text,p_start timestamptz,p_end timestamptz,p_timezone text)
returns uuid language plpgsql security definer set search_path = '' as $$
declare org uuid; result uuid;
begin
  if not private.active_user() then raise exception 'UNAUTHORIZED' using errcode='42501'; end if;
  select id into org from public.organizer_profiles where owner_id=auth.uid() and approved;
  if org is null then raise exception 'ORGANIZER_REQUIRED' using errcode='42501'; end if;
  if not exists(select 1 from pg_catalog.pg_timezone_names where name=p_timezone) then raise exception 'INVALID_TIMEZONE'; end if;
  if p_start <= now() then raise exception 'START_IN_PAST'; end if;
  if not exists(select 1 from public.categories where slug=p_category and active) then raise exception 'INVALID_CATEGORY'; end if;
  if (select count(*) from public.events where organizer_id=org and created_at>now()-interval '1 day') >= 50 then raise exception 'RATE_LIMIT'; end if;
  insert into public.events(organizer_id,category_slug,original_language,city_id,format,address)
  values(org,p_category,p_language,p_city,p_format,p_address) returning id into result;
  insert into public.event_translations values(result,p_language,p_title,p_description);
  insert into public.event_occurrences(event_id,starts_at,ends_at,timezone) values(result,p_start,p_end,p_timezone);
  insert into public.audit_logs(actor_id,action,entity_id) values(auth.uid(),'event.create',result);
  return result;
end $$;
create function public.publish_event(p_id uuid) returns void language plpgsql security definer set search_path = '' as $$
declare e public.events;
begin
  select * into e from public.events where id=p_id for update;
  if e.id is null or not private.owns_organizer(e.organizer_id) then raise exception 'FORBIDDEN' using errcode='42501'; end if;
  if e.status <> 'draft' then raise exception 'NOT_DRAFT'; end if;
  if e.format='offline' and length(trim(e.address)) < 3 then raise exception 'ADDRESS_REQUIRED'; end if;
  if not exists(select 1 from public.categories where slug=e.category_slug and active) then raise exception 'INVALID_CATEGORY'; end if;
  if not exists(select 1 from public.event_translations where event_id=p_id and language=e.original_language) then raise exception 'TRANSLATION_REQUIRED'; end if;
  if not exists(select 1 from public.event_occurrences where event_id=p_id and starts_at>now()) then raise exception 'FUTURE_OCCURRENCE_REQUIRED'; end if;
  update public.events set status='published' where id=p_id;
  insert into public.audit_logs(actor_id,action,entity_id) values(auth.uid(),'event.publish',p_id);
end $$;

-- Runs as caller: RLS is applied even if the client alters request parameters.
create function public.search_events(p_query text default '',p_city bigint default null,p_category text default null,p_language text default 'ru',p_offset integer default 0)
returns table(id uuid,title text,description text,content_language text,category_slug text,city_id bigint,city_name text,format text,address text,starts_at timestamptz,ends_at timestamptz,timezone text,organizer_name text)
language sql stable security invoker set search_path = '' as $$
  select e.id,t.title,t.description,t.language,e.category_slug,e.city_id,
    coalesce(c.names->>p_language,c.names->>'ru'),e.format,e.address,o.starts_at,o.ends_at,o.timezone,org.name
  from public.events e
  join public.cities c on c.id=e.city_id
  join public.organizer_profiles org on org.id=e.organizer_id
  join lateral (select et.* from public.event_translations et where et.event_id=e.id
    and et.language in (p_language,e.original_language)
    order by (et.language=p_language) desc limit 1) t on true
  join lateral (select eo.* from public.event_occurrences eo where eo.event_id=e.id and eo.ends_at>now()
    order by eo.starts_at,eo.id limit 1) o on true
  where e.status='published' and (p_city is null or e.city_id=p_city)
    and (p_category is null or e.category_slug=p_category)
    and (coalesce(trim(p_query),'')='' or to_tsvector('simple',t.title || ' ' || t.description) @@ plainto_tsquery('simple',left(p_query,200)))
  order by o.starts_at,e.id limit 30 offset greatest(0,least(coalesce(p_offset,0),10000))
$$;

revoke all on all functions in schema private from public,anon,authenticated;
grant usage on schema private to anon,authenticated;
grant execute on function private.active_user(),private.is_admin(),private.owns_organizer(uuid),private.can_read_event(uuid) to anon,authenticated;
revoke all on function public.submit_organizer_application(text,text,text,boolean),public.review_organizer_application(uuid,boolean),public.create_event_draft(text,bigint,text,text,text,text,text,timestamptz,timestamptz,text),public.publish_event(uuid),public.search_events(text,bigint,text,text,integer) from public,anon,authenticated;
grant execute on function public.submit_organizer_application(text,text,text,boolean),public.review_organizer_application(uuid,boolean),public.create_event_draft(text,bigint,text,text,text,text,text,timestamptz,timestamptz,text),public.publish_event(uuid) to authenticated;
grant execute on function public.search_events(text,bigint,text,text,integer) to anon,authenticated;
commit;
