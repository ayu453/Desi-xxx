-- NPL Advanced Tournament Platform — Supabase/PostgreSQL
-- Apply to a NEW Supabase project. Never expose service_role keys in browser code.
create extension if not exists pgcrypto;
create table if not exists public.profiles (id uuid primary key references auth.users(id) on delete cascade, display_name text not null, created_at timestamptz not null default now());
create table if not exists public.schools (id uuid primary key default gen_random_uuid(), name text not null unique, district text not null, state text not null default 'Bihar', school_code text unique, is_active boolean not null default true, created_at timestamptz not null default now());
create table if not exists public.school_members (school_id uuid not null references public.schools(id) on delete cascade, user_id uuid not null references public.profiles(id) on delete cascade, role text not null check(role in ('SCHOOL_ADMIN','TOURNAMENT_ADMIN','SCORER','VERIFIER','VIEWER')), approved_by uuid references public.profiles(id), approved_at timestamptz, primary key(school_id,user_id));
create table if not exists public.tournaments (id uuid primary key default gen_random_uuid(), school_id uuid not null references public.schools(id), name text not null, season text, format text not null check(format in ('LEAGUE','ROUND_ROBIN','GROUP_KNOCKOUT','KNOCKOUT')), overs_per_innings int not null check(overs_per_innings between 1 and 50), points_win numeric(5,2) not null default 2, points_tie numeric(5,2) not null default 1, points_no_result numeric(5,2) not null default 1, status text not null default 'DRAFT' check(status in ('DRAFT','REGISTRATION','SCHEDULED','LIVE','COMPLETED','ARCHIVED')), start_date date, end_date date, created_by uuid references public.profiles(id), created_at timestamptz not null default now(), unique(school_id,name,season));
create table if not exists public.teams (id uuid primary key default gen_random_uuid(), tournament_id uuid not null references public.tournaments(id) on delete cascade, name text not null, short_name text, group_name text, seed int, created_at timestamptz not null default now(), unique(tournament_id,name), unique(tournament_id,short_name));
create table if not exists public.players (id uuid primary key default gen_random_uuid(), school_id uuid not null references public.schools(id), full_name text not null, class_label text, jersey_number int, batting_style text check(batting_style in ('RIGHT','LEFT')), bowling_style text, is_active boolean not null default true, created_at timestamptz not null default now());
create table if not exists public.team_players (team_id uuid not null references public.teams(id) on delete cascade, player_id uuid not null references public.players(id), squad_role text not null default 'PLAYER' check(squad_role in ('CAPTAIN','VICE_CAPTAIN','WICKET_KEEPER','PLAYER')), is_verified boolean not null default false, verified_by uuid references public.profiles(id), verified_at timestamptz, primary key(team_id,player_id));
create table if not exists public.matches (id uuid primary key default gen_random_uuid(), tournament_id uuid not null references public.tournaments(id) on delete cascade, team_a_id uuid not null references public.teams(id), team_b_id uuid not null references public.teams(id), stage text not null default 'LEAGUE', group_name text, round_number int, match_number int, venue text, scheduled_at timestamptz, status text not null default 'UPCOMING' check(status in ('UPCOMING','LIVE','INNINGS_BREAK','COMPLETED','ABANDONED')), toss_winner_team_id uuid references public.teams(id), toss_decision text check(toss_decision in ('BAT','BOWL')), elected_batting_team_id uuid references public.teams(id), winner_team_id uuid references public.teams(id), result_type text check(result_type in ('NORMAL','TIE','NO_RESULT','WALKOVER','ABANDONED')), result_margin int, result_margin_type text check(result_margin_type in ('RUNS','WICKETS')), player_of_match_id uuid references public.players(id), notes text, created_at timestamptz not null default now(), check(team_a_id<>team_b_id), unique(tournament_id,match_number));
create table if not exists public.match_officials (match_id uuid not null references public.matches(id) on delete cascade, user_id uuid not null references public.profiles(id), role text not null check(role in ('SCORER','UMPIRE','MATCH_REFEREE')), assigned_by uuid references public.profiles(id), primary key(match_id,user_id,role));
create table if not exists public.match_squads (match_id uuid not null references public.matches(id) on delete cascade, team_id uuid not null references public.teams(id), player_id uuid not null references public.players(id), is_playing_xi boolean not null default false, is_captain boolean not null default false, is_wicketkeeper boolean not null default false, primary key(match_id,player_id));
create table if not exists public.innings (id uuid primary key default gen_random_uuid(), match_id uuid not null references public.matches(id) on delete cascade, innings_number int not null check(innings_number between 1 and 4), batting_team_id uuid not null references public.teams(id), bowling_team_id uuid not null references public.teams(id), target_runs int, is_declared boolean not null default false, is_complete boolean not null default false, created_at timestamptz not null default now(), unique(match_id,innings_number), check(batting_team_id<>bowling_team_id));
create table if not exists public.deliveries (id uuid primary key default gen_random_uuid(), innings_id uuid not null references public.innings(id) on delete cascade, sequence_no int not null, over_number int not null check(over_number>=0), ball_in_over int not null check(ball_in_over between 1 and 20), batter_id uuid references public.players(id), non_striker_id uuid references public.players(id), bowler_id uuid references public.players(id), event_type text not null check(event_type in ('LEGAL','WIDE','NO_BALL','BYE','LEG_BYE','PENALTY')), bat_runs int not null default 0 check(bat_runs between 0 and 6), extra_runs int not null default 0 check(extra_runs>=0), is_wicket boolean not null default false, dismissal_type text check(dismissal_type in ('BOWLED','CAUGHT','LBW','RUN_OUT','STUMPED','HIT_WICKET','RETIRED_OUT','OBSTRUCTING_FIELD','TIMED_OUT','OTHER')), dismissed_player_id uuid references public.players(id), fielder_id uuid references public.players(id), commentary text, recorded_by uuid references public.profiles(id), created_at timestamptz not null default now(), unique(innings_id,sequence_no), check((is_wicket and dismissal_type is not null) or (not is_wicket and dismissal_type is null)));
create table if not exists public.scoring_audit (id uuid primary key default gen_random_uuid(), match_id uuid not null references public.matches(id) on delete cascade, innings_id uuid references public.innings(id) on delete cascade, delivery_id uuid references public.deliveries(id), actor_id uuid references public.profiles(id), action text not null check(action in ('ADD_DELIVERY','CORRECT_DELIVERY','DELETE_DELIVERY','CHANGE_MATCH_STATE','OVERRIDE_RESULT')), before_data jsonb, after_data jsonb, reason text, created_at timestamptz not null default now());
create index if not exists matches_tournament_status_idx on public.matches(tournament_id,status);
create index if not exists deliveries_innings_sequence_idx on public.deliveries(innings_id,sequence_no);
create index if not exists players_school_name_idx on public.players(school_id,full_name);

