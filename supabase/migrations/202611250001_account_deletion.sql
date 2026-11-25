begin;
-- Google Play: users must be able to delete their account and data from inside the app.
-- Deleting auth.users cascades to profiles, favorites, roles, orders, tickets, push tokens
-- and notifications. Organizer rows without cascade are removed explicitly; an organizer
-- with events must contact support so attendees are not left without an event owner.
create function public.delete_own_account() returns void
language plpgsql security definer set search_path = '' as $$
declare uid uuid := auth.uid();
begin
  if uid is null then raise exception 'AUTH_REQUIRED'; end if;
  if exists (
    select 1 from public.organizer_profiles o
    join public.events e on e.organizer_id = o.id
    where o.owner_id = uid
  ) then raise exception 'ORGANIZER_HAS_EVENTS'; end if;
  update public.organizer_applications set reviewed_by = null where reviewed_by = uid;
  delete from public.organizer_profiles where owner_id = uid;
  delete from public.organizer_applications where user_id = uid;
  delete from auth.users where id = uid;
end $$;
revoke all on function public.delete_own_account() from public, anon, authenticated;
grant execute on function public.delete_own_account() to authenticated;
commit;
