-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Event Players - APSL (auto-created from match events)
-- Players found in match events but not on any roster page
-- Total Records: 208
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INSERT INTO persons (id, first_name, last_name)
VALUES (7153, 'Delvino Tavares', 'Dasilva')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (1, 7153, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Project Football' AND source_system_id = 1 LIMIT 1),
  1,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7154, 'Roodchyl Samuel', 'Pauleon')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (2, 7154, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Invictus FC' AND source_system_id = 1 LIMIT 1),
  2,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7155, 'Ofek', 'Nahar')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (3, 7155, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'SC Vistula Garfield' AND source_system_id = 1 LIMIT 1),
  3,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7156, 'Nikolce', 'Iloski')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (4, 7156, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'SC Vistula Garfield' AND source_system_id = 1 LIMIT 1),
  4,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7157, 'Martin', 'Czovek')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (5, 7157, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'SC Vistula Garfield' AND source_system_id = 1 LIMIT 1),
  5,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7158, 'Jeffrey', 'Castillo')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (6, 7158, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'SC Vistula Garfield' AND source_system_id = 1 LIMIT 1),
  6,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7159, 'Paul', 'Lee')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (7, 7159, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'SC Vistula Garfield' AND source_system_id = 1 LIMIT 1),
  7,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7160, 'Paolo', 'Musumeci')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (8, 7160, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Philadelphia Soccer Club' AND source_system_id = 1 LIMIT 1),
  8,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7161, 'Musa Bala', 'Danso')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (9, 7161, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Lansdowne Yonkers FC' AND source_system_id = 1 LIMIT 1),
  9,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7162, 'James Peter', 'Boote')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (10, 7162, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Lansdowne Yonkers FC' AND source_system_id = 1 LIMIT 1),
  10,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7163, 'Jonathan', 'Sanchez')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (11, 7163, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'SC Vistula Garfield' AND source_system_id = 1 LIMIT 1),
  11,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7164, 'Muhammed Ali', 'Kol')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (12, 7164, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Oaklyn United FC' AND source_system_id = 1 LIMIT 1),
  12,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7165, 'McCarthy Tyler', 'Gomes')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (13, 7165, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Sewell Old Boys FC' AND source_system_id = 1 LIMIT 1),
  13,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7166, 'Jackson M', 'Stuetz')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (14, 7166, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Sewell Old Boys FC' AND source_system_id = 1 LIMIT 1),
  14,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7167, 'Carter Jack', 'Norton')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (15, 7167, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Oaklyn United FC' AND source_system_id = 1 LIMIT 1),
  15,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7168, 'Aidan', 'Chendak')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (16, 7168, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Alloy Soccer Club' AND source_system_id = 1 LIMIT 1),
  16,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7169, 'Joel', 'Hughes')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (17, 7169, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Alloy Soccer Club' AND source_system_id = 1 LIMIT 1),
  17,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7170, 'Aaron', 'Gilman')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (18, 7170, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Jersey Shore Boca' AND source_system_id = 1 LIMIT 1),
  18,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7171, 'Lucien', 'Maslin')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (19, 7171, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Oaklyn United FC' AND source_system_id = 1 LIMIT 1),
  19,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7172, 'Austin', 'Pounds')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (20, 7172, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Jersey Shore Boca' AND source_system_id = 1 LIMIT 1),
  20,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7173, 'Tony', 'Aguilar')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (21, 7173, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Jersey Shore Boca' AND source_system_id = 1 LIMIT 1),
  21,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7174, 'Conlan Michael', 'Paventi')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (22, 7174, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Real Central NJ Soccer' AND source_system_id = 1 LIMIT 1),
  22,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7175, 'Djibi Tata', 'Bah')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (23, 7175, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Real Central NJ Soccer' AND source_system_id = 1 LIMIT 1),
  23,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7176, 'Miguel', 'Duran')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (24, 7176, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Real Central NJ Soccer' AND source_system_id = 1 LIMIT 1),
  24,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7177, 'Mava Mboko', 'Celestin')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (25, 7177, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Sewell Old Boys FC' AND source_system_id = 1 LIMIT 1),
  25,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7178, 'Mason James', 'Regan')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (26, 7178, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Sewell Old Boys FC' AND source_system_id = 1 LIMIT 1),
  26,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7179, 'Kyle William', 'Stone')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (27, 7179, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Sewell Old Boys FC' AND source_system_id = 1 LIMIT 1),
  27,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7180, 'Hassane', 'Abdellaoui')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (28, 7180, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Lighthouse 1893 SC' AND source_system_id = 1 LIMIT 1),
  28,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7181, 'Abdoul', 'Diallo')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (29, 7181, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Lighthouse 1893 SC' AND source_system_id = 1 LIMIT 1),
  29,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7182, 'Aboubacar', 'Bayo')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (30, 7182, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Lighthouse 1893 SC' AND source_system_id = 1 LIMIT 1),
  30,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7183, 'Dylan Leonid', 'Lacy')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (31, 7183, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'WC Predators' AND source_system_id = 1 LIMIT 1),
  31,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7184, 'Jemirkel', 'Ornaque')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (32, 7184, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Lighthouse 1893 SC' AND source_system_id = 1 LIMIT 1),
  32,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7185, 'Alec', 'Mapoy')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (33, 7185, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Jersey Shore Boca' AND source_system_id = 1 LIMIT 1),
  33,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7186, 'Victor', 'Baidel')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (34, 7186, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Lighthouse 1893 SC' AND source_system_id = 1 LIMIT 1),
  34,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7187, 'Ivan Enrique', 'Hurtado')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (35, 7187, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Hoboken FC 1912' AND source_system_id = 1 LIMIT 1),
  35,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7188, 'Sebastian', 'Dalhoff')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (36, 7188, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Hoboken FC 1912' AND source_system_id = 1 LIMIT 1),
  36,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7189, 'Isimohi Mike', 'Bello')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (37, 7189, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Hoboken FC 1912' AND source_system_id = 1 LIMIT 1),
  37,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7190, 'Aaron', 'Sexton')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (38, 7190, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Philadelphia Soccer Club' AND source_system_id = 1 LIMIT 1),
  38,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7191, 'Nigel', 'Johnson')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (39, 7191, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Philadelphia Soccer Club' AND source_system_id = 1 LIMIT 1),
  39,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7192, 'Corey', 'Yorke')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (40, 7192, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Philadelphia Soccer Club' AND source_system_id = 1 LIMIT 1),
  40,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7193, 'Christopher John', 'Spicer')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (41, 7193, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Sewell Old Boys FC' AND source_system_id = 1 LIMIT 1),
  41,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7194, 'Diego', 'Murillo Solano')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (42, 7194, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Philadelphia Soccer Club' AND source_system_id = 1 LIMIT 1),
  42,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7195, 'John Steven', 'Warren')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (43, 7195, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Philadelphia Heritage SC' AND source_system_id = 1 LIMIT 1),
  43,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7196, 'Christopher Diego', 'Anderson')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (44, 7196, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'NY Greek Americans' AND source_system_id = 1 LIMIT 1),
  44,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7197, 'El Mahdi', 'Youssoufi')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (45, 7197, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'NY Greek Americans' AND source_system_id = 1 LIMIT 1),
  45,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7198, 'Miguel Soto', 'Gonzalez')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (46, 7198, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'NY Greek Americans' AND source_system_id = 1 LIMIT 1),
  46,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7199, 'Brian Sousa', 'Saramago')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (47, 7199, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'NY Greek Americans' AND source_system_id = 1 LIMIT 1),
  47,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7200, 'Vasilios', 'Dimopoulos')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (48, 7200, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'NY Athletic Club' AND source_system_id = 1 LIMIT 1),
  48,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7201, 'Jens Mannhart', 'Hoff')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (49, 7201, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'NY Pancyprian Freedoms' AND source_system_id = 1 LIMIT 1),
  49,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7202, 'Ede Mateo', 'Gramberg')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (50, 7202, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'NY Pancyprian Freedoms' AND source_system_id = 1 LIMIT 1),
  50,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7203, 'Micheal', 'Valencia')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (51, 7203, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'NY Athletic Club' AND source_system_id = 1 LIMIT 1),
  51,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7204, 'Alpha', 'Drame')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (52, 7204, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Jersey Shore Boca' AND source_system_id = 1 LIMIT 1),
  52,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7205, 'Ray', 'Keller')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (53, 7205, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Jersey Shore Boca' AND source_system_id = 1 LIMIT 1),
  53,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7206, 'Almuthenna Hseen', 'Baled')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (54, 7206, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Vidas United FC' AND source_system_id = 1 LIMIT 1),
  54,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7207, 'Joseph', 'Liberatore')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (55, 7207, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Jersey Shore Boca' AND source_system_id = 1 LIMIT 1),
  55,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7208, 'Joshua Parbie', 'Tettey')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (56, 7208, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Buckhead SC' AND source_system_id = 1 LIMIT 1),
  56,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7209, 'Elad Khaleef', 'Bogle')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (57, 7209, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Buckhead SC' AND source_system_id = 1 LIMIT 1),
  57,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7210, 'David Alejandro', 'Fierro')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (58, 7210, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Buckhead SC' AND source_system_id = 1 LIMIT 1),
  58,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7211, 'Nixon Manuel', 'Condolo')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (59, 7211, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Buckhead SC' AND source_system_id = 1 LIMIT 1),
  59,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7212, 'Astin Timothy', 'Galanis')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (60, 7212, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Medford Strikers' AND source_system_id = 1 LIMIT 1),
  60,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7213, 'Anthony Alexis', 'Ali')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (61, 7213, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Medford Strikers' AND source_system_id = 1 LIMIT 1),
  61,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7214, 'Anthony Frank', 'Giafaglione')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (62, 7214, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Medford Strikers' AND source_system_id = 1 LIMIT 1),
  62,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7215, 'Rami Mahmoud', 'Nasr')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (63, 7215, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Medford Strikers' AND source_system_id = 1 LIMIT 1),
  63,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7216, 'Todd Richard', 'Salmon')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (64, 7216, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Medford Strikers' AND source_system_id = 1 LIMIT 1),
  64,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7217, 'Matthew David', 'Dottavi')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (65, 7217, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Medford Strikers' AND source_system_id = 1 LIMIT 1),
  65,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7218, 'Mohamed Kasongo', 'Doukoure')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (66, 7218, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Medford Strikers' AND source_system_id = 1 LIMIT 1),
  66,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7219, 'Isaiah Roman', 'Woods-Kolsky')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (67, 7219, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Medford Strikers' AND source_system_id = 1 LIMIT 1),
  67,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7220, 'Noah Sutton', 'Beltran')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (68, 7220, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'WC Predators' AND source_system_id = 1 LIMIT 1),
  68,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7221, 'Jimmy', 'Barrios')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (69, 7221, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Zum Schneider FC 03' AND source_system_id = 1 LIMIT 1),
  69,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7222, 'Athanasio', 'Mertis')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (70, 7222, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Medford Strikers' AND source_system_id = 1 LIMIT 1),
  70,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7223, 'Ibrahim', 'Voglic')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (71, 7223, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Medford Strikers' AND source_system_id = 1 LIMIT 1),
  71,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7224, 'Sean', 'Moffitt')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (72, 7224, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Jersey Shore Boca' AND source_system_id = 1 LIMIT 1),
  72,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7225, 'Yoni Andre', 'Moussodou')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (73, 7225, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Medford Strikers' AND source_system_id = 1 LIMIT 1),
  73,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7226, 'Samuel Tony', 'Zonoe')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (74, 7226, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Medford Strikers' AND source_system_id = 1 LIMIT 1),
  74,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7227, 'Matthew', 'Fernandez')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (75, 7227, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'SC Vistula Garfield' AND source_system_id = 1 LIMIT 1),
  75,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7228, 'David Tai', 'San')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (76, 7228, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Alloy Soccer Club' AND source_system_id = 1 LIMIT 1),
  76,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7229, 'Omar', 'Ahmed')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (77, 7229, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Alloy Soccer Club' AND source_system_id = 1 LIMIT 1),
  77,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7230, 'Gunnar William', 'Christensen')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (78, 7230, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Sewell Old Boys FC' AND source_system_id = 1 LIMIT 1),
  78,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7231, 'Dominic Antonio', 'lodise')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (79, 7231, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Sewell Old Boys FC' AND source_system_id = 1 LIMIT 1),
  79,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7232, 'Cesar Manuel', 'Garcia Peralta')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (80, 7232, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Leros SC' AND source_system_id = 1 LIMIT 1),
  80,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7233, 'Ashton Thomas', 'Parnell')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (81, 7233, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Alliance SC' AND source_system_id = 1 LIMIT 1),
  81,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7234, 'Bradley Hamilton', 'Tidwell')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (82, 7234, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Alliance SC' AND source_system_id = 1 LIMIT 1),
  82,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7235, 'Brendan', 'Zink')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (83, 7235, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Central Park Rangers FC' AND source_system_id = 1 LIMIT 1),
  83,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7236, 'Sean', 'Kane')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (84, 7236, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'NY Athletic Club' AND source_system_id = 1 LIMIT 1),
  84,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7237, 'Aiden Francis', 'Schmitt')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (85, 7237, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Medford Strikers' AND source_system_id = 1 LIMIT 1),
  85,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7238, 'Timothy Joseph', 'Gallagher-De Meij')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (86, 7238, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'NY Greek Americans' AND source_system_id = 1 LIMIT 1),
  86,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7239, 'Miguel Mauricio', 'Diaz Cubas')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (87, 7239, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'NY Greek Americans' AND source_system_id = 1 LIMIT 1),
  87,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7240, 'Amarghaan', 'Hasan')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (88, 7240, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Oaklyn United FC' AND source_system_id = 1 LIMIT 1),
  88,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7241, 'Brandon D', 'Valeri')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (89, 7241, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Real Central NJ Soccer' AND source_system_id = 1 LIMIT 1),
  89,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7242, 'Anderson', 'Martinez')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (90, 7242, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'GAK' AND source_system_id = 1 LIMIT 1),
  90,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7243, 'Arnol', 'Rodriguez')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (91, 7243, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'GAK' AND source_system_id = 1 LIMIT 1),
  91,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7244, 'Trinava', 'Roy')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (92, 7244, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Oaklyn United FC' AND source_system_id = 1 LIMIT 1),
  92,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7245, 'Babacar', 'Ndiaye')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (93, 7245, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Lighthouse 1893 SC' AND source_system_id = 1 LIMIT 1),
  93,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7246, 'Matt', 'Leder')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (94, 7246, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Lighthouse 1893 SC' AND source_system_id = 1 LIMIT 1),
  94,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7247, 'Ruari Eamonn', 'O’Rourke')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (95, 7247, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Buckhead SC' AND source_system_id = 1 LIMIT 1),
  95,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7248, 'Cameron', 'Bonfils')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (96, 7248, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Central Park Rangers FC' AND source_system_id = 1 LIMIT 1),
  96,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7249, 'Angel Javier', 'Rodriguez')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (97, 7249, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Vidas United FC' AND source_system_id = 1 LIMIT 1),
  97,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7250, 'Saahil', 'Nagar')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (98, 7250, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Medford Strikers' AND source_system_id = 1 LIMIT 1),
  98,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7251, 'Jorge Luis', 'Diaz Lobo')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (99, 7251, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Vidas United FC' AND source_system_id = 1 LIMIT 1),
  99,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7252, 'Maudwindo', 'Germain')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (100, 7252, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Hoboken FC 1912' AND source_system_id = 1 LIMIT 1),
  100,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7253, 'Jorge Alberto', 'Nieto Zambrano')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (101, 7253, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Doxa FCW' AND source_system_id = 1 LIMIT 1),
  101,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7254, 'Zachary', 'Gollin')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (102, 7254, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Central Park Rangers FC' AND source_system_id = 1 LIMIT 1),
  102,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7255, 'Jarbis Leonel', 'Green Arzu')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (103, 7255, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Doxa FCW' AND source_system_id = 1 LIMIT 1),
  103,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7256, 'Sean', 'Kenny')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (104, 7256, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'NY Athletic Club' AND source_system_id = 1 LIMIT 1),
  104,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7257, 'Lorenzo', 'Jayakanthan')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (105, 7257, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Real Central NJ Soccer' AND source_system_id = 1 LIMIT 1),
  105,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7258, 'Francis', 'Kanu')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (106, 7258, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Medford Strikers' AND source_system_id = 1 LIMIT 1),
  106,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7259, 'Habiburrahman', 'Emami')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (107, 7259, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Alloy Soccer Club' AND source_system_id = 1 LIMIT 1),
  107,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7260, 'Brayden', 'Schwartz')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (108, 7260, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Hoboken FC 1912' AND source_system_id = 1 LIMIT 1),
  108,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7261, 'Ali', 'Lakhrif')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (109, 7261, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Hoboken FC 1912' AND source_system_id = 1 LIMIT 1),
  109,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7262, 'Sevon Komlan', 'Koudaya')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (110, 7262, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Glastonbury Celtic' AND source_system_id = 1 LIMIT 1),
  110,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7263, 'Joao P', 'Carvalho')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (111, 7263, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Scrub Nation' AND source_system_id = 1 LIMIT 1),
  111,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7264, 'Juan Antonio', 'Gomez')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (112, 7264, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Leros SC' AND source_system_id = 1 LIMIT 1),
  112,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7265, 'Vitor', 'De Oliveira')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (113, 7265, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Zum Schneider FC 03' AND source_system_id = 1 LIMIT 1),
  113,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7266, 'Valentino', 'Martinez')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (114, 7266, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Philadelphia Heritage SC' AND source_system_id = 1 LIMIT 1),
  114,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7267, 'Elvino Tavares', 'Da Silva')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (115, 7267, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Project Football' AND source_system_id = 1 LIMIT 1),
  115,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7268, 'Samuel Armando', 'Perez')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (116, 7268, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Project Football' AND source_system_id = 1 LIMIT 1),
  116,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7269, 'Luiz Gustavo', 'Zanellato')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (117, 7269, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Invictus FC' AND source_system_id = 1 LIMIT 1),
  117,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7270, 'Carl Viggo', 'Sjoberg')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (118, 7270, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'NY Greek Americans' AND source_system_id = 1 LIMIT 1),
  118,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7271, 'Jorge Bladimir', 'Zambrano')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (119, 7271, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Doxa FCW' AND source_system_id = 1 LIMIT 1),
  119,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7272, 'Scott', 'Testori')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (120, 7272, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Glastonbury Celtic' AND source_system_id = 1 LIMIT 1),
  120,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7273, 'Kesner (Jeff)', 'Leon')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (121, 7273, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Real Central NJ Soccer' AND source_system_id = 1 LIMIT 1),
  121,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7274, 'Lorenzo', 'Scala')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (122, 7274, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Jersey Shore Boca' AND source_system_id = 1 LIMIT 1),
  122,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7275, 'Norberto', 'Crespo')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (123, 7275, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Real Central NJ Soccer' AND source_system_id = 1 LIMIT 1),
  123,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7276, 'Alex', 'Lobato')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (124, 7276, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Real Central NJ Soccer' AND source_system_id = 1 LIMIT 1),
  124,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7277, 'Shamar J', 'Kingston')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (125, 7277, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Hermandad Connecticut' AND source_system_id = 1 LIMIT 1),
  125,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7278, 'Lucas', 'Salemme')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (126, 7278, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Alloy Soccer Club' AND source_system_id = 1 LIMIT 1),
  126,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7279, 'Landen', 'Sunday')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (127, 7279, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Alloy Soccer Club' AND source_system_id = 1 LIMIT 1),
  127,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7280, 'Ethan', 'Buss')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (128, 7280, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Alloy Soccer Club' AND source_system_id = 1 LIMIT 1),
  128,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7281, 'Dan', 'Cohen')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (129, 7281, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'NY International FC' AND source_system_id = 1 LIMIT 1),
  129,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7282, 'Gnanai Ghislain', 'Yossou')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (130, 7282, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Philadelphia Soccer Club' AND source_system_id = 1 LIMIT 1),
  130,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7283, 'Nazar', 'Humeniuk')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (131, 7283, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Richmond County FC' AND source_system_id = 1 LIMIT 1),
  131,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7284, 'Michael', 'Rofail')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (132, 7284, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Richmond County FC' AND source_system_id = 1 LIMIT 1),
  132,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7285, 'Rivaldo Baessa', 'Da Silva')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (133, 7285, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Praia Kapital' AND source_system_id = 1 LIMIT 1),
  133,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7286, 'Alexander Charles', 'Patton')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (134, 7286, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Sewell Old Boys FC' AND source_system_id = 1 LIMIT 1),
  134,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7287, 'Jeffery', 'Obiagwu')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (135, 7287, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Medford Strikers' AND source_system_id = 1 LIMIT 1),
  135,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7288, 'Patrick James', 'Fluharty')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (136, 7288, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Medford Strikers' AND source_system_id = 1 LIMIT 1),
  136,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7289, 'George', 'Katsiotis')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (137, 7289, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Philadelphia Soccer Club' AND source_system_id = 1 LIMIT 1),
  137,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7290, 'Kevin', 'McCollick')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (138, 7290, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Oaklyn United FC' AND source_system_id = 1 LIMIT 1),
  138,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7291, 'Maxwell Byrd', 'Hawk')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (139, 7291, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Oaklyn United FC' AND source_system_id = 1 LIMIT 1),
  139,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7292, 'Braden', 'Wandrisco')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (140, 7292, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Philadelphia Heritage SC' AND source_system_id = 1 LIMIT 1),
  140,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7293, 'John', 'Oladele')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (141, 7293, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Lighthouse 1893 SC' AND source_system_id = 1 LIMIT 1),
  141,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7294, 'Mason McGill', 'Fifer')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (142, 7294, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Alliance SC' AND source_system_id = 1 LIMIT 1),
  142,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7295, 'Adrian', 'Segovia Alvardo')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (143, 7295, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Real Central NJ Soccer' AND source_system_id = 1 LIMIT 1),
  143,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7296, 'Nikhil Ashish', 'Verma')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (144, 7296, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'WC Predators' AND source_system_id = 1 LIMIT 1),
  144,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7297, 'Sean Ryan', 'Milelli')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (145, 7297, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Real Central NJ Soccer' AND source_system_id = 1 LIMIT 1),
  145,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7298, 'Ariel', 'Guadalupe')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (146, 7298, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'GAK' AND source_system_id = 1 LIMIT 1),
  146,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7299, 'Jose', 'Botello')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (147, 7299, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'GAK' AND source_system_id = 1 LIMIT 1),
  147,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7300, 'Elijah George', 'Sawyers')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (148, 7300, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'NY Greek Americans' AND source_system_id = 1 LIMIT 1),
  148,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7301, 'Luca', 'Natale')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (149, 7301, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Central Park Rangers FC' AND source_system_id = 1 LIMIT 1),
  149,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7302, 'Anthony', 'Scimeca')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (150, 7302, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Central Park Rangers FC' AND source_system_id = 1 LIMIT 1),
  150,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7303, 'Hamid', 'Afolabi')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (151, 7303, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Philadelphia Soccer Club' AND source_system_id = 1 LIMIT 1),
  151,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7304, 'Jonatan', 'Lopez')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (152, 7304, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Philadelphia Soccer Club' AND source_system_id = 1 LIMIT 1),
  152,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7305, 'Bruno', 'Servisi')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (153, 7305, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Central Park Rangers FC' AND source_system_id = 1 LIMIT 1),
  153,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7306, 'Timothy Francis', 'Kane')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (154, 7306, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Richmond County FC' AND source_system_id = 1 LIMIT 1),
  154,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7307, 'Jose', 'Gil Mejia')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (155, 7307, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'NY Pancyprian Freedoms' AND source_system_id = 1 LIMIT 1),
  155,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7308, 'Romar', 'Frank')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (156, 7308, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Leros SC' AND source_system_id = 1 LIMIT 1),
  156,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7309, 'Kriston', 'Julien')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (157, 7309, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Leros SC' AND source_system_id = 1 LIMIT 1),
  157,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7310, 'Alexander', 'Lara')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (158, 7310, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Lighthouse 1893 SC' AND source_system_id = 1 LIMIT 1),
  158,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7311, 'Aymery', 'Dago Dadie')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (159, 7311, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Oaklyn United FC' AND source_system_id = 1 LIMIT 1),
  159,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7312, 'Emin', 'Gunaydin')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (160, 7312, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Oaklyn United FC' AND source_system_id = 1 LIMIT 1),
  160,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7313, 'Ethan', 'Spinnato')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (161, 7313, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Oaklyn United FC' AND source_system_id = 1 LIMIT 1),
  161,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7314, 'Brahim Hadj', 'Abboud')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (162, 7314, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'WC Predators' AND source_system_id = 1 LIMIT 1),
  162,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7315, 'Rabah', 'Hameg')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (163, 7315, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Oaklyn United FC' AND source_system_id = 1 LIMIT 1),
  163,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7316, 'Kevin', 'Lucero')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (164, 7316, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Doxa FCW' AND source_system_id = 1 LIMIT 1),
  164,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7317, 'Jason', 'Alvarez')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (165, 7317, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Doxa FCW' AND source_system_id = 1 LIMIT 1),
  165,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7318, 'Augustus Manuel', 'Mcgiff')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (166, 7318, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Doxa FCW' AND source_system_id = 1 LIMIT 1),
  166,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7319, 'Andreas', 'Iosifidis')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (167, 7319, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'NY Pancyprian Freedoms' AND source_system_id = 1 LIMIT 1),
  167,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7320, 'Rondell', 'Payne')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (168, 7320, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Central Park Rangers FC' AND source_system_id = 1 LIMIT 1),
  168,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7321, 'Aymen', 'Mohamed')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (169, 7321, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Central Park Rangers FC' AND source_system_id = 1 LIMIT 1),
  169,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7322, 'Lorestho', 'Banks')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (170, 7322, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Medford Strikers' AND source_system_id = 1 LIMIT 1),
  170,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7323, 'Eion', 'Roman')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (171, 7323, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Medford Strikers' AND source_system_id = 1 LIMIT 1),
  171,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7324, 'Rodrigo', 'Fernandez')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (172, 7324, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Medford Strikers' AND source_system_id = 1 LIMIT 1),
  172,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7325, 'Maxwell', 'Anurov')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (173, 7325, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Richmond County FC' AND source_system_id = 1 LIMIT 1),
  173,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7326, 'Ross Lamont', 'Watson')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (174, 7326, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Falcons FC' AND source_system_id = 1 LIMIT 1),
  174,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7327, 'Jesus Gilberto', 'Martinez')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (175, 7327, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Project Football' AND source_system_id = 1 LIMIT 1),
  175,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7328, 'Shane', 'Reid')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (176, 7328, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'NY Athletic Club' AND source_system_id = 1 LIMIT 1),
  176,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7329, 'Marlon', 'Preciado')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (177, 7329, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Hoboken FC 1912' AND source_system_id = 1 LIMIT 1),
  177,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7330, 'Vincenzo', 'Centrella')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (178, 7330, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Hoboken FC 1912' AND source_system_id = 1 LIMIT 1),
  178,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7331, 'Colin', 'Vogel')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (179, 7331, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Terminus FC' AND source_system_id = 1 LIMIT 1),
  179,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7332, 'Delroy', 'Mattis')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (180, 7332, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Terminus FC' AND source_system_id = 1 LIMIT 1),
  180,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7333, 'Gabriel', 'Garreta')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (181, 7333, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Leros SC' AND source_system_id = 1 LIMIT 1),
  181,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7334, 'Alex', 'Lewis')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (182, 7334, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Oaklyn United FC' AND source_system_id = 1 LIMIT 1),
  182,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7335, 'Matthew', 'Pastore')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (183, 7335, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Oaklyn United FC' AND source_system_id = 1 LIMIT 1),
  183,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7336, 'Noah', 'Blodget')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (184, 7336, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Oaklyn United FC' AND source_system_id = 1 LIMIT 1),
  184,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7337, 'Rod Alexander', 'Pobre')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (185, 7337, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Oaklyn United FC' AND source_system_id = 1 LIMIT 1),
  185,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7338, 'Oscar Eduardo', 'Velasquez Centeno')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (186, 7338, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Hermandad Connecticut' AND source_system_id = 1 LIMIT 1),
  186,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7339, 'Samual', 'Craft')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (187, 7339, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'NY International FC' AND source_system_id = 1 LIMIT 1),
  187,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7340, 'Jordan', 'Trott')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (188, 7340, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'NY International FC' AND source_system_id = 1 LIMIT 1),
  188,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7341, 'Johnny Alberto', 'Cruz Chacon')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (189, 7341, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Medford Strikers' AND source_system_id = 1 LIMIT 1),
  189,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7342, 'Jack', 'Blumberg')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (190, 7342, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Medford Strikers' AND source_system_id = 1 LIMIT 1),
  190,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7343, 'Moises De pina', 'Alves')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (191, 7343, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Scrub Nation' AND source_system_id = 1 LIMIT 1),
  191,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7344, 'Maickol', 'Martins')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (192, 7344, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Grove Soccer United' AND source_system_id = 1 LIMIT 1),
  192,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7345, 'Joshua', 'Logan')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (193, 7345, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Alloy Soccer Club' AND source_system_id = 1 LIMIT 1),
  193,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7346, 'Philip', 'Washington III')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (194, 7346, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Philadelphia Soccer Club' AND source_system_id = 1 LIMIT 1),
  194,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7347, 'Diego', 'Rodriguez')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (195, 7347, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Hoboken FC 1912' AND source_system_id = 1 LIMIT 1),
  195,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7348, 'Sekou', 'Keita')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (196, 7348, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Hoboken FC 1912' AND source_system_id = 1 LIMIT 1),
  196,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7349, 'Aly', 'Camara')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (197, 7349, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Leros SC' AND source_system_id = 1 LIMIT 1),
  197,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7350, 'Adnan', 'Zaganjor')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (198, 7350, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Richmond County FC' AND source_system_id = 1 LIMIT 1),
  198,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7351, 'Vassiriki', 'Diaby')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (199, 7351, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Central Park Rangers FC' AND source_system_id = 1 LIMIT 1),
  199,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7352, 'Emmanuel', 'Kieh')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (200, 7352, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Lighthouse 1893 SC' AND source_system_id = 1 LIMIT 1),
  200,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7353, 'Daniel', 'Verdel')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (201, 7353, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Real Central NJ Soccer' AND source_system_id = 1 LIMIT 1),
  201,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7354, 'Jereme', 'Wells')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (202, 7354, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Alloy Soccer Club' AND source_system_id = 1 LIMIT 1),
  202,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7355, 'Stephen Denis Silva', 'Mendes')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (203, 7355, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Scrub Nation' AND source_system_id = 1 LIMIT 1),
  203,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7356, 'Davide', 'Clarkson')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (204, 7356, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'NY Pancyprian Freedoms' AND source_system_id = 1 LIMIT 1),
  204,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7357, 'Denis', 'Kelmendi')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (205, 7357, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'NY Pancyprian Freedoms' AND source_system_id = 1 LIMIT 1),
  205,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7358, 'Colin Forster', 'Davis')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (206, 7358, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'WC Predators' AND source_system_id = 1 LIMIT 1),
  206,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7359, 'Ismael', 'Sorogo')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (207, 7359, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'NY Athletic Club' AND source_system_id = 1 LIMIT 1),
  207,
  NOW()
);

INSERT INTO persons (id, first_name, last_name)
VALUES (7360, 'Elton J', 'Teixeira')
ON CONFLICT (id) DO NOTHING;
INSERT INTO players (id, person_id, source_system_id)
VALUES (208, 7360, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO rosters (team_id, player_id, joined_at)
VALUES (
  (SELECT id FROM teams WHERE name = 'Praia Kapital' AND source_system_id = 1 LIMIT 1),
  208,
  NOW()
);

