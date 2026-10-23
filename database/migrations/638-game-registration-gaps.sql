-- 638 (2026-10-22) — Game Center: Going but not on the official roster.
-- Owner: "if a player is set going to a game and NOT on official roster
-- yet then there should be on game center a quick send registration link
-- for apsl or casa right?"
--
-- A Going player rostered on the game's team whose roster status does not
-- count as on the league's roster is a registration gap.  The coach gets
-- that league's registration nudge (the same message_templates
-- kind='registration' row the #teams roster card sends) one tap away.  A
-- player who has already done their part — submitted and waiting on the
-- league — is listed without the buttons: re-sending them the form helps
-- nobody.

-- Which registration form each league's games send.
CREATE TABLE IF NOT EXISTS league_registration_forms (
    league_label        TEXT PRIMARY KEY,
    message_template_id INT NOT NULL REFERENCES message_templates(id),
    note                TEXT
);
COMMENT ON TABLE league_registration_forms IS 'mig 638: the registration nudge (message_templates kind=registration) a game of this fh_events.league sends to a Going player not yet on the official roster.';
INSERT INTO league_registration_forms (league_label, message_template_id, note)
SELECT v.league, m.id, v.note
  FROM (VALUES ('CASA', 'Liga1/APSL Reg', 'Liga 1 form also captures the APSL roster info'),
               ('APSL', 'APSL Reg',       NULL)) AS v(league, label, note)
  JOIN message_templates m ON m.kind = 'registration' AND m.category = 'Men''s Club' AND m.label = v.label
ON CONFLICT (league_label) DO NOTHING;

-- Statuses where the player has nothing left to do — the club or the
-- league is the one waiting.
ALTER TABLE roster_statuses ADD COLUMN IF NOT EXISTS player_done BOOLEAN NOT NULL DEFAULT false;
COMMENT ON COLUMN roster_statuses.player_done IS 'mig 638: the player has done their part (submitted); a registration nudge would not help — Game Center lists them without send buttons.';
UPDATE roster_statuses SET player_done = true
 WHERE code IN ('awaiting_approval', 'submitted_itc', 'awaiting_transfer', 'awaiting_roster_spot');

-- The gaps for one game: Going (RSVP yes), rostered on one of the game's
-- teams (an invite-only row counts — they only answer once invited), and
-- on none of them with a status that counts as on the official roster.
-- Staff who are not on the team (coaches answering Going) never appear.
CREATE OR REPLACE FUNCTION fh_event_registration_gaps(p_fh_event_id BIGINT, p_club_id INT)
RETURNS TABLE (person_id INT, first_name TEXT, last_name TEXT, status_code TEXT, status_label TEXT,
               player_done BOOLEAN, phone TEXT, email TEXT, form_label TEXT, subject TEXT, body TEXT)
LANGUAGE sql STABLE AS $$
    SELECT p.id, p.first_name::text, p.last_name::text, rs.code::text, rs.display_name::text,
           COALESCE(rs.player_done, false),
           (SELECT ph.phone_number FROM person_phones ph WHERE ph.person_id = p.id AND ph.can_receive_sms
             ORDER BY ph.is_primary DESC, ph.id LIMIT 1)::text,
           (SELECT em.email FROM person_emails em WHERE em.person_id = p.id
             ORDER BY em.is_primary DESC, em.id LIMIT 1)::text,
           m.label::text, COALESCE(fh_fill_form_links(m.subject, p_club_id), ''), fh_fill_form_links(m.body, p_club_id)
      FROM fh_events e
      JOIN league_registration_forms lrf ON lrf.league_label = e.league
      JOIN message_templates m ON m.id = lrf.message_template_id AND m.is_active
      JOIN fh_event_rsvps r ON r.fh_event_id = e.id AND r.response = 'yes'
      JOIN persons p ON p.id = r.person_id
      LEFT JOIN LATERAL (
          SELECT rs2.* FROM fh_event_teams fet
            JOIN team_persons tp ON tp.team_id = fet.team_id AND tp.person_id = p.id AND tp.removed_at IS NULL
            LEFT JOIN roster_statuses rs2 ON rs2.id = tp.roster_status_id
           WHERE fet.fh_event_id = e.id
           ORDER BY rs2.sort_order DESC NULLS LAST LIMIT 1) rs ON true
     WHERE e.id = p_fh_event_id
       AND EXISTS (SELECT 1 FROM fh_event_teams fet JOIN team_persons tp
                     ON tp.team_id = fet.team_id AND tp.person_id = p.id AND tp.removed_at IS NULL
                    WHERE fet.fh_event_id = e.id)
       AND NOT EXISTS (SELECT 1 FROM fh_event_teams fet JOIN team_persons tp
                         ON tp.team_id = fet.team_id AND tp.person_id = p.id AND tp.removed_at IS NULL
                       JOIN roster_statuses rs3 ON rs3.id = tp.roster_status_id AND rs3.counts_as_on_roster
                        WHERE fet.fh_event_id = e.id)
     ORDER BY COALESCE(rs.player_done, false), p.last_name, p.first_name
$$;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Game Center', l, 'reg_gap', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('title',     'Game Center — Going, not on the official roster ({n})',  '⚠ Going but not on the official roster ({n})', 890),
    ('hint',      'Game Center — what the registration strip is for',       'They can''t play until the league has them. The club submits by Friday 3:00 PM — send the form now.', 891),
    ('waiting',   'Game Center — submitted, waiting on the league',         'submitted — waiting on the league', 892),
    ('no_status', 'Game Center — no roster status set',                     'no status', 893)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'reg_gap' AND m.tier = v.t);
