# NPL — Navodaya Premier League

NPL is a school cricket tournament management workspace designed to grow from a small Navodaya pilot to a wider school network. The app name is NPL; school spaces are labelled by Navodaya/district, such as NPL Banka and NPL Bhagalpur.

## Current browser workspace
The root `index.html` is a responsive single-page application with:
- Dashboard and quick tournament overview
- Navodaya directory with search and add-school flow
- Tournament creation with league, round-robin, group + knockout and knockout formats
- Team registration and player roster directory
- Fixture scheduling by tournament, team, stage, date and venue
- Live scoring desk with runs, wickets, wides, no-balls, byes, leg-byes and undo
- Match score preview and batting scorecard
- Batting/bowling leaderboards and basic team standings
- Local JSON backup export/import and local demo reset
- Browser-local persistence

## Database foundation
`supabase/schema.sql` contains an expanded Supabase/PostgreSQL foundation for schools, school memberships, tournaments, teams, players, rosters, fixtures, match squads, officials, innings, ball-by-ball deliveries, scoring audit and derived scorecard views. It includes role-aware RLS policies and Realtime publication setup.

## Run
Open `index.html` in a modern browser. No build step is required for the local prototype.

## Important: prototype vs real live platform
The current browser workspace stores data in the current browser only. It is **not yet a shared multi-device live scoreboard**. The scoring interface is a working prototype, not an official scorer engine. Before a real tournament, complete:
1. Supabase project configuration and frontend integration.
2. Authenticated user accounts and school-approved admin/scorer roles.
3. Transaction-safe server-side scoring RPC/Edge Functions with cricket-law validation.
4. Realtime subscriptions for public match pages.
5. Correct strike rotation, bowler figures, dismissals, fall of wickets, partnerships, innings targets, super overs and match-result handling.
6. Full points/NRR/tie-break calculations and automatic group/knockout progression.
7. Automated tests, backup/restore, monitoring and security review.

Never put a Supabase service-role key in browser code. Do not enable anonymous writes to player, match, innings or delivery data.

## Student privacy and school approval
Collect only information required to run the tournament. Keep student information private by default, do not publish phone numbers or addresses, and obtain school/guardian approvals where applicable. Any rewards or verification reimbursements must use a school-approved adult process, not students' personal payment details.