create or replace view public.innings_scorecard as
select i.id as innings_id,i.match_id,i.innings_number,i.batting_team_id,i.bowling_team_id,coalesce(sum(d.bat_runs+d.extra_runs),0)::int as total_runs,count(*) filter(where d.is_wicket)::int as wickets,count(*) filter(where d.event_type not in ('WIDE','NO_BALL'))::int as legal_balls,coalesce(sum(d.extra_runs) filter(where d.event_type in ('WIDE','NO_BALL','BYE','LEG_BYE','PENALTY')),0)::int as extras
from public.innings i left join public.deliveries d on d.innings_id=i.id group by i.id;
create or replace view public.batting_leaderboard as
select d.batter_id as player_id,i.match_id,i.batting_team_id as team_id,count(*) filter(where d.event_type<>'WIDE')::int as balls_faced,coalesce(sum(d.bat_runs),0)::int as runs,count(*) filter(where d.bat_runs=4)::int as fours,count(*) filter(where d.bat_runs=6)::int as sixes
from public.deliveries d join public.innings i on i.id=d.innings_id where d.batter_id is not null group by d.batter_id,i.match_id,i.batting_team_id;

create or replace function public.is_school_staff(target_school uuid) returns boolean language sql stable security definer set search_path=public as $$
 select exists(select 1 from public.school_members sm where sm.school_id=target_school and sm.user_id=auth.uid() and sm.role in ('SCHOOL_ADMIN','TOURNAMENT_ADMIN','SCORER','VERIFIER') and sm.approved_at is not null);
$$;
create or replace function public.can_manage_school(target_school uuid) returns boolean language sql stable security definer set search_path=public as $$
 select exists(select 1 from public.school_members sm where sm.school_id=target_school and sm.user_id=auth.uid() and sm.role in ('SCHOOL_ADMIN','TOURNAMENT_ADMIN') and sm.approved_at is not null);
$$;

alter table public.profiles enable row level security;
alter table public.schools enable row level security;
alter table public.school_members enable row level security;
alter table public.tournaments enable row level security;
alter table public.teams enable row level security;
alter table public.players enable row level security;
alter table public.team_players enable row level security;
alter table public.matches enable row level security;
alter table public.match_officials enable row level security;
alter table public.match_squads enable row level security;
alter table public.innings enable row level security;
alter table public.deliveries enable row level security;
alter table public.scoring_audit enable row level security;

