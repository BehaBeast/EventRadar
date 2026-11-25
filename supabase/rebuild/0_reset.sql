-- DANGER: wipes everything in the public and private schemas of this Supabase project.
-- Auth users are kept. Run once in SQL Editor, then 1_migrations.sql, then 2_seed_events.sql.
drop schema if exists private cascade;
drop schema if exists public cascade;
create schema public;
grant usage on schema public to postgres, anon, authenticated, service_role;
grant all on schema public to postgres, service_role;
alter default privileges in schema public grant all on tables to postgres, service_role;
alter default privileges in schema public grant all on functions to postgres, service_role;
alter default privileges in schema public grant all on sequences to postgres, service_role;
