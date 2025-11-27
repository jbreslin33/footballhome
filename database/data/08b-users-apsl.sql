-- ========================================
-- PLAYER USERS
-- ========================================
-- Generated: 2025-11-27T18:48:57.064Z
-- Source: https://apslsoccer.com/standings/
-- AUTO-GENERATED - DO NOT EDIT MANUALLY
-- Run scraper to regenerate: node database/scripts/apsl-scraper/scrape-apsl.js
-- ========================================


-- Note: Scraped users have no email/password (roster display only)
-- They cannot log in until they register with a real email

-- ========================================
-- Falcons FC USERS
-- ========================================
INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'bc489e31-18bc-0006-a453-a1da54ab1446',
  'Sahil',
  'Banerjee',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5c49e2e2-ad5a-0006-4ee3-c305215128b6',
  'Massimiliano',
  'Bruno',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '44233d63-78ce-0006-fba1-efb396772745',
  'Kevin',
  'Alves Cruz',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'cef50d30-87ca-0006-e62e-586822754925',
  'Ryan',
  'Cura',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '12a2383c-60bb-0006-1dda-c7de7f7d611b',
  'Emilano',
  'De La Macorra Cardoso',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '96edffa8-9590-0006-537d-d1cf9698b6af',
  'Jeffery',
  'Dietrich',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5f7550f1-4427-0006-e9b4-17fcb0616453',
  'Claudio',
  'Dragonetti',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '0525d425-621f-0006-62de-510cae6fd084',
  'Miguel',
  'Enriquez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '6fe50e6b-0e35-0006-bb79-8e7972576724',
  'Charles',
  'Esber Tavares',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7105e742-14b9-0006-8794-9e89e12909af',
  'Kaven',
  'Fitch',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '65e6160f-d2cf-0006-eb04-f6fb96833838',
  'Vincenzo',
  'Fuentes',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c34fb70d-e482-0006-7754-fede765c55c5',
  'Payson',
  'Goyette',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '2150f8f1-31b3-0006-bb23-de553501906f',
  'Pano',
  'Haseotes',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '555ce01d-d87c-0006-7f51-f5c20b9eadd9',
  'Aidan',
  'Hayes',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '27cff52f-9ae4-0006-bbbf-a7e052013510',
  'Samuel',
  'Hong',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c599e90f-95a9-0006-2a35-9f8b78e00617',
  'Santiago',
  'Kadadihi',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd8ca8762-1ceb-0006-c985-141d72472997',
  'George',
  'Karafilidis',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5697dad8-3dda-0006-4855-fed317e341f4',
  'Jeremy',
  'Kim',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '3e76b025-3d56-0006-84b9-5988816cdf5d',
  'Eduardo',
  'Marquez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c7e8e40b-a6ee-0006-665e-a1cff34e8344',
  'Nicolas',
  'Martignoni',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '6dacb1d8-4f2c-0006-ff1f-f12c5be652fb',
  'Evan',
  'Mendonca',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '98edbbe5-bedf-0006-9640-a2fae231a640',
  'Pablo',
  'Montilla',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e3147dfa-0665-0006-60ba-048be198d406',
  'Lucas',
  'Ortega Morales',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e502d959-35b0-0006-483a-ae7c34bff8f0',
  'Nicholas',
  'Stephen Pierangeli',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '52ff2ff0-b13e-0006-c23e-e5e01fdfa7fa',
  'Mario',
  'Ruiz Perez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ccc170f7-1eb6-0006-d33d-d1f71448291b',
  'Edwin',
  'Saravia',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'fb16d670-27ac-0006-f947-7b777ef10d1a',
  'Caio',
  'Soares',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd41ea3ec-cd94-0006-234d-aacf9edfc357',
  'Johner',
  'Soe',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '2afa19f0-f49f-0006-c547-1ccd646572a1',
  'Luka',
  'Szymanski',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b4c0189d-9672-0006-4213-e0b09465c3a8',
  'Ross',
  'Lamont Watson',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Praia Kapital USERS
-- ========================================
INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e31dba3c-4c9e-0006-fdf0-2ce96a1d0cf1',
  'Mario',
  'Amado',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'fd343c92-76fb-0006-ca08-e3a723a8cc6b',
  'Brenner',
  'Cardoso',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f851644e-6cb9-0006-5aa8-a632a57078c0',
  'Wendy',
  'Celestin',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '87b7b08f-477a-0006-c0de-6d9d207b87da',
  'Denilson',
  'Barros Centeio',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a2ebd11d-73f2-0006-22d7-108df2b98cad',
  'Jacinto',
  'Correia',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c3292d68-7400-0006-97b9-a6ffe6203b7d',
  'Edson',
  'Andarade Da Silva',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7c1d32d7-e7ce-0006-ae30-5a70828f17fc',
  'Fabio',
  'Pires Da Silva',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'fccb2dbc-232f-0006-1f9b-144f11e0d69e',
  'Rivaldo',
  'Baessa Da Silva',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '86409dff-160f-0006-54e3-3fdb87d5cb6a',
  'Heracles',
  'De Pina Fernandes',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'fd088c7b-7038-0006-1bd0-8b78434937f3',
  'Paulo',
  'De Pina Goncalves',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e83b1a8e-c742-0006-5175-c43e0dffcef9',
  'Valdir',
  'Depina',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '88844133-cc21-0006-a9fb-dacb5b6b84bb',
  'Isandro',
  'Fernandes Lopes',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '2e0c45ff-6275-0006-9117-e96c2ed11875',
  'Mario',
  'Figueroa Garcia',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '3dfb6f5b-096c-0006-c0de-68202a0d9faa',
  'Adilson',
  'Gomes',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f95dbd22-4646-0006-aada-9a12965ee8ae',
  'Clayton',
  'Gomes',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd90af098-0a64-0006-3c03-d13566b89e37',
  'Estevao',
  'Gomes',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ee7421f3-c84c-0006-1ca0-c982c2fcb5d9',
  'Jair',
  'Gomes De Pina',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '387aa92c-35b5-0006-9106-89bf626a2a9b',
  'Jose',
  'Gomes Rodrigues',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd84b1454-08e0-0006-9959-17e52024b912',
  'Papa',
  'Ndiaye',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '861a9259-8263-0006-cba5-08bb38bed8b1',
  'Lucas',
  'Nogueira Monteiro',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c319fa3b-42fc-0006-2d45-554b851e072d',
  'Nima',
  'Norouzi Behjat',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '61811672-a748-0006-471a-ff078e1d948a',
  'Imauro',
  'Pina',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '143a5631-da25-0006-934a-d1948f94e21b',
  'Mauro',
  'Pires Amado',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f977223a-11d9-0006-9961-46111a0a54c8',
  'Anthony',
  'Ramos',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ee9f6275-f535-0006-51f3-ff103380cd5d',
  'Jose',
  'Rodrigues Teixeira',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7f8e5e32-65a7-0006-9a6c-ac1ffb0b2091',
  'Djeison',
  'Rodrigues Vieira',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '91df8aa5-b523-0006-893e-b6fad4068325',
  'Tahir',
  'Akil Scott',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7e7daebe-d025-0006-e8b6-600df20ada67',
  'Ronilson',
  'Semedo',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '18dc5113-3f83-0006-81fc-f69045394f51',
  'Francisco',
  'M Silveira',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '460efcef-562c-0006-8924-923906fa19fa',
  'Yassine',
  'Smissame',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '54f00ed5-af3a-0006-4804-3c28b8407d25',
  'Kevin',
  'Sos Santos Barbisa',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'aa8cdd1f-2f60-0006-7d61-82fcf619ca06',
  'Domingos',
  'Tavares',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '1a62fb6b-513c-0006-eb2b-803d32eeb8c1',
  'Edson',
  'Irlandino Tavares Dossantos',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '46d71052-d92c-0006-5590-45bdde73a9c4',
  'Elton',
  'J Teixeira',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Scrub Nation USERS
-- ========================================
INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'be3d7a2f-4376-0006-68de-3edfc7b28db2',
  'Moises',
  'De pina Alves',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '4d2a7ae1-7725-0006-6808-c3504221f691',
  'Jack',
  'Aronson',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '344bb3ac-f5c7-0006-a175-b4f77514ee1e',
  'Joao',
  'P Carvalho',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '915c256d-cd85-0006-5dae-e10ff96b98b1',
  'Mana',
  'Chavali',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '6aa8ad86-e544-0006-c25c-13cf3bc8a7b8',
  'Suri',
  'Chavali',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '1a804906-0737-0006-ead8-7359e6369a82',
  'Brendan',
  'Claflin',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'cfae0a60-470c-0006-dec9-0921dfe37b17',
  'Matthew',
  'Daniel Cosentino',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f7f32808-0086-0006-9153-171e8d9ca239',
  'Patrick',
  'Davison',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '38771ca6-bb8d-0006-b759-dd63ba4aebc0',
  'Joao',
  'Paulo De Mattos Almeida',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ff2c7239-bf24-0006-f246-bb2a8f522ce8',
  'Manuel',
  'António Depina',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b11ac0fc-30c2-0006-c648-7fa2f00debcf',
  'Michael',
  'Eve',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '3edd6e07-6c67-0006-2909-80d45f2e7f98',
  'Nicholas',
  'Falcone',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '98a0f920-cfc2-0006-b109-c9ec48b1ea03',
  'Jackson',
  'Faulx',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e87e38b3-aeaf-0006-5e85-a29f4b90b609',
  'Luke',
  'Hanchar',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '549cbadd-88ab-0006-fc0f-bd5e4dec4835',
  'Oswaldo',
  'Hernandez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ce0cf326-8d32-0006-ec20-e214cca9d975',
  'Martin',
  'Konstantinov',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '01337fcc-e21f-0006-b2c6-f34a59455b17',
  'Kyle',
  'Lasewicz',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a0306b79-daa2-0006-f039-827bf55a2191',
  'Surya',
  'Mani',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '77bfd936-9f9e-0006-2674-a6c08b37d6c5',
  'Christian',
  'Martins',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7ef823de-425f-0006-2d47-2e5452ea2530',
  'Gilson',
  'Martins',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '796ba022-c23e-0006-e946-77db796e9276',
  'Stephen',
  'Denis Silva Mendes',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f364b18e-75ce-0006-23b6-8ea676bd145b',
  'Chad',
  'Meyers',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e5ca9bf6-52a9-0006-1daa-611075d43f4f',
  'Charles',
  'Miller',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a7173bd9-7c14-0006-4e7c-08f8efab1643',
  'Jonathan',
  'Ernesto Rodriguez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'be3bd06d-a787-0006-b39c-2ae228eea7e7',
  'Carlos',
  'Rojas',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a5d9baf3-6a3a-0006-e6fd-4794e43fbbe1',
  'Jaderson',
  'Rutsatz',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '45eb279e-b74f-0006-f259-aea2be6a1d51',
  'Alexander',
  'Shanley',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '4edd8614-2f67-0006-3a05-0892d106456d',
  'Griffin',
  'Sisk',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e599b337-fac7-0006-f3c5-90909853eaff',
  'Daniel',
  'Soto',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'fbfbf8d3-8ee0-0006-fe9c-29d05b143241',
  'Elisandro',
  'Tavares',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd7ffb471-2676-0006-f95d-26a39cc04bbb',
  'Nick',
  'Winn',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a9de40d1-c601-0006-0711-84658df6ac16',
  'Jackson',
  'Yager',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Sete Setembro USA USERS
-- ========================================
INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b805f9cd-d99f-0006-2b30-0e5e9efc5d9e',
  'Lucas',
  'Almeida',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ad0a7afa-cbbf-0006-beea-1cdb62b3bc04',
  'Leandro',
  'Alves',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '2ba78fb6-7730-0006-4172-22a034b34088',
  'Alvaro',
  'Barbosa',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'fbd55b3f-5e27-0006-883d-e046fe290291',
  'Gustavo',
  'Candido',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '96c53b27-5d7e-0006-65b6-b0f3fbaca193',
  'Gabriel',
  'Cassemiro',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'aa22f51e-5de6-0006-98e2-f9079d1613ea',
  'Eduardo',
  'Chirico',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f0655170-d9e9-0006-978b-483b31983cdd',
  'Antonio',
  'Correa',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '67740030-97a4-0006-280f-cc1f13b1e255',
  'Gabriell',
  'De Godoi',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '4fe2b6e1-8d05-0006-226a-a28657994c74',
  'Wengleiman',
  'Peres De Souza',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '2e2cb1a2-fe0a-0006-2649-bcdeb4436bc5',
  'Ronaldinho',
  'Diniz',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '88b47d44-a149-0006-9444-2cc4d4fb2961',
  'Gabriel',
  'Vitalino Ganzer',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '1418c449-fd62-0006-a285-55b329394a2a',
  'Kellvy',
  'Garcia',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'faa11526-7892-0006-dc3d-fd57456a213a',
  'Christian',
  'Godinho',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'cd99faae-a3d3-0006-4af4-e571024a2595',
  'Maldini',
  'Goncalves',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '1fcc7b93-56ab-0006-be90-7186bbe5b70e',
  'Jonatas',
  'Paulino da Silva Inácio',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '4c17c769-2841-0006-1f40-9924e0f0d5a3',
  'Lucas',
  'Silva Juni',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '8b2b26ad-a878-0006-b329-4a6e0f9d8134',
  'Ryan',
  'Lima',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7fb6aeee-b8cc-0006-30ca-9c09bacd6752',
  'Euclides',
  'Medonca',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '15c20db8-1cfb-0006-572f-598bbe571d36',
  'Yago',
  'Miller',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '02e633e0-a6f0-0006-2d5f-e6142c7d5ab0',
  'João',
  'Miranda',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '4d77edc1-3134-0006-e066-c85ad5063669',
  'Steven',
  'Monsalve',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5f0673f4-88a9-0006-efbe-97103612c96f',
  'Alisson',
  'Monteiro',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '91c9e28d-a721-0006-c1d6-20afcb47bffd',
  'Wenderson',
  'Pereira',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '994b69a3-0902-0006-bd7d-303d49fed728',
  'Mario',
  'Prata',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd2e64ce3-0004-0006-500e-c570d51f7d55',
  'Andy',
  'Ramirez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f836061e-6ad9-0006-b2c3-fa14a5e0b392',
  'Dennis',
  'Ramirez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '60638c8d-c0ec-0006-cfef-41dc7bb448f3',
  'Marcos',
  'Santos',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e2e1a231-9e79-0006-c658-4d7ed24665a0',
  'Kaio',
  'Silva',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '6e02be28-fe46-0006-f2d2-378d8760f22e',
  'Luís',
  'Felipe Silva',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '442c991c-6a42-0006-02fb-cec5e84d2754',
  'Meny',
  'Silva',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'db11cca5-236b-0006-ffa5-74c46334b09c',
  'Jose',
  'Tavares',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'cab797c0-61ba-0006-993d-f655a32eceee',
  'Waverton',
  'Teodoro',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5e53ea04-acc2-0006-8a4d-7b054044dd2b',
  'Patrick',
  'Vilela',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '6f17adcc-822c-0006-9e1f-5281b9caff2b',
  'Michael',
  'Willis',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '3ead43ee-e5ff-0006-76d1-0395147c4c2f',
  'William',
  'Zanetti',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- South Coast Union USERS
-- ========================================
INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '10ecbb9b-0bd0-0006-bdd8-445c5d1717bc',
  'Daniel',
  'Andrade',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '34f1600f-adf8-0006-dfda-15462bac8226',
  'Edmilson',
  'Andrade',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c23c93e0-9cad-0006-afc1-6235a4ad738e',
  'Damian',
  'Anerdson',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ff674b3a-faef-0006-fbe4-4a3b144c9ecc',
  'Ronis',
  'Ayala',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5c805dc1-2758-0006-ac5c-462d53a94e2e',
  'Dominique',
  'Baessa',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '3a3719c7-2f13-0006-15c1-c40303655920',
  'Gio',
  'Barros',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '8a6fcc5e-1bc5-0006-3068-79046e5cae88',
  'Justin',
  'Barros',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '651b275c-f3cc-0006-4bb5-990300b973fd',
  'Dominek',
  'Borden',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '4c6ea97a-d6df-0006-8a7b-a93004d8d5ae',
  'Edemilson',
  'Candida',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b1748e0b-510e-0006-6e09-5b8d25bdf091',
  'Kevin',
  'Correia',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '81a73122-bcf3-0006-f11a-f206cd1745a6',
  'Neil',
  'Cunha',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f1ed8d5a-33c2-0006-115c-9eb7f9d9b888',
  'Mason',
  'Dealmeida',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd0d24d06-6d6b-0006-18c7-9575e2e2e069',
  'Clayton',
  'Demelo',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '94fb4cb6-a95d-0006-f754-e6466e24dee3',
  'Ethan',
  'Demelo',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '552ce04a-b591-0006-88f7-de0f94e2b1a9',
  'Dawson',
  'Dosvais',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '28a8bb17-4d16-0006-0028-da0580db557d',
  'Zajdele',
  'Dulcine',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '6c83864c-6e38-0006-28da-f08583c72161',
  'Augustin',
  'Edwin',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e243f53c-85e7-0006-766e-5ccb69f3784f',
  'Austin',
  'Eugenio',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'cf933db5-a8bf-0006-3336-30343a66d5d1',
  'Malaquias',
  'Tavares Garcia',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '079f7d10-c366-0006-fa39-78982b0f039a',
  'Michael',
  'Garcia',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '3c41b15d-252e-0006-5f38-cf97c6e10144',
  'Damon',
  'Greene',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '1a1027b0-f8b9-0006-3db6-7a4f3dba6a79',
  'Ricardo',
  'Macedo',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '395e2bcd-42dc-0006-7916-9b2466201f24',
  'Sam',
  'Matias',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'fc9fbe96-6ecd-0006-be37-ca4dda669e73',
  'Dylan',
  'Mendes',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5faa0ce1-4a64-0006-5522-0902ddefe4bd',
  'Jose',
  'Carlos "Ze" Mendes',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '278a5f89-bea1-0006-e887-428d019e47ea',
  'Ethan',
  'Paiva',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '52a44609-34de-0006-094d-33f59224d07f',
  'Joey',
  'Paiva',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '321bd71d-8542-0006-7c9d-2fe8ae1e0eaa',
  'Colin',
  'Pereira',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '6a37adef-bedf-0006-ddd0-9a36ebec529e',
  'Jacob',
  'Ramos',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5c419fc1-ab1a-0006-f3b5-f351e84df834',
  'Rafael',
  'Raposo',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd8e97420-1285-0006-5513-404fa75107dd',
  'Dylan',
  'Senra',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ba018c0d-f768-0006-d9cf-2193f8f2f02e',
  'Flavio',
  'Joel Soares Carvalho',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '1f74c66f-9602-0006-68a0-662831cf0bdb',
  'Christian',
  'Sousa',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Project Football USERS
-- ========================================
INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c204662d-9f60-0006-caee-ac59cfb099d0',
  'Wilson',
  'Omar Amaya Lara',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '239eb9d0-3eee-0006-bb8a-f09144263e3c',
  'Jessiel',
  'Alexander Amparo',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '9ed8d835-8faa-0006-e5f7-12baeea8b890',
  'Minor',
  'Ojanny Angel Merida',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c4180da0-d916-0006-1eee-ce86df4d0bc3',
  'Yaw',
  'Bediako',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '3f4e76f5-fef0-0006-891d-f85b037d8c25',
  'Elvino',
  'Tavares Da Silva',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '8bfdfed4-85cf-0006-70e1-52988ce09171',
  'Delvino',
  'Tavares Dasilva',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7c94eb3f-e6f9-0006-6112-e9a564fc6ddc',
  'Jamel',
  'Anch David',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '621baa97-98c1-0006-1aee-818e144a3d36',
  'Henry',
  'Edeko',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c0e3e73b-88bd-0006-5171-ddfa2c9c0612',
  'Ayoub',
  'Essaoui',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'edfd7120-4ab2-0006-c84f-02c2e467dc81',
  'Jackson',
  'Fernandes',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ac7c1c91-5031-0006-0fe4-cf975651136d',
  'Carlos',
  'Augusto Gomez Hernandez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '6839aa1b-1afc-0006-caad-5479792ec33e',
  'Braulio',
  'Gonzalez Oliveria',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '770a8af1-322c-0006-c3d2-08727477b38e',
  'Alejandro',
  'Alfonso Guerrero Vargas',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b29f8397-0d3a-0006-f3b9-24d8cbb8331d',
  'Kenneth',
  'Jared Ibarra Suarez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '74591340-f72d-0006-70b2-bda972ba6a77',
  'Aeshan',
  'Kapil',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b8f6b84b-3d4e-0006-6297-d154a8f0bac0',
  'Jesus',
  'Gilberto Martinez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f9975947-d492-0006-14ac-de306351d4f7',
  'Ricosta',
  'Mede',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '2ee6e097-2dcb-0006-bb47-e316edb83617',
  'Sheventz',
  'Multy',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '62c849af-fe31-0006-5776-f9c667a10f28',
  'Samuel',
  'Armando Perez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'de4f5a6f-574d-0006-531a-cccec1e6ca19',
  'Aiden',
  'Thor Perry',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a3dc3f02-8ce8-0006-07f5-c448faef633b',
  'Alex',
  'Andrade Pina',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e74366d4-73c8-0006-ddb1-39d1296909eb',
  'Connor',
  'Poliquin',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7ef66a1a-d185-0006-aee8-c5579114f24e',
  'Timothy',
  'Singleton',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '06243baf-d088-0006-eafa-67c39d788523',
  'Francisco',
  'Aron Villacorta',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ffa8e7ba-cf9d-0006-7871-c460998a4685',
  'Benjamin',
  'Watts',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Invictus FC USERS
