-- 1574 (2026-11-19) — ⬆ #apsl Forecast: each feeder settles its own
-- promotion playoff first.
--
-- Owner 2026-11-19: "it would be winner of 2 through 5 in each conf vs each
-- other. so settle conf first then playoff. if 3 teams someone gets bye".
--
-- pyramid_promotion_rules.feeder_playoff_first: places playoff_from..to of
-- each feeder's eligible sides play a seeded knockout inside that feeder
-- (best v worst — 2v5, 3v4 — the better seed at home, top seeds get the
-- byes when short); each feeder's winner goes on to the promotion playoff,
-- with the champions who lost the champions' knockout
-- (champion_losers_to_playoff, kept from the owner's first word "loser of
-- those would go into promotion playoffs"); that stage is a knockout with
-- a random draw, a bye when odd.
BEGIN;

ALTER TABLE pyramid_promotion_rules ADD COLUMN IF NOT EXISTS feeder_playoff_first boolean NOT NULL DEFAULT false;

UPDATE pyramid_promotion_rules r SET feeder_playoff_first = true,
       note = 'Owner 11/19: feeder champions play off for the auto spot; 2nd–5th of each feeder settle their own playoff first (seeded, 2v5 / 3v4), then the feeder winners + the losing champions meet (bye when odd); reserves and Metro-side teams skipped, the next team moves up'
  FROM pyramid_competitions c
 WHERE r.competition_id = c.id AND c.name = 'Delaware River Conference';

UPDATE message_templates
   SET body = 'How they come up: each feeder''s {champ} (reserves and sides nearer another conference skipped — the next team moves up) meet in a knockout (bye when odd); the winner goes up. {stage}{meet}',
       label = 'Forecast — promotion rules ({champ} {stage} {meet})'
 WHERE kind = 'apsl_pyramid' AND tier = 'fc_ol_rules_text';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'APSL pyramid', l, 'apsl_pyramid', t, NULL, b, o, true, true, true
  FROM (VALUES
    ('fc_ol_stage_feeder', 'Forecast — promotion rules: feeder playoffs first ({from} {to} {losers})', 'Inside each feeder, {from}–{to} play off first (seeded: best v worst, the better seed at home). The feeder winners{losers} then meet in the promotion playoff (bye when odd).', 416),
    ('fc_ol_stage_pooled', 'Forecast — promotion rules: one pooled playoff ({from} {to} {losers})',  '{from}–{to} of each feeder{losers} go into one promotion playoff (knockout, random draw).', 417),
    ('fc_ol_stage_losers', 'Forecast — promotion rules: … and the champions who lost',                ' and the champions who lost', 418),
    ('fc_ol_col_fwin',     'Forecast — feeder column: wins its feeder''s playoff %',                  '🥇 Feeder PO', 419)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = v.t);

COMMIT;
