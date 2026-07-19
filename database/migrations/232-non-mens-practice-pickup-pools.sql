-- ─────────────────────────────────────────────────────────────────────
-- 232-non-mens-practice-pickup-pools.sql (2026-07-19)
--
-- W3 follow-up from docs/calendar-design.md §0.3 (option C):
-- Create virtual Practice + Pickup pool teams for Women / Boys / Girls
-- (mirror Mens teams 908/909), wire membership requirements + gcal
-- aliases, and seed default player_rsvp_eligibility from open LA
-- memberships in each category.
--
-- Team ids (contiguous after Youth League 916/917):
--   918 Women Practice    919 Women Pickup
--   920 Boys Practice     921 Boys Pickup
--   922 Girls Practice    923 Girls Pickup
--
-- Girls finally get gender_category='girls' teams so Club Admin RSVP
-- chips and gcal `Club: Girls / Team: Practice|Pickup` can resolve.
-- ─────────────────────────────────────────────────────────────────────

BEGIN;

-- ═══ 1. Pool teams ═══════════════════════════════════════════════════
INSERT INTO teams (id, division_id, club_id, name, gender_category, is_pool, slug)
VALUES
    (918, 73, 134, 'Women Practice',  'womens', true, 'women-practice'),
    (919, 73, 134, 'Women Pickup',    'womens', true, 'women-pickup'),
    (920, 73, 134, 'Boys Practice',   'boys',   true, 'boys-practice'),
    (921, 73, 134, 'Boys Pickup',     'boys',   true, 'boys-pickup'),
    (922, 73, 134, 'Girls Practice',  'girls',  true, 'girls-practice'),
    (923, 73, 134, 'Girls Pickup',    'girls',  true, 'girls-pickup')
ON CONFLICT (id) DO NOTHING;

SELECT setval('teams_id_seq', GREATEST((SELECT MAX(id) FROM teams), 923));

-- roster_source: women/boys pools UNION from real home teams (same
-- pattern as mens 908/909). Girls have no dedicated home teams yet
-- (girls play on boys youth boards), so girls pools stay 'direct' —
-- membership is enforced via team_membership_requirements + eligibility
-- backfill from LA programs, not union composition.
UPDATE teams SET roster_source = 'union' WHERE id IN (918, 919, 920, 921);

INSERT INTO team_roster_sources (team_id, source_team_id)
SELECT pool.team_id, src.source_team_id
  FROM (VALUES
          (918, 901), (919, 901),
          (918, 583), (919, 583),
          (918, 902), (919, 902),
          (920, 911), (920, 916), (920, 917),
          (921, 911), (921, 916), (921, 917)
       ) AS pool(team_id, source_team_id)
  JOIN teams src ON src.id = pool.source_team_id
  JOIN teams dst ON dst.id = pool.team_id
ON CONFLICT DO NOTHING;

INSERT INTO team_eligible_genders (team_id, gender) VALUES
  (918, 'womens'), (919, 'womens'),
  (920, 'boys'),   (920, 'girls'),
  (921, 'boys'),   (921, 'girls'),
  (922, 'girls'),  (923, 'girls')
ON CONFLICT DO NOTHING;

-- ═══ 2. Membership requirements (LA program gate) ════════════════════
-- Program IDs (leagueapps_programs):
--   5039340 / 5064686  Women active / pickup
--   5039252 / 5064618  Boys active / pickup
--   5039357 / 5064662  Girls active / pickup
INSERT INTO team_membership_requirements (team_id, la_program_id)
SELECT t.id, p.program_id
  FROM teams t
  CROSS JOIN (VALUES (5039340::bigint), (5064686::bigint)) AS p(program_id)
 WHERE t.id IN (918, 919)
ON CONFLICT DO NOTHING;

INSERT INTO team_membership_requirements (team_id, la_program_id)
SELECT t.id, p.program_id
  FROM teams t
  CROSS JOIN (VALUES (5039252::bigint), (5064618::bigint)) AS p(program_id)
 WHERE t.id IN (920, 921)
ON CONFLICT DO NOTHING;

INSERT INTO team_membership_requirements (team_id, la_program_id)
SELECT t.id, p.program_id
  FROM teams t
  CROSS JOIN (VALUES (5039357::bigint), (5064662::bigint)) AS p(program_id)
 WHERE t.id IN (922, 923)
ON CONFLICT DO NOTHING;

-- ═══ 3. gcal aliases (append-only) ════════════════════════════════════
INSERT INTO gcal_team_aliases (club_alias, team_alias, team_id, notes) VALUES
    ('womens', 'practice', 918, 'Pool: women practice'),
    ('womens', 'pickup',   919, 'Pool: women pickup'),
    ('women',  'practice', 918, 'Alt club spelling'),
    ('women',  'pickup',   919, 'Alt club spelling'),
    ('boys',   'practice', 920, 'Pool: boys practice'),
    ('boys',   'pickup',   921, 'Pool: boys pickup'),
    ('girls',  'practice', 922, 'Pool: girls practice'),
    ('girls',  'pickup',   923, 'Pool: girls pickup')
ON CONFLICT (club_alias, team_alias) DO NOTHING;

-- ═══ 4. Default RSVP grants from open LA memberships ═════════════════
-- Every current member in the category gets Practice + Pickup eligibility.
-- leagueapps_user_id must be numeric text (LA ids).
INSERT INTO player_rsvp_eligibility (leagueapps_user_id, team_id)
SELECT DISTINCT epa.external_user_id::bigint, pool.team_id
  FROM person_la_memberships plm
  JOIN leagueapps_programs lp
    ON lp.program_id = plm.la_program_id
  JOIN external_person_aliases epa
    ON epa.person_id = plm.person_id
   AND epa.provider = 'leagueapps'
   AND epa.external_user_id ~ '^[0-9]+$'
  JOIN (VALUES
          ('women'::text, 918), ('women', 919),
          ('boys',  920), ('boys',  921),
          ('girls', 922), ('girls', 923)
       ) AS pool(category, team_id)
    ON pool.category = lp.category
 WHERE plm.ended_at IS NULL
ON CONFLICT DO NOTHING;

-- ═══ 5. Extend default-grant trigger for boys home assignments ═══════
-- When a boy is assigned to a Youth League home team, also grant
-- Practice (920) + Pickup (921). Women/girls lack a roster domain
-- today — their pool grants come from the membership backfill above
-- and stay admin-toggleable on the RSVP board.
CREATE OR REPLACE FUNCTION fn_grant_default_rsvp_eligibility()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.removed_at IS NOT NULL THEN
    RETURN NEW;
  END IF;

  IF NEW.domain = 'mens' AND NEW.team_id IN (35, 120, 121, 122) THEN
    INSERT INTO player_rsvp_eligibility (leagueapps_user_id, team_id) VALUES
      (NEW.leagueapps_user_id, NEW.team_id),
      (NEW.leagueapps_user_id, 908),
      (NEW.leagueapps_user_id, 909)
    ON CONFLICT DO NOTHING;
  ELSIF NEW.domain = 'boys' AND NEW.team_id IN (911, 916, 917) THEN
    INSERT INTO player_rsvp_eligibility (leagueapps_user_id, team_id) VALUES
      (NEW.leagueapps_user_id, NEW.team_id),
      (NEW.leagueapps_user_id, 920),
      (NEW.leagueapps_user_id, 921)
    ON CONFLICT DO NOTHING;
  END IF;

  RETURN NEW;
END $$;

COMMIT;