-- ========================================
INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a66b07d6-2ab5-0006-57aa-082db8b74bdf',
  'Mo',
  'Amine Faleh',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '9a7d998e-1d25-0006-f724-d933629c8207',
  'Ludwin',
  'Daniel Carranza',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '9a83db4e-1dd0-0006-32fa-54dc21a6f60f',
  'Albert',
  'Daniels',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '57a816c2-bdf9-0006-e504-2ed18888c2d3',
  'Yassine',
  'ElBasli',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a3b2ed71-39cd-0006-5ecc-0aeaba491fcb',
  'Eduardo',
  'Engst-Mansilla',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '06a72c5f-1933-0006-15c4-5ff419ac14a0',
  'Kerllon',
  'Silva Felipe',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'daad7aae-617f-0006-1ead-adc8335cf265',
  'Cole',
  'Fergusson',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '79168662-5a95-0006-79a6-50ce7e49bc60',
  'Joao',
  'Victor Ferreira',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '4e3dbb85-2833-0006-2e3c-7d8afa40a7cb',
  'Carl',
  'Foming',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '0d6c31d5-4891-0006-4d5d-32081b61a344',
  'Jackson',
  'C Gilstrap',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '9d9fa60a-db7d-0006-8d73-bfff050ae4f4',
  'Bernadin',
  'Herard',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '80a6f9b6-f7fe-0006-0fa0-84a1e86ec589',
  'Juan',
  'camilo Hernández',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '1b1f5065-833d-0006-4c44-eb08b66ac909',
  'Delices',
  'Keyri',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '77ea7aac-0609-0006-d415-563921a3ea66',
  'Hindolo',
  'Brima Mansaray',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '017d8a53-30c9-0006-d1f4-aaafbdf7fa54',
  'John',
  'Massaquoi',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '910e8d67-6fb5-0006-510b-aa9a4047dece',
  'Vincent',
  'Miller',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e41dc2df-b495-0006-a24b-019d76ec0bd3',
  'Hassan',
  'Mutaasa',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '4e8b195f-f1de-0006-5d6b-d7e3d196a59f',
  'Amadou',
  'Moustapha Ndiaye',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c8b24d17-62ab-0006-9dfe-363294648bdc',
  'Carl',
  'Olivier',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '6af5cba8-ed0f-0006-4be5-e819d4693911',
  'Roodchyl',
  'Samuel Pauleon',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5f93ebc7-c756-0006-fa25-659b100c2dc3',
  'Jaydon',
  'Perez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '99f05cfe-412a-0006-225a-1fe7e703fe9b',
  'Joseph',
  'Saidu',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '038eb4f3-7a89-0006-b4e2-f7dd2e34f47b',
  'Destin',
  'Sleeter',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '275f1c7b-9a07-0006-db05-4756c954d60c',
  'Pierre',
  'St Simon',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '67f4b8e1-78ab-0006-df89-1ac992184b1c',
  'Isaiah',
  'Stessman',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e30f59ac-9cd7-0006-ec64-2480e687cb4d',
  'Carlos',
  'Teixeira',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '329491a1-e4e0-0006-da14-f249b90d3a07',
  'Hamza',
  'Tribia',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '71bf6e6e-b8e3-0006-de46-e20418c83583',
  'Luiz',
  'Gustavo Zanellato',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7b4104c2-0fe7-0006-654d-b4c4b6804182',
  'Abraham',
  'Zepeda',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Fitchburg FC USERS
-- ========================================
INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a671dba9-3e70-0006-26f2-1c4186d54162',
  'Mustapha',
  'Ait Zbair',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'bca35d65-8a83-0006-1320-431e9de0c0ce',
  'Joshua',
  'Atemkeng',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'dbb7229c-8270-0006-fcb8-0e745dabcd98',
  'Ousmane',
  'balde',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '758835ce-e148-0006-2ee1-3613ccf3f3d4',
  'John',
  'Brewer',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'af00fbbf-c4ce-0006-708f-7358ac54bcd9',
  'Oscar',
  'Castillo',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '2e57d3f4-039d-0006-1959-f0aee20918a6',
  'Edmond',
  'Charles',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a715418f-b746-0006-0cd5-5f6f698465b0',
  'Dimitri',
  'Costa',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '9fa25e9e-eef5-0006-0394-3175de0b12aa',
  'Hamza',
  'El Amane',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7a2016e4-8671-0006-d680-e641a1806a0a',
  'Mohamed',
  'El-Rhoufi',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '392c3cec-b2c2-0006-d412-7b3d6996a439',
  'Hyacinth',
  'Fongang',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '3cb5654d-6c95-0006-c730-e6f73d96e27b',
  'Metayer',
  'Gassamar',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'fcdff43d-e43b-0006-b34c-a237391d430c',
  'Abubakar',
  'Sidiq Hamidu',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '25d98e29-5e85-0006-ab24-65bc2b00484b',
  'Diallo',
  'Ibrahima',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b7cc2568-7503-0006-d130-a64c1e902d68',
  'Ralph',
  'Jean Baptiste',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '05d8fe76-30b3-0006-8751-3362b6a4febd',
  'Root-mael',
  'Jean Baptiste',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '9383a7dc-1c28-0006-ce1b-27b7cbaa0a38',
  'Cedrick',
  'Labah',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '77718982-2e27-0006-2419-c0d6331edb8d',
  'Bruno',
  'Lana',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a6473cf1-c0db-0006-4eb3-5ea8059d1c1f',
  'Longtse',
  'Mofor Landoh',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '95f52929-41c9-0006-bddb-59a5c18f383c',
  'Roberto',
  'Martinez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a5468844-44db-0006-84cc-32c6775c6ad3',
  'Quang',
  'Milligan',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '18f25be9-0c86-0006-d5a9-b92e31bef6af',
  'Bonjoh',
  'Ngoasong',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ec447434-4c7c-0006-789e-800b261905c0',
  'Sydiney',
  'Nyabiosi',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '74b629c4-a0aa-0006-4629-5802b129b2ec',
  'Pedro',
  'Pedrine',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c2e6c31c-0072-0006-fbee-9c750f89afb2',
  'Marc',
  'Hattley Pierre',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c1c38b99-1c40-0006-89b6-85708049f865',
  'Luvensky',
  'Polycarpe',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b3a9c857-deda-0006-786e-d3de80fa274d',
  'Angelo',
  'Ramirez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5c473b7c-6b1e-0006-bb55-4180e2e04496',
  'Emerson',
  'Roman',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b306474b-1ffe-0006-a735-b981a3cd1445',
  'Yostin',
  'Roman',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '6592a105-8a22-0006-bcad-923a9459c8ab',
  'Shelton',
  'Sidelca',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '1858b63d-d30f-0006-3a86-388cddd478ad',
  'Redwane',
  'Tinfle',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '194d4334-ce0c-0006-83eb-9ab934e83366',
  'Nelvin',
  'Vando',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '83623023-d72b-0006-ff08-074e6c44c04d',
  'Jonathan',
  'Vazquez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c1f9df67-2c98-0006-e46a-c9329a8e6e45',
  'Ethan',
  'Vitello',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '9e1e92a5-11bc-0006-816b-4bdada1e7203',
  'Trevor',
  'Voisine',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7281b6d1-afe4-0006-123a-6f5c795fc86f',
  'Zamy',
  'Youri Ansley',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- KO Elites USERS
-- ========================================
INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5f48257b-a7b5-0006-04ac-22c18c9e56b0',
  'Meysar',
  'Abdulkadir',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '237d597c-50c6-0006-a342-8393585a6715',
  'Joel',
  'Agebtossou',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '45fca129-8a8b-0006-5098-ea71919a3695',
  'Davaughn',
  'Anderson',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'fdf168a7-0286-0006-b80e-36e847aeb353',
  'Deante',
  'Anderson',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '86ba5169-0de5-0006-292f-4fd73d64ee17',
  'Jimmy',
  'Arita',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '79210fc4-505f-0006-8d9c-be8f8d1a94ae',
  'Ben',
  'Awashie',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '6534d258-3549-0006-c0fe-6a2357fb307e',
  'Alessandro',
  'Bacabac',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '14d57c63-86cf-0006-8d3f-aa11be0c7880',
  'Dejaun',
  'Beckford',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f580334c-e0f6-0006-10bb-7fda0692c7bb',
  'Joseph',
  'Boakye',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '642ae3c8-5827-0006-bbc3-6bfd378b6724',
  'Alexander',
  'Clarke',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'cb31b213-3307-0006-fa04-c693827fb673',
  'Caleb',
  'Ennin',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '3efb2a30-fb95-0006-a230-6f961d28b22a',
  'Tim',
  'Ennin',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'eda54837-0d78-0006-c453-6a01929cede9',
  'Shaquan',
  'Facey',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '8b077d33-9688-0006-fb1b-db44abff91ea',
  'Jahvanni',
  'Grant',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ab4496ad-bb66-0006-b0d6-de990feece38',
  'Elian',
  'Guaman',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd7e9cb9e-9080-0006-1cf6-e8df22fcf626',
  'Dax',
  'Hoffman',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '28a701f3-5454-0006-022e-df02a0ab4469',
  'George',
  'Jimenez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '9b971125-784e-0006-df3a-33271e15435b',
  'Gideon',
  'Kadiri',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '455f1f4e-9c57-0006-1de6-a4857a83995b',
  'Jaheim',
  'Kennedy',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd76a8c4a-8ee3-0006-01f6-4af2f451eae7',
  'Brenden',
  'Landry',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '1fcb7ab6-f801-0006-b409-63fdaebdb1a1',
  'Shani',
  'Miller',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '46499662-a1fa-0006-a2a1-7fa4bcaec798',
  'Kwesi',
  'Mills-Odoi',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f1fae5ea-f343-0006-2068-b3d3d2ac17a1',
  'Shemar',
  'Moore',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '486e26a6-4caf-0006-adae-65576a75a8f0',
  'Andre',
  'Morrison',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '18e5bb9b-c6a4-0006-30b7-8d677e0d58da',
  'Yaw',
  'Nimo-Agyare',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '83613426-3646-0006-01ac-f6c53a5d87cf',
  'Kenny',
  'Ofori',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ed6b8b8f-0666-0006-bff0-b5d63fa24462',
  'Diwash',
  'Pun',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '9a822f11-984a-0006-4b2e-43da6a7ca569',
  'Shamar',
  'Smith',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'be8de552-01d2-0006-ab9e-3d6a6ea17b21',
  'Sholay',
  'Sock',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '4d30f313-9519-0006-7cd2-3956e8e1c040',
  'Dane',
  'Stephens',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a00ee1da-be10-0006-cf62-ce8777b8a716',
  'Romaine',
  'Walters',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Glastonbury Celtic USERS
-- ========================================
INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c3339080-371f-0006-b846-195e8a7129f9',
  'Colin',
  'Branigan',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '2e579f16-b693-0006-b0c9-079d7eee97e7',
  'Colin',
  'Brocksieper',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c0c29f9e-d2e7-0006-0341-f1af62179ab5',
  'Nick',
  'Burkle',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'fac956dc-b3b0-0006-152c-eea9cd675ad5',
  'Rocco',
  'D’Arcangelo',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'fe449959-47ce-0006-699e-7d492b4164d3',
  'Massimo',
  'Eichner',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '41076868-69ac-0006-fe1e-dde20908c978',
  'Eddy',
  'Enowbi',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f7879279-e76a-0006-1b99-6e0dea2b2ac2',
  'Sean',
  'Gannon',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '51ddf26e-40d9-0006-51d4-de0169d12fa4',
  'Andrew',
  'Hayden Geres',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '3027c9fe-a44c-0006-148f-22936d73fa40',
  'Donovan',
  'Harris',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '00a0f3cf-c733-0006-fdac-e8845a36e72f',
  'John',
  'Hess',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '240f84b5-1159-0006-a6c2-01d0ae45db78',
  'Jalen',
  'Jean',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '8c90360c-5857-0006-5cb4-23328f2cc254',
  'Eric-Bertin',
  'Kalumbwe',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '91bb200c-876d-0006-8db2-7612a79ceb83',
  'Sevon',
  'Komlan Koudaya',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '77c86f8e-e67f-0006-2e05-94fce7800388',
  'Senan',
  'Lonergan',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '13d839d0-f3db-0006-a4c9-939bc6a16dca',
  'Luke',
  'McNabb',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd04bbad1-0262-0006-a99d-8293a5aa5a8e',
  'Aidan',
  'Nolan',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '6df79880-4a58-0006-0fc7-72b6e3d27d26',
  'Aidan',
  'O''Brien',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f055065a-bae3-0006-d54f-bd44c47a25cd',
  'Liam',
  'O''Brien',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f8266ef4-1b48-0006-859d-55839d40c533',
  'Ronan',
  'O''Brien',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f4452a30-4c56-0006-85d7-c562441ebfbb',
  'Marco',
  'Parisi',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'bf74a458-0b20-0006-7f1d-88ca87521688',
  'Christian',
  'Rivas-Plata',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c906d766-3582-0006-bfc5-d4cb05081be9',
  'Colm',
  'Ryan',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'da3374b3-4ded-0006-1ddc-d1edd12a847d',
  'Ian',
  'Slattery',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'df75ca93-0ab5-0006-6ca2-5ff7da31268b',
  'Marcris',
  'Webb',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'fb537ad1-6d1e-0006-09f6-5c9adfeb34a3',
  'Nick',
  'Wlodarcyk',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Wildcat FC USERS
-- ========================================
INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'df5b154f-7409-0006-2e6e-5220e856488f',
  'Kaio',
  'Ramos Araujo',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ed98f9fc-45af-0006-0cb0-223ebc6fd69e',
  'Luciano',
  'Artaza',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7cff48dd-9993-0006-b922-3c1534a96716',
  'Luke',
  'Bello',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '290f225e-59ea-0006-0318-eddbe2dfd69c',
  'Marc',
  'Calle',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '46af404f-4f93-0006-728e-e6e783b7b474',
  'Leonardo',
  'Da Graca',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a1c34d59-234a-0006-982a-a093f109a573',
  'Ricardo',
  'Dias',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'df8c3322-9ddc-0006-f0c2-e144e5587b87',
  'Matthew',
  'Evora',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '9e8988b0-f05e-0006-c3b0-8ab21e18b994',
  'Anthony',
  'Faienza',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '8bd984ef-793c-0006-a805-60a2c5304b8b',
  'Thomas',
  'Fernandez-Wolff',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '80f07d6a-da37-0006-8270-8653355dc779',
  'Nicholas',
  'Fernández-Wolff',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '33c0f5bb-d37b-0006-9af3-9f3d6218c94f',
  'Abdulmohaymen',
  'Gadoush',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f7b000d3-f1c4-0006-18c2-06c7199ccb6c',
  'Eurico',
  'Gomes',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '9c6781cb-a72c-0006-865d-74275cd19f37',
  'Javier',
  'Hernandez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '82b4490c-a296-0006-1541-c4f1f2ad2b86',
  'Joni',
  'Kadrioski',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '23cad7b2-21f2-0006-beb6-4a7f2d287b32',
  'Chavez',
  'Mbeki',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a95d2c01-6992-0006-ff8b-600b626b5e58',
  'Kenan',
  'Mujic',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5e2f348b-40d5-0006-3102-0d7f66a5dfc7',
  'Ermis',
  'Paguada',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '2ccbb8dd-ea97-0006-57ca-228830624803',
  'Paulo',
  'Paris',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '9da83806-e9a9-0006-77d0-d9b933e9bfdd',
  'Juan',
  'Saca',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '1c41f6f3-e71c-0006-8abf-8bf33bfeb0cc',
  'Bruno',
  'Silva',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'abba3694-b109-0006-566e-85a1e07b0ca3',
  'Matthew',
  'Silva',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a0f021ae-23d3-0006-aeee-013e41a4f19a',
  'Michel',
  'Souza',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '87673440-5c13-0006-764c-1f8feaa7f962',
  'Kadin',
  'Talho',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a6a679f2-9ad4-0006-fcf7-eec486003c80',
  'Diego',
  'Vasquez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f402abc6-88aa-0006-a225-ba47b179dd9b',
  'Jannik',
  'Wille',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '60bb5a8c-3549-0006-d8d5-87901d3dcc8b',
  'Caleb',
  'Wu',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'cdc01c0d-855f-0006-9bc7-80dc5c6302f8',
  'Alan',
  'Xavier',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Hermandad Connecticut USERS
-- ========================================
INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '37887734-1c9e-0006-2a9f-ea4402a033ea',
  'Bright',
  'Agyemang',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '2c1274f4-35c4-0006-9927-edb92f123fec',
  'Wander',
  'Alves',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b6ad791d-c033-0006-c6bc-42b641d90681',
  'Guilherme',
  'Andrade',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '6d21bfe3-90d9-0006-409a-dce7d26f0992',
  'Hayllan',
  'Batista',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '141b275f-f275-0006-08be-5d3104d7e115',
  'Gabriel',
  'Berthoud',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '481d1f8b-a183-0006-b1d2-070a083d5af1',
  'Gabriel',
  'Carrelo',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '87b316fb-5f4c-0006-5da8-083ad5676203',
  'Rodney',
  'Delgado',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'af9832ff-88e9-0006-662b-469af229cf59',
  'Gregorio',
  'Espinoza',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'dbc9f3e6-fa84-0006-cc5d-5d8b35b2fb03',
  'Wilmer',
  'Flores',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '938d0a54-db68-0006-74bd-7c4b37323ad5',
  'Zouhair',
  'Khal',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5d7e9ac2-9e17-0006-eeca-6764ca4395b0',
  'Shamar',
  'J Kingston',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '09e4ba92-944c-0006-ef6f-2f4a54583d93',
  'Bruno',
  'Luiz',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '0978b528-8643-0006-d96b-e6d4ecced09c',
  'Colton',
  'Lukuc',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '8adf97db-d8d4-0006-a68b-b687f5009701',
  'Abdessamad',
  'Machi',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ffda714f-7247-0006-d86a-769e482cfce4',
  'David',
  'Mollenthiel',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e52b0058-1362-0006-73ce-fad00c2ce970',
  'Phila',
  'Nxumalo',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '65ede4cb-28c0-0006-b2bc-f58d518e479b',
  'Johan',
  'Pineda',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '756a1940-6a88-0006-c40f-e403f8dad736',
  'Patrick',
  'Pineda',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '763f3b0b-ede4-0006-4a23-2068df5686fa',
  'Andrew',
  'Ranieri',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e849dbbe-14a5-0006-de04-028a01a21dce',
  'Anthony',
  'Ranieri',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '63952863-ed62-0006-719b-1e1658d07bec',
  'Steven',
  'Rivera',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '6584e60d-7170-0006-eb1c-1db9bff85c20',
  'Maynor',
  'Robles',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ca77f3b9-8757-0006-d381-c497f6b5ec1c',
  'Michael',
  'Rodriguez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '9f25fe99-fe02-0006-dc3b-11426a5d14f7',
  'Walter',
  'Romero',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '084a82e2-1cd3-0006-4ab1-f6199d988008',
  'Edwin',
  'Rosano',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '9940e7a1-906a-0006-4126-9668daa86be8',
  'Bairon',
  'Tejada',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '9bd30a1f-a719-0006-5c63-13cadb08e706',
  'Diego',
  'Vega Toledo',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '64946898-0458-0006-35d0-ca2b76486505',
  'Oscar',
  'Eduardo Velasquez Centeno',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a6e03e26-3e59-0006-041d-4156de289f32',
  'Anderson',
  'Velez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'cbfd2ed9-308f-0006-b0ea-0b84f3095327',
  'Tristan',
  'Vincent',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'cd839d32-0465-0006-8865-a353942547c8',
  'Tyler',
  'Wrenn',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '2f187c1a-669a-0006-0753-18c18c70c0a9',
  'Javier',
  'Yanez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- NY Greek Americans USERS
-- ========================================
INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '301196cc-85f6-0006-46aa-3fdf9b6ca61f',
  'Hermanus',
  'Achterkamp',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c32b2e33-3e0e-0006-defa-e19017caee35',
  'Christopher',
  'Diego Anderson',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'be39983a-d3ce-0006-9c69-32c274a01322',
  'Daniel',
  'Bedoya',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c339a18b-6b92-0006-9352-0ffca788db0f',
  'Etienne',
  'Botty',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'aa2b3a30-9783-0006-3012-c96de69bf414',
  'Francesco',
  'Caorsi',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a461ba94-9d65-0006-98fb-d0616298ee94',
  'Roc',
  'Carles Puig',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e0447b79-71f8-0006-1f44-1048e4e1c030',
  'Myson',
  'Colo',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c72e17a8-0705-0006-c881-cc11c1b5894e',
  'Rodrigo',
  'Descalzo Rocca',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '8ff592e8-588d-0006-333d-e751e33c7887',
  'Miguel',
  'Mauricio Diaz Cubas',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '0b9b759a-2039-0006-e0f1-a134ab519a8a',
  'Timothy',
  'Joseph Gallagher-De Meij',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ba2dd9ea-4e93-0006-1076-f501632aac0f',
  'Miguel',
  'Soto Gonzalez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '8333d962-2e91-0006-ddd2-de335577c25c',
  'Adam',
  'Marcu',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '3f39782c-0495-0006-fbf6-3934468be92e',
  'Patrick',
  'McCann',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '305f9af7-7a9f-0006-e22f-ae7bd9172048',
  'Paul',
  'McVeigh',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f9d3f733-fd4b-0006-70a6-0ce9b4f7e95c',
  'James',
  'Nealis',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c0042e32-75ba-0006-78fa-456d5779221f',
  'Jack',
  'O''Malley',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '9b22def6-74f1-0006-6d08-1699cd51fd91',
  'George',
  'O`Malley',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e4c8d49f-b0c4-0006-d2e4-f419788dae13',
  'Nicholas',
  'Oberrauch',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a06987e3-0303-0006-6868-acecdef7ba3d',
  'Alberto',
  'Pangrazzi',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'fe81d03e-69ca-0006-cd96-7f80fc1497ca',
  'Francesco',
  'Perinelli',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a1731888-6639-0006-b7ec-68f8ca919f85',
  'Nicholas',
  'Petridis',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '9495766c-4298-0006-3f17-da33fafaed51',
  'Cormac',
  'Pike',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c837a663-b04d-0006-45b3-df013bd682b2',
  'Saeed',
  'Robinson',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '52e3b16a-8058-0006-d8cd-a2675e5cb7c3',
  'John',
  'Sabal',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ba2d6091-0a3f-0006-db9f-ac243be4023d',
  'Brian',
  'Sousa Saramago',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '360fc8da-30d7-0006-df1d-2e4e1d1582d6',
  'Elijah',
  'George Sawyers',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '12cb46f3-5dd0-0006-4b3a-766d1902670e',
  'Joshua',
  'Schaffer',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '55c03c6e-182b-0006-b9b8-d22d982ac4a1',
  'Barakatulla',
  'Sharifi',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f83a32f0-758f-0006-98cf-52ea4b6774ed',
  'Yacine',
  'Sidi Aissa',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '1d7bb63d-1131-0006-4dac-9ef5900a4ea3',
  'Carl',
  'Viggo Sjoberg',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a101716d-dd0e-0006-511c-13e7829942f8',
  'Leo',
  'Wei Pinto',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '17f5e376-b286-0006-7f0f-c432d68ad3af',
  'Joseph',
  'Wright',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'fa28096f-ce43-0006-25e3-e703808e45d5',
  'El',
  'Mahdi Youssoufi',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Hoboken FC 1912 USERS
