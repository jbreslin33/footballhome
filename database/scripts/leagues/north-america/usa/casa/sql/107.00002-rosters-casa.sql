-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Rosters - CASA
-- Player-team relationships from team roster pages
-- Total Records: 631
-- 
-- Architecture: Players looked up by name (no hardcoded IDs)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Adé United FC' AND t.source_system_id = 2
  AND per.first_name = 'Sammy' AND per.last_name = 'Amin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Adé United FC' AND t.source_system_id = 2
  AND per.first_name = 'Jeffrey' AND per.last_name = 'Asiedu'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Adé United FC' AND t.source_system_id = 2
  AND per.first_name = 'Theo' AND per.last_name = 'Biddle'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Adé United FC' AND t.source_system_id = 2
  AND per.first_name = 'Tyler' AND per.last_name = 'Caton'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Adé United FC' AND t.source_system_id = 2
  AND per.first_name = 'Jorge' AND per.last_name = 'Cervantes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Adé United FC' AND t.source_system_id = 2
  AND per.first_name = 'Manuel' AND per.last_name = 'Chacon Fallas'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Adé United FC' AND t.source_system_id = 2
  AND per.first_name = 'Miguel' AND per.last_name = 'Cortes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Adé United FC' AND t.source_system_id = 2
  AND per.first_name = 'Tyler' AND per.last_name = 'Dautrich'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Adé United FC' AND t.source_system_id = 2
  AND per.first_name = 'Cameron' AND per.last_name = 'Dennis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Adé United FC' AND t.source_system_id = 2
  AND per.first_name = 'Aaron' AND per.last_name = 'Endres'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Adé United FC' AND t.source_system_id = 2
  AND per.first_name = 'Evan' AND per.last_name = 'Kent'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Adé United FC' AND t.source_system_id = 2
  AND per.first_name = 'Lekan' AND per.last_name = 'King'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Adé United FC' AND t.source_system_id = 2
  AND per.first_name = 'Mateo' AND per.last_name = 'Loyo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Adé United FC' AND t.source_system_id = 2
  AND per.first_name = 'Christopher' AND per.last_name = 'Manful'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Adé United FC' AND t.source_system_id = 2
  AND per.first_name = 'Sammy' AND per.last_name = 'Monistere'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Adé United FC' AND t.source_system_id = 2
  AND per.first_name = 'Rocco' AND per.last_name = 'Monteiro'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Adé United FC' AND t.source_system_id = 2
  AND per.first_name = 'Eli' AND per.last_name = 'Moraru'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Adé United FC' AND t.source_system_id = 2
  AND per.first_name = 'Zachery' AND per.last_name = 'Moyer'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Adé United FC' AND t.source_system_id = 2
  AND per.first_name = 'Michael' AND per.last_name = 'Oh'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Adé United FC' AND t.source_system_id = 2
  AND per.first_name = 'David' AND per.last_name = 'Olukoya'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Adé United FC' AND t.source_system_id = 2
  AND per.first_name = 'Tamer' AND per.last_name = 'Ozturk'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Adé United FC' AND t.source_system_id = 2
  AND per.first_name = 'Joao' AND per.last_name = 'Patelli Ramos dos Santos'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Adé United FC' AND t.source_system_id = 2
  AND per.first_name = 'Ethan' AND per.last_name = 'Reta'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Adé United FC' AND t.source_system_id = 2
  AND per.first_name = 'Gonzalo' AND per.last_name = 'Reyes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Adé United FC' AND t.source_system_id = 2
  AND per.first_name = 'justin' AND per.last_name = 'reynoso'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Adé United FC' AND t.source_system_id = 2
  AND per.first_name = 'Cole' AND per.last_name = 'Roddy'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Adé United FC' AND t.source_system_id = 2
  AND per.first_name = 'Adam' AND per.last_name = 'Silberg'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Adé United FC' AND t.source_system_id = 2
  AND per.first_name = 'Ethan' AND per.last_name = 'Spence'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Adé United FC' AND t.source_system_id = 2
  AND per.first_name = 'Kevin' AND per.last_name = 'Taipe'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC II' AND t.source_system_id = 2
  AND per.first_name = 'Djalilou' AND per.last_name = 'Adam-Djobo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC II' AND t.source_system_id = 2
  AND per.first_name = 'Mitchel' AND per.last_name = 'Alfaro'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC II' AND t.source_system_id = 2
  AND per.first_name = 'Luke' AND per.last_name = 'Archibald'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC II' AND t.source_system_id = 2
  AND per.first_name = 'Noah' AND per.last_name = 'Blodget'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC II' AND t.source_system_id = 2
  AND per.first_name = 'Gonazalo' AND per.last_name = 'Chiang'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC II' AND t.source_system_id = 2
  AND per.first_name = 'Hayden' AND per.last_name = 'Cote'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC II' AND t.source_system_id = 2
  AND per.first_name = 'Brandon' AND per.last_name = 'Da Silva'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC II' AND t.source_system_id = 2
  AND per.first_name = 'Brandon' AND per.last_name = 'DeAngelo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC II' AND t.source_system_id = 2
  AND per.first_name = 'Khadim' AND per.last_name = 'Drame'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC II' AND t.source_system_id = 2
  AND per.first_name = 'Emin' AND per.last_name = 'Gunaydin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC II' AND t.source_system_id = 2
  AND per.first_name = 'Vincent' AND per.last_name = 'Guzzo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC II' AND t.source_system_id = 2
  AND per.first_name = 'Rabah' AND per.last_name = 'Hameg'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC II' AND t.source_system_id = 2
  AND per.first_name = 'Anthony' AND per.last_name = 'Jenkins'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC II' AND t.source_system_id = 2
  AND per.first_name = 'Sincere' AND per.last_name = 'Kato'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC II' AND t.source_system_id = 2
  AND per.first_name = 'Cooper' AND per.last_name = 'Lang'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC II' AND t.source_system_id = 2
  AND per.first_name = 'Alex' AND per.last_name = 'Lewis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC II' AND t.source_system_id = 2
  AND per.first_name = 'Lucien' AND per.last_name = 'Maslin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC II' AND t.source_system_id = 2
  AND per.first_name = 'Dayvon' AND per.last_name = 'Mbu'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC II' AND t.source_system_id = 2
  AND per.first_name = 'Kevin' AND per.last_name = 'Munive'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC II' AND t.source_system_id = 2
  AND per.first_name = 'Matthew' AND per.last_name = 'Pastore'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC II' AND t.source_system_id = 2
  AND per.first_name = 'Ethan' AND per.last_name = 'Spinatto'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC II' AND t.source_system_id = 2
  AND per.first_name = 'Travis' AND per.last_name = 'Spotts'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC II' AND t.source_system_id = 2
  AND per.first_name = 'Marc' AND per.last_name = 'M’bia M’bida-Essind Pastor'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC II' AND t.source_system_id = 2
  AND per.first_name = 'Logan' AND per.last_name = 'Shaw'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC II' AND t.source_system_id = 2
  AND per.first_name = 'Adrian' AND per.last_name = 'Rodriquez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC II' AND t.source_system_id = 2
  AND per.first_name = 'Veysel' AND per.last_name = 'Tut'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC II' AND t.source_system_id = 2
  AND per.first_name = 'John' AND per.last_name = 'Waddell'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Sierra Stars' AND t.source_system_id = 2
  AND per.first_name = 'Issac' AND per.last_name = 'Agyapong'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Sierra Stars' AND t.source_system_id = 2
  AND per.first_name = 'Abdul Razak' AND per.last_name = 'Alhassan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Sierra Stars' AND t.source_system_id = 2
  AND per.first_name = 'Hassan' AND per.last_name = 'Bah'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Sierra Stars' AND t.source_system_id = 2
  AND per.first_name = 'Abu' AND per.last_name = 'Bangura'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Sierra Stars' AND t.source_system_id = 2
  AND per.first_name = 'Mustapha' AND per.last_name = 'Bangura'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Sierra Stars' AND t.source_system_id = 2
  AND per.first_name = 'Abubakarr' AND per.last_name = 'Bangura'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Sierra Stars' AND t.source_system_id = 2
  AND per.first_name = 'Demba' AND per.last_name = 'Camara'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Sierra Stars' AND t.source_system_id = 2
  AND per.first_name = 'Cephas' AND per.last_name = 'Forson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Sierra Stars' AND t.source_system_id = 2
  AND per.first_name = 'Richardo' AND per.last_name = 'Gaye'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Sierra Stars' AND t.source_system_id = 2
  AND per.first_name = 'John' AND per.last_name = 'Gwah'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Sierra Stars' AND t.source_system_id = 2
  AND per.first_name = 'Abraham' AND per.last_name = 'Kamara'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Sierra Stars' AND t.source_system_id = 2
  AND per.first_name = 'Francis' AND per.last_name = 'Kamara'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Sierra Stars' AND t.source_system_id = 2
  AND per.first_name = 'Mohamed' AND per.last_name = 'Kamara'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Sierra Stars' AND t.source_system_id = 2
  AND per.first_name = 'Alpha' AND per.last_name = 'Kanu'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Sierra Stars' AND t.source_system_id = 2
  AND per.first_name = 'Nyakeh' AND per.last_name = 'Kiawoh'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Sierra Stars' AND t.source_system_id = 2
  AND per.first_name = 'Sory' AND per.last_name = 'Konneh'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Sierra Stars' AND t.source_system_id = 2
  AND per.first_name = 'Idrissa' AND per.last_name = 'Konobundor'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Sierra Stars' AND t.source_system_id = 2
  AND per.first_name = 'Yayah' AND per.last_name = 'Koroma'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Sierra Stars' AND t.source_system_id = 2
  AND per.first_name = 'Alpha' AND per.last_name = 'Koroma'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Sierra Stars' AND t.source_system_id = 2
  AND per.first_name = 'Moses' AND per.last_name = 'Kpalu'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Sierra Stars' AND t.source_system_id = 2
  AND per.first_name = 'Foday' AND per.last_name = 'Kuyateh'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Sierra Stars' AND t.source_system_id = 2
  AND per.first_name = 'Badamasie' AND per.last_name = 'Mujtabah'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Sierra Stars' AND t.source_system_id = 2
  AND per.first_name = 'Benedict' AND per.last_name = 'Olaloye'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Sierra Stars' AND t.source_system_id = 2
  AND per.first_name = 'Emmanuel' AND per.last_name = 'Onwubiko'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Sierra Stars' AND t.source_system_id = 2
  AND per.first_name = 'Samuel' AND per.last_name = 'Sandi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Sierra Stars' AND t.source_system_id = 2
  AND per.first_name = 'Alim' AND per.last_name = 'Sesay'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Sierra Stars' AND t.source_system_id = 2
  AND per.first_name = 'Abdul' AND per.last_name = 'Sesay'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Sierra Stars' AND t.source_system_id = 2
  AND per.first_name = 'Favor' AND per.last_name = 'WeahJr'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Persepolis FC' AND t.source_system_id = 2
  AND per.first_name = 'Sulaiman' AND per.last_name = 'Adegoke'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Persepolis FC' AND t.source_system_id = 2
  AND per.first_name = 'Promise' AND per.last_name = 'Adeyi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Persepolis FC' AND t.source_system_id = 2
  AND per.first_name = 'Ashkon' AND per.last_name = 'Ashrafiuon'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Persepolis FC' AND t.source_system_id = 2
  AND per.first_name = 'Thomas' AND per.last_name = 'Attamante'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Persepolis FC' AND t.source_system_id = 2
  AND per.first_name = 'Mama' AND per.last_name = 'Bah'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Persepolis FC' AND t.source_system_id = 2
  AND per.first_name = 'Cee' AND per.last_name = 'Brown'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Persepolis FC' AND t.source_system_id = 2
  AND per.first_name = 'John' AND per.last_name = 'Costello'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Persepolis FC' AND t.source_system_id = 2
  AND per.first_name = 'patrick' AND per.last_name = 'cronin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Persepolis FC' AND t.source_system_id = 2
  AND per.first_name = 'Jorge' AND per.last_name = 'Diaz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Persepolis FC' AND t.source_system_id = 2
  AND per.first_name = 'T-Ben' AND per.last_name = 'Donnie'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Persepolis FC' AND t.source_system_id = 2
  AND per.first_name = 'Oluwaseun' AND per.last_name = 'Falayi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Persepolis FC' AND t.source_system_id = 2
  AND per.first_name = 'Alfred Wakai' AND per.last_name = 'Gibson jr'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Persepolis FC' AND t.source_system_id = 2
  AND per.first_name = 'Peter' AND per.last_name = 'Jakubik'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Persepolis FC' AND t.source_system_id = 2
  AND per.first_name = 'Mark' AND per.last_name = 'Manis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Persepolis FC' AND t.source_system_id = 2
  AND per.first_name = 'Kevin' AND per.last_name = 'Sadeghipour'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Persepolis FC' AND t.source_system_id = 2
  AND per.first_name = 'Zouma' AND per.last_name = 'Sanya'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Persepolis FC' AND t.source_system_id = 2
  AND per.first_name = 'Christopher' AND per.last_name = 'Selekpoh'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Persepolis FC' AND t.source_system_id = 2
  AND per.first_name = 'CJ' AND per.last_name = 'Smolyn'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Persepolis FC' AND t.source_system_id = 2
  AND per.first_name = 'Fawaz' AND per.last_name = 'Somoye'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Persepolis FC' AND t.source_system_id = 2
  AND per.first_name = 'Sebastain' AND per.last_name = 'Stelmach'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Persepolis FC' AND t.source_system_id = 2
  AND per.first_name = 'Tonny' AND per.last_name = 'Temple'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Persepolis FC' AND t.source_system_id = 2
  AND per.first_name = 'Christian' AND per.last_name = 'Toussaint'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Persepolis FC' AND t.source_system_id = 2
  AND per.first_name = 'Henry' AND per.last_name = 'Tye'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Persepolis FC' AND t.source_system_id = 2
  AND per.first_name = 'Bill' AND per.last_name = 'Wilson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Phoenix SCM' AND t.source_system_id = 2
  AND per.first_name = 'Kevin' AND per.last_name = 'Bowers'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Phoenix SCM' AND t.source_system_id = 2
  AND per.first_name = 'Emile' AND per.last_name = 'Diderot'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Phoenix SCM' AND t.source_system_id = 2
  AND per.first_name = 'Joseph' AND per.last_name = 'Duddy'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Phoenix SCM' AND t.source_system_id = 2
  AND per.first_name = 'Ayoub' AND per.last_name = 'Fask'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Phoenix SCM' AND t.source_system_id = 2
  AND per.first_name = 'Alexander' AND per.last_name = 'Graul'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Phoenix SCM' AND t.source_system_id = 2
  AND per.first_name = 'Brendan' AND per.last_name = 'Hanratty'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Phoenix SCM' AND t.source_system_id = 2
  AND per.first_name = 'Kevin' AND per.last_name = 'Hanuscin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Phoenix SCM' AND t.source_system_id = 2
  AND per.first_name = 'Malcolm' AND per.last_name = 'Kane'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Phoenix SCM' AND t.source_system_id = 2
  AND per.first_name = 'Nicholas' AND per.last_name = 'LeFevre'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Phoenix SCM' AND t.source_system_id = 2
  AND per.first_name = 'Juan' AND per.last_name = 'López'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Phoenix SCM' AND t.source_system_id = 2
  AND per.first_name = 'Jimmy' AND per.last_name = 'Manning'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Phoenix SCM' AND t.source_system_id = 2
  AND per.first_name = 'Alejandro' AND per.last_name = 'Medina'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Phoenix SCM' AND t.source_system_id = 2
  AND per.first_name = 'Diego' AND per.last_name = 'Moreira Pereira'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Phoenix SCM' AND t.source_system_id = 2
  AND per.first_name = 'Jose' AND per.last_name = 'Moura Filho'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Phoenix SCM' AND t.source_system_id = 2
  AND per.first_name = 'Khalidi' AND per.last_name = 'Ponela'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Phoenix SCM' AND t.source_system_id = 2
  AND per.first_name = 'Alec' AND per.last_name = 'Power'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Phoenix SCM' AND t.source_system_id = 2
  AND per.first_name = 'Jim' AND per.last_name = 'Power'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philly BlackStars' AND t.source_system_id = 2
  AND per.first_name = 'Myles' AND per.last_name = 'Addy'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philly BlackStars' AND t.source_system_id = 2
  AND per.first_name = 'Charles' AND per.last_name = 'Afful'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philly BlackStars' AND t.source_system_id = 2
  AND per.first_name = 'Ahmed' AND per.last_name = 'Ali'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philly BlackStars' AND t.source_system_id = 2
  AND per.first_name = 'Fred' AND per.last_name = 'Amadi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philly BlackStars' AND t.source_system_id = 2
  AND per.first_name = 'Edmond' AND per.last_name = 'Ansah'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philly BlackStars' AND t.source_system_id = 2
  AND per.first_name = 'Joe' AND per.last_name = 'Attakora'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philly BlackStars' AND t.source_system_id = 2
  AND per.first_name = 'Christian' AND per.last_name = 'Bamba'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philly BlackStars' AND t.source_system_id = 2
  AND per.first_name = 'Al hassane' AND per.last_name = 'Belemou'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philly BlackStars' AND t.source_system_id = 2
  AND per.first_name = 'Prince' AND per.last_name = 'Boafo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philly BlackStars' AND t.source_system_id = 2
  AND per.first_name = 'Dilan' AND per.last_name = 'Carrasco-Palma'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philly BlackStars' AND t.source_system_id = 2
  AND per.first_name = 'Michael' AND per.last_name = 'Danquah'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philly BlackStars' AND t.source_system_id = 2
  AND per.first_name = 'Bartels' AND per.last_name = 'Danquah'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philly BlackStars' AND t.source_system_id = 2
  AND per.first_name = 'Joshua' AND per.last_name = 'Deets'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philly BlackStars' AND t.source_system_id = 2
  AND per.first_name = 'Landon' AND per.last_name = 'Goodison'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philly BlackStars' AND t.source_system_id = 2
  AND per.first_name = 'Bernard' AND per.last_name = 'Kyei-Mensah'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philly BlackStars' AND t.source_system_id = 2
  AND per.first_name = 'Imoro' AND per.last_name = 'latif'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philly BlackStars' AND t.source_system_id = 2
  AND per.first_name = 'Trinidad' AND per.last_name = 'Maldonado'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philly BlackStars' AND t.source_system_id = 2
  AND per.first_name = 'Landon' AND per.last_name = 'Neison'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philly BlackStars' AND t.source_system_id = 2
  AND per.first_name = 'Richard' AND per.last_name = 'Sarpong'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philly BlackStars' AND t.source_system_id = 2
  AND per.first_name = 'Kwamina' AND per.last_name = 'Thompson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philly BlackStars' AND t.source_system_id = 2
  AND per.first_name = 'Patrick' AND per.last_name = 'Tierney'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philly BlackStars' AND t.source_system_id = 2
  AND per.first_name = 'Logan' AND per.last_name = 'Brock'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Illyrians FC' AND t.source_system_id = 2
  AND per.first_name = 'Eljo' AND per.last_name = 'Agolli'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Illyrians FC' AND t.source_system_id = 2
  AND per.first_name = 'Carlos' AND per.last_name = 'Aroche'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Illyrians FC' AND t.source_system_id = 2
  AND per.first_name = 'Jayden' AND per.last_name = 'Barragan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Illyrians FC' AND t.source_system_id = 2
  AND per.first_name = 'Christian' AND per.last_name = 'Cardenas'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Illyrians FC' AND t.source_system_id = 2
  AND per.first_name = 'Ermal' AND per.last_name = 'Caushi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Illyrians FC' AND t.source_system_id = 2
  AND per.first_name = 'Ilir' AND per.last_name = 'Cepani'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Illyrians FC' AND t.source_system_id = 2
  AND per.first_name = 'Klevisi' AND per.last_name = 'Dervishi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Illyrians FC' AND t.source_system_id = 2
  AND per.first_name = 'Sidiki' AND per.last_name = 'Fofana'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Illyrians FC' AND t.source_system_id = 2
  AND per.first_name = 'Evlad' AND per.last_name = 'Fonda'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Illyrians FC' AND t.source_system_id = 2
  AND per.first_name = 'Zakaria' AND per.last_name = 'Gueddar'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Illyrians FC' AND t.source_system_id = 2
  AND per.first_name = 'Gavin' AND per.last_name = 'Hagen'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Illyrians FC' AND t.source_system_id = 2
  AND per.first_name = 'Mario' AND per.last_name = 'Kureta'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Illyrians FC' AND t.source_system_id = 2
  AND per.first_name = 'Olen' AND per.last_name = 'Laze'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Illyrians FC' AND t.source_system_id = 2
  AND per.first_name = 'Mario' AND per.last_name = 'Morina'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Illyrians FC' AND t.source_system_id = 2
  AND per.first_name = 'Ramadan' AND per.last_name = 'Nazeraj'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Illyrians FC' AND t.source_system_id = 2
  AND per.first_name = 'Youssef' AND per.last_name = 'Omer'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Illyrians FC' AND t.source_system_id = 2
  AND per.first_name = 'Eldion' AND per.last_name = 'Pajollari'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Illyrians FC' AND t.source_system_id = 2
  AND per.first_name = 'Albion' AND per.last_name = 'Pajollari'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Illyrians FC' AND t.source_system_id = 2
  AND per.first_name = 'Elsion' AND per.last_name = 'Pajollari'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Illyrians FC' AND t.source_system_id = 2
  AND per.first_name = 'Brahim' AND per.last_name = 'Saouid'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Illyrians FC' AND t.source_system_id = 2
  AND per.first_name = 'Temur' AND per.last_name = 'Temirov'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Illyrians FC' AND t.source_system_id = 2
  AND per.first_name = 'Achilles' AND per.last_name = 'Triantafyllos'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Illyrians FC' AND t.source_system_id = 2
  AND per.first_name = 'Brendan' AND per.last_name = 'Werner'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Victor' AND per.last_name = 'Baidel'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Weder' AND per.last_name = 'Barretos'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Aboubacar' AND per.last_name = 'Bayo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Igor' AND per.last_name = 'Bonfim'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Samuel' AND per.last_name = 'Botelho'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Inaldo' AND per.last_name = 'Botelho'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Luke' AND per.last_name = 'Breslin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Walter' AND per.last_name = 'Candido'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Christopher' AND per.last_name = 'Da Silva'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Nycolas' AND per.last_name = 'De Jesus'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Lucas' AND per.last_name = 'De Morais'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Abdoul' AND per.last_name = 'Diallo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Cloves' AND per.last_name = 'Filho'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Abouya' AND per.last_name = 'Gangue'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Andy' AND per.last_name = 'Hizdri'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Alexander' AND per.last_name = 'Lara'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Pedro' AND per.last_name = 'Lara'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Reginaldo' AND per.last_name = 'Leite'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Valentino' AND per.last_name = 'Martinez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'David' AND per.last_name = 'Masi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'John' AND per.last_name = 'Oladele'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Junior' AND per.last_name = 'Oliveira'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Christian' AND per.last_name = 'Oliveira'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Jemirkel' AND per.last_name = 'Ornaque'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Marcos' AND per.last_name = 'Ribeiro'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Denis' AND per.last_name = 'Sousa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Esnayder' AND per.last_name = 'Josue'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Boys Club' AND t.source_system_id = 2
  AND per.first_name = 'Majid' AND per.last_name = 'Kawa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Persepolis United FC II' AND t.source_system_id = 2
  AND per.first_name = 'Hamid' AND per.last_name = 'Afolabi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Persepolis United FC II' AND t.source_system_id = 2
  AND per.first_name = 'Bassam' AND per.last_name = 'Ahmed'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Persepolis United FC II' AND t.source_system_id = 2
  AND per.first_name = 'Clement' AND per.last_name = 'Atebi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Persepolis United FC II' AND t.source_system_id = 2
  AND per.first_name = 'Nicholas' AND per.last_name = 'Bowman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Persepolis United FC II' AND t.source_system_id = 2
  AND per.first_name = 'Donavan' AND per.last_name = 'Brady'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Persepolis United FC II' AND t.source_system_id = 2
  AND per.first_name = 'Uriel' AND per.last_name = 'Cabello'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Persepolis United FC II' AND t.source_system_id = 2
  AND per.first_name = 'Clarence' AND per.last_name = 'Cole'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Persepolis United FC II' AND t.source_system_id = 2
  AND per.first_name = 'Joseph' AND per.last_name = 'Cunningham'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Persepolis United FC II' AND t.source_system_id = 2
  AND per.first_name = 'Erick' AND per.last_name = 'David'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Persepolis United FC II' AND t.source_system_id = 2
  AND per.first_name = 'Tushaar' AND per.last_name = 'Godbole'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Persepolis United FC II' AND t.source_system_id = 2
  AND per.first_name = 'Benjamin' AND per.last_name = 'Goudvis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Persepolis United FC II' AND t.source_system_id = 2
  AND per.first_name = 'Jesse' AND per.last_name = 'Haines'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Persepolis United FC II' AND t.source_system_id = 2
  AND per.first_name = 'Evan' AND per.last_name = 'Hodulik'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Persepolis United FC II' AND t.source_system_id = 2
  AND per.first_name = 'Francis' AND per.last_name = 'Kanu'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Persepolis United FC II' AND t.source_system_id = 2
  AND per.first_name = 'Alex' AND per.last_name = 'Kebuz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Persepolis United FC II' AND t.source_system_id = 2
  AND per.first_name = 'Sean' AND per.last_name = 'Khazael'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Persepolis United FC II' AND t.source_system_id = 2
  AND per.first_name = 'Osman' AND per.last_name = 'Lopez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Persepolis United FC II' AND t.source_system_id = 2
  AND per.first_name = 'Payman' AND per.last_name = 'Mirzaei'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Persepolis United FC II' AND t.source_system_id = 2
  AND per.first_name = 'Jevin' AND per.last_name = 'Nathaniel'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Persepolis United FC II' AND t.source_system_id = 2
  AND per.first_name = 'Armando' AND per.last_name = 'Samukai'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Persepolis United FC II' AND t.source_system_id = 2
  AND per.first_name = 'Michael' AND per.last_name = 'Sottle'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Persepolis United FC II' AND t.source_system_id = 2
  AND per.first_name = 'Boubacar' AND per.last_name = 'Traire'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Old Timers Club' AND t.source_system_id = 2
  AND per.first_name = 'Hassane' AND per.last_name = 'Abdellaoui'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Old Timers Club' AND t.source_system_id = 2
  AND per.first_name = 'Erwa' AND per.last_name = 'Babiker'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Old Timers Club' AND t.source_system_id = 2
  AND per.first_name = 'Oumar' AND per.last_name = 'Barry'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Old Timers Club' AND t.source_system_id = 2
  AND per.first_name = 'Logan' AND per.last_name = 'Bersani'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Old Timers Club' AND t.source_system_id = 2
  AND per.first_name = 'James' AND per.last_name = 'Breslin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Old Timers Club' AND t.source_system_id = 2
  AND per.first_name = 'Luis' AND per.last_name = 'De Jesus'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Old Timers Club' AND t.source_system_id = 2
  AND per.first_name = 'Marco' AND per.last_name = 'Delgado'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Old Timers Club' AND t.source_system_id = 2
  AND per.first_name = 'Edwin' AND per.last_name = 'Garcia'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Old Timers Club' AND t.source_system_id = 2
  AND per.first_name = 'John' AND per.last_name = 'Gonzalez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Old Timers Club' AND t.source_system_id = 2
  AND per.first_name = 'Sangin' AND per.last_name = 'Hedayatullah'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Old Timers Club' AND t.source_system_id = 2
  AND per.first_name = 'Miles' AND per.last_name = 'Henry'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Old Timers Club' AND t.source_system_id = 2
  AND per.first_name = 'Arif' AND per.last_name = 'Hossain'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Old Timers Club' AND t.source_system_id = 2
  AND per.first_name = 'Zuhab' AND per.last_name = 'Imran'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Old Timers Club' AND t.source_system_id = 2
  AND per.first_name = 'Carl' AND per.last_name = 'Laroche'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Old Timers Club' AND t.source_system_id = 2
  AND per.first_name = 'Jervin' AND per.last_name = 'Lemus'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Old Timers Club' AND t.source_system_id = 2
  AND per.first_name = 'Christian' AND per.last_name = 'Lopez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Old Timers Club' AND t.source_system_id = 2
  AND per.first_name = 'John' AND per.last_name = 'Madureira'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Old Timers Club' AND t.source_system_id = 2
  AND per.first_name = 'Elmer' AND per.last_name = 'Mendoza'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Old Timers Club' AND t.source_system_id = 2
  AND per.first_name = 'Dylan' AND per.last_name = 'Moreno'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Old Timers Club' AND t.source_system_id = 2
  AND per.first_name = 'Ibrahim' AND per.last_name = 'Nassar'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Old Timers Club' AND t.source_system_id = 2
  AND per.first_name = 'Babacar' AND per.last_name = 'Ndiaye'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Old Timers Club' AND t.source_system_id = 2
  AND per.first_name = 'Zion' AND per.last_name = 'Nwalipenja'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Old Timers Club' AND t.source_system_id = 2
  AND per.first_name = 'Fabian' AND per.last_name = 'Padilla'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Old Timers Club' AND t.source_system_id = 2
  AND per.first_name = 'Caleb' AND per.last_name = 'Rojas'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Old Timers Club' AND t.source_system_id = 2
  AND per.first_name = 'Anthony' AND per.last_name = 'Sagustume'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Old Timers Club' AND t.source_system_id = 2
  AND per.first_name = 'Ali' AND per.last_name = 'Salah'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Old Timers Club' AND t.source_system_id = 2
  AND per.first_name = 'Daniel' AND per.last_name = 'Salmanca'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Old Timers Club' AND t.source_system_id = 2
  AND per.first_name = 'Leo' AND per.last_name = 'Santa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse Old Timers Club' AND t.source_system_id = 2
  AND per.first_name = 'Christopher' AND per.last_name = 'Solis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Phoenix SCR' AND t.source_system_id = 2
  AND per.first_name = 'Fritz' AND per.last_name = 'Amazan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Phoenix SCR' AND t.source_system_id = 2
  AND per.first_name = 'David' AND per.last_name = 'Aquino'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Phoenix SCR' AND t.source_system_id = 2
  AND per.first_name = 'Christian' AND per.last_name = 'Aurand'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Phoenix SCR' AND t.source_system_id = 2
  AND per.first_name = 'TJ' AND per.last_name = 'Butler'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Phoenix SCR' AND t.source_system_id = 2
  AND per.first_name = 'Troy' AND per.last_name = 'Eutermoser'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Phoenix SCR' AND t.source_system_id = 2
  AND per.first_name = 'Alex' AND per.last_name = 'Freeman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Phoenix SCR' AND t.source_system_id = 2
  AND per.first_name = 'William' AND per.last_name = 'Hanratty'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Phoenix SCR' AND t.source_system_id = 2
  AND per.first_name = 'Ryan' AND per.last_name = 'Kerr'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Phoenix SCR' AND t.source_system_id = 2
  AND per.first_name = 'Jake' AND per.last_name = 'Kucowski'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Phoenix SCR' AND t.source_system_id = 2
  AND per.first_name = 'Rood charleson' AND per.last_name = 'Labossiere'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Phoenix SCR' AND t.source_system_id = 2
  AND per.first_name = 'Ed-steeve' AND per.last_name = 'Madere'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Phoenix SCR' AND t.source_system_id = 2
  AND per.first_name = 'Daniel' AND per.last_name = 'Maggio'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Phoenix SCR' AND t.source_system_id = 2
  AND per.first_name = 'Christopher' AND per.last_name = 'McDonnell'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Phoenix SCR' AND t.source_system_id = 2
  AND per.first_name = 'Merabi' AND per.last_name = 'Megreladze'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Phoenix SCR' AND t.source_system_id = 2
  AND per.first_name = 'Marc Jerry' AND per.last_name = 'Midy'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Phoenix SCR' AND t.source_system_id = 2
  AND per.first_name = 'Giorgi' AND per.last_name = 'Nikabadze'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Phoenix SCR' AND t.source_system_id = 2
  AND per.first_name = 'Fran' AND per.last_name = 'Pitonyak'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Phoenix SCR' AND t.source_system_id = 2
  AND per.first_name = 'Chris' AND per.last_name = 'Rutledge'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Phoenix SCR' AND t.source_system_id = 2
  AND per.first_name = 'Revazi' AND per.last_name = 'Tcheshmaritashvili'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Phoenix SCR' AND t.source_system_id = 2
  AND per.first_name = 'Nick' AND per.last_name = 'Webster'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia SC Select' AND t.source_system_id = 2
  AND per.first_name = 'Costas' AND per.last_name = 'Angelis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia SC Select' AND t.source_system_id = 2
  AND per.first_name = 'Jesus' AND per.last_name = 'Colin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia SC Select' AND t.source_system_id = 2
  AND per.first_name = 'Bryan' AND per.last_name = 'Da Silva'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia SC Select' AND t.source_system_id = 2
  AND per.first_name = 'Yoofi' AND per.last_name = 'Danquah'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia SC Select' AND t.source_system_id = 2
  AND per.first_name = 'Bryan' AND per.last_name = 'De Quadros'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia SC Select' AND t.source_system_id = 2
  AND per.first_name = 'Robert' AND per.last_name = 'Ertel'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia SC Select' AND t.source_system_id = 2
  AND per.first_name = 'Julio' AND per.last_name = 'Evangilista'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia SC Select' AND t.source_system_id = 2
  AND per.first_name = 'Ahmed' AND per.last_name = 'Faik'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia SC Select' AND t.source_system_id = 2
  AND per.first_name = 'Kaua' AND per.last_name = 'Freitas'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia SC Select' AND t.source_system_id = 2
  AND per.first_name = 'Kareem' AND per.last_name = 'Green'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia SC Select' AND t.source_system_id = 2
  AND per.first_name = 'Nigel' AND per.last_name = 'Johnson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia SC Select' AND t.source_system_id = 2
  AND per.first_name = 'Paul' AND per.last_name = 'Kwoyelo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia SC Select' AND t.source_system_id = 2
  AND per.first_name = 'Jonatan' AND per.last_name = 'Lopez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia SC Select' AND t.source_system_id = 2
  AND per.first_name = 'Zach' AND per.last_name = 'Morrison'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia SC Select' AND t.source_system_id = 2
  AND per.first_name = 'Diego' AND per.last_name = 'Murillo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia SC Select' AND t.source_system_id = 2
  AND per.first_name = 'Paolo' AND per.last_name = 'Musumeci'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia SC Select' AND t.source_system_id = 2
  AND per.first_name = 'Zabi' AND per.last_name = 'Naseri'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia SC Select' AND t.source_system_id = 2
  AND per.first_name = 'Roni' AND per.last_name = 'Rountree'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia SC Select' AND t.source_system_id = 2
  AND per.first_name = 'Luca' AND per.last_name = 'Ruggiero'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia SC Select' AND t.source_system_id = 2
  AND per.first_name = 'Mohammad' AND per.last_name = 'Sanim'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia SC Select' AND t.source_system_id = 2
  AND per.first_name = 'Aaron' AND per.last_name = 'Sexton'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia SC Select' AND t.source_system_id = 2
  AND per.first_name = 'Lamin' AND per.last_name = 'Sidibeh'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia SC Select' AND t.source_system_id = 2
  AND per.first_name = 'Anis' AND per.last_name = 'Slimane'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia SC Select' AND t.source_system_id = 2
  AND per.first_name = 'Casey' AND per.last_name = 'Sorell'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia SC Select' AND t.source_system_id = 2
  AND per.first_name = 'Cavit' AND per.last_name = 'ULA'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia SC Select' AND t.source_system_id = 2
  AND per.first_name = 'Thiago' AND per.last_name = 'Vazquez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia SC Select' AND t.source_system_id = 2
  AND per.first_name = 'Sergio' AND per.last_name = 'Villanueva'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia SC Select' AND t.source_system_id = 2
  AND per.first_name = 'Michael' AND per.last_name = 'Wambold'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia SC Select' AND t.source_system_id = 2
  AND per.first_name = 'Phillip' AND per.last_name = 'Washington'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Club de Futbol Armada' AND t.source_system_id = 2
  AND per.first_name = 'Michael' AND per.last_name = 'Abarca'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Club de Futbol Armada' AND t.source_system_id = 2
  AND per.first_name = 'Victor' AND per.last_name = 'Agudelo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Club de Futbol Armada' AND t.source_system_id = 2
  AND per.first_name = 'Jonatan' AND per.last_name = 'Alberto'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Club de Futbol Armada' AND t.source_system_id = 2
  AND per.first_name = 'Colon' AND per.last_name = 'Anthony'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Club de Futbol Armada' AND t.source_system_id = 2
  AND per.first_name = 'Diego' AND per.last_name = 'Beltran Vega'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Club de Futbol Armada' AND t.source_system_id = 2
  AND per.first_name = 'Johan' AND per.last_name = 'Bolton'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Club de Futbol Armada' AND t.source_system_id = 2
  AND per.first_name = 'Manuel' AND per.last_name = 'Camayo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Club de Futbol Armada' AND t.source_system_id = 2
  AND per.first_name = 'Errol' AND per.last_name = 'Castro'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Club de Futbol Armada' AND t.source_system_id = 2
  AND per.first_name = 'Carlos' AND per.last_name = 'Chacon'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Club de Futbol Armada' AND t.source_system_id = 2
  AND per.first_name = 'Jose' AND per.last_name = 'Duarte'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Club de Futbol Armada' AND t.source_system_id = 2
  AND per.first_name = 'Arnoldo' AND per.last_name = 'Emeiler'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Club de Futbol Armada' AND t.source_system_id = 2
  AND per.first_name = 'Balron' AND per.last_name = 'Escobar'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Club de Futbol Armada' AND t.source_system_id = 2
  AND per.first_name = 'Marcelo' AND per.last_name = 'Gamboa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Club de Futbol Armada' AND t.source_system_id = 2
  AND per.first_name = 'Miguel' AND per.last_name = 'Garcia'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Club de Futbol Armada' AND t.source_system_id = 2
  AND per.first_name = 'Juan Carlos' AND per.last_name = 'Guevara'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Club de Futbol Armada' AND t.source_system_id = 2
  AND per.first_name = 'Gustavo' AND per.last_name = 'Guitierez Cuervo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Club de Futbol Armada' AND t.source_system_id = 2
  AND per.first_name = 'Fabricio' AND per.last_name = 'Guzman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Club de Futbol Armada' AND t.source_system_id = 2
  AND per.first_name = 'Smaikel Sibaja' AND per.last_name = 'Guzman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Club de Futbol Armada' AND t.source_system_id = 2
  AND per.first_name = 'Eder' AND per.last_name = 'Guzman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Club de Futbol Armada' AND t.source_system_id = 2
  AND per.first_name = 'Danior' AND per.last_name = 'Hernandez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Club de Futbol Armada' AND t.source_system_id = 2
  AND per.first_name = 'Yerald' AND per.last_name = 'Jimenez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Club de Futbol Armada' AND t.source_system_id = 2
  AND per.first_name = 'Maicol' AND per.last_name = 'Martinez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Club de Futbol Armada' AND t.source_system_id = 2
  AND per.first_name = 'Obed' AND per.last_name = 'Mayorga Curtis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Club de Futbol Armada' AND t.source_system_id = 2
  AND per.first_name = 'Melber' AND per.last_name = 'Ortega'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Club de Futbol Armada' AND t.source_system_id = 2
  AND per.first_name = 'Gelder' AND per.last_name = 'Ortiz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Club de Futbol Armada' AND t.source_system_id = 2
  AND per.first_name = 'Joseph' AND per.last_name = 'Piedra Retana'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Club de Futbol Armada' AND t.source_system_id = 2
  AND per.first_name = 'Luis' AND per.last_name = 'Retana'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Club de Futbol Armada' AND t.source_system_id = 2
  AND per.first_name = 'Ronny' AND per.last_name = 'Rodriquez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Club de Futbol Armada' AND t.source_system_id = 2
  AND per.first_name = 'Alexander' AND per.last_name = 'Rodriquez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Club de Futbol Armada' AND t.source_system_id = 2
  AND per.first_name = 'Andres' AND per.last_name = 'Rojas'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Club de Futbol Armada' AND t.source_system_id = 2
  AND per.first_name = 'Kenneth' AND per.last_name = 'Salazar'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Club de Futbol Armada' AND t.source_system_id = 2
  AND per.first_name = 'Adilcer' AND per.last_name = 'Santiago'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Club de Futbol Armada' AND t.source_system_id = 2
  AND per.first_name = 'Axel' AND per.last_name = 'Villanueva'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Club de Futbol Armada' AND t.source_system_id = 2
  AND per.first_name = 'Sergio' AND per.last_name = 'Zuluaga'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Sewell''s Old Boys' AND t.source_system_id = 2
  AND per.first_name = 'Alexander' AND per.last_name = 'Garcia'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Sewell''s Old Boys' AND t.source_system_id = 2
  AND per.first_name = 'Jeshohaih' AND per.last_name = 'Hernandez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Sewell''s Old Boys' AND t.source_system_id = 2
  AND per.first_name = 'Adam' AND per.last_name = 'Leal'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Sewell''s Old Boys' AND t.source_system_id = 2
  AND per.first_name = 'Alexander' AND per.last_name = 'Patton'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Sewell''s Old Boys' AND t.source_system_id = 2
  AND per.first_name = 'Fred' AND per.last_name = 'Renzulli'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Sewell''s Old Boys' AND t.source_system_id = 2
  AND per.first_name = 'Jackson' AND per.last_name = 'Stuetz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Sewell''s Old Boys' AND t.source_system_id = 2
  AND per.first_name = 'Joseph' AND per.last_name = 'Romano'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'BCFC All Stars' AND t.source_system_id = 2
  AND per.first_name = 'Hector Ivan' AND per.last_name = 'Acosta'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'BCFC All Stars' AND t.source_system_id = 2
  AND per.first_name = 'Yousef' AND per.last_name = 'Atrous'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'BCFC All Stars' AND t.source_system_id = 2
  AND per.first_name = 'James' AND per.last_name = 'Barden'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'BCFC All Stars' AND t.source_system_id = 2
  AND per.first_name = 'Oseche' AND per.last_name = 'Buliro'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'BCFC All Stars' AND t.source_system_id = 2
  AND per.first_name = 'John' AND per.last_name = 'Burke'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'BCFC All Stars' AND t.source_system_id = 2
  AND per.first_name = 'Kevin' AND per.last_name = 'Callanan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'BCFC All Stars' AND t.source_system_id = 2
  AND per.first_name = 'Michael' AND per.last_name = 'Chang'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'BCFC All Stars' AND t.source_system_id = 2
  AND per.first_name = 'Andrew' AND per.last_name = 'Cooke'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'BCFC All Stars' AND t.source_system_id = 2
  AND per.first_name = 'Alex' AND per.last_name = 'Cooper-Hohn'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'BCFC All Stars' AND t.source_system_id = 2
  AND per.first_name = 'Leon' AND per.last_name = 'Djusberg'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'BCFC All Stars' AND t.source_system_id = 2
  AND per.first_name = 'Trey' AND per.last_name = 'Donovan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'BCFC All Stars' AND t.source_system_id = 2
  AND per.first_name = 'Irobosa' AND per.last_name = 'Enabulele'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'BCFC All Stars' AND t.source_system_id = 2
  AND per.first_name = 'Jack' AND per.last_name = 'Garrity'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'BCFC All Stars' AND t.source_system_id = 2
  AND per.first_name = 'Kevin' AND per.last_name = 'Gilligan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'BCFC All Stars' AND t.source_system_id = 2
  AND per.first_name = 'Ian' AND per.last_name = 'Goodine'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'BCFC All Stars' AND t.source_system_id = 2
  AND per.first_name = 'Trevor' AND per.last_name = 'Grafton'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'BCFC All Stars' AND t.source_system_id = 2
  AND per.first_name = 'Nicholas' AND per.last_name = 'Harper'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'BCFC All Stars' AND t.source_system_id = 2
  AND per.first_name = 'Josh' AND per.last_name = 'Harper'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'BCFC All Stars' AND t.source_system_id = 2
  AND per.first_name = 'James' AND per.last_name = 'Helf'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'BCFC All Stars' AND t.source_system_id = 2
  AND per.first_name = 'Lewis' AND per.last_name = 'Mustoe'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'BCFC All Stars' AND t.source_system_id = 2
  AND per.first_name = 'Osasenaga' AND per.last_name = 'Owens'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'BCFC All Stars' AND t.source_system_id = 2
  AND per.first_name = 'Nathan' AND per.last_name = 'Plano'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'BCFC All Stars' AND t.source_system_id = 2
  AND per.first_name = 'Jack' AND per.last_name = 'Sarkisian'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'BCFC All Stars' AND t.source_system_id = 2
  AND per.first_name = 'Joaquin' AND per.last_name = 'Silvani'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'BCFC All Stars' AND t.source_system_id = 2
  AND per.first_name = 'Stanislaus' AND per.last_name = 'Sokolov'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'BCFC All Stars' AND t.source_system_id = 2
  AND per.first_name = 'Kohei' AND per.last_name = 'Tomita'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'BCFC All Stars' AND t.source_system_id = 2
  AND per.first_name = 'Tomas' AND per.last_name = 'Trejo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'BCFC All Stars' AND t.source_system_id = 2
  AND per.first_name = 'Caleb' AND per.last_name = 'Weinstock'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Flatley FC' AND t.source_system_id = 2
  AND per.first_name = 'Moycir' AND per.last_name = 'Amarante'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Flatley FC' AND t.source_system_id = 2
  AND per.first_name = 'Ryan' AND per.last_name = 'Beardsley'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Flatley FC' AND t.source_system_id = 2
  AND per.first_name = 'Thomas' AND per.last_name = 'Bell'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Flatley FC' AND t.source_system_id = 2
  AND per.first_name = 'Jaime' AND per.last_name = 'Cortez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Flatley FC' AND t.source_system_id = 2
  AND per.first_name = 'Jah' AND per.last_name = 'Cyrus'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Flatley FC' AND t.source_system_id = 2
  AND per.first_name = 'Raney' AND per.last_name = 'Figueiredo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Flatley FC' AND t.source_system_id = 2
  AND per.first_name = 'Paolo' AND per.last_name = 'Filippi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Flatley FC' AND t.source_system_id = 2
  AND per.first_name = 'Alpha' AND per.last_name = 'Fofanah'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Flatley FC' AND t.source_system_id = 2
  AND per.first_name = 'Patrick' AND per.last_name = 'Freire'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Flatley FC' AND t.source_system_id = 2
  AND per.first_name = 'Matheus' AND per.last_name = 'Gomes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Flatley FC' AND t.source_system_id = 2
  AND per.first_name = 'Ronnie' AND per.last_name = 'Gomez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Flatley FC' AND t.source_system_id = 2
  AND per.first_name = 'Matthew' AND per.last_name = 'Kearney'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Flatley FC' AND t.source_system_id = 2
  AND per.first_name = 'Ousmane' AND per.last_name = 'Keita'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Flatley FC' AND t.source_system_id = 2
  AND per.first_name = 'William' AND per.last_name = 'Martinez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Flatley FC' AND t.source_system_id = 2
  AND per.first_name = 'Ryan' AND per.last_name = 'McGourty'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Flatley FC' AND t.source_system_id = 2
  AND per.first_name = 'Zion' AND per.last_name = 'Monteiro'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Flatley FC' AND t.source_system_id = 2
  AND per.first_name = 'Alejandro' AND per.last_name = 'Monterroso'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Flatley FC' AND t.source_system_id = 2
  AND per.first_name = 'Gracian' AND per.last_name = 'Moreira'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Flatley FC' AND t.source_system_id = 2
  AND per.first_name = 'Carlos' AND per.last_name = 'Neves'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Flatley FC' AND t.source_system_id = 2
  AND per.first_name = 'Lucas' AND per.last_name = 'Oliveira'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Flatley FC' AND t.source_system_id = 2
  AND per.first_name = 'Felipe' AND per.last_name = 'Palacio'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Flatley FC' AND t.source_system_id = 2
  AND per.first_name = 'Markelos' AND per.last_name = 'Papa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Flatley FC' AND t.source_system_id = 2
  AND per.first_name = 'Angelos' AND per.last_name = 'Papa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Flatley FC' AND t.source_system_id = 2
  AND per.first_name = 'Michael' AND per.last_name = 'Rendon'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Flatley FC' AND t.source_system_id = 2
  AND per.first_name = 'Edson' AND per.last_name = 'Robledano'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Flatley FC' AND t.source_system_id = 2
  AND per.first_name = 'gustavo' AND per.last_name = 'sampaio'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Flatley FC' AND t.source_system_id = 2
  AND per.first_name = 'Tjamael' AND per.last_name = 'Sillah'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Flatley FC' AND t.source_system_id = 2
  AND per.first_name = 'William' AND per.last_name = 'Sousa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Flatley FC' AND t.source_system_id = 2
  AND per.first_name = 'Vlad' AND per.last_name = 'Ventura'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Flatley FC' AND t.source_system_id = 2
  AND per.first_name = 'Albert' AND per.last_name = 'Williams'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Gambeta FC' AND t.source_system_id = 2
  AND per.first_name = 'Marouen' AND per.last_name = 'Ben Guebila'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Gambeta FC' AND t.source_system_id = 2
  AND per.first_name = 'Muhammad Uzair' AND per.last_name = 'Butt'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Gambeta FC' AND t.source_system_id = 2
  AND per.first_name = 'Fredy' AND per.last_name = 'Castillo Hernandez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Gambeta FC' AND t.source_system_id = 2
  AND per.first_name = 'Ethan' AND per.last_name = 'Champlin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Gambeta FC' AND t.source_system_id = 2
  AND per.first_name = 'Kevin' AND per.last_name = 'De Leon'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Gambeta FC' AND t.source_system_id = 2
  AND per.first_name = 'Ian' AND per.last_name = 'Dhar'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Gambeta FC' AND t.source_system_id = 2
  AND per.first_name = 'William' AND per.last_name = 'Garcia'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Gambeta FC' AND t.source_system_id = 2
  AND per.first_name = 'Joshua' AND per.last_name = 'Hardester'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Gambeta FC' AND t.source_system_id = 2
  AND per.first_name = 'Norman' AND per.last_name = 'Jimenez Laverde'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Gambeta FC' AND t.source_system_id = 2
  AND per.first_name = 'Andrew' AND per.last_name = 'Lee'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Gambeta FC' AND t.source_system_id = 2
  AND per.first_name = 'Mateus' AND per.last_name = 'Loesch'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Gambeta FC' AND t.source_system_id = 2
  AND per.first_name = 'Austin' AND per.last_name = 'MBaye'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Gambeta FC' AND t.source_system_id = 2
  AND per.first_name = 'Sam' AND per.last_name = 'McGrath'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Gambeta FC' AND t.source_system_id = 2
  AND per.first_name = 'Mike' AND per.last_name = 'Mizhirumbay'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Gambeta FC' AND t.source_system_id = 2
  AND per.first_name = 'Leo' AND per.last_name = 'Mosquera'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Gambeta FC' AND t.source_system_id = 2
  AND per.first_name = 'Matt' AND per.last_name = 'Mourges'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Gambeta FC' AND t.source_system_id = 2
  AND per.first_name = 'Kevin' AND per.last_name = 'Ortiz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Gambeta FC' AND t.source_system_id = 2
  AND per.first_name = 'Jose' AND per.last_name = 'Osorto'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Gambeta FC' AND t.source_system_id = 2
  AND per.first_name = 'Haorui' AND per.last_name = 'Qin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Gambeta FC' AND t.source_system_id = 2
  AND per.first_name = 'Daniel' AND per.last_name = 'Ra'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Gambeta FC' AND t.source_system_id = 2
  AND per.first_name = 'Ethan' AND per.last_name = 'Rowe'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Gambeta FC' AND t.source_system_id = 2
  AND per.first_name = 'Rafael' AND per.last_name = 'Santos'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Gambeta FC' AND t.source_system_id = 2
  AND per.first_name = 'Harrison' AND per.last_name = 'Snodgrass'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Gambeta FC' AND t.source_system_id = 2
  AND per.first_name = 'Marshall' AND per.last_name = 'Tekell'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Gambeta FC' AND t.source_system_id = 2
  AND per.first_name = 'Jose' AND per.last_name = 'Velazquez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Jaguars United FC' AND t.source_system_id = 2
  AND per.first_name = 'Gabriel' AND per.last_name = 'Barbosa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Jaguars United FC' AND t.source_system_id = 2
  AND per.first_name = 'Juliano' AND per.last_name = 'Bento'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Jaguars United FC' AND t.source_system_id = 2
  AND per.first_name = 'Andrés' AND per.last_name = 'Bustamante'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Jaguars United FC' AND t.source_system_id = 2
  AND per.first_name = 'Itamar' AND per.last_name = 'Caldeira'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Jaguars United FC' AND t.source_system_id = 2
  AND per.first_name = 'Vinicius' AND per.last_name = 'De Oliveira'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Jaguars United FC' AND t.source_system_id = 2
  AND per.first_name = 'William' AND per.last_name = 'Dos Santos'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Jaguars United FC' AND t.source_system_id = 2
  AND per.first_name = 'Leonardo' AND per.last_name = 'Fortunato'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Jaguars United FC' AND t.source_system_id = 2
  AND per.first_name = 'Lucas' AND per.last_name = 'Franco'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Jaguars United FC' AND t.source_system_id = 2
  AND per.first_name = 'Javier' AND per.last_name = 'Garcia'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Jaguars United FC' AND t.source_system_id = 2
  AND per.first_name = 'edson' AND per.last_name = 'junior'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Jaguars United FC' AND t.source_system_id = 2
  AND per.first_name = 'Diego' AND per.last_name = 'Lorett'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Jaguars United FC' AND t.source_system_id = 2
  AND per.first_name = 'Vitor' AND per.last_name = 'Magalhaes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Jaguars United FC' AND t.source_system_id = 2
  AND per.first_name = 'Juann' AND per.last_name = 'Melo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Jaguars United FC' AND t.source_system_id = 2
  AND per.first_name = 'Frank' AND per.last_name = 'Messina'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Jaguars United FC' AND t.source_system_id = 2
  AND per.first_name = 'Sidnei' AND per.last_name = 'Monteiro'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Jaguars United FC' AND t.source_system_id = 2
  AND per.first_name = 'Jefferson' AND per.last_name = 'Oliveira'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Jaguars United FC' AND t.source_system_id = 2
  AND per.first_name = 'Lenine' AND per.last_name = 'Pereira'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Jaguars United FC' AND t.source_system_id = 2
  AND per.first_name = 'Wenderson Kenedy' AND per.last_name = 'Pereira'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Jaguars United FC' AND t.source_system_id = 2
  AND per.first_name = 'Gustavo' AND per.last_name = 'Ribeiro'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Jaguars United FC' AND t.source_system_id = 2
  AND per.first_name = 'Marek' AND per.last_name = 'Rutkowki'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Jaguars United FC' AND t.source_system_id = 2
  AND per.first_name = 'Malek' AND per.last_name = 'Sakhri'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Jaguars United FC' AND t.source_system_id = 2
  AND per.first_name = 'Souare' AND per.last_name = 'Saliou'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Jaguars United FC' AND t.source_system_id = 2
  AND per.first_name = 'Silvio' AND per.last_name = 'Silva'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Jaguars United FC' AND t.source_system_id = 2
  AND per.first_name = 'Marcos' AND per.last_name = 'Souto'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Jaguars United FC' AND t.source_system_id = 2
  AND per.first_name = 'Jhordan' AND per.last_name = 'Souza'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Jaguars United FC' AND t.source_system_id = 2
  AND per.first_name = 'Carlos' AND per.last_name = 'Teixeira'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Jaguars United FC' AND t.source_system_id = 2
  AND per.first_name = 'Elton j' AND per.last_name = 'Teixeira'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Jaguars United FC' AND t.source_system_id = 2
  AND per.first_name = 'Willian' AND per.last_name = 'Zanetti'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Shore FC' AND t.source_system_id = 2
  AND per.first_name = 'Elohim' AND per.last_name = 'Alves'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Shore FC' AND t.source_system_id = 2
  AND per.first_name = 'Luis' AND per.last_name = 'Araujo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Shore FC' AND t.source_system_id = 2
  AND per.first_name = 'Wesley' AND per.last_name = 'Borges'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Shore FC' AND t.source_system_id = 2
  AND per.first_name = 'Adriel' AND per.last_name = 'Cordeiro'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Shore FC' AND t.source_system_id = 2
  AND per.first_name = 'Wagner' AND per.last_name = 'Da Silva'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Shore FC' AND t.source_system_id = 2
  AND per.first_name = 'Luan' AND per.last_name = 'De Souza'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Shore FC' AND t.source_system_id = 2
  AND per.first_name = 'Carlos' AND per.last_name = 'De Souza'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Shore FC' AND t.source_system_id = 2
  AND per.first_name = 'Israel' AND per.last_name = 'Duarte'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Shore FC' AND t.source_system_id = 2
  AND per.first_name = 'Gabriel' AND per.last_name = 'Fernandes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Shore FC' AND t.source_system_id = 2
  AND per.first_name = 'Marcelino' AND per.last_name = 'Ferreira'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Shore FC' AND t.source_system_id = 2
  AND per.first_name = 'Walafy' AND per.last_name = 'Leonor'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Shore FC' AND t.source_system_id = 2
  AND per.first_name = 'Felipe' AND per.last_name = 'Lopes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Shore FC' AND t.source_system_id = 2
  AND per.first_name = 'Gustavo' AND per.last_name = 'Lopes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Shore FC' AND t.source_system_id = 2
  AND per.first_name = 'Raimon' AND per.last_name = 'marques'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Shore FC' AND t.source_system_id = 2
  AND per.first_name = 'Rafael' AND per.last_name = 'Medeiros'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Shore FC' AND t.source_system_id = 2
  AND per.first_name = 'Leandro' AND per.last_name = 'Pereira Ramos.'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Shore FC' AND t.source_system_id = 2
  AND per.first_name = 'Leandro' AND per.last_name = 'Pires'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Shore FC' AND t.source_system_id = 2
  AND per.first_name = 'Douglas' AND per.last_name = 'Pires'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Shore FC' AND t.source_system_id = 2
  AND per.first_name = 'Leandro' AND per.last_name = 'Ramos'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Shore FC' AND t.source_system_id = 2
  AND per.first_name = 'Caique' AND per.last_name = 'Reginaldo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Shore FC' AND t.source_system_id = 2
  AND per.first_name = 'Eduardo' AND per.last_name = 'Reis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Shore FC' AND t.source_system_id = 2
  AND per.first_name = 'Maxsuel' AND per.last_name = 'Ribeiro'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Shore FC' AND t.source_system_id = 2
  AND per.first_name = 'Luis' AND per.last_name = 'Santos'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Shore FC' AND t.source_system_id = 2
  AND per.first_name = 'Vanilson' AND per.last_name = 'Santos'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Shore FC' AND t.source_system_id = 2
  AND per.first_name = 'Deyvit' AND per.last_name = 'Silva'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Shore FC' AND t.source_system_id = 2
  AND per.first_name = 'Wenderson' AND per.last_name = 'Silva'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Shore FC' AND t.source_system_id = 2
  AND per.first_name = 'Pedro' AND per.last_name = 'Silva'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Strictly Nos Fc' AND t.source_system_id = 2
  AND per.first_name = 'Eder' AND per.last_name = 'Amado'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Strictly Nos Fc' AND t.source_system_id = 2
  AND per.first_name = 'Helton' AND per.last_name = 'Brandao'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Strictly Nos Fc' AND t.source_system_id = 2
  AND per.first_name = 'Yuri' AND per.last_name = 'Brandao'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Strictly Nos Fc' AND t.source_system_id = 2
  AND per.first_name = 'Derik' AND per.last_name = 'Brito'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Strictly Nos Fc' AND t.source_system_id = 2
  AND per.first_name = 'Erick' AND per.last_name = 'Brito'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Strictly Nos Fc' AND t.source_system_id = 2
  AND per.first_name = 'Belvick' AND per.last_name = 'da Silva'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Strictly Nos Fc' AND t.source_system_id = 2
  AND per.first_name = 'Brandon' AND per.last_name = 'Daluz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Strictly Nos Fc' AND t.source_system_id = 2
  AND per.first_name = 'Jaylon' AND per.last_name = 'Darosa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Strictly Nos Fc' AND t.source_system_id = 2
  AND per.first_name = 'Janilson' AND per.last_name = 'Debrito'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Strictly Nos Fc' AND t.source_system_id = 2
  AND per.first_name = 'Jayden' AND per.last_name = 'Depina'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Strictly Nos Fc' AND t.source_system_id = 2
  AND per.first_name = 'Lucas' AND per.last_name = 'Fernandes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Strictly Nos Fc' AND t.source_system_id = 2
  AND per.first_name = 'Luis' AND per.last_name = 'Fortes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Strictly Nos Fc' AND t.source_system_id = 2
  AND per.first_name = 'Ty' AND per.last_name = 'Gomes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Strictly Nos Fc' AND t.source_system_id = 2
  AND per.first_name = 'Jorge' AND per.last_name = 'Goncalves'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Strictly Nos Fc' AND t.source_system_id = 2
  AND per.first_name = 'Ricardo' AND per.last_name = 'Monteiro'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Strictly Nos Fc' AND t.source_system_id = 2
  AND per.first_name = 'Carlos' AND per.last_name = 'Morais'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Strictly Nos Fc' AND t.source_system_id = 2
  AND per.first_name = 'Gracian' AND per.last_name = 'Moreira'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Strictly Nos Fc' AND t.source_system_id = 2
  AND per.first_name = 'Dany' AND per.last_name = 'Pina'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Strictly Nos Fc' AND t.source_system_id = 2
  AND per.first_name = 'Johnathan' AND per.last_name = 'Pires'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Strictly Nos Fc' AND t.source_system_id = 2
  AND per.first_name = 'Danny' AND per.last_name = 'Resende'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Strictly Nos Fc' AND t.source_system_id = 2
  AND per.first_name = 'Anthony' AND per.last_name = 'Rodrigues'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Strictly Nos Fc' AND t.source_system_id = 2
  AND per.first_name = 'Jonathan' AND per.last_name = 'Rodrigues'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Strictly Nos Fc' AND t.source_system_id = 2
  AND per.first_name = 'Jeremias' AND per.last_name = 'Rosa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Strictly Nos Fc' AND t.source_system_id = 2
  AND per.first_name = 'Kevin' AND per.last_name = 'Soares'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Strictly Nos Fc' AND t.source_system_id = 2
  AND per.first_name = 'Junior' AND per.last_name = 'Tavares'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Strictly Nos Fc' AND t.source_system_id = 2
  AND per.first_name = 'Edmilson' AND per.last_name = 'Vaz Tavares'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Strictly Nos Fc' AND t.source_system_id = 2
  AND per.first_name = 'Vanilton' AND per.last_name = 'Xavier'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club Reserves' AND t.source_system_id = 2
  AND per.first_name = 'Mohammed' AND per.last_name = 'Abdulrahman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club Reserves' AND t.source_system_id = 2
  AND per.first_name = 'Omar' AND per.last_name = 'Ahmed'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club Reserves' AND t.source_system_id = 2
  AND per.first_name = 'Zain' AND per.last_name = 'AL-Ashoor'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club Reserves' AND t.source_system_id = 2
  AND per.first_name = 'Elhadj' AND per.last_name = 'Bah'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club Reserves' AND t.source_system_id = 2
  AND per.first_name = 'Ethan' AND per.last_name = 'Buss'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club Reserves' AND t.source_system_id = 2
  AND per.first_name = 'Shamanuel' AND per.last_name = 'Dominique'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club Reserves' AND t.source_system_id = 2
  AND per.first_name = 'Filip' AND per.last_name = 'Dordevic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club Reserves' AND t.source_system_id = 2
  AND per.first_name = 'Habib' AND per.last_name = 'Emami'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club Reserves' AND t.source_system_id = 2
  AND per.first_name = 'Yeremosi' AND per.last_name = 'Foste'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club Reserves' AND t.source_system_id = 2
  AND per.first_name = 'Terah' AND per.last_name = 'Garnett'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club Reserves' AND t.source_system_id = 2
  AND per.first_name = 'Ermias' AND per.last_name = 'Getnet'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club Reserves' AND t.source_system_id = 2
  AND per.first_name = 'Jesse' AND per.last_name = 'Gutierrez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club Reserves' AND t.source_system_id = 2
  AND per.first_name = 'Mohammed' AND per.last_name = 'Hassan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club Reserves' AND t.source_system_id = 2
  AND per.first_name = 'Miguel' AND per.last_name = 'Ikomo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club Reserves' AND t.source_system_id = 2
  AND per.first_name = 'Stylianos' AND per.last_name = 'Ioannou'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club Reserves' AND t.source_system_id = 2
  AND per.first_name = 'Samuel' AND per.last_name = 'Kihorezo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club Reserves' AND t.source_system_id = 2
  AND per.first_name = 'Joshua' AND per.last_name = 'Logan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club Reserves' AND t.source_system_id = 2
  AND per.first_name = 'Abdoul' AND per.last_name = 'Mamaoudou'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club Reserves' AND t.source_system_id = 2
  AND per.first_name = 'John' AND per.last_name = 'Moore'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club Reserves' AND t.source_system_id = 2
  AND per.first_name = 'Moussa' AND per.last_name = 'Oumarou'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club Reserves' AND t.source_system_id = 2
  AND per.first_name = 'Edicson' AND per.last_name = 'Sabogal'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club Reserves' AND t.source_system_id = 2
  AND per.first_name = 'Fernando' AND per.last_name = 'Salazar'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club Reserves' AND t.source_system_id = 2
  AND per.first_name = 'Gerrit' AND per.last_name = 'Stech'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club Reserves' AND t.source_system_id = 2
  AND per.first_name = 'Shengda' AND per.last_name = 'Sun Lopez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club Reserves' AND t.source_system_id = 2
  AND per.first_name = 'Daniel' AND per.last_name = 'Tema'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club Reserves' AND t.source_system_id = 2
  AND per.first_name = 'Makan' AND per.last_name = 'Traore'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club Reserves' AND t.source_system_id = 2
  AND per.first_name = 'Robby' AND per.last_name = 'Waller'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club Reserves' AND t.source_system_id = 2
  AND per.first_name = 'Jereme' AND per.last_name = 'Wells'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club Reserves' AND t.source_system_id = 2
  AND per.first_name = 'Shenoda' AND per.last_name = 'Youssef'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club Reserves' AND t.source_system_id = 2
  AND per.first_name = 'Robby' AND per.last_name = 'Waller'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'F&M FC' AND t.source_system_id = 2
  AND per.first_name = 'Harein' AND per.last_name = 'Abeysekera'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'F&M FC' AND t.source_system_id = 2
  AND per.first_name = 'Sebastian' AND per.last_name = 'Carrilo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'F&M FC' AND t.source_system_id = 2
  AND per.first_name = 'Drake' AND per.last_name = 'DeJute'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'F&M FC' AND t.source_system_id = 2
  AND per.first_name = 'Kabeer' AND per.last_name = 'Ferhan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'F&M FC' AND t.source_system_id = 2
  AND per.first_name = 'Jackson' AND per.last_name = 'Hellmann'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'F&M FC' AND t.source_system_id = 2
  AND per.first_name = 'Marc' AND per.last_name = 'Iglesias'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'F&M FC' AND t.source_system_id = 2
  AND per.first_name = 'Yussif Attabio' AND per.last_name = 'Ismail'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'F&M FC' AND t.source_system_id = 2
  AND per.first_name = 'An' AND per.last_name = 'Jaeyun'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'F&M FC' AND t.source_system_id = 2
  AND per.first_name = 'Parth' AND per.last_name = 'Karki'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'F&M FC' AND t.source_system_id = 2
  AND per.first_name = 'Sergio' AND per.last_name = 'Marin Miralles'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'F&M FC' AND t.source_system_id = 2
  AND per.first_name = 'Calix' AND per.last_name = 'Milligan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'F&M FC' AND t.source_system_id = 2
  AND per.first_name = 'Adeon' AND per.last_name = 'Muyskens'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'F&M FC' AND t.source_system_id = 2
  AND per.first_name = 'Faisal' AND per.last_name = 'Niazi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'F&M FC' AND t.source_system_id = 2
  AND per.first_name = 'Vincent' AND per.last_name = 'Okyere'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'F&M FC' AND t.source_system_id = 2
  AND per.first_name = 'Devin' AND per.last_name = 'Putnam'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'F&M FC' AND t.source_system_id = 2
  AND per.first_name = 'Bernard' AND per.last_name = 'Sakyi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'F&M FC' AND t.source_system_id = 2
  AND per.first_name = 'Jordan' AND per.last_name = 'Samuels'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'F&M FC' AND t.source_system_id = 2
  AND per.first_name = 'Sanzhar' AND per.last_name = 'Sarynzhiev'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'F&M FC' AND t.source_system_id = 2
  AND per.first_name = 'Sam' AND per.last_name = 'Scherzer'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'F&M FC' AND t.source_system_id = 2
  AND per.first_name = 'Gabriel Antonio' AND per.last_name = 'Silva Gomes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'F&M FC' AND t.source_system_id = 2
  AND per.first_name = 'Benjamin' AND per.last_name = 'Winograd'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'F&M FC' AND t.source_system_id = 2
  AND per.first_name = 'Muhyadin' AND per.last_name = 'Yusuf'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'F&M FC' AND t.source_system_id = 2
  AND per.first_name = 'Alex' AND per.last_name = 'Jacobs'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'F&M FC' AND t.source_system_id = 2
  AND per.first_name = 'Christopher' AND per.last_name = 'Wann'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Keystone Elite' AND t.source_system_id = 2
  AND per.first_name = 'Mohammed' AND per.last_name = 'Al Qudsi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Keystone Elite' AND t.source_system_id = 2
  AND per.first_name = 'Gurnoor' AND per.last_name = 'Bagri'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Keystone Elite' AND t.source_system_id = 2
  AND per.first_name = 'Quinn' AND per.last_name = 'Bertoncini-Troutman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Keystone Elite' AND t.source_system_id = 2
  AND per.first_name = 'Braedon' AND per.last_name = 'Bickford'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Keystone Elite' AND t.source_system_id = 2
  AND per.first_name = 'Albert' AND per.last_name = 'Corea'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Keystone Elite' AND t.source_system_id = 2
  AND per.first_name = 'Dylan' AND per.last_name = 'Crills'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Keystone Elite' AND t.source_system_id = 2
  AND per.first_name = 'Amini' AND per.last_name = 'Diye'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Keystone Elite' AND t.source_system_id = 2
  AND per.first_name = 'Vincent' AND per.last_name = 'Edmond'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Keystone Elite' AND t.source_system_id = 2
  AND per.first_name = 'Chri' AND per.last_name = 'Ehgay'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Keystone Elite' AND t.source_system_id = 2
  AND per.first_name = 'Ian' AND per.last_name = 'Frisbie'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Keystone Elite' AND t.source_system_id = 2
  AND per.first_name = 'Mason' AND per.last_name = 'Harris'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Keystone Elite' AND t.source_system_id = 2
  AND per.first_name = 'Bita' AND per.last_name = 'Imani'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Keystone Elite' AND t.source_system_id = 2
  AND per.first_name = 'Michael' AND per.last_name = 'Kasampilo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Keystone Elite' AND t.source_system_id = 2
  AND per.first_name = 'Asende' AND per.last_name = 'Lubende'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Keystone Elite' AND t.source_system_id = 2
  AND per.first_name = 'Faustin' AND per.last_name = 'Mucunguzi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Keystone Elite' AND t.source_system_id = 2
  AND per.first_name = 'Jack' AND per.last_name = 'Ngoy'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Keystone Elite' AND t.source_system_id = 2
  AND per.first_name = 'Ibrahim' AND per.last_name = 'Ntege'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Keystone Elite' AND t.source_system_id = 2
  AND per.first_name = 'Brandon' AND per.last_name = 'Perez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Keystone Elite' AND t.source_system_id = 2
  AND per.first_name = 'Lata' AND per.last_name = 'Petros'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Keystone Elite' AND t.source_system_id = 2
  AND per.first_name = 'Gavin' AND per.last_name = 'Roberts'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Keystone Elite' AND t.source_system_id = 2
  AND per.first_name = 'Ben' AND per.last_name = 'Singizwa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Keystone Elite' AND t.source_system_id = 2
  AND per.first_name = 'Babo' AND per.last_name = 'Tereffe'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Keystone Elite' AND t.source_system_id = 2
  AND per.first_name = 'Gavin' AND per.last_name = 'Wiley'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kutztown Men''s Soccer' AND t.source_system_id = 2
  AND per.first_name = 'Antonio' AND per.last_name = 'Alonso-Hernandez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kutztown Men''s Soccer' AND t.source_system_id = 2
  AND per.first_name = 'Daniel' AND per.last_name = 'Arraiz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kutztown Men''s Soccer' AND t.source_system_id = 2
  AND per.first_name = 'Daviont' AND per.last_name = 'Baker-Alston'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kutztown Men''s Soccer' AND t.source_system_id = 2
  AND per.first_name = 'Lucas' AND per.last_name = 'Cherniak'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kutztown Men''s Soccer' AND t.source_system_id = 2
  AND per.first_name = 'Andrew' AND per.last_name = 'Cui'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kutztown Men''s Soccer' AND t.source_system_id = 2
  AND per.first_name = 'Blake' AND per.last_name = 'Deluca'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kutztown Men''s Soccer' AND t.source_system_id = 2
  AND per.first_name = 'Matthew' AND per.last_name = 'DiCarlo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kutztown Men''s Soccer' AND t.source_system_id = 2
  AND per.first_name = 'Sleem' AND per.last_name = 'Emam'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kutztown Men''s Soccer' AND t.source_system_id = 2
  AND per.first_name = 'Rhenan' AND per.last_name = 'Ferreira'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kutztown Men''s Soccer' AND t.source_system_id = 2
  AND per.first_name = 'Aiden' AND per.last_name = 'Fogarty'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kutztown Men''s Soccer' AND t.source_system_id = 2
  AND per.first_name = 'Leonardo' AND per.last_name = 'Guzman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kutztown Men''s Soccer' AND t.source_system_id = 2
  AND per.first_name = 'Luke' AND per.last_name = 'Jones'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kutztown Men''s Soccer' AND t.source_system_id = 2
  AND per.first_name = 'Samuel' AND per.last_name = 'Kaganzev'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kutztown Men''s Soccer' AND t.source_system_id = 2
  AND per.first_name = 'William' AND per.last_name = 'Maurek'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kutztown Men''s Soccer' AND t.source_system_id = 2
  AND per.first_name = 'Jared' AND per.last_name = 'Mikloski'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kutztown Men''s Soccer' AND t.source_system_id = 2
  AND per.first_name = 'Logan' AND per.last_name = 'Rogers'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kutztown Men''s Soccer' AND t.source_system_id = 2
  AND per.first_name = 'Ethan' AND per.last_name = 'Schrampf'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kutztown Men''s Soccer' AND t.source_system_id = 2
  AND per.first_name = 'Alex' AND per.last_name = 'Schrampf'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kutztown Men''s Soccer' AND t.source_system_id = 2
  AND per.first_name = 'Caden' AND per.last_name = 'Thompson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kutztown Men''s Soccer' AND t.source_system_id = 2
  AND per.first_name = 'David' AND per.last_name = 'Turchi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kutztown Men''s Soccer' AND t.source_system_id = 2
  AND per.first_name = 'Johnny' AND per.last_name = 'Turchi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kutztown Men''s Soccer' AND t.source_system_id = 2
  AND per.first_name = 'Jacob' AND per.last_name = 'Warner'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kutztown Men''s Soccer' AND t.source_system_id = 2
  AND per.first_name = 'Koye' AND per.last_name = 'Whitman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Kutztown Men''s Soccer' AND t.source_system_id = 2
  AND per.first_name = 'Tim' AND per.last_name = 'Zellner'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lancaster City FC' AND t.source_system_id = 2
  AND per.first_name = 'Erick' AND per.last_name = 'Bernal'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, '25', NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lancaster City FC' AND t.source_system_id = 2
  AND per.first_name = 'Jordan' AND per.last_name = 'Brubaker'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, '26', NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lancaster City FC' AND t.source_system_id = 2
  AND per.first_name = 'Ian' AND per.last_name = 'Byrnes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, '12', NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lancaster City FC' AND t.source_system_id = 2
  AND per.first_name = 'Julian' AND per.last_name = 'Carvajal'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, '5', NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lancaster City FC' AND t.source_system_id = 2
  AND per.first_name = 'Joel' AND per.last_name = 'Chachapoya'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lancaster City FC' AND t.source_system_id = 2
  AND per.first_name = 'Andrea' AND per.last_name = 'DiSomma'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, '22', NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lancaster City FC' AND t.source_system_id = 2
  AND per.first_name = 'Tyler' AND per.last_name = 'Hambright'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, '10', NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lancaster City FC' AND t.source_system_id = 2
  AND per.first_name = 'Jessie' AND per.last_name = 'Herb'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lancaster City FC' AND t.source_system_id = 2
  AND per.first_name = 'Shaquille' AND per.last_name = 'Hudson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lancaster City FC' AND t.source_system_id = 2
  AND per.first_name = 'Asher' AND per.last_name = 'Klahold'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lancaster City FC' AND t.source_system_id = 2
  AND per.first_name = 'Jordan' AND per.last_name = 'McMullen'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lancaster City FC' AND t.source_system_id = 2
  AND per.first_name = 'Alex' AND per.last_name = 'Morales'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lancaster City FC' AND t.source_system_id = 2
  AND per.first_name = 'Garmonger' AND per.last_name = 'Morris'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lancaster City FC' AND t.source_system_id = 2
  AND per.first_name = 'Caden' AND per.last_name = 'Mullen'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, '4', NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lancaster City FC' AND t.source_system_id = 2
  AND per.first_name = 'Zach' AND per.last_name = 'Oster'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lancaster City FC' AND t.source_system_id = 2
  AND per.first_name = 'Nikita' AND per.last_name = 'Patrushev'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, '9', NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lancaster City FC' AND t.source_system_id = 2
  AND per.first_name = 'Joshua' AND per.last_name = 'Patrushey'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, '7', NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lancaster City FC' AND t.source_system_id = 2
  AND per.first_name = 'Andrey' AND per.last_name = 'Patrushey'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, '18', NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lancaster City FC' AND t.source_system_id = 2
  AND per.first_name = 'Aaron' AND per.last_name = 'Pearson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lancaster City FC' AND t.source_system_id = 2
  AND per.first_name = 'Josiah' AND per.last_name = 'Schendel'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lancaster City FC' AND t.source_system_id = 2
  AND per.first_name = 'Chris' AND per.last_name = 'Sosa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lancaster City FC' AND t.source_system_id = 2
  AND per.first_name = 'Daniel' AND per.last_name = 'Sosa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lancaster City FC' AND t.source_system_id = 2
  AND per.first_name = 'Ashton' AND per.last_name = 'Taughinbaugh'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, '8', NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lancaster City FC' AND t.source_system_id = 2
  AND per.first_name = 'Michael' AND per.last_name = 'Tolley'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lancaster City FC' AND t.source_system_id = 2
  AND per.first_name = 'Andrew' AND per.last_name = 'Weaver'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, '3', NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lancaster City FC' AND t.source_system_id = 2
  AND per.first_name = 'Tye' AND per.last_name = 'White'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

