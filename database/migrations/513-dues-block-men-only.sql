-- 513 (2026-10-02) — The dues block on games and practices is a Men's-section rule.
--
-- Owner: "stop the no rsvp functionality for youth. its causing problems.
-- keep it for men … when they owe 70 or more in dues. don't do the
-- functionality we put in where we block them. i will message them old
-- school … we can just put a label on their my page saying please at
-- least bring dues below 70 or you may lose eligibility for games and
-- practices."
--
-- The policy (dues_policies, mig 401/414/416) keeps its club-wide rate,
-- partial amounts and the 2-full-months line — #payments still tiers its
-- notices by months behind for everyone — but the CONSEQUENCE of being at
-- or over the line (RSVP refused, Go/No buttons replaced by a pay link,
-- the Game Center flag, the fines exemption) now needs a policy row with
-- blocks_eligibility on, and only the Men's section row has it.  A person
-- is blocked when they hold a current roster spot on a team of a section
-- whose policy in force blocks.  Everyone else over the line stays
-- eligible and sees a warning banner on #my (my_dues / warning) instead
-- of the red one.

ALTER TABLE dues_policies
  ADD COLUMN IF NOT EXISTS blocks_eligibility boolean NOT NULL DEFAULT false;
COMMENT ON COLUMN dues_policies.blocks_eligibility IS
  'mig 513: true = at or over the line (pause_after_months × rate) a member of this section is not eligible for games and practices (RSVP refused, Game Center flag). false = the line is only stated in notices and a warning on #my.';

-- The Men's section row: same rate, line and partial amounts as the
-- club-wide row in force, blocking on.
INSERT INTO dues_policies (club_id, club_section_id, monthly_dues_usd, pause_after_months,
                           effective_from, partial_amounts_usd, blocks_eligibility)
SELECT 134, cs.id, d.monthly_dues_usd, d.pause_after_months, DATE '2026-10-02', d.partial_amounts_usd, true
  FROM club_sections cs
  JOIN LATERAL (SELECT monthly_dues_usd, pause_after_months, partial_amounts_usd
                  FROM dues_policies
                 WHERE club_id = 134 AND club_section_id IS NULL AND effective_from <= CURRENT_DATE
                 ORDER BY effective_from DESC LIMIT 1) d ON true
 WHERE cs.code = 'M'
   AND NOT EXISTS (SELECT 1 FROM dues_policies p WHERE p.club_id = 134 AND p.club_section_id = cs.id);

-- Does the policy in force for this section block?  Section row first,
-- then the club-wide one; no row = no block.
CREATE OR REPLACE FUNCTION fh_dues_policy_blocks(p_club_id int, p_club_section_id int)
RETURNS boolean LANGUAGE sql STABLE AS $$
  SELECT COALESCE((
    SELECT blocks_eligibility
      FROM dues_policies
     WHERE club_id = p_club_id
       AND (club_section_id IS NULL OR club_section_id = p_club_section_id)
       AND effective_from <= CURRENT_DATE
     ORDER BY (club_section_id IS NOT NULL) DESC, effective_from DESC
     LIMIT 1), false)
$$;
COMMENT ON FUNCTION fh_dues_policy_blocks(int, int) IS
  'mig 513: whether the dues policy in force for a section makes the dues line a block on games and practices.';

-- Is this person subject to the block: a current roster spot (team_persons
-- not removed) on a team of this club in a section whose policy blocks.
CREATE OR REPLACE FUNCTION fh_dues_blocks_eligibility(p_person_id int, p_club_id int DEFAULT 134)
RETURNS boolean LANGUAGE sql STABLE AS $$
  SELECT EXISTS (
    SELECT 1
      FROM team_persons tp
      JOIN teams t ON t.id = tp.team_id
     WHERE tp.person_id = p_person_id
       AND tp.removed_at IS NULL
       AND t.club_id = p_club_id
       AND t.club_section_id IS NOT NULL
       AND fh_dues_policy_blocks(p_club_id, t.club_section_id))
$$;
COMMENT ON FUNCTION fh_dues_blocks_eligibility(int, int) IS
  'mig 513: true when the person is on a current roster of a section whose dues policy blocks games and practices at the line (Men only since 2026-10-02).';

-- At or over the line: balance ≥ the line (the club-wide line; the Men's
-- row mirrors it).  Stated on #my for everyone, a block only where the
-- section's policy says so.
CREATE OR REPLACE FUNCTION fh_dues_over_line(p_person_id int, p_club_id int DEFAULT 134)
RETURNS boolean LANGUAGE sql STABLE AS $$
  SELECT COALESCE(fh_dues_balance_usd(p_person_id) >= fh_dues_line_usd(p_club_id), false)
$$;

-- Eligible for games and practices on dues: not subject to the block, or
-- under the line.  NULL policy → eligible.
CREATE OR REPLACE FUNCTION fh_dues_eligible(p_person_id int, p_club_id int DEFAULT 134)
RETURNS boolean LANGUAGE sql STABLE AS $$
  SELECT NOT fh_dues_blocks_eligibility(p_person_id, p_club_id)
      OR COALESCE(fh_dues_balance_usd(p_person_id) < fh_dues_line_usd(p_club_id), true)
$$;

CREATE OR REPLACE FUNCTION fh_dues_eligible_at(p_person_id int, p_club_id int, p_at timestamptz)
RETURNS boolean LANGUAGE sql STABLE AS $$
  SELECT NOT fh_dues_blocks_eligibility(p_person_id, p_club_id)
      OR COALESCE(fh_dues_balance_at(p_person_id, p_at) < fh_dues_line_usd(p_club_id), true)
$$;

-- The warning on #my for someone over the line who is not blocked.
-- Tokens: {amount} balance, {min_payment} least to get under, {pause_amount} the line.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, client_side)
SELECT 'System', 'My — dues warning (over the line, not blocked)', 'my_dues', 'warning', NULL,
       'Dues {amount} owed — please bring it under {pause_amount} (at least {min_payment}) or you may lose eligibility for games and practices.', 6, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'my_dues' AND tier = 'warning');
