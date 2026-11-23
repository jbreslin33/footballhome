-- 1656 (2026-11-23) — 🧮 Program budgets: a 👥 MEMBERS section.
-- Owner: "i see 43 paying members this month so far? then 8 volunteers. of
-- those 8 volunteers lets say 4 would be on a roster. the others would be non
-- roster. keep in mind that also not all paying members will be on a roster.
-- some will be pulled or never put on if they are more casual. is there a way
-- to show this and allow for edit … show the current paying percent of members
-- and then we can use that to inform but there should be place for volunteers
-- etc" → "members is key here and we need a good section for it. the rest is
-- like i said pretty fixed".
--
-- His own numbers per plan season (NULL = today's real count):
--   collect_pct          share of the members who owe tuition that pay (live:
--                        the last 3 closed months) — the only one that moves money
--   non_paying           volunteers and others who don't pay
--   non_paying_on_roster how many of those hold a roster spot
--   paying_off_roster    members who owe tuition but hold no roster spot (casual)

ALTER TABLE program_season_plans
  ADD COLUMN IF NOT EXISTS collect_pct numeric(5,1) CHECK (collect_pct IS NULL OR collect_pct BETWEEN 0 AND 100),
  ADD COLUMN IF NOT EXISTS non_paying integer CHECK (non_paying IS NULL OR non_paying BETWEEN 0 AND 500),
  ADD COLUMN IF NOT EXISTS non_paying_on_roster integer CHECK (non_paying_on_roster IS NULL OR non_paying_on_roster BETWEEN 0 AND 500),
  ADD COLUMN IF NOT EXISTS paying_off_roster integer CHECK (paying_off_roster IS NULL OR paying_off_roster BETWEEN 0 AND 500);

INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public)
SELECT 'Finances', v.label, 'finances', v.tier, v.body, true, v.ord, true, false
  FROM (VALUES
    ('Finances — program budgets: members block', 'pb_m_title', '👥 MEMBERS', 955),
    ('Finances — program budgets: members today ({all}, {owing}, {free})', 'pb_m_today', 'Today: {all} members — {owing} owe tuition, {free} don''t pay', 956),
    ('Finances — program budgets: members who owe tuition box', 'pb_m_owing', 'Members who owe tuition', 957),
    ('Finances — program budgets: share who pay box', 'pb_m_collect', 'Share of them who pay (%)', 958),
    ('Finances — program budgets: paid this month ({paid}, {owing}, {pct}, {recent})', 'pb_m_collect_note', '{paid} of {owing} have paid so far this month ({pct}%) · last 3 months {recent}%', 959),
    ('Finances — program budgets: who pays ({n}, {dues}, {month})', 'pb_m_collect_end', '→ about {n} paying {dues} a month by {month}', 960),
    ('Finances — program budgets: non-paying box', 'pb_m_free', 'Volunteers and others who don''t pay', 961),
    ('Finances — program budgets: non-paying today ({volunteers}, {other})', 'pb_m_free_note', 'today: {volunteers} volunteers, {other} other', 962),
    ('Finances — program budgets: non-paying on a roster box', 'pb_m_free_roster', '… of them on a roster', 963),
    ('Finances — program budgets: paying off roster box', 'pb_m_off', 'Members who owe tuition but are not on a roster (casual)', 964),
    ('Finances — program budgets: on a roster today ({n})', 'pb_m_roster_note', 'today: {n} on a league roster', 965),
    ('Finances — program budgets: members at year end ({month})', 'pb_m_end', 'BY THE END OF {month}', 966),
    ('Finances — program budgets: year-end totals ({all}, {owing}, {free})', 'pb_m_end_all', '{all} members — {owing} owe tuition + {free} who don''t pay', 967),
    ('Finances — program budgets: year-end roster ({roster}, {full})', 'pb_m_end_roster', '{roster} on a roster of {full}', 968),
    ('Finances — program budgets: year-end roster, no cap ({roster})', 'pb_m_end_roster_open', '{roster} on a roster', 969),
    ('Finances — program budgets: roster spots open ({n})', 'pb_m_end_open', '{n} spots open', 970),
    ('Finances — program budgets: over the roster ({n})', 'pb_m_end_over', '{n} over — reserves, no roster spot', 971),
    ('Finances — program budgets: off roster at year end ({n})', 'pb_m_end_off', '{n} members with no roster spot', 972)
  ) AS v(label, tier, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'finances' AND t.tier = v.tier);
