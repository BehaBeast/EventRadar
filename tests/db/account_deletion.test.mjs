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
for (const m of ['202611070001_foundation', '202611070002_reference_data', '202611070003_map_push_payments', '202611250001_account_deletion']) {
  await db.exec(await readFile(new URL(`../../supabase/migrations/${m}.sql`, import.meta.url), 'utf8'));
}
for (const id of Object.values(ids)) {
  await db.query('insert into auth.users(id,email_confirmed_at) values($1,$2)', [id, new Date()]);
}
await db.query("insert into public.user_roles values($1,'admin')", [ids.admin]);

async function as(user, sql, params = []) {
  await db.exec('reset role');
  await db.query("select set_config('request.jwt.claim.sub',$1,false)", [ids[user] ?? '']);
  await db.exec(`set role ${user === 'guest' ? 'anon' : 'authenticated'}`);
  try { return await db.query(sql, params); } finally { await db.exec('reset role'); }
}
const count = async (sql, params) => (await db.query(sql, params)).rows.length;
const city = (await db.query('select id from cities order by id limit 1')).rows[0].id;

test('account deletion', async t => {
  await t.test('guest cannot call it', () =>
    assert.rejects(() => as('guest', 'select delete_own_account()')));

  await t.test('pending applicant deletes account with all data', async () => {
    const app = (await as('bob', "select submit_organizer_application('Org','b@b.c','Description of activities here',true) as id")).rows[0].id;
    await as('admin', 'select review_organizer_application($1,false)', [app]);
    await as('bob', 'select delete_own_account()');
    assert.equal(await count('select 1 from auth.users where id=$1', [ids.bob]), 0);
    assert.equal(await count('select 1 from profiles where id=$1', [ids.bob]), 0);
    assert.equal(await count('select 1 from organizer_applications where user_id=$1', [ids.bob]), 0);
  });

  await t.test('organizer with events is refused', async () => {
    const app = (await as('alice', "select submit_organizer_application('Org','a@b.c','Description of activities here',true) as id")).rows[0].id;
    await as('admin', 'select review_organizer_application($1,true)', [app]);
    await as('alice', "select create_event_draft('music',$1,'ru','Концерт джаза','Живой концерт джаза в городском зале','offline','Main hall',now()+interval '1 day',now()+interval '2 days','Asia/Tashkent')", [city]);
    await assert.rejects(() => as('alice', 'select delete_own_account()'), /ORGANIZER_HAS_EVENTS/);
    assert.equal(await count('select 1 from auth.users where id=$1', [ids.alice]), 1);
  });

  await t.test('reviewer reference is cleared when admin deletes account', async () => {
    await as('admin', 'select delete_own_account()');
    assert.equal(await count('select 1 from organizer_applications where reviewed_by=$1', [ids.admin]), 0);
    assert.equal(await count('select 1 from auth.users where id=$1', [ids.admin]), 0);
  });
  await db.close();
});
