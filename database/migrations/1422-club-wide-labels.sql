-- 1422 (2026-11-16): the whole-club shared costs read "Club wide" everywhere,
-- beside "Men's club wide" (mig 1421). Owner: "as long as the others are club
-- wide". Words only; explanatory notes untouched.
BEGIN;
UPDATE message_templates m SET body = v.body
  FROM (VALUES
    ('pm_share',             'Club wide — Men''s share (field, balls, seed …)'),
    ('pm_share_club',        'Club wide (whole club {total}) — Men''s {pct}'),
    ('plan_club_share',      'Club wide — {pct} ({active} of {all} paying members)'),
    ('plan_club_share_line', 'Club wide (balls, field, paint, gas …)'),
    ('plan_prog_shared',     '{program} — share of club wide')
  ) AS v(tier, body)
 WHERE m.kind = 'finances' AND m.tier = v.tier;
INSERT INTO schema_migrations (filename) VALUES ('1422-club-wide-labels.sql') ON CONFLICT DO NOTHING;
COMMIT;
