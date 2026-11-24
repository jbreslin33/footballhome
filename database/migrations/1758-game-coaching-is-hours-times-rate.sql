-- 1758 (2026-11-23): game coaching per game = hours per game × the hourly rate, one fact.
--
-- Owner 2026-11-23, looking at APSL on #competitions: "game coaching is 22
-- games x 3.5 hours X $20 hour right?"  Yes — but the page said $60 a game.
-- ref_fee_policies held the same fact twice: per_game_usd (what every report
-- multiplies) and hours_per_game × rate_per_hour.  Mig 1484 / 1487 changed
-- the hours (APSL 3.5, Liga 1 / Cups / U23 2.75) and left per_game_usd at the
-- old $60 / $49, so the budget was short on APSL, Liga 1 and U23 and over on
-- the cups.
--
-- * per_game_usd of a coaching policy is now always hours × rate (trigger).
-- * 2027/28 game_coaching prices (copied from per_game_usd by migs 1334/1342)
--   follow their team's policy; Liga 2 has no policy and follows Liga 1.
-- 2026-27: APSL 22 × $70 = $1,540 (was $1,320), Liga 1 22 × $55 = $1,210
-- (was $1,078), U23 6 × $55 = $330 (was $294), cups 5 × $55 = $275 (was $300).

BEGIN;

CREATE OR REPLACE FUNCTION fh_coaching_per_game() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.kind = 'coaching' AND NEW.hours_per_game IS NOT NULL AND NEW.rate_per_hour IS NOT NULL THEN
    NEW.per_game_usd := round(NEW.hours_per_game * NEW.rate_per_hour, 2);
  END IF;
  RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS ref_fee_policies_coaching_per_game ON ref_fee_policies;
CREATE TRIGGER ref_fee_policies_coaching_per_game BEFORE INSERT OR UPDATE ON ref_fee_policies
  FOR EACH ROW EXECUTE FUNCTION fh_coaching_per_game();

-- fire it on the rows that are out of step
UPDATE ref_fee_policies SET per_game_usd = per_game_usd
 WHERE kind = 'coaching' AND hours_per_game IS NOT NULL AND rate_per_hour IS NOT NULL
   AND per_game_usd IS DISTINCT FROM round(hours_per_game * rate_per_hour, 2);

-- next year's plans: the team's own policy
UPDATE league_fees lf SET amount_usd = p.per_game_usd, checked_on = '2026-11-23'
  FROM team_fee_plans tp
  JOIN team_season_entries e ON e.id = tp.entry_id
  JOIN ref_fee_policies p ON p.team_id = e.team_id AND p.kind = 'coaching' AND p.is_active
 WHERE tp.league_fee_id = lf.id AND lf.fee_kind = 'game_coaching' AND lf.amount_usd IS DISTINCT FROM p.per_game_usd;

-- Liga 2 (an option, no policy of its own): as Liga 1
UPDATE league_fees lf SET amount_usd = (SELECT per_game_usd FROM ref_fee_policies WHERE id = 8), checked_on = '2026-11-23'
  FROM team_fee_plans tp JOIN team_season_entries e ON e.id = tp.entry_id
 WHERE tp.league_fee_id = lf.id AND lf.fee_kind = 'game_coaching' AND e.team_id = 958;

INSERT INTO schema_migrations (filename) VALUES ('1758-game-coaching-is-hours-times-rate.sql') ON CONFLICT DO NOTHING;
COMMIT;
