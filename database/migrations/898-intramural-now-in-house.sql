-- 898 (2026-10-30) — "Intramural" is now "In-House" everywhere.
--
-- Owner 2026-10-30: "lets change intramural to in house in all spots".
-- Spelled In-House, as the club's published copy already is.  Team ids and
-- rosters do not change.
--
-- Google Calendar's Team: tags still say "u10 intramural" on 3,600 upcoming
-- events: those old aliases stay so they keep landing on the right team, and
-- a new event can be tagged either way.
UPDATE teams
   SET name = replace(name, 'Intramural', 'In-House'), label = replace(label, 'Intramural', 'In-House')
 WHERE name ~ 'Intramural' OR label ~ 'Intramural';

UPDATE message_templates
   SET body = replace(body, 'intramural', 'in-house'), label = replace(label, 'intramural', 'in-house')
 WHERE body ~ 'intramural' OR label ~ 'intramural';

INSERT INTO gcal_team_aliases (club_alias, team_alias, team_id, notes)
SELECT a.club_alias, replace(a.team_alias, 'intramural', v.word), a.team_id, a.notes
  FROM gcal_team_aliases a CROSS JOIN (VALUES ('in-house'), ('in house')) AS v(word)
 WHERE a.team_alias ~ 'intramural'
   AND NOT EXISTS (SELECT 1 FROM gcal_team_aliases x
                    WHERE x.club_alias = a.club_alias AND x.team_alias = replace(a.team_alias, 'intramural', v.word));
