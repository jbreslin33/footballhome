-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Rosters - CSL
-- Player-team relationships from team roster pages
-- Total Records: 2660
-- 
-- Architecture: Players looked up by name (no hardcoded IDs)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Riverside Squires' AND t.source_system_id = 3
  AND per.first_name = 'Elom' AND per.last_name = 'Amematsro'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Riverside Squires' AND t.source_system_id = 3
  AND per.first_name = 'Paul' AND per.last_name = 'Anders'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Riverside Squires' AND t.source_system_id = 3
  AND per.first_name = 'Jack' AND per.last_name = 'Arnold'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Riverside Squires' AND t.source_system_id = 3
  AND per.first_name = 'Achraf' AND per.last_name = 'Bahamou'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Riverside Squires' AND t.source_system_id = 3
  AND per.first_name = 'Jasper' AND per.last_name = 'Baur'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Riverside Squires' AND t.source_system_id = 3
  AND per.first_name = 'Julien' AND per.last_name = 'Boussard'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Riverside Squires' AND t.source_system_id = 3
  AND per.first_name = 'Daniel' AND per.last_name = 'Choi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Riverside Squires' AND t.source_system_id = 3
  AND per.first_name = 'Moulay' AND per.last_name = 'Draidia'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Riverside Squires' AND t.source_system_id = 3
  AND per.first_name = 'William' AND per.last_name = 'Foster'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Riverside Squires' AND t.source_system_id = 3
  AND per.first_name = 'Yongjie' AND per.last_name = 'Fu'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Riverside Squires' AND t.source_system_id = 3
  AND per.first_name = 'Richard' AND per.last_name = 'Groenewald'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Riverside Squires' AND t.source_system_id = 3
  AND per.first_name = 'Peter' AND per.last_name = 'Heckendorn'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Riverside Squires' AND t.source_system_id = 3
  AND per.first_name = 'Zane' AND per.last_name = 'Kerr'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Riverside Squires' AND t.source_system_id = 3
  AND per.first_name = 'Heriberto' AND per.last_name = 'Mendoza'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Riverside Squires' AND t.source_system_id = 3
  AND per.first_name = 'Zakarya' AND per.last_name = 'Mitiche'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Riverside Squires' AND t.source_system_id = 3
  AND per.first_name = 'John' AND per.last_name = 'Mullan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Riverside Squires' AND t.source_system_id = 3
  AND per.first_name = 'Nikhil' AND per.last_name = 'Nanda'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Riverside Squires' AND t.source_system_id = 3
  AND per.first_name = 'Amin' AND per.last_name = 'Nejatbakhsh'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Riverside Squires' AND t.source_system_id = 3
  AND per.first_name = 'William' AND per.last_name = 'Nkemdirim'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Riverside Squires' AND t.source_system_id = 3
  AND per.first_name = 'Robert' AND per.last_name = 'Rust'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Riverside Squires' AND t.source_system_id = 3
  AND per.first_name = 'Hasan' AND per.last_name = 'Siddiqui'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Riverside Squires' AND t.source_system_id = 3
  AND per.first_name = 'William' AND per.last_name = 'Stinson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Riverside Squires' AND t.source_system_id = 3
  AND per.first_name = 'Dani' AND per.last_name = 'Tamkin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Riverside Squires' AND t.source_system_id = 3
  AND per.first_name = 'Marshall' AND per.last_name = 'Tekell'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Riverside Squires' AND t.source_system_id = 3
  AND per.first_name = 'Denis' AND per.last_name = 'Turcu'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Riverside Squires' AND t.source_system_id = 3
  AND per.first_name = 'Nathaniel' AND per.last_name = 'Wagner'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Riverside Squires' AND t.source_system_id = 3
  AND per.first_name = 'Sam' AND per.last_name = 'Wolfson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Riverside Squires' AND t.source_system_id = 3
  AND per.first_name = 'Damon' AND per.last_name = 'Xavier'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Riverside Squires' AND t.source_system_id = 3
  AND per.first_name = 'Ray' AND per.last_name = 'Zhang'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Astoria Knights II' AND t.source_system_id = 3
  AND per.first_name = 'Stephen' AND per.last_name = 'Alabi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Astoria Knights II' AND t.source_system_id = 3
  AND per.first_name = 'Bright' AND per.last_name = 'Owusu Anim'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Astoria Knights II' AND t.source_system_id = 3
  AND per.first_name = 'Boubacar' AND per.last_name = 'Bah'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Astoria Knights II' AND t.source_system_id = 3
  AND per.first_name = 'Yannick' AND per.last_name = 'Siaka Diaby'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Astoria Knights II' AND t.source_system_id = 3
  AND per.first_name = 'Mohamed' AND per.last_name = 'Kasse Diaw'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Astoria Knights II' AND t.source_system_id = 3
  AND per.first_name = 'Youssou' AND per.last_name = 'Diawara'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Astoria Knights II' AND t.source_system_id = 3
  AND per.first_name = 'Hamadou' AND per.last_name = 'H Dieng'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Astoria Knights II' AND t.source_system_id = 3
  AND per.first_name = 'Souayibou' AND per.last_name = 'Diop'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Astoria Knights II' AND t.source_system_id = 3
  AND per.first_name = 'Juan' AND per.last_name = 'Jose Estupinan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Astoria Knights II' AND t.source_system_id = 3
  AND per.first_name = 'Hosen' AND per.last_name = 'Gakou'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Astoria Knights II' AND t.source_system_id = 3
  AND per.first_name = 'Gakou' AND per.last_name = 'Hassna'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Astoria Knights II' AND t.source_system_id = 3
  AND per.first_name = 'Isa' AND per.last_name = 'Mendez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Astoria Knights II' AND t.source_system_id = 3
  AND per.first_name = 'Dany' AND per.last_name = 'Aaron Nueva'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Astoria Knights II' AND t.source_system_id = 3
  AND per.first_name = 'Juan' AND per.last_name = 'Nueva'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Astoria Knights II' AND t.source_system_id = 3
  AND per.first_name = 'Benedict' AND per.last_name = 'Obeng'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Astoria Knights II' AND t.source_system_id = 3
  AND per.first_name = 'Luis' AND per.last_name = 'Angel Polanco'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Astoria Knights II' AND t.source_system_id = 3
  AND per.first_name = 'Adama' AND per.last_name = 'Sall'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Astoria Knights II' AND t.source_system_id = 3
  AND per.first_name = 'Luis' AND per.last_name = 'Tamay'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Caribbean FCA' AND t.source_system_id = 3
  AND per.first_name = 'Oscar' AND per.last_name = 'Alexis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Caribbean FCA' AND t.source_system_id = 3
  AND per.first_name = 'Berlandy' AND per.last_name = 'Balde'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Caribbean FCA' AND t.source_system_id = 3
  AND per.first_name = 'Chriswadle' AND per.last_name = 'Beauvil'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Caribbean FCA' AND t.source_system_id = 3
  AND per.first_name = 'Cleeford' AND per.last_name = 'Cenejuste'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Caribbean FCA' AND t.source_system_id = 3
  AND per.first_name = 'djelvens' AND per.last_name = 'charlestin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Caribbean FCA' AND t.source_system_id = 3
  AND per.first_name = 'Gedeon' AND per.last_name = 'Del Piero'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Caribbean FCA' AND t.source_system_id = 3
  AND per.first_name = 'Stevenson' AND per.last_name = 'Dieudonne'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Caribbean FCA' AND t.source_system_id = 3
  AND per.first_name = 'Chrismonor' AND per.last_name = 'Eugene'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Caribbean FCA' AND t.source_system_id = 3
  AND per.first_name = 'George' AND per.last_name = 'Jean Claude'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Caribbean FCA' AND t.source_system_id = 3
  AND per.first_name = 'Rico' AND per.last_name = 'Jean Pierre'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Caribbean FCA' AND t.source_system_id = 3
  AND per.first_name = 'mills' AND per.last_name = 'odoi kwesi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Caribbean FCA' AND t.source_system_id = 3
  AND per.first_name = 'Kenly' AND per.last_name = 'Lalane'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Caribbean FCA' AND t.source_system_id = 3
  AND per.first_name = 'Ewentz' AND per.last_name = 'Larose'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Caribbean FCA' AND t.source_system_id = 3
  AND per.first_name = 'Dieuvenson' AND per.last_name = 'Leger'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Caribbean FCA' AND t.source_system_id = 3
  AND per.first_name = 'erick' AND per.last_name = 'patrick lorent'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Caribbean FCA' AND t.source_system_id = 3
  AND per.first_name = 'Jhon' AND per.last_name = 'Fred Louis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Caribbean FCA' AND t.source_system_id = 3
  AND per.first_name = 'John' AND per.last_name = 'Kevin Louis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Caribbean FCA' AND t.source_system_id = 3
  AND per.first_name = 'Guerlain' AND per.last_name = 'Milien'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Caribbean FCA' AND t.source_system_id = 3
  AND per.first_name = 'Davidson' AND per.last_name = 'Modestil'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Caribbean FCA' AND t.source_system_id = 3
  AND per.first_name = 'Olmann' AND per.last_name = 'Pauyo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Caribbean FCA' AND t.source_system_id = 3
  AND per.first_name = 'Granderson' AND per.last_name = 'Precile'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Caribbean FCA' AND t.source_system_id = 3
  AND per.first_name = 'William' AND per.last_name = 'Shanks'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Caribbean FCA' AND t.source_system_id = 3
  AND per.first_name = 'Brice' AND per.last_name = 'Victor'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Caribbean FCA' AND t.source_system_id = 3
  AND per.first_name = 'Edwin' AND per.last_name = 'Victor'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Clarkstown SC' AND t.source_system_id = 3
  AND per.first_name = 'Brayan' AND per.last_name = 'Alejandro Villarreal Rivas'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Clarkstown SC' AND t.source_system_id = 3
  AND per.first_name = 'Randy' AND per.last_name = 'Angamarca'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Clarkstown SC' AND t.source_system_id = 3
  AND per.first_name = 'Anthony' AND per.last_name = 'Avelino'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Clarkstown SC' AND t.source_system_id = 3
  AND per.first_name = 'Brandon' AND per.last_name = 'Avelino'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Clarkstown SC' AND t.source_system_id = 3
  AND per.first_name = 'Kameron' AND per.last_name = 'Paul Connell'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Clarkstown SC' AND t.source_system_id = 3
  AND per.first_name = 'Erick' AND per.last_name = 'Cruz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Clarkstown SC' AND t.source_system_id = 3
  AND per.first_name = 'Christian' AND per.last_name = 'Dominguez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Clarkstown SC' AND t.source_system_id = 3
  AND per.first_name = 'Brandon' AND per.last_name = 'Dutan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Clarkstown SC' AND t.source_system_id = 3
  AND per.first_name = 'Ignacio' AND per.last_name = 'Escamilla Silva'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Clarkstown SC' AND t.source_system_id = 3
  AND per.first_name = 'Starlyn' AND per.last_name = 'Rene Escobar'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Clarkstown SC' AND t.source_system_id = 3
  AND per.first_name = 'Ahmed' AND per.last_name = 'Fadl'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Clarkstown SC' AND t.source_system_id = 3
  AND per.first_name = 'Jaden' AND per.last_name = 'Fernandez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Clarkstown SC' AND t.source_system_id = 3
  AND per.first_name = 'Jose' AND per.last_name = 'Gagliardi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Clarkstown SC' AND t.source_system_id = 3
  AND per.first_name = 'Wisemento' AND per.last_name = 'Germain'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Clarkstown SC' AND t.source_system_id = 3
  AND per.first_name = 'Maaz' AND per.last_name = 'Gilani'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Clarkstown SC' AND t.source_system_id = 3
  AND per.first_name = 'Janmarcos' AND per.last_name = 'Gonzalez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Clarkstown SC' AND t.source_system_id = 3
  AND per.first_name = 'mifejy' AND per.last_name = 'schwartz janvier'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Clarkstown SC' AND t.source_system_id = 3
  AND per.first_name = 'Joaquin' AND per.last_name = 'Marin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Clarkstown SC' AND t.source_system_id = 3
  AND per.first_name = 'Bryan' AND per.last_name = 'Martinez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Clarkstown SC' AND t.source_system_id = 3
  AND per.first_name = 'Armando' AND per.last_name = 'Mendez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Clarkstown SC' AND t.source_system_id = 3
  AND per.first_name = 'Luis' AND per.last_name = 'Monzon'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Clarkstown SC' AND t.source_system_id = 3
  AND per.first_name = 'Hector' AND per.last_name = 'Moran'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Clarkstown SC' AND t.source_system_id = 3
  AND per.first_name = 'Jared' AND per.last_name = 'Mullahy'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Clarkstown SC' AND t.source_system_id = 3
  AND per.first_name = 'Geremy' AND per.last_name = 'Paredes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Clarkstown SC' AND t.source_system_id = 3
  AND per.first_name = 'Jair' AND per.last_name = 'Parra'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Clarkstown SC' AND t.source_system_id = 3
  AND per.first_name = 'Michael' AND per.last_name = 'Portanova'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Clarkstown SC' AND t.source_system_id = 3
  AND per.first_name = 'Joseph' AND per.last_name = 'Portanova-'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Clarkstown SC' AND t.source_system_id = 3
  AND per.first_name = 'Brian' AND per.last_name = 'Rivera'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Clarkstown SC' AND t.source_system_id = 3
  AND per.first_name = 'James' AND per.last_name = 'Salto'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Clarkstown SC' AND t.source_system_id = 3
  AND per.first_name = 'Alexander' AND per.last_name = 'Soriano'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Clarkstown SC' AND t.source_system_id = 3
  AND per.first_name = 'Jason' AND per.last_name = 'Soulouque'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Clarkstown SC' AND t.source_system_id = 3
  AND per.first_name = 'Sebastian' AND per.last_name = 'Trotta'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Clarkstown SC' AND t.source_system_id = 3
  AND per.first_name = 'David' AND per.last_name = 'Vasquez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Clarkstown SC' AND t.source_system_id = 3
  AND per.first_name = 'Kevin' AND per.last_name = 'Vega'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Clarkstown SC' AND t.source_system_id = 3
  AND per.first_name = 'Matthew' AND per.last_name = 'Zweibach'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Afghan Ittihad FC' AND t.source_system_id = 3
  AND per.first_name = 'Fawad' AND per.last_name = 'Ahmad'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Afghan Ittihad FC' AND t.source_system_id = 3
  AND per.first_name = 'Basir' AND per.last_name = 'Akbar'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Afghan Ittihad FC' AND t.source_system_id = 3
  AND per.first_name = 'Nasir' AND per.last_name = 'Akbar'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Afghan Ittihad FC' AND t.source_system_id = 3
  AND per.first_name = 'Rashid' AND per.last_name = 'Allah Morad'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Afghan Ittihad FC' AND t.source_system_id = 3
  AND per.first_name = 'Shaeim' AND per.last_name = 'Allah Morad'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Afghan Ittihad FC' AND t.source_system_id = 3
  AND per.first_name = 'Ahmad' AND per.last_name = 'Aly'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Afghan Ittihad FC' AND t.source_system_id = 3
  AND per.first_name = 'Yusuf' AND per.last_name = 'Figueroa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Afghan Ittihad FC' AND t.source_system_id = 3
  AND per.first_name = 'Ausmanollah' AND per.last_name = 'Haye'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Afghan Ittihad FC' AND t.source_system_id = 3
  AND per.first_name = 'Bilaluddin' AND per.last_name = 'Jamaluddin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Afghan Ittihad FC' AND t.source_system_id = 3
  AND per.first_name = 'Ilyes' AND per.last_name = 'Khelaifi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Afghan Ittihad FC' AND t.source_system_id = 3
  AND per.first_name = 'Abdullah' AND per.last_name = 'Mayan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Afghan Ittihad FC' AND t.source_system_id = 3
  AND per.first_name = 'Ahmadullah' AND per.last_name = 'Mayan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Afghan Ittihad FC' AND t.source_system_id = 3
  AND per.first_name = 'Karimullah' AND per.last_name = 'Mayan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Afghan Ittihad FC' AND t.source_system_id = 3
  AND per.first_name = 'Rahmanullah' AND per.last_name = 'Mayan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Afghan Ittihad FC' AND t.source_system_id = 3
  AND per.first_name = 'Sharifullah' AND per.last_name = 'Mayan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Afghan Ittihad FC' AND t.source_system_id = 3
  AND per.first_name = 'hashim' AND per.last_name = 'morad'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Afghan Ittihad FC' AND t.source_system_id = 3
  AND per.first_name = 'Nasim' AND per.last_name = 'Morad'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Afghan Ittihad FC' AND t.source_system_id = 3
  AND per.first_name = 'BILAL' AND per.last_name = 'NASAR'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Afghan Ittihad FC' AND t.source_system_id = 3
  AND per.first_name = 'Mohammad' AND per.last_name = 'Asif Nasim'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Afghan Ittihad FC' AND t.source_system_id = 3
  AND per.first_name = 'Matin' AND per.last_name = 'Nazamy'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Afghan Ittihad FC' AND t.source_system_id = 3
  AND per.first_name = 'Mustafa' AND per.last_name = 'Nazamy'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Afghan Ittihad FC' AND t.source_system_id = 3
  AND per.first_name = 'Basir' AND per.last_name = 'Salimi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Afghan Ittihad FC' AND t.source_system_id = 3
  AND per.first_name = 'Sanawullah' AND per.last_name = 'Shairzai'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Afghan Ittihad FC' AND t.source_system_id = 3
  AND per.first_name = 'Najib' AND per.last_name = 'Ullah'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Afghan Ittihad FC' AND t.source_system_id = 3
  AND per.first_name = 'Mohammad' AND per.last_name = 'Edris Yonis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Afghan Ittihad FC' AND t.source_system_id = 3
  AND per.first_name = 'Mohammad' AND per.last_name = 'Waris Yonis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Aurora FC' AND t.source_system_id = 3
  AND per.first_name = 'Joshua' AND per.last_name = 'Ethan Lu Cabahug'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Aurora FC' AND t.source_system_id = 3
  AND per.first_name = 'Mohamed' AND per.last_name = 'Drame'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Aurora FC' AND t.source_system_id = 3
  AND per.first_name = 'Alan' AND per.last_name = 'Yuxuan Fang'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Aurora FC' AND t.source_system_id = 3
  AND per.first_name = 'Xiang' AND per.last_name = 'HU'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Aurora FC' AND t.source_system_id = 3
  AND per.first_name = 'Chen' AND per.last_name = 'Huang'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Aurora FC' AND t.source_system_id = 3
  AND per.first_name = 'HongJie' AND per.last_name = 'Huang'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Aurora FC' AND t.source_system_id = 3
  AND per.first_name = 'Samuel' AND per.last_name = 'Oluwasegun Kadejo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Aurora FC' AND t.source_system_id = 3
  AND per.first_name = 'William' AND per.last_name = 'Kim'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Aurora FC' AND t.source_system_id = 3
  AND per.first_name = 'HANK' AND per.last_name = 'S KLEIN'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Aurora FC' AND t.source_system_id = 3
  AND per.first_name = 'Paul' AND per.last_name = 'Matthew Hugo Koettering'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Aurora FC' AND t.source_system_id = 3
  AND per.first_name = 'Ram' AND per.last_name = 'Kukaj'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Aurora FC' AND t.source_system_id = 3
  AND per.first_name = 'Jonathan' AND per.last_name = 'Shih Chen Kung'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Aurora FC' AND t.source_system_id = 3
  AND per.first_name = 'RunHui' AND per.last_name = 'Li'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Aurora FC' AND t.source_system_id = 3
  AND per.first_name = 'Yong' AND per.last_name = 'Liu'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Aurora FC' AND t.source_system_id = 3
  AND per.first_name = 'Ayoub' AND per.last_name = 'El Idrissi Nabil'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Aurora FC' AND t.source_system_id = 3
  AND per.first_name = 'ZiTong' AND per.last_name = 'Qi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Aurora FC' AND t.source_system_id = 3
  AND per.first_name = 'Allen' AND per.last_name = 'Shen'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Aurora FC' AND t.source_system_id = 3
  AND per.first_name = 'WENHAO' AND per.last_name = 'SUN'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Aurora FC' AND t.source_system_id = 3
  AND per.first_name = 'ZIHAO' AND per.last_name = 'TENG'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Aurora FC' AND t.source_system_id = 3
  AND per.first_name = 'ZELONG' AND per.last_name = 'WANG'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Aurora FC' AND t.source_system_id = 3
  AND per.first_name = 'JIANFENG' AND per.last_name = 'WU'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Aurora FC' AND t.source_system_id = 3
  AND per.first_name = 'Meng' AND per.last_name = 'Xing'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Aurora FC' AND t.source_system_id = 3
  AND per.first_name = 'Daniel' AND per.last_name = 'Xu'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Aurora FC' AND t.source_system_id = 3
  AND per.first_name = 'Paulo' AND per.last_name = 'Renato Xu'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Aurora FC' AND t.source_system_id = 3
  AND per.first_name = 'Paulo' AND per.last_name = 'Rig Xu'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Aurora FC' AND t.source_system_id = 3
  AND per.first_name = 'JingSong' AND per.last_name = 'Yu'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Aurora FC' AND t.source_system_id = 3
  AND per.first_name = 'Harrison' AND per.last_name = 'Zhang'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Aurora FC' AND t.source_system_id = 3
  AND per.first_name = 'RongHang' AND per.last_name = 'Zhang'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Aurora FC' AND t.source_system_id = 3
  AND per.first_name = 'Yihuai' AND per.last_name = 'Zhang'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Aurora FC' AND t.source_system_id = 3
  AND per.first_name = 'Yuan' AND per.last_name = 'Zhen'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Aurora FC' AND t.source_system_id = 3
  AND per.first_name = 'Qingfang' AND per.last_name = 'Zheng'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Aurora FC' AND t.source_system_id = 3
  AND per.first_name = 'WENYU' AND per.last_name = 'ZHENG'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers FC' AND t.source_system_id = 3
  AND per.first_name = 'Carlos' AND per.last_name = 'Auquilla'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers FC' AND t.source_system_id = 3
  AND per.first_name = 'Sean' AND per.last_name = 'Becket'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers FC' AND t.source_system_id = 3
  AND per.first_name = 'Adrian' AND per.last_name = 'Benitez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers FC' AND t.source_system_id = 3
  AND per.first_name = 'Min' AND per.last_name = 'Choi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers FC' AND t.source_system_id = 3
  AND per.first_name = 'Matthew' AND per.last_name = 'Donovan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers FC' AND t.source_system_id = 3
  AND per.first_name = 'Julio' AND per.last_name = 'Duque'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers FC' AND t.source_system_id = 3
  AND per.first_name = 'Francho' AND per.last_name = 'Español'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers FC' AND t.source_system_id = 3
  AND per.first_name = 'Tobin' AND per.last_name = 'Feldman-Fitzthum'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers FC' AND t.source_system_id = 3
  AND per.first_name = 'Luis' AND per.last_name = 'Franco'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers FC' AND t.source_system_id = 3
  AND per.first_name = 'Daniel' AND per.last_name = 'Gutierrez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers FC' AND t.source_system_id = 3
  AND per.first_name = 'Timothy' AND per.last_name = 'Hattori'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers FC' AND t.source_system_id = 3
  AND per.first_name = 'Daniel' AND per.last_name = 'Jeon'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers FC' AND t.source_system_id = 3
  AND per.first_name = 'Pedro' AND per.last_name = 'Loor'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers FC' AND t.source_system_id = 3
  AND per.first_name = 'Juan' AND per.last_name = 'Mendoza'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers FC' AND t.source_system_id = 3
  AND per.first_name = 'Giovanny' AND per.last_name = 'Morales'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers FC' AND t.source_system_id = 3
  AND per.first_name = 'Zachary' AND per.last_name = 'Mulvihill'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers FC' AND t.source_system_id = 3
  AND per.first_name = 'Xavier' AND per.last_name = 'Negron'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers FC' AND t.source_system_id = 3
  AND per.first_name = 'Tobechukwu' AND per.last_name = 'Obi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers FC' AND t.source_system_id = 3
  AND per.first_name = 'Ademola' AND per.last_name = 'Joseph Opesanwo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers FC' AND t.source_system_id = 3
  AND per.first_name = 'David' AND per.last_name = 'Pinter'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers FC' AND t.source_system_id = 3
  AND per.first_name = 'Vincent' AND per.last_name = 'Ploum'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers FC' AND t.source_system_id = 3
  AND per.first_name = 'Sergio' AND per.last_name = 'Restrepo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers FC' AND t.source_system_id = 3
  AND per.first_name = 'Brayan' AND per.last_name = 'Roman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers FC' AND t.source_system_id = 3
  AND per.first_name = 'Remi' AND per.last_name = 'Sanderford'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers FC' AND t.source_system_id = 3
  AND per.first_name = 'Alexander' AND per.last_name = 'Stanley'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers FC' AND t.source_system_id = 3
  AND per.first_name = 'Tom' AND per.last_name = 'Wilkinson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers FC' AND t.source_system_id = 3
  AND per.first_name = 'Mark' AND per.last_name = 'Yeager'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers FC' AND t.source_system_id = 3
  AND per.first_name = 'George' AND per.last_name = 'Yeboah'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers Old Boys' AND t.source_system_id = 3
  AND per.first_name = 'Gary' AND per.last_name = 'Baddeley'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers Old Boys' AND t.source_system_id = 3
  AND per.first_name = 'Andrew' AND per.last_name = 'Bay'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers Old Boys' AND t.source_system_id = 3
  AND per.first_name = 'Jim' AND per.last_name = 'Beck'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers Old Boys' AND t.source_system_id = 3
  AND per.first_name = 'Fernando' AND per.last_name = 'Camberos'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers Old Boys' AND t.source_system_id = 3
  AND per.first_name = 'Thierno' AND per.last_name = 'Cisse'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers Old Boys' AND t.source_system_id = 3
  AND per.first_name = 'Mario' AND per.last_name = 'Cistaro'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers Old Boys' AND t.source_system_id = 3
  AND per.first_name = 'Remo' AND per.last_name = 'Enea'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers Old Boys' AND t.source_system_id = 3
  AND per.first_name = 'Jorge' AND per.last_name = 'Espanol'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers Old Boys' AND t.source_system_id = 3
  AND per.first_name = 'Gustavo' AND per.last_name = 'Garro'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers Old Boys' AND t.source_system_id = 3
  AND per.first_name = 'Zohair' AND per.last_name = 'Ghenania'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers Old Boys' AND t.source_system_id = 3
  AND per.first_name = 'Juan' AND per.last_name = 'Gonzalez Casares'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers Old Boys' AND t.source_system_id = 3
  AND per.first_name = 'Paul' AND per.last_name = 'Horan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers Old Boys' AND t.source_system_id = 3
  AND per.first_name = 'Colin' AND per.last_name = 'McLear'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers Old Boys' AND t.source_system_id = 3
  AND per.first_name = 'Greg' AND per.last_name = 'Michel'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers Old Boys' AND t.source_system_id = 3
  AND per.first_name = 'Aldo' AND per.last_name = 'Morales'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers Old Boys' AND t.source_system_id = 3
  AND per.first_name = 'Marcelo' AND per.last_name = 'Morsucci'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers Old Boys' AND t.source_system_id = 3
  AND per.first_name = 'Patrick' AND per.last_name = 'Reid'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers Old Boys' AND t.source_system_id = 3
  AND per.first_name = 'Paul' AND per.last_name = 'Rochester'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers Old Boys' AND t.source_system_id = 3
  AND per.first_name = 'David' AND per.last_name = 'Sheeran'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers Old Boys' AND t.source_system_id = 3
  AND per.first_name = 'Terrill' AND per.last_name = 'Simecki'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers Old Boys' AND t.source_system_id = 3
  AND per.first_name = 'John' AND per.last_name = 'Slaughter'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers Old Boys' AND t.source_system_id = 3
  AND per.first_name = 'Alvaro' AND per.last_name = 'Soneiro'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers Old Boys' AND t.source_system_id = 3
  AND per.first_name = 'Toy' AND per.last_name = 'Ulit Ithti'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers Old Boys' AND t.source_system_id = 3
  AND per.first_name = 'Jeremy' AND per.last_name = 'Wine'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers Old Boys' AND t.source_system_id = 3
  AND per.first_name = 'Evan' AND per.last_name = 'Woodhouse'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Barnstonworth Rovers Old Boys' AND t.source_system_id = 3
  AND per.first_name = 'Stavros' AND per.last_name = 'Zomopoulos'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Block FC' AND t.source_system_id = 3
  AND per.first_name = 'Mahamadou' AND per.last_name = 'Camara'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Block FC' AND t.source_system_id = 3
  AND per.first_name = 'Mahamadou' AND per.last_name = 'Ceesay'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Block FC' AND t.source_system_id = 3
  AND per.first_name = 'Abdulsalam' AND per.last_name = 'Dansira'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Block FC' AND t.source_system_id = 3
  AND per.first_name = 'Ebrima' AND per.last_name = 'Drammed'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Block FC' AND t.source_system_id = 3
  AND per.first_name = 'Burahima' AND per.last_name = 'Dukuray'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Block FC' AND t.source_system_id = 3
  AND per.first_name = 'Foday' AND per.last_name = 'Dukuray'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Block FC' AND t.source_system_id = 3
  AND per.first_name = 'Muhamade' AND per.last_name = 'Dukuray'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Block FC' AND t.source_system_id = 3
  AND per.first_name = 'Abdukassim' AND per.last_name = 'Fofana'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Block FC' AND t.source_system_id = 3
  AND per.first_name = 'Ibrahim' AND per.last_name = 'Gaku'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Block FC' AND t.source_system_id = 3
  AND per.first_name = 'Mohammad' AND per.last_name = 'Jagne'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Block FC' AND t.source_system_id = 3
  AND per.first_name = 'Amadou' AND per.last_name = 'Mballow'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Block FC' AND t.source_system_id = 3
  AND per.first_name = 'Mahammed' AND per.last_name = 'Sillah'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Block FC' AND t.source_system_id = 3
  AND per.first_name = 'Ousman' AND per.last_name = 'Sillah'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Block FC' AND t.source_system_id = 3
  AND per.first_name = 'Kande' AND per.last_name = 'Sohna'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Block FC' AND t.source_system_id = 3
  AND per.first_name = 'Ismaila' AND per.last_name = 'Trawally'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Block FC' AND t.source_system_id = 3
  AND per.first_name = 'Muhamadou' AND per.last_name = 'Tunkara'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Block FC' AND t.source_system_id = 3
  AND per.first_name = 'Najiru' AND per.last_name = 'Tunkara'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Block FC II' AND t.source_system_id = 3
  AND per.first_name = 'Essa' AND per.last_name = 'Bajaha'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Block FC II' AND t.source_system_id = 3
  AND per.first_name = 'Ibrahima' AND per.last_name = 'Barry'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Block FC II' AND t.source_system_id = 3
  AND per.first_name = 'Mohamed' AND per.last_name = 'Conde'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Block FC II' AND t.source_system_id = 3
  AND per.first_name = 'Muhammed' AND per.last_name = 'Drammeh'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Block FC II' AND t.source_system_id = 3
  AND per.first_name = 'Suwaibou' AND per.last_name = 'Drammeh'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Block FC II' AND t.source_system_id = 3
  AND per.first_name = 'Amara' AND per.last_name = 'Dukuray'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Block FC II' AND t.source_system_id = 3
  AND per.first_name = 'Muhammed' AND per.last_name = 'Dukuray'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Block FC II' AND t.source_system_id = 3
  AND per.first_name = 'HIMADU' AND per.last_name = 'DUKUREH'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Block FC II' AND t.source_system_id = 3
  AND per.first_name = 'Bangal' AND per.last_name = 'Fofana'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Block FC II' AND t.source_system_id = 3
  AND per.first_name = 'Ousman' AND per.last_name = 'Fofana'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Block FC II' AND t.source_system_id = 3
  AND per.first_name = 'Mahamadu' AND per.last_name = 'Gaku'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Block FC II' AND t.source_system_id = 3
  AND per.first_name = 'Muhammed' AND per.last_name = 'Jagana'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Block FC II' AND t.source_system_id = 3
  AND per.first_name = 'Mahamadou' AND per.last_name = 'Janka'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Block FC II' AND t.source_system_id = 3
  AND per.first_name = 'Ibrahim' AND per.last_name = 'Jawara'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Block FC II' AND t.source_system_id = 3
  AND per.first_name = 'ABDOULIE' AND per.last_name = 'JUWARA'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Block FC II' AND t.source_system_id = 3
  AND per.first_name = 'Musa' AND per.last_name = 'Sinera'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Block FC II' AND t.source_system_id = 3
  AND per.first_name = 'Mahmodu' AND per.last_name = 'Trawally'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Block FC II' AND t.source_system_id = 3
  AND per.first_name = 'Abulahi' AND per.last_name = 'Tunkara'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC' AND t.source_system_id = 3
  AND per.first_name = 'SERGIO' AND per.last_name = 'ABARCA'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC' AND t.source_system_id = 3
  AND per.first_name = 'MATTHAIS' AND per.last_name = 'ADAMEK'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC' AND t.source_system_id = 3
  AND per.first_name = 'NYRIK' AND per.last_name = 'JACOB ANTOINE'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC' AND t.source_system_id = 3
  AND per.first_name = 'ARAS' AND per.last_name = 'ASHRAFI'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC' AND t.source_system_id = 3
  AND per.first_name = 'DANIEL' AND per.last_name = 'SCOTT BANOONI'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC' AND t.source_system_id = 3
  AND per.first_name = 'ARDIT' AND per.last_name = 'BELEGU'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC' AND t.source_system_id = 3
  AND per.first_name = 'FOTI' AND per.last_name = 'CECI'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC' AND t.source_system_id = 3
  AND per.first_name = 'TIMOLEON' AND per.last_name = 'DELIYANNIS'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC' AND t.source_system_id = 3
  AND per.first_name = 'AMBROGIO' AND per.last_name = 'DIPASQUALE'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC' AND t.source_system_id = 3
  AND per.first_name = 'STEVEN' AND per.last_name = 'FERNANDEZ'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC' AND t.source_system_id = 3
  AND per.first_name = 'Jeffrey' AND per.last_name = 'Gad'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC' AND t.source_system_id = 3
  AND per.first_name = 'SEBASTIAN' AND per.last_name = 'GARCIA'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC' AND t.source_system_id = 3
  AND per.first_name = 'OMAR' AND per.last_name = 'GAWISH'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC' AND t.source_system_id = 3
  AND per.first_name = 'MATTHEW' AND per.last_name = 'HESSE'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC' AND t.source_system_id = 3
  AND per.first_name = 'KEVIN' AND per.last_name = 'NUNEZ'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC' AND t.source_system_id = 3
  AND per.first_name = 'DANIEL' AND per.last_name = 'PARDO'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC' AND t.source_system_id = 3
  AND per.first_name = 'JESUS' AND per.last_name = 'PATINO'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC' AND t.source_system_id = 3
  AND per.first_name = 'SERGIO' AND per.last_name = 'PERALTA-ILLESCAS'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC' AND t.source_system_id = 3
  AND per.first_name = 'JOHN' AND per.last_name = 'RODRIGUEZ'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC' AND t.source_system_id = 3
  AND per.first_name = 'DREW' AND per.last_name = 'ROSEN'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC' AND t.source_system_id = 3
  AND per.first_name = 'JACK' AND per.last_name = 'EVAN RUSSO'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC' AND t.source_system_id = 3
  AND per.first_name = 'ALEXIS' AND per.last_name = 'SANTA'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC' AND t.source_system_id = 3
  AND per.first_name = 'Azzeddine' AND per.last_name = 'Sekkat'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC' AND t.source_system_id = 3
  AND per.first_name = 'BRANDON' AND per.last_name = 'Silva'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC' AND t.source_system_id = 3
  AND per.first_name = 'JUSTIN' AND per.last_name = 'SILVA'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC' AND t.source_system_id = 3
  AND per.first_name = 'JOSEPH' AND per.last_name = 'ANDREW THOMANN'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC' AND t.source_system_id = 3
  AND per.first_name = 'George' AND per.last_name = 'Yusuff'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC II' AND t.source_system_id = 3
  AND per.first_name = 'GIUSEPPE' AND per.last_name = 'ALBERTO ANTONACCI'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC II' AND t.source_system_id = 3
  AND per.first_name = 'BAHAMOU' AND per.last_name = 'AYOUB'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC II' AND t.source_system_id = 3
  AND per.first_name = 'JOSE' AND per.last_name = 'BERMUDEZ'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC II' AND t.source_system_id = 3
  AND per.first_name = 'IUSTIN' AND per.last_name = 'BERTEA'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC II' AND t.source_system_id = 3
  AND per.first_name = 'ANDRES' AND per.last_name = 'ALEJANDRO BLOCK'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC II' AND t.source_system_id = 3
  AND per.first_name = 'JULIAN' AND per.last_name = 'CORREA'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC II' AND t.source_system_id = 3
  AND per.first_name = 'ROBERTO' AND per.last_name = 'DASHI'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC II' AND t.source_system_id = 3
  AND per.first_name = 'JUNIOR' AND per.last_name = 'DEL ROSARIO'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC II' AND t.source_system_id = 3
  AND per.first_name = 'Nick' AND per.last_name = 'Eras'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC II' AND t.source_system_id = 3
  AND per.first_name = 'Saad' AND per.last_name = 'Etsh'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC II' AND t.source_system_id = 3
  AND per.first_name = 'ATEF' AND per.last_name = 'M FAYED'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC II' AND t.source_system_id = 3
  AND per.first_name = 'ANDRO' AND per.last_name = 'GARCIA ECONOMIDES'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC II' AND t.source_system_id = 3
  AND per.first_name = 'GIUSEPPE' AND per.last_name = 'GAROFALO'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC II' AND t.source_system_id = 3
  AND per.first_name = 'STIVIN' AND per.last_name = 'GIRALDO'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC II' AND t.source_system_id = 3
  AND per.first_name = 'JUNIOR' AND per.last_name = 'GUAMAN'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC II' AND t.source_system_id = 3
  AND per.first_name = 'ANDREA' AND per.last_name = 'IAMPIETRO'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC II' AND t.source_system_id = 3
  AND per.first_name = 'ALBIN' AND per.last_name = 'MAZREKAJ'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC II' AND t.source_system_id = 3
  AND per.first_name = 'Kristopher' AND per.last_name = 'McDowell'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC II' AND t.source_system_id = 3
  AND per.first_name = 'HAROLD' AND per.last_name = 'WILLIAM MEJIA DARUICH'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC II' AND t.source_system_id = 3
  AND per.first_name = 'Yasser' AND per.last_name = 'Mourad'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC II' AND t.source_system_id = 3
  AND per.first_name = 'YUKI' AND per.last_name = 'MURA YAMA-MARTIN'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC II' AND t.source_system_id = 3
  AND per.first_name = 'GEOVANY' AND per.last_name = 'YAEL OBLEA'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC II' AND t.source_system_id = 3
  AND per.first_name = 'ALEJANDRO' AND per.last_name = 'PEREZ'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC II' AND t.source_system_id = 3
  AND per.first_name = 'KEVIN' AND per.last_name = 'PETRONILO'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC II' AND t.source_system_id = 3
  AND per.first_name = 'Akeem' AND per.last_name = 'Phipps'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC II' AND t.source_system_id = 3
  AND per.first_name = 'ZAKHAR' AND per.last_name = 'POBUTSKYY'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC II' AND t.source_system_id = 3
  AND per.first_name = 'WILSON' AND per.last_name = 'SINCHI'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC II' AND t.source_system_id = 3
  AND per.first_name = 'DIEGO' AND per.last_name = 'SINCHI PAVANA'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC II' AND t.source_system_id = 3
  AND per.first_name = 'Armando' AND per.last_name = 'Vuktijal'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Borgetto FC II' AND t.source_system_id = 3
  AND per.first_name = 'DAHEUR' AND per.last_name = 'WALID'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Brooklyn City FC' AND t.source_system_id = 3
  AND per.first_name = 'Ismael' AND per.last_name = 'Ahmad'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Brooklyn City FC' AND t.source_system_id = 3
  AND per.first_name = 'Zacharia' AND per.last_name = 'Bachiri'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Brooklyn City FC' AND t.source_system_id = 3
  AND per.first_name = 'Cole' AND per.last_name = 'Cross'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Brooklyn City FC' AND t.source_system_id = 3
  AND per.first_name = 'Jasper' AND per.last_name = 'Ehrnhardt'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Brooklyn City FC' AND t.source_system_id = 3
  AND per.first_name = 'Amr' AND per.last_name = 'Eldin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Brooklyn City FC' AND t.source_system_id = 3
  AND per.first_name = 'Kimani' AND per.last_name = 'Ellison'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Brooklyn City FC' AND t.source_system_id = 3
  AND per.first_name = 'Elijah' AND per.last_name = 'Elmore'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Brooklyn City FC' AND t.source_system_id = 3
  AND per.first_name = 'Stann' AND per.last_name = 'Jeune'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Brooklyn City FC' AND t.source_system_id = 3
  AND per.first_name = 'Ekundayo' AND per.last_name = 'Johnson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Brooklyn City FC' AND t.source_system_id = 3
  AND per.first_name = 'Jacob' AND per.last_name = 'Kipnis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Brooklyn City FC' AND t.source_system_id = 3
  AND per.first_name = 'Gerson' AND per.last_name = 'Lima'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Brooklyn City FC' AND t.source_system_id = 3
  AND per.first_name = 'Mergim' AND per.last_name = 'Mehmeti'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Brooklyn City FC' AND t.source_system_id = 3
  AND per.first_name = 'Felipe' AND per.last_name = 'Mendes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Brooklyn City FC' AND t.source_system_id = 3
  AND per.first_name = 'Edwin' AND per.last_name = 'Perez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Brooklyn City FC' AND t.source_system_id = 3
  AND per.first_name = 'Aditya' AND per.last_name = 'Radia'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Brooklyn City FC' AND t.source_system_id = 3
  AND per.first_name = 'Matteo' AND per.last_name = 'Rama'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Brooklyn City FC' AND t.source_system_id = 3
  AND per.first_name = 'Andrew' AND per.last_name = 'Robert'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Brooklyn City FC' AND t.source_system_id = 3
  AND per.first_name = 'Nicolas' AND per.last_name = 'Sirena'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Brooklyn City FC' AND t.source_system_id = 3
  AND per.first_name = 'Sami' AND per.last_name = 'Sobh'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Brooklyn City FC' AND t.source_system_id = 3
  AND per.first_name = 'Peter' AND per.last_name = 'Wise'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Brooklyn City FC' AND t.source_system_id = 3
  AND per.first_name = 'Wojciech' AND per.last_name = 'Zarlok'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Brooklyn City FC II' AND t.source_system_id = 3
  AND per.first_name = 'Ahmed' AND per.last_name = 'Ali'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Brooklyn City FC II' AND t.source_system_id = 3
  AND per.first_name = 'Ahmed' AND per.last_name = 'Aly'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Brooklyn City FC II' AND t.source_system_id = 3
  AND per.first_name = 'Jonnathan' AND per.last_name = 'Andrade'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Brooklyn City FC II' AND t.source_system_id = 3
  AND per.first_name = 'Jonathan' AND per.last_name = 'Baez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Brooklyn City FC II' AND t.source_system_id = 3
  AND per.first_name = 'Christopher' AND per.last_name = 'Belliveau'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Brooklyn City FC II' AND t.source_system_id = 3
  AND per.first_name = 'Carlos' AND per.last_name = 'Calzadilla'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Brooklyn City FC II' AND t.source_system_id = 3
  AND per.first_name = 'Aykut' AND per.last_name = 'Can'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Brooklyn City FC II' AND t.source_system_id = 3
  AND per.first_name = 'Johan' AND per.last_name = 'David Castillo Vergara'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Brooklyn City FC II' AND t.source_system_id = 3
  AND per.first_name = 'Ciro' AND per.last_name = 'Contreras'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Brooklyn City FC II' AND t.source_system_id = 3
  AND per.first_name = 'Aboubakary' AND per.last_name = 'Diaby'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Brooklyn City FC II' AND t.source_system_id = 3
  AND per.first_name = 'Mohamed' AND per.last_name = 'Eldin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Brooklyn City FC II' AND t.source_system_id = 3
  AND per.first_name = 'Anthony' AND per.last_name = 'Favara'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Brooklyn City FC II' AND t.source_system_id = 3
  AND per.first_name = 'John' AND per.last_name = 'Favara'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Brooklyn City FC II' AND t.source_system_id = 3
  AND per.first_name = 'Carlos' AND per.last_name = 'Garcia'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Brooklyn City FC II' AND t.source_system_id = 3
  AND per.first_name = 'Antonio' AND per.last_name = 'Gaspar'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Brooklyn City FC II' AND t.source_system_id = 3
  AND per.first_name = 'Ayman' AND per.last_name = 'Hamza'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Brooklyn City FC II' AND t.source_system_id = 3
  AND per.first_name = 'Steven' AND per.last_name = 'Herman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Brooklyn City FC II' AND t.source_system_id = 3
  AND per.first_name = 'Douglas' AND per.last_name = 'James'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Brooklyn City FC II' AND t.source_system_id = 3
  AND per.first_name = 'Diego' AND per.last_name = 'Jimenez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Brooklyn City FC II' AND t.source_system_id = 3
  AND per.first_name = 'Zayrab' AND per.last_name = 'Khan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Brooklyn City FC II' AND t.source_system_id = 3
  AND per.first_name = 'Rrap' AND per.last_name = 'Kukaj'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Brooklyn City FC II' AND t.source_system_id = 3
  AND per.first_name = 'Bryan' AND per.last_name = 'Mendez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Brooklyn City FC II' AND t.source_system_id = 3
  AND per.first_name = 'Alexander' AND per.last_name = 'Mendolia'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Brooklyn City FC II' AND t.source_system_id = 3
  AND per.first_name = 'Jason' AND per.last_name = 'Orban'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Brooklyn City FC II' AND t.source_system_id = 3
  AND per.first_name = 'Dimitrios' AND per.last_name = 'Paragiannis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Brooklyn City FC II' AND t.source_system_id = 3
  AND per.first_name = 'Guillermo' AND per.last_name = 'Restrepo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Brooklyn City FC II' AND t.source_system_id = 3
  AND per.first_name = 'Cristian' AND per.last_name = 'Ruiz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Brooklyn City FC II' AND t.source_system_id = 3
  AND per.first_name = 'Jose' AND per.last_name = 'Torres'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Brooklyn City FC II' AND t.source_system_id = 3
  AND per.first_name = 'Moslem' AND per.last_name = 'Yehya'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia' AND t.source_system_id = 3
  AND per.first_name = 'Estevan' AND per.last_name = 'Altamirano'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia' AND t.source_system_id = 3
  AND per.first_name = 'Miguel' AND per.last_name = 'Altamirano'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia' AND t.source_system_id = 3
  AND per.first_name = 'Santiago' AND per.last_name = 'Bedoya'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia' AND t.source_system_id = 3
  AND per.first_name = 'Mark' AND per.last_name = 'Dakov'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia' AND t.source_system_id = 3
  AND per.first_name = 'Jose' AND per.last_name = 'Elias'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia' AND t.source_system_id = 3
  AND per.first_name = 'David' AND per.last_name = 'Formoso'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia' AND t.source_system_id = 3
  AND per.first_name = 'Landon' AND per.last_name = 'Frank'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia' AND t.source_system_id = 3
  AND per.first_name = 'Rodolfo' AND per.last_name = 'Giraldi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia' AND t.source_system_id = 3
  AND per.first_name = 'Carlos' AND per.last_name = 'Gutierrez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia' AND t.source_system_id = 3
  AND per.first_name = 'Russell' AND per.last_name = 'Hoffman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia' AND t.source_system_id = 3
  AND per.first_name = 'Daniel' AND per.last_name = 'Hristodorov'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia' AND t.source_system_id = 3
  AND per.first_name = 'Matthew' AND per.last_name = 'Jennings'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia' AND t.source_system_id = 3
  AND per.first_name = 'Abraham' AND per.last_name = 'Jurado'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia' AND t.source_system_id = 3
  AND per.first_name = 'Muhammed' AND per.last_name = 'Karabay'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia' AND t.source_system_id = 3
  AND per.first_name = 'Nicholas' AND per.last_name = 'Karkut'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia' AND t.source_system_id = 3
  AND per.first_name = 'Eric' AND per.last_name = 'Klur'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia' AND t.source_system_id = 3
  AND per.first_name = 'Manuel' AND per.last_name = 'Leon'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia' AND t.source_system_id = 3
  AND per.first_name = 'Kevin' AND per.last_name = 'Maldonado'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia' AND t.source_system_id = 3
  AND per.first_name = 'Javier' AND per.last_name = 'Mejia'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia' AND t.source_system_id = 3
  AND per.first_name = 'Jake' AND per.last_name = 'Mella'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia' AND t.source_system_id = 3
  AND per.first_name = 'Julian' AND per.last_name = 'Mella'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia' AND t.source_system_id = 3
  AND per.first_name = 'Mikel' AND per.last_name = 'Ortiz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia' AND t.source_system_id = 3
  AND per.first_name = 'Anthony' AND per.last_name = 'Paino'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia' AND t.source_system_id = 3
  AND per.first_name = 'Alejandro' AND per.last_name = 'Pena'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia' AND t.source_system_id = 3
  AND per.first_name = 'Ernest' AND per.last_name = 'Peterson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia' AND t.source_system_id = 3
  AND per.first_name = 'Alejandro' AND per.last_name = 'Sanmartin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia' AND t.source_system_id = 3
  AND per.first_name = 'Victor' AND per.last_name = 'Tsigalnitsky'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia' AND t.source_system_id = 3
  AND per.first_name = 'Dionel' AND per.last_name = 'Villalva'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia' AND t.source_system_id = 3
  AND per.first_name = 'Yonah' AND per.last_name = 'Zeitz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers 1999' AND t.source_system_id = 3
  AND per.first_name = 'Rahul' AND per.last_name = 'Bhagavan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers 1999' AND t.source_system_id = 3
  AND per.first_name = 'Jake' AND per.last_name = 'Brown'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers 1999' AND t.source_system_id = 3
  AND per.first_name = 'Miguel' AND per.last_name = 'Carvalho'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers 1999' AND t.source_system_id = 3
  AND per.first_name = 'Ahmad' AND per.last_name = 'Daniel'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers 1999' AND t.source_system_id = 3
  AND per.first_name = 'Conrad' AND per.last_name = 'Freire'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers 1999' AND t.source_system_id = 3
  AND per.first_name = 'Agustin' AND per.last_name = 'Gonzalez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers 1999' AND t.source_system_id = 3
  AND per.first_name = 'Armando' AND per.last_name = 'Gonzalez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers 1999' AND t.source_system_id = 3
  AND per.first_name = 'Ahmed' AND per.last_name = 'Hamami'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers 1999' AND t.source_system_id = 3
  AND per.first_name = 'Giosue' AND per.last_name = 'Improta'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers 1999' AND t.source_system_id = 3
  AND per.first_name = 'Abdel' AND per.last_name = 'Itito'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers 1999' AND t.source_system_id = 3
  AND per.first_name = 'Jerry' AND per.last_name = 'Leon'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers 1999' AND t.source_system_id = 3
  AND per.first_name = 'Pete' AND per.last_name = 'Macinnis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers 1999' AND t.source_system_id = 3
  AND per.first_name = 'Daouda' AND per.last_name = 'Mangane'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers 1999' AND t.source_system_id = 3
  AND per.first_name = 'Aidan' AND per.last_name = 'Marcano'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers 1999' AND t.source_system_id = 3
  AND per.first_name = 'Stephen' AND per.last_name = 'Morse'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers 1999' AND t.source_system_id = 3
  AND per.first_name = 'Chris' AND per.last_name = 'Neil'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers 1999' AND t.source_system_id = 3
  AND per.first_name = 'Humza' AND per.last_name = 'Obaid'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers 1999' AND t.source_system_id = 3
  AND per.first_name = 'Randi' AND per.last_name = 'Olea'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers 1999' AND t.source_system_id = 3
  AND per.first_name = 'Mubarak' AND per.last_name = 'Ouro'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers 1999' AND t.source_system_id = 3
  AND per.first_name = 'Tyler' AND per.last_name = 'Rawlings'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers 1999' AND t.source_system_id = 3
  AND per.first_name = 'Eli' AND per.last_name = 'Richards'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers 1999' AND t.source_system_id = 3
  AND per.first_name = 'Tom' AND per.last_name = 'Ross'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers 1999' AND t.source_system_id = 3
  AND per.first_name = 'Jose' AND per.last_name = 'Miguel Sanchez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers 1999' AND t.source_system_id = 3
  AND per.first_name = 'Eduardo' AND per.last_name = 'Sebastiao'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers 1999' AND t.source_system_id = 3
  AND per.first_name = 'Beto' AND per.last_name = 'Spielvogel'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers 1999' AND t.source_system_id = 3
  AND per.first_name = 'George' AND per.last_name = 'Tidbury'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers 1999' AND t.source_system_id = 3
  AND per.first_name = 'Charilaos' AND per.last_name = 'Varelas'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers 1999' AND t.source_system_id = 3
  AND per.first_name = 'K''gnausa' AND per.last_name = 'Yodkerepaurprai'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers 1999' AND t.source_system_id = 3
  AND per.first_name = 'Kevin' AND per.last_name = 'Zapata'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Green' AND t.source_system_id = 3
  AND per.first_name = 'Liam' AND per.last_name = 'Aloni'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Green' AND t.source_system_id = 3
  AND per.first_name = 'Khenti' AND per.last_name = 'Amen'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Green' AND t.source_system_id = 3
  AND per.first_name = 'Patrick' AND per.last_name = 'Anson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Green' AND t.source_system_id = 3
  AND per.first_name = 'Zack' AND per.last_name = 'Bartula'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Green' AND t.source_system_id = 3
  AND per.first_name = 'Leonardo' AND per.last_name = 'Betancourt'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Green' AND t.source_system_id = 3
  AND per.first_name = 'Isaac' AND per.last_name = 'Bogart'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Green' AND t.source_system_id = 3
  AND per.first_name = 'Sami' AND per.last_name = 'Bolnick'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Green' AND t.source_system_id = 3
  AND per.first_name = 'Chris' AND per.last_name = 'Carroll'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Green' AND t.source_system_id = 3
  AND per.first_name = 'Astin' AND per.last_name = 'Davis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Green' AND t.source_system_id = 3
  AND per.first_name = 'Stefano' AND per.last_name = 'Delgado'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Green' AND t.source_system_id = 3
  AND per.first_name = 'Chris' AND per.last_name = 'Foy'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Green' AND t.source_system_id = 3
  AND per.first_name = 'Andres' AND per.last_name = 'Garrido'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Green' AND t.source_system_id = 3
  AND per.first_name = 'Marcel' AND per.last_name = 'Howard'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Green' AND t.source_system_id = 3
  AND per.first_name = 'Istvan' AND per.last_name = 'Kanyo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Green' AND t.source_system_id = 3
  AND per.first_name = 'Arman' AND per.last_name = 'Karbassioon'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Green' AND t.source_system_id = 3
  AND per.first_name = 'Reed' AND per.last_name = 'Kessler'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Green' AND t.source_system_id = 3
  AND per.first_name = 'Sam' AND per.last_name = 'Lerman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Green' AND t.source_system_id = 3
  AND per.first_name = 'Matthew' AND per.last_name = 'Macfarquhar'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Green' AND t.source_system_id = 3
  AND per.first_name = 'Pablo' AND per.last_name = 'Martinez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Green' AND t.source_system_id = 3
  AND per.first_name = 'Andres' AND per.last_name = 'Martynek'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Green' AND t.source_system_id = 3
  AND per.first_name = 'Bryan' AND per.last_name = 'Menegazzo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Green' AND t.source_system_id = 3
  AND per.first_name = 'Luis' AND per.last_name = 'Navarro'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Green' AND t.source_system_id = 3
  AND per.first_name = 'Tom' AND per.last_name = 'Nicholson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Green' AND t.source_system_id = 3
  AND per.first_name = 'Jude' AND per.last_name = 'Oppong-Asare'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Green' AND t.source_system_id = 3
  AND per.first_name = 'Will' AND per.last_name = 'Peatman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Green' AND t.source_system_id = 3
  AND per.first_name = 'Julien' AND per.last_name = 'Riker'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Green' AND t.source_system_id = 3
  AND per.first_name = 'Harrison' AND per.last_name = 'Ryle'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Green' AND t.source_system_id = 3
  AND per.first_name = 'Nathan' AND per.last_name = 'Song'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United' AND t.source_system_id = 3
  AND per.first_name = 'Alfredo' AND per.last_name = 'Bastidas'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United' AND t.source_system_id = 3
  AND per.first_name = 'Samuel' AND per.last_name = 'Caceres'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United' AND t.source_system_id = 3
  AND per.first_name = 'Steven' AND per.last_name = 'Diaz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United' AND t.source_system_id = 3
  AND per.first_name = 'Ilir' AND per.last_name = 'Durakovic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United' AND t.source_system_id = 3
  AND per.first_name = 'Lioa' AND per.last_name = 'Fook kee'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United' AND t.source_system_id = 3
  AND per.first_name = 'Emmanuel' AND per.last_name = 'Gamez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United' AND t.source_system_id = 3
  AND per.first_name = 'Pablo' AND per.last_name = 'Garcia'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United' AND t.source_system_id = 3
  AND per.first_name = 'Diego' AND per.last_name = 'Gonzalez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United' AND t.source_system_id = 3
  AND per.first_name = 'Henry' AND per.last_name = 'Gonzalez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United' AND t.source_system_id = 3
  AND per.first_name = 'Jorge' AND per.last_name = 'Gonzalez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United' AND t.source_system_id = 3
  AND per.first_name = 'Eugenio' AND per.last_name = 'Guillo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United' AND t.source_system_id = 3
  AND per.first_name = 'German' AND per.last_name = 'Islas'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United' AND t.source_system_id = 3
  AND per.first_name = 'Arthur' AND per.last_name = 'Kulkov'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United' AND t.source_system_id = 3
  AND per.first_name = 'Carlos' AND per.last_name = 'Moncaleano'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United' AND t.source_system_id = 3
  AND per.first_name = 'Mauricio' AND per.last_name = 'Mora'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United' AND t.source_system_id = 3
  AND per.first_name = 'Hemir' AND per.last_name = 'Niebles'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United' AND t.source_system_id = 3
  AND per.first_name = 'Gabriel' AND per.last_name = 'Ortega'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United' AND t.source_system_id = 3
  AND per.first_name = 'Brighan' AND per.last_name = 'Ortiz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United' AND t.source_system_id = 3
  AND per.first_name = 'David' AND per.last_name = 'Panchano'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United' AND t.source_system_id = 3
  AND per.first_name = 'Lucas' AND per.last_name = 'Davida Pereyra'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United' AND t.source_system_id = 3
  AND per.first_name = 'Kirk' AND per.last_name = 'Dean Scarlett'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United' AND t.source_system_id = 3
  AND per.first_name = 'Franklyn' AND per.last_name = 'Solarte'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United' AND t.source_system_id = 3
  AND per.first_name = 'Galo' AND per.last_name = 'Solis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United' AND t.source_system_id = 3
  AND per.first_name = 'Kevin' AND per.last_name = 'Vasquez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United' AND t.source_system_id = 3
  AND per.first_name = 'Raul' AND per.last_name = 'Zuniga Ochoa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Legends' AND t.source_system_id = 3
  AND per.first_name = 'Jeff' AND per.last_name = 'Alexander'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Legends' AND t.source_system_id = 3
  AND per.first_name = 'Pablo' AND per.last_name = 'Arrocha'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Legends' AND t.source_system_id = 3
  AND per.first_name = 'Danny' AND per.last_name = 'Azzo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Legends' AND t.source_system_id = 3
  AND per.first_name = 'Willie' AND per.last_name = 'Boyle'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Legends' AND t.source_system_id = 3
  AND per.first_name = 'Bo-joe' AND per.last_name = 'Brans'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Legends' AND t.source_system_id = 3
  AND per.first_name = 'Scott' AND per.last_name = 'Brindley'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Legends' AND t.source_system_id = 3
  AND per.first_name = 'Mike' AND per.last_name = 'Carducci'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Legends' AND t.source_system_id = 3
  AND per.first_name = 'Mark' AND per.last_name = 'Ciolli'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Legends' AND t.source_system_id = 3
  AND per.first_name = 'Marc' AND per.last_name = 'Duquette'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Legends' AND t.source_system_id = 3
  AND per.first_name = 'Mark' AND per.last_name = 'Edmunds'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Legends' AND t.source_system_id = 3
  AND per.first_name = 'Sean' AND per.last_name = 'Fitzsimmons'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Legends' AND t.source_system_id = 3
  AND per.first_name = 'Andrew' AND per.last_name = 'Jones'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Legends' AND t.source_system_id = 3
  AND per.first_name = 'Charles' AND per.last_name = 'Linehan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Legends' AND t.source_system_id = 3
  AND per.first_name = 'Eduardo' AND per.last_name = 'Mazzi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Legends' AND t.source_system_id = 3
  AND per.first_name = 'Creighton' AND per.last_name = 'Mershon'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Legends' AND t.source_system_id = 3
  AND per.first_name = 'Gavin' AND per.last_name = 'Moore'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Legends' AND t.source_system_id = 3
  AND per.first_name = 'Bo' AND per.last_name = 'Nyberg'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Legends' AND t.source_system_id = 3
  AND per.first_name = 'Robert' AND per.last_name = 'Phillips'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Legends' AND t.source_system_id = 3
  AND per.first_name = 'Olivier' AND per.last_name = 'Poupeney'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Legends' AND t.source_system_id = 3
  AND per.first_name = 'David' AND per.last_name = 'Sawyer'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Legends' AND t.source_system_id = 3
  AND per.first_name = 'Ilya' AND per.last_name = 'Shamovsky'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Legends' AND t.source_system_id = 3
  AND per.first_name = 'Olatokumbo' AND per.last_name = 'Shobowale'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Legends' AND t.source_system_id = 3
  AND per.first_name = 'Sebastian' AND per.last_name = 'Sobczak'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Legends' AND t.source_system_id = 3
  AND per.first_name = 'Neil' AND per.last_name = 'Stower'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Legends' AND t.source_system_id = 3
  AND per.first_name = 'Ernest' AND per.last_name = 'Subah'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Legends' AND t.source_system_id = 3
  AND per.first_name = 'Stephen' AND per.last_name = 'Teesdale'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Legends' AND t.source_system_id = 3
  AND per.first_name = 'Takeshi' AND per.last_name = 'Tsujita'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Legends' AND t.source_system_id = 3
  AND per.first_name = 'Dan' AND per.last_name = 'Wachtell'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
  AND per.first_name = 'Joseph' AND per.last_name = 'Anthony Allen'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
  AND per.first_name = 'Ryan' AND per.last_name = 'Arvin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
  AND per.first_name = 'Lenroy' AND per.last_name = 'Brown'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
  AND per.first_name = 'Atty' AND per.last_name = 'Bruce'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
  AND per.first_name = 'Steven' AND per.last_name = 'Cano'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
  AND per.first_name = 'Edixon' AND per.last_name = 'Castillo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
  AND per.first_name = 'Paul' AND per.last_name = 'Clarke'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
  AND per.first_name = 'Matthew' AND per.last_name = 'Costelloe'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
  AND per.first_name = 'Cary' AND per.last_name = 'Cousineau'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
  AND per.first_name = 'Sekou' AND per.last_name = 'Cox'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
  AND per.first_name = 'Timothy' AND per.last_name = 'Eliot'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
  AND per.first_name = 'Samuel' AND per.last_name = 'Emsell'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
  AND per.first_name = 'Yury' AND per.last_name = 'Alejandro Escobar Mejia'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
  AND per.first_name = 'David' AND per.last_name = 'Freire'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
  AND per.first_name = 'Emmanuel' AND per.last_name = 'Gamez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
  AND per.first_name = 'Dean' AND per.last_name = 'Gergoric'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
  AND per.first_name = 'Matthew' AND per.last_name = 'Hatcher'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
  AND per.first_name = 'Abelardo' AND per.last_name = 'Hernandez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
  AND per.first_name = 'Robert' AND per.last_name = 'Sven Johnson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
  AND per.first_name = 'Fabricio' AND per.last_name = 'Lima'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
  AND per.first_name = 'Meir' AND per.last_name = 'Mazal'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
  AND per.first_name = 'Dan' AND per.last_name = 'Mejias'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
  AND per.first_name = 'Kevin' AND per.last_name = 'Otte'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
  AND per.first_name = 'Juan' AND per.last_name = 'Sebastian Palacios'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
  AND per.first_name = 'Daniel' AND per.last_name = 'Quiros Herrero'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
  AND per.first_name = 'Elior' AND per.last_name = 'Talmasov'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
  AND per.first_name = 'Benjamin' AND per.last_name = 'Teipe'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
  AND per.first_name = 'Ilia' AND per.last_name = 'Vovsha'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers United II' AND t.source_system_id = 3
  AND per.first_name = 'Lee' AND per.last_name = 'Weinstein'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Orange' AND t.source_system_id = 3
  AND per.first_name = 'Marco' AND per.last_name = 'Alacron'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Orange' AND t.source_system_id = 3
  AND per.first_name = 'Juan' AND per.last_name = 'Pablo Asbun'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Orange' AND t.source_system_id = 3
  AND per.first_name = 'Gabriel' AND per.last_name = 'Cowles'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Orange' AND t.source_system_id = 3
  AND per.first_name = 'Danilo' AND per.last_name = 'Crestejo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Orange' AND t.source_system_id = 3
  AND per.first_name = 'Jason' AND per.last_name = 'Cyrus'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Orange' AND t.source_system_id = 3
  AND per.first_name = 'Willian' AND per.last_name = 'Dandrea'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Orange' AND t.source_system_id = 3
  AND per.first_name = 'Jay' AND per.last_name = 'Evans'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Orange' AND t.source_system_id = 3
  AND per.first_name = 'Christopher' AND per.last_name = 'Holterhoff'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Orange' AND t.source_system_id = 3
  AND per.first_name = 'Jason' AND per.last_name = 'Jarecki'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Orange' AND t.source_system_id = 3
  AND per.first_name = 'Grant' AND per.last_name = 'Koerner'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Orange' AND t.source_system_id = 3
  AND per.first_name = 'Najib' AND per.last_name = 'Majaj'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Orange' AND t.source_system_id = 3
  AND per.first_name = 'Robert' AND per.last_name = 'Marsella'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Orange' AND t.source_system_id = 3
  AND per.first_name = 'Devin' AND per.last_name = 'Molina'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Orange' AND t.source_system_id = 3
  AND per.first_name = 'Hakan' AND per.last_name = 'Nizam'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Orange' AND t.source_system_id = 3
  AND per.first_name = 'Justin' AND per.last_name = 'Noel'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Orange' AND t.source_system_id = 3
  AND per.first_name = 'Chris' AND per.last_name = 'ODonnell'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Orange' AND t.source_system_id = 3
  AND per.first_name = 'Bevan' AND per.last_name = 'Rosenbloom'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Orange' AND t.source_system_id = 3
  AND per.first_name = 'Vojdan' AND per.last_name = 'Rosoklija'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Orange' AND t.source_system_id = 3
  AND per.first_name = 'Claudio' AND per.last_name = 'Schneider'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Orange' AND t.source_system_id = 3
  AND per.first_name = 'Joji' AND per.last_name = 'Tokita'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Orange' AND t.source_system_id = 3
  AND per.first_name = 'Rodrigo' AND per.last_name = 'Valle'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Orange' AND t.source_system_id = 3
  AND per.first_name = 'Manohar' AND per.last_name = 'Venkataraman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Orange' AND t.source_system_id = 3
  AND per.first_name = 'Mateo' AND per.last_name = 'Vila'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Orange' AND t.source_system_id = 3
  AND per.first_name = 'Takuna' AND per.last_name = 'Watanabe'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Red' AND t.source_system_id = 3
  AND per.first_name = 'Matthew' AND per.last_name = 'Baringer'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Red' AND t.source_system_id = 3
  AND per.first_name = 'Peter' AND per.last_name = 'Berry'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Red' AND t.source_system_id = 3
  AND per.first_name = 'Trip' AND per.last_name = 'Burke'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Red' AND t.source_system_id = 3
  AND per.first_name = 'Max' AND per.last_name = 'Cherry'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Red' AND t.source_system_id = 3
  AND per.first_name = 'Oliver' AND per.last_name = 'Clift'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Red' AND t.source_system_id = 3
  AND per.first_name = 'Gerasimos' AND per.last_name = 'Dedes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Red' AND t.source_system_id = 3
  AND per.first_name = 'Zachary' AND per.last_name = 'Gollin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Red' AND t.source_system_id = 3
  AND per.first_name = 'Josh' AND per.last_name = 'Gray'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Red' AND t.source_system_id = 3
  AND per.first_name = 'James' AND per.last_name = 'Greco'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Red' AND t.source_system_id = 3
  AND per.first_name = 'David' AND per.last_name = 'Jacobs'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Red' AND t.source_system_id = 3
  AND per.first_name = 'Ajay' AND per.last_name = 'Jagadesan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Red' AND t.source_system_id = 3
  AND per.first_name = 'Devin' AND per.last_name = 'Keane'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Red' AND t.source_system_id = 3
  AND per.first_name = 'Paul' AND per.last_name = 'Le Helloco'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Red' AND t.source_system_id = 3
  AND per.first_name = 'Mike' AND per.last_name = 'Lorello'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Red' AND t.source_system_id = 3
  AND per.first_name = 'Evan' AND per.last_name = 'Mason'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Red' AND t.source_system_id = 3
  AND per.first_name = 'Troy' AND per.last_name = 'Moo Penn'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Red' AND t.source_system_id = 3
  AND per.first_name = 'Michael' AND per.last_name = 'Moraitis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Red' AND t.source_system_id = 3
  AND per.first_name = 'Henrik' AND per.last_name = 'Olsson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Red' AND t.source_system_id = 3
  AND per.first_name = 'Anthony' AND per.last_name = 'Scimeca'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Red' AND t.source_system_id = 3
  AND per.first_name = 'Chris' AND per.last_name = 'Valentine'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Red II' AND t.source_system_id = 3
  AND per.first_name = 'Mohammed' AND per.last_name = 'Aladarous'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Red II' AND t.source_system_id = 3
  AND per.first_name = 'Khalid' AND per.last_name = 'Ali'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Red II' AND t.source_system_id = 3
  AND per.first_name = 'Samuel' AND per.last_name = 'Aronoff'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Red II' AND t.source_system_id = 3
  AND per.first_name = 'Jaime' AND per.last_name = 'Bahamondes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Red II' AND t.source_system_id = 3
  AND per.first_name = 'Josh' AND per.last_name = 'Barkoff'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Red II' AND t.source_system_id = 3
  AND per.first_name = 'Jaime' AND per.last_name = 'Barrenechea'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Red II' AND t.source_system_id = 3
  AND per.first_name = 'Max' AND per.last_name = 'Berney'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Red II' AND t.source_system_id = 3
  AND per.first_name = 'Sasha' AND per.last_name = 'Boussina'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Red II' AND t.source_system_id = 3
  AND per.first_name = 'Ioan' AND per.last_name = 'Delice'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Red II' AND t.source_system_id = 3
  AND per.first_name = 'Federico' AND per.last_name = 'Diaz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Red II' AND t.source_system_id = 3
  AND per.first_name = 'Colm' AND per.last_name = 'Doherty'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Red II' AND t.source_system_id = 3
  AND per.first_name = 'Adam' AND per.last_name = 'Eldefrawy'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Red II' AND t.source_system_id = 3
  AND per.first_name = 'Kimani' AND per.last_name = 'Evans'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Red II' AND t.source_system_id = 3
  AND per.first_name = 'Francesco' AND per.last_name = 'Gjoligaj'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Red II' AND t.source_system_id = 3
  AND per.first_name = 'Deniz' AND per.last_name = 'Guven'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Red II' AND t.source_system_id = 3
  AND per.first_name = 'Daniel' AND per.last_name = 'Hare'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Red II' AND t.source_system_id = 3
  AND per.first_name = 'Cadeem' AND per.last_name = 'Harris'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Red II' AND t.source_system_id = 3
  AND per.first_name = 'Esen' AND per.last_name = 'Harris'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Red II' AND t.source_system_id = 3
  AND per.first_name = 'Alex' AND per.last_name = 'Hula'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Red II' AND t.source_system_id = 3
  AND per.first_name = 'Colin' AND per.last_name = 'Marment'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Red II' AND t.source_system_id = 3
  AND per.first_name = 'William' AND per.last_name = 'Marment'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Red II' AND t.source_system_id = 3
  AND per.first_name = 'Rory' AND per.last_name = 'Quigley'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Red II' AND t.source_system_id = 3
  AND per.first_name = 'James' AND per.last_name = 'Rosiello'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Red II' AND t.source_system_id = 3
  AND per.first_name = 'Jefri' AND per.last_name = 'Schmidt'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Red II' AND t.source_system_id = 3
  AND per.first_name = 'Maxwell' AND per.last_name = 'Song'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Red II' AND t.source_system_id = 3
  AND per.first_name = 'Adam' AND per.last_name = 'Wright'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Red II' AND t.source_system_id = 3
  AND per.first_name = 'Bernie' AND per.last_name = 'Wright'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Young Boys' AND t.source_system_id = 3
  AND per.first_name = 'Sebastian' AND per.last_name = 'Catano Bustamante'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Young Boys' AND t.source_system_id = 3
  AND per.first_name = 'Daniel' AND per.last_name = 'Culma'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Young Boys' AND t.source_system_id = 3
  AND per.first_name = 'Alex' AND per.last_name = 'De Chaves'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Young Boys' AND t.source_system_id = 3
  AND per.first_name = 'Ryan' AND per.last_name = 'Garcia'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Young Boys' AND t.source_system_id = 3
  AND per.first_name = 'Edwin' AND per.last_name = 'Guaman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Young Boys' AND t.source_system_id = 3
  AND per.first_name = 'Roberto' AND per.last_name = 'Guerrero Albarrasin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Young Boys' AND t.source_system_id = 3
  AND per.first_name = 'David' AND per.last_name = 'Holmes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Young Boys' AND t.source_system_id = 3
  AND per.first_name = 'Azmain' AND per.last_name = 'Ishrak'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Young Boys' AND t.source_system_id = 3
  AND per.first_name = 'Maximo' AND per.last_name = 'Juca'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Young Boys' AND t.source_system_id = 3
  AND per.first_name = 'Roger' AND per.last_name = 'Juca'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Young Boys' AND t.source_system_id = 3
  AND per.first_name = 'Nathan' AND per.last_name = 'Maleh'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Young Boys' AND t.source_system_id = 3
  AND per.first_name = 'Jose' AND per.last_name = 'Marquez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Young Boys' AND t.source_system_id = 3
  AND per.first_name = 'Manuel' AND per.last_name = 'Mecias'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Young Boys' AND t.source_system_id = 3
  AND per.first_name = 'Oliver' AND per.last_name = 'Noble'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Young Boys' AND t.source_system_id = 3
  AND per.first_name = 'William' AND per.last_name = 'Ogara III'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Young Boys' AND t.source_system_id = 3
  AND per.first_name = 'James' AND per.last_name = 'Pettigrew'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Young Boys' AND t.source_system_id = 3
  AND per.first_name = 'Ronald' AND per.last_name = 'Pineda'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Young Boys' AND t.source_system_id = 3
  AND per.first_name = 'Jose' AND per.last_name = 'Pinzon'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Young Boys' AND t.source_system_id = 3
  AND per.first_name = 'Jorge' AND per.last_name = 'Ruiz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Young Boys' AND t.source_system_id = 3
  AND per.first_name = 'Jesse' AND per.last_name = 'Salvato'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Young Boys' AND t.source_system_id = 3
  AND per.first_name = 'Sebastian' AND per.last_name = 'Sarmiento'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Young Boys' AND t.source_system_id = 3
  AND per.first_name = 'Andrew' AND per.last_name = 'Sepulveda'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Young Boys' AND t.source_system_id = 3
  AND per.first_name = 'Jose' AND per.last_name = 'Tagle'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers Young Boys' AND t.source_system_id = 3
  AND per.first_name = 'Michael' AND per.last_name = 'Zelaya'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Cozmoz FC' AND t.source_system_id = 3
  AND per.first_name = 'Andres' AND per.last_name = 'Alexander'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Cozmoz FC' AND t.source_system_id = 3
  AND per.first_name = 'Brahian' AND per.last_name = 'Angulo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Cozmoz FC' AND t.source_system_id = 3
  AND per.first_name = 'Adrian' AND per.last_name = 'Armstrong'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Cozmoz FC' AND t.source_system_id = 3
  AND per.first_name = 'Romain' AND per.last_name = 'Barker'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Cozmoz FC' AND t.source_system_id = 3
  AND per.first_name = 'Jon' AND per.last_name = 'Benenson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Cozmoz FC' AND t.source_system_id = 3
  AND per.first_name = 'Laidley' AND per.last_name = 'Brown'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Cozmoz FC' AND t.source_system_id = 3
  AND per.first_name = 'Marc' AND per.last_name = 'Cuenot'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Cozmoz FC' AND t.source_system_id = 3
  AND per.first_name = 'Ben' AND per.last_name = 'Espinoza'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Cozmoz FC' AND t.source_system_id = 3
  AND per.first_name = 'Steven' AND per.last_name = 'Evans'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Cozmoz FC' AND t.source_system_id = 3
  AND per.first_name = 'Jose' AND per.last_name = 'Luis Jerez Cerna'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Cozmoz FC' AND t.source_system_id = 3
  AND per.first_name = 'Ricardo' AND per.last_name = 'Jerome'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Cozmoz FC' AND t.source_system_id = 3
  AND per.first_name = 'Marlon' AND per.last_name = 'Johnson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Cozmoz FC' AND t.source_system_id = 3
  AND per.first_name = 'Jason' AND per.last_name = 'Jordan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Cozmoz FC' AND t.source_system_id = 3
  AND per.first_name = 'Brent' AND per.last_name = 'Lyons'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Cozmoz FC' AND t.source_system_id = 3
  AND per.first_name = 'Roberto' AND per.last_name = 'Maldonado'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Cozmoz FC' AND t.source_system_id = 3
  AND per.first_name = 'Ryosuke' AND per.last_name = 'Matsumoto'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Cozmoz FC' AND t.source_system_id = 3
  AND per.first_name = 'Kevin' AND per.last_name = 'Moo-Young'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Cozmoz FC' AND t.source_system_id = 3
  AND per.first_name = 'Duane' AND per.last_name = 'Pena'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Cozmoz FC' AND t.source_system_id = 3
  AND per.first_name = 'Narces' AND per.last_name = 'Phanor'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Cozmoz FC' AND t.source_system_id = 3
  AND per.first_name = 'Marlon' AND per.last_name = 'Roach'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Cozmoz FC' AND t.source_system_id = 3
  AND per.first_name = 'Mauricio' AND per.last_name = 'Romero'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Cozmoz FC' AND t.source_system_id = 3
  AND per.first_name = 'Nicholas' AND per.last_name = 'Shearer'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Cozmoz FC' AND t.source_system_id = 3
  AND per.first_name = 'Michael' AND per.last_name = 'Szivos'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Cozmoz FC' AND t.source_system_id = 3
  AND per.first_name = 'Christian' AND per.last_name = 'Tapia'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Cozmoz FC' AND t.source_system_id = 3
  AND per.first_name = 'Alan' AND per.last_name = 'Tardieu'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Cozmoz FC' AND t.source_system_id = 3
  AND per.first_name = 'Simeon' AND per.last_name = 'Trigueno'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Cozmoz FC' AND t.source_system_id = 3
  AND per.first_name = 'Dario' AND per.last_name = 'Trujillo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Cozmoz FC' AND t.source_system_id = 3
  AND per.first_name = 'Kendell' AND per.last_name = 'Villaroel'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Cozmoz FC' AND t.source_system_id = 3
  AND per.first_name = 'Maurice' AND per.last_name = 'Wellington'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Cozmoz FC' AND t.source_system_id = 3
  AND per.first_name = 'Keno' AND per.last_name = 'Williams'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad' AND t.source_system_id = 3
  AND per.first_name = 'Christopher' AND per.last_name = 'M. Marco Alves'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad' AND t.source_system_id = 3
  AND per.first_name = 'Firaas' AND per.last_name = 'Anis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad' AND t.source_system_id = 3
  AND per.first_name = 'Jasson' AND per.last_name = 'Armando Aucapina'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad' AND t.source_system_id = 3
  AND per.first_name = 'Elhadj' AND per.last_name = 'Bah'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad' AND t.source_system_id = 3
  AND per.first_name = 'Dovlet' AND per.last_name = 'Bayryyev'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad' AND t.source_system_id = 3
  AND per.first_name = 'Matthew' AND per.last_name = 'Beaty'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad' AND t.source_system_id = 3
  AND per.first_name = 'Jariga' AND per.last_name = 'Camara'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad' AND t.source_system_id = 3
  AND per.first_name = 'Lengash' AND per.last_name = 'Covenas'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad' AND t.source_system_id = 3
  AND per.first_name = 'Alan' AND per.last_name = 'Huy Dang'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad' AND t.source_system_id = 3
  AND per.first_name = 'Cristian' AND per.last_name = 'Delgado Farfan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad' AND t.source_system_id = 3
  AND per.first_name = 'Maxwell' AND per.last_name = 'Avrum Dounn'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad' AND t.source_system_id = 3
  AND per.first_name = 'Jose' AND per.last_name = 'Julio Escobedo Gomez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad' AND t.source_system_id = 3
  AND per.first_name = 'Andrew' AND per.last_name = 'Fu'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad' AND t.source_system_id = 3
  AND per.first_name = 'Zachary' AND per.last_name = 'Christian Galluzzo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad' AND t.source_system_id = 3
  AND per.first_name = 'Jakub' AND per.last_name = 'Gazi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad' AND t.source_system_id = 3
  AND per.first_name = 'Michael' AND per.last_name = 'Goldring'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad' AND t.source_system_id = 3
  AND per.first_name = 'Wade' AND per.last_name = 'Hoffman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad' AND t.source_system_id = 3
  AND per.first_name = 'Jazzany' AND per.last_name = 'Omari Joseph'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad' AND t.source_system_id = 3
  AND per.first_name = 'Andres' AND per.last_name = 'Eduardo Lopez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad' AND t.source_system_id = 3
  AND per.first_name = 'Charles' AND per.last_name = 'Mathison'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad' AND t.source_system_id = 3
  AND per.first_name = 'Maximilian' AND per.last_name = 'Moessner'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad' AND t.source_system_id = 3
  AND per.first_name = 'Federico' AND per.last_name = 'Mulieri'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad' AND t.source_system_id = 3
  AND per.first_name = 'Israel' AND per.last_name = 'Oyedapo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad' AND t.source_system_id = 3
  AND per.first_name = 'Jatan' AND per.last_name = 'Pathak'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad' AND t.source_system_id = 3
  AND per.first_name = 'Ansel' AND per.last_name = 'Ueshiro'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad' AND t.source_system_id = 3
  AND per.first_name = 'John' AND per.last_name = 'Michael Velez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad' AND t.source_system_id = 3
  AND per.first_name = 'Zhang' AND per.last_name = 'Zhiheng'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad City' AND t.source_system_id = 3
  AND per.first_name = 'Ahmad' AND per.last_name = 'Abdullah Al-Ansari'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad City' AND t.source_system_id = 3
  AND per.first_name = 'Jose' AND per.last_name = 'Aracena Belliard'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad City' AND t.source_system_id = 3
  AND per.first_name = 'Scott' AND per.last_name = 'Benson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad City' AND t.source_system_id = 3
  AND per.first_name = 'John-Paul' AND per.last_name = 'Tabi-Nyo Besong'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad City' AND t.source_system_id = 3
  AND per.first_name = 'Aamir' AND per.last_name = 'Bhojwani'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad City' AND t.source_system_id = 3
  AND per.first_name = 'Allan' AND per.last_name = 'Steven Bodden'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad City' AND t.source_system_id = 3
  AND per.first_name = 'Alam' AND per.last_name = 'Bodrul'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad City' AND t.source_system_id = 3
  AND per.first_name = 'Michael' AND per.last_name = 'F Brennan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad City' AND t.source_system_id = 3
  AND per.first_name = 'Darren' AND per.last_name = 'Lee Burton'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad City' AND t.source_system_id = 3
  AND per.first_name = 'Mark' AND per.last_name = 'Ciaran Byrne'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad City' AND t.source_system_id = 3
  AND per.first_name = 'Delano' AND per.last_name = 'Antwi Darko'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad City' AND t.source_system_id = 3
  AND per.first_name = 'Ibrahim' AND per.last_name = 'Doumbia'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad City' AND t.source_system_id = 3
  AND per.first_name = 'Alonso' AND per.last_name = 'Fernandez-Leal'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad City' AND t.source_system_id = 3
  AND per.first_name = 'Nicolas' AND per.last_name = 'Garcia'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad City' AND t.source_system_id = 3
  AND per.first_name = 'Hyunsoo' AND per.last_name = 'Kim'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad City' AND t.source_system_id = 3
  AND per.first_name = 'Christopher' AND per.last_name = 'Devin Lewis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad City' AND t.source_system_id = 3
  AND per.first_name = 'Michael' AND per.last_name = 'Marchassalla'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad City' AND t.source_system_id = 3
  AND per.first_name = 'Vengheang' AND per.last_name = 'Meng'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad City' AND t.source_system_id = 3
  AND per.first_name = 'Ignat' AND per.last_name = 'Andreevich Miagkov'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad City' AND t.source_system_id = 3
  AND per.first_name = 'Louis' AND per.last_name = 'J Moffa Jr'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad City' AND t.source_system_id = 3
  AND per.first_name = 'William' AND per.last_name = 'Moloney'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad City' AND t.source_system_id = 3
  AND per.first_name = 'Ayush' AND per.last_name = 'Narayan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad City' AND t.source_system_id = 3
  AND per.first_name = 'Daniel' AND per.last_name = 'Alejandro Oropeza'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad City' AND t.source_system_id = 3
  AND per.first_name = 'Abhishek' AND per.last_name = 'D Patel'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad City' AND t.source_system_id = 3
  AND per.first_name = 'Manuel' AND per.last_name = 'Fernando Ramos-Jimenez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad City' AND t.source_system_id = 3
  AND per.first_name = 'Carmine' AND per.last_name = 'Giovanni Sartini-Massimello'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad City' AND t.source_system_id = 3
  AND per.first_name = 'Asif' AND per.last_name = 'Saziduzzaman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad City' AND t.source_system_id = 3
  AND per.first_name = 'Abdouurahmane' AND per.last_name = 'Sow'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad City' AND t.source_system_id = 3
  AND per.first_name = 'Sonam' AND per.last_name = 'Gurung Tsering'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad City' AND t.source_system_id = 3
  AND per.first_name = 'Luis' AND per.last_name = 'Luis Alberto Victoria'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad Fury' AND t.source_system_id = 3
  AND per.first_name = 'Zachary' AND per.last_name = 'Joseph Adamonis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad Fury' AND t.source_system_id = 3
  AND per.first_name = 'Anthony' AND per.last_name = 'Alexander Aguirre Leon'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad Fury' AND t.source_system_id = 3
  AND per.first_name = 'Wadii''ah' AND per.last_name = 'Boughdir'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad Fury' AND t.source_system_id = 3
  AND per.first_name = 'Nathaniel' AND per.last_name = 'Luke Brown'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad Fury' AND t.source_system_id = 3
  AND per.first_name = 'Chazz' AND per.last_name = 'David Carter'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad Fury' AND t.source_system_id = 3
  AND per.first_name = 'Jumageldi' AND per.last_name = 'Charyyev'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad Fury' AND t.source_system_id = 3
  AND per.first_name = 'Kenyi' AND per.last_name = 'Abel Dominguez Basilio'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad Fury' AND t.source_system_id = 3
  AND per.first_name = 'Paa' AND per.last_name = 'Kwaku Dwumfour'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad Fury' AND t.source_system_id = 3
  AND per.first_name = 'Younes' AND per.last_name = 'Faridi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad Fury' AND t.source_system_id = 3
  AND per.first_name = 'Paulo' AND per.last_name = 'Francisco Ferreira Pereira'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad Fury' AND t.source_system_id = 3
  AND per.first_name = 'Tim' AND per.last_name = 'Frazier'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad Fury' AND t.source_system_id = 3
  AND per.first_name = 'Gilberto' AND per.last_name = 'Garcia'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad Fury' AND t.source_system_id = 3
  AND per.first_name = 'Bryan' AND per.last_name = 'Guananga'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad Fury' AND t.source_system_id = 3
  AND per.first_name = 'Adam' AND per.last_name = 'Atom Hadary'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad Fury' AND t.source_system_id = 3
  AND per.first_name = 'Danny' AND per.last_name = 'Iadanza'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad Fury' AND t.source_system_id = 3
  AND per.first_name = 'Shevon' AND per.last_name = 'H Jackson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad Fury' AND t.source_system_id = 3
  AND per.first_name = 'Aaron' AND per.last_name = 'Nicholas Joseph'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad Fury' AND t.source_system_id = 3
  AND per.first_name = 'David' AND per.last_name = 'Fernando Llanos'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad Fury' AND t.source_system_id = 3
  AND per.first_name = 'Manuel' AND per.last_name = 'Gustavo Lopez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad Fury' AND t.source_system_id = 3
  AND per.first_name = 'Adekunle' AND per.last_name = 'Sheriff Olalekan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad Fury' AND t.source_system_id = 3
  AND per.first_name = 'Patrick' AND per.last_name = 'Junior Pascal'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad Fury' AND t.source_system_id = 3
  AND per.first_name = 'Murat' AND per.last_name = 'Ogulcan Sahin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad Fury' AND t.source_system_id = 3
  AND per.first_name = 'Ilia' AND per.last_name = 'Sakheishvili'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad Fury' AND t.source_system_id = 3
  AND per.first_name = 'Eriberto' AND per.last_name = 'Serrano Torres'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad Fury' AND t.source_system_id = 3
  AND per.first_name = 'Victor' AND per.last_name = 'Leandro Tasayco Espinoza'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad Fury' AND t.source_system_id = 3
  AND per.first_name = 'Marcangelo' AND per.last_name = 'Antonio Trovato'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad Fury' AND t.source_system_id = 3
  AND per.first_name = 'Joe' AND per.last_name = 'Kevin Uzhca Remache'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad Fury' AND t.source_system_id = 3
  AND per.first_name = 'Geovanni' AND per.last_name = 'Joel Xilotl'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad II' AND t.source_system_id = 3
  AND per.first_name = 'Omar' AND per.last_name = 'Waleed Albakry'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad II' AND t.source_system_id = 3
  AND per.first_name = 'Bright' AND per.last_name = 'O Amin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad II' AND t.source_system_id = 3
  AND per.first_name = 'Nial' AND per.last_name = 'A Corbett'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad II' AND t.source_system_id = 3
  AND per.first_name = 'Ryan' AND per.last_name = 'Patrick Corrigan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad II' AND t.source_system_id = 3
  AND per.first_name = 'Marcello' AND per.last_name = 'Daniel Cruz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad II' AND t.source_system_id = 3
  AND per.first_name = 'Shaquille' AND per.last_name = 'Christopher Cummings'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad II' AND t.source_system_id = 3
  AND per.first_name = 'Denis' AND per.last_name = 'Dodaj'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad II' AND t.source_system_id = 3
  AND per.first_name = 'Rory' AND per.last_name = 'John Patrick Duggan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad II' AND t.source_system_id = 3
  AND per.first_name = 'Abdel' AND per.last_name = 'Mumin Elgailani'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad II' AND t.source_system_id = 3
  AND per.first_name = 'Kevin' AND per.last_name = 'Iglesias'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad II' AND t.source_system_id = 3
  AND per.first_name = 'Aliyar' AND per.last_name = 'Kasumov'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad II' AND t.source_system_id = 3
  AND per.first_name = 'Lorenzo' AND per.last_name = 'La Rosa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad II' AND t.source_system_id = 3
  AND per.first_name = 'Oisin' AND per.last_name = 'Pierce Mathers'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad II' AND t.source_system_id = 3
  AND per.first_name = 'Zafar' AND per.last_name = 'Mirzaliev'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad II' AND t.source_system_id = 3
  AND per.first_name = 'Alden' AND per.last_name = 'Dana Summerville'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad II' AND t.source_system_id = 3
  AND per.first_name = 'Petros' AND per.last_name = 'Themelis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Desportiva Sociedad II' AND t.source_system_id = 3
  AND per.first_name = 'Liam' AND per.last_name = 'Michael Walsh'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falco FC' AND t.source_system_id = 3
  AND per.first_name = 'Wilson' AND per.last_name = 'Aldas'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falco FC' AND t.source_system_id = 3
  AND per.first_name = 'Alberto' AND per.last_name = 'Alvarez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falco FC' AND t.source_system_id = 3
  AND per.first_name = 'Carlos' AND per.last_name = 'Aspiazu'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falco FC' AND t.source_system_id = 3
  AND per.first_name = 'Christian' AND per.last_name = 'Badaracco'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falco FC' AND t.source_system_id = 3
  AND per.first_name = 'Johnathan' AND per.last_name = 'Baustista'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falco FC' AND t.source_system_id = 3
  AND per.first_name = 'Jose' AND per.last_name = 'Antonio Betancourt Monasterios'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falco FC' AND t.source_system_id = 3
  AND per.first_name = 'Jordan' AND per.last_name = 'Camacho'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falco FC' AND t.source_system_id = 3
  AND per.first_name = 'Noah' AND per.last_name = 'Dougherty'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falco FC' AND t.source_system_id = 3
  AND per.first_name = 'Blaise' AND per.last_name = 'Enama'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falco FC' AND t.source_system_id = 3
  AND per.first_name = 'Regis' AND per.last_name = 'Enama'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falco FC' AND t.source_system_id = 3
  AND per.first_name = 'Alex' AND per.last_name = 'Ferrara'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falco FC' AND t.source_system_id = 3
  AND per.first_name = 'Brandon' AND per.last_name = 'Fiscina'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falco FC' AND t.source_system_id = 3
  AND per.first_name = 'Caio' AND per.last_name = 'Mancanares'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falco FC' AND t.source_system_id = 3
  AND per.first_name = 'Mathew' AND per.last_name = 'Merlo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falco FC' AND t.source_system_id = 3
  AND per.first_name = 'Michael' AND per.last_name = 'Merlo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falco FC' AND t.source_system_id = 3
  AND per.first_name = 'Chris' AND per.last_name = 'Morales'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falco FC' AND t.source_system_id = 3
  AND per.first_name = 'Ronald' AND per.last_name = 'Orejuela'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falco FC' AND t.source_system_id = 3
  AND per.first_name = 'Abdallah' AND per.last_name = 'Oumar'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falco FC' AND t.source_system_id = 3
  AND per.first_name = 'Christian' AND per.last_name = 'Paredes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falco FC' AND t.source_system_id = 3
  AND per.first_name = 'Alexander' AND per.last_name = 'Perez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falco FC' AND t.source_system_id = 3
  AND per.first_name = 'Fausto' AND per.last_name = 'Perez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falco FC' AND t.source_system_id = 3
  AND per.first_name = 'Andrew' AND per.last_name = 'Pinto'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falco FC' AND t.source_system_id = 3
  AND per.first_name = 'Aiden' AND per.last_name = 'Robinson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falco FC' AND t.source_system_id = 3
  AND per.first_name = 'Jonah' AND per.last_name = 'Sampedro'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falco FC' AND t.source_system_id = 3
  AND per.first_name = 'Daniele' AND per.last_name = 'Sgro'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falco FC' AND t.source_system_id = 3
  AND per.first_name = 'Antony' AND per.last_name = 'Simos'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falco FC' AND t.source_system_id = 3
  AND per.first_name = 'Oscar' AND per.last_name = 'Sosa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falco FC' AND t.source_system_id = 3
  AND per.first_name = 'Bryan' AND per.last_name = 'Suertegaray'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falco FC' AND t.source_system_id = 3
  AND per.first_name = 'Richard' AND per.last_name = 'Velez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falco FC' AND t.source_system_id = 3
  AND per.first_name = 'Arman' AND per.last_name = 'Zamanzadeh'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Japan' AND t.source_system_id = 3
  AND per.first_name = 'Ricardo' AND per.last_name = 'Casimir'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Japan' AND t.source_system_id = 3
  AND per.first_name = 'Kento' AND per.last_name = 'Fujita'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Japan' AND t.source_system_id = 3
  AND per.first_name = 'Hiroki' AND per.last_name = 'Fukuizumi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Japan' AND t.source_system_id = 3
  AND per.first_name = 'Ryo' AND per.last_name = 'Higuchi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Japan' AND t.source_system_id = 3
  AND per.first_name = 'Yukihiro' AND per.last_name = 'Hosoya'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Japan' AND t.source_system_id = 3
  AND per.first_name = 'Yuki' AND per.last_name = 'Ishii'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Japan' AND t.source_system_id = 3
  AND per.first_name = 'Keiichi' AND per.last_name = 'Ito'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Japan' AND t.source_system_id = 3
  AND per.first_name = 'Daisuke' AND per.last_name = 'Kanamori'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Japan' AND t.source_system_id = 3
  AND per.first_name = 'Kanji' AND per.last_name = 'Katayama'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Japan' AND t.source_system_id = 3
  AND per.first_name = 'Yuji' AND per.last_name = 'Kawaguchi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Japan' AND t.source_system_id = 3
  AND per.first_name = 'Makoto' AND per.last_name = 'Kinoshita'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Japan' AND t.source_system_id = 3
  AND per.first_name = 'Jason' AND per.last_name = 'Lawyer'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Japan' AND t.source_system_id = 3
  AND per.first_name = 'Harry' AND per.last_name = 'Lueken'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Japan' AND t.source_system_id = 3
  AND per.first_name = 'Yuto' AND per.last_name = 'Miyaji'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Japan' AND t.source_system_id = 3
  AND per.first_name = 'Ken' AND per.last_name = 'Mochizuki'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Japan' AND t.source_system_id = 3
  AND per.first_name = 'Kazuto' AND per.last_name = 'Mori'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Japan' AND t.source_system_id = 3
  AND per.first_name = 'Kaira' AND per.last_name = 'Nagai'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Japan' AND t.source_system_id = 3
  AND per.first_name = 'Ryunosuke' AND per.last_name = 'Nakagawa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Japan' AND t.source_system_id = 3
  AND per.first_name = 'Tatsuya' AND per.last_name = 'Otani'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Japan' AND t.source_system_id = 3
  AND per.first_name = 'Charles' AND per.last_name = 'Raymond'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Japan' AND t.source_system_id = 3
  AND per.first_name = 'Alexis' AND per.last_name = 'Restless'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Japan' AND t.source_system_id = 3
  AND per.first_name = 'Keisuke' AND per.last_name = 'Saito'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Japan' AND t.source_system_id = 3
  AND per.first_name = 'Kensei' AND per.last_name = 'Tanaka'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Japan' AND t.source_system_id = 3
  AND per.first_name = 'Shogo' AND per.last_name = 'Yamamoto'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Japan II' AND t.source_system_id = 3
  AND per.first_name = 'Niklas' AND per.last_name = 'Filippi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Japan II' AND t.source_system_id = 3
  AND per.first_name = 'Hansen' AND per.last_name = 'Hanggodo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Japan II' AND t.source_system_id = 3
  AND per.first_name = 'Hiroshi' AND per.last_name = 'Igarashi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Japan II' AND t.source_system_id = 3
  AND per.first_name = 'Dai' AND per.last_name = 'Kageyama'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Japan II' AND t.source_system_id = 3
  AND per.first_name = 'Masashi' AND per.last_name = 'Kanazawa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Japan II' AND t.source_system_id = 3
  AND per.first_name = 'Naoya' AND per.last_name = 'Kanno'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Japan II' AND t.source_system_id = 3
  AND per.first_name = 'Kota' AND per.last_name = 'Karube'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Japan II' AND t.source_system_id = 3
  AND per.first_name = 'Wataru' AND per.last_name = 'Kawasaki'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Japan II' AND t.source_system_id = 3
  AND per.first_name = 'Kensuke' AND per.last_name = 'Kobayashi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Japan II' AND t.source_system_id = 3
  AND per.first_name = 'Ryosuke' AND per.last_name = 'Kohigashi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Japan II' AND t.source_system_id = 3
  AND per.first_name = 'Ken' AND per.last_name = 'Kousaka'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Japan II' AND t.source_system_id = 3
  AND per.first_name = 'Hiroshi' AND per.last_name = 'Kuze'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Japan II' AND t.source_system_id = 3
  AND per.first_name = 'Juelz' AND per.last_name = 'Lewis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Japan II' AND t.source_system_id = 3
  AND per.first_name = 'Yukihiro' AND per.last_name = 'Mitsuno'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Japan II' AND t.source_system_id = 3
  AND per.first_name = 'James' AND per.last_name = 'Nakajima'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Japan II' AND t.source_system_id = 3
  AND per.first_name = 'Ren' AND per.last_name = 'Nakazawa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Japan II' AND t.source_system_id = 3
  AND per.first_name = 'Shinobu' AND per.last_name = 'Ninomiya'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Japan II' AND t.source_system_id = 3
  AND per.first_name = 'Hajime' AND per.last_name = 'Okamoto'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Japan II' AND t.source_system_id = 3
  AND per.first_name = 'Fumitake' AND per.last_name = 'Ono'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Japan II' AND t.source_system_id = 3
  AND per.first_name = 'Riki' AND per.last_name = 'Ozone'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Japan II' AND t.source_system_id = 3
  AND per.first_name = 'Isaiah' AND per.last_name = 'Schmitt'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Japan II' AND t.source_system_id = 3
  AND per.first_name = 'Yuu' AND per.last_name = 'Shimano'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Japan II' AND t.source_system_id = 3
  AND per.first_name = 'Mayuki' AND per.last_name = 'Shimizu'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Japan II' AND t.source_system_id = 3
  AND per.first_name = 'Perry' AND per.last_name = 'Tiu'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Japan II' AND t.source_system_id = 3
  AND per.first_name = 'Takahito' AND per.last_name = 'Tsuji'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Japan II' AND t.source_system_id = 3
  AND per.first_name = 'Masato' AND per.last_name = 'Yamamoto'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Partizani NY' AND t.source_system_id = 3
  AND per.first_name = 'Iglir' AND per.last_name = 'Arapi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Partizani NY' AND t.source_system_id = 3
  AND per.first_name = 'Luis' AND per.last_name = 'Balcazar Razzetto'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Partizani NY' AND t.source_system_id = 3
  AND per.first_name = 'Jurgen' AND per.last_name = 'Borici'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Partizani NY' AND t.source_system_id = 3
  AND per.first_name = 'Hayder' AND per.last_name = 'Cantos'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Partizani NY' AND t.source_system_id = 3
  AND per.first_name = 'Kevin' AND per.last_name = 'Castillo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Partizani NY' AND t.source_system_id = 3
  AND per.first_name = 'Pirro' AND per.last_name = 'Cece'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Partizani NY' AND t.source_system_id = 3
  AND per.first_name = 'Igor' AND per.last_name = 'Josue De Leon Gomez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Partizani NY' AND t.source_system_id = 3
  AND per.first_name = 'Jurgen' AND per.last_name = 'Dosti'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Partizani NY' AND t.source_system_id = 3
  AND per.first_name = 'Olawale' AND per.last_name = 'Eleso'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Partizani NY' AND t.source_system_id = 3
  AND per.first_name = 'Luciano' AND per.last_name = 'Gonzales'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Partizani NY' AND t.source_system_id = 3
  AND per.first_name = 'Arturs' AND per.last_name = 'Ivanovs'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Partizani NY' AND t.source_system_id = 3
  AND per.first_name = 'Brian' AND per.last_name = 'Koralewski'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Partizani NY' AND t.source_system_id = 3
  AND per.first_name = 'Christian' AND per.last_name = 'Lamprea'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Partizani NY' AND t.source_system_id = 3
  AND per.first_name = 'Luis' AND per.last_name = 'Munoz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Partizani NY' AND t.source_system_id = 3
  AND per.first_name = 'Ignacy' AND per.last_name = 'Sondej'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Partizani NY' AND t.source_system_id = 3
  AND per.first_name = 'Szymon' AND per.last_name = 'Sondej'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Partizani NY' AND t.source_system_id = 3
  AND per.first_name = 'Joe' AND per.last_name = 'Udeochu'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Partizani NY' AND t.source_system_id = 3
  AND per.first_name = 'Eni' AND per.last_name = 'Zejnati'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Sandzak' AND t.source_system_id = 3
  AND per.first_name = 'Maxwell' AND per.last_name = 'Taylor Aunger'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Sandzak' AND t.source_system_id = 3
  AND per.first_name = 'Romario' AND per.last_name = 'Bunjaj'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Sandzak' AND t.source_system_id = 3
  AND per.first_name = 'Mesih' AND per.last_name = 'Cekic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Sandzak' AND t.source_system_id = 3
  AND per.first_name = 'Enver' AND per.last_name = 'Desic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Sandzak' AND t.source_system_id = 3
  AND per.first_name = 'Mamadou' AND per.last_name = 'Diombera'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Sandzak' AND t.source_system_id = 3
  AND per.first_name = 'Vicetovic' AND per.last_name = 'Esmir'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Sandzak' AND t.source_system_id = 3
  AND per.first_name = 'Adnan' AND per.last_name = 'Feratovic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Sandzak' AND t.source_system_id = 3
  AND per.first_name = 'Jack' AND per.last_name = 'Gjokaj'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Sandzak' AND t.source_system_id = 3
  AND per.first_name = 'Amer' AND per.last_name = 'Hot'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Sandzak' AND t.source_system_id = 3
  AND per.first_name = 'Amar' AND per.last_name = 'Hrustemovic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Sandzak' AND t.source_system_id = 3
  AND per.first_name = 'Emir' AND per.last_name = 'Hrustemovic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Sandzak' AND t.source_system_id = 3
  AND per.first_name = 'Almas' AND per.last_name = 'Kojic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Sandzak' AND t.source_system_id = 3
  AND per.first_name = 'Alem' AND per.last_name = 'Kolenovic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Sandzak' AND t.source_system_id = 3
  AND per.first_name = 'Hajro' AND per.last_name = 'Kolenovic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Sandzak' AND t.source_system_id = 3
  AND per.first_name = 'Haris' AND per.last_name = 'Kolenovic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Sandzak' AND t.source_system_id = 3
  AND per.first_name = 'Emrah' AND per.last_name = 'Krcic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Sandzak' AND t.source_system_id = 3
  AND per.first_name = 'Ramo' AND per.last_name = 'Lukovic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Sandzak' AND t.source_system_id = 3
  AND per.first_name = 'Esad' AND per.last_name = 'Mackic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Sandzak' AND t.source_system_id = 3
  AND per.first_name = 'Gustavo' AND per.last_name = 'Mazariego'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Sandzak' AND t.source_system_id = 3
  AND per.first_name = 'Anes' AND per.last_name = 'Mrkulic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Sandzak' AND t.source_system_id = 3
  AND per.first_name = 'Fazlija' AND per.last_name = 'Nurkovic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Sandzak' AND t.source_system_id = 3
  AND per.first_name = 'Florent' AND per.last_name = 'Papuqi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Sandzak' AND t.source_system_id = 3
  AND per.first_name = 'Haris' AND per.last_name = 'Sabovic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Sandzak' AND t.source_system_id = 3
  AND per.first_name = 'Mirza' AND per.last_name = 'Sabovic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Sandzak' AND t.source_system_id = 3
  AND per.first_name = 'Gregorio' AND per.last_name = 'Sergio'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Sandzak' AND t.source_system_id = 3
  AND per.first_name = 'Daniel' AND per.last_name = 'Zholendz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Sandzak II' AND t.source_system_id = 3
  AND per.first_name = 'Dino' AND per.last_name = 'Bakovic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Sandzak II' AND t.source_system_id = 3
  AND per.first_name = 'Emir' AND per.last_name = 'Bakovic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Sandzak II' AND t.source_system_id = 3
  AND per.first_name = 'Alam' AND per.last_name = 'Bodrul'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Sandzak II' AND t.source_system_id = 3
  AND per.first_name = 'Mladen' AND per.last_name = 'Bomesrar'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Sandzak II' AND t.source_system_id = 3
  AND per.first_name = 'Samuel' AND per.last_name = 'Bunjaj'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Sandzak II' AND t.source_system_id = 3
  AND per.first_name = 'Medin' AND per.last_name = 'Cekic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Sandzak II' AND t.source_system_id = 3
  AND per.first_name = 'Dino' AND per.last_name = 'Dacic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Sandzak II' AND t.source_system_id = 3
  AND per.first_name = 'Darko' AND per.last_name = 'Drincic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Sandzak II' AND t.source_system_id = 3
  AND per.first_name = 'Safet' AND per.last_name = 'Dzaferovic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Sandzak II' AND t.source_system_id = 3
  AND per.first_name = 'Alija' AND per.last_name = 'Hodzic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Sandzak II' AND t.source_system_id = 3
  AND per.first_name = 'Mirza' AND per.last_name = 'Hot'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Sandzak II' AND t.source_system_id = 3
  AND per.first_name = 'Santos' AND per.last_name = 'Itzep'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Sandzak II' AND t.source_system_id = 3
  AND per.first_name = 'Asmir' AND per.last_name = 'Ivanovic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Sandzak II' AND t.source_system_id = 3
  AND per.first_name = 'Elmir' AND per.last_name = 'Mackic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Sandzak II' AND t.source_system_id = 3
  AND per.first_name = 'Ermin' AND per.last_name = 'Mackic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Sandzak II' AND t.source_system_id = 3
  AND per.first_name = 'Mersim' AND per.last_name = 'Mustafic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Sandzak II' AND t.source_system_id = 3
  AND per.first_name = 'Fadil' AND per.last_name = 'Paljevic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Sandzak II' AND t.source_system_id = 3
  AND per.first_name = 'Adis' AND per.last_name = 'Purisic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Sandzak II' AND t.source_system_id = 3
  AND per.first_name = 'Edin' AND per.last_name = 'Redzic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Sandzak II' AND t.source_system_id = 3
  AND per.first_name = 'Fero' AND per.last_name = 'Sabovic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Sandzak II' AND t.source_system_id = 3
  AND per.first_name = 'Bashkim' AND per.last_name = 'Saiti'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Sandzak II' AND t.source_system_id = 3
  AND per.first_name = 'Leutrim' AND per.last_name = 'Saiti'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Sandzak II' AND t.source_system_id = 3
  AND per.first_name = 'Sanel' AND per.last_name = 'Selmanovic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'FC Sandzak II' AND t.source_system_id = 3
  AND per.first_name = 'Ammar' AND per.last_name = 'Todic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
  AND per.first_name = 'Ash' AND per.last_name = 'Augustus'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
  AND per.first_name = 'Juan' AND per.last_name = 'Barrientos'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
  AND per.first_name = 'Daniel' AND per.last_name = 'Moeller Berg'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
  AND per.first_name = 'Zachary' AND per.last_name = 'Bible'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
  AND per.first_name = 'Christian' AND per.last_name = 'Buitrago Caceres'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
  AND per.first_name = 'Ian' AND per.last_name = 'Calcaterra'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
  AND per.first_name = 'Anthony' AND per.last_name = 'Carracino'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
  AND per.first_name = 'Aldahir' AND per.last_name = 'Cazun'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
  AND per.first_name = 'Kevin' AND per.last_name = 'Daniel'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
  AND per.first_name = 'Carlos' AND per.last_name = 'Del Monte Acero'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
  AND per.first_name = 'Philip' AND per.last_name = 'DiNardo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
  AND per.first_name = 'Peyton' AND per.last_name = 'Elder'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
  AND per.first_name = 'Colin' AND per.last_name = 'Furlong'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
  AND per.first_name = 'Jamar' AND per.last_name = 'Gayle'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
  AND per.first_name = 'Daniel' AND per.last_name = 'Herrera'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
  AND per.first_name = 'Mitchell' AND per.last_name = 'Hoffert'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
  AND per.first_name = 'Thomas' AND per.last_name = 'Lozowski'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
  AND per.first_name = 'Justinian' AND per.last_name = 'Michaels'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
  AND per.first_name = 'Ahmed' AND per.last_name = 'Moawad'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
  AND per.first_name = 'Brendan' AND per.last_name = 'Mulligan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
  AND per.first_name = 'Liem' AND per.last_name = 'Nguyen'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
  AND per.first_name = 'Daniel' AND per.last_name = 'Nunes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
  AND per.first_name = 'Enzo' AND per.last_name = 'Petrocelli'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
  AND per.first_name = 'Edward' AND per.last_name = 'Seaman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
  AND per.first_name = 'Theodore' AND per.last_name = 'Sisco-Tolomeo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
  AND per.first_name = 'Erik' AND per.last_name = 'Stahle'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
  AND per.first_name = 'Roni' AND per.last_name = 'Tcherniavski'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
  AND per.first_name = 'Timor' AND per.last_name = 'Tcherniavski'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 II' AND t.source_system_id = 3
  AND per.first_name = 'Cristian' AND per.last_name = 'Villanueva-Cavero'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
  AND per.first_name = 'Jason' AND per.last_name = 'Argueta'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
  AND per.first_name = 'Ali' AND per.last_name = 'Agil Aslami'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
  AND per.first_name = 'Mikhail' AND per.last_name = 'Attong'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
  AND per.first_name = 'Michael' AND per.last_name = 'Bartelli'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
  AND per.first_name = 'Julio' AND per.last_name = 'Bernal'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
  AND per.first_name = 'Philip' AND per.last_name = 'Cantave'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
  AND per.first_name = 'Jake' AND per.last_name = 'Ferrang'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
  AND per.first_name = 'Mayer' AND per.last_name = 'Gad'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
  AND per.first_name = 'Efe' AND per.last_name = 'Altu Kaynar'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
  AND per.first_name = 'Joe' AND per.last_name = 'Kelly'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
  AND per.first_name = 'Mutaz' AND per.last_name = 'Khalil'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
  AND per.first_name = 'Salar' AND per.last_name = 'Lashkari'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
  AND per.first_name = 'Jonathan' AND per.last_name = 'Lee'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
  AND per.first_name = 'Bryon' AND per.last_name = 'Lutin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
  AND per.first_name = 'Panteleimon' AND per.last_name = 'Manos'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
  AND per.first_name = 'Matthew' AND per.last_name = 'Mealha'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
  AND per.first_name = 'John' AND per.last_name = 'Nemri Jr.'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
  AND per.first_name = 'Julian' AND per.last_name = 'Ospina'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
  AND per.first_name = 'Dean' AND per.last_name = 'Patel'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
  AND per.first_name = 'Niall' AND per.last_name = 'Quinn'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
  AND per.first_name = 'Jesse' AND per.last_name = 'Ramirez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
  AND per.first_name = 'Michael' AND per.last_name = 'Rodriguez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
  AND per.first_name = 'Mark' AND per.last_name = 'Roussey'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
  AND per.first_name = 'Joseph' AND per.last_name = 'Rovelo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
  AND per.first_name = 'Connor' AND per.last_name = 'Ryan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
  AND per.first_name = 'Murat' AND per.last_name = 'Salik'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
  AND per.first_name = 'Michael' AND per.last_name = 'Schmidig'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
  AND per.first_name = 'Ryan' AND per.last_name = 'Schnabel'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
  AND per.first_name = 'Niklas' AND per.last_name = 'Stahle'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912 III' AND t.source_system_id = 3
  AND per.first_name = 'Zachary' AND per.last_name = 'Yesko'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kelmendi FC NY' AND t.source_system_id = 3
  AND per.first_name = 'Rocky' AND per.last_name = 'Bujaj'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kelmendi FC NY' AND t.source_system_id = 3
  AND per.first_name = 'Arber' AND per.last_name = 'Fizi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kelmendi FC NY' AND t.source_system_id = 3
  AND per.first_name = 'Mirdon' AND per.last_name = 'Habibaj'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kelmendi FC NY' AND t.source_system_id = 3
  AND per.first_name = 'Glorian' AND per.last_name = 'Hoxha'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kelmendi FC NY' AND t.source_system_id = 3
  AND per.first_name = 'Naim' AND per.last_name = 'Kurtovic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kelmendi FC NY' AND t.source_system_id = 3
  AND per.first_name = 'Valdrin' AND per.last_name = 'Lekocaj'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kelmendi FC NY' AND t.source_system_id = 3
  AND per.first_name = 'Agim' AND per.last_name = 'Mujaj'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kelmendi FC NY' AND t.source_system_id = 3
  AND per.first_name = 'Jurgen' AND per.last_name = 'Nacaj'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kelmendi FC NY' AND t.source_system_id = 3
  AND per.first_name = 'Eduard' AND per.last_name = 'Necaj'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kelmendi FC NY' AND t.source_system_id = 3
  AND per.first_name = 'Marino' AND per.last_name = 'Nuculovic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kelmendi FC NY' AND t.source_system_id = 3
  AND per.first_name = 'Xhek' AND per.last_name = 'Rragami'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kelmendi FC NY' AND t.source_system_id = 3
  AND per.first_name = 'Ensa' AND per.last_name = 'Sanneh'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kelmendi FC NY' AND t.source_system_id = 3
  AND per.first_name = 'Ylli' AND per.last_name = 'Sufaj'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kelmendi FC NY' AND t.source_system_id = 3
  AND per.first_name = 'Korab' AND per.last_name = 'Syla'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kelmendi FC NY' AND t.source_system_id = 3
  AND per.first_name = 'Armando' AND per.last_name = 'Vacaj'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kelmendi FC NY' AND t.source_system_id = 3
  AND per.first_name = 'Enis' AND per.last_name = 'Velia'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kelmendi FC NY II' AND t.source_system_id = 3
  AND per.first_name = 'Yusuf' AND per.last_name = 'Abdelmegid'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kelmendi FC NY II' AND t.source_system_id = 3
  AND per.first_name = 'Reiner' AND per.last_name = 'AT-Stath'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kelmendi FC NY II' AND t.source_system_id = 3
  AND per.first_name = 'Alfons' AND per.last_name = 'Bujaj'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kelmendi FC NY II' AND t.source_system_id = 3
  AND per.first_name = 'Marinel' AND per.last_name = 'Bunjaj'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kelmendi FC NY II' AND t.source_system_id = 3
  AND per.first_name = 'Agostin' AND per.last_name = 'Burimi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kelmendi FC NY II' AND t.source_system_id = 3
  AND per.first_name = 'Drissa' AND per.last_name = 'Dagnogo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kelmendi FC NY II' AND t.source_system_id = 3
  AND per.first_name = 'Cheik' AND per.last_name = 'Diakite'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kelmendi FC NY II' AND t.source_system_id = 3
  AND per.first_name = 'Manuel' AND per.last_name = 'Gjelaj'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kelmendi FC NY II' AND t.source_system_id = 3
  AND per.first_name = 'Marsel' AND per.last_name = 'Gjelaj'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kelmendi FC NY II' AND t.source_system_id = 3
  AND per.first_name = 'Elton' AND per.last_name = 'Kalaj'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kelmendi FC NY II' AND t.source_system_id = 3
  AND per.first_name = 'Valter' AND per.last_name = 'Kocaj'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kelmendi FC NY II' AND t.source_system_id = 3
  AND per.first_name = 'Amidou' AND per.last_name = 'Kone'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kelmendi FC NY II' AND t.source_system_id = 3
  AND per.first_name = 'Ibrahim' AND per.last_name = 'Kone'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kelmendi FC NY II' AND t.source_system_id = 3
  AND per.first_name = 'Anton' AND per.last_name = 'Lekocaj'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kelmendi FC NY II' AND t.source_system_id = 3
  AND per.first_name = 'Elvian' AND per.last_name = 'Lukovic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kelmendi FC NY II' AND t.source_system_id = 3
  AND per.first_name = 'Fatjon' AND per.last_name = 'Mitaj'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kelmendi FC NY II' AND t.source_system_id = 3
  AND per.first_name = 'Aliou' AND per.last_name = 'Ndiaye'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kelmendi FC NY II' AND t.source_system_id = 3
  AND per.first_name = 'Emirijan' AND per.last_name = 'Nekaj'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kelmendi FC NY II' AND t.source_system_id = 3
  AND per.first_name = 'Klodian' AND per.last_name = 'Nika'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kelmendi FC NY II' AND t.source_system_id = 3
  AND per.first_name = 'Lush' AND per.last_name = 'Pepushaj'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kelmendi FC NY II' AND t.source_system_id = 3
  AND per.first_name = 'Edmond' AND per.last_name = 'Pllumbaj'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kelmendi FC NY II' AND t.source_system_id = 3
  AND per.first_name = 'Sokol' AND per.last_name = 'Shqutaj'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kelmendi FC NY II' AND t.source_system_id = 3
  AND per.first_name = 'Alban' AND per.last_name = 'Smajlaj'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kelmendi FC NY II' AND t.source_system_id = 3
  AND per.first_name = 'Sokol' AND per.last_name = 'Smajlaj'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kelmendi FC NY II' AND t.source_system_id = 3
  AND per.first_name = 'Junior' AND per.last_name = 'Tchankwe'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kelmendi FC NY II' AND t.source_system_id = 3
  AND per.first_name = 'Ylli' AND per.last_name = 'Tinaj'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kelmendi FC NY II' AND t.source_system_id = 3
  AND per.first_name = 'Igli' AND per.last_name = 'Velcani'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kelmendi FC NY II' AND t.source_system_id = 3
  AND per.first_name = 'Valmir' AND per.last_name = 'Veseli'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kelmendi FC NY II' AND t.source_system_id = 3
  AND per.first_name = 'Etmir' AND per.last_name = 'Vukaj'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC II' AND t.source_system_id = 3
  AND per.first_name = 'Edgar' AND per.last_name = 'Aguilar'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC II' AND t.source_system_id = 3
  AND per.first_name = 'Kevin' AND per.last_name = 'Aguilar'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC II' AND t.source_system_id = 3
  AND per.first_name = 'Sadegh' AND per.last_name = 'Asgari'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC II' AND t.source_system_id = 3
  AND per.first_name = 'Naim' AND per.last_name = 'Bakere'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC II' AND t.source_system_id = 3
  AND per.first_name = 'Jehon' AND per.last_name = 'Balidemaj'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC II' AND t.source_system_id = 3
  AND per.first_name = 'Alieu' AND per.last_name = 'Barrie'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC II' AND t.source_system_id = 3
  AND per.first_name = 'Douglas' AND per.last_name = 'Carrasco'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC II' AND t.source_system_id = 3
  AND per.first_name = 'Jaime' AND per.last_name = 'Carrillo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC II' AND t.source_system_id = 3
  AND per.first_name = 'Ronaldo' AND per.last_name = 'Fatolou'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC II' AND t.source_system_id = 3
  AND per.first_name = 'Amadou' AND per.last_name = 'Fofana'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC II' AND t.source_system_id = 3
  AND per.first_name = 'Hameed' AND per.last_name = 'Gado'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC II' AND t.source_system_id = 3
  AND per.first_name = 'Gerson' AND per.last_name = 'Gonzalez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC II' AND t.source_system_id = 3
  AND per.first_name = 'Yarlen' AND per.last_name = 'Guity'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC II' AND t.source_system_id = 3
  AND per.first_name = 'Jonathan' AND per.last_name = 'Jackson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC II' AND t.source_system_id = 3
  AND per.first_name = 'Cheick' AND per.last_name = 'Kaba'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC II' AND t.source_system_id = 3
  AND per.first_name = 'Walker' AND per.last_name = 'Latham'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC II' AND t.source_system_id = 3
  AND per.first_name = 'Saul' AND per.last_name = 'Melendez-Hernandez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC II' AND t.source_system_id = 3
  AND per.first_name = 'Salu' AND per.last_name = 'Mohammed'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC II' AND t.source_system_id = 3
  AND per.first_name = 'Matthew' AND per.last_name = 'Mummert'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC II' AND t.source_system_id = 3
  AND per.first_name = 'Medoune' AND per.last_name = 'Ngom'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC II' AND t.source_system_id = 3
  AND per.first_name = 'Dustin' AND per.last_name = 'Ramirez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC II' AND t.source_system_id = 3
  AND per.first_name = 'Frankhel' AND per.last_name = 'Ramos'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC II' AND t.source_system_id = 3
  AND per.first_name = 'Caetano' AND per.last_name = 'Sanchez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC II' AND t.source_system_id = 3
  AND per.first_name = 'Vadim' AND per.last_name = 'Seliankin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC II' AND t.source_system_id = 3
  AND per.first_name = 'Ismael' AND per.last_name = 'Sorogo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC II' AND t.source_system_id = 3
  AND per.first_name = 'Dembo' AND per.last_name = 'Soussoko'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC II' AND t.source_system_id = 3
  AND per.first_name = 'Ismaila' AND per.last_name = 'Sy'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC II' AND t.source_system_id = 3
  AND per.first_name = 'Ndongo' AND per.last_name = 'Thiam'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC II' AND t.source_system_id = 3
  AND per.first_name = 'Tommy' AND per.last_name = 'Villena'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC II' AND t.source_system_id = 3
  AND per.first_name = 'Abdallah' AND per.last_name = 'Yamin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Laberia FC' AND t.source_system_id = 3
  AND per.first_name = 'Mikel' AND per.last_name = 'Agaraj'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Laberia FC' AND t.source_system_id = 3
  AND per.first_name = 'Enea' AND per.last_name = 'Canaj'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Laberia FC' AND t.source_system_id = 3
  AND per.first_name = 'Bryan' AND per.last_name = 'S. Cespedes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Laberia FC' AND t.source_system_id = 3
  AND per.first_name = 'Jacob' AND per.last_name = 'Chhetri'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Laberia FC' AND t.source_system_id = 3
  AND per.first_name = 'Francisco' AND per.last_name = 'Curipan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Laberia FC' AND t.source_system_id = 3
  AND per.first_name = 'Ervis' AND per.last_name = 'Dergjini'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Laberia FC' AND t.source_system_id = 3
  AND per.first_name = 'Alban' AND per.last_name = 'Dizdari'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Laberia FC' AND t.source_system_id = 3
  AND per.first_name = 'Andi' AND per.last_name = 'Filja'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Laberia FC' AND t.source_system_id = 3
  AND per.first_name = 'Kevin' AND per.last_name = 'Giraldo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Laberia FC' AND t.source_system_id = 3
  AND per.first_name = 'James' AND per.last_name = 'Gonzalez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Laberia FC' AND t.source_system_id = 3
  AND per.first_name = 'Sagar' AND per.last_name = 'Gurung'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Laberia FC' AND t.source_system_id = 3
  AND per.first_name = 'Juan' AND per.last_name = 'Higuita'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Laberia FC' AND t.source_system_id = 3
  AND per.first_name = 'Donald' AND per.last_name = 'Janku'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Laberia FC' AND t.source_system_id = 3
  AND per.first_name = 'Aurel' AND per.last_name = 'Katira'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Laberia FC' AND t.source_system_id = 3
  AND per.first_name = 'Salman' AND per.last_name = 'Khan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Laberia FC' AND t.source_system_id = 3
  AND per.first_name = 'Erzen' AND per.last_name = 'Kola'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Laberia FC' AND t.source_system_id = 3
  AND per.first_name = 'Sangpo' AND per.last_name = 'Kunga'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Laberia FC' AND t.source_system_id = 3
  AND per.first_name = 'Elton' AND per.last_name = 'Lalaj'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Laberia FC' AND t.source_system_id = 3
  AND per.first_name = 'Richard' AND per.last_name = 'Lalaj'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Laberia FC' AND t.source_system_id = 3
  AND per.first_name = 'Gerald' AND per.last_name = 'Lybershari'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Laberia FC' AND t.source_system_id = 3
  AND per.first_name = 'Felipe' AND per.last_name = 'Maidana Torres'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Laberia FC' AND t.source_system_id = 3
  AND per.first_name = 'Teon' AND per.last_name = 'Desraun Marcus'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Laberia FC' AND t.source_system_id = 3
  AND per.first_name = 'Ardit' AND per.last_name = 'Marku'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Laberia FC' AND t.source_system_id = 3
  AND per.first_name = 'Carlos' AND per.last_name = 'Melendez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Laberia FC' AND t.source_system_id = 3
  AND per.first_name = 'Benard' AND per.last_name = 'Millushi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Laberia FC' AND t.source_system_id = 3
  AND per.first_name = 'Juan' AND per.last_name = 'Moreno'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Laberia FC' AND t.source_system_id = 3
  AND per.first_name = 'Alexander' AND per.last_name = 'Parisel'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Laberia FC' AND t.source_system_id = 3
  AND per.first_name = 'Donald' AND per.last_name = 'Pepa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Laberia FC' AND t.source_system_id = 3
  AND per.first_name = 'Grendi' AND per.last_name = 'Rrasa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Laberia FC' AND t.source_system_id = 3
  AND per.first_name = 'Ermal' AND per.last_name = 'Sako'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Laberia FC' AND t.source_system_id = 3
  AND per.first_name = 'Elton' AND per.last_name = 'Skenderi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Laberia FC' AND t.source_system_id = 3
  AND per.first_name = 'Sandro' AND per.last_name = 'Tocaciu'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Laberia FC' AND t.source_system_id = 3
  AND per.first_name = 'Dolkar' AND per.last_name = 'Tsenkyap'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Laberia FC' AND t.source_system_id = 3
  AND per.first_name = 'XHULJO' AND per.last_name = 'TUSHI'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Laberia FC' AND t.source_system_id = 3
  AND per.first_name = 'Kriztian' AND per.last_name = 'Varga'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC Metro' AND t.source_system_id = 3
  AND per.first_name = 'Franco' AND per.last_name = 'Brandi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC Metro' AND t.source_system_id = 3
  AND per.first_name = 'James' AND per.last_name = 'Breen'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC Metro' AND t.source_system_id = 3
  AND per.first_name = 'Gary' AND per.last_name = 'Corless'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC Metro' AND t.source_system_id = 3
  AND per.first_name = 'Eoin' AND per.last_name = 'Curry'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC Metro' AND t.source_system_id = 3
  AND per.first_name = 'Niall' AND per.last_name = 'Daly Daly'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC Metro' AND t.source_system_id = 3
  AND per.first_name = 'Sean' AND per.last_name = 'Daly'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC Metro' AND t.source_system_id = 3
  AND per.first_name = 'Daniel' AND per.last_name = 'Fox'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC Metro' AND t.source_system_id = 3
  AND per.first_name = 'Prando' AND per.last_name = 'Gonzalo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC Metro' AND t.source_system_id = 3
  AND per.first_name = 'Richard' AND per.last_name = 'Hartnett'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC Metro' AND t.source_system_id = 3
  AND per.first_name = 'Conor' AND per.last_name = 'Higgins'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC Metro' AND t.source_system_id = 3
  AND per.first_name = 'Emmet' AND per.last_name = 'Hunter'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC Metro' AND t.source_system_id = 3
  AND per.first_name = 'Michael' AND per.last_name = 'Kaniatyn'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC Metro' AND t.source_system_id = 3
  AND per.first_name = 'Ryan' AND per.last_name = 'Kerley'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC Metro' AND t.source_system_id = 3
  AND per.first_name = 'Conor' AND per.last_name = 'Lynch'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC Metro' AND t.source_system_id = 3
  AND per.first_name = 'Dion' AND per.last_name = 'Norney'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC Metro' AND t.source_system_id = 3
  AND per.first_name = 'Michael' AND per.last_name = 'O''Driscoll'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC Metro' AND t.source_system_id = 3
  AND per.first_name = 'Timothy' AND per.last_name = 'O''Driscoll'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC Metro' AND t.source_system_id = 3
  AND per.first_name = 'David' AND per.last_name = 'Pond'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC Metro' AND t.source_system_id = 3
  AND per.first_name = 'Matias' AND per.last_name = 'Prando'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC Metro' AND t.source_system_id = 3
  AND per.first_name = 'Jermey' AND per.last_name = 'Schneider'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC Metro' AND t.source_system_id = 3
  AND per.first_name = 'Nicholas' AND per.last_name = 'Slevin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC Metro' AND t.source_system_id = 3
  AND per.first_name = 'Martin' AND per.last_name = 'Sutton'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC Metro' AND t.source_system_id = 3
  AND per.first_name = 'Aidan' AND per.last_name = 'Tansey'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC Metro' AND t.source_system_id = 3
  AND per.first_name = 'Mariglen' AND per.last_name = 'Verjoni'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
  AND per.first_name = 'Nikolai' AND per.last_name = 'Calder'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
  AND per.first_name = 'Luis' AND per.last_name = 'Chaparro'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
  AND per.first_name = 'Patrick' AND per.last_name = 'Conlon-Kvale'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
  AND per.first_name = 'Daniel' AND per.last_name = 'Cui'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
  AND per.first_name = 'Robert' AND per.last_name = 'DeStefano'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
  AND per.first_name = 'Sultan' AND per.last_name = 'Hausawi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
  AND per.first_name = 'Conor' AND per.last_name = 'Johnston'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
  AND per.first_name = 'Aaron' AND per.last_name = 'Kraus'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
  AND per.first_name = 'Jonathan' AND per.last_name = 'Leon'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
  AND per.first_name = 'Ben' AND per.last_name = 'Lorry'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
  AND per.first_name = 'Marques' AND per.last_name = 'Mayoras'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
  AND per.first_name = 'Santiago' AND per.last_name = 'Mendez Huergo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
  AND per.first_name = 'Edisson' AND per.last_name = 'Meza'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
  AND per.first_name = 'Mohamad' AND per.last_name = 'Miri'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
  AND per.first_name = 'Byron' AND per.last_name = 'O''Neill'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
  AND per.first_name = 'Amadou' AND per.last_name = 'Ousmane'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
  AND per.first_name = 'Luis' AND per.last_name = 'Perez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
  AND per.first_name = 'Alvise' AND per.last_name = 'Piazza'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
  AND per.first_name = 'Ryan' AND per.last_name = 'Piela'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
  AND per.first_name = 'Samuel' AND per.last_name = 'Puchalla'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
  AND per.first_name = 'Alex' AND per.last_name = 'Ruiz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
  AND per.first_name = 'Jamal' AND per.last_name = 'Sani'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
  AND per.first_name = 'Sohail' AND per.last_name = 'Shaker'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
  AND per.first_name = 'Joost-Olan' AND per.last_name = 'Sheehan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
  AND per.first_name = 'Brian' AND per.last_name = 'Simpson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
  AND per.first_name = 'Jeremy' AND per.last_name = 'Siwik'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
  AND per.first_name = 'Henry' AND per.last_name = 'Smith'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
  AND per.first_name = 'Cameron' AND per.last_name = 'Thacker'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic II' AND t.source_system_id = 3
  AND per.first_name = 'Takanori' AND per.last_name = 'Yoshizaki'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic III' AND t.source_system_id = 3
  AND per.first_name = 'Javokhir' AND per.last_name = 'Akhmadjonov'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic III' AND t.source_system_id = 3
  AND per.first_name = 'Muhanad' AND per.last_name = 'Ali'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic III' AND t.source_system_id = 3
  AND per.first_name = 'Steven' AND per.last_name = 'Bartkowski'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic III' AND t.source_system_id = 3
  AND per.first_name = 'Cullen' AND per.last_name = 'Brown'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic III' AND t.source_system_id = 3
  AND per.first_name = 'Travis' AND per.last_name = 'Bunt'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic III' AND t.source_system_id = 3
  AND per.first_name = 'Sebastián' AND per.last_name = 'Carpio'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic III' AND t.source_system_id = 3
  AND per.first_name = 'Kameron' AND per.last_name = 'Connell'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic III' AND t.source_system_id = 3
  AND per.first_name = 'Martin' AND per.last_name = 'Cordoba'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic III' AND t.source_system_id = 3
  AND per.first_name = 'Liborio' AND per.last_name = 'Cuellar'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic III' AND t.source_system_id = 3
  AND per.first_name = 'Ahmed' AND per.last_name = 'Fadl'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic III' AND t.source_system_id = 3
  AND per.first_name = 'Maxim' AND per.last_name = 'Fesenko'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic III' AND t.source_system_id = 3
  AND per.first_name = 'Hector' AND per.last_name = 'Gazca'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic III' AND t.source_system_id = 3
  AND per.first_name = 'Gregory' AND per.last_name = 'Green'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic III' AND t.source_system_id = 3
  AND per.first_name = 'Matt' AND per.last_name = 'Greene'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic III' AND t.source_system_id = 3
  AND per.first_name = 'Tariq' AND per.last_name = 'Hamid'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic III' AND t.source_system_id = 3
  AND per.first_name = 'James' AND per.last_name = 'Howell'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic III' AND t.source_system_id = 3
  AND per.first_name = 'Samuel' AND per.last_name = 'Kadejo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic III' AND t.source_system_id = 3
  AND per.first_name = 'Matthew' AND per.last_name = 'Kane'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic III' AND t.source_system_id = 3
  AND per.first_name = 'Kyungwan' AND per.last_name = 'Kang'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic III' AND t.source_system_id = 3
  AND per.first_name = 'Jacob' AND per.last_name = 'Kent'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic III' AND t.source_system_id = 3
  AND per.first_name = 'Kevin' AND per.last_name = 'Kerrigan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic III' AND t.source_system_id = 3
  AND per.first_name = 'Vitaliy' AND per.last_name = 'Khutko'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic III' AND t.source_system_id = 3
  AND per.first_name = 'Vincent' AND per.last_name = 'Moreno'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic III' AND t.source_system_id = 3
  AND per.first_name = 'Richard' AND per.last_name = 'Jason (Jake) Rowe'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic III' AND t.source_system_id = 3
  AND per.first_name = 'Ricardo' AND per.last_name = 'Ruiz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic III' AND t.source_system_id = 3
  AND per.first_name = 'Santiago' AND per.last_name = 'Ruiz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic III' AND t.source_system_id = 3
  AND per.first_name = 'Ammar' AND per.last_name = 'Shaker'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic III' AND t.source_system_id = 3
  AND per.first_name = 'Federico' AND per.last_name = 'Simmermacher'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic III' AND t.source_system_id = 3
  AND per.first_name = 'Kohei' AND per.last_name = 'Suga'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic III' AND t.source_system_id = 3
  AND per.first_name = 'John' AND per.last_name = 'Tanios'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic Masters' AND t.source_system_id = 3
  AND per.first_name = 'Itamar' AND per.last_name = 'Alpert'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic Masters' AND t.source_system_id = 3
  AND per.first_name = 'Emin' AND per.last_name = 'Avsar'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic Masters' AND t.source_system_id = 3
  AND per.first_name = 'Michael' AND per.last_name = 'Barrish'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic Masters' AND t.source_system_id = 3
  AND per.first_name = 'Dario' AND per.last_name = 'Cabanas'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic Masters' AND t.source_system_id = 3
  AND per.first_name = 'Valentin' AND per.last_name = 'Cadena-Acevedo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic Masters' AND t.source_system_id = 3
  AND per.first_name = 'Seth' AND per.last_name = 'Chernin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic Masters' AND t.source_system_id = 3
  AND per.first_name = 'Joseph' AND per.last_name = 'Franquinha'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic Masters' AND t.source_system_id = 3
  AND per.first_name = 'Josh' AND per.last_name = 'Freeman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic Masters' AND t.source_system_id = 3
  AND per.first_name = 'Jorge' AND per.last_name = 'Garcia'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic Masters' AND t.source_system_id = 3
  AND per.first_name = 'Jaime' AND per.last_name = 'Gonzalez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic Masters' AND t.source_system_id = 3
  AND per.first_name = 'Val' AND per.last_name = 'Gurariy'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic Masters' AND t.source_system_id = 3
  AND per.first_name = 'Wilmar' AND per.last_name = 'Jimenez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic Masters' AND t.source_system_id = 3
  AND per.first_name = 'Nicholas' AND per.last_name = 'Joseph'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic Masters' AND t.source_system_id = 3
  AND per.first_name = 'Boris' AND per.last_name = 'Kapelnik'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic Masters' AND t.source_system_id = 3
  AND per.first_name = 'Bryan' AND per.last_name = 'Lewis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic Masters' AND t.source_system_id = 3
  AND per.first_name = 'Paul' AND per.last_name = 'McLoughlin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic Masters' AND t.source_system_id = 3
  AND per.first_name = 'Hossam' AND per.last_name = 'Mohamed'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic Masters' AND t.source_system_id = 3
  AND per.first_name = 'Ernest' AND per.last_name = 'Murdukhayev'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic Masters' AND t.source_system_id = 3
  AND per.first_name = 'Rob' AND per.last_name = 'Olin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic Masters' AND t.source_system_id = 3
  AND per.first_name = 'Ari' AND per.last_name = 'Raisa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic Masters' AND t.source_system_id = 3
  AND per.first_name = 'Lawrence' AND per.last_name = 'Rice'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic Masters' AND t.source_system_id = 3
  AND per.first_name = 'Jonah' AND per.last_name = 'Rockoff'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic Masters' AND t.source_system_id = 3
  AND per.first_name = 'Jeffrey' AND per.last_name = 'Rothlein'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic Masters' AND t.source_system_id = 3
  AND per.first_name = 'Rustam' AND per.last_name = 'Sabirov'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic Masters' AND t.source_system_id = 3
  AND per.first_name = 'Felipe' AND per.last_name = 'Sanchez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic Masters' AND t.source_system_id = 3
  AND per.first_name = 'Ram' AND per.last_name = 'Sheves'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic Masters' AND t.source_system_id = 3
  AND per.first_name = 'Vadim' AND per.last_name = 'Slashchev'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic Masters' AND t.source_system_id = 3
  AND per.first_name = 'Leonid' AND per.last_name = 'Spitsyn'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Celtic Masters' AND t.source_system_id = 3
  AND per.first_name = 'Andrew' AND per.last_name = 'Woodbridge'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers' AND t.source_system_id = 3
  AND per.first_name = 'Shaiem' AND per.last_name = 'Allah-Morad'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers' AND t.source_system_id = 3
  AND per.first_name = 'Christopher' AND per.last_name = 'Amoruso'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers' AND t.source_system_id = 3
  AND per.first_name = 'Calvin' AND per.last_name = 'Aroh'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers' AND t.source_system_id = 3
  AND per.first_name = 'Bryan' AND per.last_name = 'Baracaldo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers' AND t.source_system_id = 3
  AND per.first_name = 'Liam' AND per.last_name = 'Bardong'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers' AND t.source_system_id = 3
  AND per.first_name = 'Nicholas' AND per.last_name = 'Edmo Bernhardt-Lanier'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers' AND t.source_system_id = 3
  AND per.first_name = 'Kyle' AND per.last_name = 'Brady'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers' AND t.source_system_id = 3
  AND per.first_name = 'Joseph' AND per.last_name = 'Braun'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers' AND t.source_system_id = 3
  AND per.first_name = 'Thomas' AND per.last_name = 'Dillmann'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers' AND t.source_system_id = 3
  AND per.first_name = 'Robert' AND per.last_name = 'Fabricant'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers' AND t.source_system_id = 3
  AND per.first_name = 'Jarod' AND per.last_name = 'Glover'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers' AND t.source_system_id = 3
  AND per.first_name = 'Amiran' AND per.last_name = 'Goguadze'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers' AND t.source_system_id = 3
  AND per.first_name = 'Soham' AND per.last_name = 'Kathuria'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers' AND t.source_system_id = 3
  AND per.first_name = 'Zachary-Michael' AND per.last_name = 'Lane'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers' AND t.source_system_id = 3
  AND per.first_name = 'Alexander' AND per.last_name = 'Martinez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers' AND t.source_system_id = 3
  AND per.first_name = 'William' AND per.last_name = 'McMillian'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers' AND t.source_system_id = 3
  AND per.first_name = 'Mohammad' AND per.last_name = 'Mohammadi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers' AND t.source_system_id = 3
  AND per.first_name = 'Brian' AND per.last_name = 'Morris'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers' AND t.source_system_id = 3
  AND per.first_name = 'Moctar' AND per.last_name = 'Niang'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers' AND t.source_system_id = 3
  AND per.first_name = 'Toric' AND per.last_name = 'Robinson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers' AND t.source_system_id = 3
  AND per.first_name = 'Brett' AND per.last_name = 'Rojas'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers' AND t.source_system_id = 3
  AND per.first_name = 'Raihan' AND per.last_name = 'Siddiqui'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers' AND t.source_system_id = 3
  AND per.first_name = 'Drew' AND per.last_name = 'Stern'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers' AND t.source_system_id = 3
  AND per.first_name = 'Jean' AND per.last_name = 'Baptiste Tamas Leloup'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers' AND t.source_system_id = 3
  AND per.first_name = 'Matthew' AND per.last_name = 'Tidona'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers' AND t.source_system_id = 3
  AND per.first_name = 'Khriswayne' AND per.last_name = 'Wallace'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers' AND t.source_system_id = 3
  AND per.first_name = 'Jordan' AND per.last_name = 'Williams'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers' AND t.source_system_id = 3
  AND per.first_name = 'Benjamin' AND per.last_name = 'Yabrow'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers Legends' AND t.source_system_id = 3
  AND per.first_name = 'Kevin' AND per.last_name = 'Adamson-Jackes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers Legends' AND t.source_system_id = 3
  AND per.first_name = 'Wale' AND per.last_name = 'Bakare'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers Legends' AND t.source_system_id = 3
  AND per.first_name = 'Arien' AND per.last_name = 'Berlowitz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers Legends' AND t.source_system_id = 3
  AND per.first_name = 'Dylan' AND per.last_name = 'Dodd'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers Legends' AND t.source_system_id = 3
  AND per.first_name = 'Dave' AND per.last_name = 'Dupuy'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers Legends' AND t.source_system_id = 3
  AND per.first_name = 'Peter' AND per.last_name = 'Finn'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers Legends' AND t.source_system_id = 3
  AND per.first_name = 'Mike' AND per.last_name = 'FitzGerald'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers Legends' AND t.source_system_id = 3
  AND per.first_name = 'Eddie' AND per.last_name = 'Yee Woo Guo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers Legends' AND t.source_system_id = 3
  AND per.first_name = 'Ardian' AND per.last_name = 'Hasko'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers Legends' AND t.source_system_id = 3
  AND per.first_name = 'Christian' AND per.last_name = 'Huguenot'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers Legends' AND t.source_system_id = 3
  AND per.first_name = 'Oscar' AND per.last_name = 'Martinez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers Legends' AND t.source_system_id = 3
  AND per.first_name = 'Jeffrey' AND per.last_name = 'Mateo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers Legends' AND t.source_system_id = 3
  AND per.first_name = 'Mike' AND per.last_name = 'Michelini'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers Legends' AND t.source_system_id = 3
  AND per.first_name = 'Khouri' AND per.last_name = 'Mullings'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers Legends' AND t.source_system_id = 3
  AND per.first_name = 'Wilson' AND per.last_name = 'Pun'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers Legends' AND t.source_system_id = 3
  AND per.first_name = 'Dan' AND per.last_name = 'Segelin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers Legends' AND t.source_system_id = 3
  AND per.first_name = 'John' AND per.last_name = 'Slover'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers Legends' AND t.source_system_id = 3
  AND per.first_name = 'Victor' AND per.last_name = 'Vergara'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers Legends' AND t.source_system_id = 3
  AND per.first_name = 'JESSE' AND per.last_name = 'MARK VOZICK'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers Legends' AND t.source_system_id = 3
  AND per.first_name = 'Joe' AND per.last_name = 'Whiteman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers Legends' AND t.source_system_id = 3
  AND per.first_name = 'Jake' AND per.last_name = 'Wilhelmsen.'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers Legends' AND t.source_system_id = 3
  AND per.first_name = 'Jeffery' AND per.last_name = 'Zaborski'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers II' AND t.source_system_id = 3
  AND per.first_name = 'Zacharie' AND per.last_name = 'Adams'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers II' AND t.source_system_id = 3
  AND per.first_name = 'Austin' AND per.last_name = 'Cayman Betterly'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers II' AND t.source_system_id = 3
  AND per.first_name = 'Christian' AND per.last_name = 'Kop Bordin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers II' AND t.source_system_id = 3
  AND per.first_name = 'Christian' AND per.last_name = 'Thomas Buechel'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers II' AND t.source_system_id = 3
  AND per.first_name = 'Pierre' AND per.last_name = 'Chen'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers II' AND t.source_system_id = 3
  AND per.first_name = 'Pedro' AND per.last_name = 'De Sa Resende'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers II' AND t.source_system_id = 3
  AND per.first_name = 'Thomas' AND per.last_name = 'Fitzpatrick'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers II' AND t.source_system_id = 3
  AND per.first_name = 'Thomas' AND per.last_name = 'Herlihy'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers II' AND t.source_system_id = 3
  AND per.first_name = 'Jared' AND per.last_name = 'Hirschowitz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers II' AND t.source_system_id = 3
  AND per.first_name = 'Almir' AND per.last_name = 'Hot'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers II' AND t.source_system_id = 3
  AND per.first_name = 'Jerremy' AND per.last_name = 'Jean'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers II' AND t.source_system_id = 3
  AND per.first_name = 'Jens' AND per.last_name = 'Jorgensen'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers II' AND t.source_system_id = 3
  AND per.first_name = 'Jomar' AND per.last_name = 'Joseph'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers II' AND t.source_system_id = 3
  AND per.first_name = 'Dennis' AND per.last_name = 'Kachintsev'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers II' AND t.source_system_id = 3
  AND per.first_name = 'Ali' AND per.last_name = 'Mannan Kapasi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers II' AND t.source_system_id = 3
  AND per.first_name = 'Zachary' AND per.last_name = 'Grant Kohn'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers II' AND t.source_system_id = 3
  AND per.first_name = 'Lodewijck' AND per.last_name = 'Kuijpers'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers II' AND t.source_system_id = 3
  AND per.first_name = 'Giovani' AND per.last_name = 'LoMonaco'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers II' AND t.source_system_id = 3
  AND per.first_name = 'Senan' AND per.last_name = 'Lonergan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers II' AND t.source_system_id = 3
  AND per.first_name = 'Jules' AND per.last_name = 'Malen'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers II' AND t.source_system_id = 3
  AND per.first_name = 'Hugo' AND per.last_name = 'Marteau'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers II' AND t.source_system_id = 3
  AND per.first_name = 'Fionn' AND per.last_name = 'O Riain'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers II' AND t.source_system_id = 3
  AND per.first_name = 'Ebrahim' AND per.last_name = 'Ramos'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers II' AND t.source_system_id = 3
  AND per.first_name = 'Antonio' AND per.last_name = 'Ruiz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers II' AND t.source_system_id = 3
  AND per.first_name = 'Ryan' AND per.last_name = 'Schneider'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers II' AND t.source_system_id = 3
  AND per.first_name = 'Lukas' AND per.last_name = 'Seebacher'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers II' AND t.source_system_id = 3
  AND per.first_name = 'Clyde' AND per.last_name = 'Robert Staley'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan Kickers II' AND t.source_system_id = 3
  AND per.first_name = 'Jesse' AND per.last_name = 'Weisberg'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC' AND t.source_system_id = 3
  AND per.first_name = 'Divar' AND per.last_name = 'Aquino'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC' AND t.source_system_id = 3
  AND per.first_name = 'Omar' AND per.last_name = 'Aragon'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC' AND t.source_system_id = 3
  AND per.first_name = 'Capy' AND per.last_name = 'Charles'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC' AND t.source_system_id = 3
  AND per.first_name = 'Brandy' AND per.last_name = 'Cineas'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC' AND t.source_system_id = 3
  AND per.first_name = 'Saul' AND per.last_name = 'E Corado'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC' AND t.source_system_id = 3
  AND per.first_name = 'Kenderson' AND per.last_name = 'Delice'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC' AND t.source_system_id = 3
  AND per.first_name = 'Junior' AND per.last_name = 'Florent'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC' AND t.source_system_id = 3
  AND per.first_name = 'Fidel' AND per.last_name = 'Safora Gonzalez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC' AND t.source_system_id = 3
  AND per.first_name = 'Julinho' AND per.last_name = 'Gustave'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC' AND t.source_system_id = 3
  AND per.first_name = 'Kevin' AND per.last_name = 'Noel Hernandez Sandoval'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC' AND t.source_system_id = 3
  AND per.first_name = 'Loovensky' AND per.last_name = 'Jean'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC' AND t.source_system_id = 3
  AND per.first_name = 'Coby' AND per.last_name = 'handy Jean Rodriguez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC' AND t.source_system_id = 3
  AND per.first_name = 'Keller,' AND per.last_name = 'Isnael Lalin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC' AND t.source_system_id = 3
  AND per.first_name = 'Oliver' AND per.last_name = 'Rosa Eduardo Mata'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC' AND t.source_system_id = 3
  AND per.first_name = 'George' AND per.last_name = 'Ishak Farid Mikhail'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC' AND t.source_system_id = 3
  AND per.first_name = 'Rohan' AND per.last_name = 'George Nelson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC' AND t.source_system_id = 3
  AND per.first_name = 'Woody' AND per.last_name = 'Occeant'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC' AND t.source_system_id = 3
  AND per.first_name = 'Chris' AND per.last_name = 'W Pierre'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC' AND t.source_system_id = 3
  AND per.first_name = 'Patrick' AND per.last_name = 'Pierre'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC' AND t.source_system_id = 3
  AND per.first_name = 'Samy' AND per.last_name = 'Raymond'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC' AND t.source_system_id = 3
  AND per.first_name = 'Andi' AND per.last_name = 'Donal Rojas Fuentes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC' AND t.source_system_id = 3
  AND per.first_name = 'Karlyl' AND per.last_name = 'Simon'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC' AND t.source_system_id = 3
  AND per.first_name = 'Woolf' AND per.last_name = 'Suprice'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC' AND t.source_system_id = 3
  AND per.first_name = 'Alexander' AND per.last_name = 'Jason Taylor'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC' AND t.source_system_id = 3
  AND per.first_name = 'Djovanny' AND per.last_name = 'Therasse'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC' AND t.source_system_id = 3
  AND per.first_name = 'Chery' AND per.last_name = 'Tingly'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC II' AND t.source_system_id = 3
  AND per.first_name = 'Benjamin' AND per.last_name = 'Alexandre'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC II' AND t.source_system_id = 3
  AND per.first_name = 'Davens' AND per.last_name = 'Alexis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC II' AND t.source_system_id = 3
  AND per.first_name = 'Joseph' AND per.last_name = 'Anderson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC II' AND t.source_system_id = 3
  AND per.first_name = 'Maximo' AND per.last_name = 'David Andrade Loyos'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC II' AND t.source_system_id = 3
  AND per.first_name = 'Alpotchino' AND per.last_name = 'M Andre'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC II' AND t.source_system_id = 3
  AND per.first_name = 'Cowendy' AND per.last_name = 'Augustin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC II' AND t.source_system_id = 3
  AND per.first_name = 'Ranchy' AND per.last_name = 'Augustin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC II' AND t.source_system_id = 3
  AND per.first_name = 'Jose' AND per.last_name = 'Manuel Caballeros Alonzo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC II' AND t.source_system_id = 3
  AND per.first_name = 'Steeve' AND per.last_name = 'Cadet'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC II' AND t.source_system_id = 3
  AND per.first_name = 'Junior' AND per.last_name = 'Cyprien'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC II' AND t.source_system_id = 3
  AND per.first_name = 'Fritz' AND per.last_name = 'Robert Desir'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC II' AND t.source_system_id = 3
  AND per.first_name = 'Kenley' AND per.last_name = 'Domond'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC II' AND t.source_system_id = 3
  AND per.first_name = 'Jean' AND per.last_name = 'Dume'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC II' AND t.source_system_id = 3
  AND per.first_name = 'Cedric' AND per.last_name = 'Fleuristin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC II' AND t.source_system_id = 3
  AND per.first_name = 'Heinrich' AND per.last_name = 'Jean Francois'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC II' AND t.source_system_id = 3
  AND per.first_name = 'Jameson' AND per.last_name = 'Jolimau'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC II' AND t.source_system_id = 3
  AND per.first_name = 'Davidson' AND per.last_name = 'Louis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC II' AND t.source_system_id = 3
  AND per.first_name = 'Christopher' AND per.last_name = 'Ariel Medina'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC II' AND t.source_system_id = 3
  AND per.first_name = 'Jimy' AND per.last_name = 'Micourt'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC II' AND t.source_system_id = 3
  AND per.first_name = 'Jose' AND per.last_name = 'Gabriel Morataya'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC II' AND t.source_system_id = 3
  AND per.first_name = 'Jean' AND per.last_name = 'Raymond Occil'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC II' AND t.source_system_id = 3
  AND per.first_name = 'Dachy' AND per.last_name = 'Ocvil'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC II' AND t.source_system_id = 3
  AND per.first_name = 'Eddy' AND per.last_name = 'Previl'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC II' AND t.source_system_id = 3
  AND per.first_name = 'Kensy' AND per.last_name = 'Prevot'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC II' AND t.source_system_id = 3
  AND per.first_name = 'Gregory' AND per.last_name = 'Remedor'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC II' AND t.source_system_id = 3
  AND per.first_name = 'Dany' AND per.last_name = 'Ridore'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC II' AND t.source_system_id = 3
  AND per.first_name = 'Weedmerlyn' AND per.last_name = 'Hall-Marvens Saintilus'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC II' AND t.source_system_id = 3
  AND per.first_name = 'Fredy' AND per.last_name = 'Jesus Salazar'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC II' AND t.source_system_id = 3
  AND per.first_name = 'Edwin' AND per.last_name = 'Franklin Santos'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Missile FC II' AND t.source_system_id = 3
  AND per.first_name = 'Valdo' AND per.last_name = 'Simon'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Albanians FC' AND t.source_system_id = 3
  AND per.first_name = 'Ledjon' AND per.last_name = 'Agaraj'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Albanians FC' AND t.source_system_id = 3
  AND per.first_name = 'Emanuel' AND per.last_name = 'Ara'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Albanians FC' AND t.source_system_id = 3
  AND per.first_name = 'Ferdi' AND per.last_name = 'Bori'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Albanians FC' AND t.source_system_id = 3
  AND per.first_name = 'Florjan' AND per.last_name = 'Delija'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Albanians FC' AND t.source_system_id = 3
  AND per.first_name = 'Raul' AND per.last_name = 'Eduardo Mainato Dutan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Albanians FC' AND t.source_system_id = 3
  AND per.first_name = 'Marian' AND per.last_name = 'Gjini'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Albanians FC' AND t.source_system_id = 3
  AND per.first_name = 'Vicens' AND per.last_name = 'Gjoka'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Albanians FC' AND t.source_system_id = 3
  AND per.first_name = 'Gasper' AND per.last_name = 'Gjokaj'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Albanians FC' AND t.source_system_id = 3
  AND per.first_name = 'Daniel' AND per.last_name = 'Hasaj'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Albanians FC' AND t.source_system_id = 3
  AND per.first_name = 'Elis' AND per.last_name = 'Hasalla'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Albanians FC' AND t.source_system_id = 3
  AND per.first_name = 'Alexander' AND per.last_name = 'Haxhari'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Albanians FC' AND t.source_system_id = 3
  AND per.first_name = 'Altin' AND per.last_name = 'Haxhari'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Albanians FC' AND t.source_system_id = 3
  AND per.first_name = 'Adrian' AND per.last_name = 'Kabashi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Albanians FC' AND t.source_system_id = 3
  AND per.first_name = 'Marinel' AND per.last_name = 'Kalaj'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Albanians FC' AND t.source_system_id = 3
  AND per.first_name = 'Fadjol' AND per.last_name = 'Kola'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Albanians FC' AND t.source_system_id = 3
  AND per.first_name = 'Ergi' AND per.last_name = 'Kurti'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Albanians FC' AND t.source_system_id = 3
  AND per.first_name = 'Elton' AND per.last_name = 'Mone'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Albanians FC' AND t.source_system_id = 3
  AND per.first_name = 'Elson' AND per.last_name = 'Ndreka'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Albanians FC' AND t.source_system_id = 3
  AND per.first_name = 'Aleksander' AND per.last_name = 'Peci'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Albanians FC' AND t.source_system_id = 3
  AND per.first_name = 'Arben' AND per.last_name = 'Pjetrushaj'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Albanians FC' AND t.source_system_id = 3
  AND per.first_name = 'Andy' AND per.last_name = 'pllumbi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Albanians FC' AND t.source_system_id = 3
  AND per.first_name = 'Klaudio' AND per.last_name = 'Shala'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Albanians FC' AND t.source_system_id = 3
  AND per.first_name = 'Robert' AND per.last_name = 'Syku'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Albanians FC' AND t.source_system_id = 3
  AND per.first_name = 'Georgios' AND per.last_name = 'Tsano'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 3
  AND per.first_name = 'Franciso' AND per.last_name = 'Agrest'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 3
  AND per.first_name = 'Nike' AND per.last_name = 'Azuma'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 3
  AND per.first_name = 'Alex' AND per.last_name = 'Bangeri'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 3
  AND per.first_name = 'Nick' AND per.last_name = 'Bartels'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 3
  AND per.first_name = 'Robert' AND per.last_name = 'Caronia'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 3
  AND per.first_name = 'Eric' AND per.last_name = 'Chang'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 3
  AND per.first_name = 'Stephen' AND per.last_name = 'Chapman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 3
  AND per.first_name = 'Aiden' AND per.last_name = 'Conaghan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 3
  AND per.first_name = 'Mathew' AND per.last_name = 'Contino'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 3
  AND per.first_name = 'Kevin' AND per.last_name = 'Davis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 3
  AND per.first_name = 'Jacob' AND per.last_name = 'Denison'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 3
  AND per.first_name = 'Keenan' AND per.last_name = 'Foley'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 3
  AND per.first_name = 'Timoney' AND per.last_name = 'Ford'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 3
  AND per.first_name = 'Kevin' AND per.last_name = 'Gil'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 3
  AND per.first_name = 'Stephanos' AND per.last_name = 'Hondrakis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 3
  AND per.first_name = 'Nicolas' AND per.last_name = 'Jandeleit'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 3
  AND per.first_name = 'Noah' AND per.last_name = 'Kossoff'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 3
  AND per.first_name = 'Aaron' AND per.last_name = 'Kovar'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 3
  AND per.first_name = 'Daniel' AND per.last_name = 'Larenetto'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 3
  AND per.first_name = 'Vana' AND per.last_name = 'Markarian'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 3
  AND per.first_name = 'Matt' AND per.last_name = 'Mbamelu'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 3
  AND per.first_name = 'Rafik' AND per.last_name = 'Mekhaldi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 3
  AND per.first_name = 'Lyman' AND per.last_name = 'Missimer'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 3
  AND per.first_name = 'Peter' AND per.last_name = 'Nolan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 3
  AND per.first_name = 'Kynan' AND per.last_name = 'Rocks'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 3
  AND per.first_name = 'Anthony' AND per.last_name = 'Rozmus'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 3
  AND per.first_name = 'Benjamin' AND per.last_name = 'Steen'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 3
  AND per.first_name = 'Matthew' AND per.last_name = 'Swain'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 3
  AND per.first_name = 'Connor' AND per.last_name = 'Willings'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 3
  AND per.first_name = 'Gabriel' AND per.last_name = 'Wirz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club II' AND t.source_system_id = 3
  AND per.first_name = 'Hugo' AND per.last_name = 'Artigas'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club II' AND t.source_system_id = 3
  AND per.first_name = 'Daniel' AND per.last_name = 'Barreira'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club II' AND t.source_system_id = 3
  AND per.first_name = 'Henry' AND per.last_name = 'Carey'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club II' AND t.source_system_id = 3
  AND per.first_name = 'Elliot' AND per.last_name = 'Cohen'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club II' AND t.source_system_id = 3
  AND per.first_name = 'Mario' AND per.last_name = 'Collaro'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club II' AND t.source_system_id = 3
  AND per.first_name = 'Richard' AND per.last_name = 'deVilliers'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club II' AND t.source_system_id = 3
  AND per.first_name = 'Aditya' AND per.last_name = 'Dias'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club II' AND t.source_system_id = 3
  AND per.first_name = 'Boubacar' AND per.last_name = 'Diatta'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club II' AND t.source_system_id = 3
  AND per.first_name = 'Vasilios' AND per.last_name = 'Dimopoulos'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club II' AND t.source_system_id = 3
  AND per.first_name = 'Scott' AND per.last_name = 'Enman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club II' AND t.source_system_id = 3
  AND per.first_name = 'Patrick' AND per.last_name = 'Figgie'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club II' AND t.source_system_id = 3
  AND per.first_name = 'Michael' AND per.last_name = 'Grasso'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club II' AND t.source_system_id = 3
  AND per.first_name = 'Octavien' AND per.last_name = 'Han'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club II' AND t.source_system_id = 3
  AND per.first_name = 'Jacob' AND per.last_name = 'Hess'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club II' AND t.source_system_id = 3
  AND per.first_name = 'Yoshio' AND per.last_name = 'Ishikawa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club II' AND t.source_system_id = 3
  AND per.first_name = 'Luke' AND per.last_name = 'Kazmierczak'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club II' AND t.source_system_id = 3
  AND per.first_name = 'Pape' AND per.last_name = 'Kromah'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club II' AND t.source_system_id = 3
  AND per.first_name = 'John' AND per.last_name = 'Leisman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club II' AND t.source_system_id = 3
  AND per.first_name = 'Yair' AND per.last_name = 'Levy'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club II' AND t.source_system_id = 3
  AND per.first_name = 'Yiannis' AND per.last_name = 'Mallios'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club II' AND t.source_system_id = 3
  AND per.first_name = 'Jake' AND per.last_name = 'Mancini'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club II' AND t.source_system_id = 3
  AND per.first_name = 'Jake' AND per.last_name = 'Mann'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club II' AND t.source_system_id = 3
  AND per.first_name = 'Florian' AND per.last_name = 'Meisenberg'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club II' AND t.source_system_id = 3
  AND per.first_name = 'Shawn' AND per.last_name = 'Pereira'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club II' AND t.source_system_id = 3
  AND per.first_name = 'Patrick' AND per.last_name = 'Pierre'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club II' AND t.source_system_id = 3
  AND per.first_name = 'Bill' AND per.last_name = 'Saporito'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club II' AND t.source_system_id = 3
  AND per.first_name = 'Henry' AND per.last_name = 'Stutz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club II' AND t.source_system_id = 3
  AND per.first_name = 'Herv?' AND per.last_name = 'Valcourt'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club II' AND t.source_system_id = 3
  AND per.first_name = 'Tom' AND per.last_name = 'Wallenstein'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club II' AND t.source_system_id = 3
  AND per.first_name = 'Andre' AND per.last_name = 'Wilkinson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Croatia' AND t.source_system_id = 3
  AND per.first_name = 'Fabian' AND per.last_name = 'Alarcon'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Croatia' AND t.source_system_id = 3
  AND per.first_name = 'Julio' AND per.last_name = 'Alexandre'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Croatia' AND t.source_system_id = 3
  AND per.first_name = 'Patrick' AND per.last_name = 'Alfaro-Gomez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Croatia' AND t.source_system_id = 3
  AND per.first_name = 'Mostafa' AND per.last_name = 'Anan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Croatia' AND t.source_system_id = 3
  AND per.first_name = 'Tazwar' AND per.last_name = 'Belal'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Croatia' AND t.source_system_id = 3
  AND per.first_name = 'Santosh' AND per.last_name = 'Birdja'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Croatia' AND t.source_system_id = 3
  AND per.first_name = 'Haralambos' AND per.last_name = 'Efstathopoulos'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Croatia' AND t.source_system_id = 3
  AND per.first_name = 'Mohamed' AND per.last_name = 'Elfaham'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Croatia' AND t.source_system_id = 3
  AND per.first_name = 'Omar' AND per.last_name = 'Elfaham'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Croatia' AND t.source_system_id = 3
  AND per.first_name = 'Nicholas' AND per.last_name = 'Fazio'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Croatia' AND t.source_system_id = 3
  AND per.first_name = 'Alexander' AND per.last_name = 'Macias'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Croatia' AND t.source_system_id = 3
  AND per.first_name = 'Luke' AND per.last_name = 'Mangiameli'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Croatia' AND t.source_system_id = 3
  AND per.first_name = 'Gabrielle' AND per.last_name = 'Manzanero'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Croatia' AND t.source_system_id = 3
  AND per.first_name = 'Michael' AND per.last_name = 'Mavra'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Croatia' AND t.source_system_id = 3
  AND per.first_name = 'Tasin' AND per.last_name = 'Mohammad'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Croatia' AND t.source_system_id = 3
  AND per.first_name = 'Carlos' AND per.last_name = 'Ocana'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Croatia' AND t.source_system_id = 3
  AND per.first_name = 'Vinai' AND per.last_name = 'Parmessar'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Croatia' AND t.source_system_id = 3
  AND per.first_name = 'Marc' AND per.last_name = 'Pavich'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Croatia' AND t.source_system_id = 3
  AND per.first_name = 'Arib' AND per.last_name = 'Rahman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Croatia' AND t.source_system_id = 3
  AND per.first_name = 'Matthew' AND per.last_name = 'Recupero'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Croatia' AND t.source_system_id = 3
  AND per.first_name = 'Bryan' AND per.last_name = 'Reinah'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Croatia' AND t.source_system_id = 3
  AND per.first_name = 'Andrew' AND per.last_name = 'Rugel'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Croatia' AND t.source_system_id = 3
  AND per.first_name = 'Matthew' AND per.last_name = 'Sikiric'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Croatia' AND t.source_system_id = 3
  AND per.first_name = 'Charles' AND per.last_name = 'Taibi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Croatia' AND t.source_system_id = 3
  AND per.first_name = 'Rosario' AND per.last_name = 'Troia'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Croatia' AND t.source_system_id = 3
  AND per.first_name = 'Camillo' AND per.last_name = 'Villacis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Galicia' AND t.source_system_id = 3
  AND per.first_name = 'Jesus' AND per.last_name = 'Alvarez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Galicia' AND t.source_system_id = 3
  AND per.first_name = 'Leonel' AND per.last_name = 'Aracena Neira'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Galicia' AND t.source_system_id = 3
  AND per.first_name = 'Pablo' AND per.last_name = 'Esono Bakale'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Galicia' AND t.source_system_id = 3
  AND per.first_name = 'Pere' AND per.last_name = 'Bosquet Llop'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Galicia' AND t.source_system_id = 3
  AND per.first_name = 'Jonathan' AND per.last_name = '"Jon" Burgos'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Galicia' AND t.source_system_id = 3
  AND per.first_name = 'Daniel' AND per.last_name = 'Clemente'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Galicia' AND t.source_system_id = 3
  AND per.first_name = 'Santiago' AND per.last_name = 'Coelho'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Galicia' AND t.source_system_id = 3
  AND per.first_name = 'Benjamin' AND per.last_name = 'Cuadra'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Galicia' AND t.source_system_id = 3
  AND per.first_name = 'Nicolas' AND per.last_name = 'Garcia'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Galicia' AND t.source_system_id = 3
  AND per.first_name = 'Ricardo' AND per.last_name = 'Garcia'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Galicia' AND t.source_system_id = 3
  AND per.first_name = 'Eddie' AND per.last_name = 'Lijo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Galicia' AND t.source_system_id = 3
  AND per.first_name = 'Javier' AND per.last_name = 'Marcos'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Galicia' AND t.source_system_id = 3
  AND per.first_name = 'Allan' AND per.last_name = 'Marquez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Galicia' AND t.source_system_id = 3
  AND per.first_name = 'Juan' AND per.last_name = 'Martínez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Galicia' AND t.source_system_id = 3
  AND per.first_name = 'Borja' AND per.last_name = 'Martinez Laredo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Galicia' AND t.source_system_id = 3
  AND per.first_name = 'Matthew' AND per.last_name = 'McDonnell'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Galicia' AND t.source_system_id = 3
  AND per.first_name = 'Jorge' AND per.last_name = 'Montero'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Galicia' AND t.source_system_id = 3
  AND per.first_name = 'Danny' AND per.last_name = 'Mora'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Galicia' AND t.source_system_id = 3
  AND per.first_name = 'Anthony' AND per.last_name = 'Moreira'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Galicia' AND t.source_system_id = 3
  AND per.first_name = 'Miguel' AND per.last_name = 'Ángel Nsang'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Galicia' AND t.source_system_id = 3
  AND per.first_name = 'Nicolás' AND per.last_name = 'Polo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Galicia' AND t.source_system_id = 3
  AND per.first_name = 'Alex' AND per.last_name = 'Rabell'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Galicia' AND t.source_system_id = 3
  AND per.first_name = 'Brais' AND per.last_name = 'Revalderia'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Galicia' AND t.source_system_id = 3
  AND per.first_name = 'Andres' AND per.last_name = 'Reyes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Galicia' AND t.source_system_id = 3
  AND per.first_name = 'Lucas' AND per.last_name = 'Riaño Avanzini'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Galicia' AND t.source_system_id = 3
  AND per.first_name = 'Cristobal' AND per.last_name = 'Rivera'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Galicia' AND t.source_system_id = 3
  AND per.first_name = 'Marc' AND per.last_name = 'Roura'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Galicia' AND t.source_system_id = 3
  AND per.first_name = 'Guillermo' AND per.last_name = 'Santamaria'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Galicia' AND t.source_system_id = 3
  AND per.first_name = 'Justin' AND per.last_name = 'Stuhr'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Galicia' AND t.source_system_id = 3
  AND per.first_name = 'Hugo' AND per.last_name = 'Urgiles'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC' AND t.source_system_id = 3
  AND per.first_name = 'Joshua' AND per.last_name = 'Adejokun'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC' AND t.source_system_id = 3
  AND per.first_name = 'Osama' AND per.last_name = 'Al Sahybi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC' AND t.source_system_id = 3
  AND per.first_name = 'Eric' AND per.last_name = 'Anderson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC' AND t.source_system_id = 3
  AND per.first_name = 'Galal' AND per.last_name = 'Bichara'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC' AND t.source_system_id = 3
  AND per.first_name = 'Dan' AND per.last_name = 'Cohen'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC' AND t.source_system_id = 3
  AND per.first_name = 'Joshua' AND per.last_name = 'Dutosme'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC' AND t.source_system_id = 3
  AND per.first_name = 'Mouhamadou' AND per.last_name = 'Fall'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC' AND t.source_system_id = 3
  AND per.first_name = 'Aaron' AND per.last_name = 'Forde'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC' AND t.source_system_id = 3
  AND per.first_name = 'Robert' AND per.last_name = 'Hourihan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC' AND t.source_system_id = 3
  AND per.first_name = 'Hugo' AND per.last_name = 'Howard'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC' AND t.source_system_id = 3
  AND per.first_name = 'Tom' AND per.last_name = 'Howse'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC' AND t.source_system_id = 3
  AND per.first_name = 'Sulaiman' AND per.last_name = 'Jalloh'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC' AND t.source_system_id = 3
  AND per.first_name = 'Conor' AND per.last_name = 'King'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC' AND t.source_system_id = 3
  AND per.first_name = 'John' AND per.last_name = 'Jake Korman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC' AND t.source_system_id = 3
  AND per.first_name = 'Carlos' AND per.last_name = 'Lopez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC' AND t.source_system_id = 3
  AND per.first_name = 'Varun' AND per.last_name = 'Mehta'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC' AND t.source_system_id = 3
  AND per.first_name = 'Christopher' AND per.last_name = 'Minty'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC' AND t.source_system_id = 3
  AND per.first_name = 'Mylo' AND per.last_name = 'Portas'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC' AND t.source_system_id = 3
  AND per.first_name = 'Fernando' AND per.last_name = 'Rosas-Quintero'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC' AND t.source_system_id = 3
  AND per.first_name = 'Al' AND per.last_name = 'Ameen Salako'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC' AND t.source_system_id = 3
  AND per.first_name = 'Idrissa' AND per.last_name = 'Sanogo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC' AND t.source_system_id = 3
  AND per.first_name = 'Louis' AND per.last_name = 'Shaw'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC' AND t.source_system_id = 3
  AND per.first_name = 'Orest' AND per.last_name = 'Sison'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC' AND t.source_system_id = 3
  AND per.first_name = 'Alexandru' AND per.last_name = 'Teodorescu'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC' AND t.source_system_id = 3
  AND per.first_name = 'Simon' AND per.last_name = 'Zheng'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Joaquin' AND per.last_name = 'Baluga'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Nick' AND per.last_name = 'Cho'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Corentin' AND per.last_name = 'Claisse'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Simon' AND per.last_name = 'Czaplinski'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Amr' AND per.last_name = 'Elbegrmi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Kenroy' AND per.last_name = 'Fuller'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Veprim' AND per.last_name = 'Gashi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Jordy' AND per.last_name = 'Gonzalez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Raheem' AND per.last_name = 'Grant'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Owen' AND per.last_name = 'Hennigan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Mark' AND per.last_name = 'Hortop'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Abdel' AND per.last_name = 'Idrissou'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Quentin' AND per.last_name = 'Jaubert'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Sam' AND per.last_name = 'Johnson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Carl' AND per.last_name = 'Kieri'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Jack' AND per.last_name = 'Kiernan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Mohamed' AND per.last_name = 'Kourouma'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Manus' AND per.last_name = 'McGuire'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Ronald' AND per.last_name = 'Paucar'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Paul' AND per.last_name = 'Petre'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Nicholas' AND per.last_name = 'Platt'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Konstantin' AND per.last_name = 'Pyankov'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Stefan' AND per.last_name = 'Rankovic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC II' AND t.source_system_id = 3
  AND per.first_name = 'William' AND per.last_name = 'Rawlings'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Sanford' AND per.last_name = 'Rodriguez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Michael' AND per.last_name = 'Rowley'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Martin' AND per.last_name = 'Serrano'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Norbu' AND per.last_name = 'Andy Sherpa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Luke' AND per.last_name = 'Simboli'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Arsen' AND per.last_name = 'Vanian'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Irish SC Legends' AND t.source_system_id = 3
  AND per.first_name = 'Yonatan' AND per.last_name = 'Biton'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Irish SC Legends' AND t.source_system_id = 3
  AND per.first_name = 'Andrew' AND per.last_name = 'Connolly'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Irish SC Legends' AND t.source_system_id = 3
  AND per.first_name = 'Donnchadh' AND per.last_name = 'Costello'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Irish SC Legends' AND t.source_system_id = 3
  AND per.first_name = 'Ciaran' AND per.last_name = 'Devlin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Irish SC Legends' AND t.source_system_id = 3
  AND per.first_name = 'Lahtouss' AND per.last_name = 'El Hafed'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Irish SC Legends' AND t.source_system_id = 3
  AND per.first_name = 'Peter' AND per.last_name = 'Ferguson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Irish SC Legends' AND t.source_system_id = 3
  AND per.first_name = 'William' AND per.last_name = 'Grone'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Irish SC Legends' AND t.source_system_id = 3
  AND per.first_name = 'Dave' AND per.last_name = 'Harvey'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Irish SC Legends' AND t.source_system_id = 3
  AND per.first_name = 'Emmett' AND per.last_name = 'Harvey'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Irish SC Legends' AND t.source_system_id = 3
  AND per.first_name = 'Francisco' AND per.last_name = 'Hoozky'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Irish SC Legends' AND t.source_system_id = 3
  AND per.first_name = 'Colin' AND per.last_name = 'Lee'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Irish SC Legends' AND t.source_system_id = 3
  AND per.first_name = 'Neil' AND per.last_name = 'Mannion'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Irish SC Legends' AND t.source_system_id = 3
  AND per.first_name = 'Keith' AND per.last_name = 'Melia'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Irish SC Legends' AND t.source_system_id = 3
  AND per.first_name = 'Ciaran' AND per.last_name = 'Moloney'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Irish SC Legends' AND t.source_system_id = 3
  AND per.first_name = 'David' AND per.last_name = 'Nasser'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Irish SC Legends' AND t.source_system_id = 3
  AND per.first_name = 'antoin' AND per.last_name = 'ODuibhir'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Irish SC Legends' AND t.source_system_id = 3
  AND per.first_name = 'Luca' AND per.last_name = 'Puracchio'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Irish SC Legends' AND t.source_system_id = 3
  AND per.first_name = 'Mauro' AND per.last_name = 'Servisi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Irish SC Legends' AND t.source_system_id = 3
  AND per.first_name = 'Edward' AND per.last_name = 'Willem'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Irish SC Legends' AND t.source_system_id = 3
  AND per.first_name = 'Brian' AND per.last_name = 'Wolohan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms II' AND t.source_system_id = 3
  AND per.first_name = 'Yusuf' AND per.last_name = 'Adib'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms II' AND t.source_system_id = 3
  AND per.first_name = 'Geraldo-Christopher' AND per.last_name = 'Agbodoh'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms II' AND t.source_system_id = 3
  AND per.first_name = 'George' AND per.last_name = 'Angelidis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms II' AND t.source_system_id = 3
  AND per.first_name = 'Noah' AND per.last_name = 'Aniser'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms II' AND t.source_system_id = 3
  AND per.first_name = 'Andreas' AND per.last_name = 'Antoniades'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms II' AND t.source_system_id = 3
  AND per.first_name = 'Sean' AND per.last_name = 'Arus'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms II' AND t.source_system_id = 3
  AND per.first_name = 'Marwan' AND per.last_name = 'Awad'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms II' AND t.source_system_id = 3
  AND per.first_name = 'Kevin' AND per.last_name = 'Contreras'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms II' AND t.source_system_id = 3
  AND per.first_name = 'Brandon' AND per.last_name = 'Cosme'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms II' AND t.source_system_id = 3
  AND per.first_name = 'Jesus' AND per.last_name = 'Cruz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms II' AND t.source_system_id = 3
  AND per.first_name = 'Cristian' AND per.last_name = 'Draguca'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms II' AND t.source_system_id = 3
  AND per.first_name = 'Andreas' AND per.last_name = 'Efraim'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms II' AND t.source_system_id = 3
  AND per.first_name = 'Saleel' AND per.last_name = 'Eldin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms II' AND t.source_system_id = 3
  AND per.first_name = 'Thomas' AND per.last_name = 'Espero'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms II' AND t.source_system_id = 3
  AND per.first_name = 'Ahmed' AND per.last_name = 'Hafez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms II' AND t.source_system_id = 3
  AND per.first_name = 'Julian' AND per.last_name = 'Lanci'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms II' AND t.source_system_id = 3
  AND per.first_name = 'Alexander' AND per.last_name = 'Lenart'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms II' AND t.source_system_id = 3
  AND per.first_name = 'Guilherme' AND per.last_name = 'Lira'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms II' AND t.source_system_id = 3
  AND per.first_name = 'Stephen' AND per.last_name = 'Manaridis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms II' AND t.source_system_id = 3
  AND per.first_name = 'George' AND per.last_name = 'Maris'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms II' AND t.source_system_id = 3
  AND per.first_name = 'Justin' AND per.last_name = 'Morales'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms II' AND t.source_system_id = 3
  AND per.first_name = 'Thiago' AND per.last_name = 'Navarro'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms II' AND t.source_system_id = 3
  AND per.first_name = 'Milton' AND per.last_name = 'Sionakides'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms II' AND t.source_system_id = 3
  AND per.first_name = 'Luis' AND per.last_name = 'Sucuzhanay'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms II' AND t.source_system_id = 3
  AND per.first_name = 'Tiago' AND per.last_name = 'Tirado'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms II' AND t.source_system_id = 3
  AND per.first_name = 'Dimitri' AND per.last_name = 'Tsirkos'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms II' AND t.source_system_id = 3
  AND per.first_name = 'Gerasimos' AND per.last_name = 'Tzanetatos'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms II' AND t.source_system_id = 3
  AND per.first_name = 'John' AND per.last_name = 'Ulusoy'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms II' AND t.source_system_id = 3
  AND per.first_name = 'Arda' AND per.last_name = 'Yazici'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks' AND t.source_system_id = 3
  AND per.first_name = 'Leon' AND per.last_name = 'Aboudi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks' AND t.source_system_id = 3
  AND per.first_name = 'Joey' AND per.last_name = 'Aronovsky'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks' AND t.source_system_id = 3
  AND per.first_name = 'Kwadwo' AND per.last_name = 'Asante'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks' AND t.source_system_id = 3
  AND per.first_name = 'Souleymane' AND per.last_name = 'Bah'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks' AND t.source_system_id = 3
  AND per.first_name = 'Urim' AND per.last_name = 'Bibovic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks' AND t.source_system_id = 3
  AND per.first_name = 'Owen' AND per.last_name = 'Bradley'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks' AND t.source_system_id = 3
  AND per.first_name = 'Raphael' AND per.last_name = 'Carvalho'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks' AND t.source_system_id = 3
  AND per.first_name = 'Peter' AND per.last_name = 'Ceesay'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks' AND t.source_system_id = 3
  AND per.first_name = 'Darren' AND per.last_name = 'Coleman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks' AND t.source_system_id = 3
  AND per.first_name = 'Zack' AND per.last_name = 'DiDonato'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks' AND t.source_system_id = 3
  AND per.first_name = 'Alejandro' AND per.last_name = 'Fritz Ruenes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks' AND t.source_system_id = 3
  AND per.first_name = 'Jahdea' AND per.last_name = 'Gildin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks' AND t.source_system_id = 3
  AND per.first_name = 'Daniel' AND per.last_name = 'Giorgi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks' AND t.source_system_id = 3
  AND per.first_name = 'Alex' AND per.last_name = 'Heston'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks' AND t.source_system_id = 3
  AND per.first_name = 'James' AND per.last_name = 'Hudson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks' AND t.source_system_id = 3
  AND per.first_name = 'Jacob' AND per.last_name = 'Jensen'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks' AND t.source_system_id = 3
  AND per.first_name = 'Christian' AND per.last_name = 'Kapper'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks' AND t.source_system_id = 3
  AND per.first_name = 'John' AND per.last_name = 'McAleenan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks' AND t.source_system_id = 3
  AND per.first_name = 'Kieran' AND per.last_name = 'McGovern'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks' AND t.source_system_id = 3
  AND per.first_name = 'Ciaran' AND per.last_name = 'McGuigan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks' AND t.source_system_id = 3
  AND per.first_name = 'Stephen' AND per.last_name = 'McKenna'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks' AND t.source_system_id = 3
  AND per.first_name = 'William' AND per.last_name = 'Oswin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks' AND t.source_system_id = 3
  AND per.first_name = 'Faissal' AND per.last_name = 'Sanfo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks' AND t.source_system_id = 3
  AND per.first_name = 'Lloyd' AND per.last_name = 'Shillabeer'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks' AND t.source_system_id = 3
  AND per.first_name = 'Larry' AND per.last_name = 'Slaughter'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks' AND t.source_system_id = 3
  AND per.first_name = 'Jordan' AND per.last_name = 'Trinci-Lyne'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks' AND t.source_system_id = 3
  AND per.first_name = 'Christian' AND per.last_name = 'Uy'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks' AND t.source_system_id = 3
  AND per.first_name = 'Jonathan' AND per.last_name = 'Uy'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks' AND t.source_system_id = 3
  AND per.first_name = 'Nick' AND per.last_name = 'Zorbo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks Legends' AND t.source_system_id = 3
  AND per.first_name = 'Jerome' AND per.last_name = 'Albertini'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks Legends' AND t.source_system_id = 3
  AND per.first_name = 'Peter' AND per.last_name = 'Anastasian'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks Legends' AND t.source_system_id = 3
  AND per.first_name = 'Dan' AND per.last_name = 'Bing'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks Legends' AND t.source_system_id = 3
  AND per.first_name = 'Paul' AND per.last_name = 'Bradshaw'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks Legends' AND t.source_system_id = 3
  AND per.first_name = 'Joe' AND per.last_name = 'Connolly'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks Legends' AND t.source_system_id = 3
  AND per.first_name = 'Niall' AND per.last_name = 'Corbett'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks Legends' AND t.source_system_id = 3
  AND per.first_name = 'Brendan' AND per.last_name = 'Donoghue'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks Legends' AND t.source_system_id = 3
  AND per.first_name = 'Conor' AND per.last_name = 'Doyle'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks Legends' AND t.source_system_id = 3
  AND per.first_name = 'John' AND per.last_name = 'Duddy'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks Legends' AND t.source_system_id = 3
  AND per.first_name = 'Kevin' AND per.last_name = 'Farrell'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks Legends' AND t.source_system_id = 3
  AND per.first_name = 'Seathrun' AND per.last_name = 'Farrell'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks Legends' AND t.source_system_id = 3
  AND per.first_name = 'Johnny' AND per.last_name = 'Keogh'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks Legends' AND t.source_system_id = 3
  AND per.first_name = 'Johno' AND per.last_name = 'Keogh'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks Legends' AND t.source_system_id = 3
  AND per.first_name = 'Onder' AND per.last_name = 'Koksal'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks Legends' AND t.source_system_id = 3
  AND per.first_name = 'Evan' AND per.last_name = 'Madden-Peister'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks Legends' AND t.source_system_id = 3
  AND per.first_name = 'Baron' AND per.last_name = 'Meyer'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks Legends' AND t.source_system_id = 3
  AND per.first_name = 'Karim' AND per.last_name = 'Morrison'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks Legends' AND t.source_system_id = 3
  AND per.first_name = 'Marcus' AND per.last_name = 'Nascimento'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks Legends' AND t.source_system_id = 3
  AND per.first_name = 'Ambrose' AND per.last_name = 'O''Donovan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks Legends' AND t.source_system_id = 3
  AND per.first_name = 'Eugene' AND per.last_name = 'O''Driscoll'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks Legends' AND t.source_system_id = 3
  AND per.first_name = 'Robert' AND per.last_name = 'O’Neill'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks Legends' AND t.source_system_id = 3
  AND per.first_name = 'Stokuley' AND per.last_name = 'Powell'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks Legends' AND t.source_system_id = 3
  AND per.first_name = 'John' AND per.last_name = 'Riordan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks Legends' AND t.source_system_id = 3
  AND per.first_name = 'Francisco' AND per.last_name = 'Rodríguez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks Legends' AND t.source_system_id = 3
  AND per.first_name = 'Mark' AND per.last_name = 'Rowe'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks Legends' AND t.source_system_id = 3
  AND per.first_name = 'Ger' AND per.last_name = 'Shivnan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks Legends' AND t.source_system_id = 3
  AND per.first_name = 'Justin' AND per.last_name = 'Stanford'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks Legends' AND t.source_system_id = 3
  AND per.first_name = 'Sergio' AND per.last_name = 'Tache'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks Legends' AND t.source_system_id = 3
  AND per.first_name = 'David' AND per.last_name = 'Tutin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks Legends' AND t.source_system_id = 3
  AND per.first_name = 'Tolga' AND per.last_name = 'Yilmaz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks II' AND t.source_system_id = 3
  AND per.first_name = 'Aaron' AND per.last_name = 'Ashe'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks II' AND t.source_system_id = 3
  AND per.first_name = 'Michael' AND per.last_name = 'Brunton'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks II' AND t.source_system_id = 3
  AND per.first_name = 'Teon' AND per.last_name = 'Chaumette'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks II' AND t.source_system_id = 3
  AND per.first_name = 'Gil' AND per.last_name = 'Christenberry'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks II' AND t.source_system_id = 3
  AND per.first_name = 'Darragh' AND per.last_name = 'Coates'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks II' AND t.source_system_id = 3
  AND per.first_name = 'Sean' AND per.last_name = 'Collins'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks II' AND t.source_system_id = 3
  AND per.first_name = 'Joseph' AND per.last_name = 'Connolly'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks II' AND t.source_system_id = 3
  AND per.first_name = 'Gavin' AND per.last_name = 'Cooney'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks II' AND t.source_system_id = 3
  AND per.first_name = 'Daniel' AND per.last_name = 'Corridan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks II' AND t.source_system_id = 3
  AND per.first_name = 'Eric' AND per.last_name = 'Doyle'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks II' AND t.source_system_id = 3
  AND per.first_name = 'Fabrice' AND per.last_name = 'Dupiton'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks II' AND t.source_system_id = 3
  AND per.first_name = 'Timothy' AND per.last_name = 'Egan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks II' AND t.source_system_id = 3
  AND per.first_name = 'Danny' AND per.last_name = 'Fallon'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks II' AND t.source_system_id = 3
  AND per.first_name = 'Joseph' AND per.last_name = 'Flynn'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks II' AND t.source_system_id = 3
  AND per.first_name = 'Mikey' AND per.last_name = 'Greed'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks II' AND t.source_system_id = 3
  AND per.first_name = 'Ronan' AND per.last_name = 'Harvey'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks II' AND t.source_system_id = 3
  AND per.first_name = 'James' AND per.last_name = 'Horan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks II' AND t.source_system_id = 3
  AND per.first_name = 'Matthew' AND per.last_name = 'Kearney'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks II' AND t.source_system_id = 3
  AND per.first_name = 'Luke' AND per.last_name = 'Kelly'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks II' AND t.source_system_id = 3
  AND per.first_name = 'Aidan' AND per.last_name = 'Kennedy'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks II' AND t.source_system_id = 3
  AND per.first_name = 'Stephen' AND per.last_name = 'Lally'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks II' AND t.source_system_id = 3
  AND per.first_name = 'Michael' AND per.last_name = 'Mc Greevy'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks II' AND t.source_system_id = 3
  AND per.first_name = 'Paul' AND per.last_name = 'McDaid'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks II' AND t.source_system_id = 3
  AND per.first_name = 'Quinn' AND per.last_name = 'McLoughlin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks II' AND t.source_system_id = 3
  AND per.first_name = 'Thomas' AND per.last_name = 'Mills'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks II' AND t.source_system_id = 3
  AND per.first_name = 'Andy' AND per.last_name = 'O''Connell'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks II' AND t.source_system_id = 3
  AND per.first_name = 'Finn' AND per.last_name = 'O''Reilly'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks II' AND t.source_system_id = 3
  AND per.first_name = 'Mark' AND per.last_name = 'Roche'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Shamrocks II' AND t.source_system_id = 3
  AND per.first_name = 'Ciaran' AND per.last_name = 'Taaffe'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Ukrainians' AND t.source_system_id = 3
  AND per.first_name = 'Nabi' AND per.last_name = 'Bangoura'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Ukrainians' AND t.source_system_id = 3
  AND per.first_name = 'Irvin' AND per.last_name = 'Mauricio Barreto Aguero'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Ukrainians' AND t.source_system_id = 3
  AND per.first_name = 'Gilbert' AND per.last_name = 'Bayonne'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Ukrainians' AND t.source_system_id = 3
  AND per.first_name = 'Andras' AND per.last_name = 'Breuer'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Ukrainians' AND t.source_system_id = 3
  AND per.first_name = 'Kalel' AND per.last_name = 'De Paula Menezes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Ukrainians' AND t.source_system_id = 3
  AND per.first_name = 'Kemo' AND per.last_name = 'Gregoire Diedhiou Momar'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Ukrainians' AND t.source_system_id = 3
  AND per.first_name = 'Nazar' AND per.last_name = 'Humeniuk'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Ukrainians' AND t.source_system_id = 3
  AND per.first_name = 'Noah' AND per.last_name = 'Hutchins'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Ukrainians' AND t.source_system_id = 3
  AND per.first_name = 'Hasier' AND per.last_name = 'Larrea-Tamayo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Ukrainians' AND t.source_system_id = 3
  AND per.first_name = 'Adam' AND per.last_name = 'Maliniak'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Ukrainians' AND t.source_system_id = 3
  AND per.first_name = 'Amar' AND per.last_name = 'Mame Mor'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Ukrainians' AND t.source_system_id = 3
  AND per.first_name = 'Connor' AND per.last_name = 'Mcdermott'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Ukrainians' AND t.source_system_id = 3
  AND per.first_name = 'Calvin' AND per.last_name = 'Moyes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Ukrainians' AND t.source_system_id = 3
  AND per.first_name = 'Lawrence' AND per.last_name = 'Mullen'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Ukrainians' AND t.source_system_id = 3
  AND per.first_name = 'George' AND per.last_name = 'Najm'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Ukrainians' AND t.source_system_id = 3
  AND per.first_name = 'Lukasz' AND per.last_name = 'Prawdzik'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Ukrainians' AND t.source_system_id = 3
  AND per.first_name = 'Christian' AND per.last_name = 'Jose Richard Quinttus'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Ukrainians' AND t.source_system_id = 3
  AND per.first_name = 'Luke' AND per.last_name = 'Sager'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Ukrainians' AND t.source_system_id = 3
  AND per.first_name = 'John' AND per.last_name = 'Salazar Banol'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Ukrainians' AND t.source_system_id = 3
  AND per.first_name = 'Paul' AND per.last_name = 'Sandoval'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Ukrainians' AND t.source_system_id = 3
  AND per.first_name = 'Ajani' AND per.last_name = 'Selassie'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Ukrainians' AND t.source_system_id = 3
  AND per.first_name = 'Roman' AND per.last_name = 'Semenko'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Ukrainians' AND t.source_system_id = 3
  AND per.first_name = 'James' AND per.last_name = 'Terpak'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Ukrainians' AND t.source_system_id = 3
  AND per.first_name = 'Robbie' AND per.last_name = 'Webster'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Ukrainians' AND t.source_system_id = 3
  AND per.first_name = 'Adnan' AND per.last_name = 'Zaganjor'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Ukrainians II' AND t.source_system_id = 3
  AND per.first_name = 'Adem' AND per.last_name = 'Altinerlielmas'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Ukrainians II' AND t.source_system_id = 3
  AND per.first_name = 'Farid' AND per.last_name = 'Bagheri Ardestani'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Ukrainians II' AND t.source_system_id = 3
  AND per.first_name = 'John' AND per.last_name = 'Corio'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Ukrainians II' AND t.source_system_id = 3
  AND per.first_name = 'Billy' AND per.last_name = 'Coulanges'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Ukrainians II' AND t.source_system_id = 3
  AND per.first_name = 'Vitantonio' AND per.last_name = 'Di Campi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Ukrainians II' AND t.source_system_id = 3
  AND per.first_name = 'Nazariy' AND per.last_name = 'Dolishnyak'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Ukrainians II' AND t.source_system_id = 3
  AND per.first_name = 'Alejandro' AND per.last_name = 'Gomez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Ukrainians II' AND t.source_system_id = 3
  AND per.first_name = 'Christian' AND per.last_name = 'Gunther'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Ukrainians II' AND t.source_system_id = 3
  AND per.first_name = 'Shaun' AND per.last_name = 'Horton'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Ukrainians II' AND t.source_system_id = 3
  AND per.first_name = 'Dmitri' AND per.last_name = 'Jacobs'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Ukrainians II' AND t.source_system_id = 3
  AND per.first_name = 'Eric' AND per.last_name = 'Jaramillo-Martinez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Ukrainians II' AND t.source_system_id = 3
  AND per.first_name = 'Kyle' AND per.last_name = 'Keefe'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Ukrainians II' AND t.source_system_id = 3
  AND per.first_name = 'Christian' AND per.last_name = 'Koziatek'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Ukrainians II' AND t.source_system_id = 3
  AND per.first_name = 'Fredie' AND per.last_name = 'Lagos'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Ukrainians II' AND t.source_system_id = 3
  AND per.first_name = 'Henry' AND per.last_name = 'Lardy'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Ukrainians II' AND t.source_system_id = 3
  AND per.first_name = 'Jaroslaw' AND per.last_name = 'Maliniak'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Ukrainians II' AND t.source_system_id = 3
  AND per.first_name = 'Nickoy' AND per.last_name = 'Montaque'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Ukrainians II' AND t.source_system_id = 3
  AND per.first_name = 'Felipe' AND per.last_name = 'Muntsch'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Ukrainians II' AND t.source_system_id = 3
  AND per.first_name = 'Jose' AND per.last_name = 'Novas Mejuto'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Ukrainians II' AND t.source_system_id = 3
  AND per.first_name = 'Marko' AND per.last_name = 'Petkovic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Ukrainians II' AND t.source_system_id = 3
  AND per.first_name = 'Bibek' AND per.last_name = 'Sambahamphe'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Ukrainians II' AND t.source_system_id = 3
  AND per.first_name = 'Lukasz' AND per.last_name = 'Stankowski'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Ukrainians II' AND t.source_system_id = 3
  AND per.first_name = 'Dalibor' AND per.last_name = 'Tolicki'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Ukrainians II' AND t.source_system_id = 3
  AND per.first_name = 'Vasyl' AND per.last_name = 'Yaremchuk'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Ukrainians II' AND t.source_system_id = 3
  AND per.first_name = 'Nazar' AND per.last_name = 'Zarichnyy'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
  AND per.first_name = 'Austin' AND per.last_name = 'Arogundade'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
  AND per.first_name = 'Shawn' AND per.last_name = 'Arrindell'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
  AND per.first_name = 'Keylor' AND per.last_name = 'Arriola'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
  AND per.first_name = 'Ibrahim' AND per.last_name = 'Aweniya'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
  AND per.first_name = 'Chadeese' AND per.last_name = 'Bennett'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
  AND per.first_name = 'Mathew' AND per.last_name = 'Briones'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
  AND per.first_name = 'Sulayman' AND per.last_name = 'Camara'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
  AND per.first_name = 'David' AND per.last_name = 'Carillo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
  AND per.first_name = 'Benjamin' AND per.last_name = 'Clark'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
  AND per.first_name = 'Sahil' AND per.last_name = 'Handa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
  AND per.first_name = 'Gabriel' AND per.last_name = 'Ezequiel Insfran'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
  AND per.first_name = 'Kourosh' AND per.last_name = 'Jalinous'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
  AND per.first_name = 'Valni' AND per.last_name = 'Jean Pierre'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
  AND per.first_name = 'Isley' AND per.last_name = 'Jean-Pierre'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
  AND per.first_name = 'Mohammad' AND per.last_name = 'Kanoongo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
  AND per.first_name = 'Shawn' AND per.last_name = 'Khan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
  AND per.first_name = 'Jonathan' AND per.last_name = 'Martinez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
  AND per.first_name = 'Myron' AND per.last_name = 'Matthews'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
  AND per.first_name = 'Armando' AND per.last_name = 'Membreno'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
  AND per.first_name = 'Junior' AND per.last_name = 'Mlawa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
  AND per.first_name = 'Adolf' AND per.last_name = 'Jose Moreno'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
  AND per.first_name = 'Eirik' AND per.last_name = 'Bratli Okeefe'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
  AND per.first_name = 'Erik' AND per.last_name = 'Rincon'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
  AND per.first_name = 'Ahmed' AND per.last_name = 'Salaudeen'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
  AND per.first_name = 'Hamza' AND per.last_name = 'Sennini'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
  AND per.first_name = 'Samuel' AND per.last_name = 'Shobowale'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
  AND per.first_name = 'Marron' AND per.last_name = 'St Marthe'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
  AND per.first_name = 'Warren' AND per.last_name = 'Vargas'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYC AlphaStars Club' AND t.source_system_id = 3
  AND per.first_name = 'Michael' AND per.last_name = 'Vasquez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC' AND t.source_system_id = 3
  AND per.first_name = 'Alan' AND per.last_name = 'Acevedo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC' AND t.source_system_id = 3
  AND per.first_name = 'Carlos' AND per.last_name = 'Bonilla'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC' AND t.source_system_id = 3
  AND per.first_name = 'Marcos' AND per.last_name = 'Buruca'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC' AND t.source_system_id = 3
  AND per.first_name = 'Alexis' AND per.last_name = 'Bustillo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC' AND t.source_system_id = 3
  AND per.first_name = 'Julian' AND per.last_name = 'Campoverde'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC' AND t.source_system_id = 3
  AND per.first_name = 'Luis' AND per.last_name = 'Delpezo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC' AND t.source_system_id = 3
  AND per.first_name = 'Juan' AND per.last_name = 'Escobar'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC' AND t.source_system_id = 3
  AND per.first_name = 'Michael' AND per.last_name = 'Fernandez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC' AND t.source_system_id = 3
  AND per.first_name = 'Christopher' AND per.last_name = 'Hernandez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC' AND t.source_system_id = 3
  AND per.first_name = 'Colin' AND per.last_name = 'Hodge'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC' AND t.source_system_id = 3
  AND per.first_name = 'Robenson' AND per.last_name = 'Jasmin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC' AND t.source_system_id = 3
  AND per.first_name = 'Selcuk' AND per.last_name = 'Kahveci'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC' AND t.source_system_id = 3
  AND per.first_name = 'Tom' AND per.last_name = 'Kcira'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC' AND t.source_system_id = 3
  AND per.first_name = 'Sean' AND per.last_name = 'Kennedy'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC' AND t.source_system_id = 3
  AND per.first_name = 'Mike' AND per.last_name = 'Maffei'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC' AND t.source_system_id = 3
  AND per.first_name = 'Daniel' AND per.last_name = 'Manz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC' AND t.source_system_id = 3
  AND per.first_name = 'Freddy' AND per.last_name = 'Marcel'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC' AND t.source_system_id = 3
  AND per.first_name = 'Diego' AND per.last_name = 'Martinez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC' AND t.source_system_id = 3
  AND per.first_name = 'Patrick' AND per.last_name = 'OCallaghan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC' AND t.source_system_id = 3
  AND per.first_name = 'Johann' AND per.last_name = 'Pacheco'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC' AND t.source_system_id = 3
  AND per.first_name = 'Sebastian' AND per.last_name = 'Pazymino'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC' AND t.source_system_id = 3
  AND per.first_name = 'Daniel' AND per.last_name = 'Poku'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC' AND t.source_system_id = 3
  AND per.first_name = 'Mark' AND per.last_name = 'Puma'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC' AND t.source_system_id = 3
  AND per.first_name = 'Michael' AND per.last_name = 'Renzulli'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC' AND t.source_system_id = 3
  AND per.first_name = 'Francesco' AND per.last_name = 'Scotti'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC' AND t.source_system_id = 3
  AND per.first_name = 'Jorn' AND per.last_name = 'Van der Heide'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC' AND t.source_system_id = 3
  AND per.first_name = 'Demetre' AND per.last_name = 'Vernon'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC' AND t.source_system_id = 3
  AND per.first_name = 'Shane' AND per.last_name = 'Wittemann'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC II' AND t.source_system_id = 3
  AND per.first_name = 'Alex' AND per.last_name = 'Alvarez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC II' AND t.source_system_id = 3
  AND per.first_name = 'John' AND per.last_name = 'Arias'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC II' AND t.source_system_id = 3
  AND per.first_name = 'Jorge' AND per.last_name = 'Bedoya'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC II' AND t.source_system_id = 3
  AND per.first_name = 'Nick' AND per.last_name = 'Capunay'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC II' AND t.source_system_id = 3
  AND per.first_name = 'Giovanny' AND per.last_name = 'Cortese'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC II' AND t.source_system_id = 3
  AND per.first_name = 'Aydin' AND per.last_name = 'Egemen'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC II' AND t.source_system_id = 3
  AND per.first_name = 'Jiovanny' AND per.last_name = 'Fierro'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC II' AND t.source_system_id = 3
  AND per.first_name = 'Jonathan' AND per.last_name = 'Forte'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC II' AND t.source_system_id = 3
  AND per.first_name = 'DOUGLAS' AND per.last_name = 'FRANCO'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC II' AND t.source_system_id = 3
  AND per.first_name = 'Amilcar' AND per.last_name = 'Garcia'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC II' AND t.source_system_id = 3
  AND per.first_name = 'Angelot' AND per.last_name = 'Georges'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC II' AND t.source_system_id = 3
  AND per.first_name = 'Sebastian' AND per.last_name = 'Hernandez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC II' AND t.source_system_id = 3
  AND per.first_name = 'Huseyin' AND per.last_name = 'Kahveci'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC II' AND t.source_system_id = 3
  AND per.first_name = 'Ugur' AND per.last_name = 'Kahveci'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC II' AND t.source_system_id = 3
  AND per.first_name = 'Christian' AND per.last_name = 'Kennedy'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC II' AND t.source_system_id = 3
  AND per.first_name = 'Jesus' AND per.last_name = 'Lugo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC II' AND t.source_system_id = 3
  AND per.first_name = 'Rafi' AND per.last_name = 'Mashriqi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC II' AND t.source_system_id = 3
  AND per.first_name = 'Nadder' AND per.last_name = 'Munassar'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC II' AND t.source_system_id = 3
  AND per.first_name = 'Juan' AND per.last_name = 'Nieto'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC II' AND t.source_system_id = 3
  AND per.first_name = 'William' AND per.last_name = 'Ortiz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC II' AND t.source_system_id = 3
  AND per.first_name = 'Eric' AND per.last_name = 'Owusu'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC II' AND t.source_system_id = 3
  AND per.first_name = 'Erik' AND per.last_name = 'Perez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC II' AND t.source_system_id = 3
  AND per.first_name = 'Ronnie' AND per.last_name = 'Roman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC II' AND t.source_system_id = 3
  AND per.first_name = 'Jorge' AND per.last_name = 'Subia'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC II' AND t.source_system_id = 3
  AND per.first_name = 'Frank' AND per.last_name = 'Talio'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC II' AND t.source_system_id = 3
  AND per.first_name = 'Matt' AND per.last_name = 'Tyburczy'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC II' AND t.source_system_id = 3
  AND per.first_name = 'Michael' AND per.last_name = 'Warren'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC II' AND t.source_system_id = 3
  AND per.first_name = 'Ransford' AND per.last_name = 'Worae'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
  AND per.first_name = 'Reza' AND per.last_name = 'Ardebili'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
  AND per.first_name = 'Curtis' AND per.last_name = 'Baksh'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
  AND per.first_name = 'Julio' AND per.last_name = 'Barbecho'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
  AND per.first_name = 'Chas' AND per.last_name = 'Briant'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
  AND per.first_name = 'Kenneth' AND per.last_name = 'Calderon'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
  AND per.first_name = 'Zhang' AND per.last_name = 'Chi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
  AND per.first_name = 'Gregory' AND per.last_name = 'Clena'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
  AND per.first_name = 'li' AND per.last_name = 'deng'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
  AND per.first_name = 'Taj' AND per.last_name = 'Green'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
  AND per.first_name = 'Alberto' AND per.last_name = 'Jadan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
  AND per.first_name = 'Ahmad' AND per.last_name = 'Kessba'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
  AND per.first_name = 'Mohamed' AND per.last_name = 'Kessba'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
  AND per.first_name = 'Ronald' AND per.last_name = 'Mejia'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
  AND per.first_name = 'Douglas' AND per.last_name = 'Narvaez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
  AND per.first_name = 'Ronald' AND per.last_name = 'Navarrete'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
  AND per.first_name = 'Hector' AND per.last_name = 'Orantes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
  AND per.first_name = 'Pablo' AND per.last_name = 'Orantes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
  AND per.first_name = 'Pablo' AND per.last_name = 'Penaherrera'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
  AND per.first_name = 'Carlos' AND per.last_name = 'Quintero'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
  AND per.first_name = 'Andre' AND per.last_name = 'Omar Richards'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
  AND per.first_name = 'Larry' AND per.last_name = 'Roberts'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
  AND per.first_name = 'Tom' AND per.last_name = 'Rolston'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
  AND per.first_name = 'Kevin' AND per.last_name = 'Savary'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
  AND per.first_name = 'JOSE' AND per.last_name = 'SURA'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
  AND per.first_name = 'Carlos' AND per.last_name = 'Villacres'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
  AND per.first_name = 'Fabrizio' AND per.last_name = 'Villatoro'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
  AND per.first_name = 'Terrence' AND per.last_name = 'Wilson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NYPD FC Veterans' AND t.source_system_id = 3
  AND per.first_name = 'Collin' AND per.last_name = 'Wynter'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Panatha USA' AND t.source_system_id = 3
  AND per.first_name = 'MICHAIL' AND per.last_name = 'AXARLIS'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Panatha USA' AND t.source_system_id = 3
  AND per.first_name = 'IOANNIS' AND per.last_name = 'BACHOS'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Panatha USA' AND t.source_system_id = 3
  AND per.first_name = 'SIMEON' AND per.last_name = 'BALEV'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Panatha USA' AND t.source_system_id = 3
  AND per.first_name = 'CHRISTOPHER' AND per.last_name = 'MARINO BARTOLOTTA'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Panatha USA' AND t.source_system_id = 3
  AND per.first_name = 'MATHEW' AND per.last_name = 'CASTRO'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Panatha USA' AND t.source_system_id = 3
  AND per.first_name = 'VASILEIOS' AND per.last_name = 'DIAMANTIS'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Panatha USA' AND t.source_system_id = 3
  AND per.first_name = 'ALEXODIMOS' AND per.last_name = 'DIMALEXIS'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Panatha USA' AND t.source_system_id = 3
  AND per.first_name = 'HASAN' AND per.last_name = 'CAN ERKAN'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Panatha USA' AND t.source_system_id = 3
  AND per.first_name = 'DIMITRIOS' AND per.last_name = 'FAKIOLAS'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Panatha USA' AND t.source_system_id = 3
  AND per.first_name = 'MILTIADIS' AND per.last_name = 'GKOROS'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Panatha USA' AND t.source_system_id = 3
  AND per.first_name = 'MATHEW' AND per.last_name = 'JACOB GREENBLATT'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Panatha USA' AND t.source_system_id = 3
  AND per.first_name = 'YIANNI' AND per.last_name = 'KORMAS'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Panatha USA' AND t.source_system_id = 3
  AND per.first_name = 'ILIA' AND per.last_name = 'ALEXANDER LOUKISSAS'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Panatha USA' AND t.source_system_id = 3
  AND per.first_name = 'PHILIP' AND per.last_name = 'LAZARUS LOUKISSAS'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Panatha USA' AND t.source_system_id = 3
  AND per.first_name = 'ANTHONY' AND per.last_name = 'MACCHIARULO'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Panatha USA' AND t.source_system_id = 3
  AND per.first_name = 'DIMITRIOS' AND per.last_name = 'MANOS'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Panatha USA' AND t.source_system_id = 3
  AND per.first_name = 'VASILEIOS' AND per.last_name = 'NEKTARIOS MAXOUTIS'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Panatha USA' AND t.source_system_id = 3
  AND per.first_name = 'CHRISTOFOROS' AND per.last_name = 'PETROPOULOS'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Panatha USA' AND t.source_system_id = 3
  AND per.first_name = 'EMILIANO' AND per.last_name = 'RIKA'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Panatha USA' AND t.source_system_id = 3
  AND per.first_name = 'GEORGIOS' AND per.last_name = 'SOTIRIADIS'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Panatha USA' AND t.source_system_id = 3
  AND per.first_name = 'DIMITRIOS' AND per.last_name = 'TSAMPRAS'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Panatha USA' AND t.source_system_id = 3
  AND per.first_name = 'FILIPPOS' AND per.last_name = 'TSIKOLAS'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Panatha USA' AND t.source_system_id = 3
  AND per.first_name = 'EVAGELOS' AND per.last_name = 'TSINGOUNIS'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Panatha USA' AND t.source_system_id = 3
  AND per.first_name = 'EVANGELOS' AND per.last_name = 'VASOS'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Panatha USA' AND t.source_system_id = 3
  AND per.first_name = 'IOANNIS' AND per.last_name = 'VASOS'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC' AND t.source_system_id = 3
  AND per.first_name = 'Mauricio' AND per.last_name = 'Aguilera Juarez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC' AND t.source_system_id = 3
  AND per.first_name = 'Lukasz' AND per.last_name = 'Bielen'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC' AND t.source_system_id = 3
  AND per.first_name = 'Travis' AND per.last_name = 'Blair'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC' AND t.source_system_id = 3
  AND per.first_name = 'Sarsfield' AND per.last_name = 'Bowman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC' AND t.source_system_id = 3
  AND per.first_name = 'Christopher' AND per.last_name = 'Branch'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC' AND t.source_system_id = 3
  AND per.first_name = 'Brett' AND per.last_name = 'Crowley'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC' AND t.source_system_id = 3
  AND per.first_name = 'Carter' AND per.last_name = 'Dutton-Kneaves'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC' AND t.source_system_id = 3
  AND per.first_name = 'Alexander' AND per.last_name = 'Goldman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC' AND t.source_system_id = 3
  AND per.first_name = 'Marcin' AND per.last_name = 'Januszko'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC' AND t.source_system_id = 3
  AND per.first_name = 'Nicholas' AND per.last_name = 'Kovalenko'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC' AND t.source_system_id = 3
  AND per.first_name = 'Antoine' AND per.last_name = 'Laurient'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC' AND t.source_system_id = 3
  AND per.first_name = 'Jakub' AND per.last_name = 'Madej'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC' AND t.source_system_id = 3
  AND per.first_name = 'Bartlomie' AND per.last_name = 'Malinowski'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC' AND t.source_system_id = 3
  AND per.first_name = 'Nathaniel' AND per.last_name = 'Merchant'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC' AND t.source_system_id = 3
  AND per.first_name = 'Conrad' AND per.last_name = 'Nowowiejski'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC' AND t.source_system_id = 3
  AND per.first_name = 'Paschal' AND per.last_name = 'Chikelu Ogbunibala'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC' AND t.source_system_id = 3
  AND per.first_name = 'Roberto' AND per.last_name = 'Pacheco'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC' AND t.source_system_id = 3
  AND per.first_name = 'David' AND per.last_name = 'Pepper'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC' AND t.source_system_id = 3
  AND per.first_name = 'Justin' AND per.last_name = 'Pertierra'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC' AND t.source_system_id = 3
  AND per.first_name = 'Myles' AND per.last_name = 'Pindus'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC' AND t.source_system_id = 3
  AND per.first_name = 'Jacob' AND per.last_name = 'Price'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC' AND t.source_system_id = 3
  AND per.first_name = 'Matthew' AND per.last_name = 'Saluga'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC' AND t.source_system_id = 3
  AND per.first_name = 'Moises' AND per.last_name = 'Sierra'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC' AND t.source_system_id = 3
  AND per.first_name = 'Corey' AND per.last_name = 'Smith'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC' AND t.source_system_id = 3
  AND per.first_name = 'Daniel' AND per.last_name = 'Alexander Sydor'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC' AND t.source_system_id = 3
  AND per.first_name = 'Ahmed' AND per.last_name = 'Zaid'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC II' AND t.source_system_id = 3
  AND per.first_name = 'Atay' AND per.last_name = 'Ates'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC II' AND t.source_system_id = 3
  AND per.first_name = 'Samuel' AND per.last_name = 'Bacherman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC II' AND t.source_system_id = 3
  AND per.first_name = 'Steven' AND per.last_name = 'Cannon'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC II' AND t.source_system_id = 3
  AND per.first_name = 'Juan' AND per.last_name = 'Diego Cantillo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC II' AND t.source_system_id = 3
  AND per.first_name = 'Giorgio' AND per.last_name = 'Castellano'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC II' AND t.source_system_id = 3
  AND per.first_name = 'Slawomir' AND per.last_name = 'Dziubek'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC II' AND t.source_system_id = 3
  AND per.first_name = 'Fernando' AND per.last_name = 'Esteves'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC II' AND t.source_system_id = 3
  AND per.first_name = 'Ignacio' AND per.last_name = 'Farias'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC II' AND t.source_system_id = 3
  AND per.first_name = 'Wojciech' AND per.last_name = 'Grala'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC II' AND t.source_system_id = 3
  AND per.first_name = 'Joseph' AND per.last_name = 'Greenwald'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC II' AND t.source_system_id = 3
  AND per.first_name = 'Adrian' AND per.last_name = 'Hiotis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC II' AND t.source_system_id = 3
  AND per.first_name = 'Derek' AND per.last_name = 'B. Johnson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC II' AND t.source_system_id = 3
  AND per.first_name = 'Jaroslaw' AND per.last_name = 'Kacprzak'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC II' AND t.source_system_id = 3
  AND per.first_name = 'Joshua' AND per.last_name = 'David Krakowsky'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC II' AND t.source_system_id = 3
  AND per.first_name = 'Jakub' AND per.last_name = 'Kucharski'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC II' AND t.source_system_id = 3
  AND per.first_name = 'Radoslaw' AND per.last_name = 'Kucharski'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC II' AND t.source_system_id = 3
  AND per.first_name = 'Marcin' AND per.last_name = 'Kulak'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC II' AND t.source_system_id = 3
  AND per.first_name = 'Lukasz' AND per.last_name = 'Legierski'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC II' AND t.source_system_id = 3
  AND per.first_name = 'Philip' AND per.last_name = 'Quin Lu'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC II' AND t.source_system_id = 3
  AND per.first_name = 'Aleksandr' AND per.last_name = 'Marceau'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC II' AND t.source_system_id = 3
  AND per.first_name = 'Nathaniel' AND per.last_name = 'Marks'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC II' AND t.source_system_id = 3
  AND per.first_name = 'Gabriel' AND per.last_name = 'Mieleszko'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC II' AND t.source_system_id = 3
  AND per.first_name = 'Matthew' AND per.last_name = 'Mieleszko'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC II' AND t.source_system_id = 3
  AND per.first_name = 'Gabriel' AND per.last_name = 'Quintela'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC II' AND t.source_system_id = 3
  AND per.first_name = 'Samuel' AND per.last_name = 'Resnick'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC II' AND t.source_system_id = 3
  AND per.first_name = 'Cristhian' AND per.last_name = 'Sierra'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC II' AND t.source_system_id = 3
  AND per.first_name = 'Gustavo' AND per.last_name = 'DeJesus Torrealba -Delgado'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Polonia SC II' AND t.source_system_id = 3
  AND per.first_name = 'Levy' AND per.last_name = 'Yakubov'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 3
  AND per.first_name = 'Hermes' AND per.last_name = 'Ademovi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 3
  AND per.first_name = 'Matthew' AND per.last_name = 'Asante'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 3
  AND per.first_name = 'Philip' AND per.last_name = 'Atbashyan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 3
  AND per.first_name = 'Bljedi' AND per.last_name = 'Bardic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 3
  AND per.first_name = 'Kemal' AND per.last_name = 'Brkanovic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 3
  AND per.first_name = 'Cesare' AND per.last_name = 'Rosario Cali'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 3
  AND per.first_name = 'Enrico' AND per.last_name = 'Desantis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 3
  AND per.first_name = 'Yuriy' AND per.last_name = 'Fedash'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 3
  AND per.first_name = 'Ady' AND per.last_name = 'Gaye'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 3
  AND per.first_name = 'Christopher' AND per.last_name = 'Gjini'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 3
  AND per.first_name = 'Peter' AND per.last_name = 'Nikolle Gjini'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 3
  AND per.first_name = 'Amir' AND per.last_name = 'Islami'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 3
  AND per.first_name = 'Jonard' AND per.last_name = 'Kadriu'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 3
  AND per.first_name = 'Marcin' AND per.last_name = 'Klim'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 3
  AND per.first_name = 'Ronaldo' AND per.last_name = 'Kocaj'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 3
  AND per.first_name = 'Florian' AND per.last_name = 'Krivca'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 3
  AND per.first_name = 'Ryan' AND per.last_name = 'Layman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 3
  AND per.first_name = 'Albert' AND per.last_name = 'Sadiku'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 3
  AND per.first_name = 'Valeriy' AND per.last_name = 'Anatoly Saramoutin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 3
  AND per.first_name = 'Mark' AND per.last_name = 'Shnadshteyn'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 3
  AND per.first_name = 'Jacob' AND per.last_name = 'Szumanski'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 3
  AND per.first_name = 'Logan' AND per.last_name = 'Tassin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 3
  AND per.first_name = 'Dominik' AND per.last_name = 'Urban'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 3
  AND per.first_name = 'Alban' AND per.last_name = 'Zekaj'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 3
  AND per.first_name = 'Peter' AND per.last_name = 'Zima'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC II' AND t.source_system_id = 3
  AND per.first_name = 'Pedro' AND per.last_name = 'Borgono'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC II' AND t.source_system_id = 3
  AND per.first_name = 'Danil' AND per.last_name = 'Bourtsev'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC II' AND t.source_system_id = 3
  AND per.first_name = 'Edin' AND per.last_name = 'Bracic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC II' AND t.source_system_id = 3
  AND per.first_name = 'Halid' AND per.last_name = 'Brkanovic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC II' AND t.source_system_id = 3
  AND per.first_name = 'Juan' AND per.last_name = 'Cruz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC II' AND t.source_system_id = 3
  AND per.first_name = 'Ronald' AND per.last_name = 'Cumbal'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC II' AND t.source_system_id = 3
  AND per.first_name = 'Suad' AND per.last_name = 'Djeka'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC II' AND t.source_system_id = 3
  AND per.first_name = 'Youssef' AND per.last_name = 'Elshammaa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC II' AND t.source_system_id = 3
  AND per.first_name = 'Wessam' AND per.last_name = 'Wael Eshak Ghali Farag'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC II' AND t.source_system_id = 3
  AND per.first_name = 'Jonathan' AND per.last_name = 'Mitchel Firensteyn'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC II' AND t.source_system_id = 3
  AND per.first_name = 'Daniel' AND per.last_name = 'Samuel Fomenko'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC II' AND t.source_system_id = 3
  AND per.first_name = 'Mesut' AND per.last_name = 'Gulluce'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC II' AND t.source_system_id = 3
  AND per.first_name = 'James' AND per.last_name = 'Haddad'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC II' AND t.source_system_id = 3
  AND per.first_name = 'Bledar' AND per.last_name = 'Kovaci'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC II' AND t.source_system_id = 3
  AND per.first_name = 'Balsha' AND per.last_name = 'Maric'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC II' AND t.source_system_id = 3
  AND per.first_name = 'Idriz' AND per.last_name = 'Metovic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC II' AND t.source_system_id = 3
  AND per.first_name = 'Sedat' AND per.last_name = 'Musovski'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC II' AND t.source_system_id = 3
  AND per.first_name = 'Boniface' AND per.last_name = 'Didier Mvondo Messi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC II' AND t.source_system_id = 3
  AND per.first_name = 'Mohamed' AND per.last_name = 'Ndao'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC II' AND t.source_system_id = 3
  AND per.first_name = 'Cristiano' AND per.last_name = 'Alex Oliveira'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC II' AND t.source_system_id = 3
  AND per.first_name = 'Andrea' AND per.last_name = 'Francesco Ruggiero'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC II' AND t.source_system_id = 3
  AND per.first_name = 'Julio' AND per.last_name = 'Sanchez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC II' AND t.source_system_id = 3
  AND per.first_name = 'Phil' AND per.last_name = 'Szumanski'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC II' AND t.source_system_id = 3
  AND per.first_name = 'Daniel' AND per.last_name = 'Tsygankov'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC II' AND t.source_system_id = 3
  AND per.first_name = 'Edwin' AND per.last_name = 'Varghese'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC II' AND t.source_system_id = 3
  AND per.first_name = 'Yoni' AND per.last_name = 'Zakoshansky'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC II' AND t.source_system_id = 3
  AND per.first_name = 'Jakub' AND per.last_name = 'Zima'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Ridgewood Romac SC' AND t.source_system_id = 3
  AND per.first_name = 'Serkan' AND per.last_name = 'Akin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Ridgewood Romac SC' AND t.source_system_id = 3
  AND per.first_name = 'Dani' AND per.last_name = 'Anton'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Ridgewood Romac SC' AND t.source_system_id = 3
  AND per.first_name = 'Robert' AND per.last_name = 'Badacsonyi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Ridgewood Romac SC' AND t.source_system_id = 3
  AND per.first_name = 'Ayhan' AND per.last_name = 'Bekdemir'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Ridgewood Romac SC' AND t.source_system_id = 3
  AND per.first_name = 'Vlad' AND per.last_name = 'Stefan Bicu'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Ridgewood Romac SC' AND t.source_system_id = 3
  AND per.first_name = 'Bujor' AND per.last_name = 'Botas'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Ridgewood Romac SC' AND t.source_system_id = 3
  AND per.first_name = 'Dani' AND per.last_name = 'Ceabuca'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Ridgewood Romac SC' AND t.source_system_id = 3
  AND per.first_name = 'Cristian' AND per.last_name = 'Costea'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Ridgewood Romac SC' AND t.source_system_id = 3
  AND per.first_name = 'Horia' AND per.last_name = 'Crisan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Ridgewood Romac SC' AND t.source_system_id = 3
  AND per.first_name = 'Dorin' AND per.last_name = 'Dican'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Ridgewood Romac SC' AND t.source_system_id = 3
  AND per.first_name = 'Ray' AND per.last_name = 'M Franks'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Ridgewood Romac SC' AND t.source_system_id = 3
  AND per.first_name = 'Andras' AND per.last_name = 'Gnandt'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Ridgewood Romac SC' AND t.source_system_id = 3
  AND per.first_name = 'Dragos' AND per.last_name = 'Herinean'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Ridgewood Romac SC' AND t.source_system_id = 3
  AND per.first_name = 'Catalin' AND per.last_name = 'Ionita'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Ridgewood Romac SC' AND t.source_system_id = 3
  AND per.first_name = 'Mihai' AND per.last_name = 'Macioca'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Ridgewood Romac SC' AND t.source_system_id = 3
  AND per.first_name = 'Ivan' AND per.last_name = 'Nino Matteoni'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Ridgewood Romac SC' AND t.source_system_id = 3
  AND per.first_name = 'BRIAN' AND per.last_name = 'MCFARLAND'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Ridgewood Romac SC' AND t.source_system_id = 3
  AND per.first_name = 'Nitu' AND per.last_name = 'Marius Nicolas'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Ridgewood Romac SC' AND t.source_system_id = 3
  AND per.first_name = 'Ovidiu' AND per.last_name = 'Ordean'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Ridgewood Romac SC' AND t.source_system_id = 3
  AND per.first_name = 'Edwin' AND per.last_name = 'Pino'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Ridgewood Romac SC' AND t.source_system_id = 3
  AND per.first_name = 'Mircea' AND per.last_name = 'Pirvu'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Ridgewood Romac SC' AND t.source_system_id = 3
  AND per.first_name = 'Gheorghe' AND per.last_name = 'Radulescu'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Ridgewood Romac SC' AND t.source_system_id = 3
  AND per.first_name = 'Iulian' AND per.last_name = 'Sassu'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Ridgewood Romac SC' AND t.source_system_id = 3
  AND per.first_name = 'Sergii' AND per.last_name = 'Savinykh'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Ridgewood Romac SC' AND t.source_system_id = 3
  AND per.first_name = 'Laurentiu' AND per.last_name = 'Surca'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Ridgewood Romac SC' AND t.source_system_id = 3
  AND per.first_name = 'Bosko' AND per.last_name = 'Trifunovic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Ridgewood Romac SC' AND t.source_system_id = 3
  AND per.first_name = 'Daniel' AND per.last_name = 'Voccia'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht' AND t.source_system_id = 3
  AND per.first_name = 'Ahmed' AND per.last_name = 'Adam'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht' AND t.source_system_id = 3
  AND per.first_name = 'Ilyan' AND per.last_name = 'Bacar Said'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht' AND t.source_system_id = 3
  AND per.first_name = 'Mikayil' AND per.last_name = 'Bacar Said'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht' AND t.source_system_id = 3
  AND per.first_name = 'Rhys' AND per.last_name = 'Bucknor'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht' AND t.source_system_id = 3
  AND per.first_name = 'Romahl' AND per.last_name = 'Bucknor'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht' AND t.source_system_id = 3
  AND per.first_name = 'Yigit' AND per.last_name = 'Cercioglu'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht' AND t.source_system_id = 3
  AND per.first_name = 'Tyler' AND per.last_name = 'Clarke'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht' AND t.source_system_id = 3
  AND per.first_name = 'Sikou' AND per.last_name = 'Drame'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht' AND t.source_system_id = 3
  AND per.first_name = 'Franklin' AND per.last_name = 'Encalada'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht' AND t.source_system_id = 3
  AND per.first_name = 'Carlos' AND per.last_name = 'Fernandez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht' AND t.source_system_id = 3
  AND per.first_name = 'Dominic' AND per.last_name = 'Roberto Florian Yoshinaga'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht' AND t.source_system_id = 3
  AND per.first_name = 'William' AND per.last_name = 'Kim'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht' AND t.source_system_id = 3
  AND per.first_name = 'Badjan' AND per.last_name = 'Kourouma'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht' AND t.source_system_id = 3
  AND per.first_name = 'Karifala' AND per.last_name = 'Kromah'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht' AND t.source_system_id = 3
  AND per.first_name = 'Nvafay' AND per.last_name = 'Kromah'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht' AND t.source_system_id = 3
  AND per.first_name = 'Justin' AND per.last_name = 'Lee'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht' AND t.source_system_id = 3
  AND per.first_name = 'Emmanuel' AND per.last_name = 'Leon'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht' AND t.source_system_id = 3
  AND per.first_name = 'Jaquan' AND per.last_name = 'Linton'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht' AND t.source_system_id = 3
  AND per.first_name = 'Hosny' AND per.last_name = 'Makhlof'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht' AND t.source_system_id = 3
  AND per.first_name = 'Dylan' AND per.last_name = 'Morales'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht' AND t.source_system_id = 3
  AND per.first_name = 'Devin' AND per.last_name = 'Mulic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht' AND t.source_system_id = 3
  AND per.first_name = 'Fernando' AND per.last_name = 'Orellana'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht' AND t.source_system_id = 3
  AND per.first_name = 'Jamal' AND per.last_name = 'Seecharran'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht' AND t.source_system_id = 3
  AND per.first_name = 'Benjamin' AND per.last_name = 'Seidl'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht' AND t.source_system_id = 3
  AND per.first_name = 'Tyler' AND per.last_name = 'Swaby'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht' AND t.source_system_id = 3
  AND per.first_name = 'Jonathan' AND per.last_name = 'Villacis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht' AND t.source_system_id = 3
  AND per.first_name = 'Mark' AND per.last_name = 'Villacis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
  AND per.first_name = 'Damir' AND per.last_name = 'Adrovic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
  AND per.first_name = 'Denis' AND per.last_name = 'Adrovic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
  AND per.first_name = 'Kwamina' AND per.last_name = 'Afful'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
  AND per.first_name = 'Dorel' AND per.last_name = 'Ardeljan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
  AND per.first_name = 'Dwight' AND per.last_name = 'Barriga'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
  AND per.first_name = 'Mark' AND per.last_name = 'Bojbasa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
  AND per.first_name = 'Joseph' AND per.last_name = 'Gazca Gonzalez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
  AND per.first_name = 'Juan' AND per.last_name = 'Carlos Gomez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
  AND per.first_name = 'Victor' AND per.last_name = 'Guaiquil'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
  AND per.first_name = 'Chris' AND per.last_name = 'Impey'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
  AND per.first_name = 'Alejandro' AND per.last_name = 'Jaramillo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
  AND per.first_name = 'Derek' AND per.last_name = 'Kelly'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
  AND per.first_name = 'Federico' AND per.last_name = 'LaFemina'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
  AND per.first_name = 'Gianni' AND per.last_name = 'Laverde'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
  AND per.first_name = 'Mark' AND per.last_name = 'Lesser'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
  AND per.first_name = 'Eugene' AND per.last_name = 'Lotrean'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
  AND per.first_name = 'Adrian' AND per.last_name = 'Mendez-Toledo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
  AND per.first_name = 'Hermilo' AND per.last_name = 'Morales'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
  AND per.first_name = 'Leonardo' AND per.last_name = 'Morales'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
  AND per.first_name = 'Milton' AND per.last_name = 'Ospina'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
  AND per.first_name = 'Maiber' AND per.last_name = 'Polanco'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
  AND per.first_name = 'Luis' AND per.last_name = 'Ramirez-Rios'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
  AND per.first_name = 'Hasan' AND per.last_name = 'Redzic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
  AND per.first_name = 'Martin' AND per.last_name = 'Russo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
  AND per.first_name = 'Jason' AND per.last_name = 'Stockdale'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
  AND per.first_name = 'Gabriel' AND per.last_name = 'Tapalaga'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
  AND per.first_name = 'Yuki' AND per.last_name = 'Tominaga'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
  AND per.first_name = 'Vinicius' AND per.last_name = 'Vasconcelos'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht Legends' AND t.source_system_id = 3
  AND per.first_name = 'Stephen' AND per.last_name = 'Zimmerman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht II' AND t.source_system_id = 3
  AND per.first_name = 'Wadson' AND per.last_name = 'Andrice'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht II' AND t.source_system_id = 3
  AND per.first_name = 'Charlie' AND per.last_name = 'Canales'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht II' AND t.source_system_id = 3
  AND per.first_name = 'Esteban' AND per.last_name = 'De La Cuesta'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht II' AND t.source_system_id = 3
  AND per.first_name = 'Javier' AND per.last_name = 'Eguidazu'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht II' AND t.source_system_id = 3
  AND per.first_name = 'Juan' AND per.last_name = 'Pablo Faican'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht II' AND t.source_system_id = 3
  AND per.first_name = 'Dara' AND per.last_name = 'Gilligan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht II' AND t.source_system_id = 3
  AND per.first_name = 'Franco' AND per.last_name = 'Hernandez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht II' AND t.source_system_id = 3
  AND per.first_name = 'Kairui' AND per.last_name = 'Huang'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht II' AND t.source_system_id = 3
  AND per.first_name = 'Kevin' AND per.last_name = 'Iraheta'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht II' AND t.source_system_id = 3
  AND per.first_name = 'Noah' AND per.last_name = 'Jarosh'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht II' AND t.source_system_id = 3
  AND per.first_name = 'Alex' AND per.last_name = 'Khachaturian'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht II' AND t.source_system_id = 3
  AND per.first_name = 'Sekou' AND per.last_name = 'Kromah'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht II' AND t.source_system_id = 3
  AND per.first_name = 'Hugo' AND per.last_name = 'Leon'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht II' AND t.source_system_id = 3
  AND per.first_name = 'Arthur' AND per.last_name = 'Li'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht II' AND t.source_system_id = 3
  AND per.first_name = 'Andrea' AND per.last_name = 'Mazzella'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht II' AND t.source_system_id = 3
  AND per.first_name = 'Gabriel' AND per.last_name = 'Montoya'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht II' AND t.source_system_id = 3
  AND per.first_name = 'Guido' AND per.last_name = 'Moreira'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht II' AND t.source_system_id = 3
  AND per.first_name = 'Macoumba' AND per.last_name = 'Ndiaye'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht II' AND t.source_system_id = 3
  AND per.first_name = 'Elijah' AND per.last_name = 'Oliveros-Rosen'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht II' AND t.source_system_id = 3
  AND per.first_name = 'Ayodeji' AND per.last_name = 'Omoogun'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht II' AND t.source_system_id = 3
  AND per.first_name = 'Matthew' AND per.last_name = 'Ovanessian'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht II' AND t.source_system_id = 3
  AND per.first_name = 'Guillermo' AND per.last_name = 'Paulino'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht II' AND t.source_system_id = 3
  AND per.first_name = 'Andrew' AND per.last_name = 'Powell'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht II' AND t.source_system_id = 3
  AND per.first_name = 'Ronny' AND per.last_name = 'Quiroz Yubis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht II' AND t.source_system_id = 3
  AND per.first_name = 'Dzenan' AND per.last_name = 'Redzic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht II' AND t.source_system_id = 3
  AND per.first_name = 'Miles' AND per.last_name = 'Thomas-Moore'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht II' AND t.source_system_id = 3
  AND per.first_name = 'Taheer' AND per.last_name = 'Wilane'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht II' AND t.source_system_id = 3
  AND per.first_name = 'Alfredo' AND per.last_name = 'Zapata'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Eintracht II' AND t.source_system_id = 3
  AND per.first_name = 'Jorge' AND per.last_name = 'Zoilan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Over-40' AND t.source_system_id = 3
  AND per.first_name = 'Gregg' AND per.last_name = 'Bergstrom'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Over-40' AND t.source_system_id = 3
  AND per.first_name = 'Rohan' AND per.last_name = 'Bogle'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Over-40' AND t.source_system_id = 3
  AND per.first_name = 'Julian' AND per.last_name = 'Brookes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Over-40' AND t.source_system_id = 3
  AND per.first_name = 'John' AND per.last_name = 'Devaney'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Over-40' AND t.source_system_id = 3
  AND per.first_name = 'Jan' AND per.last_name = 'Fiedler'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Over-40' AND t.source_system_id = 3
  AND per.first_name = 'Joseph' AND per.last_name = 'Golden'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Over-40' AND t.source_system_id = 3
  AND per.first_name = 'Jereme' AND per.last_name = 'Greensword'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Over-40' AND t.source_system_id = 3
  AND per.first_name = 'Leonardo' AND per.last_name = 'Gutierrez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Over-40' AND t.source_system_id = 3
  AND per.first_name = 'Sujay' AND per.last_name = 'Jhaveri'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Over-40' AND t.source_system_id = 3
  AND per.first_name = 'Martin' AND per.last_name = 'Kocourek'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Over-40' AND t.source_system_id = 3
  AND per.first_name = 'Daniel' AND per.last_name = 'Krygier'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Over-40' AND t.source_system_id = 3
  AND per.first_name = 'Andrew' AND per.last_name = 'Kurth'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Over-40' AND t.source_system_id = 3
  AND per.first_name = 'Lukasz' AND per.last_name = 'Leja'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Over-40' AND t.source_system_id = 3
  AND per.first_name = 'Frederic' AND per.last_name = 'Levrat'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Over-40' AND t.source_system_id = 3
  AND per.first_name = 'Julio' AND per.last_name = 'Marchant'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Over-40' AND t.source_system_id = 3
  AND per.first_name = 'Jeffrey' AND per.last_name = 'Mayer'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Over-40' AND t.source_system_id = 3
  AND per.first_name = 'Thomas' AND per.last_name = 'Mlcuch'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Over-40' AND t.source_system_id = 3
  AND per.first_name = 'GEORGE' AND per.last_name = 'MURRAY'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Over-40' AND t.source_system_id = 3
  AND per.first_name = 'Morris' AND per.last_name = 'Neil'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Over-40' AND t.source_system_id = 3
  AND per.first_name = 'Zdenek' AND per.last_name = 'Pecka'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Over-40' AND t.source_system_id = 3
  AND per.first_name = 'Julio' AND per.last_name = 'Penagos'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Over-40' AND t.source_system_id = 3
  AND per.first_name = 'Michael' AND per.last_name = 'Piscitello'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Over-40' AND t.source_system_id = 3
  AND per.first_name = 'Christian' AND per.last_name = 'Powers'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Over-40' AND t.source_system_id = 3
  AND per.first_name = 'Robert' AND per.last_name = 'Rossicone'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Over-40' AND t.source_system_id = 3
  AND per.first_name = 'Samir' AND per.last_name = 'Selmani'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Over-40' AND t.source_system_id = 3
  AND per.first_name = 'Joseph' AND per.last_name = 'Stein'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Over-40' AND t.source_system_id = 3
  AND per.first_name = 'Javier' AND per.last_name = 'Valdes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Over-40' AND t.source_system_id = 3
  AND per.first_name = 'Marvin' AND per.last_name = 'Vargas'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Over-40' AND t.source_system_id = 3
  AND per.first_name = 'Jian' AND per.last_name = 'WU'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Stal Mielec NY' AND t.source_system_id = 3
  AND per.first_name = 'Slawomir' AND per.last_name = 'Balon'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Stal Mielec NY' AND t.source_system_id = 3
  AND per.first_name = 'Pawel' AND per.last_name = 'Basisty'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Stal Mielec NY' AND t.source_system_id = 3
  AND per.first_name = 'Pawel' AND per.last_name = 'Borek'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Stal Mielec NY' AND t.source_system_id = 3
  AND per.first_name = 'Mateusz' AND per.last_name = 'Chlost'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Stal Mielec NY' AND t.source_system_id = 3
  AND per.first_name = 'Piotr' AND per.last_name = 'Dublicki'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Stal Mielec NY' AND t.source_system_id = 3
  AND per.first_name = 'Filip' AND per.last_name = 'Glowala'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Stal Mielec NY' AND t.source_system_id = 3
  AND per.first_name = 'Sebastian' AND per.last_name = 'Gostynski'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Stal Mielec NY' AND t.source_system_id = 3
  AND per.first_name = 'Lukasz' AND per.last_name = 'Haunser'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Stal Mielec NY' AND t.source_system_id = 3
  AND per.first_name = 'Piotr' AND per.last_name = 'Holda'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Stal Mielec NY' AND t.source_system_id = 3
  AND per.first_name = 'Marcin' AND per.last_name = 'Jaworek'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Stal Mielec NY' AND t.source_system_id = 3
  AND per.first_name = 'Mateusz' AND per.last_name = 'Kulpa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Stal Mielec NY' AND t.source_system_id = 3
  AND per.first_name = 'Jacek' AND per.last_name = 'Lawniczak'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Stal Mielec NY' AND t.source_system_id = 3
  AND per.first_name = 'Patryk' AND per.last_name = 'Majkut'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Stal Mielec NY' AND t.source_system_id = 3
  AND per.first_name = 'Pawel' AND per.last_name = 'Marczenia'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Stal Mielec NY' AND t.source_system_id = 3
  AND per.first_name = 'Mateusz' AND per.last_name = 'Osiecki'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Stal Mielec NY' AND t.source_system_id = 3
  AND per.first_name = 'Jakub' AND per.last_name = 'Szwakop'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Stal Mielec NY' AND t.source_system_id = 3
  AND per.first_name = 'Jakub' AND per.last_name = 'Zajac'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Stal Mielec NY II' AND t.source_system_id = 3
  AND per.first_name = 'Norbert' AND per.last_name = 'Bidzinski'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Stal Mielec NY II' AND t.source_system_id = 3
  AND per.first_name = 'Mateusz' AND per.last_name = 'Chwiejczak'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Stal Mielec NY II' AND t.source_system_id = 3
  AND per.first_name = 'Dariusz' AND per.last_name = 'Cioczek'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Stal Mielec NY II' AND t.source_system_id = 3
  AND per.first_name = 'Dawid' AND per.last_name = 'Drozd'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Stal Mielec NY II' AND t.source_system_id = 3
  AND per.first_name = 'Pawel' AND per.last_name = 'GaIanek'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Stal Mielec NY II' AND t.source_system_id = 3
  AND per.first_name = 'Piotr' AND per.last_name = 'Galanek'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Stal Mielec NY II' AND t.source_system_id = 3
  AND per.first_name = 'jacek' AND per.last_name = 'korba'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Stal Mielec NY II' AND t.source_system_id = 3
  AND per.first_name = 'Pawel' AND per.last_name = 'Koziura'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Stal Mielec NY II' AND t.source_system_id = 3
  AND per.first_name = 'Radoslaw' AND per.last_name = 'Ksepka'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Stal Mielec NY II' AND t.source_system_id = 3
  AND per.first_name = 'Rafal' AND per.last_name = 'Kulpa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Stal Mielec NY II' AND t.source_system_id = 3
  AND per.first_name = 'Wojciech' AND per.last_name = 'Kwolek'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Stal Mielec NY II' AND t.source_system_id = 3
  AND per.first_name = 'Dawid' AND per.last_name = 'Lis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Stal Mielec NY II' AND t.source_system_id = 3
  AND per.first_name = 'Krzysztof' AND per.last_name = 'Majkut'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Stal Mielec NY II' AND t.source_system_id = 3
  AND per.first_name = 'Piotr' AND per.last_name = 'Nakoneczny'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Stal Mielec NY II' AND t.source_system_id = 3
  AND per.first_name = 'Karol' AND per.last_name = 'Obidzinski'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Stal Mielec NY II' AND t.source_system_id = 3
  AND per.first_name = 'Piotr' AND per.last_name = 'Olszowy'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Stal Mielec NY II' AND t.source_system_id = 3
  AND per.first_name = 'Waldemar' AND per.last_name = 'Pyryt'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Stal Mielec NY II' AND t.source_system_id = 3
  AND per.first_name = 'Slawomir' AND per.last_name = 'Styka'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Stal Mielec NY II' AND t.source_system_id = 3
  AND per.first_name = 'Jakub' AND per.last_name = 'Subernat'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Stal Mielec NY II' AND t.source_system_id = 3
  AND per.first_name = 'Krzysztof' AND per.last_name = 'Subernat'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Stal Mielec NY II' AND t.source_system_id = 3
  AND per.first_name = 'Pawel' AND per.last_name = 'Subernat'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Stal Mielec NY II' AND t.source_system_id = 3
  AND per.first_name = 'David' AND per.last_name = 'Vetrovec'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Stal Mielec NY II' AND t.source_system_id = 3
  AND per.first_name = 'Michael' AND per.last_name = 'Wolowiec'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Stal Mielec NY II' AND t.source_system_id = 3
  AND per.first_name = 'Kevin' AND per.last_name = 'Zielinski'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Yellow Hook' AND t.source_system_id = 3
  AND per.first_name = 'Elhadj' AND per.last_name = 'Bah'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Yellow Hook' AND t.source_system_id = 3
  AND per.first_name = 'Geovanni' AND per.last_name = 'Bennett'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Yellow Hook' AND t.source_system_id = 3
  AND per.first_name = 'Pierre' AND per.last_name = 'Julien Blouin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Yellow Hook' AND t.source_system_id = 3
  AND per.first_name = 'Papa' AND per.last_name = 'Gueye'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Yellow Hook' AND t.source_system_id = 3
  AND per.first_name = 'Daniel' AND per.last_name = 'Hackett'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Yellow Hook' AND t.source_system_id = 3
  AND per.first_name = 'Jonathan' AND per.last_name = 'Hincapie'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Yellow Hook' AND t.source_system_id = 3
  AND per.first_name = 'Orwin' AND per.last_name = 'Hunte'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Yellow Hook' AND t.source_system_id = 3
  AND per.first_name = 'Jesus' AND per.last_name = 'Jimenez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Yellow Hook' AND t.source_system_id = 3
  AND per.first_name = 'Jevaughn' AND per.last_name = 'Lamont'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Yellow Hook' AND t.source_system_id = 3
  AND per.first_name = 'John' AND per.last_name = 'Luc'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Yellow Hook' AND t.source_system_id = 3
  AND per.first_name = 'Kevin' AND per.last_name = 'Mackin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Yellow Hook' AND t.source_system_id = 3
  AND per.first_name = 'Walter' AND per.last_name = 'Medina'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Yellow Hook' AND t.source_system_id = 3
  AND per.first_name = 'Javier' AND per.last_name = 'Munguia'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Yellow Hook' AND t.source_system_id = 3
  AND per.first_name = 'Arseni' AND per.last_name = 'Nazaruk'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Yellow Hook' AND t.source_system_id = 3
  AND per.first_name = 'Temur' AND per.last_name = 'Oshakmashvili'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Yellow Hook' AND t.source_system_id = 3
  AND per.first_name = 'Kevin' AND per.last_name = 'Pluviose'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Yellow Hook' AND t.source_system_id = 3
  AND per.first_name = 'Mark' AND per.last_name = 'Rodgers'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Yellow Hook' AND t.source_system_id = 3
  AND per.first_name = 'Ryuji' AND per.last_name = 'Sugiyama'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Yellow Hook' AND t.source_system_id = 3
  AND per.first_name = 'Connor' AND per.last_name = 'Sullivan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Yellow Hook' AND t.source_system_id = 3
  AND per.first_name = 'Michael' AND per.last_name = 'Tarallo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Yellow Hook' AND t.source_system_id = 3
  AND per.first_name = 'Christian' AND per.last_name = 'Whitney-Smith'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Yellow Hook' AND t.source_system_id = 3
  AND per.first_name = 'Julian' AND per.last_name = 'Zamora'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Yellow Hook' AND t.source_system_id = 3
  AND per.first_name = 'David' AND per.last_name = 'Zlobinsky'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Tibet FC' AND t.source_system_id = 3
  AND per.first_name = 'Karma' AND per.last_name = 'Bhutia'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Tibet FC' AND t.source_system_id = 3
  AND per.first_name = 'Tenzing' AND per.last_name = 'Chodek'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Tibet FC' AND t.source_system_id = 3
  AND per.first_name = 'Tharchen' AND per.last_name = 'Dhondup'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Tibet FC' AND t.source_system_id = 3
  AND per.first_name = 'Tsering' AND per.last_name = 'Dhondup'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Tibet FC' AND t.source_system_id = 3
  AND per.first_name = 'Karma' AND per.last_name = 'Dorjee'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Tibet FC' AND t.source_system_id = 3
  AND per.first_name = 'Norbu' AND per.last_name = 'Dorjee'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Tibet FC' AND t.source_system_id = 3
  AND per.first_name = 'Tenzin' AND per.last_name = 'Gonpo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Tibet FC' AND t.source_system_id = 3
  AND per.first_name = 'Sarlav' AND per.last_name = 'Gurung'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Tibet FC' AND t.source_system_id = 3
  AND per.first_name = 'Sujan' AND per.last_name = 'Gurung'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Tibet FC' AND t.source_system_id = 3
  AND per.first_name = 'Tenzin' AND per.last_name = 'Jigmey'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Tibet FC' AND t.source_system_id = 3
  AND per.first_name = 'KC' AND per.last_name = 'Bikash Jung'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Tibet FC' AND t.source_system_id = 3
  AND per.first_name = 'Karma' AND per.last_name = 'Rinchen Kalsang'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Tibet FC' AND t.source_system_id = 3
  AND per.first_name = 'Phuntsok' AND per.last_name = 'Nyima Lama'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Tibet FC' AND t.source_system_id = 3
  AND per.first_name = 'Tenzin' AND per.last_name = 'Loden'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Tibet FC' AND t.source_system_id = 3
  AND per.first_name = 'Tashi' AND per.last_name = 'Mingmar'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Tibet FC' AND t.source_system_id = 3
  AND per.first_name = 'Tenzin' AND per.last_name = 'Nyinjey'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Tibet FC' AND t.source_system_id = 3
  AND per.first_name = 'Lopsang' AND per.last_name = 'Palden'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Tibet FC' AND t.source_system_id = 3
  AND per.first_name = 'Tashi' AND per.last_name = 'Palden'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Tibet FC' AND t.source_system_id = 3
  AND per.first_name = 'Pomo' AND per.last_name = 'Limbu Paruhang'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Tibet FC' AND t.source_system_id = 3
  AND per.first_name = 'Tenzin' AND per.last_name = 'Samdup'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Tibet FC' AND t.source_system_id = 3
  AND per.first_name = 'Kunga' AND per.last_name = 'Sangpo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Tibet FC' AND t.source_system_id = 3
  AND per.first_name = 'Brian' AND per.last_name = 'Sherpa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Tibet FC' AND t.source_system_id = 3
  AND per.first_name = 'Kunsang' AND per.last_name = 'Tenzin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Tibet FC' AND t.source_system_id = 3
  AND per.first_name = 'Tenzing' AND per.last_name = 'Thabkhe'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Tibet FC' AND t.source_system_id = 3
  AND per.first_name = 'Tenzin' AND per.last_name = 'Tsephel'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Tibet FC' AND t.source_system_id = 3
  AND per.first_name = 'Penpa' AND per.last_name = 'Tsering'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Tibet FC' AND t.source_system_id = 3
  AND per.first_name = 'Tenzin' AND per.last_name = 'Tsering'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Tibet FC' AND t.source_system_id = 3
  AND per.first_name = 'Tenzin' AND per.last_name = 'Yonden'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Tibet FC' AND t.source_system_id = 3
  AND per.first_name = 'Tenzin' AND per.last_name = 'Yonten'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC' AND t.source_system_id = 3
  AND per.first_name = 'Jose' AND per.last_name = 'Augustin Aguerre Lopez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC' AND t.source_system_id = 3
  AND per.first_name = 'Santiago' AND per.last_name = 'Alejandro Alvarado'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC' AND t.source_system_id = 3
  AND per.first_name = 'Albinot' AND per.last_name = 'Berisha'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC' AND t.source_system_id = 3
  AND per.first_name = 'Christopher' AND per.last_name = 'Blivin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC' AND t.source_system_id = 3
  AND per.first_name = 'Zachary' AND per.last_name = 'Braverman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC' AND t.source_system_id = 3
  AND per.first_name = 'Benjamin' AND per.last_name = 'Citrin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC' AND t.source_system_id = 3
  AND per.first_name = 'Simon' AND per.last_name = 'Rodrigo Espinosa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC' AND t.source_system_id = 3
  AND per.first_name = 'Sam' AND per.last_name = 'Farman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC' AND t.source_system_id = 3
  AND per.first_name = 'Steven' AND per.last_name = 'Flinchbaugh'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC' AND t.source_system_id = 3
  AND per.first_name = 'Austin' AND per.last_name = 'Hafizi Font'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC' AND t.source_system_id = 3
  AND per.first_name = 'Eduardo' AND per.last_name = 'Garcia'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC' AND t.source_system_id = 3
  AND per.first_name = 'Levan' AND per.last_name = 'Gulbatashvili'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC' AND t.source_system_id = 3
  AND per.first_name = 'Tornike' AND per.last_name = 'Gurulishvili'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC' AND t.source_system_id = 3
  AND per.first_name = 'Nicholas' AND per.last_name = 'Hilton'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC' AND t.source_system_id = 3
  AND per.first_name = 'Onur' AND per.last_name = 'Ilingi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC' AND t.source_system_id = 3
  AND per.first_name = 'John' AND per.last_name = 'Kaddo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC' AND t.source_system_id = 3
  AND per.first_name = 'Alec' AND per.last_name = 'Kaminer'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC' AND t.source_system_id = 3
  AND per.first_name = 'Vasil' AND per.last_name = 'Maruashvili'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC' AND t.source_system_id = 3
  AND per.first_name = 'Bob' AND per.last_name = 'Milenovici'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC' AND t.source_system_id = 3
  AND per.first_name = 'Connor' AND per.last_name = 'Miller'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC' AND t.source_system_id = 3
  AND per.first_name = 'Vasia' AND per.last_name = 'Patov'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC' AND t.source_system_id = 3
  AND per.first_name = 'David' AND per.last_name = 'Ignacio Rodriguez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC' AND t.source_system_id = 3
  AND per.first_name = 'Mark' AND per.last_name = 'Schuber'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC' AND t.source_system_id = 3
  AND per.first_name = 'Jordan' AND per.last_name = 'Trott'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC' AND t.source_system_id = 3
  AND per.first_name = 'Gerrit' AND per.last_name = 'van den Berg'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC' AND t.source_system_id = 3
  AND per.first_name = 'Gabriel' AND per.last_name = 'Vasconcelos'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC' AND t.source_system_id = 3
  AND per.first_name = 'David' AND per.last_name = 'Vogt'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC' AND t.source_system_id = 3
  AND per.first_name = 'Rex' AND per.last_name = 'Walsh'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC' AND t.source_system_id = 3
  AND per.first_name = 'James' AND per.last_name = 'Walters'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
  AND per.first_name = 'Connor' AND per.last_name = 'Almon'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
  AND per.first_name = 'Jesus' AND per.last_name = 'Andrade'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
  AND per.first_name = 'Turner' AND per.last_name = 'Baker'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
  AND per.first_name = 'Nicolas' AND per.last_name = 'Ballester'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
  AND per.first_name = 'Pablo' AND per.last_name = 'Gabriel Barajas'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
  AND per.first_name = 'Nevin' AND per.last_name = 'Spring Bernet'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
  AND per.first_name = 'Conrado' AND per.last_name = 'Werner Briceno'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
  AND per.first_name = 'Joseph' AND per.last_name = 'Cascio'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
  AND per.first_name = 'Arun' AND per.last_name = 'Chaudhuri'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
  AND per.first_name = 'Blaiberg' AND per.last_name = 'Chicoma'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
  AND per.first_name = 'Mark' AND per.last_name = 'Gallagher'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
  AND per.first_name = 'Trevin' AND per.last_name = 'Hicks'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
  AND per.first_name = 'Justin' AND per.last_name = 'Kugel'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
  AND per.first_name = 'Tun' AND per.last_name = 'Tun Linn'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
  AND per.first_name = 'Brendan' AND per.last_name = 'M McGaley'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
  AND per.first_name = 'Israel' AND per.last_name = 'Omede'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
  AND per.first_name = 'David' AND per.last_name = 'Park'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
  AND per.first_name = 'Myko' AND per.last_name = 'Pierre'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
  AND per.first_name = 'Shariq' AND per.last_name = 'Rizvi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
  AND per.first_name = 'Adolfo' AND per.last_name = 'Rodriguez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
  AND per.first_name = 'Jason' AND per.last_name = 'Roos'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
  AND per.first_name = 'John' AND per.last_name = 'Shaw'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
  AND per.first_name = 'Alberto' AND per.last_name = 'Torres'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
  AND per.first_name = 'Casey' AND per.last_name = 'Tucker'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
  AND per.first_name = 'Daniel' AND per.last_name = 'Tully'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
  AND per.first_name = 'Anthony' AND per.last_name = 'Valverde'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC III' AND t.source_system_id = 3
  AND per.first_name = 'Shane' AND per.last_name = 'Wynne'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Jacob' AND per.last_name = 'Adler'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Cameron' AND per.last_name = 'Barwick'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Lee' AND per.last_name = 'Bellows'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC II' AND t.source_system_id = 3
  AND per.first_name = 'David' AND per.last_name = 'Bungo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Robin' AND per.last_name = 'Buyer'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Leocciano' AND per.last_name = 'Callao'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Will' AND per.last_name = 'Crum'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Augustus' AND per.last_name = 'Esgro'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Mathew' AND per.last_name = 'Forte'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Mikel' AND per.last_name = 'Gjoni'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Connor' AND per.last_name = 'Hayes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Gaurav' AND per.last_name = 'Hingorani'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Shane' AND per.last_name = 'Lapsys'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Alexander' AND per.last_name = 'Mierzejewski'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Daniel' AND per.last_name = 'Diego Millan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Sumeet' AND per.last_name = 'Patel'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Nathan' AND per.last_name = 'Charles Peifer'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Harry' AND per.last_name = 'Edward Plumptre'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Eduardo' AND per.last_name = 'Ponce'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Haran' AND per.last_name = 'Rajkumar'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Daniel' AND per.last_name = 'Rivas'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Weston' AND per.last_name = 'Rivell'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Samuel' AND per.last_name = 'Sloboda'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Michael' AND per.last_name = 'Spencer'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Paul' AND per.last_name = 'Stephan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Oscar' AND per.last_name = 'Tine'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Williamsburg International FC II' AND t.source_system_id = 3
  AND per.first_name = 'Ernesto' AND per.last_name = 'Trejo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Yemen United SC' AND t.source_system_id = 3
  AND per.first_name = 'Burhan' AND per.last_name = 'Alamisi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Yemen United SC' AND t.source_system_id = 3
  AND per.first_name = 'Husam' AND per.last_name = 'Alayah'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Yemen United SC' AND t.source_system_id = 3
  AND per.first_name = 'Mueataz' AND per.last_name = 'AlBadwi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Yemen United SC' AND t.source_system_id = 3
  AND per.first_name = 'Mohammed' AND per.last_name = 'Alkamel'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Yemen United SC' AND t.source_system_id = 3
  AND per.first_name = 'Kassem' AND per.last_name = 'Alkasimi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Yemen United SC' AND t.source_system_id = 3
  AND per.first_name = 'Maged' AND per.last_name = 'Alkasimi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Yemen United SC' AND t.source_system_id = 3
  AND per.first_name = 'Jahvon' AND per.last_name = 'Allison'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Yemen United SC' AND t.source_system_id = 3
  AND per.first_name = 'Waled' AND per.last_name = 'Alraes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Yemen United SC' AND t.source_system_id = 3
  AND per.first_name = 'Sadam' AND per.last_name = 'Alsaidi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Yemen United SC' AND t.source_system_id = 3
  AND per.first_name = 'Aemad' AND per.last_name = 'Alsayedi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Yemen United SC' AND t.source_system_id = 3
  AND per.first_name = 'Omar' AND per.last_name = 'Amari'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Yemen United SC' AND t.source_system_id = 3
  AND per.first_name = 'Ahmed' AND per.last_name = 'Hassan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Yemen United SC' AND t.source_system_id = 3
  AND per.first_name = 'Mohamed' AND per.last_name = 'kaid'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Yemen United SC' AND t.source_system_id = 3
  AND per.first_name = 'Fuad' AND per.last_name = 'Ali Kasem'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Yemen United SC' AND t.source_system_id = 3
  AND per.first_name = 'Maged' AND per.last_name = 'Mubarez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Yemen United SC' AND t.source_system_id = 3
  AND per.first_name = 'eduardo' AND per.last_name = 'raul naranjo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Yemen United SC' AND t.source_system_id = 3
  AND per.first_name = 'oscar' AND per.last_name = 'ruiz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Yemen United SC' AND t.source_system_id = 3
  AND per.first_name = 'Ibrahim' AND per.last_name = 'Saeed'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Yemen United SC' AND t.source_system_id = 3
  AND per.first_name = 'mohamed' AND per.last_name = 'shahin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Yemen United SC' AND t.source_system_id = 3
  AND per.first_name = 'Christian' AND per.last_name = 'Urgiles'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Yemen United SC' AND t.source_system_id = 3
  AND per.first_name = 'Robert' AND per.last_name = 'Urgiles'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Yemen United SC' AND t.source_system_id = 3
  AND per.first_name = 'Gamil' AND per.last_name = 'Yahya'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Yemen United SC' AND t.source_system_id = 3
  AND per.first_name = 'Omar' AND per.last_name = 'Yahya'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 II' AND t.source_system_id = 3
  AND per.first_name = 'Matel' AND per.last_name = 'Anasta'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 II' AND t.source_system_id = 3
  AND per.first_name = 'Amine' AND per.last_name = 'Benali'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 II' AND t.source_system_id = 3
  AND per.first_name = 'Jhon' AND per.last_name = 'Anderson Blandon Villegas'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 II' AND t.source_system_id = 3
  AND per.first_name = 'Ricky' AND per.last_name = 'Bowry'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 II' AND t.source_system_id = 3
  AND per.first_name = 'Michael' AND per.last_name = 'Cheaney'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 II' AND t.source_system_id = 3
  AND per.first_name = 'Jun' AND per.last_name = 'Cho'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 II' AND t.source_system_id = 3
  AND per.first_name = 'Diego' AND per.last_name = 'Cholula Castro'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 II' AND t.source_system_id = 3
  AND per.first_name = 'Martin' AND per.last_name = 'Dikanovic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 II' AND t.source_system_id = 3
  AND per.first_name = 'Lucas' AND per.last_name = 'Doucette'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 II' AND t.source_system_id = 3
  AND per.first_name = 'Jackson' AND per.last_name = 'Dumont'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 II' AND t.source_system_id = 3
  AND per.first_name = 'Sunny' AND per.last_name = 'Epochi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 II' AND t.source_system_id = 3
  AND per.first_name = 'Rafael' AND per.last_name = 'Gleicher'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 II' AND t.source_system_id = 3
  AND per.first_name = 'Mostafa' AND per.last_name = 'Haridi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 II' AND t.source_system_id = 3
  AND per.first_name = 'Maximilian' AND per.last_name = 'Heuter'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 II' AND t.source_system_id = 3
  AND per.first_name = 'Bobbak' AND per.last_name = 'Khosravi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 II' AND t.source_system_id = 3
  AND per.first_name = 'Jackson' AND per.last_name = 'Menachem'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 II' AND t.source_system_id = 3
  AND per.first_name = 'Aymen' AND per.last_name = 'Mohamed'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 II' AND t.source_system_id = 3
  AND per.first_name = 'Stephen' AND per.last_name = 'Ojo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 II' AND t.source_system_id = 3
  AND per.first_name = 'Conor' AND per.last_name = 'Pellas'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 II' AND t.source_system_id = 3
  AND per.first_name = 'Daniel' AND per.last_name = 'Pesantes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 II' AND t.source_system_id = 3
  AND per.first_name = 'Alex' AND per.last_name = 'Rovirosa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 II' AND t.source_system_id = 3
  AND per.first_name = 'Vladimir' AND per.last_name = 'Sekiguchi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 II' AND t.source_system_id = 3
  AND per.first_name = 'Arkan' AND per.last_name = 'Tahsildaroglu'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 II' AND t.source_system_id = 3
  AND per.first_name = 'Josh' AND per.last_name = 'Ulane'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 II' AND t.source_system_id = 3
  AND per.first_name = 'Samuel' AND per.last_name = 'Urban'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 II' AND t.source_system_id = 3
  AND per.first_name = 'Jeuel' AND per.last_name = 'Ventura'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 II' AND t.source_system_id = 3
  AND per.first_name = 'Atay' AND per.last_name = 'Yilmaz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 III' AND t.source_system_id = 3
  AND per.first_name = 'Jonathan' AND per.last_name = 'Adabi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 III' AND t.source_system_id = 3
  AND per.first_name = 'Michael' AND per.last_name = 'Arauz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 III' AND t.source_system_id = 3
  AND per.first_name = 'Antoine' AND per.last_name = 'Biebuyck'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 III' AND t.source_system_id = 3
  AND per.first_name = 'Carter' AND per.last_name = 'Cameron'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 III' AND t.source_system_id = 3
  AND per.first_name = 'Matviy' AND per.last_name = 'Chernyatynskyy'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 III' AND t.source_system_id = 3
  AND per.first_name = 'Jonathan' AND per.last_name = 'Crisanto'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 III' AND t.source_system_id = 3
  AND per.first_name = 'Russell' AND per.last_name = 'Davis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 III' AND t.source_system_id = 3
  AND per.first_name = 'Osmonbek' AND per.last_name = 'Djumagulov'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 III' AND t.source_system_id = 3
  AND per.first_name = 'Tulga' AND per.last_name = 'Enhsaihan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 III' AND t.source_system_id = 3
  AND per.first_name = 'Kerem' AND per.last_name = 'Guventurk'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 III' AND t.source_system_id = 3
  AND per.first_name = 'Baba' AND per.last_name = 'Kane'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 III' AND t.source_system_id = 3
  AND per.first_name = 'Jacob' AND per.last_name = 'Kipnis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 III' AND t.source_system_id = 3
  AND per.first_name = 'Daniel' AND per.last_name = 'Leiser'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 III' AND t.source_system_id = 3
  AND per.first_name = 'Chris' AND per.last_name = 'Lynn'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 III' AND t.source_system_id = 3
  AND per.first_name = 'Robert' AND per.last_name = 'Manukyan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 III' AND t.source_system_id = 3
  AND per.first_name = 'Jackson' AND per.last_name = 'Mariani'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 III' AND t.source_system_id = 3
  AND per.first_name = 'Jordi' AND per.last_name = 'Martinez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 III' AND t.source_system_id = 3
  AND per.first_name = 'Santiago' AND per.last_name = 'Montoya Salgado'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 III' AND t.source_system_id = 3
  AND per.first_name = 'Matthew' AND per.last_name = 'Nastarowicz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 III' AND t.source_system_id = 3
  AND per.first_name = 'Ridwan' AND per.last_name = 'Olawin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 III' AND t.source_system_id = 3
  AND per.first_name = 'Haig' AND per.last_name = 'Piramzadian'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 III' AND t.source_system_id = 3
  AND per.first_name = 'Edoardo' AND per.last_name = 'Pisoni'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 III' AND t.source_system_id = 3
  AND per.first_name = 'Carlos' AND per.last_name = 'Rebelo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 III' AND t.source_system_id = 3
  AND per.first_name = 'Vincenzo' AND per.last_name = 'San Lorenzo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 III' AND t.source_system_id = 3
  AND per.first_name = 'Carlos' AND per.last_name = 'San Miguel-Navas'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 III' AND t.source_system_id = 3
  AND per.first_name = 'Edward' AND per.last_name = 'Setian'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 III' AND t.source_system_id = 3
  AND per.first_name = 'Alex' AND per.last_name = 'Todorovic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 III' AND t.source_system_id = 3
  AND per.first_name = 'Facundo' AND per.last_name = 'Villegas'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03 III' AND t.source_system_id = 3
  AND per.first_name = 'Mamadou' AND per.last_name = 'Yacouba'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan FC' AND t.source_system_id = 3
  AND per.first_name = 'Johnezeki' AND per.last_name = 'Ananoria'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan FC' AND t.source_system_id = 3
  AND per.first_name = 'Elhadji' AND per.last_name = 'Anne'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan FC' AND t.source_system_id = 3
  AND per.first_name = 'Anoh' AND per.last_name = 'Boutin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan FC' AND t.source_system_id = 3
  AND per.first_name = 'Kevin' AND per.last_name = 'Caceres'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan FC' AND t.source_system_id = 3
  AND per.first_name = 'George' AND per.last_name = 'Cunha'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan FC' AND t.source_system_id = 3
  AND per.first_name = 'Oscar' AND per.last_name = 'Estrada'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan FC' AND t.source_system_id = 3
  AND per.first_name = 'Cormac' AND per.last_name = 'Fingeret'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan FC' AND t.source_system_id = 3
  AND per.first_name = 'Miguel' AND per.last_name = 'Hawthorne'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan FC' AND t.source_system_id = 3
  AND per.first_name = 'Renzo' AND per.last_name = 'Herrera'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan FC' AND t.source_system_id = 3
  AND per.first_name = 'Jeffrey' AND per.last_name = 'Joseph'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan FC' AND t.source_system_id = 3
  AND per.first_name = 'Steve' AND per.last_name = 'Kouevi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan FC' AND t.source_system_id = 3
  AND per.first_name = 'Christopher' AND per.last_name = 'Lopez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan FC' AND t.source_system_id = 3
  AND per.first_name = 'Andres' AND per.last_name = 'Lora'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan FC' AND t.source_system_id = 3
  AND per.first_name = 'Malik' AND per.last_name = 'Mathes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan FC' AND t.source_system_id = 3
  AND per.first_name = 'Moataz' AND per.last_name = 'Mohamed'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan FC' AND t.source_system_id = 3
  AND per.first_name = 'Kevin' AND per.last_name = 'Muniz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan FC' AND t.source_system_id = 3
  AND per.first_name = 'Ansen' AND per.last_name = 'Novak'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan FC' AND t.source_system_id = 3
  AND per.first_name = 'Michael' AND per.last_name = 'Reader'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan FC' AND t.source_system_id = 3
  AND per.first_name = 'Bernie' AND per.last_name = 'Rosa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan FC' AND t.source_system_id = 3
  AND per.first_name = 'Balvin' AND per.last_name = 'West'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Legacy FC' AND t.source_system_id = 3
  AND per.first_name = 'WILGEN' AND per.last_name = 'AGUILAR'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Legacy FC' AND t.source_system_id = 3
  AND per.first_name = 'ABRAHAM' AND per.last_name = 'AVILES'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Legacy FC' AND t.source_system_id = 3
  AND per.first_name = 'STEVE' AND per.last_name = 'BORBON'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Legacy FC' AND t.source_system_id = 3
  AND per.first_name = 'JACOBO' AND per.last_name = 'BOTERO MEJIA'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Legacy FC' AND t.source_system_id = 3
  AND per.first_name = 'HAYDER' AND per.last_name = 'CANTOS'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Legacy FC' AND t.source_system_id = 3
  AND per.first_name = 'CRISTOPHER' AND per.last_name = 'CASAREZ'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Legacy FC' AND t.source_system_id = 3
  AND per.first_name = 'MARCELINO' AND per.last_name = 'CASTILLO'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Legacy FC' AND t.source_system_id = 3
  AND per.first_name = 'ALEXIS' AND per.last_name = 'CORTES'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Legacy FC' AND t.source_system_id = 3
  AND per.first_name = 'IGOR' AND per.last_name = 'DE LEON'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Legacy FC' AND t.source_system_id = 3
  AND per.first_name = 'ROGER' AND per.last_name = 'DELGADO'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Legacy FC' AND t.source_system_id = 3
  AND per.first_name = 'DYLAN' AND per.last_name = 'DORIA'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Legacy FC' AND t.source_system_id = 3
  AND per.first_name = 'JORGE' AND per.last_name = 'GASPAR'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Legacy FC' AND t.source_system_id = 3
  AND per.first_name = 'EMANUEL' AND per.last_name = 'GONZALEZ'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Legacy FC' AND t.source_system_id = 3
  AND per.first_name = 'JOSE' AND per.last_name = 'GONZALEZ'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Legacy FC' AND t.source_system_id = 3
  AND per.first_name = 'DAVID' AND per.last_name = 'KNEZEVICH'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Legacy FC' AND t.source_system_id = 3
  AND per.first_name = 'OSCAR' AND per.last_name = 'LEYVA'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Legacy FC' AND t.source_system_id = 3
  AND per.first_name = 'ANGEL' AND per.last_name = 'MARTINEZ'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Legacy FC' AND t.source_system_id = 3
  AND per.first_name = 'ARTURO' AND per.last_name = 'MARTINEZ'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Legacy FC' AND t.source_system_id = 3
  AND per.first_name = 'IVAN' AND per.last_name = 'MATUTE'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Legacy FC' AND t.source_system_id = 3
  AND per.first_name = 'CHRISTIAN' AND per.last_name = 'MAZA'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Legacy FC' AND t.source_system_id = 3
  AND per.first_name = 'LUIS' AND per.last_name = 'MORA'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Legacy FC' AND t.source_system_id = 3
  AND per.first_name = 'HENRY' AND per.last_name = 'MOROCHO'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Legacy FC' AND t.source_system_id = 3
  AND per.first_name = 'JEFERSON' AND per.last_name = 'NAULA'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Legacy FC' AND t.source_system_id = 3
  AND per.first_name = 'JORGE' AND per.last_name = 'PAREDES'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Legacy FC' AND t.source_system_id = 3
  AND per.first_name = 'IVAN' AND per.last_name = 'REYES'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Legacy FC' AND t.source_system_id = 3
  AND per.first_name = 'CHRISTOPHER' AND per.last_name = 'RODAS'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Legacy FC' AND t.source_system_id = 3
  AND per.first_name = 'GABRIEL' AND per.last_name = 'RODRIGUES'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Legacy FC' AND t.source_system_id = 3
  AND per.first_name = 'ROBERT' AND per.last_name = 'RODRIGUEZ'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Legacy FC' AND t.source_system_id = 3
  AND per.first_name = 'CHRISTOPHER' AND per.last_name = 'TEPOX'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Legacy FC' AND t.source_system_id = 3
  AND per.first_name = 'DEREK' AND per.last_name = 'VANEGAS'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Yellow Hook II' AND t.source_system_id = 3
  AND per.first_name = 'Brad' AND per.last_name = 'Bohlin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Yellow Hook II' AND t.source_system_id = 3
  AND per.first_name = 'Chaz' AND per.last_name = 'Bond'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Yellow Hook II' AND t.source_system_id = 3
  AND per.first_name = 'Victor' AND per.last_name = 'Borzykh'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Yellow Hook II' AND t.source_system_id = 3
  AND per.first_name = 'Terry' AND per.last_name = 'Boursiquot'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Yellow Hook II' AND t.source_system_id = 3
  AND per.first_name = 'Alessandro' AND per.last_name = 'Chumpitaz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Yellow Hook II' AND t.source_system_id = 3
  AND per.first_name = 'Christopher' AND per.last_name = 'Davitt'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Yellow Hook II' AND t.source_system_id = 3
  AND per.first_name = 'Pierre' AND per.last_name = 'Deliso'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Yellow Hook II' AND t.source_system_id = 3
  AND per.first_name = 'Randy' AND per.last_name = 'El Nahrawy Jr'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Yellow Hook II' AND t.source_system_id = 3
  AND per.first_name = 'Michael' AND per.last_name = 'Faiello'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Yellow Hook II' AND t.source_system_id = 3
  AND per.first_name = 'Mohamed' AND per.last_name = 'Gueye'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Yellow Hook II' AND t.source_system_id = 3
  AND per.first_name = 'Santos' AND per.last_name = 'Guinea'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Yellow Hook II' AND t.source_system_id = 3
  AND per.first_name = 'Cristopher' AND per.last_name = 'Hain Prada'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Yellow Hook II' AND t.source_system_id = 3
  AND per.first_name = 'Hunter' AND per.last_name = 'Karsseboom'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Yellow Hook II' AND t.source_system_id = 3
  AND per.first_name = 'Duan' AND per.last_name = 'Knibbs'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Yellow Hook II' AND t.source_system_id = 3
  AND per.first_name = 'Christopher' AND per.last_name = 'Lau'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Yellow Hook II' AND t.source_system_id = 3
  AND per.first_name = 'Lloyd' AND per.last_name = 'Lesperance'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Yellow Hook II' AND t.source_system_id = 3
  AND per.first_name = 'Kenneth' AND per.last_name = 'Lopez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Yellow Hook II' AND t.source_system_id = 3
  AND per.first_name = 'Anthony' AND per.last_name = 'Marando'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Yellow Hook II' AND t.source_system_id = 3
  AND per.first_name = 'Victor' AND per.last_name = 'Martinez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Yellow Hook II' AND t.source_system_id = 3
  AND per.first_name = 'Steven' AND per.last_name = 'Millan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Yellow Hook II' AND t.source_system_id = 3
  AND per.first_name = 'Jakob' AND per.last_name = 'Mohammed'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Yellow Hook II' AND t.source_system_id = 3
  AND per.first_name = 'Axel' AND per.last_name = 'Morales'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Yellow Hook II' AND t.source_system_id = 3
  AND per.first_name = 'Dexter' AND per.last_name = 'Phillips'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Yellow Hook II' AND t.source_system_id = 3
  AND per.first_name = 'Kende' AND per.last_name = 'Roberts'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Yellow Hook II' AND t.source_system_id = 3
  AND per.first_name = 'Luca' AND per.last_name = 'Varisco'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Yellow Hook II' AND t.source_system_id = 3
  AND per.first_name = 'Marquis' AND per.last_name = 'Winslow'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gjoa Yellow Hook II' AND t.source_system_id = 3
  AND per.first_name = 'Giovanni' AND per.last_name = 'Yanez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan FC II' AND t.source_system_id = 3
  AND per.first_name = 'Damonie' AND per.last_name = 'Adlam'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan FC II' AND t.source_system_id = 3
  AND per.first_name = 'Colby' AND per.last_name = 'Aranibar'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan FC II' AND t.source_system_id = 3
  AND per.first_name = 'Marlon' AND per.last_name = 'Aranibar'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan FC II' AND t.source_system_id = 3
  AND per.first_name = 'Jeffry' AND per.last_name = 'Arcentales'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan FC II' AND t.source_system_id = 3
  AND per.first_name = 'Kevin' AND per.last_name = 'Cando'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan FC II' AND t.source_system_id = 3
  AND per.first_name = 'Roger' AND per.last_name = 'Castellano'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan FC II' AND t.source_system_id = 3
  AND per.first_name = 'Michael' AND per.last_name = 'Chavez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan FC II' AND t.source_system_id = 3
  AND per.first_name = 'Rolando' AND per.last_name = 'Colman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan FC II' AND t.source_system_id = 3
  AND per.first_name = 'David' AND per.last_name = 'Criollo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan FC II' AND t.source_system_id = 3
  AND per.first_name = 'Jason' AND per.last_name = 'Criollo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan FC II' AND t.source_system_id = 3
  AND per.first_name = 'Makhtar' AND per.last_name = 'Diop'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan FC II' AND t.source_system_id = 3
  AND per.first_name = 'Christian' AND per.last_name = 'Guaraca'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan FC II' AND t.source_system_id = 3
  AND per.first_name = 'Kevin' AND per.last_name = 'Guiracocha'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan FC II' AND t.source_system_id = 3
  AND per.first_name = 'Jose' AND per.last_name = 'Hernandez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan FC II' AND t.source_system_id = 3
  AND per.first_name = 'Josh' AND per.last_name = 'Hostetler'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan FC II' AND t.source_system_id = 3
  AND per.first_name = 'Ram' AND per.last_name = 'Kukaj'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan FC II' AND t.source_system_id = 3
  AND per.first_name = 'Grant' AND per.last_name = 'Montoya'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan FC II' AND t.source_system_id = 3
  AND per.first_name = 'Santiago' AND per.last_name = 'Novillo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan FC II' AND t.source_system_id = 3
  AND per.first_name = 'Carlos' AND per.last_name = 'Osorios-Rios'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan FC II' AND t.source_system_id = 3
  AND per.first_name = 'Daniel' AND per.last_name = 'Ospina'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan FC II' AND t.source_system_id = 3
  AND per.first_name = 'Anthony' AND per.last_name = 'Osuna'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan FC II' AND t.source_system_id = 3
  AND per.first_name = 'Carlos' AND per.last_name = 'Pardo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan FC II' AND t.source_system_id = 3
  AND per.first_name = 'Timothy' AND per.last_name = 'Phanthavong'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan FC II' AND t.source_system_id = 3
  AND per.first_name = 'Jhonny' AND per.last_name = 'Ramon'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan FC II' AND t.source_system_id = 3
  AND per.first_name = 'Anthony' AND per.last_name = 'Ramos'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan FC II' AND t.source_system_id = 3
  AND per.first_name = 'Aaron' AND per.last_name = 'Rodriguez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan FC II' AND t.source_system_id = 3
  AND per.first_name = 'Gorge' AND per.last_name = 'Salazar'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan FC II' AND t.source_system_id = 3
  AND per.first_name = 'Caique' AND per.last_name = 'Servija'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Manhattan FC II' AND t.source_system_id = 3
  AND per.first_name = 'Ralph' AND per.last_name = 'Zamarippa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Yemen United SC II' AND t.source_system_id = 3
  AND per.first_name = 'Waleed' AND per.last_name = 'Abumusa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Yemen United SC II' AND t.source_system_id = 3
  AND per.first_name = 'Wael' AND per.last_name = 'Aldanah'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Yemen United SC II' AND t.source_system_id = 3
  AND per.first_name = 'omar' AND per.last_name = 'algahim'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Yemen United SC II' AND t.source_system_id = 3
  AND per.first_name = 'Tari' AND per.last_name = 'Algahim'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Yemen United SC II' AND t.source_system_id = 3
  AND per.first_name = 'Ahmed' AND per.last_name = 'Alghaim'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Yemen United SC II' AND t.source_system_id = 3
  AND per.first_name = 'Omar' AND per.last_name = 'Alkasimi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Yemen United SC II' AND t.source_system_id = 3
  AND per.first_name = 'Abdullah' AND per.last_name = 'Almaghrabi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Yemen United SC II' AND t.source_system_id = 3
  AND per.first_name = 'Isskander' AND per.last_name = 'Almaliki'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Yemen United SC II' AND t.source_system_id = 3
  AND per.first_name = 'Abdelsalam' AND per.last_name = 'Almekhlafi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Yemen United SC II' AND t.source_system_id = 3
  AND per.first_name = 'Yagoub' AND per.last_name = 'Almekhlafi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Yemen United SC II' AND t.source_system_id = 3
  AND per.first_name = 'Jameel' AND per.last_name = 'Almohamadi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Yemen United SC II' AND t.source_system_id = 3
  AND per.first_name = 'Ali' AND per.last_name = 'Alrobaie'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Yemen United SC II' AND t.source_system_id = 3
  AND per.first_name = 'Gaber' AND per.last_name = 'Alsaidi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Yemen United SC II' AND t.source_system_id = 3
  AND per.first_name = 'Omar' AND per.last_name = 'Alsaydi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Yemen United SC II' AND t.source_system_id = 3
  AND per.first_name = 'Khir' AND per.last_name = 'Allah AlZawkari'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Yemen United SC II' AND t.source_system_id = 3
  AND per.first_name = 'ABDELLATIF,' AND per.last_name = 'AMARI'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Yemen United SC II' AND t.source_system_id = 3
  AND per.first_name = 'Marco' AND per.last_name = 'Barragan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Yemen United SC II' AND t.source_system_id = 3
  AND per.first_name = 'Ali' AND per.last_name = 'Hussain'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Yemen United SC II' AND t.source_system_id = 3
  AND per.first_name = 'Raed' AND per.last_name = 'Jaradie'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Yemen United SC II' AND t.source_system_id = 3
  AND per.first_name = 'Abulrahman' AND per.last_name = 'Mansoor'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Yemen United SC II' AND t.source_system_id = 3
  AND per.first_name = 'Jamal' AND per.last_name = 'Niles'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Yemen United SC II' AND t.source_system_id = 3
  AND per.first_name = 'Kassem' AND per.last_name = 'Ottman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Yemen United SC II' AND t.source_system_id = 3
  AND per.first_name = 'Anas' AND per.last_name = 'Saleh'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Yemen United SC II' AND t.source_system_id = 3
  AND per.first_name = 'Hosamelden' AND per.last_name = 'Saleh'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC III' AND t.source_system_id = 3
  AND per.first_name = 'Alex' AND per.last_name = 'Anderson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC III' AND t.source_system_id = 3
  AND per.first_name = 'Alexandre' AND per.last_name = 'Avomo-Ndong'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC III' AND t.source_system_id = 3
  AND per.first_name = 'Paul' AND per.last_name = 'Banks'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC III' AND t.source_system_id = 3
  AND per.first_name = 'Victor' AND per.last_name = 'Barbosa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC III' AND t.source_system_id = 3
  AND per.first_name = 'Robert' AND per.last_name = 'Bertagna'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC III' AND t.source_system_id = 3
  AND per.first_name = 'Hrvoje' AND per.last_name = 'Brkljacic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC III' AND t.source_system_id = 3
  AND per.first_name = 'Lamar' AND per.last_name = 'Cancino'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC III' AND t.source_system_id = 3
  AND per.first_name = 'Ryan' AND per.last_name = 'Clark'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC III' AND t.source_system_id = 3
  AND per.first_name = 'Isaac' AND per.last_name = 'Cleveland'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC III' AND t.source_system_id = 3
  AND per.first_name = 'Jesus' AND per.last_name = 'Contreras'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC III' AND t.source_system_id = 3
  AND per.first_name = 'Clark' AND per.last_name = 'Cushman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC III' AND t.source_system_id = 3
  AND per.first_name = 'Colin' AND per.last_name = 'Egerter'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC III' AND t.source_system_id = 3
  AND per.first_name = 'Nikita' AND per.last_name = 'Ermolaev'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC III' AND t.source_system_id = 3
  AND per.first_name = 'Andrew' AND per.last_name = 'Firth'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC III' AND t.source_system_id = 3
  AND per.first_name = 'Matej' AND per.last_name = 'Grguric'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC III' AND t.source_system_id = 3
  AND per.first_name = 'Casey' AND per.last_name = 'Gavin Intrator'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC III' AND t.source_system_id = 3
  AND per.first_name = 'Joshua' AND per.last_name = 'Jacobson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC III' AND t.source_system_id = 3
  AND per.first_name = 'Jason' AND per.last_name = 'Leone'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC III' AND t.source_system_id = 3
  AND per.first_name = 'Sergio' AND per.last_name = 'Montano'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC III' AND t.source_system_id = 3
  AND per.first_name = 'Andres' AND per.last_name = 'Penfold-Perez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC III' AND t.source_system_id = 3
  AND per.first_name = 'Nicolas' AND per.last_name = 'Penfold-Perez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC III' AND t.source_system_id = 3
  AND per.first_name = 'Graham' AND per.last_name = 'Peterson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC III' AND t.source_system_id = 3
  AND per.first_name = 'Jaime' AND per.last_name = 'Roque'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC III' AND t.source_system_id = 3
  AND per.first_name = 'Christian' AND per.last_name = 'Soares'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC III' AND t.source_system_id = 3
  AND per.first_name = 'Zachary' AND per.last_name = 'Sweers'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC III' AND t.source_system_id = 3
  AND per.first_name = 'Liam' AND per.last_name = 'Weitz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KidSuper Samba AC III' AND t.source_system_id = 3
  AND per.first_name = 'Maciej' AND per.last_name = 'Zielonka'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vibes FC' AND t.source_system_id = 3
  AND per.first_name = 'Joseph' AND per.last_name = 'Aste'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vibes FC' AND t.source_system_id = 3
  AND per.first_name = 'Raphael' AND per.last_name = 'Baer-Way'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vibes FC' AND t.source_system_id = 3
  AND per.first_name = 'John' AND per.last_name = 'Baney'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vibes FC' AND t.source_system_id = 3
  AND per.first_name = 'Thomas' AND per.last_name = 'Burke'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vibes FC' AND t.source_system_id = 3
  AND per.first_name = 'Ethan' AND per.last_name = 'Coad'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vibes FC' AND t.source_system_id = 3
  AND per.first_name = 'Adrien' AND per.last_name = 'Cohen'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vibes FC' AND t.source_system_id = 3
  AND per.first_name = 'Lourenzo' AND per.last_name = 'Colleyn'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vibes FC' AND t.source_system_id = 3
  AND per.first_name = 'Julien' AND per.last_name = 'Darsses'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vibes FC' AND t.source_system_id = 3
  AND per.first_name = 'Alejandro' AND per.last_name = 'Facundo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vibes FC' AND t.source_system_id = 3
  AND per.first_name = 'Joshua' AND per.last_name = 'Fish'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vibes FC' AND t.source_system_id = 3
  AND per.first_name = 'Kevin' AND per.last_name = 'Gold'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vibes FC' AND t.source_system_id = 3
  AND per.first_name = 'Cyril' AND per.last_name = 'Grant'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vibes FC' AND t.source_system_id = 3
  AND per.first_name = 'Siddhant' AND per.last_name = 'Jain'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vibes FC' AND t.source_system_id = 3
  AND per.first_name = 'Ted' AND per.last_name = 'Lowen'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vibes FC' AND t.source_system_id = 3
  AND per.first_name = 'Iain' AND per.last_name = 'Macdiarmid'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vibes FC' AND t.source_system_id = 3
  AND per.first_name = 'Max' AND per.last_name = 'Matsumoto'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vibes FC' AND t.source_system_id = 3
  AND per.first_name = 'Vuk' AND per.last_name = 'Muyot'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vibes FC' AND t.source_system_id = 3
  AND per.first_name = 'Miles' AND per.last_name = 'Neal'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vibes FC' AND t.source_system_id = 3
  AND per.first_name = 'Max' AND per.last_name = 'Neve'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vibes FC' AND t.source_system_id = 3
  AND per.first_name = 'Bryan' AND per.last_name = 'Niyonzima'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vibes FC' AND t.source_system_id = 3
  AND per.first_name = 'Stefano' AND per.last_name = 'Oppici'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vibes FC' AND t.source_system_id = 3
  AND per.first_name = 'Zak' AND per.last_name = 'Pavlovich'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vibes FC' AND t.source_system_id = 3
  AND per.first_name = 'Erik' AND per.last_name = 'Ryan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vibes FC' AND t.source_system_id = 3
  AND per.first_name = 'Francois' AND per.last_name = 'Savignac'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vibes FC' AND t.source_system_id = 3
  AND per.first_name = 'Joshua' AND per.last_name = 'Shearouse'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vibes FC' AND t.source_system_id = 3
  AND per.first_name = 'Alexander' AND per.last_name = 'Tagashira-McGillicuddy'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vibes FC' AND t.source_system_id = 3
  AND per.first_name = 'Jacob' AND per.last_name = 'Turner'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vibes FC' AND t.source_system_id = 3
  AND per.first_name = 'Jin' AND per.last_name = 'Yamashita'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vibes FC' AND t.source_system_id = 3
  AND per.first_name = 'Eric' AND per.last_name = 'Zhang'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia II' AND t.source_system_id = 3
  AND per.first_name = 'Daniel' AND per.last_name = 'Alvarez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia II' AND t.source_system_id = 3
  AND per.first_name = 'Omar' AND per.last_name = 'Anabtawi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia II' AND t.source_system_id = 3
  AND per.first_name = 'Francois' AND per.last_name = 'Artigou'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia II' AND t.source_system_id = 3
  AND per.first_name = 'Alex' AND per.last_name = 'Beiner'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia II' AND t.source_system_id = 3
  AND per.first_name = 'Laurent' AND per.last_name = 'Ben Arrous'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia II' AND t.source_system_id = 3
  AND per.first_name = 'Lior' AND per.last_name = 'Ben Arrous'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia II' AND t.source_system_id = 3
  AND per.first_name = 'Krystian' AND per.last_name = 'Boguski'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia II' AND t.source_system_id = 3
  AND per.first_name = 'Jonathan' AND per.last_name = 'Caceres'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia II' AND t.source_system_id = 3
  AND per.first_name = 'Chouran' AND per.last_name = 'Camara'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia II' AND t.source_system_id = 3
  AND per.first_name = 'Oliver' AND per.last_name = 'Castillo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia II' AND t.source_system_id = 3
  AND per.first_name = 'Renzo' AND per.last_name = 'Coronel'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia II' AND t.source_system_id = 3
  AND per.first_name = 'Louay' AND per.last_name = 'Dacosta'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia II' AND t.source_system_id = 3
  AND per.first_name = 'Jose' AND per.last_name = 'Escobedo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia II' AND t.source_system_id = 3
  AND per.first_name = 'Luis' AND per.last_name = 'Fuenmayor'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia II' AND t.source_system_id = 3
  AND per.first_name = 'Shahar' AND per.last_name = 'Golan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia II' AND t.source_system_id = 3
  AND per.first_name = 'Colin' AND per.last_name = 'Hill'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia II' AND t.source_system_id = 3
  AND per.first_name = 'James' AND per.last_name = 'Jules'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia II' AND t.source_system_id = 3
  AND per.first_name = 'Joseph' AND per.last_name = 'Kim'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia II' AND t.source_system_id = 3
  AND per.first_name = 'Kamil' AND per.last_name = 'Kosmider'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia II' AND t.source_system_id = 3
  AND per.first_name = 'Manuel' AND per.last_name = 'Lago'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia II' AND t.source_system_id = 3
  AND per.first_name = 'Jonathan' AND per.last_name = 'Martinez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia II' AND t.source_system_id = 3
  AND per.first_name = 'Raul' AND per.last_name = 'Nadirashvili'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia II' AND t.source_system_id = 3
  AND per.first_name = 'Isaac' AND per.last_name = 'Navarrete'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia II' AND t.source_system_id = 3
  AND per.first_name = 'Amar' AND per.last_name = 'Omeragic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia II' AND t.source_system_id = 3
  AND per.first_name = 'Luke' AND per.last_name = 'Oneill'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia II' AND t.source_system_id = 3
  AND per.first_name = 'Anthony' AND per.last_name = 'Rojas'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia II' AND t.source_system_id = 3
  AND per.first_name = 'Benny' AND per.last_name = 'Santiago'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia II' AND t.source_system_id = 3
  AND per.first_name = 'Naran' AND per.last_name = 'Sharaev'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia II' AND t.source_system_id = 3
  AND per.first_name = 'Dominik' AND per.last_name = 'Slaweta'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'CD Iberia II' AND t.source_system_id = 3
  AND per.first_name = 'Michael' AND per.last_name = 'Visperas'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vera FC' AND t.source_system_id = 3
  AND per.first_name = 'Diego' AND per.last_name = 'Argudo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vera FC' AND t.source_system_id = 3
  AND per.first_name = 'Kember' AND per.last_name = 'Barrios'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vera FC' AND t.source_system_id = 3
  AND per.first_name = 'Jean' AND per.last_name = 'Bautista'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vera FC' AND t.source_system_id = 3
  AND per.first_name = 'Robert' AND per.last_name = 'Chacon'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vera FC' AND t.source_system_id = 3
  AND per.first_name = 'Aboubacar' AND per.last_name = 'Diaby'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vera FC' AND t.source_system_id = 3
  AND per.first_name = 'Jerry' AND per.last_name = 'Figueroa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vera FC' AND t.source_system_id = 3
  AND per.first_name = 'Dimitrios' AND per.last_name = 'Giannopoulos'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vera FC' AND t.source_system_id = 3
  AND per.first_name = 'Christopher' AND per.last_name = 'Guillermo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vera FC' AND t.source_system_id = 3
  AND per.first_name = 'David' AND per.last_name = 'Jimenez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vera FC' AND t.source_system_id = 3
  AND per.first_name = 'Andrew' AND per.last_name = 'Parades'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vera FC' AND t.source_system_id = 3
  AND per.first_name = 'Francis' AND per.last_name = 'Paredes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vera FC' AND t.source_system_id = 3
  AND per.first_name = 'Petros' AND per.last_name = 'Polakis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vera FC' AND t.source_system_id = 3
  AND per.first_name = 'Angelo' AND per.last_name = 'Querevalu'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vera FC' AND t.source_system_id = 3
  AND per.first_name = 'Juan' AND per.last_name = 'Rambal'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vera FC' AND t.source_system_id = 3
  AND per.first_name = 'Shawn' AND per.last_name = 'Reinoso'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vera FC' AND t.source_system_id = 3
  AND per.first_name = 'Mahamadou' AND per.last_name = 'Sillah'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vera FC' AND t.source_system_id = 3
  AND per.first_name = 'Mohamed' AND per.last_name = 'Tandja'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vera FC' AND t.source_system_id = 3
  AND per.first_name = 'Alvaro' AND per.last_name = 'Teran'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vera FC' AND t.source_system_id = 3
  AND per.first_name = 'Martin' AND per.last_name = 'Torres'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vera FC' AND t.source_system_id = 3
  AND per.first_name = 'Juan' AND per.last_name = 'Vera'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa SC Legends' AND t.source_system_id = 3
  AND per.first_name = 'Anibal' AND per.last_name = 'Barbosa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa SC Legends' AND t.source_system_id = 3
  AND per.first_name = 'Marlon' AND per.last_name = 'O Brien Blackman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa SC Legends' AND t.source_system_id = 3
  AND per.first_name = 'Spiros' AND per.last_name = 'Dimotheris'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa SC Legends' AND t.source_system_id = 3
  AND per.first_name = 'Michael' AND per.last_name = 'Anthony Gayle'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa SC Legends' AND t.source_system_id = 3
  AND per.first_name = 'Tiago' AND per.last_name = 'Gomes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa SC Legends' AND t.source_system_id = 3
  AND per.first_name = 'Duane' AND per.last_name = 'A Heaven'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa SC Legends' AND t.source_system_id = 3
  AND per.first_name = 'Rosario' AND per.last_name = 'Iacono'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa SC Legends' AND t.source_system_id = 3
  AND per.first_name = 'Richard' AND per.last_name = 'Katehis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa SC Legends' AND t.source_system_id = 3
  AND per.first_name = 'Spyridon' AND per.last_name = 'Katehis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa SC Legends' AND t.source_system_id = 3
  AND per.first_name = 'Aristidis' AND per.last_name = 'Lourdas'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa SC Legends' AND t.source_system_id = 3
  AND per.first_name = 'Dany' AND per.last_name = 'Martinez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa SC Legends' AND t.source_system_id = 3
  AND per.first_name = 'Vladimir' AND per.last_name = 'Martinez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa SC Legends' AND t.source_system_id = 3
  AND per.first_name = 'William' AND per.last_name = 'Alexander Orantes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa SC Legends' AND t.source_system_id = 3
  AND per.first_name = 'Alberto' AND per.last_name = 'Paez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa SC Legends' AND t.source_system_id = 3
  AND per.first_name = 'Carlos' AND per.last_name = 'Paredes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa SC Legends' AND t.source_system_id = 3
  AND per.first_name = 'Oscar' AND per.last_name = 'Perez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa SC Legends' AND t.source_system_id = 3
  AND per.first_name = 'Jose' AND per.last_name = 'I Rodriguez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa SC Legends' AND t.source_system_id = 3
  AND per.first_name = 'Juan' AND per.last_name = 'Ruales'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa SC Legends' AND t.source_system_id = 3
  AND per.first_name = 'Theodosios' AND per.last_name = 'Siskos'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa SC Legends' AND t.source_system_id = 3
  AND per.first_name = 'Abdelali' AND per.last_name = 'Toumi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa SC Legends' AND t.source_system_id = 3
  AND per.first_name = 'Guillermo' AND per.last_name = 'Tovar'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa SC Legends' AND t.source_system_id = 3
  AND per.first_name = 'Jorge' AND per.last_name = 'D Varela'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa SC Legends' AND t.source_system_id = 3
  AND per.first_name = 'Raul' AND per.last_name = 'Salazar Velasquez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa SC Legends' AND t.source_system_id = 3
  AND per.first_name = 'Manolis' AND per.last_name = 'Vourvahis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Guyana Sunnydale Veterans FC' AND t.source_system_id = 3
  AND per.first_name = 'Adrian' AND per.last_name = 'Alfred'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Guyana Sunnydale Veterans FC' AND t.source_system_id = 3
  AND per.first_name = 'Shaquille' AND per.last_name = 'Alleyne'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Guyana Sunnydale Veterans FC' AND t.source_system_id = 3
  AND per.first_name = 'Brentsley' AND per.last_name = 'Allicock'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Guyana Sunnydale Veterans FC' AND t.source_system_id = 3
  AND per.first_name = 'Ashmar' AND per.last_name = 'Angel'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Guyana Sunnydale Veterans FC' AND t.source_system_id = 3
  AND per.first_name = 'Rondel' AND per.last_name = 'Bascom'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Guyana Sunnydale Veterans FC' AND t.source_system_id = 3
  AND per.first_name = 'Colric' AND per.last_name = 'Beckles'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Guyana Sunnydale Veterans FC' AND t.source_system_id = 3
  AND per.first_name = 'Dreshaun' AND per.last_name = 'Bishop'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Guyana Sunnydale Veterans FC' AND t.source_system_id = 3
  AND per.first_name = 'Andrew' AND per.last_name = 'Durant'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Guyana Sunnydale Veterans FC' AND t.source_system_id = 3
  AND per.first_name = 'Jermaine' AND per.last_name = 'Fordyce'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Guyana Sunnydale Veterans FC' AND t.source_system_id = 3
  AND per.first_name = 'Carey' AND per.last_name = 'Harris'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Guyana Sunnydale Veterans FC' AND t.source_system_id = 3
  AND per.first_name = 'Shuwrick' AND per.last_name = 'Hercules'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Guyana Sunnydale Veterans FC' AND t.source_system_id = 3
  AND per.first_name = 'jonathan' AND per.last_name = 'Hunte'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Guyana Sunnydale Veterans FC' AND t.source_system_id = 3
  AND per.first_name = 'Tichard' AND per.last_name = 'Joseph'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Guyana Sunnydale Veterans FC' AND t.source_system_id = 3
  AND per.first_name = 'Timothy' AND per.last_name = 'Lawrence'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Guyana Sunnydale Veterans FC' AND t.source_system_id = 3
  AND per.first_name = 'Kevin' AND per.last_name = 'Layne'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Guyana Sunnydale Veterans FC' AND t.source_system_id = 3
  AND per.first_name = 'Jamin' AND per.last_name = 'Peters'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Guyana Sunnydale Veterans FC' AND t.source_system_id = 3
  AND per.first_name = 'Dexter' AND per.last_name = 'Primo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Guyana Sunnydale Veterans FC' AND t.source_system_id = 3
  AND per.first_name = 'Sheldon' AND per.last_name = 'Williams'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Soccer Legion FC Men' AND t.source_system_id = 3
  AND per.first_name = 'Louis' AND per.last_name = 'Caiola'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Soccer Legion FC Men' AND t.source_system_id = 3
  AND per.first_name = 'Mashiach' AND per.last_name = 'Cherry'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Soccer Legion FC Men' AND t.source_system_id = 3
  AND per.first_name = 'Ryan' AND per.last_name = 'Creese'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Soccer Legion FC Men' AND t.source_system_id = 3
  AND per.first_name = 'Jayden' AND per.last_name = 'DeLacruz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Soccer Legion FC Men' AND t.source_system_id = 3
  AND per.first_name = 'Sebastien' AND per.last_name = 'Delice'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Soccer Legion FC Men' AND t.source_system_id = 3
  AND per.first_name = 'Clermens' AND per.last_name = 'Devariste'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Soccer Legion FC Men' AND t.source_system_id = 3
  AND per.first_name = 'Stephan' AND per.last_name = 'Diaz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Soccer Legion FC Men' AND t.source_system_id = 3
  AND per.first_name = 'Muhammad' AND per.last_name = 'Doumbouya'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Soccer Legion FC Men' AND t.source_system_id = 3
  AND per.first_name = 'Queensly' AND per.last_name = 'Francois'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Soccer Legion FC Men' AND t.source_system_id = 3
  AND per.first_name = 'Vladimir' AND per.last_name = 'Francois'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Soccer Legion FC Men' AND t.source_system_id = 3
  AND per.first_name = 'Edward' AND per.last_name = 'Hernandez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Soccer Legion FC Men' AND t.source_system_id = 3
  AND per.first_name = 'Diego' AND per.last_name = 'Julca'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Soccer Legion FC Men' AND t.source_system_id = 3
  AND per.first_name = 'Abdel' AND per.last_name = 'Kone'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Soccer Legion FC Men' AND t.source_system_id = 3
  AND per.first_name = 'Mohammad' AND per.last_name = 'Nasser'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Soccer Legion FC Men' AND t.source_system_id = 3
  AND per.first_name = 'Mohamed' AND per.last_name = 'Ndao'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Soccer Legion FC Men' AND t.source_system_id = 3
  AND per.first_name = 'Cheick' AND per.last_name = 'Ndiaye'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Soccer Legion FC Men' AND t.source_system_id = 3
  AND per.first_name = 'Abraham' AND per.last_name = 'Oliver'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Soccer Legion FC Men' AND t.source_system_id = 3
  AND per.first_name = 'Daniel' AND per.last_name = 'Origi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Soccer Legion FC Men' AND t.source_system_id = 3
  AND per.first_name = 'Pedro' AND per.last_name = 'Ovono'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Soccer Legion FC Men' AND t.source_system_id = 3
  AND per.first_name = 'Philippe' AND per.last_name = 'Sainvil'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Soccer Legion FC Men' AND t.source_system_id = 3
  AND per.first_name = 'Wiljy' AND per.last_name = 'Sainvilier'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Soccer Legion FC Men' AND t.source_system_id = 3
  AND per.first_name = 'Tim' AND per.last_name = 'Viltard'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Bajas FC' AND t.source_system_id = 3
  AND per.first_name = 'Leonel' AND per.last_name = 'Bravo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Bajas FC' AND t.source_system_id = 3
  AND per.first_name = 'German' AND per.last_name = 'Campoverde'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Bajas FC' AND t.source_system_id = 3
  AND per.first_name = 'Estefano' AND per.last_name = 'Chavez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Bajas FC' AND t.source_system_id = 3
  AND per.first_name = 'Jonathan' AND per.last_name = 'Chimborazo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Bajas FC' AND t.source_system_id = 3
  AND per.first_name = 'Henry' AND per.last_name = 'Cortes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Bajas FC' AND t.source_system_id = 3
  AND per.first_name = 'Alexander' AND per.last_name = 'Flores'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Bajas FC' AND t.source_system_id = 3
  AND per.first_name = 'Brian' AND per.last_name = 'Messi Fructuoso'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Bajas FC' AND t.source_system_id = 3
  AND per.first_name = 'John' AND per.last_name = 'Jarama'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Bajas FC' AND t.source_system_id = 3
  AND per.first_name = 'Jonathan' AND per.last_name = 'Puma'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Bajas FC' AND t.source_system_id = 3
  AND per.first_name = 'Alexander' AND per.last_name = 'Rodriguez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Bajas FC' AND t.source_system_id = 3
  AND per.first_name = 'Brian' AND per.last_name = 'Rojas Hernandez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Bajas FC' AND t.source_system_id = 3
  AND per.first_name = 'Alejandro' AND per.last_name = 'Santos'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Bajas FC' AND t.source_system_id = 3
  AND per.first_name = 'Julio' AND per.last_name = 'Sotelo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Bajas FC' AND t.source_system_id = 3
  AND per.first_name = 'Yosef' AND per.last_name = 'Tamay'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Bajas FC' AND t.source_system_id = 3
  AND per.first_name = 'Edison' AND per.last_name = 'Tenelema'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Bajas FC' AND t.source_system_id = 3
  AND per.first_name = 'Nestor' AND per.last_name = 'Tobar'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Bajas FC' AND t.source_system_id = 3
  AND per.first_name = 'LARRY' AND per.last_name = 'TORRES MORAN'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Bajas FC' AND t.source_system_id = 3
  AND per.first_name = 'Anthony' AND per.last_name = 'Vallejo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Bajas FC' AND t.source_system_id = 3
  AND per.first_name = 'Abraham' AND per.last_name = 'Zepeda'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Bajas FC' AND t.source_system_id = 3
  AND per.first_name = 'Isaac' AND per.last_name = 'Zepeda'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

