-- 977 (2026-11-03) — #finances "Money in & out": every dollar on a team.
--
-- Owner 2026-11-03: "we have traditionally used pills right? so apsl pill
-- clicked and expenses pill clicked would be just apsl expenses. but if i
-- click 'all' instead of income or expenses and just 'apsl' then it gives me
-- all coming in from apsl and going out … players on apsl tuition and all
-- apsl expenses right?" / "and then same for all other items and teams and
-- leagues right?" / "not both" (one page: #cash-flow folds into #finances).
--
--   cash_flow_scopes.team_id   a scope can be one of our teams (APSL, Liga 1,
--                              Cups, the women's team, U8, U10, U12, U19)
--   ref_fee_policies.team_id   whose referee fees / game coaching these are
--   cash_flow_dues_scope()     dues: the team fh_dues_team() names (mig 973/975),
--                              else the section
--   cash_flow_event_scope()    calendar work: the event's highest-ranked team
--                              (fh_event_teams), else league / category as before
--   cash_flow_policy_scope()   referee ticks: the policy's team
BEGIN;

ALTER TABLE cash_flow_scopes ADD COLUMN IF NOT EXISTS team_id INTEGER REFERENCES teams(id);
UPDATE cash_flow_scopes SET team_id = 35  WHERE code = 'apsl';
UPDATE cash_flow_scopes SET team_id = 120 WHERE code = 'liga1';
UPDATE cash_flow_scopes SET team_id = 901, label = 'Women''s team' WHERE code = 'tri_county';
UPDATE cash_flow_scopes SET label = 'Youth, all ages' WHERE code = 'ppr';
INSERT INTO cash_flow_scopes (code, label, parent, category, leagues, section_code, sort_order, team_id) VALUES
    ('cups', 'Cups', 'mens', NULL, '{"USASA Cup"}', NULL, 13, 939),
    ('u8',   'U8',   'boys', NULL, '{}', NULL, 32, 912),
    ('u10',  'U10',  'boys', NULL, '{}', NULL, 33, 913),
    ('u12',  'U12',  'boys', NULL, '{}', NULL, 34, 914),
    ('u19',  'U19',  'boys', NULL, '{}', NULL, 35, 932)
ON CONFLICT (code) DO NOTHING;
UPDATE cash_flow_scopes SET sort_order = 39 WHERE code = 'ppr';

ALTER TABLE ref_fee_policies ADD COLUMN IF NOT EXISTS team_id INTEGER REFERENCES teams(id);
UPDATE ref_fee_policies SET team_id = CASE
    WHEN label LIKE 'APSL%'   THEN 35
    WHEN label LIKE 'Liga 1%' THEN 120
    WHEN label LIKE 'Tri County%' THEN 901
    WHEN age_band = 'U8'  THEN 912
    WHEN age_band = 'U10' THEN 913
    WHEN age_band = 'U12' THEN 914 END
 WHERE team_id IS NULL;

CREATE OR REPLACE FUNCTION cash_flow_team_scope(p_team int) RETURNS text LANGUAGE sql STABLE AS $$
  SELECT code FROM cash_flow_scopes WHERE team_id = p_team ORDER BY sort_order LIMIT 1 $$;

CREATE OR REPLACE FUNCTION cash_flow_section_scope(p_category text) RETURNS text LANGUAGE sql STABLE AS $$
  SELECT COALESCE((SELECT code FROM cash_flow_scopes
                    WHERE category = CASE p_category WHEN 'men' THEN 'mens' WHEN 'women' THEN 'womens' ELSE p_category END
                    ORDER BY sort_order LIMIT 1), 'club') $$;

CREATE OR REPLACE FUNCTION cash_flow_dues_scope(p_person int, p_category text, p_at timestamptz) RETURNS text LANGUAGE sql STABLE AS $$
  SELECT COALESCE(cash_flow_team_scope(fh_dues_team(p_person, p_category, p_at)), cash_flow_section_scope(p_category)) $$;

CREATE OR REPLACE FUNCTION cash_flow_event_scope(p_event bigint, p_category text, p_league text) RETURNS text LANGUAGE sql STABLE AS $$
  SELECT COALESCE(
    (SELECT s.code FROM fh_event_teams et JOIN teams t ON t.id = et.team_id JOIN cash_flow_scopes s ON s.team_id = t.id
      WHERE et.fh_event_id = p_event ORDER BY t.dues_rank DESC NULLS LAST, s.sort_order LIMIT 1),
    cash_flow_scope(p_category, p_league)) $$;

CREATE OR REPLACE FUNCTION cash_flow_policy_scope(p_policy int) RETURNS text LANGUAGE sql STABLE AS $$
  SELECT COALESCE(cash_flow_team_scope(p.team_id), cash_flow_scope(p.event_category, p.event_league_labels[1]))
    FROM ref_fee_policies p WHERE p.id = p_policy $$;

-- The payer behind a LeagueApps transaction: the registration's member, else
-- the account's person (mig 602 aliases first).
CREATE OR REPLACE FUNCTION fh_payment_person(p_registration bigint, p_la_user bigint) RETURNS int LANGUAGE sql STABLE AS $$
  SELECT COALESCE(
    (SELECT person_id FROM person_la_memberships WHERE la_registration_id = p_registration ORDER BY id LIMIT 1),
    (SELECT person_id FROM person_la_user_ids WHERE la_user_id = p_la_user::text),
    (SELECT id FROM persons WHERE la_user_id::text = p_la_user::text ORDER BY id LIMIT 1)) $$;

-- Wording.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Finances', v.l, v.k, v.t, NULL, v.b, v.o, true, true FROM (VALUES
    ('finances',  'pill_money',   'Finances — Money in & out pill',  'Money in & out', 5),
    ('cash_flow', 'dir_all',      'Money pill — both ways',          'All', 40),
    ('cash_flow', 'dir_in',       'Money pill — in only',            'In', 41),
    ('cash_flow', 'dir_out',      'Money pill — out only',           'Out', 42),
    ('cash_flow', 'line_rental',  'Line — a field rental',           '{name}', 43),
    ('cash_flow', 'year_note',    'Budget year note',                'Budget year {year}: {from} – {to}. Dues count once, for the highest team a member was on when they paid.', 44)
) AS v(k, t, l, b, o)
WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = v.k AND m.tier = v.t);
UPDATE message_templates SET body = '{league} — dues counted for this team, plus its own costs.' WHERE kind = 'cash_flow' AND tier = 'shared_in';
COMMIT;
