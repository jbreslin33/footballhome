-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Rosters - APSL
-- Player-team relationships from team roster pages
-- Total Records: 1573
-- 
-- Architecture: Players looked up by name (no hardcoded IDs)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Matteo' AND per.last_name = 'Adiletta'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'William' AND per.last_name = 'Ardiles'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Serge' AND per.last_name = 'Biket'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Ryan' AND per.last_name = 'Butler'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Obiazie' AND per.last_name = 'Chinatu'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Seth' AND per.last_name = 'Crabbe'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Leo' AND per.last_name = 'Dunia'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Ivan' AND per.last_name = 'Fombu'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Nikolaos' AND per.last_name = 'Gousios'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Isaac' AND per.last_name = 'Hollinger'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Micah' AND per.last_name = 'Hostetter'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Abdoul' AND per.last_name = 'Issoufou'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Clovis' AND per.last_name = 'Kabre'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Justin' AND per.last_name = 'Keefer'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Mehluko' AND per.last_name = 'Letsoalo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Kel' AND per.last_name = 'Merckel'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Caden' AND per.last_name = 'Mullen'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Babunga' AND per.last_name = 'Mulumeoderwa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Luke' AND per.last_name = 'Nall'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Sivpheng' AND per.last_name = 'Phann'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Derek' AND per.last_name = 'Ramirez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Ethan' AND per.last_name = 'Ramirez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Josiah' AND per.last_name = 'Ramirez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Chris' AND per.last_name = 'Richards'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Daniel' AND per.last_name = 'Rowe'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Lazaro' AND per.last_name = 'Salazar'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'David' AND per.last_name = 'Tai San'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Dawson' AND per.last_name = 'Schreck'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Owen' AND per.last_name = 'Shea'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Denis' AND per.last_name = 'Tarasov'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Babo' AND per.last_name = 'Tereffe'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'William' AND per.last_name = 'Vasquez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Joel' AND per.last_name = 'Walker'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Christian' AND per.last_name = 'Wieand'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alloy Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Kedric' AND per.last_name = 'Yoder'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers FC' AND t.source_system_id = 1
  AND per.first_name = 'Abdul' AND per.last_name = 'Karim Bah'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers FC' AND t.source_system_id = 1
  AND per.first_name = 'Ibrahima' AND per.last_name = 'Bah'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers FC' AND t.source_system_id = 1
  AND per.first_name = 'Matthew' AND per.last_name = 'Baringer'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers FC' AND t.source_system_id = 1
  AND per.first_name = 'Cesar' AND per.last_name = 'Buitrago'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers FC' AND t.source_system_id = 1
  AND per.first_name = 'Saul' AND per.last_name = 'Cardozo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers FC' AND t.source_system_id = 1
  AND per.first_name = 'Elhadj' AND per.last_name = 'Diallo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers FC' AND t.source_system_id = 1
  AND per.first_name = 'Youssouf' AND per.last_name = 'Diallo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers FC' AND t.source_system_id = 1
  AND per.first_name = 'Ighoghoe' AND per.last_name = 'Erediauwa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers FC' AND t.source_system_id = 1
  AND per.first_name = 'Vincent' AND per.last_name = 'Galia'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers FC' AND t.source_system_id = 1
  AND per.first_name = 'Luis' AND per.last_name = 'Granados'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers FC' AND t.source_system_id = 1
  AND per.first_name = 'Radouane' AND per.last_name = 'Guissi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers FC' AND t.source_system_id = 1
  AND per.first_name = 'Joseph' AND per.last_name = 'Kalilwa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers FC' AND t.source_system_id = 1
  AND per.first_name = 'Nicholas' AND per.last_name = 'King'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers FC' AND t.source_system_id = 1
  AND per.first_name = 'Jonathan' AND per.last_name = 'Lima'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers FC' AND t.source_system_id = 1
  AND per.first_name = 'Anyolo' AND per.last_name = 'Makatiani'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers FC' AND t.source_system_id = 1
  AND per.first_name = 'Matthew' AND per.last_name = 'McDonnell'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers FC' AND t.source_system_id = 1
  AND per.first_name = 'Mohamad' AND per.last_name = 'Miri'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers FC' AND t.source_system_id = 1
  AND per.first_name = 'Eoghan' AND per.last_name = 'Morgan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers FC' AND t.source_system_id = 1
  AND per.first_name = 'Ezekiel' AND per.last_name = 'Omosanya'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers FC' AND t.source_system_id = 1
  AND per.first_name = 'Maynor' AND per.last_name = 'Palacios'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers FC' AND t.source_system_id = 1
  AND per.first_name = 'Justin' AND per.last_name = 'Peters'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers FC' AND t.source_system_id = 1
  AND per.first_name = 'Alec' AND per.last_name = 'Pineda'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers FC' AND t.source_system_id = 1
  AND per.first_name = 'Alejandro' AND per.last_name = 'Sanchez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers FC' AND t.source_system_id = 1
  AND per.first_name = 'Jaidon' AND per.last_name = 'Selden'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers FC' AND t.source_system_id = 1
  AND per.first_name = 'James' AND per.last_name = 'Terpak'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers FC' AND t.source_system_id = 1
  AND per.first_name = 'Dominic' AND per.last_name = 'Tomety'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers FC' AND t.source_system_id = 1
  AND per.first_name = 'Samuel' AND per.last_name = 'Urban'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers FC' AND t.source_system_id = 1
  AND per.first_name = 'Christopher' AND per.last_name = 'Valentine'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers FC' AND t.source_system_id = 1
  AND per.first_name = 'Marcial' AND per.last_name = 'Viveros'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Central Park Rangers FC' AND t.source_system_id = 1
  AND per.first_name = 'Timothy' AND per.last_name = 'Williams'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Christos FC' AND t.source_system_id = 1
  AND per.first_name = 'Felix' AND per.last_name = 'Amankwah'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Christos FC' AND t.source_system_id = 1
  AND per.first_name = 'Daniel' AND per.last_name = 'Baxter'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Christos FC' AND t.source_system_id = 1
  AND per.first_name = 'Drew' AND per.last_name = 'Belcher'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Christos FC' AND t.source_system_id = 1
  AND per.first_name = 'Elijah' AND per.last_name = 'Belcher'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Christos FC' AND t.source_system_id = 1
  AND per.first_name = 'Ethan' AND per.last_name = 'Belcher'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Christos FC' AND t.source_system_id = 1
  AND per.first_name = 'Jacob' AND per.last_name = 'Bender'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Christos FC' AND t.source_system_id = 1
  AND per.first_name = 'Jalen' AND per.last_name = 'Boston'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Christos FC' AND t.source_system_id = 1
  AND per.first_name = 'Brandon' AND per.last_name = 'Burkholder'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Christos FC' AND t.source_system_id = 1
  AND per.first_name = 'Nero' AND per.last_name = 'Cooper'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Christos FC' AND t.source_system_id = 1
  AND per.first_name = 'Anthony' AND per.last_name = 'Dragisics'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Christos FC' AND t.source_system_id = 1
  AND per.first_name = 'Alejandro' AND per.last_name = 'Estrada'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Christos FC' AND t.source_system_id = 1
  AND per.first_name = 'Justin' AND per.last_name = 'Gielen'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Christos FC' AND t.source_system_id = 1
  AND per.first_name = 'Brian' AND per.last_name = 'Graham'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Christos FC' AND t.source_system_id = 1
  AND per.first_name = 'Brett' AND per.last_name = 'Joyner'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Christos FC' AND t.source_system_id = 1
  AND per.first_name = 'Tanner' AND per.last_name = 'Kennard'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Christos FC' AND t.source_system_id = 1
  AND per.first_name = 'Tyler' AND per.last_name = 'Lee'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Christos FC' AND t.source_system_id = 1
  AND per.first_name = 'Stiven' AND per.last_name = 'Llano'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Christos FC' AND t.source_system_id = 1
  AND per.first_name = 'Morgan' AND per.last_name = 'Lussi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Christos FC' AND t.source_system_id = 1
  AND per.first_name = 'Raffaele' AND per.last_name = 'Mazzone'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Christos FC' AND t.source_system_id = 1
  AND per.first_name = 'Daniel' AND per.last_name = 'McCleary'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Christos FC' AND t.source_system_id = 1
  AND per.first_name = 'Edixon' AND per.last_name = 'Moreira'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Christos FC' AND t.source_system_id = 1
  AND per.first_name = 'David' AND per.last_name = 'Ogbonna'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Christos FC' AND t.source_system_id = 1
  AND per.first_name = 'Garrett' AND per.last_name = 'Peters'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Christos FC' AND t.source_system_id = 1
  AND per.first_name = 'Juston' AND per.last_name = 'Rainey'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Christos FC' AND t.source_system_id = 1
  AND per.first_name = 'Cesar' AND per.last_name = 'Ramos'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Christos FC' AND t.source_system_id = 1
  AND per.first_name = 'Aaron' AND per.last_name = 'Rilling'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Christos FC' AND t.source_system_id = 1
  AND per.first_name = 'Jackson' AND per.last_name = 'Ruckman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Christos FC' AND t.source_system_id = 1
  AND per.first_name = 'Kyle' AND per.last_name = 'Saunderson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Christos FC' AND t.source_system_id = 1
  AND per.first_name = 'Luis' AND per.last_name = 'Soria'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Christos FC' AND t.source_system_id = 1
  AND per.first_name = 'Brett' AND per.last_name = 'St Martin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Christos FC' AND t.source_system_id = 1
  AND per.first_name = 'Alexander' AND per.last_name = 'Wardle'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa FCW' AND t.source_system_id = 1
  AND per.first_name = 'Adrian' AND per.last_name = 'Aguilera'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa FCW' AND t.source_system_id = 1
  AND per.first_name = 'Julian' AND per.last_name = 'Anderson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa FCW' AND t.source_system_id = 1
  AND per.first_name = 'Balint' AND per.last_name = 'Barabas'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa FCW' AND t.source_system_id = 1
  AND per.first_name = 'Vasilios' AND per.last_name = 'Brisnovalis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa FCW' AND t.source_system_id = 1
  AND per.first_name = 'Robert' AND per.last_name = 'Cabrera'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa FCW' AND t.source_system_id = 1
  AND per.first_name = 'Murat' AND per.last_name = 'Edgar Calkap'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa FCW' AND t.source_system_id = 1
  AND per.first_name = 'Daniel' AND per.last_name = 'Curmi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa FCW' AND t.source_system_id = 1
  AND per.first_name = 'Duga' AND per.last_name = 'Dambelly'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa FCW' AND t.source_system_id = 1
  AND per.first_name = 'Khaled' AND per.last_name = 'Daoud'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa FCW' AND t.source_system_id = 1
  AND per.first_name = 'Mohamed' AND per.last_name = 'Diaw'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa FCW' AND t.source_system_id = 1
  AND per.first_name = 'Julio' AND per.last_name = 'Espinal'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa FCW' AND t.source_system_id = 1
  AND per.first_name = 'Jeison' AND per.last_name = 'Gonzalez Sanchez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa FCW' AND t.source_system_id = 1
  AND per.first_name = 'James' AND per.last_name = 'Greco'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa FCW' AND t.source_system_id = 1
  AND per.first_name = 'Grady' AND per.last_name = 'Kozak'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa FCW' AND t.source_system_id = 1
  AND per.first_name = 'Antonio' AND per.last_name = 'Linge'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa FCW' AND t.source_system_id = 1
  AND per.first_name = 'Tyrone' AND per.last_name = 'Malango'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa FCW' AND t.source_system_id = 1
  AND per.first_name = 'William' AND per.last_name = 'Marment'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa FCW' AND t.source_system_id = 1
  AND per.first_name = 'Augustus' AND per.last_name = 'Manuel Mcgiff'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa FCW' AND t.source_system_id = 1
  AND per.first_name = 'Christopher' AND per.last_name = 'Morandi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa FCW' AND t.source_system_id = 1
  AND per.first_name = 'Richard' AND per.last_name = 'Morel'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa FCW' AND t.source_system_id = 1
  AND per.first_name = 'Peter' AND per.last_name = 'Myrianthopoulos'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa FCW' AND t.source_system_id = 1
  AND per.first_name = 'Stefen' AND per.last_name = 'Nikolic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa FCW' AND t.source_system_id = 1
  AND per.first_name = 'Martin' AND per.last_name = 'Nikprelaj'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa FCW' AND t.source_system_id = 1
  AND per.first_name = 'Sergio' AND per.last_name = 'Peralta'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa FCW' AND t.source_system_id = 1
  AND per.first_name = 'Marco' AND per.last_name = 'Primavera'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa FCW' AND t.source_system_id = 1
  AND per.first_name = 'Paolo' AND per.last_name = 'Cerruto Primavera'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa FCW' AND t.source_system_id = 1
  AND per.first_name = 'Chris' AND per.last_name = 'Riordan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa FCW' AND t.source_system_id = 1
  AND per.first_name = 'David' AND per.last_name = 'Rodriguez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa FCW' AND t.source_system_id = 1
  AND per.first_name = 'Ronaldo' AND per.last_name = 'Rodriguez Jurado'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa FCW' AND t.source_system_id = 1
  AND per.first_name = 'Fredy' AND per.last_name = 'Rosales'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa FCW' AND t.source_system_id = 1
  AND per.first_name = 'Duvan' AND per.last_name = 'Sanchez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa FCW' AND t.source_system_id = 1
  AND per.first_name = 'Giuliano' AND per.last_name = 'Santucci'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa FCW' AND t.source_system_id = 1
  AND per.first_name = 'Navruz' AND per.last_name = 'Shukroev'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa FCW' AND t.source_system_id = 1
  AND per.first_name = 'Milorad' AND per.last_name = 'Sobot'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Doxa FCW' AND t.source_system_id = 1
  AND per.first_name = 'Michalis' AND per.last_name = 'Stylianou'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falcons FC' AND t.source_system_id = 1
  AND per.first_name = 'Sahil' AND per.last_name = 'Banerjee'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falcons FC' AND t.source_system_id = 1
  AND per.first_name = 'Massimiliano' AND per.last_name = 'Bruno'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falcons FC' AND t.source_system_id = 1
  AND per.first_name = 'Kevin' AND per.last_name = 'Alves Cruz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falcons FC' AND t.source_system_id = 1
  AND per.first_name = 'Ryan' AND per.last_name = 'Cura'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falcons FC' AND t.source_system_id = 1
  AND per.first_name = 'Emilano' AND per.last_name = 'De La Macorra Cardoso'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falcons FC' AND t.source_system_id = 1
  AND per.first_name = 'Jeffery' AND per.last_name = 'Dietrich'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falcons FC' AND t.source_system_id = 1
  AND per.first_name = 'Claudio' AND per.last_name = 'Dragonetti'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falcons FC' AND t.source_system_id = 1
  AND per.first_name = 'Miguel' AND per.last_name = 'Enriquez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falcons FC' AND t.source_system_id = 1
  AND per.first_name = 'Charles' AND per.last_name = 'Esber Tavares'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falcons FC' AND t.source_system_id = 1
  AND per.first_name = 'Kaven' AND per.last_name = 'Fitch'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falcons FC' AND t.source_system_id = 1
  AND per.first_name = 'Vincenzo' AND per.last_name = 'Fuentes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falcons FC' AND t.source_system_id = 1
  AND per.first_name = 'Payson' AND per.last_name = 'Goyette'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falcons FC' AND t.source_system_id = 1
  AND per.first_name = 'Pano' AND per.last_name = 'Haseotes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falcons FC' AND t.source_system_id = 1
  AND per.first_name = 'Aidan' AND per.last_name = 'Hayes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falcons FC' AND t.source_system_id = 1
  AND per.first_name = 'Samuel' AND per.last_name = 'Hong'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falcons FC' AND t.source_system_id = 1
  AND per.first_name = 'Santiago' AND per.last_name = 'Kadadihi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falcons FC' AND t.source_system_id = 1
  AND per.first_name = 'George' AND per.last_name = 'Karafilidis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falcons FC' AND t.source_system_id = 1
  AND per.first_name = 'Jeremy' AND per.last_name = 'Kim'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falcons FC' AND t.source_system_id = 1
  AND per.first_name = 'Eduardo' AND per.last_name = 'Marquez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falcons FC' AND t.source_system_id = 1
  AND per.first_name = 'Nicolas' AND per.last_name = 'Martignoni'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falcons FC' AND t.source_system_id = 1
  AND per.first_name = 'Evan' AND per.last_name = 'Mendonca'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falcons FC' AND t.source_system_id = 1
  AND per.first_name = 'Pablo' AND per.last_name = 'Montilla'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falcons FC' AND t.source_system_id = 1
  AND per.first_name = 'Lucas' AND per.last_name = 'Ortega Morales'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falcons FC' AND t.source_system_id = 1
  AND per.first_name = 'Nicholas' AND per.last_name = 'Stephen Pierangeli'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falcons FC' AND t.source_system_id = 1
  AND per.first_name = 'Mario' AND per.last_name = 'Ruiz Perez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falcons FC' AND t.source_system_id = 1
  AND per.first_name = 'Edwin' AND per.last_name = 'Saravia'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falcons FC' AND t.source_system_id = 1
  AND per.first_name = 'Caio' AND per.last_name = 'Soares'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falcons FC' AND t.source_system_id = 1
  AND per.first_name = 'Johner' AND per.last_name = 'Soe'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falcons FC' AND t.source_system_id = 1
  AND per.first_name = 'Luka' AND per.last_name = 'Szymanski'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Falcons FC' AND t.source_system_id = 1
  AND per.first_name = 'Ross' AND per.last_name = 'Lamont Watson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Fitchburg FC' AND t.source_system_id = 1
  AND per.first_name = 'Mustapha' AND per.last_name = 'Ait Zbair'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Fitchburg FC' AND t.source_system_id = 1
  AND per.first_name = 'Joshua' AND per.last_name = 'Atemkeng'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Fitchburg FC' AND t.source_system_id = 1
  AND per.first_name = 'Ousmane' AND per.last_name = 'balde'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Fitchburg FC' AND t.source_system_id = 1
  AND per.first_name = 'John' AND per.last_name = 'Brewer'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Fitchburg FC' AND t.source_system_id = 1
  AND per.first_name = 'Oscar' AND per.last_name = 'Castillo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Fitchburg FC' AND t.source_system_id = 1
  AND per.first_name = 'Edmond' AND per.last_name = 'Charles'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Fitchburg FC' AND t.source_system_id = 1
  AND per.first_name = 'Dimitri' AND per.last_name = 'Costa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Fitchburg FC' AND t.source_system_id = 1
  AND per.first_name = 'Hamza' AND per.last_name = 'El Amane'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Fitchburg FC' AND t.source_system_id = 1
  AND per.first_name = 'Mohamed' AND per.last_name = 'El-Rhoufi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Fitchburg FC' AND t.source_system_id = 1
  AND per.first_name = 'Hyacinth' AND per.last_name = 'Fongang'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Fitchburg FC' AND t.source_system_id = 1
  AND per.first_name = 'Metayer' AND per.last_name = 'Gassamar'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Fitchburg FC' AND t.source_system_id = 1
  AND per.first_name = 'Abubakar' AND per.last_name = 'Sidiq Hamidu'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Fitchburg FC' AND t.source_system_id = 1
  AND per.first_name = 'Diallo' AND per.last_name = 'Ibrahima'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Fitchburg FC' AND t.source_system_id = 1
  AND per.first_name = 'Ralph' AND per.last_name = 'Jean Baptiste'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Fitchburg FC' AND t.source_system_id = 1
  AND per.first_name = 'Root-mael' AND per.last_name = 'Jean Baptiste'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Fitchburg FC' AND t.source_system_id = 1
  AND per.first_name = 'Cedrick' AND per.last_name = 'Labah'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Fitchburg FC' AND t.source_system_id = 1
  AND per.first_name = 'Bruno' AND per.last_name = 'Lana'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Fitchburg FC' AND t.source_system_id = 1
  AND per.first_name = 'Longtse' AND per.last_name = 'Mofor Landoh'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Fitchburg FC' AND t.source_system_id = 1
  AND per.first_name = 'Roberto' AND per.last_name = 'Martinez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Fitchburg FC' AND t.source_system_id = 1
  AND per.first_name = 'Quang' AND per.last_name = 'Milligan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Fitchburg FC' AND t.source_system_id = 1
  AND per.first_name = 'Bonjoh' AND per.last_name = 'Ngoasong'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Fitchburg FC' AND t.source_system_id = 1
  AND per.first_name = 'Sydiney' AND per.last_name = 'Nyabiosi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Fitchburg FC' AND t.source_system_id = 1
  AND per.first_name = 'Pedro' AND per.last_name = 'Pedrine'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Fitchburg FC' AND t.source_system_id = 1
  AND per.first_name = 'Marc' AND per.last_name = 'Hattley Pierre'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Fitchburg FC' AND t.source_system_id = 1
  AND per.first_name = 'Luvensky' AND per.last_name = 'Polycarpe'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Fitchburg FC' AND t.source_system_id = 1
  AND per.first_name = 'Angelo' AND per.last_name = 'Ramirez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Fitchburg FC' AND t.source_system_id = 1
  AND per.first_name = 'Emerson' AND per.last_name = 'Roman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Fitchburg FC' AND t.source_system_id = 1
  AND per.first_name = 'Yostin' AND per.last_name = 'Roman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Fitchburg FC' AND t.source_system_id = 1
  AND per.first_name = 'Shelton' AND per.last_name = 'Sidelca'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Fitchburg FC' AND t.source_system_id = 1
  AND per.first_name = 'Redwane' AND per.last_name = 'Tinfle'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Fitchburg FC' AND t.source_system_id = 1
  AND per.first_name = 'Nelvin' AND per.last_name = 'Vando'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Fitchburg FC' AND t.source_system_id = 1
  AND per.first_name = 'Jonathan' AND per.last_name = 'Vazquez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Fitchburg FC' AND t.source_system_id = 1
  AND per.first_name = 'Ethan' AND per.last_name = 'Vitello'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Fitchburg FC' AND t.source_system_id = 1
  AND per.first_name = 'Trevor' AND per.last_name = 'Voisine'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Fitchburg FC' AND t.source_system_id = 1
  AND per.first_name = 'Zamy' AND per.last_name = 'Youri Ansley'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Glastonbury Celtic' AND t.source_system_id = 1
  AND per.first_name = 'Colin' AND per.last_name = 'Branigan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Glastonbury Celtic' AND t.source_system_id = 1
  AND per.first_name = 'Colin' AND per.last_name = 'Brocksieper'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Glastonbury Celtic' AND t.source_system_id = 1
  AND per.first_name = 'Nick' AND per.last_name = 'Burkle'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Glastonbury Celtic' AND t.source_system_id = 1
  AND per.first_name = 'Rocco' AND per.last_name = 'D’Arcangelo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Glastonbury Celtic' AND t.source_system_id = 1
  AND per.first_name = 'Massimo' AND per.last_name = 'Eichner'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Glastonbury Celtic' AND t.source_system_id = 1
  AND per.first_name = 'Eddy' AND per.last_name = 'Enowbi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Glastonbury Celtic' AND t.source_system_id = 1
  AND per.first_name = 'Sean' AND per.last_name = 'Gannon'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Glastonbury Celtic' AND t.source_system_id = 1
  AND per.first_name = 'Andrew' AND per.last_name = 'Hayden Geres'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Glastonbury Celtic' AND t.source_system_id = 1
  AND per.first_name = 'Donovan' AND per.last_name = 'Harris'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Glastonbury Celtic' AND t.source_system_id = 1
  AND per.first_name = 'John' AND per.last_name = 'Hess'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Glastonbury Celtic' AND t.source_system_id = 1
  AND per.first_name = 'Jalen' AND per.last_name = 'Jean'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Glastonbury Celtic' AND t.source_system_id = 1
  AND per.first_name = 'Eric-Bertin' AND per.last_name = 'Kalumbwe'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Glastonbury Celtic' AND t.source_system_id = 1
  AND per.first_name = 'Sevon' AND per.last_name = 'Komlan Koudaya'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Glastonbury Celtic' AND t.source_system_id = 1
  AND per.first_name = 'Senan' AND per.last_name = 'Lonergan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Glastonbury Celtic' AND t.source_system_id = 1
  AND per.first_name = 'Luke' AND per.last_name = 'McNabb'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Glastonbury Celtic' AND t.source_system_id = 1
  AND per.first_name = 'Aidan' AND per.last_name = 'Nolan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Glastonbury Celtic' AND t.source_system_id = 1
  AND per.first_name = 'Aidan' AND per.last_name = 'O''Brien'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Glastonbury Celtic' AND t.source_system_id = 1
  AND per.first_name = 'Liam' AND per.last_name = 'O''Brien'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Glastonbury Celtic' AND t.source_system_id = 1
  AND per.first_name = 'Ronan' AND per.last_name = 'O''Brien'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Glastonbury Celtic' AND t.source_system_id = 1
  AND per.first_name = 'Marco' AND per.last_name = 'Parisi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Glastonbury Celtic' AND t.source_system_id = 1
  AND per.first_name = 'Christian' AND per.last_name = 'Rivas-Plata'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Glastonbury Celtic' AND t.source_system_id = 1
  AND per.first_name = 'Colm' AND per.last_name = 'Ryan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Glastonbury Celtic' AND t.source_system_id = 1
  AND per.first_name = 'Ian' AND per.last_name = 'Slattery'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Glastonbury Celtic' AND t.source_system_id = 1
  AND per.first_name = 'Marcris' AND per.last_name = 'Webb'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Glastonbury Celtic' AND t.source_system_id = 1
  AND per.first_name = 'Nick' AND per.last_name = 'Wlodarcyk'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Grove Soccer United' AND t.source_system_id = 1
  AND per.first_name = 'Sami' AND per.last_name = 'Afiouni'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Grove Soccer United' AND t.source_system_id = 1
  AND per.first_name = 'Samuel' AND per.last_name = 'Amedeker'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Grove Soccer United' AND t.source_system_id = 1
  AND per.first_name = 'Owen' AND per.last_name = 'Blount'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Grove Soccer United' AND t.source_system_id = 1
  AND per.first_name = 'Jordan' AND per.last_name = 'Bonnett'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Grove Soccer United' AND t.source_system_id = 1
  AND per.first_name = 'Evan' AND per.last_name = 'Bosak'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Grove Soccer United' AND t.source_system_id = 1
  AND per.first_name = 'Gerard' AND per.last_name = 'Broussard'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Grove Soccer United' AND t.source_system_id = 1
  AND per.first_name = 'Brian' AND per.last_name = 'Chidzvondo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Grove Soccer United' AND t.source_system_id = 1
  AND per.first_name = 'Matthew' AND per.last_name = 'Do'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Grove Soccer United' AND t.source_system_id = 1
  AND per.first_name = 'Joseph' AND per.last_name = 'Enebeli'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Grove Soccer United' AND t.source_system_id = 1
  AND per.first_name = 'Adam' AND per.last_name = 'Grace'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Grove Soccer United' AND t.source_system_id = 1
  AND per.first_name = 'Demetrius' AND per.last_name = 'Howe'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Grove Soccer United' AND t.source_system_id = 1
  AND per.first_name = 'Massimo' AND per.last_name = 'Johnson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Grove Soccer United' AND t.source_system_id = 1
  AND per.first_name = 'Benjamin' AND per.last_name = 'Jones'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Grove Soccer United' AND t.source_system_id = 1
  AND per.first_name = 'Aidan' AND per.last_name = 'Krivanec'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Grove Soccer United' AND t.source_system_id = 1
  AND per.first_name = 'Leighton' AND per.last_name = 'Langenhoven'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Grove Soccer United' AND t.source_system_id = 1
  AND per.first_name = 'Salah' AND per.last_name = 'Mahmoud'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Grove Soccer United' AND t.source_system_id = 1
  AND per.first_name = 'Treyvon' AND per.last_name = 'Medley-Green'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Grove Soccer United' AND t.source_system_id = 1
  AND per.first_name = 'Museba' AND per.last_name = 'Mwape'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Grove Soccer United' AND t.source_system_id = 1
  AND per.first_name = 'Jake' AND per.last_name = 'Nelson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Grove Soccer United' AND t.source_system_id = 1
  AND per.first_name = 'Abulfazl' AND per.last_name = 'Panahi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Grove Soccer United' AND t.source_system_id = 1
  AND per.first_name = 'Dame' AND per.last_name = 'Pene'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Grove Soccer United' AND t.source_system_id = 1
  AND per.first_name = 'Henry' AND per.last_name = 'Pittman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Grove Soccer United' AND t.source_system_id = 1
  AND per.first_name = 'Yoskar' AND per.last_name = 'Alejandro Quintanilla'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Grove Soccer United' AND t.source_system_id = 1
  AND per.first_name = 'Emerson' AND per.last_name = 'Reyes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Grove Soccer United' AND t.source_system_id = 1
  AND per.first_name = 'Mahdi' AND per.last_name = 'Reza'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Grove Soccer United' AND t.source_system_id = 1
  AND per.first_name = 'Mourtala' AND per.last_name = 'Seck'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Grove Soccer United' AND t.source_system_id = 1
  AND per.first_name = 'Alakhe' AND per.last_name = 'Sibeko'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Grove Soccer United' AND t.source_system_id = 1
  AND per.first_name = 'Noe' AND per.last_name = 'Soriano'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Grove Soccer United' AND t.source_system_id = 1
  AND per.first_name = 'Sharief' AND per.last_name = 'Stancil'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Grove Soccer United' AND t.source_system_id = 1
  AND per.first_name = 'Max' AND per.last_name = 'Taliaferro'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Grove Soccer United' AND t.source_system_id = 1
  AND per.first_name = 'Asanda' AND per.last_name = 'Tom'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Grove Soccer United' AND t.source_system_id = 1
  AND per.first_name = 'Caleb' AND per.last_name = 'Underwood'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Grove Soccer United' AND t.source_system_id = 1
  AND per.first_name = 'Callum' AND per.last_name = 'Vellozzi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Grove Soccer United' AND t.source_system_id = 1
  AND per.first_name = 'Chrisendo' AND per.last_name = 'Wentzel'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Grove Soccer United' AND t.source_system_id = 1
  AND per.first_name = 'John' AND per.last_name = 'Williams'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hermandad Connecticut' AND t.source_system_id = 1
  AND per.first_name = 'Bright' AND per.last_name = 'Agyemang'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hermandad Connecticut' AND t.source_system_id = 1
  AND per.first_name = 'Wander' AND per.last_name = 'Alves'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hermandad Connecticut' AND t.source_system_id = 1
  AND per.first_name = 'Guilherme' AND per.last_name = 'Andrade'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hermandad Connecticut' AND t.source_system_id = 1
  AND per.first_name = 'Hayllan' AND per.last_name = 'Batista'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hermandad Connecticut' AND t.source_system_id = 1
  AND per.first_name = 'Gabriel' AND per.last_name = 'Berthoud'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hermandad Connecticut' AND t.source_system_id = 1
  AND per.first_name = 'Gabriel' AND per.last_name = 'Carrelo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hermandad Connecticut' AND t.source_system_id = 1
  AND per.first_name = 'Rodney' AND per.last_name = 'Delgado'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hermandad Connecticut' AND t.source_system_id = 1
  AND per.first_name = 'Gregorio' AND per.last_name = 'Espinoza'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hermandad Connecticut' AND t.source_system_id = 1
  AND per.first_name = 'Wilmer' AND per.last_name = 'Flores'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hermandad Connecticut' AND t.source_system_id = 1
  AND per.first_name = 'Zouhair' AND per.last_name = 'Khal'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hermandad Connecticut' AND t.source_system_id = 1
  AND per.first_name = 'Shamar' AND per.last_name = 'J Kingston'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hermandad Connecticut' AND t.source_system_id = 1
  AND per.first_name = 'Bruno' AND per.last_name = 'Luiz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hermandad Connecticut' AND t.source_system_id = 1
  AND per.first_name = 'Colton' AND per.last_name = 'Lukuc'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hermandad Connecticut' AND t.source_system_id = 1
  AND per.first_name = 'Abdessamad' AND per.last_name = 'Machi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hermandad Connecticut' AND t.source_system_id = 1
  AND per.first_name = 'David' AND per.last_name = 'Mollenthiel'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hermandad Connecticut' AND t.source_system_id = 1
  AND per.first_name = 'Phila' AND per.last_name = 'Nxumalo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hermandad Connecticut' AND t.source_system_id = 1
  AND per.first_name = 'Johan' AND per.last_name = 'Pineda'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hermandad Connecticut' AND t.source_system_id = 1
  AND per.first_name = 'Patrick' AND per.last_name = 'Pineda'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hermandad Connecticut' AND t.source_system_id = 1
  AND per.first_name = 'Andrew' AND per.last_name = 'Ranieri'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hermandad Connecticut' AND t.source_system_id = 1
  AND per.first_name = 'Anthony' AND per.last_name = 'Ranieri'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hermandad Connecticut' AND t.source_system_id = 1
  AND per.first_name = 'Steven' AND per.last_name = 'Rivera'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hermandad Connecticut' AND t.source_system_id = 1
  AND per.first_name = 'Maynor' AND per.last_name = 'Robles'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hermandad Connecticut' AND t.source_system_id = 1
  AND per.first_name = 'Michael' AND per.last_name = 'Rodriguez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hermandad Connecticut' AND t.source_system_id = 1
  AND per.first_name = 'Walter' AND per.last_name = 'Romero'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hermandad Connecticut' AND t.source_system_id = 1
  AND per.first_name = 'Edwin' AND per.last_name = 'Rosano'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hermandad Connecticut' AND t.source_system_id = 1
  AND per.first_name = 'Bairon' AND per.last_name = 'Tejada'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hermandad Connecticut' AND t.source_system_id = 1
  AND per.first_name = 'Diego' AND per.last_name = 'Vega Toledo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hermandad Connecticut' AND t.source_system_id = 1
  AND per.first_name = 'Oscar' AND per.last_name = 'Eduardo Velasquez Centeno'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hermandad Connecticut' AND t.source_system_id = 1
  AND per.first_name = 'Anderson' AND per.last_name = 'Velez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hermandad Connecticut' AND t.source_system_id = 1
  AND per.first_name = 'Tristan' AND per.last_name = 'Vincent'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hermandad Connecticut' AND t.source_system_id = 1
  AND per.first_name = 'Tyler' AND per.last_name = 'Wrenn'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hermandad Connecticut' AND t.source_system_id = 1
  AND per.first_name = 'Javier' AND per.last_name = 'Yanez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912' AND t.source_system_id = 1
  AND per.first_name = 'Santiago' AND per.last_name = 'Arroyave'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912' AND t.source_system_id = 1
  AND per.first_name = 'Tristan' AND per.last_name = 'Barquin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912' AND t.source_system_id = 1
  AND per.first_name = 'Ethan' AND per.last_name = 'Bazan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912' AND t.source_system_id = 1
  AND per.first_name = 'Steven' AND per.last_name = 'Bednarsky'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912' AND t.source_system_id = 1
  AND per.first_name = 'Isimohi' AND per.last_name = 'Mike Bello'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912' AND t.source_system_id = 1
  AND per.first_name = 'Kouadio' AND per.last_name = 'Bolaty'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912' AND t.source_system_id = 1
  AND per.first_name = 'Andrew' AND per.last_name = 'Bortey'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912' AND t.source_system_id = 1
  AND per.first_name = 'Kelvin' AND per.last_name = 'Brito'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912' AND t.source_system_id = 1
  AND per.first_name = 'Dorgeles' AND per.last_name = 'Coulibaly'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912' AND t.source_system_id = 1
  AND per.first_name = 'Tyler' AND per.last_name = 'Diaz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912' AND t.source_system_id = 1
  AND per.first_name = 'Samuel' AND per.last_name = 'Epitime'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912' AND t.source_system_id = 1
  AND per.first_name = 'Adam' AND per.last_name = 'Garner'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912' AND t.source_system_id = 1
  AND per.first_name = 'Matthew' AND per.last_name = 'Gotrell'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912' AND t.source_system_id = 1
  AND per.first_name = 'Ivan' AND per.last_name = 'Enrique Hurtado'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912' AND t.source_system_id = 1
  AND per.first_name = 'Stefan' AND per.last_name = 'Koroman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912' AND t.source_system_id = 1
  AND per.first_name = 'Joseph' AND per.last_name = 'Kresse'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912' AND t.source_system_id = 1
  AND per.first_name = 'Keeroy' AND per.last_name = 'Lionel'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912' AND t.source_system_id = 1
  AND per.first_name = 'Yamil' AND per.last_name = 'Macias'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912' AND t.source_system_id = 1
  AND per.first_name = 'Cameron' AND per.last_name = 'McGregor'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912' AND t.source_system_id = 1
  AND per.first_name = 'Coby' AND per.last_name = 'Mcgregor'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912' AND t.source_system_id = 1
  AND per.first_name = 'Joseph' AND per.last_name = 'Moon'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912' AND t.source_system_id = 1
  AND per.first_name = 'Israel' AND per.last_name = 'Neto'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912' AND t.source_system_id = 1
  AND per.first_name = 'Abdoul' AND per.last_name = 'Ouedraogo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912' AND t.source_system_id = 1
  AND per.first_name = 'Brian' AND per.last_name = 'Paredes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912' AND t.source_system_id = 1
  AND per.first_name = 'Jung' AND per.last_name = 'Park'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912' AND t.source_system_id = 1
  AND per.first_name = 'Ewan' AND per.last_name = 'Sanchez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912' AND t.source_system_id = 1
  AND per.first_name = 'Kevin' AND per.last_name = 'Santamaria'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912' AND t.source_system_id = 1
  AND per.first_name = 'Rodrigo' AND per.last_name = 'Santiago'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912' AND t.source_system_id = 1
  AND per.first_name = 'Miguel' AND per.last_name = 'Sencion'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912' AND t.source_system_id = 1
  AND per.first_name = 'Toheeb' AND per.last_name = 'Shodimu'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912' AND t.source_system_id = 1
  AND per.first_name = 'Luc' AND per.last_name = 'Smith'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912' AND t.source_system_id = 1
  AND per.first_name = 'Ramchwy' AND per.last_name = 'St Vil'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912' AND t.source_system_id = 1
  AND per.first_name = 'Mohamed' AND per.last_name = 'Tall'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912' AND t.source_system_id = 1
  AND per.first_name = 'Christian' AND per.last_name = 'Villegas Libreros'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Hoboken FC 1912' AND t.source_system_id = 1
  AND per.first_name = 'Andrew' AND per.last_name = 'Weiner'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Jersey Shore Boca' AND t.source_system_id = 1
  AND per.first_name = 'Justin' AND per.last_name = 'Alves'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Jersey Shore Boca' AND t.source_system_id = 1
  AND per.first_name = 'Rob' AND per.last_name = 'Andrade'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Jersey Shore Boca' AND t.source_system_id = 1
  AND per.first_name = 'Tyler' AND per.last_name = 'Andreas'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Jersey Shore Boca' AND t.source_system_id = 1
  AND per.first_name = 'William' AND per.last_name = 'Bartels'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Jersey Shore Boca' AND t.source_system_id = 1
  AND per.first_name = 'Harmony' AND per.last_name = 'Bell-Gam'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Jersey Shore Boca' AND t.source_system_id = 1
  AND per.first_name = 'Dane' AND per.last_name = 'Calhoun'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Jersey Shore Boca' AND t.source_system_id = 1
  AND per.first_name = 'Adrian' AND per.last_name = 'Dilascio'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Jersey Shore Boca' AND t.source_system_id = 1
  AND per.first_name = 'Grady' AND per.last_name = 'Edwards'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Jersey Shore Boca' AND t.source_system_id = 1
  AND per.first_name = 'Matt' AND per.last_name = 'Fuentes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Jersey Shore Boca' AND t.source_system_id = 1
  AND per.first_name = 'Douglas' AND per.last_name = 'Jensen'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Jersey Shore Boca' AND t.source_system_id = 1
  AND per.first_name = 'Dylan' AND per.last_name = 'Kanson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Jersey Shore Boca' AND t.source_system_id = 1
  AND per.first_name = 'Marcus' AND per.last_name = 'Mason'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Jersey Shore Boca' AND t.source_system_id = 1
  AND per.first_name = 'Carter' AND per.last_name = 'Mathis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Jersey Shore Boca' AND t.source_system_id = 1
  AND per.first_name = 'Alex' AND per.last_name = 'Matos'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Jersey Shore Boca' AND t.source_system_id = 1
  AND per.first_name = 'Rafael' AND per.last_name = 'Pereira'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Jersey Shore Boca' AND t.source_system_id = 1
  AND per.first_name = 'Anthony' AND per.last_name = 'Ryan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Jersey Shore Boca' AND t.source_system_id = 1
  AND per.first_name = 'Bryan' AND per.last_name = 'Sanchez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Jersey Shore Boca' AND t.source_system_id = 1
  AND per.first_name = 'Dante' AND per.last_name = 'Shenkin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Jersey Shore Boca' AND t.source_system_id = 1
  AND per.first_name = 'Gianni' AND per.last_name = 'Smith'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Jersey Shore Boca' AND t.source_system_id = 1
  AND per.first_name = 'Kieran' AND per.last_name = 'Sundermann'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Jersey Shore Boca' AND t.source_system_id = 1
  AND per.first_name = 'Albert' AND per.last_name = 'Truszkowski'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Jersey Shore Boca' AND t.source_system_id = 1
  AND per.first_name = 'Uche' AND per.last_name = 'Wokocha'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Jersey Shore Boca' AND t.source_system_id = 1
  AND per.first_name = 'Clay' AND per.last_name = 'Yannazzone'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Jersey Shore Boca' AND t.source_system_id = 1
  AND per.first_name = 'Alex' AND per.last_name = 'Zargo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KO Elites' AND t.source_system_id = 1
  AND per.first_name = 'Meysar' AND per.last_name = 'Abdulkadir'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KO Elites' AND t.source_system_id = 1
  AND per.first_name = 'Joel' AND per.last_name = 'Agebtossou'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KO Elites' AND t.source_system_id = 1
  AND per.first_name = 'Davaughn' AND per.last_name = 'Anderson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KO Elites' AND t.source_system_id = 1
  AND per.first_name = 'Deante' AND per.last_name = 'Anderson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KO Elites' AND t.source_system_id = 1
  AND per.first_name = 'Jimmy' AND per.last_name = 'Arita'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KO Elites' AND t.source_system_id = 1
  AND per.first_name = 'Ben' AND per.last_name = 'Awashie'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KO Elites' AND t.source_system_id = 1
  AND per.first_name = 'Alessandro' AND per.last_name = 'Bacabac'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KO Elites' AND t.source_system_id = 1
  AND per.first_name = 'Dejaun' AND per.last_name = 'Beckford'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KO Elites' AND t.source_system_id = 1
  AND per.first_name = 'Joseph' AND per.last_name = 'Boakye'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KO Elites' AND t.source_system_id = 1
  AND per.first_name = 'Alexander' AND per.last_name = 'Clarke'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KO Elites' AND t.source_system_id = 1
  AND per.first_name = 'Caleb' AND per.last_name = 'Ennin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KO Elites' AND t.source_system_id = 1
  AND per.first_name = 'Tim' AND per.last_name = 'Ennin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KO Elites' AND t.source_system_id = 1
  AND per.first_name = 'Shaquan' AND per.last_name = 'Facey'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KO Elites' AND t.source_system_id = 1
  AND per.first_name = 'Jahvanni' AND per.last_name = 'Grant'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KO Elites' AND t.source_system_id = 1
  AND per.first_name = 'Elian' AND per.last_name = 'Guaman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KO Elites' AND t.source_system_id = 1
  AND per.first_name = 'Dax' AND per.last_name = 'Hoffman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KO Elites' AND t.source_system_id = 1
  AND per.first_name = 'George' AND per.last_name = 'Jimenez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KO Elites' AND t.source_system_id = 1
  AND per.first_name = 'Gideon' AND per.last_name = 'Kadiri'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KO Elites' AND t.source_system_id = 1
  AND per.first_name = 'Jaheim' AND per.last_name = 'Kennedy'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KO Elites' AND t.source_system_id = 1
  AND per.first_name = 'Brenden' AND per.last_name = 'Landry'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KO Elites' AND t.source_system_id = 1
  AND per.first_name = 'Shani' AND per.last_name = 'Miller'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KO Elites' AND t.source_system_id = 1
  AND per.first_name = 'Kwesi' AND per.last_name = 'Mills-Odoi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KO Elites' AND t.source_system_id = 1
  AND per.first_name = 'Shemar' AND per.last_name = 'Moore'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KO Elites' AND t.source_system_id = 1
  AND per.first_name = 'Andre' AND per.last_name = 'Morrison'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KO Elites' AND t.source_system_id = 1
  AND per.first_name = 'Yaw' AND per.last_name = 'Nimo-Agyare'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KO Elites' AND t.source_system_id = 1
  AND per.first_name = 'Kenny' AND per.last_name = 'Ofori'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KO Elites' AND t.source_system_id = 1
  AND per.first_name = 'Diwash' AND per.last_name = 'Pun'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KO Elites' AND t.source_system_id = 1
  AND per.first_name = 'Shamar' AND per.last_name = 'Smith'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KO Elites' AND t.source_system_id = 1
  AND per.first_name = 'Sholay' AND per.last_name = 'Sock'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KO Elites' AND t.source_system_id = 1
  AND per.first_name = 'Dane' AND per.last_name = 'Stephens'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'KO Elites' AND t.source_system_id = 1
  AND per.first_name = 'Romaine' AND per.last_name = 'Walters'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC' AND t.source_system_id = 1
  AND per.first_name = 'John' AND per.last_name = 'Bernardi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC' AND t.source_system_id = 1
  AND per.first_name = 'James' AND per.last_name = 'Peter Boote'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC' AND t.source_system_id = 1
  AND per.first_name = 'Aidan' AND per.last_name = 'Borra'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC' AND t.source_system_id = 1
  AND per.first_name = 'Marco' AND per.last_name = 'Charnas'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC' AND t.source_system_id = 1
  AND per.first_name = 'Constantine' AND per.last_name = 'Christodoulou'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC' AND t.source_system_id = 1
  AND per.first_name = 'Stefan' AND per.last_name = 'Copetti'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC' AND t.source_system_id = 1
  AND per.first_name = 'Carlos' AND per.last_name = 'Cortes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC' AND t.source_system_id = 1
  AND per.first_name = 'Musa' AND per.last_name = 'Bala Danso'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC' AND t.source_system_id = 1
  AND per.first_name = 'Ali' AND per.last_name = 'Dawha'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC' AND t.source_system_id = 1
  AND per.first_name = 'Daniel' AND per.last_name = 'Dimarco'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC' AND t.source_system_id = 1
  AND per.first_name = 'Sean' AND per.last_name = 'Doran'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC' AND t.source_system_id = 1
  AND per.first_name = 'Dino' AND per.last_name = 'Feratovic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC' AND t.source_system_id = 1
  AND per.first_name = 'Ethan' AND per.last_name = 'Furphy'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC' AND t.source_system_id = 1
  AND per.first_name = 'Michael' AND per.last_name = 'Gallagher'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC' AND t.source_system_id = 1
  AND per.first_name = 'Kyle' AND per.last_name = 'Galloway'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC' AND t.source_system_id = 1
  AND per.first_name = 'Henry' AND per.last_name = 'Hamilton'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC' AND t.source_system_id = 1
  AND per.first_name = 'Cillian' AND per.last_name = 'Heaney'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC' AND t.source_system_id = 1
  AND per.first_name = 'Michael' AND per.last_name = 'Hewes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC' AND t.source_system_id = 1
  AND per.first_name = 'Ethan' AND per.last_name = 'Homler'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC' AND t.source_system_id = 1
  AND per.first_name = 'Jared' AND per.last_name = 'Juleau'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC' AND t.source_system_id = 1
  AND per.first_name = 'Andy' AND per.last_name = 'Kasza'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC' AND t.source_system_id = 1
  AND per.first_name = 'Daryl' AND per.last_name = 'Kavanagh'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC' AND t.source_system_id = 1
  AND per.first_name = 'Seamus' AND per.last_name = 'Keogh'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC' AND t.source_system_id = 1
  AND per.first_name = 'Sean' AND per.last_name = 'Kerrigan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC' AND t.source_system_id = 1
  AND per.first_name = 'Danu' AND per.last_name = 'Kinsella-Bishop'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC' AND t.source_system_id = 1
  AND per.first_name = 'Nicolas' AND per.last_name = 'Macri Badessich'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC' AND t.source_system_id = 1
  AND per.first_name = 'Luis' AND per.last_name = 'Puchol Del Pozo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC' AND t.source_system_id = 1
  AND per.first_name = 'Sebastian' AND per.last_name = 'Rojek'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC' AND t.source_system_id = 1
  AND per.first_name = 'Liam' AND per.last_name = 'Salmon'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC' AND t.source_system_id = 1
  AND per.first_name = 'Harry' AND per.last_name = 'Sankey'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC' AND t.source_system_id = 1
  AND per.first_name = 'Edward' AND per.last_name = 'Speed'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC' AND t.source_system_id = 1
  AND per.first_name = 'Benjamin' AND per.last_name = 'Stitz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC' AND t.source_system_id = 1
  AND per.first_name = 'Liam' AND per.last_name = 'Walsh'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lansdowne Yonkers FC' AND t.source_system_id = 1
  AND per.first_name = 'Oskar' AND per.last_name = 'Zywiec'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Nova FC' AND t.source_system_id = 1
  AND per.first_name = 'Soheyl' AND per.last_name = 'Ali Rafi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Nova FC' AND t.source_system_id = 1
  AND per.first_name = 'Jonathan' AND per.last_name = 'Arguta'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Nova FC' AND t.source_system_id = 1
  AND per.first_name = 'Jean' AND per.last_name = 'Ayolmbong'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Nova FC' AND t.source_system_id = 1
  AND per.first_name = 'Eric' AND per.last_name = 'Calvillo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Nova FC' AND t.source_system_id = 1
  AND per.first_name = 'Jhonny' AND per.last_name = 'De Souza'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Nova FC' AND t.source_system_id = 1
  AND per.first_name = 'Valdir' AND per.last_name = 'De Souza'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Nova FC' AND t.source_system_id = 1
  AND per.first_name = 'Isiah' AND per.last_name = 'Dorsey'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Nova FC' AND t.source_system_id = 1
  AND per.first_name = 'Ricardo' AND per.last_name = 'Espinoza'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Nova FC' AND t.source_system_id = 1
  AND per.first_name = 'Jerry' AND per.last_name = 'Felix'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Nova FC' AND t.source_system_id = 1
  AND per.first_name = 'Caleb' AND per.last_name = 'Ghannam'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Nova FC' AND t.source_system_id = 1
  AND per.first_name = 'Jose' AND per.last_name = 'Gonzlaez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Nova FC' AND t.source_system_id = 1
  AND per.first_name = 'Adsam' AND per.last_name = 'Guennouni'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Nova FC' AND t.source_system_id = 1
  AND per.first_name = 'Jackson' AND per.last_name = 'Hall'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Nova FC' AND t.source_system_id = 1
  AND per.first_name = 'Emmitt' AND per.last_name = 'Inestroza'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Nova FC' AND t.source_system_id = 1
  AND per.first_name = 'Abdul-Azim' AND per.last_name = 'Ismail'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Nova FC' AND t.source_system_id = 1
  AND per.first_name = 'Abdul-Rahman' AND per.last_name = 'Ismail'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Nova FC' AND t.source_system_id = 1
  AND per.first_name = 'Ethan' AND per.last_name = 'Lee'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Nova FC' AND t.source_system_id = 1
  AND per.first_name = 'Huber' AND per.last_name = 'Letona'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Nova FC' AND t.source_system_id = 1
  AND per.first_name = 'Ethan' AND per.last_name = 'Lloyd'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Nova FC' AND t.source_system_id = 1
  AND per.first_name = 'Bernardo' AND per.last_name = 'Majano'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Nova FC' AND t.source_system_id = 1
  AND per.first_name = 'Reda' AND per.last_name = 'Manafi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Nova FC' AND t.source_system_id = 1
  AND per.first_name = 'Jack' AND per.last_name = 'Pinson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Nova FC' AND t.source_system_id = 1
  AND per.first_name = 'Jaime' AND per.last_name = 'Quintanilla'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Nova FC' AND t.source_system_id = 1
  AND per.first_name = 'Michael' AND per.last_name = 'Radomski'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Nova FC' AND t.source_system_id = 1
  AND per.first_name = 'Ahmed' AND per.last_name = 'Sheta'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Nova FC' AND t.source_system_id = 1
  AND per.first_name = 'Roman' AND per.last_name = 'Topler'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Nova FC' AND t.source_system_id = 1
  AND per.first_name = 'Marques' AND per.last_name = 'Vagner'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Nova FC' AND t.source_system_id = 1
  AND per.first_name = 'Alton' AND per.last_name = 'West'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 1
  AND per.first_name = 'Dominik' AND per.last_name = 'Brulinski'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 1
  AND per.first_name = 'Mathew' AND per.last_name = 'Contino'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 1
  AND per.first_name = 'Joseph' AND per.last_name = 'Core'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 1
  AND per.first_name = 'Jacob' AND per.last_name = 'Denison'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 1
  AND per.first_name = 'Jack' AND per.last_name = 'Doran'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 1
  AND per.first_name = 'Javiar' AND per.last_name = 'Edwards'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 1
  AND per.first_name = 'Humbert' AND per.last_name = 'Ferrer'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 1
  AND per.first_name = 'Spencer' AND per.last_name = 'Fleurant'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 1
  AND per.first_name = 'Jason' AND per.last_name = 'Gaylord'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 1
  AND per.first_name = 'Daniel' AND per.last_name = 'Giorgi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 1
  AND per.first_name = 'Kevin' AND per.last_name = 'Harrington'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 1
  AND per.first_name = 'Stephanos' AND per.last_name = 'Hondrakis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 1
  AND per.first_name = 'Cris' AND per.last_name = 'Huacon'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 1
  AND per.first_name = 'Samuka' AND per.last_name = 'Kenneh'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 1
  AND per.first_name = 'Evan' AND per.last_name = 'Kim'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 1
  AND per.first_name = 'Brent' AND per.last_name = 'McKeown'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 1
  AND per.first_name = 'Enrique' AND per.last_name = 'Montana III'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 1
  AND per.first_name = 'Jack' AND per.last_name = 'Mulhare'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 1
  AND per.first_name = 'Curtis' AND per.last_name = 'Oberg'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 1
  AND per.first_name = 'Farouk' AND per.last_name = 'Osman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 1
  AND per.first_name = 'Cole' AND per.last_name = 'Parete'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 1
  AND per.first_name = 'William' AND per.last_name = 'Pearce'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 1
  AND per.first_name = 'Akeem' AND per.last_name = 'Phipps'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 1
  AND per.first_name = 'Layton' AND per.last_name = 'Purchase'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 1
  AND per.first_name = 'Nabeel' AND per.last_name = 'Qawasmi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 1
  AND per.first_name = 'Yannick' AND per.last_name = 'Rihs'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 1
  AND per.first_name = 'Antonio' AND per.last_name = 'Rocha'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 1
  AND per.first_name = 'Jake' AND per.last_name = 'Rozhansky'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 1
  AND per.first_name = 'Yahli' AND per.last_name = 'Saltsberg'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 1
  AND per.first_name = 'Frank' AND per.last_name = 'Shkreli'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 1
  AND per.first_name = 'Michael' AND per.last_name = 'Soboff'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 1
  AND per.first_name = 'Tom' AND per.last_name = 'Wallenstein'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 1
  AND per.first_name = 'Michael' AND per.last_name = 'Wampler'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 1
  AND per.first_name = 'Peter' AND per.last_name = 'Wentzel'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Athletic Club' AND t.source_system_id = 1
  AND per.first_name = 'Edwin' AND per.last_name = 'Zuniga Lopez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Greek Americans' AND t.source_system_id = 1
  AND per.first_name = 'Hermanus' AND per.last_name = 'Achterkamp'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Greek Americans' AND t.source_system_id = 1
  AND per.first_name = 'Christopher' AND per.last_name = 'Diego Anderson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Greek Americans' AND t.source_system_id = 1
  AND per.first_name = 'Daniel' AND per.last_name = 'Bedoya'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Greek Americans' AND t.source_system_id = 1
  AND per.first_name = 'Etienne' AND per.last_name = 'Botty'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Greek Americans' AND t.source_system_id = 1
  AND per.first_name = 'Daniel' AND per.last_name = 'Burko'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Greek Americans' AND t.source_system_id = 1
  AND per.first_name = 'Stefano' AND per.last_name = 'Campisi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Greek Americans' AND t.source_system_id = 1
  AND per.first_name = 'Francesco' AND per.last_name = 'Caorsi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Greek Americans' AND t.source_system_id = 1
  AND per.first_name = 'Roc' AND per.last_name = 'Carles Puig'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Greek Americans' AND t.source_system_id = 1
  AND per.first_name = 'Myson' AND per.last_name = 'Colo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Greek Americans' AND t.source_system_id = 1
  AND per.first_name = 'Rodrigo' AND per.last_name = 'Descalzo Rocca'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Greek Americans' AND t.source_system_id = 1
  AND per.first_name = 'Miguel' AND per.last_name = 'Mauricio Diaz Cubas'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Greek Americans' AND t.source_system_id = 1
  AND per.first_name = 'Timothy' AND per.last_name = 'Joseph Gallagher-De Meij'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Greek Americans' AND t.source_system_id = 1
  AND per.first_name = 'Miguel' AND per.last_name = 'Soto Gonzalez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Greek Americans' AND t.source_system_id = 1
  AND per.first_name = 'Pierce' AND per.last_name = 'John Infuso'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Greek Americans' AND t.source_system_id = 1
  AND per.first_name = 'Adam' AND per.last_name = 'Marcu'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Greek Americans' AND t.source_system_id = 1
  AND per.first_name = 'Patrick' AND per.last_name = 'McCann'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Greek Americans' AND t.source_system_id = 1
  AND per.first_name = 'Paul' AND per.last_name = 'McVeigh'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Greek Americans' AND t.source_system_id = 1
  AND per.first_name = 'James' AND per.last_name = 'Nealis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Greek Americans' AND t.source_system_id = 1
  AND per.first_name = 'Jack' AND per.last_name = 'O''Malley'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Greek Americans' AND t.source_system_id = 1
  AND per.first_name = 'George' AND per.last_name = 'O`Malley'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Greek Americans' AND t.source_system_id = 1
  AND per.first_name = 'Nicholas' AND per.last_name = 'Oberrauch'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Greek Americans' AND t.source_system_id = 1
  AND per.first_name = 'Alberto' AND per.last_name = 'Pangrazzi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Greek Americans' AND t.source_system_id = 1
  AND per.first_name = 'Francesco' AND per.last_name = 'Perinelli'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Greek Americans' AND t.source_system_id = 1
  AND per.first_name = 'Nicholas' AND per.last_name = 'Petridis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Greek Americans' AND t.source_system_id = 1
  AND per.first_name = 'Cormac' AND per.last_name = 'Pike'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Greek Americans' AND t.source_system_id = 1
  AND per.first_name = 'Saeed' AND per.last_name = 'Robinson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Greek Americans' AND t.source_system_id = 1
  AND per.first_name = 'John' AND per.last_name = 'Sabal'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Greek Americans' AND t.source_system_id = 1
  AND per.first_name = 'Brian' AND per.last_name = 'Sousa Saramago'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Greek Americans' AND t.source_system_id = 1
  AND per.first_name = 'Joshua' AND per.last_name = 'Schaffer'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Greek Americans' AND t.source_system_id = 1
  AND per.first_name = 'Barakatulla' AND per.last_name = 'Sharifi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Greek Americans' AND t.source_system_id = 1
  AND per.first_name = 'Yacine' AND per.last_name = 'Sidi Aissa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Greek Americans' AND t.source_system_id = 1
  AND per.first_name = 'Gabriel' AND per.last_name = 'Villanueva Pacheco'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Greek Americans' AND t.source_system_id = 1
  AND per.first_name = 'Leo' AND per.last_name = 'Wei Pinto'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Greek Americans' AND t.source_system_id = 1
  AND per.first_name = 'Joseph' AND per.last_name = 'Wright'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Greek Americans' AND t.source_system_id = 1
  AND per.first_name = 'El' AND per.last_name = 'Mahdi Youssoufi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms' AND t.source_system_id = 1
  AND per.first_name = 'Pablo' AND per.last_name = 'Ablanedo Llaneza'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms' AND t.source_system_id = 1
  AND per.first_name = 'Jordan' AND per.last_name = 'Bailon'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms' AND t.source_system_id = 1
  AND per.first_name = 'Filip' AND per.last_name = 'Basili'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms' AND t.source_system_id = 1
  AND per.first_name = 'Axel' AND per.last_name = 'Berglund'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms' AND t.source_system_id = 1
  AND per.first_name = 'Christopher' AND per.last_name = 'Bermudez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms' AND t.source_system_id = 1
  AND per.first_name = 'Victor' AND per.last_name = 'Castel'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms' AND t.source_system_id = 1
  AND per.first_name = 'Rikard' AND per.last_name = 'Cederberg'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms' AND t.source_system_id = 1
  AND per.first_name = 'Nicolas' AND per.last_name = 'Cifuentes DIaz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms' AND t.source_system_id = 1
  AND per.first_name = 'Sergio' AND per.last_name = 'Diaz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms' AND t.source_system_id = 1
  AND per.first_name = 'Eric' AND per.last_name = 'Frimpong'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms' AND t.source_system_id = 1
  AND per.first_name = 'George' AND per.last_name = 'Gantalis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms' AND t.source_system_id = 1
  AND per.first_name = 'Gonzalo' AND per.last_name = 'Gil de Pareja'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms' AND t.source_system_id = 1
  AND per.first_name = 'Ede' AND per.last_name = 'Mateo Gramberg'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms' AND t.source_system_id = 1
  AND per.first_name = 'Thomas' AND per.last_name = 'Gray'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms' AND t.source_system_id = 1
  AND per.first_name = 'Antreas' AND per.last_name = 'Hadjigavriel'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms' AND t.source_system_id = 1
  AND per.first_name = 'Harri' AND per.last_name = 'Hawkins'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms' AND t.source_system_id = 1
  AND per.first_name = 'Devin' AND per.last_name = 'Heanue'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms' AND t.source_system_id = 1
  AND per.first_name = 'Christopher' AND per.last_name = 'Heckenberg'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms' AND t.source_system_id = 1
  AND per.first_name = 'Kevin' AND per.last_name = 'Hernandez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms' AND t.source_system_id = 1
  AND per.first_name = 'Jens' AND per.last_name = 'Mannhart Hoff'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms' AND t.source_system_id = 1
  AND per.first_name = 'Joseph' AND per.last_name = 'Holland'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms' AND t.source_system_id = 1
  AND per.first_name = 'Filip' AND per.last_name = 'Jauk'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms' AND t.source_system_id = 1
  AND per.first_name = 'Konstantinos' AND per.last_name = 'Karousis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms' AND t.source_system_id = 1
  AND per.first_name = 'Benny' AND per.last_name = 'Lafortune'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms' AND t.source_system_id = 1
  AND per.first_name = 'Joshua' AND per.last_name = 'Levine'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms' AND t.source_system_id = 1
  AND per.first_name = 'Juan' AND per.last_name = 'Martinez Moreno'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms' AND t.source_system_id = 1
  AND per.first_name = 'Filip' AND per.last_name = 'Mirkovic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms' AND t.source_system_id = 1
  AND per.first_name = 'Christoforos' AND per.last_name = 'Moulinos'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms' AND t.source_system_id = 1
  AND per.first_name = 'Stephen' AND per.last_name = 'O’ Connell'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms' AND t.source_system_id = 1
  AND per.first_name = 'Alex' AND per.last_name = 'Palas'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms' AND t.source_system_id = 1
  AND per.first_name = 'Sebastian' AND per.last_name = 'Ruiz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms' AND t.source_system_id = 1
  AND per.first_name = 'Athanasis' AND per.last_name = 'Shehadeh'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms' AND t.source_system_id = 1
  AND per.first_name = 'James' AND per.last_name = 'Thristino'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY Pancyprian Freedoms' AND t.source_system_id = 1
  AND per.first_name = 'Sean' AND per.last_name = 'Towey'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC' AND t.source_system_id = 1
  AND per.first_name = 'Osman' AND per.last_name = 'Barrie'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC' AND t.source_system_id = 1
  AND per.first_name = 'Paul' AND per.last_name = 'Bechtelheimer'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC' AND t.source_system_id = 1
  AND per.first_name = 'Nathan' AND per.last_name = 'Biersbach'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC' AND t.source_system_id = 1
  AND per.first_name = 'Brayden' AND per.last_name = 'Birnstiel'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC' AND t.source_system_id = 1
  AND per.first_name = 'Ryan' AND per.last_name = 'Cleary'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC' AND t.source_system_id = 1
  AND per.first_name = 'Theo' AND per.last_name = 'Da Silva'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC' AND t.source_system_id = 1
  AND per.first_name = 'Kaelan' AND per.last_name = 'Debbage'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC' AND t.source_system_id = 1
  AND per.first_name = 'Blake' AND per.last_name = 'Driehuis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC' AND t.source_system_id = 1
  AND per.first_name = 'Gavin' AND per.last_name = 'Faracchio'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC' AND t.source_system_id = 1
  AND per.first_name = 'Vincent' AND per.last_name = 'Guzzo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC' AND t.source_system_id = 1
  AND per.first_name = 'Maxwell' AND per.last_name = 'Byrd Hawk'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC' AND t.source_system_id = 1
  AND per.first_name = 'Austin' AND per.last_name = 'Johnson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC' AND t.source_system_id = 1
  AND per.first_name = 'Sincere' AND per.last_name = 'Kato'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC' AND t.source_system_id = 1
  AND per.first_name = 'Muhammed' AND per.last_name = 'Ali Kol'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC' AND t.source_system_id = 1
  AND per.first_name = 'Berlenz' AND per.last_name = 'Lumarque'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC' AND t.source_system_id = 1
  AND per.first_name = 'Jason' AND per.last_name = 'Mancuso'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC' AND t.source_system_id = 1
  AND per.first_name = 'Jade' AND per.last_name = 'Mesias'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC' AND t.source_system_id = 1
  AND per.first_name = 'Tommy' AND per.last_name = 'Monaghan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC' AND t.source_system_id = 1
  AND per.first_name = 'Jeff' AND per.last_name = 'Morgan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC' AND t.source_system_id = 1
  AND per.first_name = 'Jake' AND per.last_name = 'Mulinge'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC' AND t.source_system_id = 1
  AND per.first_name = 'Joseph' AND per.last_name = 'Nguyen'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC' AND t.source_system_id = 1
  AND per.first_name = 'Carter' AND per.last_name = 'Jack Norton'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC' AND t.source_system_id = 1
  AND per.first_name = 'Matthew' AND per.last_name = 'Perrella'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC' AND t.source_system_id = 1
  AND per.first_name = 'Dylan' AND per.last_name = 'Pino'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC' AND t.source_system_id = 1
  AND per.first_name = 'Samuel' AND per.last_name = 'Quaye'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC' AND t.source_system_id = 1
  AND per.first_name = 'Julito' AND per.last_name = 'Quintana'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC' AND t.source_system_id = 1
  AND per.first_name = 'Ethan' AND per.last_name = 'Romito'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC' AND t.source_system_id = 1
  AND per.first_name = 'Ahmed' AND per.last_name = 'Saidi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC' AND t.source_system_id = 1
  AND per.first_name = 'Max' AND per.last_name = 'Schrader'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC' AND t.source_system_id = 1
  AND per.first_name = 'Seth' AND per.last_name = 'Sidle'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC' AND t.source_system_id = 1
  AND per.first_name = 'Adam' AND per.last_name = 'Sternberger'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC' AND t.source_system_id = 1
  AND per.first_name = 'Steven' AND per.last_name = 'Thompson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC' AND t.source_system_id = 1
  AND per.first_name = 'Nico' AND per.last_name = 'Tramontana'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Oaklyn United FC' AND t.source_system_id = 1
  AND per.first_name = 'John' AND per.last_name = 'Troiano'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PFA EPSL' AND t.source_system_id = 1
  AND per.first_name = 'Kennison' AND per.last_name = 'Akuro'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PFA EPSL' AND t.source_system_id = 1
  AND per.first_name = 'Melvin' AND per.last_name = 'Asanji'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PFA EPSL' AND t.source_system_id = 1
  AND per.first_name = 'Brandon' AND per.last_name = 'Betts'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PFA EPSL' AND t.source_system_id = 1
  AND per.first_name = 'Isaac' AND per.last_name = 'Carvajal'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PFA EPSL' AND t.source_system_id = 1
  AND per.first_name = 'Elido' AND per.last_name = 'Noel Chun Reyes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PFA EPSL' AND t.source_system_id = 1
  AND per.first_name = 'Jenovic' AND per.last_name = 'Elumbu'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PFA EPSL' AND t.source_system_id = 1
  AND per.first_name = 'Anderson' AND per.last_name = 'Fernandez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PFA EPSL' AND t.source_system_id = 1
  AND per.first_name = 'Angello' AND per.last_name = 'Fernandez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PFA EPSL' AND t.source_system_id = 1
  AND per.first_name = 'Terry' AND per.last_name = 'Fon'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PFA EPSL' AND t.source_system_id = 1
  AND per.first_name = 'Eduardo' AND per.last_name = 'Fuentes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PFA EPSL' AND t.source_system_id = 1
  AND per.first_name = 'Christian' AND per.last_name = 'Garavito'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PFA EPSL' AND t.source_system_id = 1
  AND per.first_name = 'Thaddeus' AND per.last_name = 'Goddard'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PFA EPSL' AND t.source_system_id = 1
  AND per.first_name = 'Alexis' AND per.last_name = 'Gonzalez Ayala'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PFA EPSL' AND t.source_system_id = 1
  AND per.first_name = 'Chayton' AND per.last_name = 'Kuidlan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PFA EPSL' AND t.source_system_id = 1
  AND per.first_name = 'Tobias' AND per.last_name = 'Lane'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PFA EPSL' AND t.source_system_id = 1
  AND per.first_name = 'Jonathan' AND per.last_name = 'Lemus Morales'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PFA EPSL' AND t.source_system_id = 1
  AND per.first_name = 'Creasy' AND per.last_name = 'Lopez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PFA EPSL' AND t.source_system_id = 1
  AND per.first_name = 'Lutho' AND per.last_name = 'Mlunguza'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PFA EPSL' AND t.source_system_id = 1
  AND per.first_name = 'Toju' AND per.last_name = 'Okonedo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PFA EPSL' AND t.source_system_id = 1
  AND per.first_name = 'David' AND per.last_name = 'Pawlowski'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PFA EPSL' AND t.source_system_id = 1
  AND per.first_name = 'Danny' AND per.last_name = 'Paz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PFA EPSL' AND t.source_system_id = 1
  AND per.first_name = 'Brayan' AND per.last_name = 'Perez Mendez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PFA EPSL' AND t.source_system_id = 1
  AND per.first_name = 'Bronson' AND per.last_name = 'Shepherd'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PFA EPSL' AND t.source_system_id = 1
  AND per.first_name = 'Nicholas' AND per.last_name = 'Tziamouranis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PFA EPSL' AND t.source_system_id = 1
  AND per.first_name = 'William' AND per.last_name = 'Villatoro Velasquez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PFA EPSL' AND t.source_system_id = 1
  AND per.first_name = 'Brian' AND per.last_name = 'Ware'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Heritage SC' AND t.source_system_id = 1
  AND per.first_name = 'Eric' AND per.last_name = 'Adamo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Heritage SC' AND t.source_system_id = 1
  AND per.first_name = 'Salam' AND per.last_name = 'Ashurmamadov'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Heritage SC' AND t.source_system_id = 1
  AND per.first_name = 'Matthew' AND per.last_name = 'Bergmaier'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Heritage SC' AND t.source_system_id = 1
  AND per.first_name = 'Daniel' AND per.last_name = 'Bloyou'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Heritage SC' AND t.source_system_id = 1
  AND per.first_name = 'Lawrence' AND per.last_name = 'Buigbo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Heritage SC' AND t.source_system_id = 1
  AND per.first_name = 'Diego' AND per.last_name = 'Cabrera'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Heritage SC' AND t.source_system_id = 1
  AND per.first_name = 'Emanuel' AND per.last_name = 'Caire'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Heritage SC' AND t.source_system_id = 1
  AND per.first_name = 'Sebastian' AND per.last_name = 'Carmona'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Heritage SC' AND t.source_system_id = 1
  AND per.first_name = 'Chad' AND per.last_name = 'Catalana'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Heritage SC' AND t.source_system_id = 1
  AND per.first_name = 'Nyles' AND per.last_name = 'Cayemitte'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Heritage SC' AND t.source_system_id = 1
  AND per.first_name = 'Justin' AND per.last_name = 'Cooper'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Heritage SC' AND t.source_system_id = 1
  AND per.first_name = 'Kevin' AND per.last_name = 'Davis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Heritage SC' AND t.source_system_id = 1
  AND per.first_name = 'Alvin' AND per.last_name = 'Deegon'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Heritage SC' AND t.source_system_id = 1
  AND per.first_name = 'Yousouf' AND per.last_name = 'Doucoure'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Heritage SC' AND t.source_system_id = 1
  AND per.first_name = 'Nick' AND per.last_name = 'Dudek'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Heritage SC' AND t.source_system_id = 1
  AND per.first_name = 'Andres' AND per.last_name = 'Freire'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Heritage SC' AND t.source_system_id = 1
  AND per.first_name = 'Luka' AND per.last_name = 'Gogidze'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Heritage SC' AND t.source_system_id = 1
  AND per.first_name = 'Andres' AND per.last_name = 'Gomez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Heritage SC' AND t.source_system_id = 1
  AND per.first_name = 'Brendan' AND per.last_name = 'Gorman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Heritage SC' AND t.source_system_id = 1
  AND per.first_name = 'Ermir' AND per.last_name = 'Hoti'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Heritage SC' AND t.source_system_id = 1
  AND per.first_name = 'Hamin' AND per.last_name = 'Kim'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Heritage SC' AND t.source_system_id = 1
  AND per.first_name = 'Kalvin' AND per.last_name = 'Matischak'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Heritage SC' AND t.source_system_id = 1
  AND per.first_name = 'Gabriel' AND per.last_name = 'Matute'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Heritage SC' AND t.source_system_id = 1
  AND per.first_name = 'Aidan' AND per.last_name = 'Meissler'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Heritage SC' AND t.source_system_id = 1
  AND per.first_name = 'Glenn' AND per.last_name = 'Moyer'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Heritage SC' AND t.source_system_id = 1
  AND per.first_name = 'Kyle' AND per.last_name = 'Mtshazo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Heritage SC' AND t.source_system_id = 1
  AND per.first_name = 'Daniel' AND per.last_name = 'Murtagh'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Heritage SC' AND t.source_system_id = 1
  AND per.first_name = 'Justin' AND per.last_name = 'Odoemene'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Heritage SC' AND t.source_system_id = 1
  AND per.first_name = 'Ryan' AND per.last_name = 'Pereus'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Heritage SC' AND t.source_system_id = 1
  AND per.first_name = 'Christopher' AND per.last_name = 'Rodriguez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Heritage SC' AND t.source_system_id = 1
  AND per.first_name = 'Eran' AND per.last_name = 'Shifris'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Heritage SC' AND t.source_system_id = 1
  AND per.first_name = 'Andres' AND per.last_name = 'Velez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Heritage SC' AND t.source_system_id = 1
  AND per.first_name = 'Seth' AND per.last_name = 'Walker'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Heritage SC' AND t.source_system_id = 1
  AND per.first_name = 'John' AND per.last_name = 'Steven Warren'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Mark' AND per.last_name = 'Abbonizio'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Sergio' AND per.last_name = 'Abelardy'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Harry' AND per.last_name = 'Angelis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Pedro' AND per.last_name = 'Barbosa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Hunter' AND per.last_name = 'Bell'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Brendan' AND per.last_name = 'Callahan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Mohamed' AND per.last_name = 'Elgayar'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Salvatore' AND per.last_name = 'Ficarotta'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Henry' AND per.last_name = 'Guzman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Theophilus' AND per.last_name = 'Ijeboi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Mohamed' AND per.last_name = 'Jawara'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Sean' AND per.last_name = 'Murray'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Laurence' AND per.last_name = 'Narcisi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Michael' AND per.last_name = 'Newell'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Kaleb' AND per.last_name = 'Raymond'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Joel' AND per.last_name = 'Richmond'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Benjamin' AND per.last_name = 'Richter'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Joshua' AND per.last_name = 'Rifkin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Daniel' AND per.last_name = 'Saint-Pol'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'David' AND per.last_name = 'Skiendzielewski'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Owen' AND per.last_name = 'Stock'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Ryan' AND per.last_name = 'Stock'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Rasheed' AND per.last_name = 'Thomas'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Sean' AND per.last_name = 'Touey'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Philadelphia Soccer Club' AND t.source_system_id = 1
  AND per.first_name = 'Jesse' AND per.last_name = 'Weick'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Praia Kapital' AND t.source_system_id = 1
  AND per.first_name = 'Mario' AND per.last_name = 'Amado'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Praia Kapital' AND t.source_system_id = 1
  AND per.first_name = 'Brenner' AND per.last_name = 'Cardoso'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Praia Kapital' AND t.source_system_id = 1
  AND per.first_name = 'Wendy' AND per.last_name = 'Celestin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Praia Kapital' AND t.source_system_id = 1
  AND per.first_name = 'Denilson' AND per.last_name = 'Barros Centeio'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Praia Kapital' AND t.source_system_id = 1
  AND per.first_name = 'Jacinto' AND per.last_name = 'Correia'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Praia Kapital' AND t.source_system_id = 1
  AND per.first_name = 'Edson' AND per.last_name = 'Andarade Da Silva'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Praia Kapital' AND t.source_system_id = 1
  AND per.first_name = 'Fabio' AND per.last_name = 'Pires Da Silva'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Praia Kapital' AND t.source_system_id = 1
  AND per.first_name = 'Rivaldo' AND per.last_name = 'Baessa Da Silva'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Praia Kapital' AND t.source_system_id = 1
  AND per.first_name = 'Heracles' AND per.last_name = 'De Pina Fernandes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Praia Kapital' AND t.source_system_id = 1
  AND per.first_name = 'Paulo' AND per.last_name = 'De Pina Goncalves'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Praia Kapital' AND t.source_system_id = 1
  AND per.first_name = 'Valdir' AND per.last_name = 'Depina'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Praia Kapital' AND t.source_system_id = 1
  AND per.first_name = 'Isandro' AND per.last_name = 'Fernandes Lopes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Praia Kapital' AND t.source_system_id = 1
  AND per.first_name = 'Mario' AND per.last_name = 'Figueroa Garcia'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Praia Kapital' AND t.source_system_id = 1
  AND per.first_name = 'Adilson' AND per.last_name = 'Gomes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Praia Kapital' AND t.source_system_id = 1
  AND per.first_name = 'Clayton' AND per.last_name = 'Gomes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Praia Kapital' AND t.source_system_id = 1
  AND per.first_name = 'Estevao' AND per.last_name = 'Gomes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Praia Kapital' AND t.source_system_id = 1
  AND per.first_name = 'Jair' AND per.last_name = 'Gomes De Pina'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Praia Kapital' AND t.source_system_id = 1
  AND per.first_name = 'Jose' AND per.last_name = 'Gomes Rodrigues'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Praia Kapital' AND t.source_system_id = 1
  AND per.first_name = 'Papa' AND per.last_name = 'Ndiaye'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Praia Kapital' AND t.source_system_id = 1
  AND per.first_name = 'Lucas' AND per.last_name = 'Nogueira Monteiro'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Praia Kapital' AND t.source_system_id = 1
  AND per.first_name = 'Nima' AND per.last_name = 'Norouzi Behjat'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Praia Kapital' AND t.source_system_id = 1
  AND per.first_name = 'Imauro' AND per.last_name = 'Pina'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Praia Kapital' AND t.source_system_id = 1
  AND per.first_name = 'Mauro' AND per.last_name = 'Pires Amado'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Praia Kapital' AND t.source_system_id = 1
  AND per.first_name = 'Anthony' AND per.last_name = 'Ramos'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Praia Kapital' AND t.source_system_id = 1
  AND per.first_name = 'Jose' AND per.last_name = 'Rodrigues Teixeira'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Praia Kapital' AND t.source_system_id = 1
  AND per.first_name = 'Djeison' AND per.last_name = 'Rodrigues Vieira'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Praia Kapital' AND t.source_system_id = 1
  AND per.first_name = 'Tahir' AND per.last_name = 'Akil Scott'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Praia Kapital' AND t.source_system_id = 1
  AND per.first_name = 'Ronilson' AND per.last_name = 'Semedo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Praia Kapital' AND t.source_system_id = 1
  AND per.first_name = 'Francisco' AND per.last_name = 'M Silveira'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Praia Kapital' AND t.source_system_id = 1
  AND per.first_name = 'Yassine' AND per.last_name = 'Smissame'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Praia Kapital' AND t.source_system_id = 1
  AND per.first_name = 'Kevin' AND per.last_name = 'Sos Santos Barbisa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Praia Kapital' AND t.source_system_id = 1
  AND per.first_name = 'Domingos' AND per.last_name = 'Tavares'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Praia Kapital' AND t.source_system_id = 1
  AND per.first_name = 'Edson' AND per.last_name = 'Irlandino Tavares Dossantos'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Praia Kapital' AND t.source_system_id = 1
  AND per.first_name = 'Elton' AND per.last_name = 'J Teixeira'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Project Football' AND t.source_system_id = 1
  AND per.first_name = 'Wilson' AND per.last_name = 'Omar Amaya Lara'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Project Football' AND t.source_system_id = 1
  AND per.first_name = 'Jessiel' AND per.last_name = 'Alexander Amparo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Project Football' AND t.source_system_id = 1
  AND per.first_name = 'Minor' AND per.last_name = 'Ojanny Angel Merida'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Project Football' AND t.source_system_id = 1
  AND per.first_name = 'Yaw' AND per.last_name = 'Bediako'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Project Football' AND t.source_system_id = 1
  AND per.first_name = 'Elvino' AND per.last_name = 'Tavares Da Silva'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Project Football' AND t.source_system_id = 1
  AND per.first_name = 'Delvino' AND per.last_name = 'Tavares Dasilva'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Project Football' AND t.source_system_id = 1
  AND per.first_name = 'Jamel' AND per.last_name = 'Anch David'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Project Football' AND t.source_system_id = 1
  AND per.first_name = 'Henry' AND per.last_name = 'Edeko'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Project Football' AND t.source_system_id = 1
  AND per.first_name = 'Ayoub' AND per.last_name = 'Essaoui'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Project Football' AND t.source_system_id = 1
  AND per.first_name = 'Jackson' AND per.last_name = 'Fernandes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Project Football' AND t.source_system_id = 1
  AND per.first_name = 'Carlos' AND per.last_name = 'Augusto Gomez Hernandez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Project Football' AND t.source_system_id = 1
  AND per.first_name = 'Braulio' AND per.last_name = 'Gonzalez Oliveria'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Project Football' AND t.source_system_id = 1
  AND per.first_name = 'Alejandro' AND per.last_name = 'Alfonso Guerrero Vargas'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Project Football' AND t.source_system_id = 1
  AND per.first_name = 'Kenneth' AND per.last_name = 'Jared Ibarra Suarez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Project Football' AND t.source_system_id = 1
  AND per.first_name = 'Aeshan' AND per.last_name = 'Kapil'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Project Football' AND t.source_system_id = 1
  AND per.first_name = 'Jesus' AND per.last_name = 'Gilberto Martinez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Project Football' AND t.source_system_id = 1
  AND per.first_name = 'Ricosta' AND per.last_name = 'Mede'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Project Football' AND t.source_system_id = 1
  AND per.first_name = 'Sheventz' AND per.last_name = 'Multy'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Project Football' AND t.source_system_id = 1
  AND per.first_name = 'Samuel' AND per.last_name = 'Armando Perez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Project Football' AND t.source_system_id = 1
  AND per.first_name = 'Aiden' AND per.last_name = 'Thor Perry'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Project Football' AND t.source_system_id = 1
  AND per.first_name = 'Alex' AND per.last_name = 'Andrade Pina'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Project Football' AND t.source_system_id = 1
  AND per.first_name = 'Connor' AND per.last_name = 'Poliquin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Project Football' AND t.source_system_id = 1
  AND per.first_name = 'Timothy' AND per.last_name = 'Singleton'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Project Football' AND t.source_system_id = 1
  AND per.first_name = 'Francisco' AND per.last_name = 'Aron Villacorta'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Project Football' AND t.source_system_id = 1
  AND per.first_name = 'Benjamin' AND per.last_name = 'Watts'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PW Nova' AND t.source_system_id = 1
  AND per.first_name = 'David' AND per.last_name = 'Alverez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PW Nova' AND t.source_system_id = 1
  AND per.first_name = 'Carlos' AND per.last_name = 'Amador'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PW Nova' AND t.source_system_id = 1
  AND per.first_name = 'Chris' AND per.last_name = 'Avila'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PW Nova' AND t.source_system_id = 1
  AND per.first_name = 'Yaseen' AND per.last_name = 'Ben Chouikha'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PW Nova' AND t.source_system_id = 1
  AND per.first_name = 'Amir' AND per.last_name = 'Bentaleb'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PW Nova' AND t.source_system_id = 1
  AND per.first_name = 'Angel' AND per.last_name = 'Viera Castro'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PW Nova' AND t.source_system_id = 1
  AND per.first_name = 'Jesse' AND per.last_name = 'Conteh'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PW Nova' AND t.source_system_id = 1
  AND per.first_name = 'Gio' AND per.last_name = 'Cruz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PW Nova' AND t.source_system_id = 1
  AND per.first_name = 'German' AND per.last_name = 'Del Cid'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PW Nova' AND t.source_system_id = 1
  AND per.first_name = 'Mohammed' AND per.last_name = 'Ahmed Elsir'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PW Nova' AND t.source_system_id = 1
  AND per.first_name = 'Collins' AND per.last_name = 'Frimpong'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PW Nova' AND t.source_system_id = 1
  AND per.first_name = 'Roy' AND per.last_name = 'Alex Galeano'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PW Nova' AND t.source_system_id = 1
  AND per.first_name = 'Oscar' AND per.last_name = 'Garcia'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PW Nova' AND t.source_system_id = 1
  AND per.first_name = 'Sam' AND per.last_name = 'Garcia'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PW Nova' AND t.source_system_id = 1
  AND per.first_name = 'Anthony' AND per.last_name = 'Juarez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PW Nova' AND t.source_system_id = 1
  AND per.first_name = 'Kwasi' AND per.last_name = 'Kotoko'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PW Nova' AND t.source_system_id = 1
  AND per.first_name = 'Orlando' AND per.last_name = 'Martinez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PW Nova' AND t.source_system_id = 1
  AND per.first_name = 'Andrew' AND per.last_name = 'Mejia'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PW Nova' AND t.source_system_id = 1
  AND per.first_name = 'Chris' AND per.last_name = 'Mejia'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PW Nova' AND t.source_system_id = 1
  AND per.first_name = 'Milton' AND per.last_name = 'Miranda'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PW Nova' AND t.source_system_id = 1
  AND per.first_name = 'Nasrullah' AND per.last_name = 'Muhammed'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PW Nova' AND t.source_system_id = 1
  AND per.first_name = 'Alexis' AND per.last_name = 'Palma'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PW Nova' AND t.source_system_id = 1
  AND per.first_name = 'Luis' AND per.last_name = 'Reyes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PW Nova' AND t.source_system_id = 1
  AND per.first_name = 'Romel' AND per.last_name = 'Reyes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PW Nova' AND t.source_system_id = 1
  AND per.first_name = 'Jason' AND per.last_name = 'Rodriguez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PW Nova' AND t.source_system_id = 1
  AND per.first_name = 'Elias' AND per.last_name = 'San Juan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PW Nova' AND t.source_system_id = 1
  AND per.first_name = 'Ricardo' AND per.last_name = 'Vega'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'PW Nova' AND t.source_system_id = 1
  AND per.first_name = 'Raul' AND per.last_name = 'Villalta'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Real Central NJ Soccer' AND t.source_system_id = 1
  AND per.first_name = 'Djibi' AND per.last_name = 'Tata Bah'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Real Central NJ Soccer' AND t.source_system_id = 1
  AND per.first_name = 'James' AND per.last_name = 'Bernstein'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Real Central NJ Soccer' AND t.source_system_id = 1
  AND per.first_name = 'Pierre' AND per.last_name = 'Bosquet'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Real Central NJ Soccer' AND t.source_system_id = 1
  AND per.first_name = 'Erik' AND per.last_name = 'Carchipulla'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Real Central NJ Soccer' AND t.source_system_id = 1
  AND per.first_name = 'Filippo' AND per.last_name = 'D''Anna'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Real Central NJ Soccer' AND t.source_system_id = 1
  AND per.first_name = 'Jonathan' AND per.last_name = 'Firmino'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Real Central NJ Soccer' AND t.source_system_id = 1
  AND per.first_name = 'Jose' AND per.last_name = '(Tony) Flores'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Real Central NJ Soccer' AND t.source_system_id = 1
  AND per.first_name = 'Liam' AND per.last_name = 'Fredericks'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Real Central NJ Soccer' AND t.source_system_id = 1
  AND per.first_name = 'Eric' AND per.last_name = 'Goldberg'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Real Central NJ Soccer' AND t.source_system_id = 1
  AND per.first_name = 'Taeus' AND per.last_name = 'Jones'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Real Central NJ Soccer' AND t.source_system_id = 1
  AND per.first_name = 'Brendan' AND per.last_name = 'Kerins'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Real Central NJ Soccer' AND t.source_system_id = 1
  AND per.first_name = 'Sean' AND per.last_name = 'Ryan Milelli'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Real Central NJ Soccer' AND t.source_system_id = 1
  AND per.first_name = 'Conlan' AND per.last_name = 'Michael Paventi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Real Central NJ Soccer' AND t.source_system_id = 1
  AND per.first_name = 'Kevin' AND per.last_name = 'Perez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Real Central NJ Soccer' AND t.source_system_id = 1
  AND per.first_name = 'Giovanni' AND per.last_name = 'Pierleonardi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Real Central NJ Soccer' AND t.source_system_id = 1
  AND per.first_name = 'Giuseppe' AND per.last_name = 'Pierleonardi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Real Central NJ Soccer' AND t.source_system_id = 1
  AND per.first_name = 'Guiliano' AND per.last_name = 'Pierleonardi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Real Central NJ Soccer' AND t.source_system_id = 1
  AND per.first_name = 'Vincenzo' AND per.last_name = 'Pugliese'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Real Central NJ Soccer' AND t.source_system_id = 1
  AND per.first_name = 'Joel' AND per.last_name = 'Quist'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Real Central NJ Soccer' AND t.source_system_id = 1
  AND per.first_name = 'Dennis' AND per.last_name = 'Rooney'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Real Central NJ Soccer' AND t.source_system_id = 1
  AND per.first_name = 'Ilia' AND per.last_name = 'Sakheishvili'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Real Central NJ Soccer' AND t.source_system_id = 1
  AND per.first_name = 'Cole' AND per.last_name = 'Sotack'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Real Central NJ Soccer' AND t.source_system_id = 1
  AND per.first_name = 'Reed' AND per.last_name = 'Sviben'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Real Central NJ Soccer' AND t.source_system_id = 1
  AND per.first_name = 'Brandon' AND per.last_name = 'D Valeri'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Real Central NJ Soccer' AND t.source_system_id = 1
  AND per.first_name = 'Ronald' AND per.last_name = 'Ventura'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 1
  AND per.first_name = 'Hermes' AND per.last_name = 'Ademovi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 1
  AND per.first_name = 'Mamadou' AND per.last_name = 'Bah'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 1
  AND per.first_name = 'Bljedi' AND per.last_name = 'Bardic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 1
  AND per.first_name = 'Giuseppe' AND per.last_name = 'Barone'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 1
  AND per.first_name = 'Salvatore' AND per.last_name = 'Barone'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 1
  AND per.first_name = 'Kemal' AND per.last_name = 'Brkanovic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 1
  AND per.first_name = 'Cesare' AND per.last_name = 'Cali'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 1
  AND per.first_name = 'Keithlend' AND per.last_name = 'Cesar'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 1
  AND per.first_name = 'Kyaire' AND per.last_name = 'Clarke'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 1
  AND per.first_name = 'Luis' AND per.last_name = 'Cueva'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 1
  AND per.first_name = 'Bradley' AND per.last_name = 'Espejo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 1
  AND per.first_name = 'Roberto' AND per.last_name = 'Gioffre'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 1
  AND per.first_name = 'Pietro' AND per.last_name = 'Giove'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 1
  AND per.first_name = 'Christopher' AND per.last_name = 'Gjini'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 1
  AND per.first_name = 'Peter' AND per.last_name = 'Gjini'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 1
  AND per.first_name = 'Armando' AND per.last_name = 'Guarnera'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 1
  AND per.first_name = 'James' AND per.last_name = 'Haddad'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 1
  AND per.first_name = 'Yassin' AND per.last_name = 'Hairane'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 1
  AND per.first_name = 'Amir' AND per.last_name = 'Islami'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 1
  AND per.first_name = 'Timothy' AND per.last_name = 'Francis Kane'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 1
  AND per.first_name = 'Brian' AND per.last_name = 'Kerliu'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 1
  AND per.first_name = 'Peterson' AND per.last_name = 'Larose'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 1
  AND per.first_name = 'Dylan' AND per.last_name = 'Meadows'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 1
  AND per.first_name = 'Gerald' AND per.last_name = 'Mehja'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 1
  AND per.first_name = 'Michael' AND per.last_name = 'Mollica'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 1
  AND per.first_name = 'Anthony' AND per.last_name = 'Oliveira'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 1
  AND per.first_name = 'Cristiano' AND per.last_name = 'Oliveira'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 1
  AND per.first_name = 'Andrea' AND per.last_name = 'Ruggiero'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 1
  AND per.first_name = 'Leutrim' AND per.last_name = 'Saiti'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 1
  AND per.first_name = 'Valeriy' AND per.last_name = 'Saramoutin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 1
  AND per.first_name = 'Mark' AND per.last_name = 'Shnadshteyn'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 1
  AND per.first_name = 'Demyan' AND per.last_name = 'Turiy'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 1
  AND per.first_name = 'Dominik' AND per.last_name = 'Urban'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 1
  AND per.first_name = 'Bryant' AND per.last_name = 'Vidals'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Richmond County FC' AND t.source_system_id = 1
  AND per.first_name = 'Dani' AND per.last_name = 'Villa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Vistula Garfield' AND t.source_system_id = 1
  AND per.first_name = 'Johannes' AND per.last_name = 'Alvarez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Vistula Garfield' AND t.source_system_id = 1
  AND per.first_name = 'Jason' AND per.last_name = 'Alves'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Vistula Garfield' AND t.source_system_id = 1
  AND per.first_name = 'Christopher' AND per.last_name = 'Barnas'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Vistula Garfield' AND t.source_system_id = 1
  AND per.first_name = 'Sebastian' AND per.last_name = 'Capozucchi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Vistula Garfield' AND t.source_system_id = 1
  AND per.first_name = 'Roberto' AND per.last_name = 'Chernez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Vistula Garfield' AND t.source_system_id = 1
  AND per.first_name = 'Gabriel' AND per.last_name = 'Costa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Vistula Garfield' AND t.source_system_id = 1
  AND per.first_name = 'Keijon' AND per.last_name = 'Davis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Vistula Garfield' AND t.source_system_id = 1
  AND per.first_name = 'Shaunavon' AND per.last_name = 'DeSouza'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Vistula Garfield' AND t.source_system_id = 1
  AND per.first_name = 'Gabriel' AND per.last_name = 'DiPierro'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Vistula Garfield' AND t.source_system_id = 1
  AND per.first_name = 'Emiland' AND per.last_name = 'Elezaj'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Vistula Garfield' AND t.source_system_id = 1
  AND per.first_name = 'Andres' AND per.last_name = 'Gonzalez-Rios'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Vistula Garfield' AND t.source_system_id = 1
  AND per.first_name = 'Jonathan' AND per.last_name = 'Gutierrez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Vistula Garfield' AND t.source_system_id = 1
  AND per.first_name = 'Oscar' AND per.last_name = 'Horwitz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Vistula Garfield' AND t.source_system_id = 1
  AND per.first_name = 'Jashar' AND per.last_name = 'Jashar'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Vistula Garfield' AND t.source_system_id = 1
  AND per.first_name = 'Christopher' AND per.last_name = 'Karcz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Vistula Garfield' AND t.source_system_id = 1
  AND per.first_name = 'Wiktor' AND per.last_name = 'Kiszkiel'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Vistula Garfield' AND t.source_system_id = 1
  AND per.first_name = 'Christopher' AND per.last_name = 'Kondratowicz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Vistula Garfield' AND t.source_system_id = 1
  AND per.first_name = 'Paul' AND per.last_name = 'Kondratowicz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Vistula Garfield' AND t.source_system_id = 1
  AND per.first_name = 'Nicholas' AND per.last_name = 'Kozdron'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Vistula Garfield' AND t.source_system_id = 1
  AND per.first_name = 'Sebastian' AND per.last_name = 'Lapczynski'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Vistula Garfield' AND t.source_system_id = 1
  AND per.first_name = 'John' AND per.last_name = 'McGeechan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Vistula Garfield' AND t.source_system_id = 1
  AND per.first_name = 'Mark' AND per.last_name = 'Mikanik'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Vistula Garfield' AND t.source_system_id = 1
  AND per.first_name = 'Aldo' AND per.last_name = 'Munoz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Vistula Garfield' AND t.source_system_id = 1
  AND per.first_name = 'Cyrus' AND per.last_name = 'Nasseri'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Vistula Garfield' AND t.source_system_id = 1
  AND per.first_name = 'Krystian' AND per.last_name = 'Nitek'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Vistula Garfield' AND t.source_system_id = 1
  AND per.first_name = 'Viktor' AND per.last_name = 'Pervushkin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Vistula Garfield' AND t.source_system_id = 1
  AND per.first_name = 'Tyler' AND per.last_name = 'Pinho'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Vistula Garfield' AND t.source_system_id = 1
  AND per.first_name = 'Alvaro' AND per.last_name = 'Rodriguez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Vistula Garfield' AND t.source_system_id = 1
  AND per.first_name = 'Daniel' AND per.last_name = 'Sawicki'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Vistula Garfield' AND t.source_system_id = 1
  AND per.first_name = 'Gabriel' AND per.last_name = 'Serafin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Vistula Garfield' AND t.source_system_id = 1
  AND per.first_name = 'William' AND per.last_name = 'Tomlinson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Vistula Garfield' AND t.source_system_id = 1
  AND per.first_name = 'Igor' AND per.last_name = 'Trajceski'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Vistula Garfield' AND t.source_system_id = 1
  AND per.first_name = 'Kevin' AND per.last_name = 'Valdivia'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Coast Union' AND t.source_system_id = 1
  AND per.first_name = 'Daniel' AND per.last_name = 'Andrade'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Coast Union' AND t.source_system_id = 1
  AND per.first_name = 'Edmilson' AND per.last_name = 'Andrade'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Coast Union' AND t.source_system_id = 1
  AND per.first_name = 'Damian' AND per.last_name = 'Anerdson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Coast Union' AND t.source_system_id = 1
  AND per.first_name = 'Ronis' AND per.last_name = 'Ayala'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Coast Union' AND t.source_system_id = 1
  AND per.first_name = 'Dominique' AND per.last_name = 'Baessa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Coast Union' AND t.source_system_id = 1
  AND per.first_name = 'Gio' AND per.last_name = 'Barros'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Coast Union' AND t.source_system_id = 1
  AND per.first_name = 'Justin' AND per.last_name = 'Barros'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Coast Union' AND t.source_system_id = 1
  AND per.first_name = 'Dominek' AND per.last_name = 'Borden'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Coast Union' AND t.source_system_id = 1
  AND per.first_name = 'Edemilson' AND per.last_name = 'Candida'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Coast Union' AND t.source_system_id = 1
  AND per.first_name = 'Kevin' AND per.last_name = 'Correia'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Coast Union' AND t.source_system_id = 1
  AND per.first_name = 'Neil' AND per.last_name = 'Cunha'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Coast Union' AND t.source_system_id = 1
  AND per.first_name = 'Mason' AND per.last_name = 'Dealmeida'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Coast Union' AND t.source_system_id = 1
  AND per.first_name = 'Clayton' AND per.last_name = 'Demelo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Coast Union' AND t.source_system_id = 1
  AND per.first_name = 'Ethan' AND per.last_name = 'Demelo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Coast Union' AND t.source_system_id = 1
  AND per.first_name = 'Dawson' AND per.last_name = 'Dosvais'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Coast Union' AND t.source_system_id = 1
  AND per.first_name = 'Zajdele' AND per.last_name = 'Dulcine'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Coast Union' AND t.source_system_id = 1
  AND per.first_name = 'Augustin' AND per.last_name = 'Edwin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Coast Union' AND t.source_system_id = 1
  AND per.first_name = 'Austin' AND per.last_name = 'Eugenio'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Coast Union' AND t.source_system_id = 1
  AND per.first_name = 'Malaquias' AND per.last_name = 'Tavares Garcia'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Coast Union' AND t.source_system_id = 1
  AND per.first_name = 'Michael' AND per.last_name = 'Garcia'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Coast Union' AND t.source_system_id = 1
  AND per.first_name = 'Damon' AND per.last_name = 'Greene'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Coast Union' AND t.source_system_id = 1
  AND per.first_name = 'Ricardo' AND per.last_name = 'Macedo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Coast Union' AND t.source_system_id = 1
  AND per.first_name = 'Sam' AND per.last_name = 'Matias'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Coast Union' AND t.source_system_id = 1
  AND per.first_name = 'Dylan' AND per.last_name = 'Mendes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Coast Union' AND t.source_system_id = 1
  AND per.first_name = 'Jose' AND per.last_name = 'Carlos "Ze" Mendes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Coast Union' AND t.source_system_id = 1
  AND per.first_name = 'Ethan' AND per.last_name = 'Paiva'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Coast Union' AND t.source_system_id = 1
  AND per.first_name = 'Joey' AND per.last_name = 'Paiva'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Coast Union' AND t.source_system_id = 1
  AND per.first_name = 'Colin' AND per.last_name = 'Pereira'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Coast Union' AND t.source_system_id = 1
  AND per.first_name = 'Jacob' AND per.last_name = 'Ramos'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Coast Union' AND t.source_system_id = 1
  AND per.first_name = 'Rafael' AND per.last_name = 'Raposo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Coast Union' AND t.source_system_id = 1
  AND per.first_name = 'Dylan' AND per.last_name = 'Senra'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Coast Union' AND t.source_system_id = 1
  AND per.first_name = 'Flavio' AND per.last_name = 'Joel Soares Carvalho'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'South Coast Union' AND t.source_system_id = 1
  AND per.first_name = 'Christian' AND per.last_name = 'Sousa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'VA Marauders FC' AND t.source_system_id = 1
  AND per.first_name = 'Mohamed' AND per.last_name = 'Abdelrehman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'VA Marauders FC' AND t.source_system_id = 1
  AND per.first_name = 'Nyliek' AND per.last_name = 'Allen'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'VA Marauders FC' AND t.source_system_id = 1
  AND per.first_name = 'Jared' AND per.last_name = 'Benedict'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'VA Marauders FC' AND t.source_system_id = 1
  AND per.first_name = 'David' AND per.last_name = 'Bernal-Clark'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'VA Marauders FC' AND t.source_system_id = 1
  AND per.first_name = 'Alex' AND per.last_name = 'Bilski'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'VA Marauders FC' AND t.source_system_id = 1
  AND per.first_name = 'Nicholas' AND per.last_name = 'Blake'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'VA Marauders FC' AND t.source_system_id = 1
  AND per.first_name = 'Edwardo' AND per.last_name = 'Chavez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'VA Marauders FC' AND t.source_system_id = 1
  AND per.first_name = 'Charles' AND per.last_name = 'Evangelos'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'VA Marauders FC' AND t.source_system_id = 1
  AND per.first_name = 'Jessi' AND per.last_name = 'e Garcia'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'VA Marauders FC' AND t.source_system_id = 1
  AND per.first_name = 'Daniel' AND per.last_name = 'Gonzalez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'VA Marauders FC' AND t.source_system_id = 1
  AND per.first_name = 'Sayed' AND per.last_name = 'Hashemi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'VA Marauders FC' AND t.source_system_id = 1
  AND per.first_name = 'Sayed' AND per.last_name = 'Hashemi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'VA Marauders FC' AND t.source_system_id = 1
  AND per.first_name = 'Vasilios' AND per.last_name = 'Kazakos'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'VA Marauders FC' AND t.source_system_id = 1
  AND per.first_name = 'Alejandro' AND per.last_name = 'Lenz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'VA Marauders FC' AND t.source_system_id = 1
  AND per.first_name = 'Josaphat' AND per.last_name = 'Letona'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'VA Marauders FC' AND t.source_system_id = 1
  AND per.first_name = 'Braden' AND per.last_name = 'Lopez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'VA Marauders FC' AND t.source_system_id = 1
  AND per.first_name = 'Gabriel' AND per.last_name = 'Maguire'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'VA Marauders FC' AND t.source_system_id = 1
  AND per.first_name = 'Moussa' AND per.last_name = 'Mahama'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'VA Marauders FC' AND t.source_system_id = 1
  AND per.first_name = 'Louis' AND per.last_name = 'Manyele'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'VA Marauders FC' AND t.source_system_id = 1
  AND per.first_name = 'Carlos' AND per.last_name = 'Mareno'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'VA Marauders FC' AND t.source_system_id = 1
  AND per.first_name = 'George' AND per.last_name = 'Mavronis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'VA Marauders FC' AND t.source_system_id = 1
  AND per.first_name = 'Michael' AND per.last_name = 'Medina'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'VA Marauders FC' AND t.source_system_id = 1
  AND per.first_name = 'Roman' AND per.last_name = 'Milian'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'VA Marauders FC' AND t.source_system_id = 1
  AND per.first_name = 'Johnny' AND per.last_name = 'Paletar'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'VA Marauders FC' AND t.source_system_id = 1
  AND per.first_name = 'Danish' AND per.last_name = 'Saeedi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'VA Marauders FC' AND t.source_system_id = 1
  AND per.first_name = 'Jordon' AND per.last_name = 'Salvi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'VA Marauders FC' AND t.source_system_id = 1
  AND per.first_name = 'Leonel' AND per.last_name = 'Sanchez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'VA Marauders FC' AND t.source_system_id = 1
  AND per.first_name = 'Selim' AND per.last_name = 'Senel'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'VA Marauders FC' AND t.source_system_id = 1
  AND per.first_name = 'Ahmadi' AND per.last_name = 'Shayan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'VA Marauders FC' AND t.source_system_id = 1
  AND per.first_name = 'Akimanzi' AND per.last_name = 'Siibo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'VA Marauders FC' AND t.source_system_id = 1
  AND per.first_name = 'Alex' AND per.last_name = 'Sosa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'VA Marauders FC' AND t.source_system_id = 1
  AND per.first_name = 'Viktor' AND per.last_name = 'Tachev'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'VA Marauders FC' AND t.source_system_id = 1
  AND per.first_name = 'Matthew' AND per.last_name = 'Zelaya'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'VA Marauders FC' AND t.source_system_id = 1
  AND per.first_name = 'Nebeyo' AND per.last_name = 'Zerihun'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'VA Marauders FC' AND t.source_system_id = 1
  AND per.first_name = 'Ossy' AND per.last_name = 'Zubiria'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vidas United FC' AND t.source_system_id = 1
  AND per.first_name = 'Emani' AND per.last_name = 'Arroyo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vidas United FC' AND t.source_system_id = 1
  AND per.first_name = 'Nolan' AND per.last_name = 'Bair'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vidas United FC' AND t.source_system_id = 1
  AND per.first_name = 'Almuthenna' AND per.last_name = 'Hseen Baled'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vidas United FC' AND t.source_system_id = 1
  AND per.first_name = 'Richard' AND per.last_name = 'Blanchard'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vidas United FC' AND t.source_system_id = 1
  AND per.first_name = 'Bakuri' AND per.last_name = 'Buadze'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vidas United FC' AND t.source_system_id = 1
  AND per.first_name = 'Maximo' AND per.last_name = 'Chavez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vidas United FC' AND t.source_system_id = 1
  AND per.first_name = 'Evan' AND per.last_name = 'Chinwendu Azoro'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vidas United FC' AND t.source_system_id = 1
  AND per.first_name = 'Adan' AND per.last_name = 'Crispin-Morales'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vidas United FC' AND t.source_system_id = 1
  AND per.first_name = 'Jorge' AND per.last_name = 'Luis Diaz Lobo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vidas United FC' AND t.source_system_id = 1
  AND per.first_name = 'Spencer' AND per.last_name = 'Dickinson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vidas United FC' AND t.source_system_id = 1
  AND per.first_name = 'Isaiah' AND per.last_name = 'Fox'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vidas United FC' AND t.source_system_id = 1
  AND per.first_name = 'Goga' AND per.last_name = 'Gogoladze'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vidas United FC' AND t.source_system_id = 1
  AND per.first_name = 'Stephen' AND per.last_name = 'Grazioli'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vidas United FC' AND t.source_system_id = 1
  AND per.first_name = 'Mohamed' AND per.last_name = 'Ibrahim'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vidas United FC' AND t.source_system_id = 1
  AND per.first_name = 'Matthew' AND per.last_name = 'JeanPierre'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vidas United FC' AND t.source_system_id = 1
  AND per.first_name = 'Mohammadzain' AND per.last_name = 'Kazi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vidas United FC' AND t.source_system_id = 1
  AND per.first_name = 'Guilherme' AND per.last_name = 'Martins'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vidas United FC' AND t.source_system_id = 1
  AND per.first_name = 'John' AND per.last_name = 'Miller'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vidas United FC' AND t.source_system_id = 1
  AND per.first_name = 'Edwin' AND per.last_name = 'Owusu Siaw'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vidas United FC' AND t.source_system_id = 1
  AND per.first_name = 'Juan' AND per.last_name = 'Polanco'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vidas United FC' AND t.source_system_id = 1
  AND per.first_name = 'Angel' AND per.last_name = 'Javier Rodriguez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vidas United FC' AND t.source_system_id = 1
  AND per.first_name = 'Ahmed' AND per.last_name = 'Saedahmed'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vidas United FC' AND t.source_system_id = 1
  AND per.first_name = 'Edi' AND per.last_name = 'Schwartz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vidas United FC' AND t.source_system_id = 1
  AND per.first_name = 'Maksym' AND per.last_name = 'Shevchenko'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vidas United FC' AND t.source_system_id = 1
  AND per.first_name = 'Alexander' AND per.last_name = 'Simon'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vidas United FC' AND t.source_system_id = 1
  AND per.first_name = 'Daniel' AND per.last_name = 'Smith'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vidas United FC' AND t.source_system_id = 1
  AND per.first_name = 'Christian' AND per.last_name = 'Sorteberg'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vidas United FC' AND t.source_system_id = 1
  AND per.first_name = 'Sekou' AND per.last_name = 'Sylla'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Vidas United FC' AND t.source_system_id = 1
  AND per.first_name = 'Abraham' AND per.last_name = 'Waldman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wave FC' AND t.source_system_id = 1
  AND per.first_name = 'Kelechi' AND per.last_name = 'Akujuobi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wave FC' AND t.source_system_id = 1
  AND per.first_name = 'Faisal' AND per.last_name = 'Alay'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wave FC' AND t.source_system_id = 1
  AND per.first_name = 'Victorine' AND per.last_name = 'Kwame Appohsam'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wave FC' AND t.source_system_id = 1
  AND per.first_name = 'Hector' AND per.last_name = 'Avila Hernandez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wave FC' AND t.source_system_id = 1
  AND per.first_name = 'Eduardo' AND per.last_name = 'G Barria'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wave FC' AND t.source_system_id = 1
  AND per.first_name = 'Zavier' AND per.last_name = 'Bell'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wave FC' AND t.source_system_id = 1
  AND per.first_name = 'Zach' AND per.last_name = 'Boyd'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wave FC' AND t.source_system_id = 1
  AND per.first_name = 'Julio' AND per.last_name = 'Bravo-Guzman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wave FC' AND t.source_system_id = 1
  AND per.first_name = 'Deontae' AND per.last_name = 'Campbell'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wave FC' AND t.source_system_id = 1
  AND per.first_name = 'Brandon' AND per.last_name = 'Chambers'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wave FC' AND t.source_system_id = 1
  AND per.first_name = 'Aiden' AND per.last_name = 'Chen'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wave FC' AND t.source_system_id = 1
  AND per.first_name = 'Marckensley' AND per.last_name = 'Constant'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wave FC' AND t.source_system_id = 1
  AND per.first_name = 'Tim' AND per.last_name = 'Cooley'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wave FC' AND t.source_system_id = 1
  AND per.first_name = 'Christian' AND per.last_name = 'Cruz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wave FC' AND t.source_system_id = 1
  AND per.first_name = 'Danilo' AND per.last_name = 'Duric'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wave FC' AND t.source_system_id = 1
  AND per.first_name = 'Logan' AND per.last_name = 'Flanagan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wave FC' AND t.source_system_id = 1
  AND per.first_name = 'Colin' AND per.last_name = 'Foley'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wave FC' AND t.source_system_id = 1
  AND per.first_name = 'Nathan' AND per.last_name = 'Gichuhi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wave FC' AND t.source_system_id = 1
  AND per.first_name = 'Jeremy' AND per.last_name = 'Gonzalez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wave FC' AND t.source_system_id = 1
  AND per.first_name = 'Josh' AND per.last_name = 'Gutierrez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wave FC' AND t.source_system_id = 1
  AND per.first_name = 'Jonah' AND per.last_name = 'Harvey'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wave FC' AND t.source_system_id = 1
  AND per.first_name = 'Josh' AND per.last_name = 'Haynie'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wave FC' AND t.source_system_id = 1
  AND per.first_name = 'Mitchell' AND per.last_name = 'Hopkins'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wave FC' AND t.source_system_id = 1
  AND per.first_name = 'Tanner' AND per.last_name = 'Johnston'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wave FC' AND t.source_system_id = 1
  AND per.first_name = 'David' AND per.last_name = 'Miller'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wave FC' AND t.source_system_id = 1
  AND per.first_name = 'Abdul' AND per.last_name = 'Mokhtar'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wave FC' AND t.source_system_id = 1
  AND per.first_name = 'Bijan' AND per.last_name = 'Morshedi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wave FC' AND t.source_system_id = 1
  AND per.first_name = 'Ander' AND per.last_name = 'Ochoa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wave FC' AND t.source_system_id = 1
  AND per.first_name = 'Victor' AND per.last_name = 'Oladeinde'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wave FC' AND t.source_system_id = 1
  AND per.first_name = 'Oved' AND per.last_name = 'Ortega'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wave FC' AND t.source_system_id = 1
  AND per.first_name = 'Kameron' AND per.last_name = 'Payne'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wave FC' AND t.source_system_id = 1
  AND per.first_name = 'Jayden' AND per.last_name = 'Rodriguez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wave FC' AND t.source_system_id = 1
  AND per.first_name = 'Oumar' AND per.last_name = 'Thiandoum'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wave FC' AND t.source_system_id = 1
  AND per.first_name = 'Ronju' AND per.last_name = 'Walters'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'WC Predators' AND t.source_system_id = 1
  AND per.first_name = 'Brahim' AND per.last_name = 'Hadj Abboud'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'WC Predators' AND t.source_system_id = 1
  AND per.first_name = 'Tomas' AND per.last_name = 'Ascoli'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'WC Predators' AND t.source_system_id = 1
  AND per.first_name = 'August' AND per.last_name = 'Axtman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'WC Predators' AND t.source_system_id = 1
  AND per.first_name = 'Edwin' AND per.last_name = 'Bedolla'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'WC Predators' AND t.source_system_id = 1
  AND per.first_name = 'Noah' AND per.last_name = 'Sutton Beltran'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'WC Predators' AND t.source_system_id = 1
  AND per.first_name = 'Ammit' AND per.last_name = 'Bhogal'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'WC Predators' AND t.source_system_id = 1
  AND per.first_name = 'John' AND per.last_name = 'Bonas'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'WC Predators' AND t.source_system_id = 1
  AND per.first_name = 'Marcus' AND per.last_name = 'Brenes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'WC Predators' AND t.source_system_id = 1
  AND per.first_name = 'Carter' AND per.last_name = 'Burris'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'WC Predators' AND t.source_system_id = 1
  AND per.first_name = 'Colin' AND per.last_name = 'Forster Davis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'WC Predators' AND t.source_system_id = 1
  AND per.first_name = 'Alex' AND per.last_name = 'Demars'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'WC Predators' AND t.source_system_id = 1
  AND per.first_name = 'Oliver' AND per.last_name = 'Garcia'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'WC Predators' AND t.source_system_id = 1
  AND per.first_name = 'Michael' AND per.last_name = 'Gonzalez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'WC Predators' AND t.source_system_id = 1
  AND per.first_name = 'Emmanuel' AND per.last_name = 'Hewitt'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'WC Predators' AND t.source_system_id = 1
  AND per.first_name = 'Luke' AND per.last_name = 'Hill'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'WC Predators' AND t.source_system_id = 1
  AND per.first_name = 'Jack' AND per.last_name = 'Jasinski'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'WC Predators' AND t.source_system_id = 1
  AND per.first_name = 'Dylan' AND per.last_name = 'Leonid Lacy'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'WC Predators' AND t.source_system_id = 1
  AND per.first_name = 'Joel' AND per.last_name = 'Lopez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'WC Predators' AND t.source_system_id = 1
  AND per.first_name = 'Dominick' AND per.last_name = 'Martinez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'WC Predators' AND t.source_system_id = 1
  AND per.first_name = 'Brian' AND per.last_name = 'McDaid'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'WC Predators' AND t.source_system_id = 1
  AND per.first_name = 'Luca' AND per.last_name = 'Mellor'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'WC Predators' AND t.source_system_id = 1
  AND per.first_name = 'Mason' AND per.last_name = 'Miller'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'WC Predators' AND t.source_system_id = 1
  AND per.first_name = 'Ayoub' AND per.last_name = 'Mouhou'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'WC Predators' AND t.source_system_id = 1
  AND per.first_name = 'Riley' AND per.last_name = 'Porter'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'WC Predators' AND t.source_system_id = 1
  AND per.first_name = 'Luke' AND per.last_name = 'Pressler'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'WC Predators' AND t.source_system_id = 1
  AND per.first_name = 'Ridge' AND per.last_name = 'Robinson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'WC Predators' AND t.source_system_id = 1
  AND per.first_name = 'Miguel' AND per.last_name = 'Ross'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'WC Predators' AND t.source_system_id = 1
  AND per.first_name = 'Maximos' AND per.last_name = 'Sacarellos'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'WC Predators' AND t.source_system_id = 1
  AND per.first_name = 'Justin' AND per.last_name = 'Thomas'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'WC Predators' AND t.source_system_id = 1
  AND per.first_name = 'Luke' AND per.last_name = 'Thomas'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'WC Predators' AND t.source_system_id = 1
  AND per.first_name = 'Sama' AND per.last_name = 'Tima'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'WC Predators' AND t.source_system_id = 1
  AND per.first_name = 'Kyle' AND per.last_name = 'Tucker'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'WC Predators' AND t.source_system_id = 1
  AND per.first_name = 'Nikhil' AND per.last_name = 'Ashish Verma'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'WC Predators' AND t.source_system_id = 1
  AND per.first_name = 'Jacob' AND per.last_name = 'Weaver'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'WC Predators' AND t.source_system_id = 1
  AND per.first_name = 'Charles' AND per.last_name = 'Wilson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wildcat FC' AND t.source_system_id = 1
  AND per.first_name = 'Kaio' AND per.last_name = 'Ramos Araujo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wildcat FC' AND t.source_system_id = 1
  AND per.first_name = 'Luciano' AND per.last_name = 'Artaza'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wildcat FC' AND t.source_system_id = 1
  AND per.first_name = 'Luke' AND per.last_name = 'Bello'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wildcat FC' AND t.source_system_id = 1
  AND per.first_name = 'Marc' AND per.last_name = 'Calle'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wildcat FC' AND t.source_system_id = 1
  AND per.first_name = 'Leonardo' AND per.last_name = 'Da Graca'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wildcat FC' AND t.source_system_id = 1
  AND per.first_name = 'Ricardo' AND per.last_name = 'Dias'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wildcat FC' AND t.source_system_id = 1
  AND per.first_name = 'Matthew' AND per.last_name = 'Evora'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wildcat FC' AND t.source_system_id = 1
  AND per.first_name = 'Anthony' AND per.last_name = 'Faienza'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wildcat FC' AND t.source_system_id = 1
  AND per.first_name = 'Thomas' AND per.last_name = 'Fernandez-Wolff'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wildcat FC' AND t.source_system_id = 1
  AND per.first_name = 'Nicholas' AND per.last_name = 'Fernández-Wolff'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wildcat FC' AND t.source_system_id = 1
  AND per.first_name = 'Abdulmohaymen' AND per.last_name = 'Gadoush'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wildcat FC' AND t.source_system_id = 1
  AND per.first_name = 'Eurico' AND per.last_name = 'Gomes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wildcat FC' AND t.source_system_id = 1
  AND per.first_name = 'Javier' AND per.last_name = 'Hernandez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wildcat FC' AND t.source_system_id = 1
  AND per.first_name = 'Joni' AND per.last_name = 'Kadrioski'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wildcat FC' AND t.source_system_id = 1
  AND per.first_name = 'Chavez' AND per.last_name = 'Mbeki'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wildcat FC' AND t.source_system_id = 1
  AND per.first_name = 'Kenan' AND per.last_name = 'Mujic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wildcat FC' AND t.source_system_id = 1
  AND per.first_name = 'Ermis' AND per.last_name = 'Paguada'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wildcat FC' AND t.source_system_id = 1
  AND per.first_name = 'Paulo' AND per.last_name = 'Paris'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wildcat FC' AND t.source_system_id = 1
  AND per.first_name = 'Juan' AND per.last_name = 'Saca'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wildcat FC' AND t.source_system_id = 1
  AND per.first_name = 'Bruno' AND per.last_name = 'Silva'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wildcat FC' AND t.source_system_id = 1
  AND per.first_name = 'Matthew' AND per.last_name = 'Silva'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wildcat FC' AND t.source_system_id = 1
  AND per.first_name = 'Michel' AND per.last_name = 'Souza'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wildcat FC' AND t.source_system_id = 1
  AND per.first_name = 'Kadin' AND per.last_name = 'Talho'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wildcat FC' AND t.source_system_id = 1
  AND per.first_name = 'Diego' AND per.last_name = 'Vasquez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wildcat FC' AND t.source_system_id = 1
  AND per.first_name = 'Jannik' AND per.last_name = 'Wille'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wildcat FC' AND t.source_system_id = 1
  AND per.first_name = 'Caleb' AND per.last_name = 'Wu'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Wildcat FC' AND t.source_system_id = 1
  AND per.first_name = 'Alan' AND per.last_name = 'Xavier'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03' AND t.source_system_id = 1
  AND per.first_name = 'Richard' AND per.last_name = 'Bastian'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03' AND t.source_system_id = 1
  AND per.first_name = 'Tal' AND per.last_name = 'Benhamou'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03' AND t.source_system_id = 1
  AND per.first_name = 'Nathan' AND per.last_name = 'Bennett'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03' AND t.source_system_id = 1
  AND per.first_name = 'Jason' AND per.last_name = 'Budhai'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03' AND t.source_system_id = 1
  AND per.first_name = 'Dennis' AND per.last_name = 'Coke Jr'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03' AND t.source_system_id = 1
  AND per.first_name = 'Sully' AND per.last_name = 'Corneille'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03' AND t.source_system_id = 1
  AND per.first_name = 'Dario' AND per.last_name = 'Giovanni Cruz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03' AND t.source_system_id = 1
  AND per.first_name = 'Juan' AND per.last_name = 'Cruz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03' AND t.source_system_id = 1
  AND per.first_name = 'Tomas' AND per.last_name = 'de Andrade Gomes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03' AND t.source_system_id = 1
  AND per.first_name = 'Felix' AND per.last_name = 'Dyckerhoff'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03' AND t.source_system_id = 1
  AND per.first_name = 'Salim' AND per.last_name = 'Dziri'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03' AND t.source_system_id = 1
  AND per.first_name = 'Glenford' AND per.last_name = 'Gentle'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03' AND t.source_system_id = 1
  AND per.first_name = 'Boris' AND per.last_name = 'Grubic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03' AND t.source_system_id = 1
  AND per.first_name = 'Wisdom' AND per.last_name = 'Hountondji'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03' AND t.source_system_id = 1
  AND per.first_name = 'Tom' AND per.last_name = 'Hultsch'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03' AND t.source_system_id = 1
  AND per.first_name = 'Raphael' AND per.last_name = 'John'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03' AND t.source_system_id = 1
  AND per.first_name = 'Ryo' AND per.last_name = 'Koiso'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03' AND t.source_system_id = 1
  AND per.first_name = 'Michael' AND per.last_name = 'Laret'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03' AND t.source_system_id = 1
  AND per.first_name = 'Jason' AND per.last_name = 'Lee'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03' AND t.source_system_id = 1
  AND per.first_name = 'Cesare' AND per.last_name = 'Marconi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03' AND t.source_system_id = 1
  AND per.first_name = 'Denny' AND per.last_name = 'Morinigo-Arce'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03' AND t.source_system_id = 1
  AND per.first_name = 'Mateo' AND per.last_name = 'Munoz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03' AND t.source_system_id = 1
  AND per.first_name = 'Deniz' AND per.last_name = 'Oncu'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03' AND t.source_system_id = 1
  AND per.first_name = 'Mubarak' AND per.last_name = 'Ouro'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03' AND t.source_system_id = 1
  AND per.first_name = 'Jean' AND per.last_name = 'Carlo Perez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03' AND t.source_system_id = 1
  AND per.first_name = 'Mario' AND per.last_name = 'Ramirez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03' AND t.source_system_id = 1
  AND per.first_name = 'Paul' AND per.last_name = 'Restrepo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03' AND t.source_system_id = 1
  AND per.first_name = 'Ely' AND per.last_name = 'Schartz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03' AND t.source_system_id = 1
  AND per.first_name = 'Diego' AND per.last_name = 'Silva'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03' AND t.source_system_id = 1
  AND per.first_name = 'Tyler' AND per.last_name = 'Swaby'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Zum Schneider FC 03' AND t.source_system_id = 1
  AND per.first_name = 'Andrade' AND per.last_name = 'Wright'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Peachtree FC' AND t.source_system_id = 1
  AND per.first_name = 'Bilal' AND per.last_name = 'Ahmed'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Peachtree FC' AND t.source_system_id = 1
  AND per.first_name = 'Tim' AND per.last_name = 'Amoui'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Peachtree FC' AND t.source_system_id = 1
  AND per.first_name = 'Badr' AND per.last_name = 'El Yazami'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Peachtree FC' AND t.source_system_id = 1
  AND per.first_name = 'Stan-Lee' AND per.last_name = 'Etienne'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Peachtree FC' AND t.source_system_id = 1
  AND per.first_name = 'Sylvi' AND per.last_name = 'Mahmood'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Peachtree FC' AND t.source_system_id = 1
  AND per.first_name = 'Pedro' AND per.last_name = 'Marinho'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Peachtree FC' AND t.source_system_id = 1
  AND per.first_name = 'Juan' AND per.last_name = 'Martinez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Peachtree FC' AND t.source_system_id = 1
  AND per.first_name = 'David' AND per.last_name = 'Michaelson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Peachtree FC' AND t.source_system_id = 1
  AND per.first_name = 'Metsantika' AND per.last_name = 'Mokgoatsana'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Peachtree FC' AND t.source_system_id = 1
  AND per.first_name = 'Ali' AND per.last_name = 'Niang'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Peachtree FC' AND t.source_system_id = 1
  AND per.first_name = 'Javier' AND per.last_name = 'Pace'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Peachtree FC' AND t.source_system_id = 1
  AND per.first_name = 'Osman' AND per.last_name = 'Rodriguez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Peachtree FC' AND t.source_system_id = 1
  AND per.first_name = 'Aaron' AND per.last_name = 'Shiffman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Peachtree FC' AND t.source_system_id = 1
  AND per.first_name = 'Miwoned' AND per.last_name = 'Siraj'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Peachtree FC' AND t.source_system_id = 1
  AND per.first_name = 'Tyler' AND per.last_name = 'Swinehart'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Peachtree FC' AND t.source_system_id = 1
  AND per.first_name = 'Gabriel' AND per.last_name = 'Villar'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Peachtree FC' AND t.source_system_id = 1
  AND per.first_name = 'Michael' AND per.last_name = 'Walsh'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Peachtree FC' AND t.source_system_id = 1
  AND per.first_name = 'Joshua' AND per.last_name = 'Warde'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Peachtree FC' AND t.source_system_id = 1
  AND per.first_name = 'Christopher' AND per.last_name = 'Wilson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Peachtree FC' AND t.source_system_id = 1
  AND per.first_name = 'Kyle' AND per.last_name = 'Xhajanka'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC' AND t.source_system_id = 1
  AND per.first_name = 'Joshua' AND per.last_name = 'Adejokun'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC' AND t.source_system_id = 1
  AND per.first_name = 'Saad' AND per.last_name = 'Afif'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC' AND t.source_system_id = 1
  AND per.first_name = 'Youssef' AND per.last_name = 'Afif'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC' AND t.source_system_id = 1
  AND per.first_name = 'Osama' AND per.last_name = 'Al Sahybi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC' AND t.source_system_id = 1
  AND per.first_name = 'Eric' AND per.last_name = 'Anderson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC' AND t.source_system_id = 1
  AND per.first_name = 'Raphael' AND per.last_name = 'Carvalho'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC' AND t.source_system_id = 1
  AND per.first_name = 'Oscar' AND per.last_name = 'Champigneulle'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC' AND t.source_system_id = 1
  AND per.first_name = 'Ryan' AND per.last_name = 'Chuang'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC' AND t.source_system_id = 1
  AND per.first_name = 'Michael' AND per.last_name = 'Dempsey'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC' AND t.source_system_id = 1
  AND per.first_name = 'Byran' AND per.last_name = 'Dia'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC' AND t.source_system_id = 1
  AND per.first_name = 'Yohance' AND per.last_name = 'Douglas'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC' AND t.source_system_id = 1
  AND per.first_name = 'Jeffrey' AND per.last_name = 'Gad'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC' AND t.source_system_id = 1
  AND per.first_name = 'Jahdea' AND per.last_name = 'Gildin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC' AND t.source_system_id = 1
  AND per.first_name = 'Ross' AND per.last_name = 'Holden'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC' AND t.source_system_id = 1
  AND per.first_name = 'Hugo' AND per.last_name = 'Howard'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC' AND t.source_system_id = 1
  AND per.first_name = 'Ikrom' AND per.last_name = 'Husanov'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC' AND t.source_system_id = 1
  AND per.first_name = 'Geireann' AND per.last_name = 'Lindfield'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC' AND t.source_system_id = 1
  AND per.first_name = 'Sean' AND per.last_name = 'Molloy'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC' AND t.source_system_id = 1
  AND per.first_name = 'Shamir' AND per.last_name = 'Mullings'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC' AND t.source_system_id = 1
  AND per.first_name = 'Ridwan' AND per.last_name = 'Olawin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC' AND t.source_system_id = 1
  AND per.first_name = 'Gary' AND per.last_name = 'Philpott'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC' AND t.source_system_id = 1
  AND per.first_name = 'Sean' AND per.last_name = 'Reilly'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC' AND t.source_system_id = 1
  AND per.first_name = 'Faissal' AND per.last_name = 'Sanfo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC' AND t.source_system_id = 1
  AND per.first_name = 'Ensa' AND per.last_name = 'Sanneh'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC' AND t.source_system_id = 1
  AND per.first_name = 'Avinash' AND per.last_name = 'Singh'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC' AND t.source_system_id = 1
  AND per.first_name = 'John' AND per.last_name = 'Stevens'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC' AND t.source_system_id = 1
  AND per.first_name = 'Alexandru' AND per.last_name = 'Teodorescu'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'NY International FC' AND t.source_system_id = 1
  AND per.first_name = 'Maurice' AND per.last_name = 'Vermeulen'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Buckhead SC' AND t.source_system_id = 1
  AND per.first_name = 'Jonathan' AND per.last_name = 'Adabi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Buckhead SC' AND t.source_system_id = 1
  AND per.first_name = 'Tishe' AND per.last_name = 'Adekanmbi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Buckhead SC' AND t.source_system_id = 1
  AND per.first_name = 'Abdoulmalik' AND per.last_name = 'Adesanya'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Buckhead SC' AND t.source_system_id = 1
  AND per.first_name = 'Caleb' AND per.last_name = 'Ayan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Buckhead SC' AND t.source_system_id = 1
  AND per.first_name = 'Olumide' AND per.last_name = 'Ayo-Ajibike'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Buckhead SC' AND t.source_system_id = 1
  AND per.first_name = 'Elad' AND per.last_name = 'Khaleef Bogle'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Buckhead SC' AND t.source_system_id = 1
  AND per.first_name = 'Tobias' AND per.last_name = 'Ciho'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Buckhead SC' AND t.source_system_id = 1
  AND per.first_name = 'Nixon' AND per.last_name = 'Manuel Condolo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Buckhead SC' AND t.source_system_id = 1
  AND per.first_name = 'Felipe' AND per.last_name = 'Correa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Buckhead SC' AND t.source_system_id = 1
  AND per.first_name = 'Michael' AND per.last_name = 'Dardis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Buckhead SC' AND t.source_system_id = 1
  AND per.first_name = 'Abdoulaye' AND per.last_name = 'Diba'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Buckhead SC' AND t.source_system_id = 1
  AND per.first_name = 'Lech' AND per.last_name = 'Dunser'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Buckhead SC' AND t.source_system_id = 1
  AND per.first_name = 'Daniel' AND per.last_name = 'Duran Gonzalez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Buckhead SC' AND t.source_system_id = 1
  AND per.first_name = 'David' AND per.last_name = 'Alejandro Fierro'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Buckhead SC' AND t.source_system_id = 1
  AND per.first_name = 'Caleb' AND per.last_name = 'Johnson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Buckhead SC' AND t.source_system_id = 1
  AND per.first_name = 'Ian' AND per.last_name = 'Thomas Kunkel'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Buckhead SC' AND t.source_system_id = 1
  AND per.first_name = 'Jelle' AND per.last_name = 'Lansdaal'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Buckhead SC' AND t.source_system_id = 1
  AND per.first_name = 'Ruari' AND per.last_name = 'Eamonn O’Rourke'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Buckhead SC' AND t.source_system_id = 1
  AND per.first_name = 'Siddharth' AND per.last_name = 'Rajesh'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Buckhead SC' AND t.source_system_id = 1
  AND per.first_name = 'Anel' AND per.last_name = 'Ramic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Buckhead SC' AND t.source_system_id = 1
  AND per.first_name = 'Sumner' AND per.last_name = 'Richardson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Buckhead SC' AND t.source_system_id = 1
  AND per.first_name = 'George' AND per.last_name = 'Bishop Rodi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Buckhead SC' AND t.source_system_id = 1
  AND per.first_name = 'Connor' AND per.last_name = 'Rosenthal'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Buckhead SC' AND t.source_system_id = 1
  AND per.first_name = 'Godfred' AND per.last_name = 'Nii Tettey'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Buckhead SC' AND t.source_system_id = 1
  AND per.first_name = 'Joshua' AND per.last_name = 'Parbie Tettey'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Buckhead SC' AND t.source_system_id = 1
  AND per.first_name = 'Robert' AND per.last_name = 'A Thomas'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Buckhead SC' AND t.source_system_id = 1
  AND per.first_name = 'Chris' AND per.last_name = 'Arturo Vitela'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Buckhead SC' AND t.source_system_id = 1
  AND per.first_name = 'Noah' AND per.last_name = 'Wieland'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Buckhead SC' AND t.source_system_id = 1
  AND per.first_name = 'Olanrewaju' AND per.last_name = 'Yusuff'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Prima FC' AND t.source_system_id = 1
  AND per.first_name = 'Zackeriah' AND per.last_name = 'Aday-Nicholson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Prima FC' AND t.source_system_id = 1
  AND per.first_name = 'Gabriel' AND per.last_name = 'Alvarez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Prima FC' AND t.source_system_id = 1
  AND per.first_name = 'Dylan' AND per.last_name = 'Bapst'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Prima FC' AND t.source_system_id = 1
  AND per.first_name = 'Mitchell' AND per.last_name = 'Barry'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Prima FC' AND t.source_system_id = 1
  AND per.first_name = 'Charles' AND per.last_name = 'Blakenship'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Prima FC' AND t.source_system_id = 1
  AND per.first_name = 'Davis' AND per.last_name = 'Bryan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Prima FC' AND t.source_system_id = 1
  AND per.first_name = 'Kevin' AND per.last_name = 'Carvalho'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Prima FC' AND t.source_system_id = 1
  AND per.first_name = 'John' AND per.last_name = 'Fragakis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Prima FC' AND t.source_system_id = 1
  AND per.first_name = 'Stefan' AND per.last_name = 'Gojic'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Prima FC' AND t.source_system_id = 1
  AND per.first_name = 'Andrew' AND per.last_name = 'Grodhaus'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Prima FC' AND t.source_system_id = 1
  AND per.first_name = 'Colton' AND per.last_name = 'Huebner'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Prima FC' AND t.source_system_id = 1
  AND per.first_name = 'Joshua' AND per.last_name = 'James'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Prima FC' AND t.source_system_id = 1
  AND per.first_name = 'William' AND per.last_name = 'Keegan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Prima FC' AND t.source_system_id = 1
  AND per.first_name = 'Konrad' AND per.last_name = 'Knap'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Prima FC' AND t.source_system_id = 1
  AND per.first_name = 'Jordan' AND per.last_name = 'Locke'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Prima FC' AND t.source_system_id = 1
  AND per.first_name = 'Christopher' AND per.last_name = 'Marshall'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Prima FC' AND t.source_system_id = 1
  AND per.first_name = 'Javier' AND per.last_name = 'Martinez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Prima FC' AND t.source_system_id = 1
  AND per.first_name = 'Cain' AND per.last_name = 'McMillan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Prima FC' AND t.source_system_id = 1
  AND per.first_name = 'Anthony' AND per.last_name = 'Norman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Prima FC' AND t.source_system_id = 1
  AND per.first_name = 'Sampson' AND per.last_name = 'Nsemoh'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Prima FC' AND t.source_system_id = 1
  AND per.first_name = 'Thomas' AND per.last_name = 'Powers'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Prima FC' AND t.source_system_id = 1
  AND per.first_name = 'Seth' AND per.last_name = 'Prieto'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Prima FC' AND t.source_system_id = 1
  AND per.first_name = 'Adam' AND per.last_name = 'Rooney'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Prima FC' AND t.source_system_id = 1
  AND per.first_name = 'Jacob' AND per.last_name = 'Sayer'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Prima FC' AND t.source_system_id = 1
  AND per.first_name = 'Zachary' AND per.last_name = 'Smith'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Prima FC' AND t.source_system_id = 1
  AND per.first_name = 'Christian' AND per.last_name = 'Waeglin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Prima FC' AND t.source_system_id = 1
  AND per.first_name = 'Christopher' AND per.last_name = 'Witmond'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Bel Calcio FC' AND t.source_system_id = 1
  AND per.first_name = 'Nathan' AND per.last_name = 'Bio'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Bel Calcio FC' AND t.source_system_id = 1
  AND per.first_name = 'Rob' AND per.last_name = 'Bonet'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Bel Calcio FC' AND t.source_system_id = 1
  AND per.first_name = 'Aziymu' AND per.last_name = 'Shamil Burns'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Bel Calcio FC' AND t.source_system_id = 1
  AND per.first_name = 'Jackson' AND per.last_name = 'Cavenaugh'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Bel Calcio FC' AND t.source_system_id = 1
  AND per.first_name = 'Kyle' AND per.last_name = 'Crawford'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Bel Calcio FC' AND t.source_system_id = 1
  AND per.first_name = 'Eduardo' AND per.last_name = 'Delgado'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Bel Calcio FC' AND t.source_system_id = 1
  AND per.first_name = 'Matheus' AND per.last_name = 'Fineto'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Bel Calcio FC' AND t.source_system_id = 1
  AND per.first_name = 'Enrique' AND per.last_name = 'Gonzalez Plaza'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Bel Calcio FC' AND t.source_system_id = 1
  AND per.first_name = 'Chris' AND per.last_name = 'Griffith'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Bel Calcio FC' AND t.source_system_id = 1
  AND per.first_name = 'Philip' AND per.last_name = 'Harris'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Bel Calcio FC' AND t.source_system_id = 1
  AND per.first_name = 'Justin' AND per.last_name = 'Heimerl'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Bel Calcio FC' AND t.source_system_id = 1
  AND per.first_name = 'Lucas' AND per.last_name = 'Horton'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Bel Calcio FC' AND t.source_system_id = 1
  AND per.first_name = 'Karson' AND per.last_name = 'Reese Kendall'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Bel Calcio FC' AND t.source_system_id = 1
  AND per.first_name = 'Konner' AND per.last_name = 'Kendall'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Bel Calcio FC' AND t.source_system_id = 1
  AND per.first_name = 'Mouad' AND per.last_name = 'Labied'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Bel Calcio FC' AND t.source_system_id = 1
  AND per.first_name = 'Jake' AND per.last_name = 'Langton'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Bel Calcio FC' AND t.source_system_id = 1
  AND per.first_name = 'Myles' AND per.last_name = 'Levelle'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Bel Calcio FC' AND t.source_system_id = 1
  AND per.first_name = 'Randy' AND per.last_name = 'Mallar-Calvillo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Bel Calcio FC' AND t.source_system_id = 1
  AND per.first_name = 'Matt' AND per.last_name = 'Mitchell'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Bel Calcio FC' AND t.source_system_id = 1
  AND per.first_name = 'Nikos' AND per.last_name = 'Papanikolopoulos'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Bel Calcio FC' AND t.source_system_id = 1
  AND per.first_name = 'Cade' AND per.last_name = 'Quinto'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Bel Calcio FC' AND t.source_system_id = 1
  AND per.first_name = 'Juandi' AND per.last_name = 'Riley'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Bel Calcio FC' AND t.source_system_id = 1
  AND per.first_name = 'Luis' AND per.last_name = 'Romero'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Bel Calcio FC' AND t.source_system_id = 1
  AND per.first_name = 'Eduardo' AND per.last_name = 'Ernesto Salmeron'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Bel Calcio FC' AND t.source_system_id = 1
  AND per.first_name = 'Aswin' AND per.last_name = 'Sembu'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Bel Calcio FC' AND t.source_system_id = 1
  AND per.first_name = 'Adam' AND per.last_name = 'Sole'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Bel Calcio FC' AND t.source_system_id = 1
  AND per.first_name = 'Zaid' AND per.last_name = 'Takrouri'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Bel Calcio FC' AND t.source_system_id = 1
  AND per.first_name = 'Michael' AND per.last_name = 'Touihri'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Bel Calcio FC' AND t.source_system_id = 1
  AND per.first_name = 'Ivan' AND per.last_name = 'Verdezoto'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Bel Calcio FC' AND t.source_system_id = 1
  AND per.first_name = 'Min' AND per.last_name = 'Yoo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alliance SC' AND t.source_system_id = 1
  AND per.first_name = 'Roberto' AND per.last_name = 'Carlos Calix'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alliance SC' AND t.source_system_id = 1
  AND per.first_name = 'Eli' AND per.last_name = 'Francisco Carrasco'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alliance SC' AND t.source_system_id = 1
  AND per.first_name = 'Axel' AND per.last_name = 'Castrejon'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alliance SC' AND t.source_system_id = 1
  AND per.first_name = 'Gael' AND per.last_name = 'Jared Castrejon'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alliance SC' AND t.source_system_id = 1
  AND per.first_name = 'Jared' AND per.last_name = 'Scott Childs'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alliance SC' AND t.source_system_id = 1
  AND per.first_name = 'Dylan' AND per.last_name = 'Bright Edmonds'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alliance SC' AND t.source_system_id = 1
  AND per.first_name = 'Mason' AND per.last_name = 'McGill Fifer'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alliance SC' AND t.source_system_id = 1
  AND per.first_name = 'Omar' AND per.last_name = 'Guadarrama'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alliance SC' AND t.source_system_id = 1
  AND per.first_name = 'Brandon' AND per.last_name = 'Gutierrez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alliance SC' AND t.source_system_id = 1
  AND per.first_name = 'Maury' AND per.last_name = 'Ibarra'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alliance SC' AND t.source_system_id = 1
  AND per.first_name = 'Sebastian' AND per.last_name = 'Tyler Jones'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alliance SC' AND t.source_system_id = 1
  AND per.first_name = 'Dino' AND per.last_name = 'Kalac'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alliance SC' AND t.source_system_id = 1
  AND per.first_name = 'Taylor' AND per.last_name = 'Benjamin Lemmon'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alliance SC' AND t.source_system_id = 1
  AND per.first_name = 'Ivan' AND per.last_name = 'Israel Lopez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alliance SC' AND t.source_system_id = 1
  AND per.first_name = 'Sebastian' AND per.last_name = 'Lopez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alliance SC' AND t.source_system_id = 1
  AND per.first_name = 'Juanes' AND per.last_name = 'Martinez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alliance SC' AND t.source_system_id = 1
  AND per.first_name = 'Sebastian' AND per.last_name = 'Nuñez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alliance SC' AND t.source_system_id = 1
  AND per.first_name = 'Ashton' AND per.last_name = 'Thomas Parnell'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alliance SC' AND t.source_system_id = 1
  AND per.first_name = 'Tyler' AND per.last_name = 'Pineda'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alliance SC' AND t.source_system_id = 1
  AND per.first_name = 'Voshon' AND per.last_name = 'Ramcharan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alliance SC' AND t.source_system_id = 1
  AND per.first_name = 'Marvin' AND per.last_name = 'Rodriguez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alliance SC' AND t.source_system_id = 1
  AND per.first_name = 'Fabian' AND per.last_name = 'Rodriguez-Escobedo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alliance SC' AND t.source_system_id = 1
  AND per.first_name = 'Blair' AND per.last_name = 'Springhall'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alliance SC' AND t.source_system_id = 1
  AND per.first_name = 'Bradley' AND per.last_name = 'Hamilton Tidwell'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alliance SC' AND t.source_system_id = 1
  AND per.first_name = 'Edward' AND per.last_name = 'Trejo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alliance SC' AND t.source_system_id = 1
  AND per.first_name = 'Johan' AND per.last_name = 'Miguel Trigo-Rios'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alliance SC' AND t.source_system_id = 1
  AND per.first_name = 'Luis' AND per.last_name = 'Albert Ventura'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alliance SC' AND t.source_system_id = 1
  AND per.first_name = 'Patrick' AND per.last_name = 'Ventura'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Alliance SC' AND t.source_system_id = 1
  AND per.first_name = 'Nicholas' AND per.last_name = 'Wheeler'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Majestic SC' AND t.source_system_id = 1
  AND per.first_name = 'Rashid' AND per.last_name = 'Alarape'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Majestic SC' AND t.source_system_id = 1
  AND per.first_name = 'Alex' AND per.last_name = 'Archambeau'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Majestic SC' AND t.source_system_id = 1
  AND per.first_name = 'Christopher' AND per.last_name = 'Avery'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Majestic SC' AND t.source_system_id = 1
  AND per.first_name = 'Carlos' AND per.last_name = 'Ayala-Viera'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Majestic SC' AND t.source_system_id = 1
  AND per.first_name = 'Carlos' AND per.last_name = 'Becerra-Gomez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Majestic SC' AND t.source_system_id = 1
  AND per.first_name = 'Oskar' AND per.last_name = 'Bringle'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Majestic SC' AND t.source_system_id = 1
  AND per.first_name = 'Elliot' AND per.last_name = 'Curtin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Majestic SC' AND t.source_system_id = 1
  AND per.first_name = 'Eli' AND per.last_name = 'Dent'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Majestic SC' AND t.source_system_id = 1
  AND per.first_name = 'Jackson' AND per.last_name = 'Eskay'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Majestic SC' AND t.source_system_id = 1
  AND per.first_name = 'Andrew' AND per.last_name = 'Fitton'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Majestic SC' AND t.source_system_id = 1
  AND per.first_name = 'Mike' AND per.last_name = 'Foutsop'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Majestic SC' AND t.source_system_id = 1
  AND per.first_name = 'Neema' AND per.last_name = 'Gharib'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Majestic SC' AND t.source_system_id = 1
  AND per.first_name = 'Andrew' AND per.last_name = 'Halloran'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Majestic SC' AND t.source_system_id = 1
  AND per.first_name = 'Thierno' AND per.last_name = 'Issabre'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Majestic SC' AND t.source_system_id = 1
  AND per.first_name = 'Michael' AND per.last_name = 'Johnson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Majestic SC' AND t.source_system_id = 1
  AND per.first_name = 'Brennan' AND per.last_name = 'Koslow'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Majestic SC' AND t.source_system_id = 1
  AND per.first_name = 'Mitchell' AND per.last_name = 'Kupstas'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Majestic SC' AND t.source_system_id = 1
  AND per.first_name = 'Boland' AND per.last_name = 'Lekeaka'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Majestic SC' AND t.source_system_id = 1
  AND per.first_name = 'Adrian' AND per.last_name = 'Lollar'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Majestic SC' AND t.source_system_id = 1
  AND per.first_name = 'McKinley' AND per.last_name = 'Mercer III'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Majestic SC' AND t.source_system_id = 1
  AND per.first_name = 'Luke' AND per.last_name = 'Narker'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Majestic SC' AND t.source_system_id = 1
  AND per.first_name = 'Hassan' AND per.last_name = 'Pinto'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Majestic SC' AND t.source_system_id = 1
  AND per.first_name = 'Cory' AND per.last_name = 'Plasker'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Majestic SC' AND t.source_system_id = 1
  AND per.first_name = 'Max' AND per.last_name = 'Poore'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Majestic SC' AND t.source_system_id = 1
  AND per.first_name = 'Kevin' AND per.last_name = 'Reyes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Majestic SC' AND t.source_system_id = 1
  AND per.first_name = 'Sharpe' AND per.last_name = 'Sablon'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Majestic SC' AND t.source_system_id = 1
  AND per.first_name = 'Iain' AND per.last_name = 'Smith'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Majestic SC' AND t.source_system_id = 1
  AND per.first_name = 'Thor' AND per.last_name = 'Svienbjorsson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Majestic SC' AND t.source_system_id = 1
  AND per.first_name = 'Thomas' AND per.last_name = 'Toney'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Majestic SC' AND t.source_system_id = 1
  AND per.first_name = 'Zachary' AND per.last_name = 'Paul Young'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Medford Strikers' AND t.source_system_id = 1
  AND per.first_name = 'Anthony' AND per.last_name = 'Alexis Ali'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Medford Strikers' AND t.source_system_id = 1
  AND per.first_name = 'Dylan' AND per.last_name = 'Bednarek'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Medford Strikers' AND t.source_system_id = 1
  AND per.first_name = 'Garrett' AND per.last_name = 'Blankinship'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Medford Strikers' AND t.source_system_id = 1
  AND per.first_name = 'Matthew' AND per.last_name = 'David Dottavi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Medford Strikers' AND t.source_system_id = 1
  AND per.first_name = 'Mohamed' AND per.last_name = 'Kasongo Doukoure'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Medford Strikers' AND t.source_system_id = 1
  AND per.first_name = 'Noel' AND per.last_name = 'Fernadez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Medford Strikers' AND t.source_system_id = 1
  AND per.first_name = 'Patrick' AND per.last_name = 'James Fluharty'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Medford Strikers' AND t.source_system_id = 1
  AND per.first_name = 'Astin' AND per.last_name = 'Timothy Galanis'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Medford Strikers' AND t.source_system_id = 1
  AND per.first_name = 'Anthony' AND per.last_name = 'Frank Giafaglione'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Medford Strikers' AND t.source_system_id = 1
  AND per.first_name = 'Amir' AND per.last_name = 'Khan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Medford Strikers' AND t.source_system_id = 1
  AND per.first_name = 'Anthony' AND per.last_name = 'Konah'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Medford Strikers' AND t.source_system_id = 1
  AND per.first_name = 'Brian' AND per.last_name = 'Lorenz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Medford Strikers' AND t.source_system_id = 1
  AND per.first_name = 'Yoni' AND per.last_name = 'Andre Moussodou'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Medford Strikers' AND t.source_system_id = 1
  AND per.first_name = 'Oguzhan' AND per.last_name = 'Mutaf'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Medford Strikers' AND t.source_system_id = 1
  AND per.first_name = 'Rami' AND per.last_name = 'Mahmoud Nasr'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Medford Strikers' AND t.source_system_id = 1
  AND per.first_name = 'Michael' AND per.last_name = 'Negrete'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Medford Strikers' AND t.source_system_id = 1
  AND per.first_name = 'Juan' AND per.last_name = 'Oliveira'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Medford Strikers' AND t.source_system_id = 1
  AND per.first_name = 'Edwin' AND per.last_name = 'Perez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Medford Strikers' AND t.source_system_id = 1
  AND per.first_name = 'Antonio' AND per.last_name = 'Ramos'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Medford Strikers' AND t.source_system_id = 1
  AND per.first_name = 'Ethan' AND per.last_name = 'Rosado'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Medford Strikers' AND t.source_system_id = 1
  AND per.first_name = 'Todd' AND per.last_name = 'Richard Salmon'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Medford Strikers' AND t.source_system_id = 1
  AND per.first_name = 'Aiden' AND per.last_name = 'Francis Schmitt'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Medford Strikers' AND t.source_system_id = 1
  AND per.first_name = 'Liam' AND per.last_name = 'Smith'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Medford Strikers' AND t.source_system_id = 1
  AND per.first_name = 'Jovanny' AND per.last_name = 'Trinidad-Romero'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Medford Strikers' AND t.source_system_id = 1
  AND per.first_name = 'Isaiah' AND per.last_name = 'Roman Woods-Kolsky'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Medford Strikers' AND t.source_system_id = 1
  AND per.first_name = 'Chenyu' AND per.last_name = 'Yi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Medford Strikers' AND t.source_system_id = 1
  AND per.first_name = 'Samuel' AND per.last_name = 'Tony Zonoe'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Medford Strikers' AND t.source_system_id = 1
  AND per.first_name = 'Skylar' AND per.last_name = 'Zugay'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Leros SC' AND t.source_system_id = 1
  AND per.first_name = 'Keirol' AND per.last_name = 'Aaron'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Leros SC' AND t.source_system_id = 1
  AND per.first_name = 'Matthais' AND per.last_name = 'Adamek'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Leros SC' AND t.source_system_id = 1
  AND per.first_name = 'Yohance' AND per.last_name = 'Alexander'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Leros SC' AND t.source_system_id = 1
  AND per.first_name = 'Andrea' AND per.last_name = 'Andreou'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Leros SC' AND t.source_system_id = 1
  AND per.first_name = 'Luis' AND per.last_name = 'Argudo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Leros SC' AND t.source_system_id = 1
  AND per.first_name = 'Theodore' AND per.last_name = 'Bernhard'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Leros SC' AND t.source_system_id = 1
  AND per.first_name = 'Antonio' AND per.last_name = 'Biggs'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Leros SC' AND t.source_system_id = 1
  AND per.first_name = 'Mason' AND per.last_name = 'Chetti'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Leros SC' AND t.source_system_id = 1
  AND per.first_name = 'Jarvis' AND per.last_name = 'Cleal'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Leros SC' AND t.source_system_id = 1
  AND per.first_name = 'Joel' AND per.last_name = 'Cunningham'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Leros SC' AND t.source_system_id = 1
  AND per.first_name = 'Caleb' AND per.last_name = 'Danquah'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Leros SC' AND t.source_system_id = 1
  AND per.first_name = 'Eric' AND per.last_name = 'Danquah'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Leros SC' AND t.source_system_id = 1
  AND per.first_name = 'Sameer' AND per.last_name = 'Fathazada'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Leros SC' AND t.source_system_id = 1
  AND per.first_name = 'Leo' AND per.last_name = 'Folla'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Leros SC' AND t.source_system_id = 1
  AND per.first_name = 'Jakob' AND per.last_name = 'Friedman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Leros SC' AND t.source_system_id = 1
  AND per.first_name = 'Sebastian' AND per.last_name = 'Goicochea'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Leros SC' AND t.source_system_id = 1
  AND per.first_name = 'Juan' AND per.last_name = 'Antonio Gomez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Leros SC' AND t.source_system_id = 1
  AND per.first_name = 'Alessio' AND per.last_name = 'Hernandez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Leros SC' AND t.source_system_id = 1
  AND per.first_name = 'Benjamin' AND per.last_name = 'Jones'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Leros SC' AND t.source_system_id = 1
  AND per.first_name = 'Selcuk' AND per.last_name = 'Kahveci'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Leros SC' AND t.source_system_id = 1
  AND per.first_name = 'Chad' AND per.last_name = 'Mark'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Leros SC' AND t.source_system_id = 1
  AND per.first_name = 'Eoin' AND per.last_name = 'Martin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Leros SC' AND t.source_system_id = 1
  AND per.first_name = 'Leonardo' AND per.last_name = 'Martinelli'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Leros SC' AND t.source_system_id = 1
  AND per.first_name = 'Alexander' AND per.last_name = 'McLachlan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Leros SC' AND t.source_system_id = 1
  AND per.first_name = 'Giovanny' AND per.last_name = 'Morales'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Leros SC' AND t.source_system_id = 1
  AND per.first_name = 'Bradley' AND per.last_name = 'Nestor'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Leros SC' AND t.source_system_id = 1
  AND per.first_name = 'Godwin' AND per.last_name = 'Partey'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Leros SC' AND t.source_system_id = 1
  AND per.first_name = 'Junior' AND per.last_name = 'Rosero'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Leros SC' AND t.source_system_id = 1
  AND per.first_name = 'Karim' AND per.last_name = 'Russell'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Leros SC' AND t.source_system_id = 1
  AND per.first_name = 'Sanoussi' AND per.last_name = 'Sangary'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Leros SC' AND t.source_system_id = 1
  AND per.first_name = 'Shaquille' AND per.last_name = 'Saunchez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Leros SC' AND t.source_system_id = 1
  AND per.first_name = 'Kendell' AND per.last_name = 'Thomas'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Leros SC' AND t.source_system_id = 1
  AND per.first_name = 'Dillon' AND per.last_name = 'Woods'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Leros SC' AND t.source_system_id = 1
  AND per.first_name = 'George' AND per.last_name = 'Yusuff'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Terminus FC' AND t.source_system_id = 1
  AND per.first_name = 'Nour' AND per.last_name = 'Alamri'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Terminus FC' AND t.source_system_id = 1
  AND per.first_name = 'Henry' AND per.last_name = 'Asbill'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Terminus FC' AND t.source_system_id = 1
  AND per.first_name = 'Asad' AND per.last_name = 'Bashir'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Terminus FC' AND t.source_system_id = 1
  AND per.first_name = 'Kai' AND per.last_name = 'Bennett'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Terminus FC' AND t.source_system_id = 1
  AND per.first_name = 'Alex' AND per.last_name = 'Caskey'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Terminus FC' AND t.source_system_id = 1
  AND per.first_name = 'Damian' AND per.last_name = 'Charles'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Terminus FC' AND t.source_system_id = 1
  AND per.first_name = 'Jamie' AND per.last_name = 'Gleeson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Terminus FC' AND t.source_system_id = 1
  AND per.first_name = 'Noah' AND per.last_name = 'Goodman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Terminus FC' AND t.source_system_id = 1
  AND per.first_name = 'Anthony' AND per.last_name = 'Gourdine'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Terminus FC' AND t.source_system_id = 1
  AND per.first_name = 'Morgan' AND per.last_name = 'Hall'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Terminus FC' AND t.source_system_id = 1
  AND per.first_name = 'Josh' AND per.last_name = 'Hughes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Terminus FC' AND t.source_system_id = 1
  AND per.first_name = 'Gad' AND per.last_name = 'Kabwende'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Terminus FC' AND t.source_system_id = 1
  AND per.first_name = 'Jason' AND per.last_name = 'Kayne'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Terminus FC' AND t.source_system_id = 1
  AND per.first_name = 'JT' AND per.last_name = 'Keiffer'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Terminus FC' AND t.source_system_id = 1
  AND per.first_name = 'Sebastian' AND per.last_name = 'Lopez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Terminus FC' AND t.source_system_id = 1
  AND per.first_name = 'Jean' AND per.last_name = 'Malilo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Terminus FC' AND t.source_system_id = 1
  AND per.first_name = 'Zion' AND per.last_name = 'Jediah-Jason McClean'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Terminus FC' AND t.source_system_id = 1
  AND per.first_name = 'Gregg' AND per.last_name = 'McPheely'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Terminus FC' AND t.source_system_id = 1
  AND per.first_name = 'Nathan' AND per.last_name = 'Miles'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Terminus FC' AND t.source_system_id = 1
  AND per.first_name = 'Alex' AND per.last_name = 'Rotoloni'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Terminus FC' AND t.source_system_id = 1
  AND per.first_name = 'Jack' AND per.last_name = 'Snyder'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Terminus FC' AND t.source_system_id = 1
  AND per.first_name = 'Brynn' AND per.last_name = 'Thompson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Terminus FC' AND t.source_system_id = 1
  AND per.first_name = 'Tyler' AND per.last_name = 'Vogt'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Terminus FC' AND t.source_system_id = 1
  AND per.first_name = 'Renaldo' AND per.last_name = 'Walters'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Terminus FC' AND t.source_system_id = 1
  AND per.first_name = 'Matt' AND per.last_name = 'Williams'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Terminus FC' AND t.source_system_id = 1
  AND per.first_name = 'Nick' AND per.last_name = 'York'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse 1893 SC' AND t.source_system_id = 1
  AND per.first_name = 'Musa' AND per.last_name = 'Abdelgadir'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse 1893 SC' AND t.source_system_id = 1
  AND per.first_name = 'Amar' AND per.last_name = 'Abdelrazek'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse 1893 SC' AND t.source_system_id = 1
  AND per.first_name = 'Abdelrahman' AND per.last_name = 'Ali'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse 1893 SC' AND t.source_system_id = 1
  AND per.first_name = 'Ahmed' AND per.last_name = 'Ali'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse 1893 SC' AND t.source_system_id = 1
  AND per.first_name = 'Erwa' AND per.last_name = 'Babiker'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse 1893 SC' AND t.source_system_id = 1
  AND per.first_name = 'Arsene' AND per.last_name = 'Bado'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse 1893 SC' AND t.source_system_id = 1
  AND per.first_name = 'Logan' AND per.last_name = 'Bersani'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse 1893 SC' AND t.source_system_id = 1
  AND per.first_name = 'Mohamed' AND per.last_name = 'Bility'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse 1893 SC' AND t.source_system_id = 1
  AND per.first_name = 'Hamzah' AND per.last_name = 'Dabbour'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse 1893 SC' AND t.source_system_id = 1
  AND per.first_name = 'Terrence' AND per.last_name = 'Doe'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse 1893 SC' AND t.source_system_id = 1
  AND per.first_name = 'Musa' AND per.last_name = 'Donza'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse 1893 SC' AND t.source_system_id = 1
  AND per.first_name = 'Alexander' AND per.last_name = 'Duopu'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse 1893 SC' AND t.source_system_id = 1
  AND per.first_name = 'Luis' AND per.last_name = 'Espejo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse 1893 SC' AND t.source_system_id = 1
  AND per.first_name = 'Christopher' AND per.last_name = 'Fletcher'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse 1893 SC' AND t.source_system_id = 1
  AND per.first_name = 'Mujtaba' AND per.last_name = 'Galas'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse 1893 SC' AND t.source_system_id = 1
  AND per.first_name = 'Mustafa' AND per.last_name = 'Galas'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse 1893 SC' AND t.source_system_id = 1
  AND per.first_name = 'John' AND per.last_name = 'Gonzalez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse 1893 SC' AND t.source_system_id = 1
  AND per.first_name = 'Ahmed' AND per.last_name = 'Gosie'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse 1893 SC' AND t.source_system_id = 1
  AND per.first_name = 'Maccarrey' AND per.last_name = 'Guillaume'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse 1893 SC' AND t.source_system_id = 1
  AND per.first_name = 'Otmane' AND per.last_name = 'Houasli'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse 1893 SC' AND t.source_system_id = 1
  AND per.first_name = 'Esnayder' AND per.last_name = 'Josue'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse 1893 SC' AND t.source_system_id = 1
  AND per.first_name = 'Abdoulaye' AND per.last_name = 'Kamagate'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse 1893 SC' AND t.source_system_id = 1
  AND per.first_name = 'Amadou' AND per.last_name = 'Kamagate'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse 1893 SC' AND t.source_system_id = 1
  AND per.first_name = 'Majid' AND per.last_name = 'Kawa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse 1893 SC' AND t.source_system_id = 1
  AND per.first_name = 'Mohamed' AND per.last_name = 'Khalafalla'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse 1893 SC' AND t.source_system_id = 1
  AND per.first_name = 'Kouassi' AND per.last_name = 'Nguessan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse 1893 SC' AND t.source_system_id = 1
  AND per.first_name = 'Benell' AND per.last_name = 'Saygarn'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Lighthouse 1893 SC' AND t.source_system_id = 1
  AND per.first_name = 'Oumar' AND per.last_name = 'Sylla'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Sewell Old Boys FC' AND t.source_system_id = 1
  AND per.first_name = 'Dylan' AND per.last_name = 'Frank Aportela'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Sewell Old Boys FC' AND t.source_system_id = 1
  AND per.first_name = 'Monsif' AND per.last_name = 'Atify'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Sewell Old Boys FC' AND t.source_system_id = 1
  AND per.first_name = 'Shane' AND per.last_name = 'Baker'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Sewell Old Boys FC' AND t.source_system_id = 1
  AND per.first_name = 'Mava' AND per.last_name = 'Mboko Celestin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Sewell Old Boys FC' AND t.source_system_id = 1
  AND per.first_name = 'Gunnar' AND per.last_name = 'William Christensen'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Sewell Old Boys FC' AND t.source_system_id = 1
  AND per.first_name = 'Bailey' AND per.last_name = 'Cifone'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Sewell Old Boys FC' AND t.source_system_id = 1
  AND per.first_name = 'Emmett' AND per.last_name = 'Dougherty'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Sewell Old Boys FC' AND t.source_system_id = 1
  AND per.first_name = 'Sean' AND per.last_name = 'Fatiga'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Sewell Old Boys FC' AND t.source_system_id = 1
  AND per.first_name = 'Gil' AND per.last_name = 'Ferreira'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Sewell Old Boys FC' AND t.source_system_id = 1
  AND per.first_name = 'Greg' AND per.last_name = 'Ferreira'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Sewell Old Boys FC' AND t.source_system_id = 1
  AND per.first_name = 'Ryan' AND per.last_name = 'Gale'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Sewell Old Boys FC' AND t.source_system_id = 1
  AND per.first_name = 'Elvis' AND per.last_name = 'Gboho'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Sewell Old Boys FC' AND t.source_system_id = 1
  AND per.first_name = 'McCarthy' AND per.last_name = 'Tyler Gomes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Sewell Old Boys FC' AND t.source_system_id = 1
  AND per.first_name = 'Jeshohaih' AND per.last_name = 'Hernandez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Sewell Old Boys FC' AND t.source_system_id = 1
  AND per.first_name = 'Ahmir' AND per.last_name = 'Lamar Johnson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Sewell Old Boys FC' AND t.source_system_id = 1
  AND per.first_name = 'Ahsan' AND per.last_name = 'Johnson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Sewell Old Boys FC' AND t.source_system_id = 1
  AND per.first_name = 'Bugra' AND per.last_name = 'Kumas'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Sewell Old Boys FC' AND t.source_system_id = 1
  AND per.first_name = 'Jake' AND per.last_name = 'Kuzmick'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Sewell Old Boys FC' AND t.source_system_id = 1
  AND per.first_name = 'Dominic' AND per.last_name = 'Antonio lodise'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Sewell Old Boys FC' AND t.source_system_id = 1
  AND per.first_name = 'Gavin' AND per.last_name = 'O''Neill'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Sewell Old Boys FC' AND t.source_system_id = 1
  AND per.first_name = 'Krish' AND per.last_name = 'Olmedo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Sewell Old Boys FC' AND t.source_system_id = 1
  AND per.first_name = 'Alexander' AND per.last_name = 'Charles Patton'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Sewell Old Boys FC' AND t.source_system_id = 1
  AND per.first_name = 'Noam' AND per.last_name = 'Raz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Sewell Old Boys FC' AND t.source_system_id = 1
  AND per.first_name = 'Mason' AND per.last_name = 'James Regan'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Sewell Old Boys FC' AND t.source_system_id = 1
  AND per.first_name = 'Fred' AND per.last_name = 'Renzulli'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Sewell Old Boys FC' AND t.source_system_id = 1
  AND per.first_name = 'Joseph' AND per.last_name = 'Romano'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Sewell Old Boys FC' AND t.source_system_id = 1
  AND per.first_name = 'Joshua' AND per.last_name = 'Rossell'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Sewell Old Boys FC' AND t.source_system_id = 1
  AND per.first_name = 'Brian' AND per.last_name = 'Sharkey'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Sewell Old Boys FC' AND t.source_system_id = 1
  AND per.first_name = 'Christopher' AND per.last_name = 'John Spicer'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Sewell Old Boys FC' AND t.source_system_id = 1
  AND per.first_name = 'Kyle' AND per.last_name = 'William Stone'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Sewell Old Boys FC' AND t.source_system_id = 1
  AND per.first_name = 'Owen' AND per.last_name = 'Strohm'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Sewell Old Boys FC' AND t.source_system_id = 1
  AND per.first_name = 'Jackson' AND per.last_name = 'M Stuetz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Sewell Old Boys FC' AND t.source_system_id = 1
  AND per.first_name = 'Melcohol' AND per.last_name = 'Velasquez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Sewell Old Boys FC' AND t.source_system_id = 1
  AND per.first_name = 'Christian' AND per.last_name = 'Vetter'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Scrub Nation' AND t.source_system_id = 1
  AND per.first_name = 'Moises' AND per.last_name = 'De pina Alves'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Scrub Nation' AND t.source_system_id = 1
  AND per.first_name = 'Jack' AND per.last_name = 'Aronson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Scrub Nation' AND t.source_system_id = 1
  AND per.first_name = 'Joao' AND per.last_name = 'P Carvalho'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Scrub Nation' AND t.source_system_id = 1
  AND per.first_name = 'Mana' AND per.last_name = 'Chavali'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Scrub Nation' AND t.source_system_id = 1
  AND per.first_name = 'Suri' AND per.last_name = 'Chavali'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Scrub Nation' AND t.source_system_id = 1
  AND per.first_name = 'Brendan' AND per.last_name = 'Claflin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Scrub Nation' AND t.source_system_id = 1
  AND per.first_name = 'Matthew' AND per.last_name = 'Daniel Cosentino'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Scrub Nation' AND t.source_system_id = 1
  AND per.first_name = 'Patrick' AND per.last_name = 'Davison'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Scrub Nation' AND t.source_system_id = 1
  AND per.first_name = 'Joao' AND per.last_name = 'Paulo De Mattos Almeida'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Scrub Nation' AND t.source_system_id = 1
  AND per.first_name = 'Manuel' AND per.last_name = 'António Depina'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Scrub Nation' AND t.source_system_id = 1
  AND per.first_name = 'Michael' AND per.last_name = 'Eve'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Scrub Nation' AND t.source_system_id = 1
  AND per.first_name = 'Nicholas' AND per.last_name = 'Falcone'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Scrub Nation' AND t.source_system_id = 1
  AND per.first_name = 'Jackson' AND per.last_name = 'Faulx'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Scrub Nation' AND t.source_system_id = 1
  AND per.first_name = 'Luke' AND per.last_name = 'Hanchar'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Scrub Nation' AND t.source_system_id = 1
  AND per.first_name = 'Oswaldo' AND per.last_name = 'Hernandez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Scrub Nation' AND t.source_system_id = 1
  AND per.first_name = 'Martin' AND per.last_name = 'Konstantinov'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Scrub Nation' AND t.source_system_id = 1
  AND per.first_name = 'Kyle' AND per.last_name = 'Lasewicz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Scrub Nation' AND t.source_system_id = 1
  AND per.first_name = 'Surya' AND per.last_name = 'Mani'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Scrub Nation' AND t.source_system_id = 1
  AND per.first_name = 'Christian' AND per.last_name = 'Martins'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Scrub Nation' AND t.source_system_id = 1
  AND per.first_name = 'Gilson' AND per.last_name = 'Martins'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Scrub Nation' AND t.source_system_id = 1
  AND per.first_name = 'Stephen' AND per.last_name = 'Denis Silva Mendes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Scrub Nation' AND t.source_system_id = 1
  AND per.first_name = 'Chad' AND per.last_name = 'Meyers'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Scrub Nation' AND t.source_system_id = 1
  AND per.first_name = 'Charles' AND per.last_name = 'Miller'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Scrub Nation' AND t.source_system_id = 1
  AND per.first_name = 'Jonathan' AND per.last_name = 'Ernesto Rodriguez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Scrub Nation' AND t.source_system_id = 1
  AND per.first_name = 'Carlos' AND per.last_name = 'Rojas'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Scrub Nation' AND t.source_system_id = 1
  AND per.first_name = 'Jaderson' AND per.last_name = 'Rutsatz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Scrub Nation' AND t.source_system_id = 1
  AND per.first_name = 'Alexander' AND per.last_name = 'Shanley'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Scrub Nation' AND t.source_system_id = 1
  AND per.first_name = 'Griffin' AND per.last_name = 'Sisk'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Scrub Nation' AND t.source_system_id = 1
  AND per.first_name = 'Daniel' AND per.last_name = 'Soto'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Scrub Nation' AND t.source_system_id = 1
  AND per.first_name = 'Elisandro' AND per.last_name = 'Tavares'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Scrub Nation' AND t.source_system_id = 1
  AND per.first_name = 'Nick' AND per.last_name = 'Winn'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Scrub Nation' AND t.source_system_id = 1
  AND per.first_name = 'Jackson' AND per.last_name = 'Yager'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Invictus FC' AND t.source_system_id = 1
  AND per.first_name = 'Mo' AND per.last_name = 'Amine Faleh'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Invictus FC' AND t.source_system_id = 1
  AND per.first_name = 'Ludwin' AND per.last_name = 'Daniel Carranza'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Invictus FC' AND t.source_system_id = 1
  AND per.first_name = 'Albert' AND per.last_name = 'Daniels'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Invictus FC' AND t.source_system_id = 1
  AND per.first_name = 'Yassine' AND per.last_name = 'ElBasli'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Invictus FC' AND t.source_system_id = 1
  AND per.first_name = 'Eduardo' AND per.last_name = 'Engst-Mansilla'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Invictus FC' AND t.source_system_id = 1
  AND per.first_name = 'Kerllon' AND per.last_name = 'Silva Felipe'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Invictus FC' AND t.source_system_id = 1
  AND per.first_name = 'Cole' AND per.last_name = 'Fergusson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Invictus FC' AND t.source_system_id = 1
  AND per.first_name = 'Joao' AND per.last_name = 'Victor Ferreira'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Invictus FC' AND t.source_system_id = 1
  AND per.first_name = 'Carl' AND per.last_name = 'Foming'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Invictus FC' AND t.source_system_id = 1
  AND per.first_name = 'Jackson' AND per.last_name = 'C Gilstrap'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Invictus FC' AND t.source_system_id = 1
  AND per.first_name = 'Bernadin' AND per.last_name = 'Herard'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Invictus FC' AND t.source_system_id = 1
  AND per.first_name = 'Juan' AND per.last_name = 'camilo Hernández'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Invictus FC' AND t.source_system_id = 1
  AND per.first_name = 'Delices' AND per.last_name = 'Keyri'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Invictus FC' AND t.source_system_id = 1
  AND per.first_name = 'Hindolo' AND per.last_name = 'Brima Mansaray'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Invictus FC' AND t.source_system_id = 1
  AND per.first_name = 'John' AND per.last_name = 'Massaquoi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Invictus FC' AND t.source_system_id = 1
  AND per.first_name = 'Vincent' AND per.last_name = 'Miller'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Invictus FC' AND t.source_system_id = 1
  AND per.first_name = 'Hassan' AND per.last_name = 'Mutaasa'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Invictus FC' AND t.source_system_id = 1
  AND per.first_name = 'Amadou' AND per.last_name = 'Moustapha Ndiaye'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Invictus FC' AND t.source_system_id = 1
  AND per.first_name = 'Carl' AND per.last_name = 'Olivier'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Invictus FC' AND t.source_system_id = 1
  AND per.first_name = 'Roodchyl' AND per.last_name = 'Samuel Pauleon'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Invictus FC' AND t.source_system_id = 1
  AND per.first_name = 'Jaydon' AND per.last_name = 'Perez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Invictus FC' AND t.source_system_id = 1
  AND per.first_name = 'Joseph' AND per.last_name = 'Saidu'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Invictus FC' AND t.source_system_id = 1
  AND per.first_name = 'Destin' AND per.last_name = 'Sleeter'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Invictus FC' AND t.source_system_id = 1
  AND per.first_name = 'Pierre' AND per.last_name = 'St Simon'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Invictus FC' AND t.source_system_id = 1
  AND per.first_name = 'Isaiah' AND per.last_name = 'Stessman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Invictus FC' AND t.source_system_id = 1
  AND per.first_name = 'Carlos' AND per.last_name = 'Teixeira'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Invictus FC' AND t.source_system_id = 1
  AND per.first_name = 'Hamza' AND per.last_name = 'Tribia'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Invictus FC' AND t.source_system_id = 1
  AND per.first_name = 'Luiz' AND per.last_name = 'Gustavo Zanellato'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Invictus FC' AND t.source_system_id = 1
  AND per.first_name = 'Abraham' AND per.last_name = 'Zepeda'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Delmarva Thunder' AND t.source_system_id = 1
  AND per.first_name = 'Joseph' AND per.last_name = 'Daly Aigner'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Delmarva Thunder' AND t.source_system_id = 1
  AND per.first_name = 'Liam' AND per.last_name = 'Charles Aigner'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Delmarva Thunder' AND t.source_system_id = 1
  AND per.first_name = 'Jacob' AND per.last_name = 'L Amon'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Delmarva Thunder' AND t.source_system_id = 1
  AND per.first_name = 'Samuel' AND per.last_name = 'Amon'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Delmarva Thunder' AND t.source_system_id = 1
  AND per.first_name = 'Walner' AND per.last_name = 'Anescar'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Delmarva Thunder' AND t.source_system_id = 1
  AND per.first_name = 'Samuel' AND per.last_name = 'Burbage'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Delmarva Thunder' AND t.source_system_id = 1
  AND per.first_name = 'Joshua' AND per.last_name = 'Alexander Carey'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Delmarva Thunder' AND t.source_system_id = 1
  AND per.first_name = 'Corvens' AND per.last_name = 'Jay Corvil'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Delmarva Thunder' AND t.source_system_id = 1
  AND per.first_name = 'Zechariah' AND per.last_name = 'Dapaah'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Delmarva Thunder' AND t.source_system_id = 1
  AND per.first_name = 'Adam' AND per.last_name = 'Stephen DeLizza'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Delmarva Thunder' AND t.source_system_id = 1
  AND per.first_name = 'Heberson' AND per.last_name = 'Edouard'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Delmarva Thunder' AND t.source_system_id = 1
  AND per.first_name = 'Ashley' AND per.last_name = 'Fevrier'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Delmarva Thunder' AND t.source_system_id = 1
  AND per.first_name = 'Christ-Daniel' AND per.last_name = 'Fils'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Delmarva Thunder' AND t.source_system_id = 1
  AND per.first_name = 'Caleb' AND per.last_name = 'James Gragg'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Delmarva Thunder' AND t.source_system_id = 1
  AND per.first_name = 'Marc' AND per.last_name = 'Henrice'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Delmarva Thunder' AND t.source_system_id = 1
  AND per.first_name = 'Colin' AND per.last_name = 'Benjamin Hofmann'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Delmarva Thunder' AND t.source_system_id = 1
  AND per.first_name = 'Elijah' AND per.last_name = 'Jabagat'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Delmarva Thunder' AND t.source_system_id = 1
  AND per.first_name = 'Rickelmy' AND per.last_name = 'Jeune'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Delmarva Thunder' AND t.source_system_id = 1
  AND per.first_name = 'Damarius' AND per.last_name = 'Kelley'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Delmarva Thunder' AND t.source_system_id = 1
  AND per.first_name = 'Goran' AND per.last_name = 'Mijalkovski'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Delmarva Thunder' AND t.source_system_id = 1
  AND per.first_name = 'Sean' AND per.last_name = 'Chidozie Morse'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Delmarva Thunder' AND t.source_system_id = 1
  AND per.first_name = 'Abdelazim' AND per.last_name = 'Osman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Delmarva Thunder' AND t.source_system_id = 1
  AND per.first_name = 'Ahmed' AND per.last_name = 'Osman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Delmarva Thunder' AND t.source_system_id = 1
  AND per.first_name = 'Pat' AND per.last_name = 'Parrish'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Delmarva Thunder' AND t.source_system_id = 1
  AND per.first_name = 'Caden' AND per.last_name = 'Mark Pollard'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Delmarva Thunder' AND t.source_system_id = 1
  AND per.first_name = 'Ivan' AND per.last_name = 'Sanchez-Gonzalez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Delmarva Thunder' AND t.source_system_id = 1
  AND per.first_name = 'Gianluca' AND per.last_name = 'Secondi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Delmarva Thunder' AND t.source_system_id = 1
  AND per.first_name = 'Mourad' AND per.last_name = 'Shalaby'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Delmarva Thunder' AND t.source_system_id = 1
  AND per.first_name = 'Kenny' AND per.last_name = 'Spock'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Delmarva Thunder' AND t.source_system_id = 1
  AND per.first_name = 'Guy' AND per.last_name = 'Holmeade Talbott V'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Delmarva Thunder' AND t.source_system_id = 1
  AND per.first_name = 'Devon' AND per.last_name = 'Warman'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'Delmarva Thunder' AND t.source_system_id = 1
  AND per.first_name = 'Skyler' AND per.last_name = 'Williams'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gwinnett' AND t.source_system_id = 1
  AND per.first_name = 'Adam' AND per.last_name = 'Abdullahi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gwinnett' AND t.source_system_id = 1
  AND per.first_name = 'Mohammed' AND per.last_name = 'Al-Asady'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gwinnett' AND t.source_system_id = 1
  AND per.first_name = 'Malek' AND per.last_name = 'Almariri'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gwinnett' AND t.source_system_id = 1
  AND per.first_name = 'Mario' AND per.last_name = 'Arreguin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gwinnett' AND t.source_system_id = 1
  AND per.first_name = 'Ali' AND per.last_name = 'Bazz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gwinnett' AND t.source_system_id = 1
  AND per.first_name = 'Monchu' AND per.last_name = 'Camara'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gwinnett' AND t.source_system_id = 1
  AND per.first_name = 'Steven' AND per.last_name = 'Carrillo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gwinnett' AND t.source_system_id = 1
  AND per.first_name = 'Karl' AND per.last_name = 'Christiansen'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gwinnett' AND t.source_system_id = 1
  AND per.first_name = 'Franklin' AND per.last_name = 'Contreras'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gwinnett' AND t.source_system_id = 1
  AND per.first_name = 'Vitor' AND per.last_name = 'De Souza'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gwinnett' AND t.source_system_id = 1
  AND per.first_name = 'Adrian' AND per.last_name = 'Garcia'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gwinnett' AND t.source_system_id = 1
  AND per.first_name = 'Josue' AND per.last_name = 'Gomez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gwinnett' AND t.source_system_id = 1
  AND per.first_name = 'Jafet' AND per.last_name = 'Higuera'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gwinnett' AND t.source_system_id = 1
  AND per.first_name = 'Rui' AND per.last_name = 'James-Pereira'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gwinnett' AND t.source_system_id = 1
  AND per.first_name = 'Kendrick' AND per.last_name = 'Jean'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gwinnett' AND t.source_system_id = 1
  AND per.first_name = 'Sanaa' AND per.last_name = 'Listenbee'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gwinnett' AND t.source_system_id = 1
  AND per.first_name = 'Chris' AND per.last_name = 'Louissaint'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gwinnett' AND t.source_system_id = 1
  AND per.first_name = 'David' AND per.last_name = 'Martinez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gwinnett' AND t.source_system_id = 1
  AND per.first_name = 'Ramsis' AND per.last_name = 'Martinez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gwinnett' AND t.source_system_id = 1
  AND per.first_name = 'Ruben' AND per.last_name = 'Martinez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gwinnett' AND t.source_system_id = 1
  AND per.first_name = 'Jonathan' AND per.last_name = 'May'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gwinnett' AND t.source_system_id = 1
  AND per.first_name = 'Jaylen' AND per.last_name = 'McCray'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gwinnett' AND t.source_system_id = 1
  AND per.first_name = 'Tariq' AND per.last_name = 'Mohammed'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gwinnett' AND t.source_system_id = 1
  AND per.first_name = 'Geovanni' AND per.last_name = 'Oboh'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gwinnett' AND t.source_system_id = 1
  AND per.first_name = 'Jordan' AND per.last_name = 'Paul'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gwinnett' AND t.source_system_id = 1
  AND per.first_name = 'Nicolas' AND per.last_name = 'Pegorer'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gwinnett' AND t.source_system_id = 1
  AND per.first_name = 'Pablo' AND per.last_name = 'Piraquive'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gwinnett' AND t.source_system_id = 1
  AND per.first_name = 'Roney' AND per.last_name = 'Rubio'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gwinnett' AND t.source_system_id = 1
  AND per.first_name = 'Anakin' AND per.last_name = 'Ruiz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gwinnett' AND t.source_system_id = 1
  AND per.first_name = 'Jazeime' AND per.last_name = 'Russell'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gwinnett' AND t.source_system_id = 1
  AND per.first_name = 'Jonathan' AND per.last_name = 'Sandoval'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gwinnett' AND t.source_system_id = 1
  AND per.first_name = 'Ayman' AND per.last_name = 'Saudin'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gwinnett' AND t.source_system_id = 1
  AND per.first_name = 'Manuel' AND per.last_name = 'Simental'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gwinnett' AND t.source_system_id = 1
  AND per.first_name = 'Mahmoud' AND per.last_name = 'Tasslak'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'SC Gwinnett' AND t.source_system_id = 1
  AND per.first_name = 'Myles' AND per.last_name = 'Williams'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'GAK' AND t.source_system_id = 1
  AND per.first_name = 'Geovany' AND per.last_name = 'Acevedo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'GAK' AND t.source_system_id = 1
  AND per.first_name = 'Axel' AND per.last_name = 'Bladimir'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'GAK' AND t.source_system_id = 1
  AND per.first_name = 'Michael' AND per.last_name = 'Carmody'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'GAK' AND t.source_system_id = 1
  AND per.first_name = 'Julien' AND per.last_name = 'Carraha'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'GAK' AND t.source_system_id = 1
  AND per.first_name = 'Nicholas' AND per.last_name = 'Cruz'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'GAK' AND t.source_system_id = 1
  AND per.first_name = 'Aba' AND per.last_name = 'David'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'GAK' AND t.source_system_id = 1
  AND per.first_name = 'Jonah' AND per.last_name = 'Dias'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'GAK' AND t.source_system_id = 1
  AND per.first_name = 'Mamadou' AND per.last_name = 'Diouf'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'GAK' AND t.source_system_id = 1
  AND per.first_name = 'Oliver' AND per.last_name = 'Dyson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'GAK' AND t.source_system_id = 1
  AND per.first_name = 'Allan' AND per.last_name = 'Francisco'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'GAK' AND t.source_system_id = 1
  AND per.first_name = 'Randy' AND per.last_name = 'Gonzalez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'GAK' AND t.source_system_id = 1
  AND per.first_name = 'Daniel' AND per.last_name = 'Grund'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'GAK' AND t.source_system_id = 1
  AND per.first_name = 'Ryan' AND per.last_name = 'Grund'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'GAK' AND t.source_system_id = 1
  AND per.first_name = 'Jeremy' AND per.last_name = 'Hernandez Ortega'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'GAK' AND t.source_system_id = 1
  AND per.first_name = 'Chidi' AND per.last_name = 'Iloka'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'GAK' AND t.source_system_id = 1
  AND per.first_name = 'Cesar' AND per.last_name = 'Jarmillo'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'GAK' AND t.source_system_id = 1
  AND per.first_name = 'Tomtom' AND per.last_name = 'Johnson'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'GAK' AND t.source_system_id = 1
  AND per.first_name = 'Davenson' AND per.last_name = 'Joinvilmar'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'GAK' AND t.source_system_id = 1
  AND per.first_name = 'Dylan' AND per.last_name = 'Kotch'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'GAK' AND t.source_system_id = 1
  AND per.first_name = 'adan' AND per.last_name = 'lopez'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'GAK' AND t.source_system_id = 1
  AND per.first_name = 'Liam' AND per.last_name = 'MacDonald'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'GAK' AND t.source_system_id = 1
  AND per.first_name = 'Mario' AND per.last_name = 'Martell'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'GAK' AND t.source_system_id = 1
  AND per.first_name = 'Arnaldo' AND per.last_name = 'Mendoza'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'GAK' AND t.source_system_id = 1
  AND per.first_name = 'Dani' AND per.last_name = 'Morales'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'GAK' AND t.source_system_id = 1
  AND per.first_name = 'jonathan' AND per.last_name = 'olaleye'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'GAK' AND t.source_system_id = 1
  AND per.first_name = 'Lucknerson' AND per.last_name = 'Pierre'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'GAK' AND t.source_system_id = 1
  AND per.first_name = 'Kyle' AND per.last_name = 'Pilliteri'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'GAK' AND t.source_system_id = 1
  AND per.first_name = 'Alex' AND per.last_name = 'Quezada'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'GAK' AND t.source_system_id = 1
  AND per.first_name = 'Wesley' AND per.last_name = 'Reyes'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'GAK' AND t.source_system_id = 1
  AND per.first_name = 'Nick' AND per.last_name = 'Sample'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'GAK' AND t.source_system_id = 1
  AND per.first_name = 'Melvin' AND per.last_name = 'Sapon'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'GAK' AND t.source_system_id = 1
  AND per.first_name = 'Chefetson' AND per.last_name = 'Simeus'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'GAK' AND t.source_system_id = 1
  AND per.first_name = 'Emerson' AND per.last_name = 'Vicente'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'GAK' AND t.source_system_id = 1
  AND per.first_name = 'Mate' AND per.last_name = 'Vilagosi'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, NULL, NOW()
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = 'GAK' AND t.source_system_id = 1
  AND per.first_name = 'John' AND per.last_name = 'Warwick'
ON CONFLICT (team_id, player_id, joined_at) DO NOTHING;

