-- 1582 (2026-11-19) — 📉 #apsl Forecast: the owner confirms the guesses.
-- Owner 2026-11-19: "1 do random draw for now. 2. yes. 3. no relegation
-- unless drc 11 in normal year. 4. 7 plays 7 and loser goes down and winner
-- plays feeder winner of promotion playoff not the auto promotion winner
-- they go up and the losers of auto go into the promotion playoffs".
-- Notes only — the simulation already plays it this way (migs 1573–1575).
BEGIN;
UPDATE pyramid_relegation_size_rules SET note = 'Owner 11/19 (confirmed): 11 teams → no relegation, 1 up (back to 12). Delaware River has its own seasons (pyramid_relegation_outlook), so this never applies to it'
 WHERE teams = 11;
UPDATE pyramid_promotion_rules r SET note = 'Owner 11/19 (confirmed): feeder champions meet in a knockout, random draw for now (bye when odd), the winner goes up; the champions who lose drop into the promotion playoff with each feeder''s 2nd–5th winner; its winner plays the 7th-v-7th winner (the loser of 7th v 7th goes down). Reserves and Metro-side sides skipped'
  FROM pyramid_competitions c
 WHERE r.competition_id = c.id AND c.name = 'Delaware River Conference';
UPDATE pyramid_forecast_policies p SET feeder_label = 'the promotion-playoff winner',
       note = 'Owner 11/19: 7th A v 7th B, loser relegated; winner plays the feeders'' promotion-playoff winner to stay up (50/50 until the sides can be compared)'
  FROM pyramid_competitions c
 WHERE p.competition_id = c.id AND c.name = 'Delaware River Conference';
COMMIT;
