# NPL — Navodaya Premier League

Professional dark-theme cricket scoreboard prototype.

## Included
- Searchable Navodaya home list with pilot entries NPL Banka and NPL Bhagalpur.
- School centre with Matches, Points Table and Player Stats sections.
- Match setup for teams, overs, date and venue.
- Manual scoring controls for 0, 1, 2, 3, 4, 6, wicket, wide, no-ball, bye and leg-bye.
- Basic automatic innings totals, overs, batter runs/balls/boundaries, strike rate and run rate.
- Public match scorecard view.
- Browser-local storage for prototype testing.
- Supabase SQL schema starter for a shared live database.

## Run
Open index.html in a modern browser. No build step is required.

## Important limitation
This first build saves data in the current browser only. It is NOT yet a shared cross-device live scoreboard. To make it genuinely public and real-time, deploy the frontend and connect a Supabase project. Apply supabase/schema.sql, then implement authenticated scorer/admin roles, secure write policies, server-side score validation and Realtime subscriptions. Never put a Supabase service-role key in frontend code.

## Next engineering steps
1. Connect Supabase URL and anon key.
2. Add approved scorer login and role-based write permissions.
3. Save scoring events transactionally; recalculate totals server-side.
4. Add complete player rosters, dismissal types, bowler figures, partnerships and correction audit history.
5. Implement tournament formats, points, tie-breakers, NRR, player leaderboards, match results and knockout progression.
6. Add tests for cricket scoring edge cases before official use.

## Student privacy
Collect only necessary player information. Get school/guardian approvals where required. Keep profiles private by default and never publish student phone numbers, addresses or personal contact details. Use school-approved adult processes for scorer access and rewards.
