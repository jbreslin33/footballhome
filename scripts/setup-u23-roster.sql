-- Setup U23 Men (team 903) roster from GroupMe members
-- Skipping coaches: James Breslin, Coach Darlensky, Coach Rancy

-- Step 1: insert any missing persons
INSERT INTO persons (first_name, last_name) VALUES
  ('Abdoul', 'Diallo'),
  ('Aboubacar', 'Bayo'),
  ('Ali', 'Salah'),
  ('Andy', 'Hizdri'),
  ('Babacar', 'Ndiaye'),
  ('Benell', 'Saygarn'),
  ('Chris', 'Fletcher'),
  ('David', 'Masi'),
  ('Gangue', 'Abouya'),
  ('Luis', 'De Jesus'),
  ('Luke', 'Breslin'),
  ('Matheus', 'Bonvicinio Rodrigues'),
  ('Musa', ''),
  ('Oumar', 'Barry'),
  ('Valentino', 'Martinez'),
  ('Yancarlo', 'Corredor'),
  ('Zion', 'Nwalipenja'),
  ('Gian', ''),
  ('Moriba', 'Kamara'),
  ('Hedayatullah', 'Sangin'),
  ('Abou', 'Bayo'),
  ('Majid', 'Hamid'),
  ('Isaac', 'Anderson'),
  ('Victor', 'Baidel'),
  ('Christopher', 'Braz'),
  ('Emmanuel', 'Dennis'),
  ('Owen', 'Magee'),
  ('Dylan', ''),
  ('Marco', 'Delgado'),
  ('Edwin', 'Garcia'),
  ('Elmer', 'Diaz'),
  ('Caleb', 'Rojas'),
  ('Christopher', 'Solis'),
  ('Cristian', 'Paredes'),
  ('Mohamed', 'Mahgoub'),
  ('Joey', 'Benzing'),
  ('Juan', 'Gonzalez'),
  ('Trevor', 'Bartholdi'),
  ('Shawn', 'Street'),
  ('Karim', ''),
  ('Jonathan', 'MedinaRodriguez')
ON CONFLICT (first_name, last_name) DO NOTHING;

-- Step 2: insert players for any of these persons that don't have one
INSERT INTO players (person_id)
SELECT p.id FROM persons p
WHERE (p.first_name || '|' || p.last_name) IN (
  'Abdoul|Diallo','Aboubacar|Bayo','Ali|Salah','Andy|Hizdri',
  'Babacar|Ndiaye','Benell|Saygarn','Chris|Fletcher','David|Masi',
  'Gangue|Abouya','Luis|De Jesus','Luke|Breslin',
  'Matheus|Bonvicinio Rodrigues','Musa|','Oumar|Barry',
  'Valentino|Martinez','Yancarlo|Corredor','Zion|Nwalipenja',
  'Gian|','Moriba|Kamara','Hedayatullah|Sangin','Abou|Bayo',
  'Majid|Hamid','Isaac|Anderson','Victor|Baidel',
  'Christopher|Braz','Emmanuel|Dennis','Owen|Magee','Dylan|',
  'Marco|Delgado','Edwin|Garcia','Elmer|Diaz','Caleb|Rojas',
  'Christopher|Solis','Cristian|Paredes','Mohamed|Mahgoub',
  'Joey|Benzing','Juan|Gonzalez','Trevor|Bartholdi',
  'Shawn|Street','Karim|','Jonathan|MedinaRodriguez'
)
AND NOT EXISTS (SELECT 1 FROM players pl2 WHERE pl2.person_id = p.id);

-- Step 3: insert roster entries for team 903
INSERT INTO rosters (team_id, player_id)
SELECT 903, pl.id
FROM persons p
JOIN players pl ON pl.person_id = p.id
WHERE (p.first_name || '|' || p.last_name) IN (
  'Abdoul|Diallo','Aboubacar|Bayo','Ali|Salah','Andy|Hizdri',
  'Babacar|Ndiaye','Benell|Saygarn','Chris|Fletcher','David|Masi',
  'Gangue|Abouya','Luis|De Jesus','Luke|Breslin',
  'Matheus|Bonvicinio Rodrigues','Musa|','Oumar|Barry',
  'Valentino|Martinez','Yancarlo|Corredor','Zion|Nwalipenja',
  'Gian|','Moriba|Kamara','Hedayatullah|Sangin','Abou|Bayo',
  'Majid|Hamid','Isaac|Anderson','Victor|Baidel',
  'Christopher|Braz','Emmanuel|Dennis','Owen|Magee','Dylan|',
  'Marco|Delgado','Edwin|Garcia','Elmer|Diaz','Caleb|Rojas',
  'Christopher|Solis','Cristian|Paredes','Mohamed|Mahgoub',
  'Joey|Benzing','Juan|Gonzalez','Trevor|Bartholdi',
  'Shawn|Street','Karim|','Jonathan|MedinaRodriguez'
)
AND NOT EXISTS (SELECT 1 FROM rosters r2 WHERE r2.team_id = 903 AND r2.player_id = pl.id);

SELECT COUNT(*) as roster_count FROM rosters WHERE team_id = 903;
