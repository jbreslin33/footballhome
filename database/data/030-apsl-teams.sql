-- APSL Teams

INSERT INTO teams (id, sport_division_id, name, city, logo_url, source_system_id, external_id)
VALUES
  (1, NULL, 'Falcons FC', NULL, NULL, 1, '114814'),
  (2, NULL, 'Scrub Nation', NULL, NULL, 1, '118063'),
  (3, NULL, 'Praia Kapital', NULL, NULL, 1, '114837'),
  (4, NULL, 'South Coast Union', NULL, NULL, 1, '114844'),
  (5, NULL, 'Project Football', NULL, NULL, 1, '114838'),
  (6, NULL, 'Invictus FC', NULL, NULL, 1, '118064'),
  (7, NULL, 'Fitchburg FC', NULL, NULL, 1, '114815'),
  (8, NULL, 'Somerville United FC', NULL, NULL, 1, '131978'),
  (9, NULL, 'KO Elites', NULL, NULL, 1, '114826'),
  (10, NULL, 'Glastonbury Celtic', NULL, NULL, 1, '114816'),
  (11, NULL, 'Wildcat FC', NULL, NULL, 1, '114851'),
  (12, NULL, 'Hermandad Connecticut', NULL, NULL, 1, '114819'),
  (13, NULL, 'NY Greek Americans', NULL, NULL, 1, '114831'),
  (14, NULL, 'Hoboken FC 1912', NULL, NULL, 1, '114820'),
  (15, NULL, 'NY Pancyprian Freedoms', NULL, NULL, 1, '114832'),
  (16, NULL, 'Lansdowne Yonkers FC', NULL, NULL, 1, '114827'),
  (17, NULL, 'Doxa FCW', NULL, NULL, 1, '114813'),
  (18, NULL, 'Leros SC', NULL, NULL, 1, '115315'),
  (19, NULL, 'NY International FC', NULL, NULL, 1, '115102'),
  (20, NULL, 'Richmond County FC', NULL, NULL, 1, '114841'),
  (21, NULL, 'Zum Schneider FC 03', NULL, NULL, 1, '114852'),
  (22, NULL, 'Central Park Rangers FC', NULL, NULL, 1, '114811'),
  (23, NULL, 'SC Vistula Garfield', NULL, NULL, 1, '114842'),
  (24, NULL, 'NY Athletic Club', NULL, NULL, 1, '114830'),
  (25, NULL, 'WC Predators', NULL, NULL, 1, '114850'),
  (26, NULL, 'Alloy Soccer Club', NULL, NULL, 1, '114808'),
  (27, NULL, 'Oaklyn United FC', NULL, NULL, 1, '114833'),
  (28, NULL, 'Real Central NJ Soccer', NULL, NULL, 1, '114840'),
  (29, NULL, 'Philadelphia Heritage SC', NULL, NULL, 1, '114835'),
  (30, NULL, 'Philadelphia Soccer Club', NULL, NULL, 1, '114836'),
  (31, NULL, 'Vidas United FC', NULL, NULL, 1, '114847'),
  (32, NULL, 'GAK', NULL, NULL, 1, '124946'),
  (33, NULL, 'Lighthouse 1893 SC', NULL, NULL, 1, '116079'),
  (34, NULL, 'Jersey Shore Boca', NULL, NULL, 1, '114822'),
  (35, NULL, 'Sewell Old Boys FC', NULL, NULL, 1, '116136'),
  (36, NULL, 'Medford Strikers', NULL, NULL, 1, '115227'),
  (37, NULL, 'Nova FC', NULL, NULL, 1, '114829'),
  (38, NULL, 'VA Marauders FC', NULL, NULL, 1, '114846'),
  (39, NULL, 'Wave FC', NULL, NULL, 1, '114849'),
  (40, NULL, 'PFA EPSL', NULL, NULL, 1, '114834'),
  (41, NULL, 'Grove Soccer United', NULL, NULL, 1, '114817'),
  (42, NULL, 'Christos FC', NULL, NULL, 1, '114812'),
  (43, NULL, 'Delmarva Thunder', NULL, NULL, 1, '118680'),
  (44, NULL, 'PW Nova', NULL, NULL, 1, '114839'),
  (45, NULL, 'Terminus FC', NULL, NULL, 1, '115815'),
  (46, NULL, 'Prima FC', NULL, NULL, 1, '115105'),
  (47, NULL, 'Majestic SC', NULL, NULL, 1, '115108'),
  (48, NULL, 'Peachtree FC', NULL, NULL, 1, '115101'),
  (49, NULL, 'Bel Calcio FC', NULL, NULL, 1, '115106'),
  (50, NULL, 'Buckhead SC', NULL, NULL, 1, '115104'),
  (51, NULL, 'Alliance SC', NULL, NULL, 1, '115107'),
  (52, NULL, 'SC Gwinnett', NULL, NULL, 1, '119159'),
  (53, NULL, 'Sete Setembro USA', NULL, NULL, 1, 'STUB-SeteSetembroUSA'),
  (54, NULL, 'Sete Setembro USA 


				

			
				APSL New England Cup', NULL, NULL, 1, 'STUB-SeteSetembroUSAAPSLNewEnglandCup'),
  (55, NULL, 'Strictly Nos FC', NULL, NULL, 1, 'STUB-StrictlyNosFC'),
  (56, NULL, 'Lithonia City FC', NULL, NULL, 1, 'STUB-LithoniaCityFC')
ON CONFLICT (id) DO UPDATE SET
  sport_division_id = EXCLUDED.sport_division_id,
  name = EXCLUDED.name,
  city = EXCLUDED.city,
  logo_url = EXCLUDED.logo_url,
  source_system_id = EXCLUDED.source_system_id,
  external_id = EXCLUDED.external_id
;

