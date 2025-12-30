-- APSL Players

INSERT INTO players (id, full_name, first_name, last_name, source_system_id, external_id)
VALUES
  (1, 'Musa Abdelgadir', 'Musa', 'Abdelgadir', 1, '116079-musa-abdelgadir'),
  (2, 'Amar Abdelrazek', 'Amar', 'Abdelrazek', 1, '116079-amar-abdelrazek'),
  (3, 'Abdelrahman Ali', 'Abdelrahman', 'Ali', 1, '116079-abdelrahman-ali'),
  (4, 'Ahmed Ali', 'Ahmed', 'Ali', 1, '116079-ahmed-ali'),
  (5, 'Erwa Babiker', 'Erwa', 'Babiker', 1, '116079-erwa-babiker'),
  (6, 'Arsene Bado', 'Arsene', 'Bado', 1, '116079-arsene-bado'),
  (7, 'Logan Bersani', 'Logan', 'Bersani', 1, '116079-logan-bersani'),
  (8, 'Mohamed Bility', 'Mohamed', 'Bility', 1, '116079-mohamed-bility'),
  (9, 'Hamzah Dabbour', 'Hamzah', 'Dabbour', 1, '116079-hamzah-dabbour'),
  (10, 'Terrence Doe', 'Terrence', 'Doe', 1, '116079-terrence-doe'),
  (11, 'Musa Donza', 'Musa', 'Donza', 1, '116079-musa-donza'),
  (12, 'Alexander Duopu', 'Alexander', 'Duopu', 1, '116079-alexander-duopu'),
  (13, 'Luis Espejo', 'Luis', 'Espejo', 1, '116079-luis-espejo'),
  (14, 'Christopher Fletcher', 'Christopher', 'Fletcher', 1, '116079-christopher-fletcher'),
  (15, 'Mujtaba Galas', 'Mujtaba', 'Galas', 1, '116079-mujtaba-galas'),
  (16, 'Mustafa Galas', 'Mustafa', 'Galas', 1, '116079-mustafa-galas'),
  (17, 'John Gonzalez', 'John', 'Gonzalez', 1, '116079-john-gonzalez'),
  (18, 'Ahmed Gosie', 'Ahmed', 'Gosie', 1, '116079-ahmed-gosie'),
  (19, 'Maccarrey Guillaume', 'Maccarrey', 'Guillaume', 1, '116079-maccarrey-guillaume'),
  (20, 'Otmane Houasli', 'Otmane', 'Houasli', 1, '116079-otmane-houasli'),
  (21, 'Esnayder Josue', 'Esnayder', 'Josue', 1, '116079-esnayder-josue'),
  (22, 'Abdoulaye Kamagate', 'Abdoulaye', 'Kamagate', 1, '116079-abdoulaye-kamagate'),
  (23, 'Amadou Kamagate', 'Amadou', 'Kamagate', 1, '116079-amadou-kamagate'),
  (24, 'Majid Kawa', 'Majid', 'Kawa', 1, '116079-majid-kawa'),
  (25, 'Mohamed Khalafalla', 'Mohamed', 'Khalafalla', 1, '116079-mohamed-khalafalla'),
  (26, 'Kouassi Nguessan', 'Kouassi', 'Nguessan', 1, '116079-kouassi-nguessan'),
  (27, 'Benell Saygarn', 'Benell', 'Saygarn', 1, '116079-benell-saygarn'),
  (28, 'Oumar Sylla', 'Oumar', 'Sylla', 1, '116079-oumar-sylla')
ON CONFLICT (id) DO UPDATE SET
  full_name = EXCLUDED.full_name,
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  source_system_id = EXCLUDED.source_system_id,
  external_id = EXCLUDED.external_id
;

