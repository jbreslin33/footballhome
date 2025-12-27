-- APSL Players (Linked)

INSERT INTO apsl_players (id, apsl_id, name, license_number, user_id)
VALUES
  ('b3a96ca1-6346-4711-8cc8-965cbcfc9ad2', 'musa-abdelgadir', 'Musa Abdelgadir', NULL, NULL),
  ('c59a4811-9e8c-48f5-8696-08053f99f812', 'amar-abdelrazek', 'Amar Abdelrazek', NULL, NULL),
  ('4f717d33-1252-4b90-8ced-d2ea213e92e1', 'abdelrahman-ali', 'Abdelrahman Ali', NULL, NULL),
  ('cfca239b-ce5b-4cf5-89f7-ca90cf059e2b', 'ahmed-ali', 'Ahmed Ali', NULL, NULL),
  ('249bc9a7-208e-475a-84ea-c15835d7c960', 'erwa-babiker', 'Erwa Babiker', NULL, NULL),
  ('909d4ca8-0e2a-4732-8264-bc96f2b8b640', 'arsene-bado', 'Arsene Bado', NULL, NULL),
  ('7adec5c8-a4e9-45ee-8531-21a79d82617e', 'logan-bersani', 'Logan Bersani', NULL, NULL),
  ('c1eb95d7-720a-4024-8a1b-364da510db4d', 'mohamed-bility', 'Mohamed Bility', NULL, NULL),
  ('bc61fe1c-5d31-4f00-875f-00f4ac1c05ef', 'hamzah-dabbour', 'Hamzah Dabbour', NULL, NULL),
  ('629a2cb1-fea2-4f8c-83fb-bb93b54eef1a', 'terrence-doe', 'Terrence Doe', NULL, NULL),
  ('99ae3950-f247-43d8-8b2d-744cc761e187', 'musa-donza', 'Musa Donza', NULL, NULL),
  ('0bd32008-211c-4f1d-8a5e-7df8d19a0b27', 'alexander-duopu', 'Alexander Duopu', NULL, NULL),
  ('739ea333-3c77-4202-8334-8aee0a2a5015', 'luis-espejo', 'Luis Espejo', NULL, NULL),
  ('e042ecf7-c405-429d-8a35-5424bb840a46', 'christopher-fletcher', 'Christopher Fletcher', NULL, NULL),
  ('2a63b089-7d92-439d-885e-9e1c5adf1a43', 'mujtaba-galas', 'Mujtaba Galas', NULL, NULL),
  ('a4e6d1b5-b22d-4a8b-8756-b6605fe85a67', 'mustafa-galas', 'Mustafa Galas', NULL, NULL),
  ('915f0ee4-cf23-4686-821b-9a3198a3f252', 'john-gonzalez', 'John Gonzalez', NULL, NULL),
  ('269626aa-343f-4358-8070-27d53d3a9552', 'ahmed-gosie', 'Ahmed Gosie', NULL, NULL),
  ('0f283aee-9dbe-4b72-8f1b-c41db0fc3b47', 'maccarrey-guillaume', 'Maccarrey Guillaume', NULL, NULL),
  ('22a3cbc9-34d2-4e11-8388-11b755d5319a', 'otmane-houasli', 'Otmane Houasli', NULL, NULL),
  ('9952e54c-26f3-4712-861c-c7f98b3399c9', 'esnayder-josue', 'Esnayder Josue', NULL, NULL),
  ('055aca13-019f-416a-857b-6a80f17ea21f', 'abdoulaye-kamagate', 'Abdoulaye Kamagate', NULL, NULL),
  ('66ca49aa-ef89-44cd-815c-4e95d26c479b', 'amadou-kamagate', 'Amadou Kamagate', NULL, NULL),
  ('8d780cb8-605b-47c7-8b7f-32da69ef475a', 'majid-kawa', 'Majid Kawa', NULL, NULL),
  ('26dbd58a-f7c2-4d7d-852f-e63a4e9786d0', 'mohamed-khalafalla', 'Mohamed Khalafalla', NULL, NULL),
  ('21f7c518-1b66-4313-8cfc-d7ad89a0359c', 'kouassi-nguessan', 'Kouassi Nguessan', NULL, NULL),
  ('acb58064-6109-4d95-8f15-d84969b004bd', 'benell-saygarn', 'Benell Saygarn', NULL, NULL),
  ('443a8801-5e1a-4f29-8454-2f48b2d1129e', 'oumar-sylla', 'Oumar Sylla', NULL, NULL)
ON CONFLICT (id) DO UPDATE SET
  apsl_id = EXCLUDED.apsl_id,
  name = EXCLUDED.name,
  license_number = EXCLUDED.license_number,
  user_id = EXCLUDED.user_id
;

