-- 514 (2026-10-03) — The dues block on games and practices is off for
-- everyone, for now.
--
-- Owner: "we need to take out completely for now the no rsvp for 70 or
-- more owed. for everyone. jusst post a warning that if not brought under
-- 70 they may soon blocked from practice and games."
--
-- Mig 513 left the block on for the Men's section only.  The switch is
-- still dues_policies.blocks_eligibility; from today the Men's policy in
-- force has it off, so nobody is refused an RSVP, shown the pay-link pill
-- or flagged in Game Center, and everyone at or over the line gets the
-- amber warning on #my (my_dues / warning).  Turning the block back on is
-- a new Men's (or club-wide) row with blocks_eligibility on.
--
-- The days the block WAS on stay on the record: the Men's blocking row is
-- backdated to the day the 2-month line came in (2026-09-23) and ends with
-- today's row, and the "at" functions read the policy in force on the day
-- — so a Men's fine for a practice missed while dues-blocked stays exempt
-- (mig 461), and days from today on are fine-able again.

UPDATE dues_policies
   SET effective_from = DATE '2026-09-23'
 WHERE club_id = 134
   AND club_section_id = (SELECT id FROM club_sections WHERE code = 'M')
   AND effective_from = DATE '2026-10-02'
   AND blocks_eligibility;

INSERT INTO dues_policies (club_id, club_section_id, monthly_dues_usd, pause_after_months,
                           effective_from, partial_amounts_usd, blocks_eligibility)
SELECT 134, cs.id, d.monthly_dues_usd, d.pause_after_months, DATE '2026-10-03', d.partial_amounts_usd, false
  FROM club_sections cs
  JOIN LATERAL (SELECT monthly_dues_usd, pause_after_months, partial_amounts_usd
                  FROM dues_policies
                 WHERE club_id = 134 AND club_section_id = cs.id
                 ORDER BY effective_from DESC LIMIT 1) d ON true
 WHERE cs.code = 'M'
   AND NOT EXISTS (SELECT 1 FROM dues_policies p
                    WHERE p.club_id = 134 AND p.club_section_id = cs.id
                      AND p.effective_from = DATE '2026-10-03');

-- Does the policy in force for this section on this day block?  Section
-- row first, then the club-wide one; no row = no block.
DROP FUNCTION IF EXISTS fh_dues_policy_blocks(int, int);
CREATE OR REPLACE FUNCTION fh_dues_policy_blocks(p_club_id int, p_club_section_id int, p_on date DEFAULT CURRENT_DATE)
RETURNS boolean LANGUAGE sql STABLE AS $$
  SELECT COALESCE((
    SELECT blocks_eligibility
      FROM dues_policies
     WHERE club_id = p_club_id
       AND (club_section_id IS NULL OR club_section_id = p_club_section_id)
       AND effective_from <= p_on
     ORDER BY (club_section_id IS NOT NULL) DESC, effective_from DESC
     LIMIT 1), false)
$$;
COMMENT ON FUNCTION fh_dues_policy_blocks(int, int, date) IS
  'mig 513/514: whether the dues policy in force for a section on a day makes the dues line a block on games and practices.';

-- Was this person subject to the block on this day: a current roster spot
-- on a team of a section whose policy in force that day blocks.
DROP FUNCTION IF EXISTS fh_dues_blocks_eligibility(int, int);
CREATE OR REPLACE FUNCTION fh_dues_blocks_eligibility(p_person_id int, p_club_id int DEFAULT 134, p_on date DEFAULT CURRENT_DATE)
RETURNS boolean LANGUAGE sql STABLE AS $$
  SELECT EXISTS (
    SELECT 1
      FROM team_persons tp
      JOIN teams t ON t.id = tp.team_id
     WHERE tp.person_id = p_person_id
       AND tp.removed_at IS NULL
       AND t.club_id = p_club_id
       AND t.club_section_id IS NOT NULL
       AND fh_dues_policy_blocks(p_club_id, t.club_section_id, p_on))
$$;
COMMENT ON FUNCTION fh_dues_blocks_eligibility(int, int, date) IS
  'mig 513/514: true when the person is on a current roster of a section whose dues policy in force on the day blocks games and practices at the line (nobody since 2026-10-03; Men 2026-09-23 to 2026-10-02).';

CREATE OR REPLACE FUNCTION fh_dues_eligible_at(p_person_id int, p_club_id int, p_at timestamptz)
RETURNS boolean LANGUAGE sql STABLE AS $$
  SELECT NOT fh_dues_blocks_eligibility(p_person_id, p_club_id, (p_at AT TIME ZONE 'America/New_York')::date)
      OR COALESCE(fh_dues_balance_at(p_person_id, p_at) < fh_dues_line_usd(p_club_id), true)
$$;

-- The warning everyone at or over the line now sees on #my.
UPDATE message_templates
   SET body  = 'Dues {amount} owed — please bring it under {pause_amount} (at least {min_payment}) or you may soon be blocked from practices and games.',
       label = 'My — dues warning (over the line)'
 WHERE kind = 'my_dues' AND tier = 'warning';