do $$ declare p record; begin
 for p in select schemaname,tablename,policyname from pg_policies where schemaname='public'
 loop execute format('drop policy if exists %I on %I.%I',p.policyname,p.schemaname,p.tablename); end loop;
end $$;
create policy "profiles self read" on public.profiles for select using(id=auth.uid());
create policy "profiles self update" on public.profiles for update using(id=auth.uid()) with check(id=auth.uid());
create policy "public schools read" on public.schools for select using(is_active);
create policy "membership scoped read" on public.school_members for select using(user_id=auth.uid() or public.can_manage_school(school_id));
create policy "school admins manage memberships" on public.school_members for all using(public.can_manage_school(school_id)) with check(public.can_manage_school(school_id));
create policy "public tournaments read" on public.tournaments for select using(true);
create policy "staff manage tournaments" on public.tournaments for all using(public.is_school_staff(school_id)) with check(public.is_school_staff(school_id));
create policy "public teams read" on public.teams for select using(true);
create policy "staff manage teams" on public.teams for all using(exists(select 1 from public.tournaments t where t.id=tournament_id and public.is_school_staff(t.school_id))) with check(exists(select 1 from public.tournaments t where t.id=tournament_id and public.is_school_staff(t.school_id)));
create policy "staff read players" on public.players for select using(public.is_school_staff(school_id));
create policy "staff manage players" on public.players for all using(public.is_school_staff(school_id)) with check(public.is_school_staff(school_id));
create policy "staff manage roster" on public.team_players for all using(exists(select 1 from public.teams tm join public.tournaments t on t.id=tm.tournament_id where tm.id=team_id and public.is_school_staff(t.school_id))) with check(exists(select 1 from public.teams tm join public.tournaments t on t.id=tm.tournament_id where tm.id=team_id and public.is_school_staff(t.school_id)));
create policy "public matches read" on public.matches for select using(true);
create policy "staff manage matches" on public.matches for all using(exists(select 1 from public.tournaments t where t.id=tournament_id and public.is_school_staff(t.school_id))) with check(exists(select 1 from public.tournaments t where t.id=tournament_id and public.is_school_staff(t.school_id)));
create policy "official assignments read" on public.match_officials for select using(user_id=auth.uid() or exists(select 1 from public.matches m join public.tournaments t on t.id=m.tournament_id where m.id=match_id and public.can_manage_school(t.school_id)));
create policy "staff manage squads" on public.match_squads for all using(exists(select 1 from public.matches m join public.tournaments t on t.id=m.tournament_id where m.id=match_id and public.is_school_staff(t.school_id))) with check(exists(select 1 from public.matches m join public.tournaments t on t.id=m.tournament_id where m.id=match_id and public.is_school_staff(t.school_id)));
create policy "public innings read" on public.innings for select using(true);
create policy "staff manage innings" on public.innings for all using(exists(select 1 from public.matches m join public.tournaments t on t.id=m.tournament_id where m.id=match_id and public.is_school_staff(t.school_id))) with check(exists(select 1 from public.matches m join public.tournaments t on t.id=m.tournament_id where m.id=match_id and public.is_school_staff(t.school_id)));
create policy "public deliveries read" on public.deliveries for select using(true);
create policy "staff manage deliveries" on public.deliveries for all using(exists(select 1 from public.innings i join public.matches m on m.id=i.match_id join public.tournaments t on t.id=m.tournament_id where i.id=innings_id and public.is_school_staff(t.school_id))) with check(exists(select 1 from public.innings i join public.matches m on m.id=i.match_id join public.tournaments t on t.id=m.tournament_id where i.id=innings_id and public.is_school_staff(t.school_id)));
create policy "staff audit read" on public.scoring_audit for select using(exists(select 1 from public.matches m join public.tournaments t on t.id=m.tournament_id where m.id=match_id and public.is_school_staff(t.school_id)));
create policy "staff audit insert" on public.scoring_audit for insert with check(actor_id=auth.uid() and exists(select 1 from public.matches m join public.tournaments t on t.id=m.tournament_id where m.id=match_id and public.is_school_staff(t.school_id)));

do $$ begin alter publication supabase_realtime add table public.matches; exception when duplicate_object then null; when undefined_object then null; end $$;
do $$ begin alter publication supabase_realtime add table public.innings; exception when duplicate_object then null; when undefined_object then null; end $$;
do $$ begin alter publication supabase_realtime add table public.deliveries; exception when duplicate_object then null; when undefined_object then null; end $$;

-- Production scoring must use a transaction-safe RPC/Edge Function that locks innings,
-- validates cricket rules, appends the event + audit record, and recalculates totals.
-- Anonymous/public writes are intentionally not enabled.
