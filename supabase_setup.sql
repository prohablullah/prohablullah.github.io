-- Hablullah El Masry | HSC 2028
-- Supabase Dashboard > SQL Editor > New query > paste all > Run.
-- Run this only in your NEW project. Review SQL before running.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  role text not null default 'student' check (role in ('student','teacher','admin')),
  created_at timestamptz not null default now()
);
alter table public.profiles enable row level security;

create table if not exists public.notes (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  subject text,
  chapter text,
  resource_type text not null default 'Link' check (resource_type in ('PDF','Video','Link','Image')),
  resource_url text not null,
  description text,
  published boolean not null default false,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now()
);
alter table public.notes enable row level security;

create table if not exists public.exams (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  subject text,
  questions jsonb not null default '[]'::jsonb,
  total_marks numeric not null default 0 check (total_marks >= 0),
  duration_minutes integer not null default 20 check (duration_minutes between 1 and 240),
  published boolean not null default false,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now()
);
alter table public.exams enable row level security;

create table if not exists public.results (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  exam_id uuid references public.exams(id) on delete set null,
  exam_title text,
  score numeric not null default 0 check (score >= 0),
  total_marks numeric not null default 0 check (total_marks >= 0),
  answers jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);
alter table public.results enable row level security;

create table if not exists public.site_settings (
  id integer primary key default 1 check (id = 1),
  site_title text not null default 'Hablullah El Masry | HSC 2028',
  tagline text not null default 'Learn Smart. Grow Every Day.',
  announcement text not null default '',
  announcement_enabled boolean not null default false,
  updated_by uuid references auth.users(id) on delete set null,
  updated_at timestamptz not null default now()
);
alter table public.site_settings enable row level security;
insert into public.site_settings (id) values (1) on conflict (id) do nothing;

-- Profile creation from Supabase Auth. Role is always student at signup.
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = ''
as $$
begin
  insert into public.profiles (id, full_name, role)
  values (new.id, coalesce(new.raw_user_meta_data ->> 'full_name','Student'), 'student')
  on conflict (id) do nothing;
  return new;
end;
$$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
for each row execute procedure public.handle_new_user();

-- Safe role helper; callers cannot set their own role through public profile updates.
create or replace function public.is_staff()
returns boolean language sql stable security definer set search_path = ''
as $$
  select exists (
    select 1 from public.profiles p
    where p.id = (select auth.uid()) and p.role in ('admin','teacher')
  );
$$;
create or replace function public.is_admin()
returns boolean language sql stable security definer set search_path = ''
as $$
  select exists (
    select 1 from public.profiles p
    where p.id = (select auth.uid()) and p.role = 'admin'
  );
$$;
revoke all on function public.is_staff() from public;
revoke all on function public.is_admin() from public;
grant execute on function public.is_staff() to authenticated;
grant execute on function public.is_admin() to authenticated;

-- Policies: students can see published resources; staff manage content.
drop policy if exists "profile read self or staff" on public.profiles;
create policy "profile read self or staff" on public.profiles for select to authenticated
using (id = (select auth.uid()) or public.is_staff());
drop policy if exists "profile update own name only" on public.profiles;
create policy "profile update own name only" on public.profiles for update to authenticated
using (id = (select auth.uid()))
with check (id = (select auth.uid()) and role = (select role from public.profiles p where p.id = (select auth.uid())));
drop policy if exists "admin update profiles" on public.profiles;
create policy "admin update profiles" on public.profiles for update to authenticated
using (public.is_admin()) with check (public.is_admin());

drop policy if exists "read published notes or staff" on public.notes;
create policy "read published notes or staff" on public.notes for select to authenticated
using (published = true or public.is_staff());
drop policy if exists "staff insert notes" on public.notes;
create policy "staff insert notes" on public.notes for insert to authenticated
with check (public.is_staff() and created_by = (select auth.uid()));
drop policy if exists "staff update notes" on public.notes;
create policy "staff update notes" on public.notes for update to authenticated
using (public.is_staff()) with check (public.is_staff());
drop policy if exists "staff delete notes" on public.notes;
create policy "staff delete notes" on public.notes for delete to authenticated
using (public.is_staff());

drop policy if exists "read published exams or staff" on public.exams;
create policy "read published exams or staff" on public.exams for select to authenticated
using (published = true or public.is_staff());
drop policy if exists "staff insert exams" on public.exams;
create policy "staff insert exams" on public.exams for insert to authenticated
with check (public.is_staff() and created_by = (select auth.uid()));
drop policy if exists "staff update exams" on public.exams;
create policy "staff update exams" on public.exams for update to authenticated
using (public.is_staff()) with check (public.is_staff());
drop policy if exists "staff delete exams" on public.exams;
create policy "staff delete exams" on public.exams for delete to authenticated
using (public.is_staff());

drop policy if exists "students read own results staff all" on public.results;
create policy "students read own results staff all" on public.results for select to authenticated
using (user_id = (select auth.uid()) or public.is_staff());
drop policy if exists "students insert own result" on public.results;
create policy "students insert own result" on public.results for insert to authenticated
with check (user_id = (select auth.uid()));
drop policy if exists "staff manage results" on public.results;
create policy "staff manage results" on public.results for all to authenticated
using (public.is_staff()) with check (public.is_staff());

drop policy if exists "read settings authenticated" on public.site_settings;
create policy "read settings authenticated" on public.site_settings for select to authenticated
using (true);
drop policy if exists "staff manage settings" on public.site_settings;
create policy "staff manage settings" on public.site_settings for all to authenticated
using (public.is_staff()) with check (public.is_staff());

-- Explicit grants for API access. RLS above limits rows/actions.
grant select, update on public.profiles to authenticated;
grant select, insert, update, delete on public.notes to authenticated;
grant select, insert, update, delete on public.exams to authenticated;
grant select, insert, update, delete on public.results to authenticated;
grant select, insert, update, delete on public.site_settings to authenticated;

-- IMPORTANT: first admin is set manually AFTER signing up with that account:
-- 1) Supabase > Authentication > Users: copy your own user UUID.
-- 2) Replace YOUR-USER-UUID below, then run this one statement separately:
-- update public.profiles set role = 'admin' where id = 'YOUR-USER-UUID';
-- Do not make any self-service "become admin" button.
