-- NPL shared live database schema (Supabase/PostgreSQL)
-- Apply in Supabase SQL Editor. Public access is read-only until scorer auth policies are added.
create extension if not exists pgcrypto;
create table if not exists public.schools (
 id uuid primary key default gen_random_uuid(), name text not null unique,
 district text, is_active boolean not null default true, created_at timestamptz not null default now()
);
create table if not exists public.matches (
 id uuid primary key default gen_random_uuid(), school_id uuid not null references public.schools(id),
 team_a text not null, team_b text not null, overs_per_innings int not null check(overs_per_innings between 1 and 50),
 venue text, scheduled_at timestamptz, status text not null default 'UPCOMING' check(status in ('UPCOMING','LIVE','COMPLETED','ABANDONED')),
 toss_winner text, toss_decision text check(toss_decision in ('BAT','BOWL')), created_at timestamptz not null default now()
);
create table if not exists public.innings (
 id uuid primary key default gen_random_uuid(), match_id uuid not null references public.matches(id) on delete cascade,
 innings_number int not null check(innings_number in (1,2)), batting_team text not null,
 runs int not null default 0 check(runs>=0), wickets int not null default 0 check(wickets between 0 and 10),
 legal_balls int not null default 0 check(legal_balls>=0), is_complete boolean not null default false,
 unique(match_id,innings_number)
);
create table if not exists public.deliveries (
 id uuid primary key default gen_random_uuid(), innings_id uuid not null references public.innings(id) on delete cascade,
 sequence_no int not null, batter text, bowler text,
 event_type text not null check(event_type in ('RUN','WICKET','WIDE','NO_BALL','BYE','LEG_BYE','PENALTY')),
 bat_runs int not null default 0 check(bat_runs between 0 and 6), extra_runs int not null default 0 check(extra_runs>=0),
 legal_ball boolean not null default true, dismissal text, created_at timestamptz not null default now(),
 unique(innings_id,sequence_no)
);
alter table public.schools enable row level security;
alter table public.matches enable row level security;
alter table public.innings enable row level security;
alter table public.deliveries enable row level security;
create policy "public read active schools" on public.schools for select using(is_active=true);
create policy "public read matches" on public.matches for select using(true);
create policy "public read innings" on public.innings for select using(true);
create policy "public read deliveries" on public.deliveries for select using(true);
alter publication supabase_realtime add table public.matches;
alter publication supabase_realtime add table public.innings;
alter publication supabase_realtime add table public.deliveries;
