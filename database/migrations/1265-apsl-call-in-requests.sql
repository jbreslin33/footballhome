-- 1265 (2026-11-11) — 🙋 Request call-in: Liga 1 players see APSL games
-- and can put their hand up; the coach accepts = an invite.
--
-- Owner 2026-11-11: "we need a way for guys to request call in to apsl …
-- if the apsl showed for everyone who is on liga roster then we could just
-- quickly add them … i would think the apsl game would instead of rsvp
-- section it says request call in otherwise it looks same" / "we don't
-- have ability to auto text everyone so i think just show the rsvp buttons
-- and put him in 'No Response' section … safer" / "if they see liga 1
-- they see call in. unless they have standing invite."
--
-- Model:
--   team_callin_sources  (team, from_team): whoever SEES from_team's games
--     (an active roster row that grants games: removed_at NULL and not
--     invite_only — fh_roster_row_grants) sees team's games with a
--     🙋 Request call-in button instead of Go / No.  Row: APSL Reserves 938
--     ← Liga 1 120.
--   fh_event_callin_requests: one row per ask; the coach decides.
--     accepted = an fh_event_invites row (from_team = the source team) →
--     the game is his like any call-up: Go / No on #my, he sits in
--     No Response until he answers.  No text is sent.
--   An invite (incl. a standing one, team_auto_invites) beats all of this:
--     he just has the game.
--   fh_event_callin(event, person) → NULL (no button) or
--     {state: open|requested|declined, from, request_id}.

CREATE TABLE IF NOT EXISTS team_callin_sources (
    team_id      integer NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    from_team_id integer NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    created_at   timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (team_id, from_team_id)
);
COMMENT ON TABLE team_callin_sources IS
    'mig 1265: players who see from_team''s games see team''s games with 🙋 Request call-in (no Go/No) until invited.';

INSERT INTO team_callin_sources (team_id, from_team_id)
SELECT 35, 120 WHERE EXISTS (SELECT 1 FROM teams WHERE id = 35) AND EXISTS (SELECT 1 FROM teams WHERE id = 120)
ON CONFLICT DO NOTHING;

CREATE TABLE IF NOT EXISTS fh_event_callin_requests (
    id                 bigserial PRIMARY KEY,
    fh_event_id        bigint  NOT NULL REFERENCES fh_events(id) ON DELETE CASCADE,
    person_id          integer NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    from_team_id       integer REFERENCES teams(id),
    requested_at       timestamptz NOT NULL DEFAULT now(),
    withdrawn_at       timestamptz,
    decision           text CHECK (decision IS NULL OR decision IN ('accepted', 'declined')),
    decided_at         timestamptz,
    decided_by_user_id integer REFERENCES users(id)
);
CREATE UNIQUE INDEX IF NOT EXISTS fh_event_callin_requests_open
    ON fh_event_callin_requests (fh_event_id, person_id) WHERE withdrawn_at IS NULL;
COMMENT ON TABLE fh_event_callin_requests IS
    'mig 1265: a player''s 🙋 call-in ask for one game. accepted → fh_event_invites row; declined = not this week; withdrawn = he took it back.';

-- The source team that lets this person ask for this game (NULL = none).
CREATE OR REPLACE FUNCTION fh_event_callin_source(p_event_id bigint, p_person_id integer)
RETURNS integer LANGUAGE sql STABLE AS $$
    SELECT s.from_team_id
      FROM fh_events fe
      JOIN fh_event_teams fet ON fet.fh_event_id = fe.id
      JOIN team_callin_sources s ON s.team_id = fet.team_id
      JOIN teams ft ON ft.id = s.from_team_id AND ft.is_active
      JOIN team_persons tp ON tp.team_id = s.from_team_id AND tp.person_id = p_person_id
                          AND tp.removed_at IS NULL AND NOT tp.invite_only
     WHERE fe.id = p_event_id AND fe.kind = 'match'
     ORDER BY s.from_team_id
     LIMIT 1
$$;

-- What #my shows instead of Go / No.  NULL once he is invited, already on
-- the game some other way, or not on a source team.
CREATE OR REPLACE FUNCTION fh_event_callin(p_event_id bigint, p_person_id integer)
RETURNS jsonb LANGUAGE sql STABLE AS $$
    SELECT jsonb_build_object(
             'state', CASE WHEN r.id IS NULL THEN 'open'
                           WHEN r.decision = 'declined' THEN 'declined'
                           ELSE 'requested' END,
             'request_id', r.id,
             'from', NULLIF(regexp_replace(COALESCE(ft.label, ft.name, ''), '^[^[:alnum:]]+\s*', ''), ''))
      FROM (SELECT fh_event_callin_source(p_event_id, p_person_id) AS src) x
      JOIN teams ft ON ft.id = x.src
      -- An accepted ask whose invite was later taken back = he can ask again.
      LEFT JOIN fh_event_callin_requests r
             ON r.fh_event_id = p_event_id AND r.person_id = p_person_id AND r.withdrawn_at IS NULL
            AND r.decision IS DISTINCT FROM 'accepted'
     WHERE x.src IS NOT NULL
       AND NOT fh_event_invited(p_event_id, p_person_id)
       -- Already on the game through a roster row that grants it.
       AND NOT EXISTS (
             SELECT 1 FROM fh_event_teams fet
               JOIN team_persons tp ON tp.team_id = fet.team_id AND tp.person_id = p_person_id
                                   AND tp.removed_at IS NULL
                                   AND fh_roster_row_grants(tp.team_id, tp.invite_only, p_event_id)
              WHERE fet.fh_event_id = p_event_id)
       -- Coaches of the game's team and club staff already have it.
       AND NOT EXISTS (
             SELECT 1 FROM fh_event_teams fet
               JOIN team_coaches tc ON tc.team_id = fet.team_id AND tc.ended_at IS NULL
               JOIN coaches co ON co.id = tc.coach_id
              WHERE fet.fh_event_id = p_event_id AND co.person_id = p_person_id)
       AND NOT fh_event_staff(p_event_id, p_person_id)
$$;

-- Words (#my card + Event Center requests list).
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Call-in', v.label, 'callin', v.tier, NULL, v.body, v.sort, true, true
  FROM (VALUES
    ('button',          '#my — request call-in button',                                '🙋 Request call-in', 1),
    ('note',            '#my — line under the button ({from})',                        'Want in for this one? Put your hand up and the coach will let you know.', 2),
    ('requested',       '#my — after asking',                                          '🙋 Call-in requested — the coach will let you know.', 3),
    ('withdraw',        '#my — take the request back',                                 'Take it back', 4),
    ('declined',        '#my — coach said not this week',                              'Not this week — thanks for putting your hand up.', 5),
    ('chip',            '#my — chip on the card',                                      'CALL-IN', 6),
    ('staff_title',     'Event Center — requests section title ({n})',                 '🙋 CALL-IN REQUESTS ({n})', 10),
    ('staff_note',      'Event Center — requests section note',                        'Accept = invited: Go / No shows for him and he sits in No Response until he answers. No text is sent.', 11),
    ('accept',          'Event Center — accept button',                                '✓ Accept', 12),
    ('decline',         'Event Center — not this week button',                         'Not this week', 13),
    ('undo_decline',    'Event Center — undo a not-this-week',                         'Undo', 14),
    ('declined_title',  'Event Center — declined list title ({n})',                    'Not this week ({n})', 15),
    ('off_list',        'Event Center — not on the league list warning',               '⚠ not on the APSL list', 16)
  ) AS v(tier, label, body, sort)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'callin' AND t.tier = v.tier);