-- ========================================
INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7d34d8bc-79c9-0006-0ca7-da9e5e7098cd',
  'Santiago',
  'Arroyave',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '776ac1ef-e719-0006-392f-6f3018ffa05a',
  'Tristan',
  'Barquin',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'dc59256f-e35f-0006-14a7-28bce22acbdc',
  'Ethan',
  'Bazan',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '1b6d8052-5f37-0006-b5c4-e84efa7ee1c8',
  'Steven',
  'Bednarsky',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '49fa6860-fa1e-0006-6a87-21cc547b7d2e',
  'Isimohi',
  'Mike Bello',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c07df1fb-6f49-0006-be75-510b4083549e',
  'Kouadio',
  'Bolaty',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a505ea71-79e5-0006-a589-e2ef4dce5622',
  'Andrew',
  'Bortey',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '9b529b5d-9eaa-0006-ab8b-d899f0365ee2',
  'Kelvin',
  'Brito',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '3c9e3d11-7853-0006-1f0c-babcb15d5ed3',
  'Dorgeles',
  'Coulibaly',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e2632be1-c983-0006-e4ec-ac4f5123a3f1',
  'Tyler',
  'Diaz',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b2bbc4d6-6654-0006-0880-a3b79927b1de',
  'Samuel',
  'Epitime',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '59e8261d-3426-0006-03e5-b19fae529f67',
  'Adam',
  'Garner',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c4cca3e3-1ecd-0006-ed84-e2a4962ab429',
  'Matthew',
  'Gotrell',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '6de1c4f9-94bd-0006-0a3a-505ef7ae6e5a',
  'Ivan',
  'Enrique Hurtado',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '2d9e0689-418a-0006-4841-4e2f14c33289',
  'Stefan',
  'Koroman',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7851e92c-264b-0006-aba3-b728ae6dfc82',
  'Keeroy',
  'Lionel',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '836c656f-c985-0006-3268-260d1aac7afd',
  'Yamil',
  'Macias',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '1eeb8012-e8ea-0006-40bc-992347b04575',
  'Cameron',
  'McGregor',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd4573209-6662-0006-05a0-7130381b62a4',
  'Coby',
  'Mcgregor',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'bb857711-8f53-0006-7820-47f2c5cacb02',
  'Joseph',
  'Moon',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '82e727f0-f912-0006-af62-6bd3b076f113',
  'Israel',
  'Neto',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '37d5e396-215d-0006-004a-94246c0a5144',
  'Abdoul',
  'Ouedraogo',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '14ef5b9c-c20d-0006-b86d-084bbb0e58cd',
  'Brian',
  'Paredes',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'da967792-2afb-0006-63e7-e8d522725a17',
  'Jung',
  'Park',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b28c2d64-6759-0006-189a-b7c9f1e31487',
  'Ewan',
  'Sanchez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '66d5082d-9c7c-0006-e276-95bafed41de7',
  'Jossimar',
  'Sanchez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e788aa21-dddc-0006-8a72-79cd47baf379',
  'Kevin',
  'Santamaria',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a85fbe60-64e9-0006-05c3-ebce0212c4b5',
  'Rodrigo',
  'Santiago',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c244669f-3d2a-0006-b722-121835bd745b',
  'Luc',
  'Smith',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '16c7bd74-ccdb-0006-a2ff-6dcffd12b32d',
  'Ramchwy',
  'St Vil',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c6d4a358-0660-0006-1e0a-20f8f92754e4',
  'Mohamed',
  'Tall',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '0220f79d-d177-0006-1d33-498fa52c6485',
  'Christian',
  'Villegas Libreros',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'bc8312ea-2301-0006-3e60-14898c745702',
  'Andrew',
  'Weiner',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- NY Pancyprian Freedoms USERS
-- ========================================
INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ad95defb-0e84-0006-1f5d-01700a7f7d39',
  'Pablo',
  'Ablanedo Llaneza',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '0b9f6a24-f6d0-0006-927e-3a09b6633c9a',
  'Jordan',
  'Bailon',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ca9319b0-6b21-0006-e70c-ad5a74350686',
  'Filip',
  'Basili',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '8d84cee1-a81b-0006-1981-af5d5556e1c7',
  'Christopher',
  'Bermudez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '9f0d6c6e-1a3c-0006-e375-a79fe5238b21',
  'Victor',
  'Castel',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7f28b126-0afc-0006-71b8-cbc6f9f0ac78',
  'Rikard',
  'Cederberg',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd149f49b-acc5-0006-2c7c-eb2074be7674',
  'Nicolas',
  'Cifuentes DIaz',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '375d9aff-512e-0006-9d11-705d57b38f2c',
  'Davide',
  'Clarkson',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '2a9d2882-1fba-0006-a423-f0addab7b5be',
  'Sergio',
  'Diaz',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '0cd0b9b4-7a59-0006-bf55-9fe2f7b63d74',
  'Eric',
  'Frimpong',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '0a912565-84ec-0006-d1c3-e33df55ab126',
  'George',
  'Gantalis',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '269a1762-04e0-0006-9e08-cc7f73150dae',
  'Jose',
  'Gil Mejia',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'de85cb97-a39a-0006-04de-e4895788f723',
  'Ede',
  'Mateo Gramberg',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7b22c55c-b1dc-0006-d308-fdeabb970179',
  'Thomas',
  'Gray',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c4e6b96e-ed58-0006-d9cb-06c2ac156021',
  'Antreas',
  'Hadjigavriel',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e617b3b8-f880-0006-1cae-01ab200de6d8',
  'Devin',
  'Heanue',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '10ba9b74-a1b3-0006-a65f-c8d6498e0e22',
  'Kevin',
  'Hernandez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'aa860b38-a098-0006-ae66-66d4c5dbe941',
  'Jens',
  'Mannhart Hoff',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd6cdd6ad-4891-0006-7814-665e6c6fcd4f',
  'Joseph',
  'Holland',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '9812044e-02b4-0006-f0df-fc72fb89b3dd',
  'Filip',
  'Jauk',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '233f1298-8ddb-0006-74d3-74647a81d1f0',
  'Soren',
  'Jensen',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd3804ae3-e7d1-0006-c3b9-8fb7248015c7',
  'Konstantinos',
  'Karousis',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '3653f472-7432-0006-739a-5b47b8569883',
  'Connor',
  'Kelly',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '0e410dd4-6f65-0006-b6ee-75a2056d1964',
  'Benny',
  'Lafortune',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '36a0fa14-0977-0006-a6a1-ce6c0722f049',
  'Joshua',
  'Levine',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e6d97a8a-7919-0006-e19e-b468acb0046a',
  'Juan',
  'Martinez Moreno',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '843caf24-a2a3-0006-000b-e7d1b47bfdea',
  'Filip',
  'Mirkovic',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd8bf5fa7-6122-0006-8719-4e35e266f779',
  'Christoforos',
  'Moulinos',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a1d91af4-baf6-0006-21b8-e578411a9741',
  'Stephen',
  'O’ Connell',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '2b2cfb6b-fefa-0006-1d4c-00ebdad5c0f1',
  'Alex',
  'Palas',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '71a41f70-ae60-0006-9b7a-2ab4a48b664c',
  'Sebastian',
  'Ruiz',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'fa6ef07f-217e-0006-3d14-934fa4e539d5',
  'Athanasis',
  'Shehadeh',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '439f4875-fe30-0006-6033-eceda3120c9c',
  'Jack',
  'Sluys',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '84f23cf4-c102-0006-6e4e-021e447badea',
  'James',
  'Thristino',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '59f47a10-9f5d-0006-3980-2cf779b8e785',
  'Sean',
  'Towey',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Lansdowne Yonkers FC USERS
-- ========================================
INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '59993596-e37e-0006-eb45-ce2067821294',
  'John',
  'Bernardi',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '8151f31a-42d3-0006-84c3-16e1657f1ee6',
  'James',
  'Peter Boote',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '542c61bf-23cc-0006-5b9b-9e47513f06ef',
  'Aidan',
  'Borra',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '8c5f2aaf-060f-0006-ca44-bc11978ad32f',
  'Tajee',
  'Campbell',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '1f80a10c-2dbb-0006-f563-1fcb5f80c6f6',
  'Marco',
  'Charnas',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '324477f5-4b71-0006-c97d-33ec70b6f835',
  'Constantine',
  'Christodoulou',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '8f87a43e-a21b-0006-0f9e-0e6341598a27',
  'Stefan',
  'Copetti',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '0a26b622-a633-0006-aeea-d25be4cce5d1',
  'Carlos',
  'Cortes',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '8aef3fbf-5667-0006-a7d8-4f2ea899ebc6',
  'Musa',
  'Bala Danso',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '0fa8333c-30ca-0006-a175-a4baa2c2d7a3',
  'Ali',
  'Dawha',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '0a77640d-8df1-0006-4871-8519314a2fe7',
  'Daniel',
  'Dimarco',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '4b5c2ad0-c1fa-0006-8023-bf505cf2dae0',
  'Sean',
  'Doran',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '9528e132-5250-0006-8e6f-7ea8894ba9ac',
  'Dino',
  'Feratovic',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '41a442f6-c9b1-0006-bedc-940830335d05',
  'Ethan',
  'Furphy',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ea04ced7-5034-0006-0f54-e769b07caf06',
  'Michael',
  'Gallagher',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'fbeba52d-c0ef-0006-bd13-ac959470c068',
  'Kyle',
  'Galloway',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f64b0b59-376d-0006-9d9f-25ba56d0af6b',
  'Cillian',
  'Heaney',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f2930979-f5b3-0006-265e-136e45b28d1d',
  'Michael',
  'Hewes',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '15eaa056-d846-0006-9c0f-175666a4fd1a',
  'Ethan',
  'Homler',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'eb1412c8-e287-0006-4e93-303dd7c39dec',
  'Jared',
  'Juleau',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '40702513-5295-0006-a8c7-5d74accaee01',
  'Andy',
  'Kasza',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '889220c7-9111-0006-3b6d-83cacc26c343',
  'Daryl',
  'Kavanagh',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '49b2014d-cea6-0006-d060-8911a5d1ef78',
  'Seamus',
  'Keogh',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a793c8b6-ceae-0006-7a5c-bb1e984a89ac',
  'Sean',
  'Kerrigan',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '85ed3843-48b3-0006-8f5d-13e45c73c4fb',
  'Danu',
  'Kinsella-Bishop',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'cce91945-afd7-0006-7554-2810eef95e96',
  'Nicolas',
  'Macri Badessich',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '55c93f52-566a-0006-fe47-e093a3f91c8d',
  'Malcolm',
  'Moreno',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '1f53cfbb-7254-0006-61a5-d57a93d42ed4',
  'Luis',
  'Puchol Del Pozo',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f713870a-4ee0-0006-36fe-30cace47d5d5',
  'Sebastian',
  'Rojek',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '6fb5e046-e079-0006-ed16-e5ff4f7e1ad7',
  'Liam',
  'Salmon',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '86b76e74-2a1b-0006-5819-f17fcc240b4c',
  'Harry',
  'Sankey',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '42f7c932-6f92-0006-3527-d6b4f16a1708',
  'Edward',
  'Speed',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5d719a69-2fc5-0006-b01c-84d4449c7493',
  'Benjamin',
  'Stitz',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '75854c8a-34e5-0006-def8-40f438cd0ad0',
  'Liam',
  'Walsh',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b0f0e842-7fd5-0006-f8a2-653ed9376c3a',
  'Oskar',
  'Zywiec',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Leros SC USERS
-- ========================================
INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '414f2572-fddf-0006-3a45-d6ee22d678c4',
  'Keirol',
  'Aaron',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '65464fd3-4a6e-0006-6f38-22d9d1881c9b',
  'Matthais',
  'Adamek',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e978ab5e-a1c0-0006-d059-3e564e18b1fb',
  'Yohance',
  'Alexander',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '381f3765-2083-0006-6f4d-3841bd909aba',
  'Andrea',
  'Andreou',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '85224882-93cb-0006-6634-9f484cd2da58',
  'Luis',
  'Argudo',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'be8d6c47-4e8a-0006-a5ad-6ad150cdcdcf',
  'Theodore',
  'Bernhard',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5007e41e-9ba6-0006-ce0f-877f8a328038',
  'Antonio',
  'Biggs',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '9d0729d8-ab23-0006-dcac-13b89a78b448',
  'Mason',
  'Chetti',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd64244a7-ce94-0006-0005-ed6ebe4cb28d',
  'Jarvis',
  'Cleal',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f197bffc-ca2a-0006-2730-7acf60e6aa26',
  'Joel',
  'Cunningham',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '617414fa-4c77-0006-3d61-94cb8986268b',
  'Caleb',
  'Danquah',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '13d66bb3-8fe8-0006-04f8-7028251009c9',
  'Eric',
  'Danquah',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '49f6aa3a-3ab0-0006-271c-4ce5048d698a',
  'Sameer',
  'Fathazada',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '60416857-810d-0006-adc3-d0c3b974f62e',
  'Leo',
  'Folla',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '9f69d7f1-48d5-0006-0434-e25a91b2002f',
  'Jakob',
  'Friedman',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '86a78668-d490-0006-507c-c63cbe981cd4',
  'Cesar',
  'Manuel Garcia Peralta',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5fcece2e-4f5d-0006-6334-93a1764a38bf',
  'Sebastian',
  'Goicochea',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e6a3268a-f969-0006-b947-49b105511976',
  'Juan',
  'Antonio Gomez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '01bc95c9-ebf3-0006-3908-51d74696b381',
  'Alessio',
  'Hernandez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '55aa0a89-1333-0006-b9c3-e796842f5e4a',
  'Benjamin',
  'Jones',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '63fb84cf-c36b-0006-6c30-9f561178bfad',
  'Selcuk',
  'Kahveci',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '4e3f35f9-419a-0006-2b84-c039cf774337',
  'Chad',
  'Mark',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '549c604a-6c05-0006-8afb-b8364faeef3c',
  'Leonardo',
  'Martinelli',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5d9518ee-d056-0006-1792-4ca69133d10a',
  'Alexander',
  'McLachlan',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '441e00f6-91b9-0006-ae48-da96496c6b24',
  'Giovanny',
  'Morales',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'fa4fc325-734d-0006-257f-61160483af45',
  'Bradley',
  'Nestor',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b1f9ddd9-2d2f-0006-9c7c-c17b0413f6e7',
  'Godwin',
  'Partey',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '0990a3e5-73da-0006-4bee-936357ce3b05',
  'Kevin',
  'Piedrahita',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '59776b14-d92f-0006-7c21-acc132ee5372',
  'Junior',
  'Rosero',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f7471293-2b2d-0006-a6af-0f5bfe705f06',
  'Karim',
  'Russell',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ea425cb3-cb0e-0006-42ab-63e39811f9ec',
  'Sanoussi',
  'Sangary',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '96d07dfc-7d4e-0006-23cb-315fd5dac2bb',
  'Shaquille',
  'Saunchez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '96e928a1-380e-0006-0399-a4c5edd55f2c',
  'Kendell',
  'Thomas',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '26b7d142-5aaf-0006-39ea-39a5af77dfdb',
  'Dillon',
  'Woods',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '1cc2f56c-2f29-0006-00a4-11ffd36b837a',
  'George',
  'Yusuff',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Doxa FCW USERS
-- ========================================
INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '8553283e-0bc5-0006-ab93-d578af73abc5',
  'Adrian',
  'Aguilera',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b807f992-6c9f-0006-8fe6-9e67409b66b6',
  'Balint',
  'Barabas',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '9dfcf283-1554-0006-47f4-f999e499c15c',
  'Vasilios',
  'Brisnovalis',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e8b6dbbf-15a0-0006-ab8d-3d73a99ad0b5',
  'Robert',
  'Cabrera',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '136850cb-6768-0006-7d88-0968d7a98f4f',
  'Murat',
  'Edgar Calkap',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '82a13ab1-cfc2-0006-8bc3-f33d80f586e1',
  'Daniel',
  'Curmi',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e354b1b6-cec7-0006-6b0b-ae698e5ee5b4',
  'Duga',
  'Dambelly',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a9b8178b-ffcf-0006-0a01-3d678f53ff7e',
  'Khaled',
  'Daoud',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '96e324e8-3075-0006-8275-dfa60b361080',
  'Julio',
  'Espinal',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd80e6914-bf79-0006-a5db-9b406a0f25c8',
  'Jeison',
  'Gonzalez Sanchez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '16652c73-e63c-0006-817c-3e33ca1327fa',
  'James',
  'Greco',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f4684a76-c17a-0006-c1ec-c80b80a9d5f5',
  'Grady',
  'Kozak',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '6fc4c8b3-be27-0006-d6cc-9d92536c7ead',
  'Antonio',
  'Linge',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '6d9c5821-5a40-0006-e297-99756d01cc20',
  'Kevin',
  'Lucero',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '31e30e09-6459-0006-f52e-29d2146f24ba',
  'Tyrone',
  'Malango',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a78962bf-9a98-0006-39ee-9f19a504be4e',
  'William',
  'Marment',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '58bc203e-e5c3-0006-c8f1-e511a51f0b1e',
  'Augustus',
  'Manuel Mcgiff',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c7559bdd-b14e-0006-5a4c-428b6409759f',
  'Christopher',
  'Morandi',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e1978acf-a2db-0006-fcdb-245d371706c6',
  'Richard',
  'Morel',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ff98ae93-b10a-0006-86d4-c2923fd89ad4',
  'Peter',
  'Myrianthopoulos',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '00f5fd37-aced-0006-9734-daf0d702148d',
  'Jorge',
  'Alberto Nieto Zambrano',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a2b8a7c5-b649-0006-cce0-a7bd93543da6',
  'Stefen',
  'Nikolic',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5365bc6b-7090-0006-06c6-b79ce5aac6c2',
  'Martin',
  'Nikprelaj',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '402bdfcc-c09b-0006-1155-cc6a9044c704',
  'Sergio',
  'Peralta',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '8768a116-0221-0006-25bf-cfb6e9d0442c',
  'Paolo',
  'Cerruto Primavera',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd1c1bb4d-6783-0006-186d-c12447516d68',
  'Chris',
  'Riordan',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '15edf299-22ff-0006-24cd-e91f642aeb47',
  'David',
  'Rodriguez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e04b2828-5b2c-0006-b352-a80109558d4c',
  'Ronaldo',
  'Rodriguez Jurado',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c7cff871-f78f-0006-a535-a62155edc074',
  'Fredy',
  'Rosales',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '6295c243-c1e4-0006-d160-eb71b9ce4ad5',
  'Duvan',
  'Sanchez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e44e575c-135d-0006-5bae-085489cbb696',
  'Giuliano',
  'Santucci',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7526effd-5575-0006-4b12-bba489538263',
  'Navruz',
  'Shukroev',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '95623388-791f-0006-aac5-7ce51887876c',
  'Milorad',
  'Sobot',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '99357ccf-ed73-0006-03f8-c5d7c22911b2',
  'Michalis',
  'Stylianou',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '733b8d31-f7dd-0006-a386-88c38d3814df',
  'Jorge',
  'Bladimir Zambrano',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- NY International FC USERS
-- ========================================
INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'da11023f-75d1-0006-31ec-5f8725c570f8',
  'Joshua',
  'Adejokun',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a0b93ed1-0371-0006-0019-02f58a70793b',
  'Saad',
  'Afif',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '6a0674ac-94f3-0006-a9a5-9c94612b911b',
  'Youssef',
  'Afif',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '08634319-2781-0006-dfdb-6fd18e60fc06',
  'Osama',
  'Al Sahybi',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c2780cd9-2043-0006-11f1-042bb40eae9d',
  'Eric',
  'Anderson',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '4d2f1838-300c-0006-617f-04debd1eb0c6',
  'Oscar',
  'Champigneulle',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f4be107b-41e5-0006-1de2-23992501bc4c',
  'Ryan',
  'Chuang',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '9f8e5d31-a1f0-0006-a234-3344918bd80f',
  'Michael',
  'Dempsey',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7d345240-5184-0006-3a30-17c55cabe0a3',
  'Byran',
  'Dia',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f4db866f-e2e1-0006-f1d7-878a45e9e6a0',
  'Yohance',
  'Douglas',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'cd0ab36f-22a6-0006-f49b-ae71ee5f279b',
  'Jeffrey',
  'Gad',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b8347f17-2aa3-0006-05a7-6e06d27bf528',
  'Jahdea',
  'Gildin',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c9243d59-0f6a-0006-085a-af39bee83bb7',
  'Ross',
  'Holden',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ee7e4197-801a-0006-2112-d89d75e5b13b',
  'Hugo',
  'Howard',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b3726b38-086b-0006-301c-91d24e5cfa80',
  'Ikrom',
  'Husanov',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '0fe80dea-a7da-0006-12a8-61e8e623d47d',
  'Geireann',
  'Lindfield',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '93863025-3322-0006-c9d4-cffc6653cb4c',
  'Sean',
  'Molloy',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '3b2c6fa5-2920-0006-d424-57fb89ad4a05',
  'Shamir',
  'Mullings',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '91708f14-86aa-0006-9f16-1893bf050cda',
  'Ridwan',
  'Olawin',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5272fa1c-7995-0006-2dc6-e45bf6200869',
  'Gary',
  'Philpott',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ae03dfad-1bde-0006-8220-e144a12d7fa2',
  'Sean',
  'Reilly',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5ae84ac0-8c22-0006-139e-955db58f24c9',
  'Faissal',
  'Sanfo',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'aaa0b7d4-af86-0006-687c-0afc97197b3c',
  'Ensa',
  'Sanneh',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '900b1ebd-3e5d-0006-95b5-c0564c3f1ccc',
  'Avinash',
  'Singh',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '4096ec7a-118b-0006-d968-3e19aa35297c',
  'John',
  'Stevens',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '03d5af41-d440-0006-db41-25dabf295dad',
  'Alexandru',
  'Teodorescu',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e6db93de-0ef0-0006-ea37-fd688fefc784',
  'Maurice',
  'Vermeulen',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Richmond County FC USERS
