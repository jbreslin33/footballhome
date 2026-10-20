-- 613 (2026-10-20) — Any dues balance makes a Men's player an ALTERNATE,
-- never a ban.
--
-- Owner: "for any player with a balance on mens side we warn them that
-- they will be at bottom of selection pool for starters and bench for
-- apsl and liga 1 games until balance is paid. this way we don't ban
-- them in case we need them and they can still see everything …
-- this warning can go right on the game and i would probably list them
-- as alternates … this way no one else sees it to embarrass them but
-- there is pressure now."
--
-- Mechanics: a new policy switch (alternate_on_balance) on dues_policies,
-- turned on for the Men's section only.  Where it is in force, ANY
-- balance > 0 marks the player dues-alternate on that section's games:
-- the Game Center selection pool sorts them to the bottom, the coach
-- sees a small chip, and the player reads a private warning on their own
-- eligibility card.  Nothing is blocked — RSVP, visibility and call-ups
-- are untouched — and nobody else's view shows it (the server blanks the
-- flag on every row that is not the viewer's own, unless the viewer is
-- the coach).  Distinct from blocks_eligibility (mig 513, the $70-line
-- RSVP ban, off since 2026-10-03).

ALTER TABLE dues_policies
  ADD COLUMN IF NOT EXISTS alternate_on_balance boolean NOT NULL DEFAULT false;
COMMENT ON COLUMN dues_policies.alternate_on_balance IS
  'mig 613: true = ANY dues balance makes a member of this section an alternate on its games — bottom of the starter/bench selection pool, private warning on the game — without blocking anything.';

-- The Men''s section row in force gets the switch: a fresh row effective
-- today so history keeps what each period''s policy actually was.
INSERT INTO dues_policies (club_id, club_section_id, monthly_dues_usd, pause_after_months,
                           effective_from, partial_amounts_usd, blocks_eligibility, alternate_on_balance)
SELECT d.club_id, d.club_section_id, d.monthly_dues_usd, d.pause_after_months,
       DATE '2026-10-20', d.partial_amounts_usd, false, true
  FROM dues_policies d
  JOIN club_sections cs ON cs.id = d.club_section_id AND cs.code = 'M'
 WHERE d.club_id = 134 AND d.effective_from <= DATE '2026-10-20'
 ORDER BY d.effective_from DESC
 LIMIT 1;

-- Does the policy in force for this section mark balance-holders as
-- alternates?  Section row first, then club-wide; no row = no.
-- (Same shape as fh_dues_policy_blocks, mig 513.)
CREATE OR REPLACE FUNCTION fh_dues_policy_alternates(p_club_id int, p_club_section_id int)
RETURNS boolean LANGUAGE sql STABLE AS $$
  SELECT COALESCE((
    SELECT alternate_on_balance
      FROM dues_policies
     WHERE club_id = p_club_id
       AND (club_section_id IS NULL OR club_section_id = p_club_section_id)
       AND effective_from <= CURRENT_DATE
     ORDER BY (club_section_id IS NOT NULL) DESC, effective_from DESC
     LIMIT 1), false)
$$;
COMMENT ON FUNCTION fh_dues_policy_alternates(int, int) IS
  'mig 613: whether the dues policy in force for a section makes any balance an alternate marker on its games (Men only since 2026-10-20).';

-- Copy (never hardcoded): the private warning on the player''s own
-- eligibility card, its heading, and the coach''s chip.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, client_side)
SELECT 'System', 'Game — dues alternate warning (player''s own view)', 'my_dues', 'alternate_game', NULL,
       'Dues {amount} owed — until it''s paid you''re an alternate for this game: bottom of the selection pool for starters and bench, and you may not be called on. Any payment moves you back up.', 7, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'my_dues' AND tier = 'alternate_game');

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, client_side)
SELECT 'System', 'Game — dues alternate box heading', 'my_dues', 'alternate_heading', NULL,
       'Dues', 8, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'my_dues' AND tier = 'alternate_heading');

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, client_side)
SELECT 'System', 'Game Center — dues alternate chip (coach view + the player''s own card)', 'my_dues', 'alternate_chip', NULL,
       'Alternate · dues owed', 9, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'my_dues' AND tier = 'alternate_chip');
