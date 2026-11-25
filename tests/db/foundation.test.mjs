import { PGlite } from '@electric-sql/pglite';
import { readFile } from 'node:fs/promises';
import assert from 'node:assert/strict';
import { test } from 'node:test';

// Isolated PostgreSQL WASM test database. Supabase Auth is represented only by
// its users table and auth.uid() contract; never deploy this bootstrap.
const db = new PGlite();
const ids = {
  alice:'00000000-0000-0000-0000-000000000001',
  bob:'00000000-0000-0000-0000-000000000002',
  admin:'00000000-0000-0000-0000-000000000003',
  unverified:'00000000-0000-0000-0000-000000000004',
};
await db.exec(`create role anon; create role authenticated; create schema auth;
create table auth.users(id uuid primary key,raw_user_meta_data jsonb default '{}',email_confirmed_at timestamptz,phone_confirmed_at timestamptz);
create function auth.uid() returns uuid language sql stable as $$ select nullif(current_setting('request.jwt.claim.sub',true),'')::uuid $$;
grant usage on schema auth to anon,authenticated; grant execute on function auth.uid() to anon,authenticated;`);
await db.exec(await readFile(new URL('../../supabase/migrations/202611070001_foundation.sql',import.meta.url),'utf8'));
await db.exec(await readFile(new URL('../../supabase/migrations/202611070002_reference_data.sql',import.meta.url),'utf8'));
for(const [name,id] of Object.entries(ids)) await db.query('insert into auth.users(id,email_confirmed_at) values($1,$2)',[id,name==='unverified'?null:new Date()]);
await db.query("insert into public.user_roles values($1,'admin')",[ids.admin]);
async function as(user,sql,params=[]){
 await db.exec('reset role');
 await db.query("select set_config('request.jwt.claim.sub',$1,false)",[ids[user]??'']);
 await db.exec(`set role ${user==='guest'?'anon':'authenticated'}`);
 try{return await db.query(sql,params);} finally{await db.exec('reset role');}
}
async function fails(user,sql,params=[],message){await assert.rejects(()=>as(user,sql,params),message);}
const city=(await db.query('select id from cities order by id limit 1')).rows[0].id;
let application,event;

test('foundation database permissions and workflow',async t=>{
 await t.test('signup trigger creates private profile',async()=>{
  assert.equal((await as('alice','select * from profiles')).rows.length,1);
  assert.equal((await as('alice','select * from profiles')).rows[0].id,ids.alice);
 });
 await t.test('guest cannot access profiles',()=>fails('guest','select * from profiles'));
 await t.test('user cannot grant own admin role',()=>fails('alice',"insert into user_roles values($1,'admin')",[ids.alice]));
 await t.test('profile name editable, identity immutable',async()=>{
  await as('alice',"update profiles set display_name='Alice' where id=$1",[ids.alice]);
  await fails('alice','update profiles set id=$1',[ids.bob]);
 });
 await t.test('unverified application rejected',()=>fails('unverified',"select submit_organizer_application('Org','a@b.c','Description of activities here',true)",[],/CONTACT_NOT_VERIFIED/));
 await t.test('terms must be explicitly accepted',()=>fails('alice',"select submit_organizer_application('Org','a@b.c','Description of activities here',null)",[],/TERMS_REQUIRED/));
 await t.test('verified user submits application',async()=>{
  application=(await as('alice',"select submit_organizer_application('Org','a@b.c','Description of activities here',true) as id")).rows[0].id;
 });
 await t.test('duplicate pending application rejected',()=>fails('alice',"select submit_organizer_application('Org','a@b.c','Description of activities here',true)"));
 await t.test('applicant cannot self approve',()=>fails('alice','select review_organizer_application($1,true)',[application],/FORBIDDEN/));
 await t.test('applications are private',async()=>assert.equal((await as('bob','select * from organizer_applications')).rows.length,0));
 await t.test('admin approval is audited and creates organizer',async()=>{
  await as('admin','select review_organizer_application($1,true)',[application]);
  assert.equal((await as('admin',"select * from audit_logs where action='organizer.review'")).rows.length,1);
 });
 await t.test('approval cannot be repeated',()=>fails('admin','select review_organizer_application($1,true)',[application],/NOT_PENDING/));
 const create="select create_event_draft('music',$1,'ru','Концерт джаза','Живой концерт джаза в городском зале','offline','Main hall',now()+interval '1 day',now()+interval '2 days',$2) as id";
 await t.test('ordinary visitor cannot create event',()=>fails('bob',create,[city,'Asia/Tashkent'],/ORGANIZER_REQUIRED/));
 await t.test('invalid timezone rejected',()=>fails('alice',create,[city,'not/a/zone'],/INVALID_TIMEZONE/));
 await t.test('approved organizer creates private draft',async()=>{
  event=(await as('alice',create,[city,'Asia/Tashkent'])).rows[0].id;
  assert.equal((await as('guest','select * from events')).rows.length,0);
  assert.equal((await as('guest','select * from event_translations')).rows.length,0);
  assert.equal((await as('guest','select * from event_occurrences')).rows.length,0);
  assert.equal((await as('alice','select * from events')).rows.length,1);
 });
 await t.test('other user cannot publish draft',()=>fails('bob','select publish_event($1)',[event],/FORBIDDEN/));
 await t.test('direct event mutation denied',()=>fails('alice',"update events set status='published' where id=$1",[event]));
 await t.test('owner publishes and guest can search',async()=>{
  await as('alice','select publish_event($1)',[event]);
  const rows=(await as('guest',"select * from search_events('джаза',null,null,'en')")).rows;
  assert.equal(rows.length,1); assert.equal(rows[0].content_language,'ru');
  assert.equal(rows[0].timezone,'Asia/Tashkent');
  assert.equal((await as('guest',"select * from search_events('unmatched')")).rows.length,0);
 });
 await t.test('online access table is private even for organizer',()=>fails('alice','select * from event_access'));
 await t.test('favorite is stored once and only for self',async()=>{
  await as('alice','insert into favorites(user_id,event_id) values($1,$2)',[ids.alice,event]);
  await fails('alice','insert into favorites(user_id,event_id) values($1,$2)',[ids.alice,event]);
  await fails('bob','insert into favorites(user_id,event_id) values($1,$2)',[ids.alice,event]);
  assert.equal((await as('bob','select * from favorites')).rows.length,0);
  assert.equal((await as('alice','select * from favorites')).rows.length,1);
 });
 await t.test('audit log cannot be forged or read by visitor',async()=>{
  await fails('alice',"insert into audit_logs(action) values('fake')");
  assert.equal((await as('alice','select * from audit_logs')).rows.length,0);
 });
 await t.test('blocked account cannot write',async()=>{
  await db.query("insert into account_restrictions(user_id,reason) values($1,'test')",[ids.alice]);
  assert.equal((await as('alice',"update profiles set display_name='Blocked' returning id")).rows.length,0);
  await fails('alice',create,[city,'Asia/Tashkent'],/UNAUTHORIZED/);
 });
 await t.test('all public tables have RLS',async()=>{
  const rows=(await db.query("select relname from pg_class c join pg_namespace n on n.oid=c.relnamespace where n.nspname='public' and relkind='r' and not relrowsecurity")).rows;
  assert.deepEqual(rows,[]);
 });
 await db.close();
});
