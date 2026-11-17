-- Standing CALL-UPS retired; standing CALL-DOWNS stay (owner 11/17 "yes
-- remove it. but we need standing call down due to apsl/casa rule that if
-- on apsl roster but not liga 1 we can still call down 2 apsl players to
-- liga 1" + "standing call down can be more than 2 and we would select
-- based on whatever").
--
-- An official league list now puts a man on that team's games (mig 1443),
-- so a standing call-up (L1 → APSL) is redundant. A standing call-down
-- (APSL → L1) is not: the APSL man is on no CASA list. A standing invite is
-- now allowed only where a league call-down cap exists (team_invite_caps
-- to_team ← from_team; today APSL → L1, max 2 per game). The standing list
-- itself is unlimited; the cap binds the squad only (Game Center, migs
-- 616/617).

CREATE OR REPLACE FUNCTION fh_team_auto_invites_call_down_only()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.active AND NOT EXISTS (SELECT 1 FROM team_invite_caps c
                                 WHERE c.to_team_id = NEW.team_id AND c.from_team_id = NEW.from_team_id) THEN
    RAISE EXCEPTION 'Standing invites are call-downs only (a league call-down rule from team % to team %)', NEW.from_team_id, NEW.team_id;
  END IF;
  RETURN NEW;
END $$;
DROP TRIGGER IF EXISTS trg_team_auto_invites_call_down_only ON team_auto_invites;

-- Retire the standing call-ups (Isaac Anderson, Lusayo Mwakatika → APSL;
-- both on an APSL list, so mig 1443 keeps them on APSL games).
WITH retired AS (
  UPDATE team_auto_invites a SET active = false
   WHERE a.active AND NOT EXISTS (SELECT 1 FROM team_invite_caps c
                                   WHERE c.to_team_id = a.team_id AND c.from_team_id = a.from_team_id)
  RETURNING a.team_id, a.person_id
)
UPDATE fh_event_invites i SET revoked_at = now()
  FROM retired r, fh_events fe, gcal_events ge
 WHERE i.person_id = r.person_id AND i.channel = 'auto' AND i.revoked_at IS NULL
   AND fe.id = i.fh_event_id AND ge.id = fe.gcal_event_id AND ge.starts_at > now()
   AND EXISTS (SELECT 1 FROM fh_event_teams fet WHERE fet.fh_event_id = fe.id AND fet.team_id = r.team_id);

CREATE TRIGGER trg_team_auto_invites_call_down_only BEFORE INSERT OR UPDATE ON team_auto_invites
  FOR EACH ROW EXECUTE FUNCTION fh_team_auto_invites_call_down_only();

-- The list invites take over where the auto ones were revoked.
SELECT fh_sync_roster_game_invites() AS list_sync;

-- 👁 SEES: a standing invite is a call-down now.
UPDATE message_templates SET body = '⬇⚽', label = 'Card — SEES: standing call-down (games of the lower team)'
 WHERE kind = 'roster_sheet' AND tier = 'card_sees_invite';

-- The standing call-up chip is gone (#teams cards): its words retire.
UPDATE message_templates SET is_active = false
 WHERE kind = 'invite_chip' AND tier IN ('standing_up', 'standing_up_tip');
