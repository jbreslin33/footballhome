-- 617 (2026-10-20) — Default call-downs, and the cap enforced on the
-- lineup itself.
--
-- Owner: "We need Sheldon Rhoden and Armando Pena with call down on
-- default but with a setting so i can change it … we should not even be
-- able to add more than 2 to lineup right?"
--
-- team_auto_invites: who is invited to a team's games BY DEFAULT.  A
-- trigger invites them (channel 'auto', no message sent — the game just
-- appears on their #my with a Go/No) the moment a game is bridged to the
-- team; the 🎟 panel gets a per-player ⭐ Auto toggle that flips the row
-- and back-fills / revokes future games.  The mig-616 cap still counts
-- these invites, and the lineup save now refuses more than the cap's
-- call-downs in starters + bench (EligibilityController).

CREATE TABLE IF NOT EXISTS team_auto_invites (
    id           serial PRIMARY KEY,
    team_id      int NOT NULL REFERENCES teams(id),     -- whose games
    person_id    int NOT NULL REFERENCES persons(id),
    from_team_id int REFERENCES teams(id),              -- squad they come down from
    active       boolean NOT NULL DEFAULT true,
    created_at   timestamptz NOT NULL DEFAULT now(),
    UNIQUE (team_id, person_id)
);
COMMENT ON TABLE team_auto_invites IS
  'mig 617: standing call-downs — people invited to every new game of team_id automatically (fh_event_invites channel ''auto''; visibility only, no message). Toggled from the 🎟 panel.';

-- 'auto' joins the invite channels (sms/email/copy): an invite that was
-- never messaged — it only grants the game on the player's page.
ALTER TABLE fh_event_invites DROP CONSTRAINT IF EXISTS fh_event_invites_channel_check;
ALTER TABLE fh_event_invites ADD CONSTRAINT fh_event_invites_channel_check
  CHECK (channel IS NULL OR channel = ANY (ARRAY['sms'::text, 'email'::text, 'copy'::text, 'auto'::text]));

-- Sheldon Rhoden and Armando Pena ride every Liga 1 (CASA) game by default.
INSERT INTO team_auto_invites (team_id, person_id, from_team_id)
VALUES (120, 22433, 35), (120, 22710, 35)
ON CONFLICT (team_id, person_id) DO NOTHING;

-- A new game bridged to the team invites its standing call-downs.  Games
-- only — practices stay invite-by-hand.
CREATE OR REPLACE FUNCTION fh_apply_team_auto_invites() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  INSERT INTO fh_event_invites (fh_event_id, person_id, from_team_id, recipient_person_id, channel)
  SELECT NEW.fh_event_id, a.person_id, a.from_team_id, a.person_id, 'auto'
    FROM team_auto_invites a
    JOIN fh_events fe ON fe.id = NEW.fh_event_id AND fe.kind = 'match'
   WHERE a.team_id = NEW.team_id AND a.active
     AND NOT EXISTS (SELECT 1 FROM fh_event_invites i
                      WHERE i.fh_event_id = NEW.fh_event_id
                        AND i.person_id = a.person_id AND i.revoked_at IS NULL);
  RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS trg_team_auto_invites ON fh_event_teams;
CREATE TRIGGER trg_team_auto_invites
AFTER INSERT ON fh_event_teams
FOR EACH ROW EXECUTE FUNCTION fh_apply_team_auto_invites();

-- Back-fill: every UPCOMING game already bridged to a team with standing
-- call-downs gets their invites now.
INSERT INTO fh_event_invites (fh_event_id, person_id, from_team_id, recipient_person_id, channel)
SELECT fet.fh_event_id, a.person_id, a.from_team_id, a.person_id, 'auto'
  FROM team_auto_invites a
  JOIN fh_event_teams fet ON fet.team_id = a.team_id
  JOIN fh_events fe ON fe.id = fet.fh_event_id AND fe.kind = 'match'
  JOIN gcal_events ge ON ge.id = fe.gcal_event_id AND ge.deleted_at IS NULL
                     AND ge.starts_at > now()
 WHERE a.active
   AND NOT EXISTS (SELECT 1 FROM fh_event_invites i
                    WHERE i.fh_event_id = fet.fh_event_id
                      AND i.person_id = a.person_id AND i.revoked_at IS NULL);
