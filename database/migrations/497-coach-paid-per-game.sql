-- 497 (2026-09-29) — A coach paid per game, not per usual week.
-- Owner: "for coaches jamie hours are just games. so 22 games a year
-- 2 hours each".
--
-- Jamie Arevalo's usual week (2 h every Sunday, mig 475) is the game
-- itself, so #finances was counting it twice: once as Usual hours and
-- once as Game hours — Tri County.  pay_basis says which basis an issuer's
-- labor projects on: 'weekly' = the default week × rate (James, Luke,
-- Anthony); 'games' = only the coaching game-hours policy for their
-- section (Jamie).  The default week stays for invoice prefill.
ALTER TABLE invoice_issuers ADD COLUMN IF NOT EXISTS pay_basis TEXT NOT NULL DEFAULT 'weekly' CHECK (pay_basis IN ('weekly', 'games'));
COMMENT ON COLUMN invoice_issuers.pay_basis IS 'weekly = usual week × rate projects on #finances; games = only the coaching game-hours policy does (mig 497).';
UPDATE invoice_issuers SET pay_basis = 'games', updated_at = now() WHERE person_id = 22193;

-- Tri County (women, 2 h per game): 22 games a year, split across the two
-- seasons the league plays.  Both still assumed until the schedules post.
UPDATE ref_fee_seasons s SET home_games_expected = 11
  FROM ref_fee_policies p
 WHERE p.id = s.policy_id AND p.club_id = 134 AND p.kind = 'coaching' AND p.label = 'Tri County' AND s.label IN ('Fall 2026', 'Spring 2027');
UPDATE ref_fee_policies SET note = 'Owner 2026-09-29: coach paid 2 h per game at the $15 coaching rate, home and away; 22 games a year (11 fall + 11 spring)'
 WHERE club_id = 134 AND kind = 'coaching' AND label = 'Tri County';

-- The Coaching row for a per-game coach: only what they have invoiced.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Finances', 'Finances — per-game coach item', 'finances', 'games_invoiced', NULL, 'Games invoiced — {name}', 24, true, true
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'finances' AND tier = 'games_invoiced');