-- ========================================
INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'bce1161c-8a20-0006-c0d0-95b6c66eeeb3',
  'Hermes',
  'Ademovi',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e485bb60-e873-0006-bca7-63763ea70cd3',
  'Mamadou',
  'Bah',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '8c7d4b82-ae75-0006-396b-2e68ecd51e28',
  'Bljedi',
  'Bardic',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7e777131-a30d-0006-d1c6-1b14c183ce4f',
  'Giuseppe',
  'Barone',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '0b80437b-f9d9-0006-9d55-84ad74e321ba',
  'Salvatore',
  'Barone',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '8beeea2d-7b6c-0006-1628-f3b2815c5c02',
  'Kemal',
  'Brkanovic',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '287a050f-094b-0006-ccec-08c2669d1d4b',
  'Cesare',
  'Cali',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd99f371d-90cd-0006-72f1-85fac4052ece',
  'Keithlend',
  'Cesar',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'dbb797c4-0df7-0006-5c6a-01944c09e188',
  'Kyaire',
  'Clarke',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f25d0c35-a284-0006-e480-317e1eb03217',
  'Luis',
  'Cueva',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'aea90e37-c643-0006-376d-a3c5e6c8b432',
  'Bradley',
  'Espejo',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7df3844d-8dd6-0006-6d5f-7dfac0f54ecd',
  'Roberto',
  'Gioffre',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b27dafc4-a86b-0006-5e3f-3e455b109671',
  'Pietro',
  'Giove',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '21c6e29c-5af7-0006-258a-1d25ec801ff3',
  'Christopher',
  'Gjini',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e0adf473-fe6d-0006-7294-233eb2365fbc',
  'Peter',
  'Gjini',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f9dcfd4b-bfa1-0006-7611-9be226bdba33',
  'Armando',
  'Guarnera',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'acd787f5-aa56-0006-8da8-8344e205a251',
  'James',
  'Haddad',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '0f64c776-35e1-0006-64c9-6c93a2cd1832',
  'Yassin',
  'Hairane',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '2dce9028-0149-0006-594f-429575a87a2e',
  'Amir',
  'Islami',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e22ef105-39cb-0006-b5e2-153fa15f1d25',
  'Timothy',
  'Francis Kane',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'da40f677-135e-0006-5a50-eb52bc0b4430',
  'Brian',
  'Kerliu',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f196192d-1511-0006-529c-b35d76c429b3',
  'Peterson',
  'Larose',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f8ecceba-6f7b-0006-b174-8f6bd4b0c533',
  'Dylan',
  'Meadows',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '28fd501f-630e-0006-5824-6c22ac2bafc7',
  'Gerald',
  'Mehja',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '10249ce5-05d1-0006-0776-8926a01291bb',
  'Michael',
  'Mollica',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '53b61c25-83f8-0006-588f-4439c483b14f',
  'Anthony',
  'Oliveira',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b2aa37b8-b942-0006-c9b0-08c69bd71116',
  'Cristiano',
  'Oliveira',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '2de3d2cc-16dd-0006-7349-f11e1d8abe77',
  'Andrea',
  'Ruggiero',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5957a3f6-b96c-0006-227f-3eff7b8a9171',
  'Leutrim',
  'Saiti',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '971cd727-111d-0006-d68c-1df8069ee8f1',
  'Valeriy',
  'Saramoutin',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '41d9d017-e552-0006-32dd-f4da36bceace',
  'Mark',
  'Shnadshteyn',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '3cea49a3-cbe8-0006-36f7-2e2850a8304a',
  'Demyan',
  'Turiy',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'fd4aaa73-51cb-0006-dd76-41e8170e8901',
  'Dominik',
  'Urban',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b9f831be-2af6-0006-597a-108e95db60f6',
  'Bryant',
  'Vidals',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ca787b8d-9fa4-0006-1d9b-2c9386b04b5c',
  'Dani',
  'Villa',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Zum Schneider FC 03 USERS
-- ========================================
INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '49c3a3a1-574c-0006-614d-dda5233ffa63',
  'Jimmy',
  'Barrios',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '76877460-9405-0006-21f2-54b9e1c25045',
  'Richard',
  'Bastian',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '19a21d5c-9974-0006-01e0-3c18768f7de7',
  'Tal',
  'Benhamou',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c10629cb-3295-0006-14da-5ea2ab2f05ec',
  'Nathan',
  'Bennett',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '078bba28-5537-0006-bf21-78ab7580545e',
  'Jason',
  'Budhai',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '9eeb251b-70cf-0006-0f36-b7b55b09448c',
  'Dennis',
  'Coke Jr',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'bcea2412-8f7d-0006-3fd3-9dbb4726db23',
  'Sully',
  'Corneille',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '22174273-ed2f-0006-3d69-e3406836c4d9',
  'Dario',
  'Giovanni Cruz',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b6924d73-37de-0006-2267-13682493f9fa',
  'Juan',
  'Cruz',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '02a45a5f-37ad-0006-8cd9-9f18754af64b',
  'Tomas',
  'de Andrade Gomes',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f40824e5-0bc2-0006-7499-9dc0d2d4e044',
  'Felix',
  'Dyckerhoff',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd5a40e0a-5b95-0006-89a5-aab3b10298d6',
  'Salim',
  'Dziri',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '40c14827-209d-0006-6aa2-204d9f8623a7',
  'Glenford',
  'Gentle',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '785224fb-086d-0006-9237-706419cd8767',
  'Boris',
  'Grubic',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b9b61877-eb8d-0006-0f43-8352cc3face7',
  'Wisdom',
  'Hountondji',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '4aa9360b-92c0-0006-8887-c1935e7a0738',
  'Tom',
  'Hultsch',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '6128cd53-4dcf-0006-ce08-eaad819a7fb4',
  'Raphael',
  'John',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'fe670433-3fb3-0006-a064-98cb336bb46a',
  'Ryo',
  'Koiso',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd367d0f1-232f-0006-fc14-0dcab7c29330',
  'Michael',
  'Laret',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ab08f853-6ea2-0006-f2e3-e6b4d49b539b',
  'Jason',
  'Lee',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'db262a89-1b94-0006-95ca-89715dab850c',
  'Cesare',
  'Marconi',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '00ea6a8e-3545-0006-271a-5ad09a1f0abf',
  'Denny',
  'Morinigo-Arce',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b2b8090e-a6eb-0006-8e39-359e41a7b097',
  'Mateo',
  'Munoz',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7d44aa99-7614-0006-da89-abdb7b5a2ca1',
  'Deniz',
  'Oncu',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e8990e9c-5426-0006-a8a5-9a8d72e894ea',
  'Mubarak',
  'Ouro',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '51d5d67e-6556-0006-7e55-1e3086afbedd',
  'Jean',
  'Carlo Perez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '80f7e57a-c7ca-0006-06c0-227c75724030',
  'Mario',
  'Ramirez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '0a039ea1-dc67-0006-01d0-280bfe57a233',
  'Paul',
  'Restrepo',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '4f9c1a37-70d2-0006-8910-85ca9fafcef3',
  'Ely',
  'Schartz',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '971f1615-30bc-0006-8c44-0c4aa4aabba5',
  'Diego',
  'Silva',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd8683cfd-50b9-0006-1627-7d5a28d65c15',
  'Tyler',
  'Swaby',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '8437099b-1363-0006-371c-65b5b6f737c6',
  'Anderson',
  'Velazquez-Mendoza',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '73473ad7-30f2-0006-3739-85cd61eccf2b',
  'Andrade',
  'Wright',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- SC Vistula Garfield USERS
-- ========================================
INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '3f3733e7-657f-0006-0e24-cf9ff3f0d0fa',
  'Johannes',
  'Alvarez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5d4de7c8-3d9a-0006-9cc9-fa85928a7164',
  'Jason',
  'Alves',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c8800a92-b539-0006-192b-1ddffe904d4c',
  'Christopher',
  'Barnas',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ee7b0564-1987-0006-df37-e8f7b5f9dd76',
  'Roberto',
  'Chernez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '18fd44e9-26b7-0006-049a-959bd6819e24',
  'Gabriel',
  'Costa',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a1d48fd8-87cd-0006-b41c-5a9298f76871',
  'Keijon',
  'Davis',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '3f6cfe4c-d473-0006-63b6-2361a70149e2',
  'Shaunavon',
  'DeSouza',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd5ac0372-aa40-0006-2590-f7318d99bcce',
  'Gabriel',
  'DiPierro',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '31cf0a9e-12de-0006-a6fe-fa064ba8cb10',
  'Emiland',
  'Elezaj',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '0910c7ca-7a43-0006-4244-2bd46eacedee',
  'Andres',
  'Gonzalez-Rios',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a1b59e16-e6df-0006-15a9-27edaa41d6bc',
  'Jonathan',
  'Gutierrez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '56efd39a-9a30-0006-6460-837eca786e62',
  'Oscar',
  'Horwitz',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '21bdcefa-10df-0006-06ff-9eaf90f68733',
  'Jashar',
  'Jashar',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '782d35a8-d9da-0006-3f41-70c449e58d4b',
  'Christopher',
  'Karcz',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ccbdfeb5-1e21-0006-1246-f1359776c8aa',
  'Wiktor',
  'Kiszkiel',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '78bc5527-3031-0006-caeb-56e915e6a0d9',
  'Christopher',
  'Kondratowicz',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '895dae53-ddad-0006-d28c-f016c5bb511f',
  'Paul',
  'Kondratowicz',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7a21ec10-1a2f-0006-e404-93a5ffb92593',
  'Nicholas',
  'Kozdron',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '47b018da-72df-0006-6037-a51843d19e84',
  'Sebastian',
  'Lapczynski',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '1c3783c6-bdca-0006-3ac9-65682be5e4db',
  'John',
  'McGeechan',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7fcb56e5-35da-0006-93db-2ebc97d0418a',
  'Mark',
  'Mikanik',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ecf7a8ef-b691-0006-9b3c-f2bb27ec8829',
  'Aldo',
  'Munoz',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '86300470-6cda-0006-8570-a0807605134c',
  'Cyrus',
  'Nasseri',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b93c06bf-4171-0006-e850-ab4fd6ea9a68',
  'Krystian',
  'Nitek',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '807a6936-b907-0006-f97c-ea276db8d942',
  'Viktor',
  'Pervushkin',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e70c8183-460a-0006-d92f-a24a40fbec8f',
  'Tyler',
  'Pinho',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '01de1cd6-c809-0006-e0a7-f06314e40991',
  'Alvaro',
  'Rodriguez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '67324332-16ad-0006-8dfd-3be7f08de349',
  'Daniel',
  'Sawicki',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7a382673-a77c-0006-23de-562d8868122b',
  'Gabriel',
  'Serafin',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ed105191-f1e0-0006-7616-da426caa21c9',
  'William',
  'Tomlinson',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '4020ae27-181e-0006-29b3-21dfc09e6e18',
  'Igor',
  'Trajceski',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '8791a6a4-41ef-0006-a249-a284f3a9aa48',
  'Kevin',
  'Valdivia',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- NY Athletic Club USERS
-- ========================================
INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '424aa738-9a99-0006-07f1-afd4796d44e7',
  'Dominik',
  'Brulinski',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '4facf928-18fe-0006-01bc-be92f391c06b',
  'Mathew',
  'Contino',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '8b10ada8-4aea-0006-52d4-7bc16fd93d53',
  'Joseph',
  'Core',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '0dd2b243-5b0d-0006-71ef-0599cb8ca0fa',
  'Jacob',
  'Denison',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5a358224-ba04-0006-2d21-0af9ac4e2f39',
  'Jack',
  'Doran',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '16f96f66-54cd-0006-9a4d-10d9fa94dde9',
  'Javiar',
  'Edwards',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '18e3aaad-b08e-0006-b5e1-7413d805fd35',
  'Humbert',
  'Ferrer',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '3aad862a-a0e4-0006-faa0-7bd7be16f4da',
  'Spencer',
  'Fleurant',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '95f064c5-f725-0006-8f09-cab36284516c',
  'Jason',
  'Gaylord',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '26967907-e703-0006-5f9a-2a25c57d4d46',
  'Daniel',
  'Giorgi',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b946b12b-cfff-0006-254a-6bb70d5a4122',
  'Kevin',
  'Harrington',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'dd882c44-0d60-0006-d0be-366d480388fa',
  'Stephanos',
  'Hondrakis',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b155a0c4-7b1d-0006-7522-3f5e75a4f1c7',
  'Cris',
  'Huacon',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'cd066a82-4806-0006-2e80-9392fae48ad6',
  'Samuka',
  'Kenneh',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd0bb1d8b-2d88-0006-425a-cba7604cccf6',
  'Evan',
  'Kim',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '43550c1f-ebee-0006-7a52-62f5c95f5482',
  'Brent',
  'McKeown',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7aef160c-eaf2-0006-f671-8485b9437a57',
  'Enrique',
  'Montana III',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '89cdfd6c-d787-0006-d900-491e7ce24064',
  'Jack',
  'Mulhare',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '0cfae6e2-c65b-0006-aa6f-6fbf00f42df0',
  'Curtis',
  'Oberg',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'eb9c3771-5d7c-0006-5f30-8ac16610de94',
  'Farouk',
  'Osman',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '648e0435-0fef-0006-9f01-2453924d5327',
  'Cole',
  'Parete',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '4a3c8d2a-51af-0006-aa71-61202c127768',
  'William',
  'Pearce',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '322981c0-1fe1-0006-dd98-91f8eaaec451',
  'Akeem',
  'Phipps',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a4cd1fe6-b5a5-0006-060f-e4ba3e5bbf88',
  'Layton',
  'Purchase',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd1b3680e-ebf9-0006-9f5b-e06dbf0b1606',
  'Nabeel',
  'Qawasmi',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '3cf2ea8e-c9ec-0006-f0e4-0903b7189ce3',
  'Yannick',
  'Rihs',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f2eb412d-cd5f-0006-31dd-f288cdc65d05',
  'Antonio',
  'Rocha',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c4b69158-1295-0006-380b-9d5f50052611',
  'Jake',
  'Rozhansky',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '3e3322ca-d940-0006-f329-c8cbd23c60be',
  'Yahli',
  'Saltsberg',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '33ff1ee8-0488-0006-9ef1-ce5436ff921c',
  'Frank',
  'Shkreli',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '2ad4f0ec-6ae6-0006-6705-c122d3a28def',
  'Michael',
  'Soboff',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '19afdc23-6ed6-0006-962b-f6078457bf46',
  'Tom',
  'Wallenstein',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'bd5fcc93-54be-0006-632a-eb4a87111153',
  'Michael',
  'Wampler',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '6c593aa2-c9d2-0006-118b-a45da93ed968',
  'Peter',
  'Wentzel',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '30471c7b-f4fe-0006-2daf-ff0aa57c8207',
  'Edwin',
  'Zuniga Lopez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Central Park Rangers FC USERS
-- ========================================
INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '6400a53a-c0b1-0006-c2c1-f06107272338',
  'Abdul',
  'Karim Bah',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '4321140e-41f3-0006-2016-23c06cc59555',
  'Ibrahima',
  'Bah',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '8ce5236a-2665-0006-3ac1-a727e3ea8299',
  'Matthew',
  'Baringer',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'bdf66c42-99b7-0006-16bd-e883a6fa027e',
  'Cesar',
  'Buitrago',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '909c8051-a601-0006-3b21-a4f4f60d56cf',
  'Vassiriki',
  'Diaby',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ebf5c86e-f594-0006-ca66-af82c13adc03',
  'Elhadj',
  'Diallo',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '299ea506-ab3f-0006-079e-bff363d76130',
  'Youssouf',
  'Diallo',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '4809998f-c160-0006-eadb-62d3159b9b84',
  'Ighoghoe',
  'Erediauwa',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '97caf7ea-0c49-0006-48fb-474ee9b98fcf',
  'Luis',
  'Granados',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '0d6325f7-952e-0006-a692-5239c5d09c23',
  'Radouane',
  'Guissi',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '59634929-83ef-0006-b2ee-558c0e43e7cd',
  'Joseph',
  'Kalilwa',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '4263e408-4561-0006-a2d8-a906585e185c',
  'Nicholas',
  'King',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7d6d06ee-6694-0006-521c-6497d921ea56',
  'Anyolo',
  'Makatiani',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e6c42fb3-bd7d-0006-7672-3d1915509a2e',
  'Matthew',
  'McDonnell',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '19138c23-bd1a-0006-33bf-096185790ea3',
  'Mohamad',
  'Miri',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '70de6205-b31e-0006-2231-eca9806af0f9',
  'Aymen',
  'Mohamed',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '90e689e4-0c8a-0006-ea38-c85229492500',
  'Eoghan',
  'Morgan',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '4a35132b-ed78-0006-35b0-cc73a216abcd',
  'Luca',
  'Natale',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'edf2fe1b-e561-0006-8856-a74938f2a735',
  'Ezekiel',
  'Omosanya',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a0926711-47b9-0006-0b99-23e5c63844b6',
  'Maynor',
  'Palacios',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '1040a9c0-2d96-0006-72b9-a56a1ed8dd85',
  'Justin',
  'Peters',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '1d8c2a48-325c-0006-fca1-96ba294a5d04',
  'Jaidon',
  'Selden',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'fee01806-73fb-0006-ec40-e60461e53f22',
  'Ismaila',
  'Tall',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '77314a44-b988-0006-9617-9e7a0e61fd66',
  'James',
  'Terpak',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b5d17042-4464-0006-c762-ec4e66379275',
  'Dominic',
  'Tomety',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '913e8618-6262-0006-3674-3abdd9a89db4',
  'Samuel',
  'Urban',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f6ed8295-6ae4-0006-e301-49a4ef4f02fe',
  'Christopher',
  'Valentine',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '02071ec5-affd-0006-efc7-b35131388eb1',
  'Marcial',
  'Viveros',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '6001a807-29e9-0006-7e2b-4e92d522ed9e',
  'Timothy',
  'Williams',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- WC Predators USERS
-- ========================================
INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '73e80cff-7b6b-0006-bb21-6322f3d274b5',
  'Brahim',
  'Hadj Abboud',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5e3f4cca-bea8-0006-a670-46771038170f',
  'Tomas',
  'Ascoli',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '77470338-c623-0006-c548-0aa3a6e330ee',
  'August',
  'Axtman',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '0ab541cb-335c-0006-74a6-3d7ea57f27d4',
  'Edwin',
  'Bedolla',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f141d474-787a-0006-d45e-47bc6736ffec',
  'Noah',
  'Sutton Beltran',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '147fb591-8d3d-0006-be4d-9c0dc25d4184',
  'Ammit',
  'Bhogal',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '72e5127a-0420-0006-195f-ba747905cb41',
  'John',
  'Bonas',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a0860460-a8d9-0006-485b-c66645a15db5',
  'Marcus',
  'Brenes',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '8e26679f-a4e5-0006-f878-c76a25672fb7',
  'Carter',
  'Burris',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a836e83f-94cf-0006-8043-2d8885a74c04',
  'Colin',
  'Forster Davis',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'abccd0b4-b8fd-0006-0d6f-bc1f68a9dca2',
  'Alex',
  'Demars',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '21a198c1-c1be-0006-5275-35e5e2d03bb3',
  'Oliver',
  'Garcia',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f236924a-f93c-0006-0133-9296ae3556e0',
  'Michael',
  'Gonzalez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '356a7d21-6e82-0006-3470-dc8fc101267b',
  'Emmanuel',
  'Hewitt',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '1821dd74-7def-0006-5d0d-8fc2237b95a9',
  'Bobby',
  'Dwayne Hickerson',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '8e947f42-3cf8-0006-843e-60f8b5fea83d',
  'Luke',
  'Hill',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '2915f812-2eaf-0006-3247-a3ee3a2c7d3d',
  'Dylan',
  'Leonid Lacy',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '163628c2-89d1-0006-d1af-bb18a863454e',
  'Joel',
  'Lopez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '409dde8f-23a4-0006-e141-4d64030234e5',
  'Dominick',
  'Martinez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '717e4cbd-f435-0006-5502-e6c0727b7c97',
  'Brian',
  'McDaid',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7b7896a2-c6e0-0006-957c-616ed64dd685',
  'Luca',
  'Mellor',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f99e964d-eaa9-0006-c8ae-032e285b76b7',
  'Mason',
  'Miller',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a719d07e-0517-0006-4eae-bc3d71aa524d',
  'Ayoub',
  'Mouhou',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7d34576c-c7d0-0006-dbc9-d786cde27cac',
  'Riley',
  'Porter',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '59d24fd9-50d0-0006-54f4-e73ab264adca',
  'Luke',
  'Pressler',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5f863b85-eea9-0006-40a9-1840f613e7de',
  'Ridge',
  'Robinson',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b5c3d2b2-4c4a-0006-896b-98221bce19b9',
  'Miguel',
  'Ross',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'eb392240-6123-0006-ab7b-66e5e6335dc2',
  'Maximos',
  'Sacarellos',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '9df4a12e-0f4b-0006-42a6-9dc70077a9c7',
  'Justin',
  'Thomas',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c65439ba-734b-0006-b92b-69fae3536a62',
  'Luke',
  'Thomas',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '78567556-1970-0006-3861-b9e49089ccf1',
  'Sama',
  'Tima',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '293f3da0-7fe3-0006-9f2c-8e940b99a09c',
  'Kyle',
  'Tucker',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '6bfd6b45-130a-0006-04a3-db60a109c0cc',
  'Nikhil',
  'Ashish Verma',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '111652fa-a72d-0006-615c-f27cf2316ff8',
  'Jacob',
  'Weaver',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'aa703ec6-38af-0006-7896-981f05f6694e',
  'Charles',
  'Wilson',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Alloy Soccer Club USERS
