-- 826 (2026-10-29) — game: the assistant aims LEVEL with the line (G4.90,
-- game/DESIGN.md §8.88).
--
-- James 10/29: "continue" (the assistant, after G4.89). 75% of the offside
-- whistles left were for ONSIDE men; the G4.88 assistant aimed a positioning
-- "slack" BEYOND the second-last defender (mig 822, from Oudejans 2000's
-- "ARs mostly stand beyond" — a share, not a distance): mean +2 m, a third of
-- kicks 3 m+. Measured, assistants sit about 1 m off the second-last defender
-- [Gonçalves et al. 2021], aligned (< 0.2 m) 14% of the time, trailing ~53%
-- and leading ~33% [Mallo et al. 2012, as cited there]. Now he aims level
-- (IFAB) at the line as he read it his lag ago — positioning sets the lag.

BEGIN;

INSERT INTO game_sources (code, kind, title, url, verified) VALUES
  ('goncalves-2021', 'analysis',
   'Gonçalves, Coutinho, Travassos, Brito & Figueiredo (2021), Match analysis of soccer refereeing using spatiotemporal data: a case study, Sensors 21(7):2541',
   'https://pmc.ncbi.nlm.nih.gov/articles/PMC8038568', true),
  ('mallo-2012', 'analysis',
   'Mallo et al. (2012), assistant referees'' positioning and offside decisions, J Sports Sci (read through Gonçalves et al. 2021)',
   NULL, false)
ON CONFLICT (code) DO NOTHING;

DELETE FROM game_model_params WHERE owner = 'official' AND code = 'assistant' AND param LIKE 'slack_m_at%';

INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
  ('official', 'assistant', 'lag_s_at0', 0.6, 's',
   'He aims level with the second-last defender as he read it this long ago, at positioning 0 — so he trails a moving line. [FH] estimate; measured result to match: ~1 m off the line (Gonçalves et al. 2021), aligned < 0.2 m 14%, trail ~53% / lead ~33% (Mallo et al. 2012).'),
  ('official', 'assistant', 'lag_s_at50', 0.3, 's', 'At 50.'),
  ('official', 'assistant', 'lag_s_at100', 0.1, 's', 'At 100.'),
  ('official', 'assistant', 'track_s', 0.5, 's',
   'He SHADOWS the line: moves at its speed and closes his gap over this long (ar-side-steps). Walking to the spot with an ease-in he was always arriving. [FH] estimate.')
ON CONFLICT DO NOTHING;

UPDATE game_ref_attributes
   SET description = 'How close to level with the line he holds (an assistant), how well he holds the diagonal.',
       scales = 'assistant: the age of his read of the line he shadows — 0.6 s at 0 … 0.3 at 50 … 0.1 at 100 [FH]'
 WHERE code = 'positioning';

UPDATE game_ref_positionings SET status = 'wired' WHERE code = 'ar-side-steps';

UPDATE game_ref_positionings
   SET how = 'On his touchline, facing the field, LEVEL with the second-last defender of the team defending his half — or with the ball if it is nearer the goal line; at halfway when the line is in the other half. He reads the line his positioning lag ago, so he trails a moving line.'
 WHERE code = 'ar-second-last-defender';

INSERT INTO game_ref_positioning_sources (positioning_id, source_id, citation, verified)
SELECT p.id, s.id, x.citation, x.verified
  FROM (VALUES
    ('goncalves-2021', 'Elite assistants about 1 m from the second-last defender', true),
    ('mallo-2012', 'Aligned (< 0.2 m) 14% of the time; trail ~53%, lead ~33%; fewer errors at a 46-60° visual angle', false)
  ) AS x(source, citation, verified)
  JOIN game_sources s ON s.code = x.source
  JOIN game_ref_positionings p ON p.code = 'ar-second-last-defender'
ON CONFLICT DO NOTHING;

COMMIT;
