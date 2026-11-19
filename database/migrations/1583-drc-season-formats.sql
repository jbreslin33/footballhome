-- 1583 (2026-11-19) — ⬇⬆ #apsl Forecast: how each Delaware River season's
-- relegations happen.
-- Owner 2026-11-19 (2027-28, two groups of 7): "then it goes 6 for what 7
-- was and 7 for what 8 was".
--   auto_down       places from the bottom of each group relegated outright
--   playoff_place   the place (counted from the top) that plays for the half
--                   spot; two groups → A v B, loser down, winner v the
--                   feeders' promotion-playoff winner; one table → straight
--                   v the promotion-playoff winner
-- 2026-27: 8th A + 8th B down, 7th v 7th.  2027-28: 7th + 7th down, 6th v
-- 6th.  2028-29 (one table of 12, 1.5): 12th down, 11th v the promotion-
-- playoff winner (normal APSL rules — owner to confirm).
BEGIN;
ALTER TABLE pyramid_relegation_outlook ADD COLUMN IF NOT EXISTS auto_down integer CHECK (auto_down >= 0);
ALTER TABLE pyramid_relegation_outlook ADD COLUMN IF NOT EXISTS playoff_place integer CHECK (playoff_place >= 1);
UPDATE pyramid_relegation_outlook o SET auto_down = v.a, playoff_place = v.p
  FROM pyramid_competitions c, (VALUES ('2026-27', 1, 7), ('2027-28', 1, 6), ('2028-29', 1, 11)) AS v(season, a, p)
 WHERE o.competition_id = c.id AND c.name = 'Delaware River Conference' AND o.season = v.season;
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'APSL pyramid', l, 'apsl_pyramid', t, NULL, b, o, true, true, true
  FROM (VALUES
    ('fc_ol_how',        'Forecast — outlook column: how',                                   'How', 490),
    ('fc_ol_how_paired', 'Forecast — how, two groups ({auto} {rp})',                         '{auto} down · {rp} A v {rp} B: loser down, winner plays the promotion-playoff winner', 491),
    ('fc_ol_how_single', 'Forecast — how, one table ({auto} {rp})',                          '{auto} down · {rp} plays the promotion-playoff winner', 492)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = v.t);
COMMIT;
