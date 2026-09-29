-- 500 (2026-09-29) — Luke and Anthony's usual weeks and their game hours.
-- Owner: "they will both do u8. which is 4pm to 530pm 2 days a week.
-- monday and wednesday all year. then they luke will do u10 and anthony
-- u12 3 days a week 530 to 7. then give anthony u8 games and luke u10 and
-- u12 games. each age group will have 22 games at same time frame as
-- women. u8 and u10 will be 1.5 hours per game and u12 2 hours per game"
--
-- Usual 2 weeks (day_index 0 = first Friday, mig 477): Mon + Wed 4:00–5:30
-- U8 for both; Mon, Wed, Fri 5:30–7:00 U10 (Luke) / U12 (Anthony) — the
-- third day is assumed to be their existing Friday.
DELETE FROM invoice_default_shifts WHERE issuer_id IN (SELECT id FROM invoice_issuers WHERE person_id IN (3463, 22397));
INSERT INTO invoice_default_shifts (issuer_id, day_index, start_at, end_at, note)
SELECT i.id, d.day_index, d.start_at, d.end_at, CASE WHEN d.start_at = TIME '16:00' THEN 'U8' WHEN i.person_id = 3463 THEN 'U10' ELSE 'U12' END
  FROM invoice_issuers i
  CROSS JOIN (VALUES
    (3,  TIME '16:00', TIME '17:30'), (5,  TIME '16:00', TIME '17:30'),
    (10, TIME '16:00', TIME '17:30'), (12, TIME '16:00', TIME '17:30'),
    (3,  TIME '17:30', TIME '19:00'), (5,  TIME '17:30', TIME '19:00'), (0, TIME '17:30', TIME '19:00'),
    (10, TIME '17:30', TIME '19:00'), (12, TIME '17:30', TIME '19:00'), (7, TIME '17:30', TIME '19:00')) AS d(day_index, start_at, end_at)
 WHERE i.person_id IN (3463, 22397);

-- Which coach a coaching policy's game hours pay.
ALTER TABLE ref_fee_policies ADD COLUMN IF NOT EXISTS coach_issuer_id INT REFERENCES invoice_issuers(id) ON DELETE SET NULL;
COMMENT ON COLUMN ref_fee_policies.coach_issuer_id IS 'kind coaching: the issuer paid these game hours (mig 500).';
UPDATE ref_fee_policies p SET coach_issuer_id = i.id FROM invoice_issuers i WHERE p.club_id = 134 AND p.kind = 'coaching' AND p.label = 'Tri County'       AND i.person_id = 22193;
UPDATE ref_fee_policies p SET coach_issuer_id = i.id FROM invoice_issuers i WHERE p.club_id = 134 AND p.kind = 'coaching' AND p.label = 'Parks & Rec U8'   AND i.person_id = 22397;
UPDATE ref_fee_policies p SET coach_issuer_id = i.id FROM invoice_issuers i WHERE p.club_id = 134 AND p.kind = 'coaching' AND p.label IN ('Parks & Rec U10', 'Parks & Rec U12') AND i.person_id = 3463;

-- Youth game hours: 22 games a year each, the women's windows (11 Sep–Nov,
-- 11 Mar–Jun); no indoor season.  U8/U10 1.5 h, U12 2 h (unchanged).
DELETE FROM ref_fee_seasons s USING ref_fee_policies p WHERE p.id = s.policy_id AND p.club_id = 134 AND p.kind = 'coaching' AND p.label LIKE 'Parks & Rec U%' AND s.label = 'Indoor 2026/27';
UPDATE ref_fee_seasons s SET starts_on = DATE '2026-09-01', ends_on = DATE '2026-11-30', home_games_expected = 11 FROM ref_fee_policies p WHERE p.id = s.policy_id AND p.club_id = 134 AND p.kind = 'coaching' AND p.label LIKE 'Parks & Rec U%' AND s.label = 'Fall 2026';
UPDATE ref_fee_seasons s SET starts_on = DATE '2027-03-01', ends_on = DATE '2027-06-30', home_games_expected = 11 FROM ref_fee_policies p WHERE p.id = s.policy_id AND p.club_id = 134 AND p.kind = 'coaching' AND p.label LIKE 'Parks & Rec U%' AND s.label = 'Spring 2027';
UPDATE ref_fee_policies SET hours_per_game = 1.50, per_game_usd = ROUND(1.50 * rate_per_hour, 2), note = 'Owner 2026-09-29: 1.5 h per game at the $15 coaching rate, home and away; 22 games a year (11 Sep–Nov + 11 Mar–Jun)' WHERE club_id = 134 AND kind = 'coaching' AND label IN ('Parks & Rec U8', 'Parks & Rec U10');
UPDATE ref_fee_policies SET hours_per_game = 2.00, per_game_usd = ROUND(2.00 * rate_per_hour, 2), note = 'Owner 2026-09-29: 2 h per game at the $15 coaching rate, home and away; 22 games a year (11 Sep–Nov + 11 Mar–Jun)' WHERE club_id = 134 AND kind = 'coaching' AND label = 'Parks & Rec U12';
