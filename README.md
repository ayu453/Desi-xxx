# NPL — Navodaya Premier League

NPL is designed as a complete school cricket tournament platform, not a simple scorecard. The pilot begins with a curated Navodaya directory (currently NPL Banka and NPL Bhagalpur) and can expand gradually.

## Advanced product modules
- School directory and school-wise tournament centres
- League, round robin, group + knockout and knockout tournament formats
- Team registration, player rosters, squad verification and playing XI
- Fixture scheduling, groups, stages, toss and match officials
- Ball-by-ball scoring and complete innings/scorecard data model
- Public match centre with live updates
- Points, standings, Net Run Rate and tournament progression
- Batting/bowling leaderboards, match awards and records
- Role-based school administration, scorer access and correction audit trail

## Repository status
index.html is the existing browser prototype. It demonstrates the school directory, match creation, basic scoring and scorecard UI using browser-local storage. It is NOT yet a production-ready advanced application and does not yet provide cross-device live sync.

supabase/schema.sql is the advanced Supabase data foundation. It adds schools, memberships, tournaments, teams, player rosters, fixtures, squads, innings, ball-by-ball deliveries, officials, scoring audit, derived scorecard views, role-aware RLS policies and Realtime publication.

## Setup
1. Create a Supabase project.
2. Review supabase/schema.sql with a developer and apply it to a fresh project.
3. Configure Supabase URL and anon key as public frontend configuration only.
4. Implement secure scorer authentication and server-side scoring RPC/Edge Functions.
5. Connect the frontend to Supabase and subscribe to match, innings and delivery changes.
6. Deploy the frontend (for example, through the connected Vercel project).

Never put a Supabase service-role key in browser code. Do not enable anonymous writes to match, innings, player or delivery data.

## Production requirements
- Validate and commit every score event transactionally on the server.
- Corrections/deletions must create an audit record with actor, reason and before/after values.
- Implement tournament standings/NRR calculations and deterministic knockout advancement.
- Test legal-ball rules, wides/no-balls, byes/leg-byes, strike changes, wickets, super overs, ties, abandoned matches and corrections.
- Add backups, monitoring, rate limits and admin recovery procedures.
- Keep student information private by default. Collect only minimum required data, obtain school/guardian approval where applicable, and never publish personal contact details.
- Any incentives or verification payments must use a school-approved adult process; do not collect students' personal payment details.

## Current limitations
The browser prototype remains a local demo. The SQL schema is a data/security foundation, not a complete backend. Server-side scoring RPCs, automated tournament calculations, frontend integration, authentication flows and end-to-end tests remain to be built before real tournament use.
