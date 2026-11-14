-- 1367 (2026-11-14) — #finances: the standard nonprofit set only, root and stem.
--
-- Owner: "please just the standard industry standard for non profits and take
-- out everything else root and stem. we can always add back but we will start
-- clean!"
--
-- Kept: Budget (operating budget — Revenue, Expenses by category, Net), Actuals,
-- Cash forecast.  Gone with their code: Members, Break-even (At capacity, mig
-- 1360), Scenarios (Playground, mig 1361), the Budget's option switches (Liga 2 /
-- Temple 7s stay as is_option entries, never counted), grants switch (grants
-- awarded or received are now always revenue with donor restrictions), the
-- shared-by / full-roster / team-count boxes, the Home games list and the
-- budget-line editor on Cash forecast.  /api/finances/summary stays (Actuals
-- reads it).  Wording rows nothing reads any more are deleted.
BEGIN;

DROP FUNCTION IF EXISTS fh_budget_playground_kits(int, int);
DROP FUNCTION IF EXISTS fh_budget_playground_reset(int, int);
DROP TABLE IF EXISTS budget_playground_coaches;
DROP TABLE IF EXISTS budget_playground_teams;
DROP TABLE IF EXISTS budget_playground_settings;
DROP TABLE IF EXISTS budget_playground_groups;
DROP TABLE IF EXISTS youth_age_capacities;

UPDATE message_templates SET body = 'Grant ({purpose}, restricted) — {label}'
 WHERE kind = 'finances' AND tier = 'plan_rev_grant';
UPDATE message_templates SET body = 'Revenue, expenses and the net result for the budget year (Aug 1 – Jul 31). Dues = paying members × dues × 12; grants awarded or received count as revenue restricted to their purpose. Expenses are rate × quantity from each team''s fee plan plus section and club-wide lines; tap a category to see its lines. Options (Liga 2, Temple 7s) are not in the budget. * = assumed. When money moves is on Cash forecast; what really happened is on Actuals.'
 WHERE kind = 'finances' AND tier = 'plan_note';

DELETE FROM message_templates WHERE kind = 'finances' AND tier IN (
    'budget_columns','budget_note','budget_per_member','budget_per_week','budget_title','capacity_age','capacity_c
    lub_covers','capacity_columns','capacity_gap_now','capacity_need','capacity_note','capacity_short','capacity_s
    pare','capacity_title','capacity_total','capacity_youth_group','capacity_youth_total','expenses_note','expense
    s_title','net_label','pg_add_coach','pg_add_line','pg_add_team','pg_b_suffix','pg_break_even','pg_club_columns
    ','pg_coach_columns','pg_copied','pg_copy_team','pg_dues','pg_kit','pg_kits_base','pg_new_coach','pg_new_line'
    ,'pg_new_team','pg_note','pg_over_roster','pg_per_game','pg_per_week','pg_reset','pg_reset_confirm','pg_sectio
    n_coaches','pg_summary_columns','pg_team_columns','pg_title','pg_total','pill_capacity','pill_playground','pil
    l_revenue','pill_summary','plan_general','plan_grants_add','plan_grants_note','plan_grants_on','plan_grants_sh
    are','plan_grants_title','plan_option_add','plan_option_on','plan_option_tag','plan_per_player','plan_rosters_
    note','plan_rosters_title','plan_split_active','plan_split_columns','plan_split_current','plan_split_full','pl
    an_total_after_grants','refs_note','refs_title');

COMMIT;
