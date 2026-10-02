-- 510 (2026-10-02) — Injuries: a health setting per person, with a time frame.
--
-- Owner: "we need an injured check box or setting in the drop down. for
-- status. like Healthy, short term injury, long term injury. or allow for
-- setting time frame."  Then: "this way we can avoid sending practice
-- reminders and fining them."  (Ryan Terrero, U12 Travel, injured — he sat
-- in No Response beside two players with no excuse.)
--
-- Health is a fact about the PERSON, not about a team's league paperwork,
-- so it is not a roster_statuses row: that dropdown says where a player is
-- in the league's pipeline (On Roster, Needs Docs …) and an injured player
-- is still On Roster.
--
--   health_statuses        the dropdown: Healthy, Short-term injury,
--                          Long-term injury — label, icon, colours
--   person_injuries        one row per injury: which kind, since when, and
--                          when the player is back (NULL = until someone
--                          sets Healthy).  Healthy is the absence of a row
--                          covering now; past injuries stay as history
--   fh_person_injured_at   was this person injured at that instant
--   fh_person_injury_label the chip on a card: "🩹 Short-term injury · back
--                          Tue Oct 20", NULL when healthy
--
-- While an injury lasts the player owes no RSVP: the #rsvps board and its
-- reminders skip every event inside the time frame they have not answered
-- (an answer they do give still counts), and fh_person_fines() fines
-- nothing inside it.  Their schedule on #my is untouched — they can still
-- answer.  rsvp_suspensions is the other tool, and the wrong one here: it
-- takes the events away from the player altogether.

CREATE TABLE IF NOT EXISTS health_statuses (
  id           serial PRIMARY KEY,
  code         varchar(30) NOT NULL UNIQUE,
  display_name varchar(60) NOT NULL,
  icon         text,
  is_injured   boolean NOT NULL,
  color_bg     varchar(7),
  color_fg     varchar(7),
  color_border varchar(7),
  sort_order   integer NOT NULL DEFAULT 0,
  is_active    boolean NOT NULL DEFAULT true
);
COMMENT ON TABLE health_statuses IS
  'The health dropdown on a roster card (mig 510). is_injured = false is "Healthy": choosing it ends the person''s current person_injuries row rather than storing one.';

INSERT INTO health_statuses (code, display_name, icon, is_injured, color_bg, color_fg, color_border, sort_order)
VALUES ('healthy',           'Healthy',           NULL, false, NULL,      NULL,      NULL,      1),
       ('short_term_injury', 'Short-term injury', '🩹', true,  '#f59e0b', '#422006', '#f59e0b', 2),
       ('long_term_injury',  'Long-term injury',  '🩹', true,  '#b91c1c', '#ffffff', '#f87171', 3)
ON CONFLICT (code) DO NOTHING;

CREATE TABLE IF NOT EXISTS person_injuries (
  id                 bigserial PRIMARY KEY,
  person_id          integer NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
  health_status_id   integer NOT NULL REFERENCES health_statuses(id),
  starts_at          timestamptz NOT NULL DEFAULT now(),
  ends_at            timestamptz,
  note               text,
  created_by_user_id integer REFERENCES users(id),
  created_at         timestamptz NOT NULL DEFAULT now(),
  CHECK (ends_at IS NULL OR ends_at > starts_at)
);
CREATE INDEX IF NOT EXISTS person_injuries_person_idx ON person_injuries (person_id, starts_at);
COMMENT ON TABLE person_injuries IS
  'A person''s injuries (mig 510). starts_at..ends_at is the time frame the player is excused from RSVPs and fines; ends_at NULL = until set Healthy, a future ends_at = the day they are back. Read through fh_person_injured_at().';

CREATE OR REPLACE FUNCTION fh_person_injured_at(p_person_id int, p_at timestamptz)
RETURNS boolean LANGUAGE sql STABLE AS $$
  SELECT EXISTS (
    SELECT 1 FROM person_injuries i
     WHERE i.person_id = p_person_id
       AND i.starts_at <= p_at
       AND (i.ends_at IS NULL OR i.ends_at > p_at))
$$;
COMMENT ON FUNCTION fh_person_injured_at(int, timestamptz) IS
  'True when a person_injuries row covers that instant (mig 510) — the player owed no RSVP then and is not fined for it.';

-- ── Copy ─────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION pg_temp.add_health_tpl(p_tier text, p_label text, p_body text, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
  SELECT 'System', p_label, 'health', p_tier, NULL, p_body, p_sort, true, true
   WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'health' AND tier = p_tier);
$$;
SELECT pg_temp.add_health_tpl('chip',         'Health — chip on a card, no return date',  '{icon} {status}', 1);
SELECT pg_temp.add_health_tpl('chip_until',   'Health — chip on a card, with return date', '{icon} {status} · back {date}', 2);
SELECT pg_temp.add_health_tpl('select_title', 'Health — tooltip on the dropdown',
  'Health — while injured a player gets no RSVP reminders and no fines', 3);
