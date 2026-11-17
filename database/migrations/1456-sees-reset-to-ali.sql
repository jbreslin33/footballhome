-- 👁 SEES reset (owner 11/17 "sees table should be empty right except for
-- ali … then i can add to it" + "lets reset it"): Sheldon Rhoden's
-- standing call-down to L1 (carried over from team_auto_invites) ends now.
-- Ended rows stay as history for past games; open rows = Ali only.
UPDATE person_team_sees SET ended_at = now()
 WHERE ended_at IS NULL
   AND person_id <> 3509;   -- Ali Salah Alshami stays (APSL → L1)