-- ========================================
INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '16d92ff3-9a57-0006-147d-280de1b7db40',
  'Matteo',
  'Adiletta',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '814a9c1d-8620-0006-fc65-3b86fdfbac20',
  'William',
  'Ardiles',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '84d2ee83-7c45-0006-1dab-59de9792906c',
  'Serge',
  'Biket',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '8ceeaa55-f225-0006-08cc-ffb7de4701a8',
  'Ryan',
  'Butler',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'dfe87512-0319-0006-8548-325bd5838ee9',
  'Obiazie',
  'Chinatu',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '17c9c8e7-1315-0006-bb2f-416ce8a18678',
  'Seth',
  'Crabbe',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '985ebafc-5269-0006-25fc-ad8f0dc32b3c',
  'Leo',
  'Dunia',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '492ea2dd-919e-0006-644c-293da698aae6',
  'Ivan',
  'Fombu',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '64afe88d-0fe3-0006-5a43-346701077142',
  'Nikolaos',
  'Gousios',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '1f2de849-cb2d-0006-2909-7ee022ed5674',
  'Isaac',
  'Hollinger',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '4686541b-cf02-0006-3704-ffda942ae37b',
  'Micah',
  'Hostetter',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b4e19a88-ed02-0006-16f6-954571f73f18',
  'Abdoul',
  'Issoufou',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '1ec1357e-f099-0006-9e77-85c72c0f7eb3',
  'Clovis',
  'Kabre',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '50b1a6e6-ab05-0006-facb-7d8d04b79397',
  'Justin',
  'Keefer',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '66f7cd58-be5d-0006-8bf3-4a46a6245a00',
  'Mehluko',
  'Letsoalo',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '6fa99191-236c-0006-9c0e-142c5199daac',
  'Kel',
  'Merckel',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '46b93ff5-4a41-0006-513d-fab5d6778c83',
  'Caden',
  'Mullen',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '4f04250a-4984-0006-8f4a-4961b600ac45',
  'Babunga',
  'Mulumeoderwa',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '222b5834-d814-0006-8243-9a84fbf3efa7',
  'Luke',
  'Nall',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '48930eb9-5f31-0006-6cb0-abb280213e4c',
  'Sivpheng',
  'Phann',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '0b634a77-de63-0006-5f0b-c219e2d3314e',
  'Derek',
  'Ramirez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a576fe92-034d-0006-ef52-0f7ac0658a1a',
  'Josiah',
  'Ramirez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '82284f64-89cc-0006-10c8-8fe9b7e7d46e',
  'Chris',
  'Richards',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '142189da-3562-0006-c670-f7a826da045d',
  'Daniel',
  'Rowe',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd0123234-a6ba-0006-20fd-9b1ee7e590e2',
  'Lazaro',
  'Salazar',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '829e0d25-5eec-0006-40be-c05fa9fedd68',
  'David',
  'Tai San',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '69e8d194-ff48-0006-c460-a912f7fc942d',
  'Dawson',
  'Schreck',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5f21b05f-63cb-0006-70b8-cbe8e5e79b42',
  'Owen',
  'Shea',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '2512eac1-4e1f-0006-f908-b74a67ea1df7',
  'Denis',
  'Tarasov',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a305845b-886c-0006-870f-5bd1836fecf8',
  'Babo',
  'Tereffe',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd4fd6fa0-6e88-0006-589d-a3de0ad19a5a',
  'William',
  'Vasquez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'bd5686cf-ff37-0006-ab7d-7b1f782c12a4',
  'Joel',
  'Walker',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '2bd72cfd-a1b1-0006-5bd2-7d60d55e868f',
  'Christian',
  'Wieand',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '868ba230-c422-0006-edb3-2d111bc2f2d0',
  'Kedric',
  'Yoder',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Philadelphia Heritage SC USERS
-- ========================================
INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '9f528086-f1dc-0006-02d3-129c1a89f217',
  'Eric',
  'Adamo',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '61766419-79ba-0006-0d2c-67d82acac321',
  'Salam',
  'Ashurmamadov',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '3534290b-8ac7-0006-cfde-3d2307bc6777',
  'Matthew',
  'Bergmaier',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '9da04c79-4301-0006-981b-20a78277623a',
  'Daniel',
  'Bloyou',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '696479a2-a4dc-0006-e7d9-4f413577ba63',
  'Lawrence',
  'Buigbo',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'faa898f0-7e7d-0006-cc5f-7588ef4c6c67',
  'Diego',
  'Cabrera',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '584d92d6-3f6a-0006-5138-2b12bbd10beb',
  'Emanuel',
  'Caire',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '773910ac-70bb-0006-1347-bffa895dabbe',
  'Sebastian',
  'Carmona',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '675b867c-0b93-0006-0afb-24743fad4132',
  'Chad',
  'Catalana',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '01181b06-fd26-0006-a9b5-e37fb0513489',
  'Nyles',
  'Cayemitte',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '42fa29b2-81ec-0006-4921-e5d1d785ed98',
  'Justin',
  'Cooper',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b3652ce9-2860-0006-5640-e94c61724552',
  'Kevin',
  'Davis',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '61cf4157-f653-0006-b5c6-39c24fd9866a',
  'Alvin',
  'Deegon',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e53ed71e-debf-0006-7a8e-6520d161bc2f',
  'Yousouf',
  'Doucoure',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e0d5e932-646a-0006-1004-33bb89698dcd',
  'Nick',
  'Dudek',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '195add2e-8735-0006-4171-644823d4a00f',
  'Andres',
  'Freire',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b63c6d5f-6693-0006-bcbf-383487120e1a',
  'Luka',
  'Gogidze',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '2d975247-9777-0006-523d-193f2d2cab53',
  'Andres',
  'Gomez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5f795242-1de4-0006-0aa6-6482c08358ec',
  'Brendan',
  'Gorman',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '87449ab5-c81a-0006-9188-c8cd09391777',
  'Ermir',
  'Hoti',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '10c00684-5530-0006-9e75-64bb24a81c8d',
  'Hamin',
  'Kim',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '821024ec-6e2e-0006-3551-960d684ab8dc',
  'Kalvin',
  'Matischak',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '4cb51f6b-50be-0006-cf9c-25c385f61e40',
  'Gabriel',
  'Matute',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e5d4d925-f466-0006-f20a-032c43eb1d7f',
  'Aidan',
  'Meissler',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '1d318d31-a7df-0006-b874-24cbd65e7938',
  'Glenn',
  'Moyer',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c569a669-6ad3-0006-1674-025adc8f95a5',
  'Kyle',
  'Mtshazo',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '445eaea8-b547-0006-520a-df103335510e',
  'Daniel',
  'Murtagh',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd2ff88b2-4803-0006-614c-3f5861963ff9',
  'Justin',
  'Odoemene',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f3f76a07-6ebb-0006-5864-e904be625495',
  'Ryan',
  'Pereus',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '9b1b152b-fd16-0006-82cb-df0e8f9c03ac',
  'Christopher',
  'Rodriguez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '77b15275-e972-0006-c1a5-9fb831d3b337',
  'Eran',
  'Shifris',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '287bd74a-b462-0006-448f-0174adcd134d',
  'Andres',
  'Velez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '30939ef1-3caf-0006-f5c3-842dc5a6597e',
  'Seth',
  'Walker',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7e36ec31-3ad0-0006-96c9-d37bd0f48623',
  'John',
  'Steven Warren',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Real Central NJ Soccer USERS
-- ========================================
INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '86d51aa0-be25-0006-193b-db3e2adc4631',
  'Djibi',
  'Tata Bah',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '35b1bc42-4f1e-0006-ded9-b9df3a34c5cf',
  'Walter',
  'Barreto',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '43413162-7882-0006-5d56-b71e555f9691',
  'James',
  'Bernstein',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd0292f9f-02dc-0006-06ee-75cf7adf5925',
  'Pierre',
  'Bosquet',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c244cfb8-b093-0006-774a-eacd70542335',
  'Erik',
  'Carchipulla',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '18147fb2-d96a-0006-4857-e033c4bc4f26',
  'Filippo',
  'D''Anna',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b4526f39-7e27-0006-eee2-a89b63af889e',
  'Jonathan',
  'Firmino',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'fe568cfe-11cb-0006-3574-4e8e598c776e',
  'Jose',
  '(Tony) Flores',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e45c7edf-df0e-0006-1633-4653a2f8a3c2',
  'Liam',
  'Fredericks',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '6d4f96c4-14e0-0006-e08b-170b463b4edf',
  'Eric',
  'Goldberg',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b1bbae49-4fc5-0006-1db2-7b7fd6536ad4',
  'Lorenzo',
  'Jayakanthan',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c873d9ec-eef6-0006-a865-3f32b5e09c36',
  'Taeus',
  'Jones',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5093c74f-9ade-0006-a102-19d78a9aac18',
  'Brendan',
  'Kerins',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'dab4223f-fc7f-0006-4d2d-a7ff6c296cd5',
  'Sean',
  'Ryan Milelli',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5f8f41f3-183f-0006-a400-f08ef20db0e1',
  'Conlan',
  'Michael Paventi',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a95fd652-5fce-0006-4adb-c8d9dbfe5421',
  'Kevin',
  'Perez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '2268ea79-4d94-0006-0405-8b7d22b68d60',
  'Giovanni',
  'Pierleonardi',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'cd79bce6-dcf9-0006-efbc-6da8fe9f09b5',
  'Giuseppe',
  'Pierleonardi',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a47a3208-71ee-0006-f734-0e9edf876ad6',
  'Guiliano',
  'Pierleonardi',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '1b2b5528-15b8-0006-17e4-bb120dbed317',
  'Vincenzo',
  'Pugliese',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f8c2ad45-eb32-0006-558f-9243f57f3d01',
  'Joel',
  'Quist',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd500b3ed-3494-0006-be2c-242a2025d9d0',
  'Dennis',
  'Rooney',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '1ac818b2-8c87-0006-0c07-ee686030fe48',
  'Ilia',
  'Sakheishvili',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'bfd119b4-ce47-0006-27fc-97aeb536d1f6',
  'Cole',
  'Sotack',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'fcb29f52-86c8-0006-9d89-d9194f1d9477',
  'Reed',
  'Sviben',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '68a552ca-73e0-0006-9f60-eb800ec5e1bd',
  'Brandon',
  'D Valeri',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '6b595c01-24db-0006-8754-89f6298a6d58',
  'Ronald',
  'Ventura',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Vidas United FC USERS
-- ========================================
INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '07e8cd0c-8ccf-0006-707d-3add15aeb8da',
  'Emani',
  'Arroyo',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c466ff26-125b-0006-da01-94c3ece9fe2f',
  'Nolan',
  'Bair',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b3a4953a-6ccc-0006-2a2c-e8f00911e2ae',
  'Almuthenna',
  'Hseen Baled',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '3852c479-f1e8-0006-5176-079202b770c4',
  'Richard',
  'Blanchard',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ee0829ea-5c96-0006-da85-f155a15be98c',
  'Bakuri',
  'Buadze',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e1f24d22-9ee9-0006-fbaa-bb38bb3a5375',
  'Maximo',
  'Chavez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7f88e917-d531-0006-6b0f-714b3dc1994d',
  'Evan',
  'Chinwendu Azoro',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '1fabdff6-2b87-0006-c19a-56b2f4cbd91d',
  'Adan',
  'Crispin-Morales',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f10de78a-a2f5-0006-c690-2a8d548fc5ce',
  'Jorge',
  'Luis Diaz Lobo',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b10aa613-4f83-0006-a7ba-ff36dec80c0c',
  'Spencer',
  'Dickinson',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd93b3955-5647-0006-a808-2755eac9fdb8',
  'Isaiah',
  'Fox',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '8e84bde8-8c61-0006-bcbd-908578cfc12d',
  'Goga',
  'Gogoladze',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '43315a90-8c07-0006-c8bb-808a1ef36cec',
  'Stephen',
  'Grazioli',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '28f09349-70fa-0006-9b86-deeb6f3a865b',
  'Mohamed',
  'Ibrahim',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c1cef24c-cd31-0006-2a5f-fe542053ae27',
  'Matthew',
  'JeanPierre',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '8ee042d2-ec1b-0006-7365-4300a9657803',
  'Mohammadzain',
  'Kazi',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '47331ae4-1b98-0006-0aaa-114c9e6e8c72',
  'Guilherme',
  'Martins',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'fcc5d2b9-0379-0006-eea1-57755f8fb2c5',
  'John',
  'Miller',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '04f6fa3d-fe6e-0006-ae7a-861415434260',
  'Edwin',
  'Owusu Siaw',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '64ef506d-0c36-0006-43c7-b8d26236d30e',
  'Juan',
  'Polanco',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ff7f3a3b-4770-0006-439f-ead095ec0449',
  'Angel',
  'Javier Rodriguez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ac8d9e83-4310-0006-4509-180df564e5db',
  'Ahmed',
  'Saedahmed',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7267e085-fbd2-0006-1d8d-0b5af04a0261',
  'Edi',
  'Schwartz',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e70c4f3f-eae7-0006-ed35-3fe58a4fee37',
  'Maksym',
  'Shevchenko',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '2bfde7e9-6e52-0006-fdd6-a94d0989fe28',
  'Alexander',
  'Simon',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5565c7c4-c50d-0006-8e55-b704a3cac296',
  'Daniel',
  'Smith',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '13b1aaa4-f205-0006-4f9d-e6476b707f5b',
  'Christian',
  'Sorteberg',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '03ec51ee-52f3-0006-910c-ba2407fb16b9',
  'Sekou',
  'Sylla',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '8aa059ed-5b5b-0006-da67-6538d4b43523',
  'Abraham',
  'Waldman',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Philadelphia Soccer Club USERS
-- ========================================
INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a9ba68f3-0f7f-0006-358d-fd63a7689123',
  'Mark',
  'Abbonizio',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ae04becd-a47b-0006-5a96-4c38531d03d4',
  'Sergio',
  'Abelardy',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '72e4776c-5809-0006-e317-9cf118445bd7',
  'Pedro',
  'Barbosa',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '719d9258-cf7e-0006-8eb2-ffb5f0a6d894',
  'Hunter',
  'Bell',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '6b4d97c5-783b-0006-e858-7e43a4e3a710',
  'Mohamed',
  'Elgayar',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '2c0045fc-8936-0006-4901-3005a950d5fb',
  'Salvatore',
  'Ficarotta',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd0fa7536-1fb8-0006-b191-b96070d0cd69',
  'Henry',
  'Guzman',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '965482bc-020a-0006-7e19-24e46a2f2557',
  'Theophilus',
  'Ijeboi',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'dfb495f3-ad0d-0006-4a63-f277ab99a9e5',
  'Mohamed',
  'Jawara',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c962643d-da84-0006-abf0-3cee898b0284',
  'Sean',
  'Murray',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '1bace6e6-6191-0006-654e-438eae1d01c7',
  'Laurence',
  'Narcisi',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '64205475-7ea5-0006-c157-b58d5f8e7352',
  'Michael',
  'Newell',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '9d94f51c-9581-0006-b91e-6704c9277f7e',
  'Kaleb',
  'Raymond',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '43cd8a37-250f-0006-0f1f-2dc468827103',
  'Joel',
  'Richmond',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '52e2cae2-d9ac-0006-554f-de40933cc1c8',
  'Benjamin',
  'Richter',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e92ba81a-e412-0006-e30c-0ed3b9f606e2',
  'Joshua',
  'Rifkin',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '4f0ca7b3-0687-0006-b5ca-ae8876879ca5',
  'Daniel',
  'Saint-Pol',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '2933ab46-31c8-0006-221d-5f7dfabcd0a9',
  'David',
  'Skiendzielewski',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '33988cd2-c5b4-0006-6f0e-764693b44a97',
  'Owen',
  'Stock',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '20223cdc-63ce-0006-8a49-05e9f504fa48',
  'Ryan',
  'Stock',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'bf24ae90-55f7-0006-180e-162c9b2c4f35',
  'Rasheed',
  'Thomas',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ef84510d-4ce7-0006-43ca-f65fc4d0ede9',
  'Sean',
  'Touey',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '2d7f675c-563a-0006-2dfd-c9692bbc5d9f',
  'Jesse',
  'Weick',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Oaklyn United FC USERS
-- ========================================
INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '71df8607-2764-0006-be4f-f62b9022a409',
  'Osman',
  'Barrie',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5799be88-db80-0006-f9ef-3df307a698c3',
  'Paul',
  'Bechtelheimer',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'cbd4f193-e8d8-0006-b980-4cce087170b4',
  'Nathan',
  'Biersbach',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '78c995a8-6426-0006-330c-e738344e92fa',
  'Brayden',
  'Birnstiel',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '85f9b46e-9ec5-0006-998b-b595bfef6d83',
  'Theo',
  'Da Silva',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '35f70e2e-8c57-0006-5f5d-a7f450d84339',
  'Kaelan',
  'Debbage',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd846eb32-8018-0006-f104-98587d54395d',
  'Blake',
  'Driehuis',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '106939cb-a4c7-0006-03ac-8261cc90d806',
  'Gavin',
  'Faracchio',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '9d5dce99-7e66-0006-dcf4-6880c44244c1',
  'Emin',
  'Gunaydin',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd39431ba-d80b-0006-a7d5-62fddc3a4727',
  'Vincent',
  'Guzzo',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '60a07d61-7b5e-0006-0b32-d3677eb2dcfc',
  'Maxwell',
  'Byrd Hawk',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '02cd6efc-7b96-0006-ca40-f23545453cb5',
  'Anthony',
  'Jenkins',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '029f4f0c-02ac-0006-18e9-3c393b8d02d6',
  'Austin',
  'Johnson',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '06afadb4-7733-0006-4d6d-191596b99910',
  'Sincere',
  'Kato',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '562059bc-79d0-0006-f3f2-b383e1e8ddf3',
  'Muhammed',
  'Ali Kol',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '8ea1cdc4-0882-0006-5a0b-c3a308b287f2',
  'Berlenz',
  'Lumarque',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '0dfa7220-ee26-0006-829d-a9265ac259c3',
  'Jason',
  'Mancuso',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c22c0a10-052b-0006-ee1e-9ffac117ebea',
  'Jade',
  'Mesias',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b7c66ebe-25a9-0006-9eaf-6715c42b61c2',
  'Jeff',
  'Morgan',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '03685128-c258-0006-7b3e-65e96d6cb14e',
  'Jake',
  'Mulinge',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '80b973f9-ae54-0006-2fab-9bf2c4583f2f',
  'Joseph',
  'Nguyen',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ae70b5a1-d1de-0006-48b1-ed3fd75f5c55',
  'Matthew',
  'Perrella',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '31ce6bd2-40c1-0006-a3f0-0c57e0a14847',
  'Samuel',
  'Quaye',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '8a0a6f35-57d8-0006-ad2d-18b037714c72',
  'Julito',
  'Quintana',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '2c2c7d61-fde8-0006-1396-b9747a713457',
  'Ethan',
  'Romito',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'fdea7ec3-67b0-0006-2e92-7876591b7854',
  'Ahmed',
  'Saidi',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd2509fe2-42ad-0006-bf78-24ba4885ea4c',
  'Seth',
  'Sidle',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '85308641-904a-0006-265b-a8660dd49ced',
  'Adam',
  'Sternberger',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a02363ec-3315-0006-1d6e-e6943eee6ca5',
  'Steven',
  'Thompson',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ee75d842-1ae6-0006-8c53-9d885fc74c26',
  'Nico',
  'Tramontana',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- GAK USERS
-- ========================================
INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c6634ec4-3116-0006-97cb-10929f847d88',
  'Geovany',
  'Acevedo',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '8c057fae-c618-0006-afe4-0bca248a8f23',
  'Axel',
  'Bladimir',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd7fbbe6c-af7c-0006-a7f5-21289ec00427',
  'Julien',
  'Carraha',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f51d3955-418f-0006-7089-6cba763c51ba',
  'Nicholas',
  'Cruz',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7a6f6516-397c-0006-7d94-d1ea3c0ca3f9',
  'Aba',
  'David',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '35d32d60-a2ed-0006-341a-55683e159c03',
  'Jonah',
  'Dias',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '8aab63f1-c4c6-0006-32ff-583e6a12263c',
  'Mamadou',
  'Diouf',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '9fb18392-3760-0006-95a4-ef5fddde7950',
  'Oliver',
  'Dyson',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '81751f47-3547-0006-ed06-174be04b84dd',
  'Robert',
  'Ellerson',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '0888b0b4-487c-0006-fa70-cea0d131771c',
  'Carlos',
  'Fuentes',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a0ba6bb8-a359-0006-957a-b3c1a5111aed',
  'Randy',
  'Gonzalez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5030ea77-ddfe-0006-1fb4-428e8701c150',
  'Daniel',
  'Grund',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c1a269c4-7f62-0006-2b52-f4665c63f46c',
  'Ryan',
  'Grund',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e79a8f46-0fdb-0006-ad87-40a83df9316a',
  'Chidi',
  'Iloka',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd8d39dca-cf6c-0006-d693-02d484a00311',
  'Davenson',
  'Joinvilmar',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd8ba57f8-b7bd-0006-4e4c-956bac1c2900',
  'Dylan',
  'Kotch',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '75401479-549d-0006-01f2-505157115e85',
  'Liam',
  'MacDonald',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '3c37f45a-0aed-0006-7fa2-77f3467e5de7',
  'Anderson',
  'Martinez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '9d527478-a389-0006-46aa-2dfb9aac6b3a',
  'Arnaldo',
  'Mendoza',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7e42fc98-b13e-0006-1dc3-c70b98e4b21d',
  'Dani',
  'Morales',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '9c7f4fef-d2d3-0006-8a52-407f71a1ea9f',
  'Lucknerson',
  'Pierre',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a695b106-8071-0006-ec89-9777f3460789',
  'Kyle',
  'Pilliteri',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '3f57ba68-1014-0006-bc01-aa1cf4c3698e',
  'Alex',
  'Quezada',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '3f240fc1-f882-0006-09d4-058b0609ab21',
  'Wesley',
  'Reyes',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a9792982-fd05-0006-a548-363d171b95e9',
  'Arnol',
  'Rodriguez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '652319d6-5062-0006-a0aa-018bace24cc1',
  'Nick',
  'Sample',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c05fc6df-acb1-0006-62db-d02e7a9e6960',
  'Melvin',
  'Sapon',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a9d06281-f304-0006-521e-1adca8723c9b',
  'Chefetson',
  'Simeus',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '54d14e1e-2f6d-0006-32cd-f0d343e0cca1',
  'Emerson',
  'Vicente',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '0478cdd5-c6a4-0006-de9e-aa4ccd100674',
  'Mate',
  'Vilagosi',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a845b6de-d2ac-0006-cb5f-fec49ee7bda0',
  'John',
  'Warwick',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Lighthouse 1893 SC USERS
