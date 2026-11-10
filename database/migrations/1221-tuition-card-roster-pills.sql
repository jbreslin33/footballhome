-- 1221: #payments (Tuition) cards show where each player stands on every
-- team and every official league list.
--
-- Owner 2026-11-10: "on tuition page i would like you to show their status,
-- active, inactive, what official rosters they are on. like APSL Active,
-- APSL Inactive, APSL OFFICIAL, LIGA 1 OFFICIAL etc".
--
-- Read by GET /api/payments/standing (rosters[]) and drawn by
-- PersonStanding.rosterHtml:
--   team status  = his live team_persons row: no squad status = Active,
--                  else the squad status (💤 Inactive / Practice Squad),
--                  invite-only with no squad status = Call-in
--   official     = official_roster_seen on an active official_roster_sources
--                  row (the league's own list as last pulled: APSL Active
--                  Roster, APSL Reserve Roster, CASA Liga 1, Parks & Rec)
--
-- teams.on_tuition_card: the USASA Cup container (939) mirrors the whole
-- men's pool by trigger (mig 585), so "Cup Active" on every man says
-- nothing — it and the pickup pool stay off the cards.

BEGIN;

ALTER TABLE teams ADD COLUMN IF NOT EXISTS on_tuition_card boolean NOT NULL DEFAULT true;
COMMENT ON COLUMN teams.on_tuition_card IS
  'Show this team''s status pill on #payments (Tuition) cards (mig 1221). Off for containers mirrored by trigger (USASA Cup) and pools.';

UPDATE teams SET on_tuition_card = false
 WHERE is_pool
    OR (club_id = 134 AND name = 'USASA Cup');

INSERT INTO message_templates (category, kind, tier, label, body, client_side, sort_order) VALUES
  ('Person standing', 'person_standing', 'roster_active',         'Tuition card: team status Active ({team})',         '{team} Active',         true, 50),
  ('Person standing', 'person_standing', 'roster_inactive',       'Tuition card: team status Inactive ({team})',       '{team} Inactive',       true, 51),
  ('Person standing', 'person_standing', 'roster_practice_squad', 'Tuition card: team status Practice Squad ({team})', '{team} Practice Squad', true, 52),
  ('Person standing', 'person_standing', 'roster_call_in',        'Tuition card: team status Call-in ({team})',        '{team} Call-in',        true, 53),
  ('Person standing', 'person_standing', 'roster_status_tip',     'Tuition card: team status tooltip ({team})',        'Status on {team} (#teams)', true, 54),
  ('Person standing', 'person_standing', 'roster_official',       'Tuition card: on official list ({team})',           '📋 {team} Official',    true, 55),
  ('Person standing', 'person_standing', 'roster_official_tip',   'Tuition card: official list tooltip ({list} {date})', 'On the league''s official list — {list}[[, last pulled {date}]]', true, 56);

COMMIT;
