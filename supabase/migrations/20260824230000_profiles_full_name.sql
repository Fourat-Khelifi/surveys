-- ============================================================================
-- Profiles — a real home for the user's name
-- ============================================================================
--
-- Until now the display name lived only in auth.users.raw_user_meta_data, which
-- works but has two problems: it is not joinable (you cannot list responses
-- with the respondent's name without going through the Auth admin API), and it
-- is entirely user-controlled with no schema to validate against.
--
-- This gives the name a table. Note what is deliberately NOT here: any notion
-- of a balance. Points stay derived from completed responses. A profile row
-- holds only things it is safe for the user to edit, which is why the UPDATE
-- policy below can be permissive without opening anything.
--
-- Additive and idempotent.
-- ============================================================================

create table if not exists public.profiles (
  id         uuid primary key references auth.users (id) on delete cascade,
  created_at timestamptz not null default now()
);

-- A `profiles` table already existed on this project from an earlier attempt,
-- so everything below is written to bring whatever is there up to spec rather
-- than assuming a fresh table.

alter table public.profiles
  add column if not exists full_name text;

alter table public.profiles
  add column if not exists created_at timestamptz not null default now();

alter table public.profiles
  add column if not exists updated_at timestamptz not null default now();

alter table public.profiles
  drop constraint if exists full_name_length;

alter table public.profiles
  add constraint full_name_length check (
    full_name is null or char_length(btrim(full_name)) between 1 and 80
  );

-- The pre-existing table carried a `points` column. Nothing reads it — the
-- balance is derived from completed responses — and leaving it in place under
-- the permissive UPDATE policy below would hand every user a writable balance,
-- which is the exact bug this design exists to avoid.
--
-- Guarded rather than dropped blindly: if it somehow holds real values, this
-- stops and says so instead of destroying them.
do $$
declare v_total bigint;
begin
  if exists (
    select 1 from information_schema.columns
    where table_schema = 'public' and table_name = 'profiles'
      and column_name = 'points'
  ) then
    execute 'select coalesce(sum(points), 0) from public.profiles' into v_total;
    if v_total <> 0 then
      raise exception
        'profiles.points holds a non-zero total (%). Reconcile it before dropping.',
        v_total;
    end if;
    execute 'alter table public.profiles drop column points';
    raise notice 'dropped unused profiles.points column';
  end if;
end;
$$;

-- ── Keep updated_at honest ──────────────────────────────────────────────────

create or replace function public.touch_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists profiles_touch_updated_at on public.profiles;
create trigger profiles_touch_updated_at
  before update on public.profiles
  for each row execute function public.touch_updated_at();

-- ── Every auth user gets a profile ──────────────────────────────────────────
--
-- Reads either key: the app now sends `full_name`, but accounts created before
-- this migration have `display_name`. Falling back to the local part of the
-- email means a profile is never nameless, which is what stops the UI having to
-- render "User".

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, full_name)
  values (
    new.id,
    coalesce(
      nullif(btrim(new.raw_user_meta_data ->> 'full_name'), ''),
      nullif(btrim(new.raw_user_meta_data ->> 'display_name'), ''),
      initcap(replace(split_part(new.email, '@', 1), '.', ' '))
    )
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ── Backfill everyone who already exists ────────────────────────────────────

insert into public.profiles (id, full_name)
select
  u.id,
  coalesce(
    nullif(btrim(u.raw_user_meta_data ->> 'full_name'), ''),
    nullif(btrim(u.raw_user_meta_data ->> 'display_name'), ''),
    initcap(replace(split_part(u.email, '@', 1), '.', ' '))
  )
from auth.users u
on conflict (id) do nothing;

-- Fill in any profile that exists but has no name yet.
update public.profiles p
set full_name = coalesce(
      nullif(btrim(u.raw_user_meta_data ->> 'full_name'), ''),
      nullif(btrim(u.raw_user_meta_data ->> 'display_name'), ''),
      initcap(replace(split_part(u.email, '@', 1), '.', ' '))
    )
from auth.users u
where u.id = p.id
  and (p.full_name is null or btrim(p.full_name) = '');

-- The demo account, so the profile screen has something real to show.
update public.profiles p
set full_name = 'Test User'
from auth.users u
where u.id = p.id and u.email = 'test@mail.com';

-- ── Row Level Security ──────────────────────────────────────────────────────
--
-- Read and update your own row, nothing else. There is no INSERT policy: rows
-- are created by the SECURITY DEFINER trigger above, so a client cannot
-- fabricate a profile for a user id that does not exist.
--
-- UPDATE is safe to allow here only because the table holds nothing but a name.
-- If a balance or a role column is ever added, this policy must be narrowed to
-- specific columns first.

alter table public.profiles enable row level security;

drop policy if exists profiles_read_own on public.profiles;
create policy profiles_read_own on public.profiles
  for select to authenticated
  using (id = auth.uid());

drop policy if exists profiles_update_own on public.profiles;
create policy profiles_update_own on public.profiles
  for update to authenticated
  using (id = auth.uid())
  with check (id = auth.uid());

revoke insert, delete on public.profiles from anon, authenticated;

-- ── Check ───────────────────────────────────────────────────────────────────

select u.email, p.full_name, p.created_at
from public.profiles p
join auth.users u on u.id = p.id
order by p.created_at;