-- ========================================
INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '01aca9b0-ae64-0006-e96d-7e69a00ffec4',
  'Musa',
  'Abdelgadir',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e7b6e3e7-4b6c-0006-c471-183c094b8b51',
  'Amar',
  'Abdelrazek',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '326e6bc0-e8ed-0006-62b1-b4e94dd6a079',
  'Abdelrahman',
  'Ali',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '1089a0ee-8eb6-0006-d3d5-20bf6ba6ee7a',
  'Ahmed',
  'Ali',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '52737162-6e42-0006-4a28-377d5fbdb22a',
  'Erwa',
  'Babiker',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '769b5796-c33c-0006-69b6-bc37abae18bf',
  'Arsene',
  'Bado',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f5dfe66e-8e08-0006-ff59-107bf2898b1a',
  'Logan',
  'Bersani',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'dd7d3571-d69e-0006-7979-7a2ce126dac6',
  'Mohamed',
  'Bility',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '326e8020-b576-0006-761c-7e233e2fbba2',
  'Hamzah',
  'Dabbour',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '97b0d643-5b54-0006-be6b-066460c214b1',
  'Terrence',
  'Doe',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f9e55725-38a4-0006-4da9-32f792737ce3',
  'Musa',
  'Donza',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '8194c8f3-e9b5-0006-1b83-b544991ee783',
  'Alexander',
  'Duopu',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '6f56fb40-d2e7-0006-962f-ecf2b2125067',
  'Luis',
  'Espejo',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '68b0bb11-c853-0006-7aca-7a06730bac1c',
  'Christopher',
  'Fletcher',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '49385a1c-d37b-0006-f0c9-dac164502d9b',
  'Mujtaba',
  'Galas',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'df029c0e-28c8-0006-5da8-18ab2837dcaa',
  'Mustafa',
  'Galas',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ce93b48a-1f6b-0006-e2c1-47799cfcfff5',
  'John',
  'Gonzalez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b128734e-616a-0006-94f9-740b7dab4b61',
  'Ahmed',
  'Gosie',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '3cb5f823-9e5d-0006-e69f-35b97baec652',
  'Maccarrey',
  'Guillaume',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'aecf8394-3dea-0006-c777-facfc9af77f9',
  'Otmane',
  'Houasli',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '4d8fb2ee-241e-0006-98a8-9f87f7b4be5a',
  'Esnayder',
  'Josue',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '57ae3eff-d209-0006-409d-b97ebabee860',
  'Abdoulaye',
  'Kamagate',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '1058e8dc-f991-0006-3421-156e9aae5a81',
  'Amadou',
  'Kamagate',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '70b36e4b-b5bd-0006-dd9c-f58dfcd5c239',
  'Majid',
  'Kawa',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '23dd5826-bb2e-0006-4dd3-59927f01b65e',
  'Mohamed',
  'Khalafalla',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '87d3f035-c0d4-0006-ee7b-0637fb8b40fd',
  'Kouassi',
  'Nguessan',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f57ec0ec-24ef-0006-a2f7-0aad81711c11',
  'Benell',
  'Saygarn',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '0af0fa43-db02-0006-b625-bf47c0eb6099',
  'Oumar',
  'Sylla',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Jersey Shore Boca USERS
-- ========================================
INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e5489cab-1ff6-0006-7ba7-7b04f178d0f9',
  'Justin',
  'Alves',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '1bbff203-f549-0006-9605-bfe8251d9914',
  'Rob',
  'Andrade',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '9e91d86b-35c2-0006-b841-c082d5825af0',
  'Tyler',
  'Andreas',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '31994764-1fe4-0006-bc86-ce0a4b68bbbe',
  'William',
  'Bartels',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '52936b80-8e59-0006-0fc4-85ccda24d91c',
  'Harmony',
  'Bell-Gam',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e25db64e-fe6e-0006-190f-d87dcf9dad2d',
  'Dane',
  'Calhoun',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '73f34efc-6372-0006-9dc0-d133eefe09c6',
  'Adrian',
  'Dilascio',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '8abc7a91-74ac-0006-8d9c-15adf9f405ab',
  'Grady',
  'Edwards',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '921bc389-af8a-0006-313c-7cd6526a255d',
  'Matt',
  'Fuentes',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '4a253e7a-7dfc-0006-2a37-2ee6bc89c4e3',
  'Douglas',
  'Jensen',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ecec0332-f886-0006-960c-691a358e9193',
  'Dylan',
  'Kanson',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e33aff11-c818-0006-d022-1628d35160a9',
  'Marcus',
  'Mason',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '52ce4b42-dcd8-0006-a26b-381fe16ff2f7',
  'Carter',
  'Mathis',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '801582d5-d5a2-0006-8a55-ff1041b1d21b',
  'Alex',
  'Matos',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f8174808-81f6-0006-8c36-49a9fe9967f7',
  'Rafael',
  'Pereira',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '6dcbe7ad-949d-0006-397c-138e5a82286d',
  'Anthony',
  'Ryan',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b9dce495-41bd-0006-fde2-328e8693d33c',
  'Bryan',
  'Sanchez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'fd714f3e-bd0e-0006-c240-7afae08290ec',
  'Dante',
  'Shenkin',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a28a3152-af47-0006-f2d4-cd47e151ae81',
  'Gianni',
  'Smith',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '3ad2a010-eaa8-0006-65bb-0ca2bc2067e1',
  'Kieran',
  'Sundermann',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '422465c2-9bd8-0006-b5d4-898e2e13cb35',
  'Albert',
  'Truszkowski',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd9739566-e50e-0006-d8c7-c2de6c5d715c',
  'Uche',
  'Wokocha',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '461fb060-2fe3-0006-1aa1-5ab6b5312e57',
  'Clay',
  'Yannazzone',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b7472afb-4a7e-0006-96bb-0e68d3872ae0',
  'Alex',
  'Zargo',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Sewell Old Boys FC USERS
-- ========================================
INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f67ada13-a784-0006-ebe9-25878029ac0a',
  'Dylan',
  'Frank Aportela',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '9654b13d-c906-0006-5155-d62bf939456e',
  'Monsif',
  'Atify',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'cd58ffbb-6004-0006-5e18-c6a854913706',
  'Shane',
  'Baker',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '40400f0a-dc66-0006-9cac-c6f2a3164647',
  'Mava',
  'Mboko Celestin',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c3722096-f4b0-0006-dca0-cadb9fbf40e2',
  'Gunnar',
  'William Christensen',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a424af65-6f03-0006-058c-a7a48d6652af',
  'Bailey',
  'Cifone',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '99bedb6f-ad6f-0006-e76f-b805ceaac7c5',
  'Emmett',
  'Dougherty',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7f78a7a4-91f8-0006-8b1e-e20ca1f4f8c4',
  'Sean',
  'Fatiga',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '44f85cae-c76d-0006-01db-6b4a9d57cbaa',
  'Gil',
  'Ferreira',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '9ca63f04-9f10-0006-8037-ea09de9c3d8d',
  'Ryan',
  'Gale',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c302c071-2de9-0006-ebe8-64dfecdc632d',
  'Elvis',
  'Gboho',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'fc451354-f699-0006-52c2-7b35e330721e',
  'McCarthy',
  'Tyler Gomes',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b6902b1a-2cea-0006-91ca-d82ff4c21b47',
  'Jeshohaih',
  'Hernandez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a485bb5f-cf03-0006-4c35-e1ee86746e77',
  'Ahmir',
  'Lamar Johnson',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7f8471af-d9d1-0006-1cbb-2f3b3dd5302a',
  'Ahsan',
  'Johnson',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '6fb1b484-4160-0006-e010-9dcf7ad6f1b6',
  'Bugra',
  'Kumas',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '9d9d8ce8-2804-0006-8ea5-b78420c974c6',
  'Jake',
  'Kuzmick',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b032397d-d4bf-0006-1bba-abd247ca1a2b',
  'Dominic',
  'Antonio lodise',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '88fb1858-e71e-0006-59d5-73ed0c8e84bb',
  'Gavin',
  'O''Neill',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '1110bdd3-0313-0006-7007-74dc84613e90',
  'Krish',
  'Olmedo',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd87d3cb5-33a5-0006-c1e6-f9e0579402ec',
  'Alexander',
  'Charles Patton',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f3fe8146-5c97-0006-399f-699797bf0c2a',
  'Mason',
  'James Regan',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '03994c64-9574-0006-6b6b-201159b7c622',
  'Fred',
  'Renzulli',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '17212409-140e-0006-bde1-d2882b37c526',
  'Joseph',
  'Romano',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '0075015c-43a6-0006-70ee-053e5befbd02',
  'Joshua',
  'Rossell',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '07c30bdf-4953-0006-f93d-1432d91d5e79',
  'Brian',
  'Sharkey',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b1aba238-fa67-0006-cdd6-41b151d70e65',
  'Christopher',
  'John Spicer',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '3338fb82-78cc-0006-1a2a-3cbeb8946181',
  'Kyle',
  'William Stone',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f5d2b265-4455-0006-401b-db41d2589cef',
  'Owen',
  'Strohm',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '22d562ae-e529-0006-54ec-c0631e593f17',
  'Melcohol',
  'Velasquez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'fbb69e9a-d0c2-0006-cbcc-00f3224ca188',
  'Christian',
  'Vetter',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Medford Strikers USERS
-- ========================================
INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '10c64bf2-6baa-0006-73e1-c4dc5e7159fb',
  'Anthony',
  'Alexis Ali',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'af9a3985-e5f8-0006-e9fc-85939aaced32',
  'Dylan',
  'Bednarek',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'fbb56593-54a4-0006-4579-9065523a45c3',
  'Garrett',
  'Blankinship',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'dffe5dbe-040b-0006-bd85-8db2f3135b36',
  'Matthew',
  'David Dottavi',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '30037147-8072-0006-0f81-6c31d0c21693',
  'Mohamed',
  'Kasongo Doukoure',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '48c20dcb-2f20-0006-c5ca-5295605fbfd4',
  'Noel',
  'Fernadez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '0fa923fb-0199-0006-0419-4bc4478fbe0d',
  'Patrick',
  'James Fluharty',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '925a13c5-0dc4-0006-3d67-8bbc8278fcf1',
  'Astin',
  'Timothy Galanis',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '508d8fca-1304-0006-d82d-702bd061894d',
  'Anthony',
  'Frank Giafaglione',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd122ea4b-af14-0006-d112-d22449afa224',
  'Amir',
  'Khan',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a264f3b0-56ec-0006-bb04-3475d211c2b3',
  'Anthony',
  'Konah',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ad2ac504-c1a4-0006-b9ad-45d0a61406b5',
  'Brian',
  'Lorenz',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '01f3092d-f59c-0006-7cd8-09762ee218dd',
  'Yoni',
  'Andre Moussodou',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '6710150b-5316-0006-957e-e1d5dfcd1ef6',
  'Oguzhan',
  'Mutaf',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '15b07594-13e7-0006-5f64-04fef9b634be',
  'Rami',
  'Mahmoud Nasr',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a63e54b5-c115-0006-610c-5b7582453ac8',
  'Michael',
  'Negrete',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'aae5f4bb-bb9e-0006-4655-622b22a3613a',
  'Juan',
  'Oliveira',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5799b4ee-1915-0006-27e9-7c2f5000413e',
  'Edwin',
  'Perez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '61af1611-575b-0006-cc22-1b1a6b52ebf3',
  'Antonio',
  'Ramos',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '0a1d578c-6e52-0006-3e41-8a204df067f4',
  'Ethan',
  'Rosado',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5470a7b5-3fb1-0006-90cd-f00b52a6a456',
  'Todd',
  'Richard Salmon',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '4e0f1372-36c2-0006-8095-0fce0252e408',
  'Aiden',
  'Francis Schmitt',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a66e9339-a1a8-0006-2513-a75c735cc502',
  'Liam',
  'Smith',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '26afb7be-8fb0-0006-33c8-bcda9fb77992',
  'Jovanny',
  'Trinidad-Romero',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '9fbb2268-1902-0006-13b8-219c6ec5a61e',
  'Isaiah',
  'Roman Woods-Kolsky',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '92598d33-3c31-0006-e423-efa9e7501110',
  'Chenyu',
  'Yi',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd342c508-d98d-0006-da46-8f27574bf1db',
  'Samuel',
  'Tony Zonoe',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '460081a2-2618-0006-fedd-a9ade5eb0e62',
  'Skylar',
  'Zugay',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Nova FC USERS
-- ========================================
INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '8a6a205a-7cca-0006-ee76-3e7f59fc0eab',
  'Soheyl',
  'Ali Rafi',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '45d5a4c4-ef5c-0006-eb0e-09c8cd4e46b4',
  'Jonathan',
  'Arguta',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '48aab16d-fb20-0006-681b-67bd4f4cfd91',
  'Jean',
  'Ayolmbong',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c37ca36e-55a2-0006-bc10-4a17704f2aba',
  'Eric',
  'Calvillo',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f0827d85-abc0-0006-7f13-2634c79e0ca8',
  'Jhonny',
  'De Souza',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c7a36261-dc54-0006-6b62-6aea5179115a',
  'Valdir',
  'De Souza',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '8ce4b98f-bddc-0006-0d98-1338435df600',
  'Isiah',
  'Dorsey',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '60c49765-32d8-0006-431d-dc5ad9b18356',
  'Ricardo',
  'Espinoza',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b1a6c4ac-10bb-0006-5e23-0dff3660db9b',
  'Jerry',
  'Felix',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'bc7181a2-4b25-0006-af63-0e246c4037cd',
  'Caleb',
  'Ghannam',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e177526e-2320-0006-f5ba-a8f1e234f3be',
  'Jose',
  'Gonzlaez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '2d7e92c3-5921-0006-28e6-f2137efdfb9e',
  'Adsam',
  'Guennouni',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '71bb9e82-4cb7-0006-40d7-936076c8e8ec',
  'Jackson',
  'Hall',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '001e3f63-03ff-0006-e0cb-b68637bc78b0',
  'Emmitt',
  'Inestroza',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd3cce29f-cce8-0006-39a9-9607eaaf5d59',
  'Abdul-Azim',
  'Ismail',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b26687b7-c0ad-0006-40a7-048372c8ff0c',
  'Abdul-Rahman',
  'Ismail',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '2c55d1a3-6031-0006-fadb-27e9d829d446',
  'Ethan',
  'Lee',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5bca2e0e-cda8-0006-d1d9-33cf56343833',
  'Huber',
  'Letona',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '2b8a0534-c0d8-0006-726b-83f07f31876c',
  'Ethan',
  'Lloyd',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f84cb700-50b2-0006-9928-6e32e60feb13',
  'Bernardo',
  'Majano',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e1149adc-7f7a-0006-0210-ea26443b3b5d',
  'Reda',
  'Manafi',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'dc43183b-098f-0006-ab96-acbd14956817',
  'Jack',
  'Pinson',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a1159155-0905-0006-880e-7923df18e59e',
  'Jaime',
  'Quintanilla',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7b3211b1-ff0f-0006-6f39-4aba9902f2c2',
  'Michael',
  'Radomski',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '4c3e723e-57cd-0006-54b5-b1bc2e6cc04b',
  'Ahmed',
  'Sheta',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5d99de83-596b-0006-92f2-61221f51b7c5',
  'Roman',
  'Topler',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '0e184784-501e-0006-560b-114ceac199af',
  'Marques',
  'Vagner',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '3ff56ceb-c246-0006-b53c-fc1fbfad202a',
  'Alton',
  'West',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Wave FC USERS
-- ========================================
INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '20e6091b-ef8a-0006-b6dc-5cace4e9062a',
  'Kelechi',
  'Akujuobi',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '87387418-7b00-0006-077b-bdb995f8c3e2',
  'Faisal',
  'Alay',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'df498f7d-636c-0006-9732-fa812c1f3664',
  'Victorine',
  'Kwame Appohsam',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'fc21351c-aae7-0006-6442-3945dac8b4fc',
  'Hector',
  'Avila Hernandez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '2c9a88cd-82fb-0006-2c5e-2f62c52a4464',
  'Eduardo',
  'G Barria',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '81b97b1d-984e-0006-5515-ca68706b841a',
  'Zavier',
  'Bell',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a84aae62-0d93-0006-cd06-f8356af5e028',
  'Zach',
  'Boyd',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '62c2d5b3-c033-0006-6db4-512430ec4220',
  'Julio',
  'Bravo-Guzman',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a2a4e33a-12ee-0006-2a86-feceb991b495',
  'Deontae',
  'Campbell',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a5249549-ad69-0006-c1de-c3d6cd2a33d0',
  'Brandon',
  'Chambers',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7a2f2756-e33a-0006-a3ea-d7a18d4209b6',
  'Aiden',
  'Chen',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a273ff71-c957-0006-6070-a1e27e7ca0b2',
  'Marckensley',
  'Constant',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '239583df-4fe8-0006-3034-9dfc2bdd9482',
  'Tim',
  'Cooley',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '640c3a9c-b6c6-0006-e83f-323b6ce3beaa',
  'Christian',
  'Cruz',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'bc24c6de-a0d3-0006-a3cf-1f60497856f2',
  'Danilo',
  'Duric',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'db125199-f694-0006-0d79-f905a10a14ca',
  'Logan',
  'Flanagan',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c0f033c9-099c-0006-e1cc-c6ef0905036f',
  'Colin',
  'Foley',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '1a244857-4875-0006-d0c7-8a57ad9bdcf6',
  'Nathan',
  'Gichuhi',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '99151dfb-a66d-0006-8760-66833514e424',
  'Jeremy',
  'Gonzalez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '9a681699-c706-0006-d690-cd03c0af65bb',
  'Josh',
  'Gutierrez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '116361d2-5a35-0006-6f45-7a44bb6aef3b',
  'Jonah',
  'Harvey',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '4ef606d4-a361-0006-0c7b-54c98cd1d702',
  'Josh',
  'Haynie',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '52dfa7e3-1ecb-0006-4988-91aaf12b3e53',
  'Mitchell',
  'Hopkins',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '1acd7741-fa53-0006-85e6-46da5dc5c984',
  'Tanner',
  'Johnston',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '2cf19d93-a04a-0006-c947-5da7b9df7ad9',
  'David',
  'Miller',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '4a163bd5-9295-0006-0263-2d7d93b3eecf',
  'Abdul',
  'Mokhtar',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5226f800-990b-0006-9d53-fad17a37e1db',
  'Bijan',
  'Morshedi',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c3aa1522-f07a-0006-c2f6-b9c72d4dcd6c',
  'Ander',
  'Ochoa',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '3402a511-9820-0006-14cd-a657dbbc7768',
  'Victor',
  'Oladeinde',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7e52798f-e99b-0006-c264-9155c44f309d',
  'Oved',
  'Ortega',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '86e35fb6-59bb-0006-c9d2-3adacb7eac51',
  'Kameron',
  'Payne',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'cb80d2e0-2811-0006-688d-4f0227005854',
  'Jayden',
  'Rodriguez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '85ca48c0-51a6-0006-7f1d-890682279cf4',
  'Oumar',
  'Thiandoum',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'efa170cb-fb00-0006-c691-39d6f16942d3',
  'Ronju',
  'Walters',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- VA Marauders FC USERS
-- ========================================
INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ea38911e-019d-0006-81cf-bfc1c41cfcd0',
  'Mohamed',
  'Abdelrehman',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '0dd7c57d-e353-0006-d135-0774bfa60140',
  'Nyliek',
  'Allen',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '92c1fcf6-6001-0006-4635-14bea9e9460f',
  'Jared',
  'Benedict',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '435d0f98-c5c5-0006-a17d-dcc67e5cd7ca',
  'David',
  'Bernal-Clark',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '29398684-3ef4-0006-c080-d3c3059cfd2a',
  'Alex',
  'Bilski',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd37e87f6-7532-0006-fe63-7fce9ece4af2',
  'Nicholas',
  'Blake',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '6f057637-94c4-0006-6792-2c7c3ee81d0b',
  'Edwardo',
  'Chavez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '277e6125-119d-0006-6a56-2940e99d02d5',
  'Charles',
  'Evangelos',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '1d32585f-3f4a-0006-8be7-04c981cb85c3',
  'Jessi',
  'e Garcia',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '0baccd7f-4b0a-0006-926d-dac754e8ffb6',
  'Daniel',
  'Gonzalez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'acefe636-051e-0006-d10e-3ed76f115f9e',
  'Sayed',
  'Hashemi',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7ece1a85-0658-0006-ed39-949b915ae36b',
  'Vasilios',
  'Kazakos',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5fbf7c9c-03ed-0006-4a3b-2ba971fc7696',
  'Alejandro',
  'Lenz',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '0aabd123-2a74-0006-8c42-c9dace9a21f0',
  'Josaphat',
  'Letona',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a16b014e-2c6d-0006-ac02-4c627c4e655a',
  'Braden',
  'Lopez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '1009b741-c6e6-0006-76eb-9010e50b2993',
  'Gabriel',
  'Maguire',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '658e515c-2ef6-0006-be04-29dc186dcb09',
  'Moussa',
  'Mahama',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '91aeff3b-dff6-0006-8456-e080dd721d51',
  'Louis',
  'Manyele',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a6ff11bf-d379-0006-f617-671c8a047de9',
  'Carlos',
  'Mareno',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '0b378add-0d84-0006-d943-5a550f1dd937',
  'George',
  'Mavronis',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a2354141-8f01-0006-8593-be6028f61131',
  'Michael',
  'Medina',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '62fb4994-83a7-0006-698e-b2e4013a26f9',
  'Roman',
  'Milian',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f9211e29-5fd2-0006-4600-8c2076b8fd22',
  'Johnny',
  'Paletar',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f70c9844-16f8-0006-6c22-7cc383ed3c09',
  'Danish',
  'Saeedi',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '39b58c47-9ace-0006-e346-42d6004e3c86',
  'Jordon',
  'Salvi',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5a9b1fa9-15a0-0006-5c98-46671150599d',
  'Leonel',
  'Sanchez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '12272fb5-404e-0006-03ea-f3f0271ac232',
  'Selim',
  'Senel',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '3a2385ea-ca52-0006-e0fb-6814ce92615d',
  'Ahmadi',
  'Shayan',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'cba566f5-e1e1-0006-cdd0-495973f019da',
  'Akimanzi',
  'Siibo',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7ef2ec8a-d549-0006-e78e-14edbbe77b3b',
  'Alex',
  'Sosa',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5e4eb7b1-35f0-0006-34dc-8df8d72eb5c9',
  'Viktor',
  'Tachev',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '21232c35-692c-0006-7b68-abe14089578e',
  'Matthew',
  'Zelaya',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '3da5238e-ee63-0006-eb33-103b30f768c3',
  'Nebeyo',
  'Zerihun',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '1f9abd6d-6fed-0006-f5b3-8727016e1dab',
  'Ossy',
  'Zubiria',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Grove Soccer United USERS
