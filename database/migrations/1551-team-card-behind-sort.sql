-- 1551 (2026-11-19) — #teams team cards: every group sorted worst-first + a count line.
--
-- Owner: "is it pointless on teams to categorize the players who are
-- regulars? like up to date in rsvp and dues, behind rsvp, behind in dues,
-- behind in both?" → "or is that better done as a sort?" → "yes build it"
-- → "it should do all reservees and injured etc" "for apsl and liga 1".
--
-- Each box group on the APSL and Liga 1 cards (Regulars pitch, folded
-- Reserves pitch, Reserves / Practice squad / Injured / Inactive bands)
-- sorts: behind on both → dues only → RSVP only → up to date, A–Z within.
-- Behind on RSVP = red (no own answer within rsvp_box_policy.yellow_days);
-- behind on dues = owes on a live membership (vol / $0 / no LA don't).
-- Each group shows one count line (frontend only; words below).
INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side)
SELECT 'Roster sheet', 'Team card: group count line ({ok} up to date, {rsvp} behind RSVP, {dues} behind dues, {both} behind both)',
       'roster_sheet', 'tc_tally', '✅ {ok} · RSVP {rsvp} · $ {dues} · both {both}', 902, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'roster_sheet' AND m.tier = 'tc_tally');
