-- 1474 (2026-11-18) — #finances programs + Men's: each running balance is
-- named for what was just added, not what comes next (owner "i like balance
-- 'after' not 'before' before looks weird … after each section we should just
-- have a running balance right?").  Same numbers, same places.
BEGIN;
UPDATE message_templates SET body = v.b, updated_at = now()
  FROM (VALUES
    ('pm_pre_coach',     'BALANCE AFTER TEAM COSTS'),
    ('pm_pre_club',      'BALANCE AFTER COACHING'),
    ('pm_pre_grant',     'BALANCE AFTER CLUB WIDE'),
    ('pm_out_pre_coach', 'Money out — team costs'),
    ('pm_in_total',      'Money in (grant below)')
  ) AS v(t, b)
 WHERE message_templates.kind = 'finances' AND message_templates.tier = v.t;
COMMIT;
