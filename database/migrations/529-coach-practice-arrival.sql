-- 529 (2026-10-05) — coaches arrive before a practice starts.
-- Owner: "also practice arrival for coaches for u8 is 4pm" … "arrival for
-- parents can be at practice time for all practices. coaches need to be
-- there 30 minutes ahead to setup" — so every training group's coaches are
-- due 30 minutes before the start (4:00 for the 4:30 session); players and
-- parents arrive at practice time.
--
-- How long before the start a training group's coaches arrive is a column
-- on the group (rsvp_team_groups, mig 419).  The calendar feed hands a
-- coach / staff viewer that time on the group's practices
-- (coach_arrival_at); #my shows it on the card, uses it as the coach's own
-- default Arrive time and in the conflict check (mig 526).  Players and
-- children keep the event's own times.  NULL = coaches arrive at the start.
ALTER TABLE rsvp_team_groups ADD COLUMN IF NOT EXISTS coach_arrival_minutes_before INTEGER;
COMMENT ON COLUMN rsvp_team_groups.coach_arrival_minutes_before IS 'Minutes before a practice of this group starts that its coaches are due (mig 529); NULL = at the start.';
UPDATE rsvp_team_groups SET coach_arrival_minutes_before = 30 WHERE club_id = 134;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'System', 'My schedule — card: when coaches arrive for a practice', 'my_schedule', 'coach_arrival', NULL, 'Coaches arrive {time}', 36, true, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'my_schedule' AND tier = 'coach_arrival');
