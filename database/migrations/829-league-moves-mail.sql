-- 829 (2026-10-29) — ✉️ roster-moves email to the league commissioner, on #apsl.
--
-- Owner: "need email in apsl for commish to make the rosters moves from
-- roster. this email should also appear there if there are moves to make.
-- so on load of that apsl page you should check roster page right?"
--
-- The moves are the #teams Roster pill's own (migs 770–820), worked out
-- here once so the page that mails them and the board agree:
--   DROP — on the league list and ✂ cut (no live LeagueApps playing
--          membership, mig 810), or his card is in a drop lane whose
--          status asks the league (roster_statuses.league_request).
--   ADD  — on the team, off the list, status asks the league (Has Docs).
-- Who to ask = official_roster_sources.request_contact_id (a club_contacts
-- row — APSL's commissioner, Aaron Sexton).  "✓ Sent" logs the ask in
-- league_move_requests and moves each live card to the status the ask
-- leads to (drop → Pending Drop, add → Awaiting Approval), so the email
-- only shows while something is still unasked.

ALTER TABLE official_roster_sources
  ADD COLUMN IF NOT EXISTS request_contact_id integer REFERENCES club_contacts(id) ON DELETE SET NULL;
COMMENT ON COLUMN official_roster_sources.request_contact_id IS
  'Who the club emails to make roster moves on this list (mig 829) — e.g. the APSL commissioner.';

UPDATE official_roster_sources s SET request_contact_id = k.id
  FROM club_contacts k
 WHERE s.system = 'teampass' AND s.site_slug = 'APSL' AND s.request_contact_id IS NULL
   AND k.club_id = 65 AND k.role = 'Commissioner' AND k.is_active;

ALTER TABLE roster_statuses
  ADD COLUMN IF NOT EXISTS league_request text CHECK (league_request IN ('add', 'drop')),
  ADD COLUMN IF NOT EXISTS league_request_sent_status_id integer REFERENCES roster_statuses(id);
COMMENT ON COLUMN roster_statuses.league_request IS
  'A card in this status is a move the league must make (mig 829): add / drop.';
COMMENT ON COLUMN roster_statuses.league_request_sent_status_id IS
  'The status a card moves to once the league has been asked (mig 829).';

UPDATE roster_statuses SET league_request = 'add',
       league_request_sent_status_id = (SELECT id FROM roster_statuses WHERE code = 'awaiting_approval')
 WHERE code = 'has_docs';
UPDATE roster_statuses SET league_request = 'drop',
       league_request_sent_status_id = (SELECT id FROM roster_statuses WHERE code = 'pending_drop')
 WHERE code = 'possible_drop';

CREATE TABLE IF NOT EXISTS league_move_requests (
  id                   serial PRIMARY KEY,
  source_id            integer NOT NULL REFERENCES official_roster_sources(id) ON DELETE CASCADE,
  person_id            integer NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
  move                 text NOT NULL CHECK (move IN ('add', 'drop')),
  contact_id           integer REFERENCES club_contacts(id) ON DELETE SET NULL,
  requested_by_user_id integer,
  requested_at         timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS league_move_requests_src_person ON league_move_requests (source_id, person_id, move);

-- Every move owed on every list that has someone to ask.  requested_at =
-- the last ask (NULL = still to ask); a drop the board already shows as
-- Pending Drop counts as asked.
CREATE OR REPLACE FUNCTION fh_league_moves()
RETURNS TABLE (source_id integer, team_id integer, person_id integer, full_name text,
               official_no integer, move text, reason text, requested_at timestamptz)
LANGUAGE sql STABLE AS $$
  WITH src AS (
    SELECT s.id, s.team_id FROM official_roster_sources s
     WHERE s.is_active AND s.request_contact_id IS NOT NULL
  ), list AS (
    SELECT DISTINCT ON (s.id, n.person_id) s.id AS source_id, s.team_id, n.person_id, n.full_name,
           (row_number() OVER (PARTITION BY s.id ORDER BY n.sort_order, n.id))::int AS official_no
      FROM src s JOIN official_roster_names n ON n.source_id = s.id
     ORDER BY s.id, n.person_id, n.sort_order
  ), live AS (
    SELECT tp.team_id, tp.person_id, rs.code, rs.board_section, rs.league_request
      FROM team_persons tp JOIN roster_statuses rs ON rs.id = tp.roster_status_id
     WHERE tp.removed_at IS NULL
  ), moves AS (
    SELECT l.source_id, l.team_id, l.person_id, l.full_name, l.official_no, 'drop'::text AS move,
           CASE WHEN v.league_request = 'drop' THEN 'drop' ELSE 'cut' END AS reason,
           v.board_section = 'pending_drop' AS asked
      FROM list l LEFT JOIN live v ON v.team_id = l.team_id AND v.person_id = l.person_id
     WHERE l.person_id IS NOT NULL
       AND (v.league_request = 'drop' OR v.board_section = 'pending_drop' OR NOT fh_in_leagueapps(l.person_id))
    UNION ALL
    SELECT s.id, s.team_id, v.person_id,
           trim(COALESCE(p.first_name, '') || ' ' || COALESCE(p.last_name, '')), NULL, 'add', 'add', false
      FROM src s JOIN live v ON v.team_id = s.team_id AND v.league_request = 'add'
      JOIN persons p ON p.id = v.person_id
     WHERE NOT EXISTS (SELECT 1 FROM official_roster_names n WHERE n.source_id = s.id AND n.person_id = v.person_id)
  )
  SELECT m.source_id, m.team_id, m.person_id, m.full_name, m.official_no, m.move, m.reason,
         COALESCE((SELECT max(r.requested_at) FROM league_move_requests r
                    WHERE r.source_id = m.source_id AND r.person_id = m.person_id AND r.move = m.move),
                  CASE WHEN m.asked THEN now() END)
    FROM moves m
   ORDER BY m.source_id, m.move DESC, m.official_no NULLS LAST, m.full_name;
$$;

-- The words (kind league_moves).  {moves} = one team_block per list with
-- something to ask; each block's {lines} = one line_drop / line_add each.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'League moves', l, 'league_moves', t, s, b, o, true, true, false
  FROM (VALUES
    ('panel_h',    '#apsl — roster-moves email: panel heading', NULL,
     '✉️ Roster moves to send {contact}', 10),
    ('panel_note', '#apsl — roster-moves email: under the heading', NULL,
     'From the Roster pill on #teams — cut players and drops to take off, players with docs to add. Shows only while something is unasked.', 11),
    ('email',      '#apsl — roster-moves email: the email ({moves} = the team blocks)',
     'Lighthouse 1893 SC — roster moves',
     E'Hi {contact_first},\n\nCould you please make these roster moves for Lighthouse 1893 SC?\n\n{moves}\nThank you,[[\n{sender}]]\nLighthouse 1893 SC', 12),
    ('team_block', '#apsl — roster-moves email: one list''s moves', NULL,
     E'{team}:\n{lines}\n', 13),
    ('line_drop',  '#apsl — roster-moves email: a drop line', NULL, '  • DROP {name}', 14),
    ('line_add',   '#apsl — roster-moves email: an add line',  NULL, '  • ADD {name}', 15),
    ('send_btn',   '#apsl — roster-moves email: Gmail button', NULL, '✉️ Email {contact}', 16),
    ('sent_btn',   '#apsl — roster-moves email: mark asked button', NULL, '✓ Sent — mark pending', 17),
    ('asked_note', '#apsl — roster-moves email: already asked (still on the list)', NULL, 'Asked {date}, waiting on the league:', 18),
    ('reason_cut', '#apsl — roster-moves email: why a drop (cut)', NULL, '✂ not in LeagueApps', 19),
    ('reason_drop','#apsl — roster-moves email: why a drop (Dropping)', NULL, '⬇ dropping', 20)
  ) AS v(t, l, s, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'league_moves' AND m.tier = v.t);
