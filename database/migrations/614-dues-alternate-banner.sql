-- 614 (2026-10-20) — The dues-alternate rule (mig 613) gets its #my banner.
--
-- Owner: "players who are delinquent will have banner?"  A Men's player
-- $35 behind had no banner — over_line (mig 513) only fires at the $70
-- line, so the only warning was buried on the game's eligibility card.
-- Now ANY balance where the alternate policy is in force puts an amber
-- banner on the player's own #my: you're an alternate for men's games
-- until it's paid.  Still private (a banner on their own page), still
-- not a ban.

-- Is this person an alternate on dues: any balance AND a current roster
-- spot on a section whose policy alternates (Men since mig 613).  Same
-- shape as fh_dues_blocks_eligibility (mig 513).
CREATE OR REPLACE FUNCTION fh_dues_alternate(p_person_id int, p_club_id int DEFAULT 134)
RETURNS boolean LANGUAGE sql STABLE AS $$
  SELECT COALESCE(fh_dues_balance_usd(p_person_id), 0) > 0
     AND EXISTS (
    SELECT 1
      FROM team_persons tp
      JOIN teams t ON t.id = tp.team_id
     WHERE tp.person_id = p_person_id
       AND tp.removed_at IS NULL
       AND t.club_id = p_club_id
       AND t.club_section_id IS NOT NULL
       AND fh_dues_policy_alternates(p_club_id, t.club_section_id))
$$;
COMMENT ON FUNCTION fh_dues_alternate(int, int) IS
  'mig 614: true when the person carries any dues balance and holds a current roster spot on a section whose policy marks balance-holders as alternates (Men, mig 613).';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, client_side)
SELECT 'System', 'My — dues alternate banner (any balance, Men)', 'my_dues', 'alternate_banner', NULL,
       'Dues {amount} owed — you''re an alternate for men''s games (bottom of the starter and bench pool) until it''s paid. Any payment moves you back up.', 10, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'my_dues' AND tier = 'alternate_banner');
