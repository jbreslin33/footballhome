-- Migration 009: Populate external_identities with confirmed GroupMe user_id → person_id mappings
-- This ensures sync-groupme-events.js resolves correct person_ids from personCache
-- instead of falling back to the corrupted chat_event_rsvps table.

INSERT INTO external_identities (person_id, provider_id, external_user_id, external_username)
VALUES
  -- APSL Roster: Lighthouse 1893 SC
  (1347, 1, '122495163', 'Musa Abdelgadir'),          -- Musa Abdelgadir
  (1348, 1, '97325370', 'Amar'),                       -- Amar Abdelrazek
  (1349, 1, '48811979', 'Dul'),                         -- Abdelrahman Ali (Dul in APSL, Abdul Ali in Training/Pickup)
  -- Ahmed Ali: not in any chat
  (1351, 1, '94275062', 'Erwa'),                        -- Erwa Babiker
  (1352, 1, '93185527', 'Arsene'),                      -- Arsene Bado
  (1353, 1, '41842904', 'Logan Bersani'),               -- Logan Bersani (also Liga 2)
  (1354, 1, '129019479', 'Bility⚽️'),                   -- Mohamed Bility
  (1355, 1, '85327762', 'Hamzah Dabbour'),              -- Hamzah Dabbour (also Liga 1)
  (1356, 1, '112016720', 'Terrence Forkey Doe Jr'),     -- Terrence Doe
  (1357, 1, '120781414', 'Musa'),                       -- Musa Donza
  (1358, 1, '134880198', 'Alex Duopu'),                 -- Alexander Duopu
  (1359, 1, '72775984', 'Luis 3'),                      -- Luis Espejo (Pickup only)
  (1360, 1, '94024150', 'Chris Fletcher'),              -- Christopher Fletcher
  (1361, 1, '93980449', 'Mujtaba Galas'),               -- Mujtaba Galas
  (1362, 1, '93981417', 'Mustafa Galas'),               -- Mustafa Galas
  (1363, 1, '107847219', 'John Gonzalez'),              -- John Gonzalez (also Liga 2)
  (1364, 1, '28549771', 'Gosie Ahmed'),                 -- Ahmed Gosie
  (1365, 1, '97381953', 'Maccarrey Guillaume'),         -- Maccarrey Guillaume
  (1366, 1, '134164362', 'Otmane Houasli'),             -- Otmane Houasli
  (1367, 1, '134104068', 'Esnayder Josue'),             -- Esnayder Josue
  (1368, 1, '93667641', 'Abdoulaye'),                   -- Abdoulaye Kamagate
  (1369, 1, '135162620', 'The Prince Momo'),            -- Amadou Kamagate
  (1370, 1, '89900747', 'Majid Hamid⚽️'),               -- Majid Kawa
  (1371, 1, '135207508', 'Mohamed Khalafalla'),         -- Mohamed Khalafalla
  -- Kouassi Nguessan: not in any chat
  (1373, 1, '91595946', 'Benell Saygarn'),              -- Benell Saygarn
  (1374, 1, '113152395', 'Oumar Sylla'),                -- Oumar Sylla (away with pro team)

  -- Liga 1 Roster: Lighthouse Boys Club
  (28266, 1, '138758538', 'Weder Junior'),              -- Weder Aguire
  (4401, 1, '90439138', 'VictorB'),                     -- Victor Baidel
  (4406, 1, '138723905', 'Inaldo Francisco Botelho'),   -- Inaldo Botelho
  (4405, 1, '139398148', 'Samuel Francisco Botelho'),   -- Samuel Botelho
  -- Christopher Braz: ambiguous, skipped
  (4407, 1, '85675093', 'Luke Breslin'),                -- Luke Breslin
  (4408, 1, '138636497', 'Walter'),                     -- Walter Candido
  -- Kayke Maciel Da Silva: not in any chat
  -- Nycolas Kayke De Jesus: not in any chat
  (28276, 1, '138632425', 'Clovis Ferreira'),           -- Clovis Ferreira
  -- Cloves Ferreira da Silva Jr: ambiguous (Cloves Junior), skipped
  -- Cloves Filho: ambiguous (Cloves Junior), skipped
  (4414, 1, '123823038', 'Gangue Abouya'),              -- Abouya Gangue
  (28280, 1, '138653291', 'Denis Jhony'),               -- Denis Jhony
  (4416, 1, '106174197', 'Alexander Lara'),             -- Alexander Lara
  (4417, 1, '139393544', 'Pedro Lara'),                 -- Pedro Lara
  -- Reginaldo Leite: not in any chat
  (28284, 1, '72341901', 'Owen Magee'),                 -- Owen Magee
  (19934, 1, '85600311', 'Gian'),                       -- Gian Maldonado
  (4419, 1, '85675094', 'Valentino Martinez'),          -- Valentino Martinez
  -- Weverson Ribeiro Mendes: not in any chat
  -- Lucas Morais: ambiguous, skipped
  (4421, 1, '33127246', 'John Oladele'),                -- John Oladele
  (4422, 1, '131086069', 'Junior Oliveira'),            -- Junior Oliveira
  (4424, 1, '125987196', 'Jemirkel Ornaque'),           -- Jemirkel Ornaque
  (4425, 1, '138651497', 'Marcos Ribeiro'),             -- Marcos Ribeiro
  -- Marcos Santos: ambiguous, skipped
  (28294, 1, '126091017', 'Igor Bonfim'),               -- Igor Santos Bonfim
  (28295, 1, '37940150', 'Cleubimar Teixeira'),         -- Cleubimar Teixeira Souza

  -- Liga 2 Roster: Lighthouse Boys Club U23
  (4455, 1, '129538370', 'Oumar Barry'),                -- Oumar Barry
  (4403, 1, '124568844', 'Aboubacar Bayo'),             -- Aboubacar Bayo
  -- Logan Bersani: already mapped above
  (1, 1, '82634805', 'James Breslin'),                  -- James Breslin
  (4458, 1, '120997626', 'Luis De Jesus'),              -- Luis De Jesus
  (4459, 1, '58578098', 'Marco Delgado'),               -- Marco Delgado
  (4412, 1, '124568365', 'Abdoul Diallo'),              -- Abdoul Diallo
  (4460, 1, '135650171', 'Edwin Garcia'),               -- Edwin Garcia
  -- John Gonzalez: already mapped above
  (4463, 1, '61878175', 'Miles Henry'),                 -- Miles Henry
  (4415, 1, '108086683', 'Andy Hizdri'),                -- Andy Hizdri
  -- Arif Hossain: not in any chat
  (4465, 1, '121062896', 'Zuhaib Imran'),               -- Zuhab Imran
  (4420, 1, '38901068', 'David Masi'),                  -- David Masi
  (4470, 1, '129910157', 'Elmer Diaz'),                 -- Elmer Mendoza (Elmer Diaz in chat)
  (4471, 1, '102647011', 'Dylan Moreno'),               -- Dylan Moreno
  (4473, 1, '125487699', 'Babacar Ndiaye'),             -- Babacar Ndiaye
  (4474, 1, '131505376', 'Zion Nwalipenja'),            -- Zion Nwalipenja
  (4475, 1, '46522836', 'Fabian Padilla'),              -- Fabian Padilla
  (24805, 1, '139387636', 'Matheus Bonvicinio Rodrigues'), -- Matheus Rodrigues
  (4476, 1, '85027218', 'Caleb Rojas'),                 -- Caleb Rojas
  (4477, 1, '70287123', 'Anthony Sagastume'),           -- Anthony Sagustume (The Batman in Pickup)
  (4478, 1, '133693884', 'Ali Salah'),                  -- Ali Salah
  (4479, 1, '133534525', 'Daniel Salamanca'),           -- Daniel Salmanca
  (19423, 1, '138176366', 'Hedayatullah Sangin'),       -- Hedayatullah Sangin
  -- Leo Santa: ambiguous, skipped
  -- Christopher Solis: ambiguous, skipped
  (4482, 1, '108587480', 'Idris')                       -- Idris Washington
ON CONFLICT (provider_id, external_user_id) DO UPDATE SET
  person_id = EXCLUDED.person_id,
  external_username = EXCLUDED.external_username;
