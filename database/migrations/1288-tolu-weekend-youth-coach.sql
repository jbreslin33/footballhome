-- 1288 (2026-11-11): Tolu Asekun-Masha back as a youth coach, weekends.
-- Owner: "youth coach on weekends. so he should see all youth weekend stuff
-- and needs to rsvp to it."  (He came off coaching in mig 952; volunteer
-- row from mig 1286.)
--
--  * Assistant coach on every active youth team (fall/spring + ❄️ winter),
--    like every other youth coach (mig 1204).
--  * #coach-schedule (mig 955): Youth section, Sat + Sun only → he sees and
--    RSVPs to weekend practices.  practices_only stays false so youth games
--    show too (the schedule never filters games).

BEGIN;

INSERT INTO team_coaches (team_id, coach_id, coach_role_id)
SELECT t.id, c.id, (SELECT id FROM coach_roles WHERE name = 'assistant')
  FROM coaches c
  JOIN teams t ON t.is_active AND t.gender_category IN ('boys', 'girls')
 WHERE c.person_id = 22598
   AND NOT EXISTS (SELECT 1 FROM team_coaches x
                    WHERE x.team_id = t.id AND x.coach_id = c.id AND x.ended_at IS NULL);

INSERT INTO coach_schedules (coach_id, club_section_id)
SELECT c.id, cs.id
  FROM coaches c, club_sections cs
 WHERE c.person_id = 22598 AND cs.code = 'B'
ON CONFLICT (coach_id, club_section_id) DO NOTHING;

DELETE FROM coach_schedule_days d
 USING coach_schedules s, coaches c
 WHERE d.coach_schedule_id = s.id AND s.coach_id = c.id AND c.person_id = 22598
   AND d.isodow NOT IN (6, 7);

INSERT INTO coach_schedule_days (coach_schedule_id, isodow)
SELECT s.id, d
  FROM coach_schedules s
  JOIN coaches c ON c.id = s.coach_id AND c.person_id = 22598
  JOIN club_sections cs ON cs.id = s.club_section_id AND cs.code = 'B'
 CROSS JOIN (VALUES (6), (7)) AS v(d)
ON CONFLICT DO NOTHING;

UPDATE club_volunteers SET helps_with = 'Youth coach (weekends)' WHERE person_id = 22598;

INSERT INTO schema_migrations (filename) VALUES ('1288-tolu-weekend-youth-coach.sql') ON CONFLICT DO NOTHING;

COMMIT;
