-- 618 (2026-10-20) — The call-down cap binds the LINEUP, not the invites.
--
-- Owner: "we should be able to have more than 2 calls out and more than 2
-- set going etc. what we need to not allow is me putting 3 or more in
-- liga 1 lineup."
--
-- Code change in the same commit removed the invite-time refusals (the
-- invite POST and the ⭐ Auto toggle are uncapped again); the rule lives
-- in the lineup save (EligibilityController) and the tap guards, and the
-- 🎟 counter now counts call-downs in the SAVED SQUAD (starters + bench).
-- This migration only corrects the table's documentation.

COMMENT ON TABLE team_invite_caps IS
  'migs 616/618: league limits on CALL-DOWNS IN THE SQUAD — at most max_per_event players rostered on from_team (and not on a tagged team) may hold a starter/bench spot on a to_team game. Invites and Going answers are unlimited; enforced by the lineup save and the Game Center tap guards.';