SELECT pg_temp.add_health_tpl('since_label',  'Health — label on the injured-since date', 'Injured since', 4);
SELECT pg_temp.add_health_tpl('until_label',  'Health — label on the back-on date',       'Back on (optional)', 5);

-- The chip.  {date} = "Tue Oct 20", the day the player is back.
CREATE OR REPLACE FUNCTION fh_person_injury_label(p_person_id int)
RETURNS text LANGUAGE sql STABLE AS $$
  SELECT btrim(replace(replace(replace(m.body,
           '{icon}',   COALESCE(h.icon, '')),
           '{status}', h.display_name),
           '{date}',   COALESCE(to_char(i.ends_at AT TIME ZONE 'America/New_York', 'Dy Mon FMDD'), '')))
    FROM person_injuries i
    JOIN health_statuses h ON h.id = i.health_status_id
    JOIN message_templates m
      ON m.kind = 'health' AND m.is_active
     AND m.tier = CASE WHEN i.ends_at IS NULL THEN 'chip' ELSE 'chip_until' END
   WHERE i.person_id = p_person_id
     AND i.starts_at <= now()
     AND (i.ends_at IS NULL OR i.ends_at > now())
   ORDER BY i.starts_at DESC, m.sort_order, m.id
   LIMIT 1
$$;

-- ── Fines: nothing inside an injury ──────────────────────────────────
-- As migration 461, plus the injury line in `owed`.
CREATE OR REPLACE FUNCTION fh_person_fines(p_person_ids int[], p_from timestamptz)
RETURNS TABLE (
  person_id      int,
  fh_event_id    bigint,
  team_id        int,
  starts_at      timestamptz,
  event_kind     text,
  opponent       text,
  fine_kind      text,
  amount_usd     numeric,
  response       text,
  attendance     text
) LANGUAGE sql STABLE AS $$
  WITH owed AS (
    SELECT DISTINCT ON (tp.person_id, fe.id)
           tp.person_id, fe.id AS fh_event_id, t.id AS team_id, t.club_id, t.club_section_id,
           ge.starts_at, fe.kind, fe.opponent,
           rv.response, rv.responded_at, att.status AS attendance
      FROM team_persons tp
      JOIN teams t              ON t.id = tp.team_id AND t.is_active
      LEFT JOIN roster_statuses rs ON rs.id = tp.roster_status_id
      JOIN fh_event_teams fet   ON fet.team_id = t.id
      JOIN fh_events fe         ON fe.id = fet.fh_event_id
                               AND fe.kind IN ('practice', 'match', 'intrasquad')
      JOIN gcal_events ge       ON ge.id = fe.gcal_event_id
      LEFT JOIN fh_event_rsvps rv       ON rv.fh_event_id = fe.id  AND rv.person_id  = tp.person_id
      LEFT JOIN fh_event_attendance att ON att.fh_event_id = fe.id AND att.person_id = tp.person_id
     WHERE tp.person_id = ANY (p_person_ids)
       AND tp.removed_at IS NULL
       AND COALESCE(rs.show_in_rsvp, true)
       AND t.club_section_id IS NOT NULL
       AND ge.deleted_at IS NULL AND ge.status IS DISTINCT FROM 'cancelled'
       AND ge.starts_at >= GREATEST(tp.joined_at, p_from)
       AND ge.starts_at <  now()
       AND NOT EXISTS (SELECT 1 FROM rsvp_suspensions s
                        WHERE s.person_id = tp.person_id
                          AND (s.team_id IS NULL OR s.team_id = t.id)
                          AND s.starts_at <= ge.starts_at
                          AND (s.ends_at IS NULL OR s.ends_at > ge.starts_at))
       -- Blocked from answering by dues on the event day: no fine (mig 461).
       AND fh_dues_eligible_at(tp.person_id, t.club_id, ge.starts_at)
       -- Injured on the event day: no fine (mig 510).
       AND NOT fh_person_injured_at(tp.person_id, ge.starts_at)
     ORDER BY tp.person_id, fe.id, t.id
  ), judged AS (
    SELECT o.*,
           CASE
             WHEN o.response IS NULL OR o.responded_at >= o.starts_at
               THEN CASE WHEN o.kind = 'practice' THEN 'missed_rsvp_practice' ELSE 'missed_rsvp_game' END
             WHEN o.response = 'yes' AND o.attendance = 'absent'
               THEN CASE WHEN o.kind = 'practice' THEN 'no_show_practice' ELSE 'no_show_game' END
           END AS fine_kind
      FROM owed o
  )
  SELECT j.person_id, j.fh_event_id, j.team_id, j.starts_at, j.kind, j.opponent,
         j.fine_kind, amt.amount_usd, j.response, j.attendance
    FROM judged j
    CROSS JOIN LATERAL (
      SELECT fh_fine_amount_usd(j.club_id, j.club_section_id, j.fine_kind,
                                (j.starts_at AT TIME ZONE 'America/New_York')::date) AS amount_usd
    ) amt
   WHERE j.fine_kind IS NOT NULL AND amt.amount_usd IS NOT NULL AND amt.amount_usd > 0
$$;