-- ========================================
INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '23ea29e7-81cf-0006-4e02-a09554130215',
  'Sami',
  'Afiouni',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '6fb82b85-82c8-0006-c127-b5810aefd1bd',
  'Samuel',
  'Amedeker',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f0463993-b06b-0006-2a7a-6850c655de78',
  'Owen',
  'Blount',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e0806b14-5724-0006-9037-6b74f806841a',
  'Jordan',
  'Bonnett',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '50f1bece-6c6b-0006-357c-e3b45fd115c4',
  'Evan',
  'Bosak',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a30d63ca-d94c-0006-a72e-6dcc1d5bf020',
  'Gerard',
  'Broussard',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a4ef4295-5ca9-0006-96e3-479449289fe9',
  'Brian',
  'Chidzvondo',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c39ad8aa-5a3f-0006-c2d0-a54413adba27',
  'Matthew',
  'Do',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd0d33fce-1b6c-0006-afc1-56aaa6df65fa',
  'Joseph',
  'Enebeli',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '561848c2-b312-0006-0783-7fff45415975',
  'Adam',
  'Grace',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7cdb0545-2f44-0006-1096-5dc302f5286d',
  'Demetrius',
  'Howe',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '52c76170-7887-0006-8b05-19da43b3c2f4',
  'Massimo',
  'Johnson',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a26325bd-5481-0006-6b38-74140bd26764',
  'Benjamin',
  'Jones',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b5090f1e-9518-0006-9c87-34cfb1fd341e',
  'Aidan',
  'Krivanec',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '151e4a1c-3e30-0006-c975-e47bef2f2278',
  'Leighton',
  'Langenhoven',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '08030ed2-2cd9-0006-c708-be58ec3dcc2c',
  'Salah',
  'Mahmoud',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '6dc0cea6-2e8c-0006-e11d-230cf0743d4f',
  'Treyvon',
  'Medley-Green',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '36cd179d-bdfb-0006-b2e6-1456e0915c14',
  'Museba',
  'Mwape',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b4fa1466-18e0-0006-4f5a-73d74b61be16',
  'Jake',
  'Nelson',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '38441d7e-c4d3-0006-022e-5717d61a3c7d',
  'Abulfazl',
  'Panahi',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '68c28c9c-92d5-0006-f9f6-098659f55cbb',
  'Dame',
  'Pene',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '2e342b93-a22f-0006-8be0-75886cd2ca2b',
  'Henry',
  'Pittman',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'fcebd2a9-8da2-0006-2d89-353c07835885',
  'Yoskar',
  'Alejandro Quintanilla',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '8debf748-486f-0006-84c6-ad67e6441dbf',
  'Emerson',
  'Reyes',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '8920a87e-34d2-0006-a308-cede08b5bc85',
  'Mahdi',
  'Reza',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e26fc5a5-aae4-0006-1ed6-c958d572a650',
  'Mourtala',
  'Seck',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a092dbbc-19fe-0006-ff40-6dbb0d8cd7ab',
  'Alakhe',
  'Sibeko',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e2301c14-3b50-0006-62c0-fec1e02ea225',
  'Noe',
  'Soriano',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '87aafe06-e1bc-0006-8719-606a00d56566',
  'Sharief',
  'Stancil',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '8aaa0937-ebcc-0006-f7b5-9bf199cfeb71',
  'Max',
  'Taliaferro',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f734dd37-51b8-0006-01f9-8fb693083318',
  'Asanda',
  'Tom',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd2297d62-19c2-0006-954a-159d8224b632',
  'Caleb',
  'Underwood',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '34fa5e05-0285-0006-6072-68514344a498',
  'Callum',
  'Vellozzi',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'bb5ddd63-4504-0006-63a6-e06d34a35778',
  'Chrisendo',
  'Wentzel',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '92497df4-e9a9-0006-e063-27471ad9ef92',
  'John',
  'Williams',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Christos FC USERS
-- ========================================
INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'dd409a66-46d7-0006-70f8-0a14e258eaf7',
  'Felix',
  'Amankwah',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7a2c7c6a-2f56-0006-a6e4-2a8f83ded7b4',
  'Daniel',
  'Baxter',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b0e131c5-5e29-0006-7695-a6fd033a0f6c',
  'Drew',
  'Belcher',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '52e7ca86-5766-0006-f79a-a21a61517a7c',
  'Elijah',
  'Belcher',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5255f81f-10fa-0006-1930-cd1789821549',
  'Ethan',
  'Belcher',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '63bf5588-9ee9-0006-2f7e-77aabf55da30',
  'Jacob',
  'Bender',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '8fe190e3-c920-0006-68cd-218cf87f60fd',
  'Jalen',
  'Boston',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '84c7faec-4ba6-0006-5c3f-d2bdecdad548',
  'Brandon',
  'Burkholder',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '91ef5b6d-6015-0006-60e4-624cbb154c49',
  'Nero',
  'Cooper',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '22136d87-cbbb-0006-2f69-71538eff6273',
  'Anthony',
  'Dragisics',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '356a928a-8f0a-0006-c418-7e71522a839c',
  'Alejandro',
  'Estrada',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7d0d00de-c7c6-0006-0130-6004ba5e4c19',
  'Justin',
  'Gielen',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'dc532d6e-59de-0006-c495-e77acdb897e8',
  'Brian',
  'Graham',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '99a88530-8f78-0006-f5d3-333681f52037',
  'Brett',
  'Joyner',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e7c75c11-eef1-0006-2405-af8d26aa95e9',
  'Tanner',
  'Kennard',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '0ed2c9cd-97db-0006-e9e4-21702bfc1f3c',
  'Tyler',
  'Lee',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '96f11540-24ce-0006-f53e-9d589d007775',
  'Stiven',
  'Llano',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd672e7ef-09bd-0006-eb6b-a2a032fa1bc5',
  'Morgan',
  'Lussi',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7552f1c4-bd1f-0006-1940-c6ed38817eb5',
  'Raffaele',
  'Mazzone',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5314308f-b807-0006-a1f0-8790e46cd3c0',
  'Daniel',
  'McCleary',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c2b0d43d-1aed-0006-fe44-7c74442372c6',
  'Edixon',
  'Moreira',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '106523d4-7801-0006-884c-2b45f2ebe99c',
  'David',
  'Ogbonna',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '73f5c0b1-dea1-0006-b51a-3c7e146bf1e2',
  'Garrett',
  'Peters',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '82df00b4-306f-0006-4b3c-b72835c5a454',
  'Juston',
  'Rainey',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c15eff76-d18e-0006-0ed3-b1cc0ebdffb4',
  'Cesar',
  'Ramos',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '72af4ed6-8aa7-0006-9f51-cf2fc23d99a0',
  'Aaron',
  'Rilling',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '53a94b23-4dda-0006-5cee-f00a7e789ce3',
  'Jackson',
  'Ruckman',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '450c8fe9-f510-0006-7532-c98bd3223028',
  'Kyle',
  'Saunderson',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5d528abd-6bb7-0006-4e82-ccaf432fa1b8',
  'Luis',
  'Soria',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5fa60a7c-73a8-0006-d11e-a434cca23aa0',
  'Brett',
  'St Martin',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e053c640-4464-0006-bec5-cff27b9876d2',
  'Alexander',
  'Wardle',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- PFA EPSL USERS
-- ========================================
INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '41672236-053b-0006-463b-fafde1f83fae',
  'Kennison',
  'Akuro',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ed7beb1e-57c6-0006-a964-c023ca33f018',
  'Melvin',
  'Asanji',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '4cdb4fec-a108-0006-3024-21c1b0e93639',
  'Brandon',
  'Betts',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '1e9c5a6b-2745-0006-0d37-2dedaf509ac5',
  'Isaac',
  'Carvajal',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '964640a2-b0cf-0006-4e8d-81e9aae27abd',
  'Jenovic',
  'Elumbu',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd54ec81f-b9e7-0006-1d81-59496222bc4f',
  'Anderson',
  'Fernandez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a49747f8-58b4-0006-8041-226baa7079e7',
  'Angello',
  'Fernandez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e0c00c53-343a-0006-26d7-66a07377ce63',
  'Terry',
  'Fon',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '84632a56-d3a0-0006-e06c-cd25e193c0ad',
  'Eduardo',
  'Fuentes',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a78dba3d-3536-0006-8d37-50d5efe78a6c',
  'Christian',
  'Garavito',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b4bf0347-1334-0006-5e3e-39d900d3586a',
  'Thaddeus',
  'Goddard',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '685cc3fa-5ca9-0006-65da-2672fa97abb0',
  'Alexis',
  'Gonzalez Ayala',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e1f2ff52-2f1e-0006-5751-60640491d25a',
  'Chayton',
  'Kuidlan',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '60d1ae3b-be7e-0006-87eb-488dd99cd9ae',
  'Tobias',
  'Lane',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7f6fe638-59cb-0006-bebe-1f409a3cdb5e',
  'Jonathan',
  'Lemus Morales',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '6fe26ee6-c0a5-0006-1027-eeb53062dbf3',
  'Creasy',
  'Lopez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '2df93f06-45fc-0006-1abf-ce95b342a265',
  'Lutho',
  'Mlunguza',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '61d004c0-a7db-0006-70c5-ce75941d3c80',
  'Toju',
  'Okonedo',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '91c7c07c-ddd4-0006-bb1d-ab37cffcd990',
  'David',
  'Pawlowski',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd95fdaf2-6af8-0006-3428-4a34e9ac6d8e',
  'Danny',
  'Paz',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a2c3b15d-df06-0006-c45f-c7e1d63c8dd0',
  'Brayan',
  'Perez Mendez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b1fe8bfd-cc5e-0006-7327-3b331cfbf6ca',
  'Nicholas',
  'Tziamouranis',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '06e0323c-007c-0006-25c3-983115664737',
  'William',
  'Villatoro Velasquez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f7594491-6bda-0006-bcd1-ce32af311366',
  'Brian',
  'Ware',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- PW Nova USERS
-- ========================================
INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '55d1669d-900d-0006-5b25-e71fbd385c73',
  'David',
  'Alverez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'bde03f16-fc9e-0006-7f1f-07a163e91845',
  'Carlos',
  'Amador',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ba79f6c0-bcb7-0006-713d-a8c8dddac61b',
  'Chris',
  'Avila',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '138b9956-acd0-0006-4107-074bd3b6dbef',
  'Yaseen',
  'Ben Chouikha',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '79cc1fc6-bc7e-0006-c036-109fa270d075',
  'Amir',
  'Bentaleb',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '560f1dc3-425c-0006-415e-ffe391d03afa',
  'Angel',
  'Viera Castro',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'aa0e7838-9814-0006-aaaf-177c9b90771f',
  'Jesse',
  'Conteh',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e3cb0bf1-21f0-0006-00b6-55fe561e7371',
  'Gio',
  'Cruz',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ec9059d1-f21f-0006-1a51-67dbe179846f',
  'German',
  'Del Cid',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c4f5143c-3027-0006-389a-c34b7ed10779',
  'Mohammed',
  'Ahmed Elsir',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '1b7630a0-58b9-0006-0c92-653497774368',
  'Collins',
  'Frimpong',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e84e4e0e-71bd-0006-6001-3df5c8c793c8',
  'Roy',
  'Alex Galeano',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '8310d12a-836d-0006-fd98-a07a5a1e1540',
  'Oscar',
  'Garcia',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '8a9537a0-0219-0006-01a7-1778cb8c9b31',
  'Sam',
  'Garcia',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '96f78927-1d19-0006-b38f-dc3f61f4251d',
  'Anthony',
  'Juarez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '9046189c-6711-0006-f0c5-d30a2fb3076e',
  'Kwasi',
  'Kotoko',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '45729472-c51e-0006-fe6f-0e753e8b8afb',
  'Orlando',
  'Martinez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '4e81c397-aef4-0006-5edf-a413084725ad',
  'Andrew',
  'Mejia',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a0369371-a33c-0006-38ae-b188c26a944d',
  'Chris',
  'Mejia',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a003a024-0d8d-0006-b362-bd3ccb101be6',
  'Milton',
  'Miranda',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7f600291-3408-0006-c9fb-3becdd65d33e',
  'Nasrullah',
  'Muhammed',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'aabf10b4-aed3-0006-a6be-0b0a9387a781',
  'Alexis',
  'Palma',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c0dccfef-274c-0006-3e8e-041705d89e6b',
  'Luis',
  'Reyes',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '6b0da0e1-9b13-0006-fb5b-718214ecc9b5',
  'Romel',
  'Reyes',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '85dc854f-1a69-0006-4d8d-3c0edec106ad',
  'Jason',
  'Rodriguez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '59badf67-b54a-0006-8b52-717225792ff0',
  'Elias',
  'San Juan',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '1e23a983-d928-0006-0401-c2dcdd4c5031',
  'Ricardo',
  'Vega',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '3d8e5af9-d934-0006-2664-5e4954728710',
  'Raul',
  'Villalta',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Delmarva Thunder USERS
-- ========================================
INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '92c7fd2d-0956-0006-c58e-974aad93603e',
  'Joseph',
  'Daly Aigner',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '693872a4-1638-0006-cfb1-21f6ca72498d',
  'Liam',
  'Charles Aigner',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd021a016-576f-0006-f8cf-781488e10e72',
  'Jacob',
  'L Amon',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '43078a08-625a-0006-a088-f4dc212fd2cf',
  'Samuel',
  'Amon',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5a2933c3-68d5-0006-1061-7d748e76f09d',
  'Walner',
  'Anescar',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '9119582c-7aa5-0006-0103-e2ad241d37f0',
  'Samuel',
  'Burbage',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '56261293-85c9-0006-b9ad-ffa41a506817',
  'Joshua',
  'Alexander Carey',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '1982193e-8595-0006-8694-0fbe5675a948',
  'Corvens',
  'Jay Corvil',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '019a6065-9008-0006-00de-c3bfe9df1b9c',
  'Zechariah',
  'Dapaah',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '2be2940a-4e87-0006-aae7-23295bfd3521',
  'Adam',
  'Stephen DeLizza',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'de88499a-816d-0006-d519-84669bc9dc2a',
  'Heberson',
  'Edouard',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '3b224c58-8fcc-0006-c4d8-dea542d1e6d4',
  'Christ-Daniel',
  'Fils',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '9a2f0952-a124-0006-f9e1-a7d6a8a85e13',
  'Caleb',
  'James Gragg',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '05087429-19ac-0006-a922-d439e442fd19',
  'Colin',
  'Benjamin Hofmann',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '50b5320a-d42a-0006-a077-97402d75fd15',
  'Elijah',
  'Jabagat',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '0dff08a2-e20a-0006-1eb5-df6e1773a43e',
  'Rickelmy',
  'Jeune',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7e3c58c3-b6db-0006-2628-a4b5650cd31c',
  'Damarius',
  'Kelley',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5efff8a3-972b-0006-4b6a-21d187681606',
  'Goran',
  'Mijalkovski',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '49fe28bc-a75a-0006-7d22-e92916225840',
  'Sean',
  'Chidozie Morse',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '07873d72-4c7a-0006-3f5d-382a721bde4d',
  'Abdelazim',
  'Osman',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '02df80f8-3d73-0006-8a04-8ff897bdf24d',
  'Ahmed',
  'Osman',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5c8f377b-97e1-0006-c210-37bacb1f5c3b',
  'Pat',
  'Parrish',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c517a51e-338b-0006-31ca-7a2f4cd09107',
  'Caden',
  'Mark Pollard',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '4db891a8-781d-0006-5658-8fd6c9066eb6',
  'Ivan',
  'Sanchez-Gonzalez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'acddbcaa-5078-0006-0f1a-ee04c78c227b',
  'Gianluca',
  'Secondi',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '1d20df32-8a34-0006-768d-940cc715c343',
  'Mourad',
  'Shalaby',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd4b1edd1-35bd-0006-acab-605fb73933ef',
  'Kenny',
  'Spock',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '3f58adda-b22f-0006-f20c-59992f115d09',
  'Guy',
  'Holmeade Talbott V',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '0698dad4-90f8-0006-0b38-11232c0e77f4',
  'Devon',
  'Warman',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd1b3c475-bf75-0006-6d20-a8d4ce9ce349',
  'Skyler',
  'Williams',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Terminus FC USERS
-- ========================================
INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5053aa8b-ef5d-0006-dec7-1ca9be3bc782',
  'Nour',
  'Alamri',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '15aabcde-ef4a-0006-e979-f856816be467',
  'Henry',
  'Asbill',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5ad009e2-8a43-0006-f91b-d3c88f1da44c',
  'Asad',
  'Bashir',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ef507504-2c44-0006-572d-08e6d528bfa9',
  'Kai',
  'Bennett',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '1d41ac2a-b3fd-0006-5b09-ed26efa22472',
  'Alex',
  'Caskey',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a7ffe2c4-9759-0006-b23d-f3f2e42482e5',
  'Damian',
  'Charles',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '2b034d6d-f28a-0006-70a8-817a6b996d6d',
  'Jamie',
  'Gleeson',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '009b1c25-3f31-0006-757e-db7713467e82',
  'Noah',
  'Goodman',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'cc9ba7ea-c562-0006-c70d-a3b54afecbc6',
  'Anthony',
  'Gourdine',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '6933ec21-d0f0-0006-4098-500ac2691f2a',
  'Morgan',
  'Hall',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a44bcf66-b651-0006-acd5-d239e10218fc',
  'Josh',
  'Hughes',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '6d8cb093-9da7-0006-9adb-3f239abce839',
  'Gad',
  'Kabwende',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '608a0969-1c4b-0006-aec5-fb33f7060455',
  'Jason',
  'Kayne',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ac544f2d-c290-0006-23d2-c44fe4d79813',
  'JT',
  'Keiffer',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a77f656f-1780-0006-6237-8e4afac163fd',
  'Sebastian',
  'Lopez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '004f2caf-0688-0006-8e9c-070e72ee2a0f',
  'Jean',
  'Malilo',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '19347387-8fd3-0006-38cd-2f250bea5369',
  'Zion',
  'Jediah-Jason McClean',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5cb0b072-a930-0006-4b42-11438606322d',
  'Gregg',
  'McPheely',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '9e7238e6-8004-0006-6317-b985df73f054',
  'Nathan',
  'Miles',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '8625253b-3933-0006-0217-6d47db9dc69b',
  'Alex',
  'Rotoloni',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd3e30f53-3bc0-0006-4439-50bdb5c7db0b',
  'Jack',
  'Snyder',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '2ff6669c-b6d8-0006-4f23-5f0140a1aa4a',
  'Brynn',
  'Thompson',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '0ac3d864-f5d3-0006-2ee2-d188a1c7d859',
  'Tyler',
  'Vogt',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '054400ab-80b8-0006-e4a2-984a3add5e1c',
  'Renaldo',
  'Walters',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'fbd28e47-6125-0006-a22a-dd7b08276f5d',
  'Matt',
  'Williams',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '1b776436-699a-0006-beb5-ee8d690e183f',
  'Nick',
  'York',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Majestic SC USERS
-- ========================================
INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '18bd3372-e461-0006-fa41-5bb46a9b1dc1',
  'Rashid',
  'Alarape',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '83745656-5720-0006-1ec7-c86b8aa76b42',
  'Alex',
  'Archambeau',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7254d086-ebd7-0006-c394-48c68776da0a',
  'Christopher',
  'Avery',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '15927f34-49ae-0006-85a7-fcbf81bafe33',
  'Carlos',
  'Ayala-Viera',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5f202405-211a-0006-4754-d97519d0888b',
  'Carlos',
  'Becerra-Gomez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'cb3dba76-73c8-0006-1d0d-d6be03c25f72',
  'Elliot',
  'Curtin',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '85148961-4ccf-0006-62cc-030f0cf42e88',
  'Eli',
  'Dent',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '6c45c931-85d9-0006-e514-397d19787fd1',
  'Jackson',
  'Eskay',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '3efb5865-788e-0006-1baf-7f9dd37bf51e',
  'Andrew',
  'Fitton',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '59e41f4c-e413-0006-1edb-5e6ba072fb83',
  'Mike',
  'Foutsop',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '3b2f0a78-ba07-0006-f038-69f2576600ad',
  'Neema',
  'Gharib',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd5de72db-584f-0006-621e-d2b75fe48c8a',
  'Andrew',
  'Halloran',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a22980eb-3044-0006-ca16-5c3c911c48d1',
  'Thierno',
  'Issabre',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '93a8d0cd-ec1d-0006-eefc-d4fbdb90e896',
  'Michael',
  'Johnson',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ad965ae0-6702-0006-3180-99a7e70e2a0a',
  'Brennan',
  'Koslow',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '4999ad84-dd4b-0006-f470-024b80b2db5f',
  'Mitchell',
  'Kupstas',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '8ab06db9-7ffc-0006-e347-a1dba37b0698',
  'Adrian',
  'Lollar',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '1cac3e46-a5a9-0006-90c5-4ef7f35b9733',
  'McKinley',
  'Mercer III',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f9386d75-8e8a-0006-6b26-25e0ebdd5758',
  'Luke',
  'Narker',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5b5042e1-28be-0006-650b-f7ef67ada2b8',
  'Hassan',
  'Pinto',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e698698f-86cb-0006-dfdd-b8b296971737',
  'Cory',
  'Plasker',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd5fe16b6-d486-0006-003d-4cb836f13de0',
  'Max',
  'Poore',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '9a4a00f9-924d-0006-4573-3693c5d6041b',
  'Kevin',
  'Reyes',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '2d6265b1-253e-0006-cc14-ed318220a368',
  'Sharpe',
  'Sablon',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '970313b2-94c8-0006-8fec-5f18f915290a',
  'Iain',
  'Smith',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '1c0174b6-5432-0006-541b-cd449efcc7d1',
  'Thor',
  'Svienbjorsson',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c1036a25-e2de-0006-8a70-68ab51170558',
  'Thomas',
  'Toney',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '0487e9d0-0181-0006-18d8-02f40df4aa20',
  'Zachary',
  'Paul Young',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Peachtree FC USERS
