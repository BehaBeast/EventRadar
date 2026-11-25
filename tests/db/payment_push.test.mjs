import { PGlite } from '@electric-sql/pglite';
import { readFile } from 'node:fs/promises';
import assert from 'node:assert/strict';
import { test } from 'node:test';

const db = new PGlite();
const ids = {
  alice: '00000000-0000-0000-0000-000000000001',
  bob: '00000000-0000-0000-0000-000000000002',
  admin: '00000000-0000-0000-0000-000000000003',
};

await db.exec(`create role anon; create role authenticated; create schema auth;
create table auth.users(id uuid primary key,raw_user_meta_data jsonb default '{}',email_confirmed_at timestamptz,phone_confirmed_at timestamptz);
create function auth.uid() returns uuid language sql stable as $$ select nullif(current_setting('request.jwt.claim.sub',true),'')::uuid $$;
grant usage on schema auth to anon,authenticated; grant execute on function auth.uid() to anon,authenticated;`);

await db.exec(await readFile(new URL('../../supabase/migrations/202611070001_foundation.sql', import.meta.url), 'utf8'));
await db.exec(await readFile(new URL('../../supabase/migrations/202611070002_reference_data.sql', import.meta.url), 'utf8'));
await db.exec(await readFile(new URL('../../supabase/migrations/202611070003_map_push_payments.sql', import.meta.url), 'utf8'));

for (const [name, id] of Object.entries(ids)) {
  await db.query('insert into auth.users(id,email_confirmed_at) values($1,$2)', [id, new Date()]);
}
await db.query("insert into public.user_roles values($1,'admin')", [ids.admin]);

async function as(user, sql, params = []) {
  await db.exec('reset role');
  await db.query("select set_config('request.jwt.claim.sub',$1,false)", [ids[user] ?? '']);
  await db.exec(`set role ${user === 'guest' ? 'anon' : 'authenticated'}`);
  try {
    return await db.query(sql, params);
  } finally {
    await db.exec('reset role');
  }
}

async function fails(user, sql, params = [], message) {
  await assert.rejects(() => as(user, sql, params), message);
}

test('map, push and payments migration', async (t) => {
  let eventId, tierId;

  await t.test('setup organizer and published event with geo coordinates', async () => {
    const app = (await as('alice', "select submit_organizer_application('Concerts Org','org@test.uz','Organizer description here',true) as id")).rows[0].id;
    await as('admin', 'select review_organizer_application($1,true)', [app]);

    const city = (await db.query('select id from cities order by id limit 1')).rows[0].id;
    const start = new Date(Date.now() + 86400000).toISOString();
    const end = new Date(Date.now() + 90000000).toISOString();

    eventId = (await as('alice', `select create_event_draft('music', $1, 'ru', 'Концерт в Ташкенте', 'Живая музыка на открытой площадке', 'offline', 'Улица Навои, 1', $2, $3, 'Asia/Tashkent') as id`, [city, start, end])).rows[0].id;

    // Map geo coordinates
    await db.query('update public.events set latitude = 41.2995, longitude = 69.2401 where id = $1', [eventId]);
    await as('alice', 'select publish_event($1)', [eventId]);

    const event = (await as('guest', 'select latitude, longitude from events where id = $1', [eventId])).rows[0];
    assert.equal(event.latitude, 41.2995);
    assert.equal(event.longitude, 69.2401);
  });

  await t.test('create ticket tier and purchase via payment RPC', async () => {
    const tierRes = await db.query(
      `insert into public.ticket_tiers(event_id, name, price, quantity_total) values($1, 'Стандарт', 150000, 100) returning id`,
      [eventId]
    );
    tierId = tierRes.rows[0].id;

    // Bob purchases 2 tickets
    const orderRes = await as('bob', 'select create_ticket_order($1, $2, 2, $3) as result', [eventId, tierId, 'payme']);
    const result = orderRes.rows[0].result;
    assert.equal(result.status, 'paid');
    assert.equal(result.quantity, 2);
    assert.equal(result.total_amount, 300000);

    // Verify Bob's tickets
    const tickets = (await as('bob', 'select * from tickets where user_id = $1', [ids.bob])).rows;
    assert.equal(tickets.length, 2);
    assert.ok(tickets[0].qr_code.includes('EVENTRADAR:TICKET'));

    // Verify Alice cannot see Bob's tickets (RLS)
    const aliceTickets = (await as('alice', 'select * from tickets where user_id = $1', [ids.bob])).rows;
    assert.equal(aliceTickets.length, 0);

    // Verify Notification generated for Bob
    const notifs = (await as('bob', 'select * from notifications where user_id = $1', [ids.bob])).rows;
    assert.equal(notifs.length, 1);
    assert.equal(notifs[0].type, 'ticket');
  });

  await t.test('register and manage push token', async () => {
    await as('bob', "insert into user_push_tokens(user_id, token, platform) values($1, 'fcm_bob_test_token_123', 'android')", [ids.bob]);
    const tokens = (await as('bob', 'select token from user_push_tokens')).rows;
    assert.equal(tokens.length, 1);
    assert.equal(tokens[0].token, 'fcm_bob_test_token_123');

    // Alice cannot see Bob's token
    const aliceSeenTokens = (await as('alice', 'select * from user_push_tokens where user_id = $1', [ids.bob])).rows;
    assert.equal(aliceSeenTokens.length, 0);
  });

  await t.test('sold out handling in payment order RPC', async () => {
    const limitedTier = (await db.query(
      `insert into public.ticket_tiers(event_id, name, price, quantity_total) values($1, 'VIP Лимит', 500000, 1) returning id`,
      [eventId]
    )).rows[0].id;

    // 1st purchase succeeds
    await as('bob', 'select create_ticket_order($1, $2, 1, $3)', [eventId, limitedTier, 'click']);

    // 2nd purchase fails because sold out
    await fails('alice', 'select create_ticket_order($1, $2, 1, $3)', [eventId, limitedTier, 'click'], /SOLD_OUT/);
  });
});

