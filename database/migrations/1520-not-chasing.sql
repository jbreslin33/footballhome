-- 1520 (2026-11-19) — Chase list vs not chasing; men's Practice Squad.
--
-- Owner, deadline day with 18 Liga 1 no-responses: "some of them are ghosts
-- for sure" → "they are cluttering my graphic and the players view
-- graphic" → "there a group that if they are paying dues but 'busy' we
-- don't want to spam them every day. i am thinking 1x per week reminder if
-- that for them … they are practice squaid. and actually i dont even think
-- we remind practice squad for practice" → "a practice squad player for
-- men is diff then youth" → the #teams Team groups decide the game card:
--
--   ACTIVE / 🟢 NEEDS ADD   → – No response (chase, reminded)
--   NEEDS ONBOARD           → 👋 Not chasing fold (never answered anything)
--   🏋 PRACTICE SQUAD        → doesn't see games unless called up (as before)
--   🩹 INJURED / 💤 INACTIVE → their own folds (as before)
--
-- 1. squad_status_section_rules — a squad status can behave differently per
--    club section.  Men's 🏋 Practice Squad owes NO practice answers (youth
--    Practice Squad still does: "no spot on this team, practises with the
--    age group").  fh_squad_owes_practice(status, team) reads it; the RSVP
--    board and the event who's-coming list use it.
-- 2. fh_person_needs_onboard(person) — never answered an RSVP himself (or
--    via a parent): the #teams NEEDS ONBOARD rule, now on the event payloads
--    so every card agrees.
-- 3. rsvp_reminder_hold_policies + fh_rsvp_reminder_held(person) — a man who
--    needs onboarding or is on 🏋 Practice Squad on every men's row gets at
--    most one RSVP reminder per 7 days, whoever taps Remind and however
--    often (Kante got 14 in 14 days).
-- 4. Words.

BEGIN;

-- 1 ────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS squad_status_section_rules (
  club_section_id      integer NOT NULL REFERENCES club_sections(id),
  squad_status_id      integer NOT NULL REFERENCES squad_statuses(id),
  owes_practice_rsvps  boolean NOT NULL,
  PRIMARY KEY (club_section_id, squad_status_id)
);
COMMENT ON TABLE squad_status_section_rules IS
  'mig 1520: per-section override of a squad status''s behaviour (squad_statuses is the default). Men''s Practice Squad owes no practice RSVPs; youth keeps the default.';

INSERT INTO squad_status_section_rules (club_section_id, squad_status_id, owes_practice_rsvps)
SELECT cs.id, ss.id, false FROM club_sections cs, squad_statuses ss
 WHERE cs.code = 'M' AND ss.code = 'practice_squad'
ON CONFLICT DO NOTHING;

CREATE OR REPLACE FUNCTION fh_squad_owes_practice(p_squad_status_id integer, p_team_id integer)
RETURNS boolean LANGUAGE sql STABLE AS $$
  SELECT COALESCE(r.owes_practice_rsvps, ss.owes_practice_rsvps)
    FROM squad_statuses ss
    LEFT JOIN teams t ON t.id = p_team_id
    LEFT JOIN squad_status_section_rules r
           ON r.squad_status_id = ss.id AND r.club_section_id = t.club_section_id
   WHERE ss.id = p_squad_status_id
$$;
COMMENT ON FUNCTION fh_squad_owes_practice(integer, integer) IS
  'mig 1520: does this squad status on this team owe practice RSVPs? Section rule (squad_status_section_rules) else squad_statuses.owes_practice_rsvps.';

-- 2 ────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION fh_person_needs_onboard(p_person_id integer)
RETURNS boolean LANGUAGE sql STABLE AS $$
  SELECT NOT EXISTS (SELECT 1 FROM fh_event_rsvps r
                      WHERE r.person_id = p_person_id AND r.created_via = 'manual')
$$;
COMMENT ON FUNCTION fh_person_needs_onboard(integer) IS
  'mig 1520: never answered an RSVP himself or through a parent (standing defaults and admin overrides don''t count) — #teams NEEDS ONBOARD; on the cards = 👋 Not chasing.';

-- 3 ────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS rsvp_reminder_hold_policies (
  club_id     integer PRIMARY KEY REFERENCES clubs(id),
  hold_days   smallint NOT NULL CHECK (hold_days > 0),
  created_at  timestamptz NOT NULL DEFAULT now()
);
COMMENT ON TABLE rsvp_reminder_hold_policies IS
  'mig 1520: a not-chasing man (fh_person_needs_onboard, or men''s Practice Squad on every men''s row) gets at most one RSVP reminder per hold_days.';
INSERT INTO rsvp_reminder_hold_policies (club_id, hold_days) VALUES (134, 7) ON CONFLICT DO NOTHING;

-- NULL = may be reminded; else the instant the hold ends.
CREATE OR REPLACE FUNCTION fh_rsvp_reminder_held_until(p_person_id integer, p_club_id integer DEFAULT 134)
RETURNS timestamptz LANGUAGE sql STABLE AS $$
  WITH pol AS (SELECT hold_days FROM rsvp_reminder_hold_policies WHERE club_id = p_club_id),
  not_chasing AS (
    SELECT fh_person_needs_onboard(p_person_id)
        OR (EXISTS (SELECT 1 FROM team_persons tp JOIN teams t ON t.id = tp.team_id
                     JOIN club_sections cs ON cs.id = t.club_section_id AND cs.code = 'M'
                    WHERE tp.person_id = p_person_id AND tp.removed_at IS NULL)
            AND NOT EXISTS (SELECT 1 FROM team_persons tp JOIN teams t ON t.id = tp.team_id
                             JOIN club_sections cs ON cs.id = t.club_section_id AND cs.code = 'M'
                             LEFT JOIN squad_statuses ss ON ss.id = tp.squad_status_id
                            WHERE tp.person_id = p_person_id AND tp.removed_at IS NULL
                              AND t.is_active AND (ss.code IS NULL OR ss.code <> 'practice_squad'))) AS yes
  ), last AS (
    SELECT max(sent_at) AS at FROM rsvp_reminders WHERE person_id = p_person_id
  )
  SELECT last.at + make_interval(days => pol.hold_days)
    FROM pol, not_chasing, last
   WHERE not_chasing.yes AND last.at IS NOT NULL
     AND last.at + make_interval(days => pol.hold_days) > now()
$$;
COMMENT ON FUNCTION fh_rsvp_reminder_held_until(integer, integer) IS
  'mig 1520: when a not-chasing man''s weekly RSVP-reminder hold ends (NULL = free to remind). Read by /api/rsvp-board/remind and remind-event.';

-- 4 ────────────────────────────────────────────────────────────────────
INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side)
SELECT 'Event Center', v.label, 'event_center', v.tier, v.body, v.ord, true
  FROM (VALUES
    ('sec_not_chasing', 'Event / game card: never answered anything — not chased (fold + graphic row)',
     '👋 Not chasing', 905),
    ('sec_not_chasing_tip', 'Event / game card: not chasing — hover',
     'Never answered an RSVP. Not in Remind all; at most one reminder a week. They move to No response the first time they answer.', 906)
  ) AS v(tier, label, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = v.tier);

INSERT INTO message_templates (category, label, kind, tier, body, sort_order)
SELECT 'RSVP', 'Reminder held: weekly cap for a not-chasing player', 'rsvp_reminder', 'held',
       'Held — {first} was reminded {when}; not-chasing players get one a week (next after {next}).', 90
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'rsvp_reminder' AND m.tier = 'held');

COMMIT;