-- ========================================
INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '52f86506-b899-0006-e304-e601997b9c2e',
  'Bilal',
  'Ahmed',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ea26b1b1-cb54-0006-821b-a6d301f142fa',
  'Tim',
  'Amoui',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '498f385c-3957-0006-a1e5-9a699de6be68',
  'Badr',
  'El Yazami',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '2b945af7-cdc8-0006-78dd-e619fa32962d',
  'Stan-Lee',
  'Etienne',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ef86c172-542a-0006-04fa-2c534d58d487',
  'Sylvi',
  'Mahmood',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '93a498fb-a70a-0006-a1e1-3991ba21c677',
  'Pedro',
  'Marinho',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '14145f3a-4794-0006-2b1f-0e9155b0041a',
  'Juan',
  'Martinez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '39e859f3-11d8-0006-9c15-0711da626eed',
  'David',
  'Michaelson',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '8063071f-b57e-0006-5ce3-ffab43fa5242',
  'Metsantika',
  'Mokgoatsana',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '257e6ff6-b2c0-0006-7297-f76cfc123f39',
  'Ali',
  'Niang',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '92d69d87-c612-0006-6d8f-9379b771a731',
  'Javier',
  'Pace',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ff05a9d3-7c8d-0006-26d2-a45f24cb78ee',
  'Osman',
  'Rodriguez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '6c76d517-d4a9-0006-f761-17c854e78335',
  'Aaron',
  'Shiffman',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f69c1672-6dea-0006-be5c-c84dd2296418',
  'Miwoned',
  'Siraj',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '801b1e30-0a36-0006-a3ce-7f8d45d5043d',
  'Tyler',
  'Swinehart',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a1743c4a-f809-0006-aeb5-cc5802df6539',
  'Gabriel',
  'Villar',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '2f17c28d-7780-0006-f293-e630663fba56',
  'Michael',
  'Walsh',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ff317d6c-7e60-0006-e5f7-404306adce9c',
  'Joshua',
  'Warde',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '0e363b75-23a6-0006-be3e-7aaebd6032ad',
  'Christopher',
  'Wilson',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '1a392f98-9da7-0006-1a53-6dbc563e6a10',
  'Kyle',
  'Xhajanka',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Prima FC USERS
-- ========================================
INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f15d6958-7484-0006-c037-657c85b1ae38',
  'Zackeriah',
  'Aday-Nicholson',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e60ac574-f2cd-0006-4b5d-d76ee6adc628',
  'Gabriel',
  'Alvarez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '0d0bc3b1-617c-0006-0ca4-ac355679760e',
  'Dylan',
  'Bapst',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '61796fe0-4ef5-0006-40ae-e9d3f36a597f',
  'Mitchell',
  'Barry',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a82f72e6-c197-0006-abd2-2de08516908f',
  'Charles',
  'Blakenship',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '1ca12f32-d400-0006-7206-5f58c95d959d',
  'Kevin',
  'Carvalho',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '3e8d7a95-b863-0006-b8db-9ea871cfe3d7',
  'Stefan',
  'Gojic',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '3ff14c9b-20cc-0006-7a9b-5f7593a0c84e',
  'Andrew',
  'Grodhaus',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5fe9912f-c785-0006-c7d1-538ccbf4ae91',
  'Colton',
  'Huebner',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '9f15468d-3c73-0006-204f-d2263be1c97d',
  'Joshua',
  'James',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '4c11f19d-a362-0006-0d43-df83659861dc',
  'William',
  'Keegan',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '2ab8ee61-bd29-0006-23d7-7f56fd290ffb',
  'Konrad',
  'Knap',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5169e942-a093-0006-c028-bd204017359f',
  'Jordan',
  'Locke',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '0de960d5-64e9-0006-aa98-badd0aa017b4',
  'Christopher',
  'Marshall',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'bcb4f1a9-6840-0006-74bf-a31fe146b7d8',
  'Javier',
  'Martinez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '3c66a94d-42e1-0006-a6f6-cce213a54dfb',
  'Cain',
  'McMillan',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7644c73d-5a0b-0006-94c6-c6177a87a0d9',
  'Anthony',
  'Norman',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e594e343-368c-0006-5996-dce06cd0dcfa',
  'Sampson',
  'Nsemoh',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ca6343cb-5d14-0006-4562-d5b64127dab7',
  'Thomas',
  'Powers',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '99c86369-da29-0006-9704-3d5552dcead7',
  'Seth',
  'Prieto',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5a791d6c-7ff7-0006-4031-de562ad81dce',
  'Adam',
  'Rooney',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '87673ffe-2b0b-0006-b73b-4abde057abe4',
  'Jacob',
  'Sayer',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '22faa896-9be8-0006-9d24-3bda3579c08b',
  'Zachary',
  'Smith',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '43212e19-925a-0006-52b0-aca62ed0d5ff',
  'Christian',
  'Waeglin',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f7d36655-c443-0006-8ac5-78a0bbd5903d',
  'Christopher',
  'Witmond',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Bel Calcio FC USERS
-- ========================================
INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '09d33dd8-9416-0006-67ec-8326bbeb0fb2',
  'Nathan',
  'Bio',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '26333b66-701b-0006-f490-b40467188a5d',
  'Rob',
  'Bonet',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ebd6e635-936f-0006-17ed-5d87219f8bb6',
  'Aziymu',
  'Shamil Burns',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '2f05bd4a-cf23-0006-4e12-0bd459133d35',
  'Jackson',
  'Cavenaugh',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '91be8151-889f-0006-1a47-e4ca10e09600',
  'Kyle',
  'Crawford',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd3793838-381f-0006-534c-49b50580b7b9',
  'Eduardo',
  'Delgado',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'dd723fbb-b34f-0006-abbe-7d105ebcc0e5',
  'Matheus',
  'Fineto',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a8cbc1a7-608f-0006-dbf6-2c64b8372997',
  'Enrique',
  'Gonzalez Plaza',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7b2321d4-35cd-0006-5ac8-3b60f32d59cf',
  'Chris',
  'Griffith',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ed937721-2e32-0006-150d-778b8d7419b7',
  'Philip',
  'Harris',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '2beabf16-26d4-0006-198e-73e5939c02b7',
  'Justin',
  'Heimerl',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '2225523c-19d1-0006-7331-3379c90a6a05',
  'Lucas',
  'Horton',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '9f8bf572-09e7-0006-0cfc-2ced73776715',
  'Karson',
  'Reese Kendall',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '93916a6c-3912-0006-9c0d-1095cf2523fc',
  'Konner',
  'Kendall',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'cd983245-a660-0006-2f72-541e59202e9b',
  'Mouad',
  'Labied',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd4fefc80-25ea-0006-41d0-edf53c08b333',
  'Jake',
  'Langton',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '8c997c27-8525-0006-9be6-694cf8adaaaf',
  'Myles',
  'Levelle',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c863a6a6-8ba3-0006-b896-f6c26b9ee9dc',
  'Randy',
  'Mallar-Calvillo',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c299b0e4-a978-0006-9c4b-dc0430d07e29',
  'Matt',
  'Mitchell',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'de60f99d-d8ae-0006-149d-1fba66a5bf3e',
  'Nikos',
  'Papanikolopoulos',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'da7e0b9d-2448-0006-7ee7-7d7b9b2aac2a',
  'Cade',
  'Quinto',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'cb7de99c-a2da-0006-b86c-9acb3f1fbe1d',
  'Juandi',
  'Riley',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '76e8d381-bbf1-0006-86be-df0ec9e64eb7',
  'Luis',
  'Romero',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ba4c1420-36e5-0006-9817-60976e01e18a',
  'Eduardo',
  'Ernesto Salmeron',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '888f33dd-c99b-0006-c158-4e6413a860a1',
  'Aswin',
  'Sembu',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'fec78a36-aec8-0006-a6df-1cbc76d446b7',
  'Adam',
  'Sole',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '05d44070-70a3-0006-3128-a8f89ac11946',
  'Zaid',
  'Takrouri',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '65b83388-5051-0006-5e4c-7b3117013677',
  'Michael',
  'Touihri',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '6a27f8b7-700f-0006-08f3-dcd43f81b028',
  'Ivan',
  'Verdezoto',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '98a982b4-e3dd-0006-a7eb-c107c716b5ad',
  'Min',
  'Yoo',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Buckhead SC USERS
-- ========================================
INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '67c717f9-0e22-0006-a160-6f0b0af633ec',
  'Jonathan',
  'Adabi',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7edd3143-8eae-0006-f999-9848f54d30b6',
  'Tishe',
  'Adekanmbi',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '154447ed-44c1-0006-bc8c-8a2c58749b78',
  'Abdoulmalik',
  'Adesanya',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'fe4d0dea-8ee6-0006-8c10-b1891334cda1',
  'Caleb',
  'Ayan',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '8c6f22ca-0469-0006-7a53-5dfa7b1dc1d1',
  'Olumide',
  'Ayo-Ajibike',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '943b61f3-6d76-0006-37ea-410450964c10',
  'Elad',
  'Khaleef Bogle',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '35e548cf-d0c9-0006-c19c-ddcb23dde64c',
  'Tobias',
  'Ciho',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'aa6d515d-7bfd-0006-15ad-f251c2b7c979',
  'Nixon',
  'Manuel Condolo',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '79e7c669-0541-0006-0d28-9821dd9dc9fe',
  'Felipe',
  'Correa',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b5ea4dc4-80f0-0006-4645-a1178a1fb88b',
  'Michael',
  'Dardis',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b2c3bcac-93df-0006-0ef5-3f9597f635ec',
  'Abdoulaye',
  'Diba',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '8a8f94f7-62da-0006-4bdb-6055ca84b233',
  'Lech',
  'Dunser',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '67a4045c-e53f-0006-b26a-7fb0b9af295d',
  'Daniel',
  'Duran Gonzalez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7629c0b7-fcf3-0006-3b4a-b74a2ef45a10',
  'David',
  'Alejandro Fierro',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e7655121-b366-0006-75b8-2de65542c573',
  'Caleb',
  'Johnson',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5ca21ef1-623e-0006-ff8b-c1141e0bce59',
  'Ian',
  'Thomas Kunkel',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5255297c-d992-0006-4de2-8306b24109e7',
  'Jelle',
  'Lansdaal',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '3b0d79af-38c8-0006-970a-2877cfc59131',
  'Ruari',
  'Eamonn O’Rourke',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'fc49af75-7fb6-0006-e311-bf38ab82a796',
  'Siddharth',
  'Rajesh',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7d32ad87-9bcc-0006-6d63-031bcceb1b7e',
  'Anel',
  'Ramic',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '40cf4020-29c7-0006-6bce-361774fc2ced',
  'Sumner',
  'Richardson',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5b22976d-62cc-0006-d50f-8277a6bb2af1',
  'George',
  'Bishop Rodi',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '0b049e08-e6e9-0006-44e8-efd2fe719ac5',
  'Connor',
  'Rosenthal',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7fd110a7-4f2b-0006-85c1-a10ce80701f0',
  'Godfred',
  'Nii Tettey',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '9102d5a1-ac5f-0006-a057-6393aef813e1',
  'Joshua',
  'Parbie Tettey',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd69142ce-1550-0006-5cf7-b8a659857391',
  'Robert',
  'A Thomas',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '779cbd46-c4d9-0006-ff5c-9f228c0b4da5',
  'Chris',
  'Arturo Vitela',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b4f8606a-abf1-0006-8e3c-d48051f0b659',
  'Noah',
  'Wieland',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd5aa9ec2-8926-0006-5b24-ce213b96f3aa',
  'Olanrewaju',
  'Yusuff',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Alliance SC USERS
-- ========================================
INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'eff0ad86-a9c6-0006-e5f7-ca4d37ad5cb5',
  'Roberto',
  'Carlos Calix',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'caec3d52-c03a-0006-ec65-5b08d4d3dc0a',
  'Eli',
  'Francisco Carrasco',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '36f71167-5317-0006-d0aa-acbe201f774f',
  'Axel',
  'Castrejon',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd835978e-f207-0006-65ee-6333880b7597',
  'Gael',
  'Jared Castrejon',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'cf6a8c79-cf8d-0006-170f-bacbe88aba4c',
  'Jared',
  'Scott Childs',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '51861750-b8fa-0006-56be-e7346cd0d220',
  'Dylan',
  'Bright Edmonds',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '02f9d145-bb1a-0006-eb8b-f4d1277cae78',
  'Mason',
  'McGill Fifer',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5cf2478b-4c5d-0006-237a-a8271f4e02c1',
  'Omar',
  'Guadarrama',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7751451a-65bc-0006-1ae7-6733ae9bf858',
  'Brandon',
  'Gutierrez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e13cfeb9-343a-0006-36bb-a0f0088ff3e2',
  'Maury',
  'Ibarra',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'cc9f00af-45b7-0006-6cbc-bea9832c7fc1',
  'Sebastian',
  'Tyler Jones',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'fadea840-662e-0006-9701-5fd9f1dfb3b0',
  'Dino',
  'Kalac',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '96edb7ca-eada-0006-eaeb-c388fd6bdd7d',
  'Taylor',
  'Benjamin Lemmon',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '3a82f7f6-9f2d-0006-93e8-aa6ab33d8f7c',
  'Ivan',
  'Israel Lopez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '270cc341-a114-0006-ec56-3a9fccb6a6bc',
  'Sebastian',
  'Lopez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'df9caa89-de4c-0006-3f71-64b0a257e243',
  'Juanes',
  'Martinez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '121da025-6ba1-0006-3ac3-ab2bf02690e0',
  'Sebastian',
  'Nuñez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'fc3700a0-3105-0006-8a86-1eb6e452103f',
  'Ashton',
  'Thomas Parnell',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '74c48423-50fe-0006-9b5e-a91db71a02f6',
  'Tyler',
  'Pineda',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '39de285a-25e2-0006-ea15-cd1589ff6fa5',
  'Voshon',
  'Ramcharan',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '9d8c4573-6c25-0006-c96a-87176662bddd',
  'Marvin',
  'Rodriguez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '1b7fda65-9e7e-0006-37fe-fb946d2d152c',
  'Fabian',
  'Rodriguez-Escobedo',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'babbeebc-37b5-0006-f336-d6856f8dfb5b',
  'Blair',
  'Springhall',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '79446aef-a5c9-0006-e301-c46029ca3cca',
  'Bradley',
  'Hamilton Tidwell',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b0cdf812-577c-0006-107a-5dc16237f88f',
  'Edward',
  'Trejo',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c309c35d-f4a0-0006-d13b-4f5ebaa12765',
  'Johan',
  'Miguel Trigo-Rios',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'cfebbeb5-b3e5-0006-cf3b-41499bb8bae7',
  'Luis',
  'Albert Ventura',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '668558ba-53a6-0006-ea66-abd8ce89a6fd',
  'Patrick',
  'Ventura',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '445838aa-5a02-0006-ef8f-f6d5b3f499d8',
  'Nicholas',
  'Wheeler',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- SC Gwinnett USERS
-- ========================================
INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '5663ac0e-d6f3-0006-5a6b-7e4768d01481',
  'Adam',
  'Abdullahi',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '94885f0d-b8a2-0006-bb09-90aeda2b88f6',
  'Mohammed',
  'Al-Asady',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'bb67c0f6-6f3b-0006-c4c2-980cc8207f19',
  'Malek',
  'Almariri',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '2f66afc0-9bd4-0006-7e7e-5238f40eebb0',
  'Mario',
  'Arreguin',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '6b3af454-9681-0006-6961-1c23eccaf4a4',
  'Ali',
  'Bazz',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ea689bee-87e8-0006-4e2d-26cd2b50973f',
  'Monchu',
  'Camara',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'eed85bda-375a-0006-24d3-11a2c8be7ef6',
  'Steven',
  'Carrillo',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '4470d8a6-f46b-0006-b2ad-6eb29365be8b',
  'Karl',
  'Christiansen',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'ca696aae-8c13-0006-5072-1ddfb011d2ac',
  'Franklin',
  'Contreras',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c4dc2286-4ae0-0006-0a46-28a0f2736353',
  'Vitor',
  'De Souza',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd3f94877-31c5-0006-0c0a-40d566403b17',
  'Adrian',
  'Garcia',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '1fa147ea-b8e7-0006-b883-cc3b1c41483d',
  'Josue',
  'Gomez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '2cf5fff2-7e09-0006-d248-a063ebd814a8',
  'Jafet',
  'Higuera',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '8d7d943d-cf15-0006-d21f-0a0b28cc9f98',
  'Rui',
  'James-Pereira',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '96ed43c4-4720-0006-5f8c-a3e24a9f67b0',
  'Kendrick',
  'Jean',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '47a34124-dedf-0006-4230-a2a3eff9cde2',
  'Sanaa',
  'Listenbee',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '93e5c8c8-d4dd-0006-97aa-7a8760a98cba',
  'Chris',
  'Louissaint',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '04008f6e-0f84-0006-f7ab-b3e397a27570',
  'David',
  'Martinez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f982d691-2b9d-0006-2134-eed4cd86be4e',
  'Ramsis',
  'Martinez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'fe6ecd1b-23e1-0006-5a4f-21d23c208945',
  'Ruben',
  'Martinez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '73b685ec-39e7-0006-881e-7f5476bdd43c',
  'Jonathan',
  'May',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'cd34aae8-c306-0006-10aa-cc66434b135a',
  'Jaylen',
  'McCray',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7adb4c64-82c4-0006-2798-f01ed6ec79f6',
  'Tariq',
  'Mohammed',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c83d9d36-0b03-0006-52d3-742c46bf54af',
  'Geovanni',
  'Oboh',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '79b9e4cc-05ae-0006-59a2-7d43db57580c',
  'Jordan',
  'Paul',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'da170cc8-0375-0006-2972-9b67eb8176a3',
  'Nicolas',
  'Pegorer',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b0ba7e22-61ef-0006-32b7-a9256a34347c',
  'Pablo',
  'Piraquive',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '8b0f37c3-c302-0006-2b4b-0245b5403fd5',
  'Roney',
  'Rubio',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '7dc91d0e-f073-0006-31bd-d9616e9771d7',
  'Anakin',
  'Ruiz',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '819b01bb-63ca-0006-74f7-1a50fe600419',
  'Jazeime',
  'Russell',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '1ce8e347-3f93-0006-bb0f-72263aaf51ba',
  'Jonathan',
  'Sandoval',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '02367907-63f3-0006-073c-06dafa1e1789',
  'Ayman',
  'Saudin',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'cb5bb2a3-ba01-0006-ca9a-05009b4c8825',
  'Manuel',
  'Simental',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '73a05d99-04fd-0006-32a6-c41b3add7e85',
  'Mahmoud',
  'Tasslak',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '2190ac37-15a8-0006-456d-119506e76681',
  'Myles',
  'Williams',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Lithonia City FC USERS
-- ========================================
INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'c739b13a-6576-0006-5bb2-2f93ba74cbb6',
  'Ochuko',
  'Asibelua',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b6d97c5d-90b2-0006-37b6-5a2303eb163a',
  'Sang',
  'Bawi',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b87af906-b8b3-0006-29f7-0ddfa1ac3862',
  'Kanye',
  'Alexander Blake',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'b1aae734-0d27-0006-66fc-a13ddc50bfca',
  'Jackson',
  'Cherfils',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'fee02eb6-dd59-0006-5d57-7b75d5b12b9e',
  'Okikiade',
  'Leo Faduyile',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e9961d8f-b74d-0006-5056-6efe24b3bbbe',
  'Alivic',
  'Fossem',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '08913780-7bf7-0006-d3df-41e01b27d88d',
  'Didier',
  'Lehman Fresh',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '67201bda-2955-0006-b71f-927618f5ae53',
  'Daniel',
  'Gonzalez',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'f7514e41-5757-0006-80fc-b9c5f31fa934',
  'James',
  'Wedson Jean',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'de1fe14e-bb12-0006-827b-b1012f5d69de',
  'Maxinio',
  'Joseph',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '1d4e2c2d-30b6-0006-3bc6-2e7c2ff30140',
  'Berlin',
  'Marcelin',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'd8c47625-808c-0006-61ee-ae7cb3e3a52c',
  'Hachem',
  'Alaoui Mhamdi',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e27e77a2-a2d8-0006-a353-bc685f147361',
  'Olivier',
  'A. Momplaisir',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a2e665d8-ffb4-0006-f969-a936d7d7ca41',
  'Aaron',
  'Morales',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '3f422c12-7367-0006-e9c7-5e73cb0fd6fd',
  'Taft',
  'Parsons',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'a96fb340-d6a4-0006-5451-e428593dcc62',
  'Edmar',
  'Pere-de Leon',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  'e7f2f206-b43d-0006-5b70-cd9a8a9f4292',
  'Paul',
  'Phillips',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '0fbec5c8-2659-0006-c844-9742e6b518ca',
  'Moise',
  'Pierre',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '258ebc29-8db9-0006-affd-8026eaa7d7d6',
  'Neo',
  'Ramos Lorza',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '6cfa8eb7-033a-0006-5b54-6e5d0bed1f7e',
  'Edwin',
  'Rios Zapata',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '401961e9-22fc-0006-e710-dc480de22552',
  'Jose',
  'Ruben',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '0244d2b0-f028-0006-4cd6-b4055957613b',
  'Emmanuel',
  'Michael Rwakabuba',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '9e344863-6949-0006-201e-cd6a0c3876eb',
  'Rickenson',
  'Saint Quitte',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, first_name, last_name, is_active)
VALUES (
  '23051d8c-96d9-0006-db80-f0fba977bafa',
  'Calvin',
  'Ventura',
  true
)
ON CONFLICT (id) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


