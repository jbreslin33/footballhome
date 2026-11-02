-- 899 (2026-10-30) — Youth is four teams: U8, U10, U12, U19.
--
-- Owner 2026-10-30: "dump ALL playhers u8 and under to u8. then dump all u13
-- to u19 to a u19 and get rid of u16", "it would not even be called travel
-- right?", "if a player is NOT ON ROSTER then they should not see game. set
-- it up just like men in teams. roster and teams".
--
-- The Travel and In-House teams at one age had the same practices, and the
-- In-House teams had no games, so a second team only ever said "not in
-- games".  Now the roster status says it:
--
--   U8   912   U8 Travel + U8 In-House 935 + U6 In-House 931
--   U10  913   U10 Travel + U10 In-House 936
--   U12  914   U12 Travel + U12 In-House 937
--   U19  932   U19 In-House + U16 In-House 934
--
-- teams.games_need_roster: on these teams a player whose status does not
-- count as On Roster is a ↔ Call In (mig 637: invite_only + call_in, the
-- men's board's words) — every practice, and a game only by invite.  A
-- trigger sets it from the status, so On Roster gives the games by itself.
-- U19 has no games and no league list, so it is not flagged.
--
-- Google Calendar is not touched: every old tag still lands on the right
-- team through gcal_team_aliases.
ALTER TABLE teams ADD COLUMN IF NOT EXISTS games_need_roster boolean NOT NULL DEFAULT false;
UPDATE teams SET games_need_roster = true WHERE id IN (912, 913, 914);

CREATE OR REPLACE FUNCTION fh_team_persons_games_need_roster() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE on_list boolean;
BEGIN
    IF (SELECT games_need_roster FROM teams WHERE id = NEW.team_id) THEN
        on_list := COALESCE((SELECT counts_as_on_roster FROM roster_statuses WHERE id = NEW.roster_status_id), false);
        NEW.invite_only := NOT on_list;
        NEW.call_in     := NOT on_list;
    END IF;
    RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS team_persons_games_need_roster ON team_persons;
CREATE TRIGGER team_persons_games_need_roster
    BEFORE INSERT OR UPDATE OF roster_status_id ON team_persons
    FOR EACH ROW EXECUTE FUNCTION fh_team_persons_games_need_roster();

CREATE TEMP TABLE youth_merge (src int, dst int);
INSERT INTO youth_merge VALUES (931, 912), (935, 912), (936, 913), (937, 914), (934, 932);

-- Players: a new row on the kept team (the trigger makes it a Call In there),
-- the old one closed.
INSERT INTO team_persons (team_id, person_id, assigned_by_user_id)
SELECT m.dst, tp.person_id, tp.assigned_by_user_id
  FROM team_persons tp JOIN youth_merge m ON m.src = tp.team_id
 WHERE tp.removed_at IS NULL
   AND NOT EXISTS (SELECT 1 FROM team_persons x WHERE x.team_id = m.dst AND x.person_id = tp.person_id AND x.removed_at IS NULL);

UPDATE team_persons tp SET removed_at = now(), removed_reason = 'team_merge'
  FROM youth_merge m WHERE m.src = tp.team_id AND tp.removed_at IS NULL;

-- Who is already on a kept team and not On Roster.
UPDATE team_persons tp SET invite_only = true, call_in = true
  FROM teams t
 WHERE t.id = tp.team_id AND t.games_need_roster AND tp.removed_at IS NULL
   AND NOT COALESCE((SELECT counts_as_on_roster FROM roster_statuses WHERE id = tp.roster_status_id), false);

-- Coaches.
INSERT INTO team_coaches (team_id, coach_id, coach_role_id)
SELECT DISTINCT ON (m.dst, tc.coach_id) m.dst, tc.coach_id, tc.coach_role_id
  FROM team_coaches tc JOIN youth_merge m ON m.src = tc.team_id
 WHERE tc.ended_at IS NULL
   AND NOT EXISTS (SELECT 1 FROM team_coaches x WHERE x.team_id = m.dst AND x.coach_id = tc.coach_id AND x.ended_at IS NULL)
 ORDER BY m.dst, tc.coach_id, tc.coach_role_id NULLS LAST;

UPDATE team_coaches tc SET ended_at = now()
  FROM youth_merge m WHERE m.src = tc.team_id AND tc.ended_at IS NULL;

-- Events (practices only: these teams have no games).
INSERT INTO fh_event_teams (fh_event_id, team_id)
SELECT et.fh_event_id, m.dst
  FROM fh_event_teams et JOIN youth_merge m ON m.src = et.team_id
ON CONFLICT DO NOTHING;
DELETE FROM fh_event_teams et USING youth_merge m WHERE m.src = et.team_id;

UPDATE gcal_team_aliases a SET team_id = m.dst FROM youth_merge m WHERE m.src = a.team_id;

INSERT INTO rsvp_team_group_teams (group_id, team_id)
SELECT g.group_id, m.dst FROM rsvp_team_group_teams g JOIN youth_merge m ON m.src = g.team_id
ON CONFLICT DO NOTHING;
DELETE FROM rsvp_team_group_teams g USING youth_merge m WHERE m.src = g.team_id;

UPDATE teams SET is_active = false WHERE id IN (SELECT src FROM youth_merge);

-- The official list is the limit now; 12/12/16 counted squads.
UPDATE teams SET max_roster = NULL WHERE id IN (912, 913, 914);

UPDATE teams SET name = 'U8',  label = '⚽ U8',  short_label = 'U8'  WHERE id = 912;
UPDATE teams SET name = 'U10', label = '⚽ U10', short_label = 'U10' WHERE id = 913;
UPDATE teams SET name = 'U12', label = '⚽ U12', short_label = 'U12' WHERE id = 914;
UPDATE teams SET name = 'U19', label = '⚽ U19', short_label = 'U19' WHERE id = 932;

UPDATE message_templates
   SET body = replace(replace(body, 'a travel or in-house team', 'a team'), 'in travel games', 'in league games'),
       label = replace(label, 'assumed in-house team', 'assumed team')
 WHERE kind IN ('welcome_docs', 'welcome_no_team', 'welcome_assumed_team');
