-- 1010: men's #teams Team pill = two game columns, APSL and Liga 1
-- (owner 2026-11-03: "reserves are not a real team so its really apsl and
-- liga 1"; proposal decision 1).
--
-- teams.team_pill_fold_into_id: the Team pill leaves this team's column
-- out and shows its men inside the named team's column as ⭐ CALL-UP POOL.
-- The Roster pill keeps the column (it is a real league list: APSL's
-- TeamPass "Reserve Roster").  Call-ups still come from
-- team_callup_policies (mig 605); nothing about who sees games changes.
--
-- ACTIVE (was PLAYS) splits by the column's league list: 📋 on the list /
-- ⚠ wants in — a man not on the list can RSVP Going, which is the signal
-- to add him (decision 3).

BEGIN;

ALTER TABLE teams ADD COLUMN IF NOT EXISTS team_pill_fold_into_id integer REFERENCES teams(id);
COMMENT ON COLUMN teams.team_pill_fold_into_id IS
  'mig 1010: #teams Team pill shows this team''s men as the CALL-UP POOL inside that team''s column, not as a column of its own. Roster pill unaffected.';

UPDATE teams SET team_pill_fold_into_id = 35
 WHERE id = 938 AND name = 'Lighthouse Mens Club APSL Reserves';

UPDATE message_templates SET body = 'ACTIVE', label = 'Team boards — Team pill section: active', updated_at = now()
 WHERE kind = 'roster_sheet' AND tier = 'board_plays_h';

UPDATE message_templates
   SET body = 'His category — Plays, Practice Squad (trains, games on call-up), Paper spot (holds the place, plays only when invited), Call-in, Inactive (not practicing, still billed, no RSVP asks) or injured. Practice Squad, Inactive and injured are one per man: they apply on every team in his section.',
       updated_at = now()
 WHERE kind = 'roster_sheet' AND tier = 'team_status_title';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Roster sheet', l, 'roster_sheet', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('board_listed_sub',     'Team boards — Team pill ACTIVE: on the league list',   '📋 On the {list} list',                           1010),
    ('board_wants_in_sub',   'Team boards — Team pill ACTIVE: not on the list',      '⚠ Wants in · can RSVP, not on the {list} list',  1011),
    ('board_callup_pool_h',  'Team boards — Team pill: folded team''s men',          '⭐ CALL-UP POOL · asked when called up',          1012),
    ('board_wants_in_chip',  'Team boards — Team pill card chip: not on the list',   '⚠ not on {list} list',                            1013)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'roster_sheet' AND m.tier = v.t);

COMMIT;
