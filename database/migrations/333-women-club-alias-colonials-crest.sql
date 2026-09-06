-- "Club: Women" spelling + Colonials crest (owner 2026-09-05).
--
-- The 9/13 Tri County game was tagged `Club: Women | Team: Tri County`;
-- the alias table only knew club_alias='womens' so it did not classify.
-- Same fix as migration 331 did for "Men": accept both spellings.
INSERT INTO gcal_team_aliases (club_alias, team_alias, team_id, notes)
SELECT 'women', a.team_alias, a.team_id, 'Spelling variant of club_alias=womens (migration 333)'
  FROM gcal_team_aliases a
 WHERE a.club_alias = 'womens'
   AND NOT EXISTS (SELECT 1 FROM gcal_team_aliases b
                    WHERE b.club_alias = 'women' AND b.team_alias = a.team_alias);

-- Colonial Soccer Club (Tri County opponent), owner-supplied image.
INSERT INTO opponent_logo_cache (opponent_text, logo_url, source, fetched_at) VALUES
  ('Colonials',            '/images/teams/logos/colonials.png', 'manual', now()),
  ('Colonial',             '/images/teams/logos/colonials.png', 'manual', now()),
  ('Colonial SC',          '/images/teams/logos/colonials.png', 'manual', now()),
  ('Colonial Soccer Club', '/images/teams/logos/colonials.png', 'manual', now())
ON CONFLICT (lower(btrim(opponent_text))) DO UPDATE
   SET logo_url = EXCLUDED.logo_url, source = 'manual', fetched_at = now();
