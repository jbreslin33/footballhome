-- Coach schedule (owner 11/2: "we need a schedule and that is what they would
-- rsvp too").  A coach with a schedule for a section is expected, and RSVPs,
-- only on those weekdays' practices of that section's teams.  No days = call in
-- if needed: nothing is expected until invited on the event.  A coach with no
-- schedule stays on every practice.  Games are never affected, and neither is
-- anything before the schedule starts.
CREATE TABLE coach_schedules (
    id              serial PRIMARY KEY,
    coach_id        integer NOT NULL REFERENCES coaches(id) ON DELETE CASCADE,
    club_section_id integer NOT NULL REFERENCES club_sections(id),
    starts_at       timestamptz NOT NULL DEFAULT now(),
    created_at      timestamptz NOT NULL DEFAULT now(),
    UNIQUE (coach_id, club_section_id)
);

CREATE TABLE coach_schedule_days (
    coach_schedule_id integer NOT NULL REFERENCES coach_schedules(id) ON DELETE CASCADE,
    isodow            smallint NOT NULL CHECK (isodow BETWEEN 1 AND 7),
    PRIMARY KEY (coach_schedule_id, isodow)
);

-- True when this coach's schedule leaves them off this event.
CREATE OR REPLACE FUNCTION fh_coach_off_schedule(p_person_id integer, p_team_id integer, p_fh_event_id bigint)
RETURNS boolean LANGUAGE sql STABLE AS $$
  SELECT EXISTS (
    SELECT 1
      FROM coach_schedules s
      JOIN coaches c ON c.id = s.coach_id AND c.person_id = p_person_id
      JOIN teams t ON t.id = p_team_id AND t.club_section_id = s.club_section_id
      JOIN fh_events fe ON fe.id = p_fh_event_id AND fe.kind = 'practice'
      JOIN gcal_events ge ON ge.id = fe.gcal_event_id
     WHERE ge.starts_at >= s.starts_at
       AND NOT EXISTS (SELECT 1 FROM coach_schedule_days d
                        WHERE d.coach_schedule_id = s.id
                          AND d.isodow = extract(isodow FROM ge.starts_at AT TIME ZONE 'America/New_York')::int))
$$;

-- Youth (Boys section, Girls play on its teams).  1 = Monday … 7 = Sunday, so
-- every day means every practice, whatever days practices move to.
INSERT INTO coach_schedules (coach_id, club_section_id)
SELECT c.id, cs.id
  FROM coaches c
  JOIN club_sections cs ON cs.code = 'B'
 WHERE c.person_id IN (SELECT p.id FROM persons p
                        WHERE (p.first_name, p.last_name) IN
                              (('Ali Salah','Alshami'), ('Luke','Breslin'), ('Anthony','Acevedo'),
                               ('Joseph','Vazquez'), ('Sheldon','Rhoden'), ('Victor','Baidal')))
   AND EXISTS (SELECT 1 FROM team_coaches tc JOIN teams t ON t.id = tc.team_id
                WHERE tc.coach_id = c.id AND tc.ended_at IS NULL AND t.club_section_id = cs.id);

INSERT INTO coach_schedule_days (coach_schedule_id, isodow)
SELECT s.id, d
  FROM coach_schedules s
  JOIN coaches c ON c.id = s.coach_id
  JOIN persons p ON p.id = c.person_id
 CROSS JOIN generate_series(1, 7) AS d
 WHERE (p.first_name = 'Ali Salah' AND d = 5)
    OR (p.last_name IN ('Rhoden', 'Baidal', 'Acevedo') OR (p.first_name, p.last_name) = ('Luke', 'Breslin'));
