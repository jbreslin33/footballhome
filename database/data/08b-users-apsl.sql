-- ========================================
-- PLAYER USERS
-- ========================================
-- Generated: 2025-11-25T17:54:57.591Z
-- Source: https://apslsoccer.com/standings/
-- AUTO-GENERATED - DO NOT EDIT MANUALLY
-- Run scraper to regenerate: node database/scripts/apsl-scraper/scrape-apsl.js
-- ========================================


-- Note: Passwords are bcrypt-hashed. Default pattern: Player[random]!
-- Players should reset passwords on first login.

-- ========================================
-- Falcons FC USERS
-- ========================================
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'bc489e31-18bc-0006-a453-a1da54ab1446',
  'sahil.banerjee.093a47d2@apsl.player',
  'Sahil',
  'Banerjee',
  crypt('Playerw1wjjtac!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5c49e2e2-ad5a-0006-4ee3-c305215128b6',
  'massimiliano.bruno.093a47d2@apsl.player',
  'Massimiliano',
  'Bruno',
  crypt('Playero7tbumml!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '44233d63-78ce-0006-fba1-efb396772745',
  'kevin.alves.cruz.093a47d2@apsl.player',
  'Kevin',
  'Alves Cruz',
  crypt('Playeracasem51!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'cef50d30-87ca-0006-e62e-586822754925',
  'ryan.cura.093a47d2@apsl.player',
  'Ryan',
  'Cura',
  crypt('Player5i16f72o!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '12a2383c-60bb-0006-1dda-c7de7f7d611b',
  'emilano.de.la.macorra.cardoso.093a47d2@apsl.player',
  'Emilano',
  'De La Macorra Cardoso',
  crypt('Playertr30zcae!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '96edffa8-9590-0006-537d-d1cf9698b6af',
  'jeffery.dietrich.093a47d2@apsl.player',
  'Jeffery',
  'Dietrich',
  crypt('Playerkt55xaxf!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5f7550f1-4427-0006-e9b4-17fcb0616453',
  'claudio.dragonetti.093a47d2@apsl.player',
  'Claudio',
  'Dragonetti',
  crypt('Player5q5w8jk8!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '0525d425-621f-0006-62de-510cae6fd084',
  'miguel.enriquez.093a47d2@apsl.player',
  'Miguel',
  'Enriquez',
  crypt('Player4xk49fam!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '6fe50e6b-0e35-0006-bb79-8e7972576724',
  'charles.esber.tavares.093a47d2@apsl.player',
  'Charles',
  'Esber Tavares',
  crypt('Player4akq5ww2!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7105e742-14b9-0006-8794-9e89e12909af',
  'kaven.fitch.093a47d2@apsl.player',
  'Kaven',
  'Fitch',
  crypt('Playerp2gpvbtj!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '65e6160f-d2cf-0006-eb04-f6fb96833838',
  'vincenzo.fuentes.093a47d2@apsl.player',
  'Vincenzo',
  'Fuentes',
  crypt('Playerbx6a4ow4!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c34fb70d-e482-0006-7754-fede765c55c5',
  'payson.goyette.093a47d2@apsl.player',
  'Payson',
  'Goyette',
  crypt('Player69sken36!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '2150f8f1-31b3-0006-bb23-de553501906f',
  'pano.haseotes.093a47d2@apsl.player',
  'Pano',
  'Haseotes',
  crypt('Playerf2qw5wg7!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '555ce01d-d87c-0006-7f51-f5c20b9eadd9',
  'aidan.hayes.093a47d2@apsl.player',
  'Aidan',
  'Hayes',
  crypt('Playervbvkdas2!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '27cff52f-9ae4-0006-bbbf-a7e052013510',
  'samuel.hong.093a47d2@apsl.player',
  'Samuel',
  'Hong',
  crypt('Playerkiiija2b!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c599e90f-95a9-0006-2a35-9f8b78e00617',
  'santiago.kadadihi.093a47d2@apsl.player',
  'Santiago',
  'Kadadihi',
  crypt('Playerrpvoqk70!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd8ca8762-1ceb-0006-c985-141d72472997',
  'george.karafilidis.093a47d2@apsl.player',
  'George',
  'Karafilidis',
  crypt('Playertqjici9y!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5697dad8-3dda-0006-4855-fed317e341f4',
  'jeremy.kim.093a47d2@apsl.player',
  'Jeremy',
  'Kim',
  crypt('Playerrs6okco5!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '3e76b025-3d56-0006-84b9-5988816cdf5d',
  'eduardo.marquez.093a47d2@apsl.player',
  'Eduardo',
  'Marquez',
  crypt('Playerhlj64x3i!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c7e8e40b-a6ee-0006-665e-a1cff34e8344',
  'nicolas.martignoni.093a47d2@apsl.player',
  'Nicolas',
  'Martignoni',
  crypt('Playervg37or5o!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '6dacb1d8-4f2c-0006-ff1f-f12c5be652fb',
  'evan.mendonca.093a47d2@apsl.player',
  'Evan',
  'Mendonca',
  crypt('Player1273yolr!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '98edbbe5-bedf-0006-9640-a2fae231a640',
  'pablo.montilla.093a47d2@apsl.player',
  'Pablo',
  'Montilla',
  crypt('Player3kd3s8jp!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e3147dfa-0665-0006-60ba-048be198d406',
  'lucas.ortega.morales.093a47d2@apsl.player',
  'Lucas',
  'Ortega Morales',
  crypt('Playerklprhvff!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e502d959-35b0-0006-483a-ae7c34bff8f0',
  'nicholas.stephen.pierangeli.093a47d2@apsl.player',
  'Nicholas',
  'Stephen Pierangeli',
  crypt('Player8hoj6068!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '52ff2ff0-b13e-0006-c23e-e5e01fdfa7fa',
  'mario.ruiz.perez.093a47d2@apsl.player',
  'Mario',
  'Ruiz Perez',
  crypt('Playerx358l301!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ccc170f7-1eb6-0006-d33d-d1f71448291b',
  'edwin.saravia.093a47d2@apsl.player',
  'Edwin',
  'Saravia',
  crypt('Playeruyniq8uj!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'fb16d670-27ac-0006-f947-7b777ef10d1a',
  'caio.soares.093a47d2@apsl.player',
  'Caio',
  'Soares',
  crypt('Playerqv2opg90!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd41ea3ec-cd94-0006-234d-aacf9edfc357',
  'johner.soe.093a47d2@apsl.player',
  'Johner',
  'Soe',
  crypt('Playerfube9h35!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '2afa19f0-f49f-0006-c547-1ccd646572a1',
  'luka.szymanski.093a47d2@apsl.player',
  'Luka',
  'Szymanski',
  crypt('Playeryeh9kepj!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b4c0189d-9672-0006-4213-e0b09465c3a8',
  'ross.lamont.watson.093a47d2@apsl.player',
  'Ross',
  'Lamont Watson',
  crypt('Playerga0hzirf!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Praia Kapital USERS
-- ========================================
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e31dba3c-4c9e-0006-fdf0-2ce96a1d0cf1',
  'mario.amado.2a1d62b2@apsl.player',
  'Mario',
  'Amado',
  crypt('Playeratpi08tg!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'fd343c92-76fb-0006-ca08-e3a723a8cc6b',
  'brenner.cardoso.2a1d62b2@apsl.player',
  'Brenner',
  'Cardoso',
  crypt('Playermobmrkwx!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f851644e-6cb9-0006-5aa8-a632a57078c0',
  'wendy.celestin.2a1d62b2@apsl.player',
  'Wendy',
  'Celestin',
  crypt('Playern085pbuu!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '87b7b08f-477a-0006-c0de-6d9d207b87da',
  'denilson.barros.centeio.2a1d62b2@apsl.player',
  'Denilson',
  'Barros Centeio',
  crypt('Playeryooi80mh!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a2ebd11d-73f2-0006-22d7-108df2b98cad',
  'jacinto.correia.2a1d62b2@apsl.player',
  'Jacinto',
  'Correia',
  crypt('Player24c21uk4!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c3292d68-7400-0006-97b9-a6ffe6203b7d',
  'edson.andarade.da.silva.2a1d62b2@apsl.player',
  'Edson',
  'Andarade Da Silva',
  crypt('Playerdh2zsfmi!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7c1d32d7-e7ce-0006-ae30-5a70828f17fc',
  'fabio.pires.da.silva.2a1d62b2@apsl.player',
  'Fabio',
  'Pires Da Silva',
  crypt('Playerrffdnyxz!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'fccb2dbc-232f-0006-1f9b-144f11e0d69e',
  'rivaldo.baessa.da.silva.2a1d62b2@apsl.player',
  'Rivaldo',
  'Baessa Da Silva',
  crypt('Playerww9rrw2e!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '86409dff-160f-0006-54e3-3fdb87d5cb6a',
  'heracles.de.pina.fernandes.2a1d62b2@apsl.player',
  'Heracles',
  'De Pina Fernandes',
  crypt('Playerfd0k7qbe!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'fd088c7b-7038-0006-1bd0-8b78434937f3',
  'paulo.de.pina.goncalves.2a1d62b2@apsl.player',
  'Paulo',
  'De Pina Goncalves',
  crypt('Playergpl4jn5t!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e83b1a8e-c742-0006-5175-c43e0dffcef9',
  'valdir.depina.2a1d62b2@apsl.player',
  'Valdir',
  'Depina',
  crypt('Playercuchvjxu!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '88844133-cc21-0006-a9fb-dacb5b6b84bb',
  'isandro.fernandes.lopes.2a1d62b2@apsl.player',
  'Isandro',
  'Fernandes Lopes',
  crypt('Playerr10m2lqm!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '2e0c45ff-6275-0006-9117-e96c2ed11875',
  'mario.figueroa.garcia.2a1d62b2@apsl.player',
  'Mario',
  'Figueroa Garcia',
  crypt('Playerbfc57yyb!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '3dfb6f5b-096c-0006-c0de-68202a0d9faa',
  'adilson.gomes.2a1d62b2@apsl.player',
  'Adilson',
  'Gomes',
  crypt('Playerbj3r4bo3!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f95dbd22-4646-0006-aada-9a12965ee8ae',
  'clayton.gomes.2a1d62b2@apsl.player',
  'Clayton',
  'Gomes',
  crypt('Playerswt654ci!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd90af098-0a64-0006-3c03-d13566b89e37',
  'estevao.gomes.2a1d62b2@apsl.player',
  'Estevao',
  'Gomes',
  crypt('Player6nssnudg!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ee7421f3-c84c-0006-1ca0-c982c2fcb5d9',
  'jair.gomes.de.pina.2a1d62b2@apsl.player',
  'Jair',
  'Gomes De Pina',
  crypt('Playerri4gpv3y!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '387aa92c-35b5-0006-9106-89bf626a2a9b',
  'jose.gomes.rodrigues.2a1d62b2@apsl.player',
  'Jose',
  'Gomes Rodrigues',
  crypt('Playerr83pvosg!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd84b1454-08e0-0006-9959-17e52024b912',
  'papa.ndiaye.2a1d62b2@apsl.player',
  'Papa',
  'Ndiaye',
  crypt('Playerh0o8uwg9!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '861a9259-8263-0006-cba5-08bb38bed8b1',
  'lucas.nogueira.monteiro.2a1d62b2@apsl.player',
  'Lucas',
  'Nogueira Monteiro',
  crypt('Playerxjnqqjqh!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c319fa3b-42fc-0006-2d45-554b851e072d',
  'nima.norouzi.behjat.2a1d62b2@apsl.player',
  'Nima',
  'Norouzi Behjat',
  crypt('Players5hsbsww!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '61811672-a748-0006-471a-ff078e1d948a',
  'imauro.pina.2a1d62b2@apsl.player',
  'Imauro',
  'Pina',
  crypt('Playerplb2tegk!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '143a5631-da25-0006-934a-d1948f94e21b',
  'mauro.pires.amado.2a1d62b2@apsl.player',
  'Mauro',
  'Pires Amado',
  crypt('Playerlgqqiou2!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f977223a-11d9-0006-9961-46111a0a54c8',
  'anthony.ramos.2a1d62b2@apsl.player',
  'Anthony',
  'Ramos',
  crypt('Playercpvbz3v7!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ee9f6275-f535-0006-51f3-ff103380cd5d',
  'jose.rodrigues.teixeira.2a1d62b2@apsl.player',
  'Jose',
  'Rodrigues Teixeira',
  crypt('Player607y1cma!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7f8e5e32-65a7-0006-9a6c-ac1ffb0b2091',
  'djeison.rodrigues.vieira.2a1d62b2@apsl.player',
  'Djeison',
  'Rodrigues Vieira',
  crypt('Playerni0ptior!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '91df8aa5-b523-0006-893e-b6fad4068325',
  'tahir.akil.scott.2a1d62b2@apsl.player',
  'Tahir',
  'Akil Scott',
  crypt('Player34bu4609!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7e7daebe-d025-0006-e8b6-600df20ada67',
  'ronilson.semedo.2a1d62b2@apsl.player',
  'Ronilson',
  'Semedo',
  crypt('Playertflhx2fu!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '18dc5113-3f83-0006-81fc-f69045394f51',
  'francisco.m.silveira.2a1d62b2@apsl.player',
  'Francisco',
  'M Silveira',
  crypt('Player9e9g5hcu!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '460efcef-562c-0006-8924-923906fa19fa',
  'yassine.smissame.2a1d62b2@apsl.player',
  'Yassine',
  'Smissame',
  crypt('Playerhgdl3r1l!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '54f00ed5-af3a-0006-4804-3c28b8407d25',
  'kevin.sos.santos.barbisa.2a1d62b2@apsl.player',
  'Kevin',
  'Sos Santos Barbisa',
  crypt('Playernwiiyg08!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'aa8cdd1f-2f60-0006-7d61-82fcf619ca06',
  'domingos.tavares.2a1d62b2@apsl.player',
  'Domingos',
  'Tavares',
  crypt('Playerxiedvi73!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '1a62fb6b-513c-0006-eb2b-803d32eeb8c1',
  'edson.irlandino.tavares.dossantos.2a1d62b2@apsl.player',
  'Edson',
  'Irlandino Tavares Dossantos',
  crypt('Playertkhgwlij!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '46d71052-d92c-0006-5590-45bdde73a9c4',
  'elton.j.teixeira.2a1d62b2@apsl.player',
  'Elton',
  'J Teixeira',
  crypt('Playereh82cxcn!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Scrub Nation USERS
-- ========================================
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'be3d7a2f-4376-0006-68de-3edfc7b28db2',
  'moises.de.pina.alves.cd2f494d@apsl.player',
  'Moises',
  'De pina Alves',
  crypt('Playermtmra3g7!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '4d2a7ae1-7725-0006-6808-c3504221f691',
  'jack.aronson.cd2f494d@apsl.player',
  'Jack',
  'Aronson',
  crypt('Playerhied32lp!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '344bb3ac-f5c7-0006-a175-b4f77514ee1e',
  'joao.p.carvalho.cd2f494d@apsl.player',
  'Joao',
  'P Carvalho',
  crypt('Playerral6hzsr!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '915c256d-cd85-0006-5dae-e10ff96b98b1',
  'mana.chavali.cd2f494d@apsl.player',
  'Mana',
  'Chavali',
  crypt('Player7jgzxdnr!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '6aa8ad86-e544-0006-c25c-13cf3bc8a7b8',
  'suri.chavali.cd2f494d@apsl.player',
  'Suri',
  'Chavali',
  crypt('Playersch4pgcb!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '1a804906-0737-0006-ead8-7359e6369a82',
  'brendan.claflin.cd2f494d@apsl.player',
  'Brendan',
  'Claflin',
  crypt('Playerrt5y9yxy!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'cfae0a60-470c-0006-dec9-0921dfe37b17',
  'matthew.daniel.cosentino.cd2f494d@apsl.player',
  'Matthew',
  'Daniel Cosentino',
  crypt('Playercg2zubir!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f7f32808-0086-0006-9153-171e8d9ca239',
  'patrick.davison.cd2f494d@apsl.player',
  'Patrick',
  'Davison',
  crypt('Playerwn77prae!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '38771ca6-bb8d-0006-b759-dd63ba4aebc0',
  'joao.paulo.de.mattos.almeida.cd2f494d@apsl.player',
  'Joao',
  'Paulo De Mattos Almeida',
  crypt('Player4tivrdkc!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ff2c7239-bf24-0006-f246-bb2a8f522ce8',
  'manuel.ant.nio.depina.cd2f494d@apsl.player',
  'Manuel',
  'António Depina',
  crypt('Playerj5xq5gyq!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b11ac0fc-30c2-0006-c648-7fa2f00debcf',
  'michael.eve.cd2f494d@apsl.player',
  'Michael',
  'Eve',
  crypt('Playerayaax507!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '3edd6e07-6c67-0006-2909-80d45f2e7f98',
  'nicholas.falcone.cd2f494d@apsl.player',
  'Nicholas',
  'Falcone',
  crypt('Playerp5cgnw0k!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '98a0f920-cfc2-0006-b109-c9ec48b1ea03',
  'jackson.faulx.cd2f494d@apsl.player',
  'Jackson',
  'Faulx',
  crypt('Player6p4q14j8!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e87e38b3-aeaf-0006-5e85-a29f4b90b609',
  'luke.hanchar.cd2f494d@apsl.player',
  'Luke',
  'Hanchar',
  crypt('Playerfxze6wr9!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '549cbadd-88ab-0006-fc0f-bd5e4dec4835',
  'oswaldo.hernandez.cd2f494d@apsl.player',
  'Oswaldo',
  'Hernandez',
  crypt('Player0vtt6ycy!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ce0cf326-8d32-0006-ec20-e214cca9d975',
  'martin.konstantinov.cd2f494d@apsl.player',
  'Martin',
  'Konstantinov',
  crypt('Playerzfa6mkti!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '01337fcc-e21f-0006-b2c6-f34a59455b17',
  'kyle.lasewicz.cd2f494d@apsl.player',
  'Kyle',
  'Lasewicz',
  crypt('Playerqjd8qlyv!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a0306b79-daa2-0006-f039-827bf55a2191',
  'surya.mani.cd2f494d@apsl.player',
  'Surya',
  'Mani',
  crypt('Player1alze5sw!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '77bfd936-9f9e-0006-2674-a6c08b37d6c5',
  'christian.martins.cd2f494d@apsl.player',
  'Christian',
  'Martins',
  crypt('Playervduqtmor!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7ef823de-425f-0006-2d47-2e5452ea2530',
  'gilson.martins.cd2f494d@apsl.player',
  'Gilson',
  'Martins',
  crypt('Playervcm3qfex!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '796ba022-c23e-0006-e946-77db796e9276',
  'stephen.denis.silva.mendes.cd2f494d@apsl.player',
  'Stephen',
  'Denis Silva Mendes',
  crypt('Playerie2n9v4k!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f364b18e-75ce-0006-23b6-8ea676bd145b',
  'chad.meyers.cd2f494d@apsl.player',
  'Chad',
  'Meyers',
  crypt('Player6jsrkaoj!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e5ca9bf6-52a9-0006-1daa-611075d43f4f',
  'charles.miller.cd2f494d@apsl.player',
  'Charles',
  'Miller',
  crypt('Playerp89bnhgl!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a7173bd9-7c14-0006-4e7c-08f8efab1643',
  'jonathan.ernesto.rodriguez.cd2f494d@apsl.player',
  'Jonathan',
  'Ernesto Rodriguez',
  crypt('Playersddpg3d6!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'be3bd06d-a787-0006-b39c-2ae228eea7e7',
  'carlos.rojas.cd2f494d@apsl.player',
  'Carlos',
  'Rojas',
  crypt('Playergllqcdyt!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a5d9baf3-6a3a-0006-e6fd-4794e43fbbe1',
  'jaderson.rutsatz.cd2f494d@apsl.player',
  'Jaderson',
  'Rutsatz',
  crypt('Playerintigq2l!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '45eb279e-b74f-0006-f259-aea2be6a1d51',
  'alexander.shanley.cd2f494d@apsl.player',
  'Alexander',
  'Shanley',
  crypt('Playerg2lmgh9l!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '4edd8614-2f67-0006-3a05-0892d106456d',
  'griffin.sisk.cd2f494d@apsl.player',
  'Griffin',
  'Sisk',
  crypt('Player1ykwd5yb!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e599b337-fac7-0006-f3c5-90909853eaff',
  'daniel.soto.cd2f494d@apsl.player',
  'Daniel',
  'Soto',
  crypt('Playerj3qo319q!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'fbfbf8d3-8ee0-0006-fe9c-29d05b143241',
  'elisandro.tavares.cd2f494d@apsl.player',
  'Elisandro',
  'Tavares',
  crypt('Playerchrbznyo!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd7ffb471-2676-0006-f95d-26a39cc04bbb',
  'nick.winn.cd2f494d@apsl.player',
  'Nick',
  'Winn',
  crypt('Playerj6ih0e6d!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a9de40d1-c601-0006-0711-84658df6ac16',
  'jackson.yager.cd2f494d@apsl.player',
  'Jackson',
  'Yager',
  crypt('Playerc4192i4z!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Sete Setembro USA USERS
-- ========================================
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b805f9cd-d99f-0006-2b30-0e5e9efc5d9e',
  'lucas.almeida.a9f395bc@apsl.player',
  'Lucas',
  'Almeida',
  crypt('Playerb7j9z1d6!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ad0a7afa-cbbf-0006-beea-1cdb62b3bc04',
  'leandro.alves.a9f395bc@apsl.player',
  'Leandro',
  'Alves',
  crypt('Playerh7flx6fp!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '2ba78fb6-7730-0006-4172-22a034b34088',
  'alvaro.barbosa.a9f395bc@apsl.player',
  'Alvaro',
  'Barbosa',
  crypt('Playerj69h4ipz!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'fbd55b3f-5e27-0006-883d-e046fe290291',
  'gustavo.candido.a9f395bc@apsl.player',
  'Gustavo',
  'Candido',
  crypt('Playeryu8sywcs!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '96c53b27-5d7e-0006-65b6-b0f3fbaca193',
  'gabriel.cassemiro.a9f395bc@apsl.player',
  'Gabriel',
  'Cassemiro',
  crypt('Player7g92yya4!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'aa22f51e-5de6-0006-98e2-f9079d1613ea',
  'eduardo.chirico.a9f395bc@apsl.player',
  'Eduardo',
  'Chirico',
  crypt('Playerijl02qvf!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f0655170-d9e9-0006-978b-483b31983cdd',
  'antonio.correa.a9f395bc@apsl.player',
  'Antonio',
  'Correa',
  crypt('Playertfmgynsb!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '67740030-97a4-0006-280f-cc1f13b1e255',
  'gabriell.de.godoi.a9f395bc@apsl.player',
  'Gabriell',
  'De Godoi',
  crypt('Player2vr9x5ip!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '4fe2b6e1-8d05-0006-226a-a28657994c74',
  'wengleiman.peres.de.souza.a9f395bc@apsl.player',
  'Wengleiman',
  'Peres De Souza',
  crypt('Playerojx9xw2r!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '2e2cb1a2-fe0a-0006-2649-bcdeb4436bc5',
  'ronaldinho.diniz.a9f395bc@apsl.player',
  'Ronaldinho',
  'Diniz',
  crypt('Playermtcvf5rf!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '88b47d44-a149-0006-9444-2cc4d4fb2961',
  'gabriel.vitalino.ganzer.a9f395bc@apsl.player',
  'Gabriel',
  'Vitalino Ganzer',
  crypt('Player36ebu7s5!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '1418c449-fd62-0006-a285-55b329394a2a',
  'kellvy.garcia.a9f395bc@apsl.player',
  'Kellvy',
  'Garcia',
  crypt('Playertplcqhnv!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'faa11526-7892-0006-dc3d-fd57456a213a',
  'christian.godinho.a9f395bc@apsl.player',
  'Christian',
  'Godinho',
  crypt('Playerkxwmvbk8!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'cd99faae-a3d3-0006-4af4-e571024a2595',
  'maldini.goncalves.a9f395bc@apsl.player',
  'Maldini',
  'Goncalves',
  crypt('Playerutwl3ohe!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '1fcc7b93-56ab-0006-be90-7186bbe5b70e',
  'jonatas.paulino.da.silva.in.cio.a9f395bc@apsl.player',
  'Jonatas',
  'Paulino da Silva Inácio',
  crypt('Playerkj48rh1c!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '4c17c769-2841-0006-1f40-9924e0f0d5a3',
  'lucas.silva.juni.a9f395bc@apsl.player',
  'Lucas',
  'Silva Juni',
  crypt('Player8vgj967w!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '8b2b26ad-a878-0006-b329-4a6e0f9d8134',
  'ryan.lima.a9f395bc@apsl.player',
  'Ryan',
  'Lima',
  crypt('Playermjtp2uev!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7fb6aeee-b8cc-0006-30ca-9c09bacd6752',
  'euclides.medonca.a9f395bc@apsl.player',
  'Euclides',
  'Medonca',
  crypt('Playerkmh8pomj!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '15c20db8-1cfb-0006-572f-598bbe571d36',
  'yago.miller.a9f395bc@apsl.player',
  'Yago',
  'Miller',
  crypt('Playerjmqlszsz!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '02e633e0-a6f0-0006-2d5f-e6142c7d5ab0',
  'jo.o.miranda.a9f395bc@apsl.player',
  'João',
  'Miranda',
  crypt('Playervjfch9rz!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '4d77edc1-3134-0006-e066-c85ad5063669',
  'steven.monsalve.a9f395bc@apsl.player',
  'Steven',
  'Monsalve',
  crypt('Player3e2fbihr!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5f0673f4-88a9-0006-efbe-97103612c96f',
  'alisson.monteiro.a9f395bc@apsl.player',
  'Alisson',
  'Monteiro',
  crypt('Playeri599dnsg!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '91c9e28d-a721-0006-c1d6-20afcb47bffd',
  'wenderson.pereira.a9f395bc@apsl.player',
  'Wenderson',
  'Pereira',
  crypt('Playerjcrvwp5z!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '994b69a3-0902-0006-bd7d-303d49fed728',
  'mario.prata.a9f395bc@apsl.player',
  'Mario',
  'Prata',
  crypt('Playermbglk4nz!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd2e64ce3-0004-0006-500e-c570d51f7d55',
  'andy.ramirez.a9f395bc@apsl.player',
  'Andy',
  'Ramirez',
  crypt('Playerknt4r28y!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f836061e-6ad9-0006-b2c3-fa14a5e0b392',
  'dennis.ramirez.a9f395bc@apsl.player',
  'Dennis',
  'Ramirez',
  crypt('Player1rwsf5ft!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '60638c8d-c0ec-0006-cfef-41dc7bb448f3',
  'marcos.santos.a9f395bc@apsl.player',
  'Marcos',
  'Santos',
  crypt('Player8e74nsln!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e2e1a231-9e79-0006-c658-4d7ed24665a0',
  'kaio.silva.a9f395bc@apsl.player',
  'Kaio',
  'Silva',
  crypt('Playerui9myfmk!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '6e02be28-fe46-0006-f2d2-378d8760f22e',
  'lu.s.felipe.silva.a9f395bc@apsl.player',
  'Luís',
  'Felipe Silva',
  crypt('Playerf0zwwd7d!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '442c991c-6a42-0006-02fb-cec5e84d2754',
  'meny.silva.a9f395bc@apsl.player',
  'Meny',
  'Silva',
  crypt('Player23rywv1v!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'db11cca5-236b-0006-ffa5-74c46334b09c',
  'jose.tavares.a9f395bc@apsl.player',
  'Jose',
  'Tavares',
  crypt('Playerkouoyqw3!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'cab797c0-61ba-0006-993d-f655a32eceee',
  'waverton.teodoro.a9f395bc@apsl.player',
  'Waverton',
  'Teodoro',
  crypt('Player7r9ly20l!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5e53ea04-acc2-0006-8a4d-7b054044dd2b',
  'patrick.vilela.a9f395bc@apsl.player',
  'Patrick',
  'Vilela',
  crypt('Playerl56ebxi7!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '6f17adcc-822c-0006-9e1f-5281b9caff2b',
  'michael.willis.a9f395bc@apsl.player',
  'Michael',
  'Willis',
  crypt('Playerxgj7qvb9!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '3ead43ee-e5ff-0006-76d1-0395147c4c2f',
  'william.zanetti.a9f395bc@apsl.player',
  'William',
  'Zanetti',
  crypt('Playerrgdc2n00!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- South Coast Union USERS
-- ========================================
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '10ecbb9b-0bd0-0006-bdd8-445c5d1717bc',
  'daniel.andrade.3b1d4171@apsl.player',
  'Daniel',
  'Andrade',
  crypt('Player5jhe74ci!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '34f1600f-adf8-0006-dfda-15462bac8226',
  'edmilson.andrade.3b1d4171@apsl.player',
  'Edmilson',
  'Andrade',
  crypt('Playerxzf04bqp!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c23c93e0-9cad-0006-afc1-6235a4ad738e',
  'damian.anerdson.3b1d4171@apsl.player',
  'Damian',
  'Anerdson',
  crypt('Playerdzt6z5eb!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ff674b3a-faef-0006-fbe4-4a3b144c9ecc',
  'ronis.ayala.3b1d4171@apsl.player',
  'Ronis',
  'Ayala',
  crypt('Playergdw41ik9!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5c805dc1-2758-0006-ac5c-462d53a94e2e',
  'dominique.baessa.3b1d4171@apsl.player',
  'Dominique',
  'Baessa',
  crypt('Playerlzql7rj1!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '3a3719c7-2f13-0006-15c1-c40303655920',
  'gio.barros.3b1d4171@apsl.player',
  'Gio',
  'Barros',
  crypt('Player22aul6id!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '8a6fcc5e-1bc5-0006-3068-79046e5cae88',
  'justin.barros.3b1d4171@apsl.player',
  'Justin',
  'Barros',
  crypt('Playerdqyx3nmj!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '651b275c-f3cc-0006-4bb5-990300b973fd',
  'dominek.borden.3b1d4171@apsl.player',
  'Dominek',
  'Borden',
  crypt('Playerk6vu2zv6!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '4c6ea97a-d6df-0006-8a7b-a93004d8d5ae',
  'edemilson.candida.3b1d4171@apsl.player',
  'Edemilson',
  'Candida',
  crypt('Playerro0lqmg1!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b1748e0b-510e-0006-6e09-5b8d25bdf091',
  'kevin.correia.3b1d4171@apsl.player',
  'Kevin',
  'Correia',
  crypt('Playerho1ecwtp!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '81a73122-bcf3-0006-f11a-f206cd1745a6',
  'neil.cunha.3b1d4171@apsl.player',
  'Neil',
  'Cunha',
  crypt('Player8ps2d48l!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f1ed8d5a-33c2-0006-115c-9eb7f9d9b888',
  'mason.dealmeida.3b1d4171@apsl.player',
  'Mason',
  'Dealmeida',
  crypt('Player8c4dzqqu!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd0d24d06-6d6b-0006-18c7-9575e2e2e069',
  'clayton.demelo.3b1d4171@apsl.player',
  'Clayton',
  'Demelo',
  crypt('Players7g4o4pk!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '94fb4cb6-a95d-0006-f754-e6466e24dee3',
  'ethan.demelo.3b1d4171@apsl.player',
  'Ethan',
  'Demelo',
  crypt('Player0ojanopk!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '552ce04a-b591-0006-88f7-de0f94e2b1a9',
  'dawson.dosvais.3b1d4171@apsl.player',
  'Dawson',
  'Dosvais',
  crypt('Playerv1bets3s!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '28a8bb17-4d16-0006-0028-da0580db557d',
  'zajdele.dulcine.3b1d4171@apsl.player',
  'Zajdele',
  'Dulcine',
  crypt('Playerh9dl0fnk!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '6c83864c-6e38-0006-28da-f08583c72161',
  'augustin.edwin.3b1d4171@apsl.player',
  'Augustin',
  'Edwin',
  crypt('Playeru2wllr7y!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e243f53c-85e7-0006-766e-5ccb69f3784f',
  'austin.eugenio.3b1d4171@apsl.player',
  'Austin',
  'Eugenio',
  crypt('Player6o9p3wtv!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'cf933db5-a8bf-0006-3336-30343a66d5d1',
  'malaquias.tavares.garcia.3b1d4171@apsl.player',
  'Malaquias',
  'Tavares Garcia',
  crypt('Playermfgk606w!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '079f7d10-c366-0006-fa39-78982b0f039a',
  'michael.garcia.3b1d4171@apsl.player',
  'Michael',
  'Garcia',
  crypt('Player60qciv6v!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '3c41b15d-252e-0006-5f38-cf97c6e10144',
  'damon.greene.3b1d4171@apsl.player',
  'Damon',
  'Greene',
  crypt('Player72lr2gpn!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '1a1027b0-f8b9-0006-3db6-7a4f3dba6a79',
  'ricardo.macedo.3b1d4171@apsl.player',
  'Ricardo',
  'Macedo',
  crypt('Player0z668ghv!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '395e2bcd-42dc-0006-7916-9b2466201f24',
  'sam.matias.3b1d4171@apsl.player',
  'Sam',
  'Matias',
  crypt('Playern4vcccz0!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'fc9fbe96-6ecd-0006-be37-ca4dda669e73',
  'dylan.mendes.3b1d4171@apsl.player',
  'Dylan',
  'Mendes',
  crypt('Player5jqu2sf0!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5faa0ce1-4a64-0006-5522-0902ddefe4bd',
  'jose.carlos.ze.mendes.3b1d4171@apsl.player',
  'Jose',
  'Carlos "Ze" Mendes',
  crypt('Playerwpmr9fwt!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '278a5f89-bea1-0006-e887-428d019e47ea',
  'ethan.paiva.3b1d4171@apsl.player',
  'Ethan',
  'Paiva',
  crypt('Playerluzj0z9o!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '52a44609-34de-0006-094d-33f59224d07f',
  'joey.paiva.3b1d4171@apsl.player',
  'Joey',
  'Paiva',
  crypt('Playerkn7eqo9b!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '321bd71d-8542-0006-7c9d-2fe8ae1e0eaa',
  'colin.pereira.3b1d4171@apsl.player',
  'Colin',
  'Pereira',
  crypt('Playerb7zj69y7!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '6a37adef-bedf-0006-ddd0-9a36ebec529e',
  'jacob.ramos.3b1d4171@apsl.player',
  'Jacob',
  'Ramos',
  crypt('Playerecjqssdg!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5c419fc1-ab1a-0006-f3b5-f351e84df834',
  'rafael.raposo.3b1d4171@apsl.player',
  'Rafael',
  'Raposo',
  crypt('Player1f8obtn6!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd8e97420-1285-0006-5513-404fa75107dd',
  'dylan.senra.3b1d4171@apsl.player',
  'Dylan',
  'Senra',
  crypt('Playerhdtqt124!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ba018c0d-f768-0006-d9cf-2193f8f2f02e',
  'flavio.joel.soares.carvalho.3b1d4171@apsl.player',
  'Flavio',
  'Joel Soares Carvalho',
  crypt('Playerbmuvherm!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '1f74c66f-9602-0006-68a0-662831cf0bdb',
  'christian.sousa.3b1d4171@apsl.player',
  'Christian',
  'Sousa',
  crypt('Player7o5poz5a!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Project Football USERS
-- ========================================
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c204662d-9f60-0006-caee-ac59cfb099d0',
  'wilson.omar.amaya.lara.d6dd2763@apsl.player',
  'Wilson',
  'Omar Amaya Lara',
  crypt('Playerksi43o7j!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '239eb9d0-3eee-0006-bb8a-f09144263e3c',
  'jessiel.alexander.amparo.d6dd2763@apsl.player',
  'Jessiel',
  'Alexander Amparo',
  crypt('Playerz2hwp7qv!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '9ed8d835-8faa-0006-e5f7-12baeea8b890',
  'minor.ojanny.angel.merida.d6dd2763@apsl.player',
  'Minor',
  'Ojanny Angel Merida',
  crypt('Playera4qsdtm9!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c4180da0-d916-0006-1eee-ce86df4d0bc3',
  'yaw.bediako.d6dd2763@apsl.player',
  'Yaw',
  'Bediako',
  crypt('Playerxm1ntz1q!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '3f4e76f5-fef0-0006-891d-f85b037d8c25',
  'elvino.tavares.da.silva.d6dd2763@apsl.player',
  'Elvino',
  'Tavares Da Silva',
  crypt('Playerhm2k0d1a!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '8bfdfed4-85cf-0006-70e1-52988ce09171',
  'delvino.tavares.dasilva.d6dd2763@apsl.player',
  'Delvino',
  'Tavares Dasilva',
  crypt('Playerxv07qdvl!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7c94eb3f-e6f9-0006-6112-e9a564fc6ddc',
  'jamel.anch.david.d6dd2763@apsl.player',
  'Jamel',
  'Anch David',
  crypt('Playerilpxcu6k!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '621baa97-98c1-0006-1aee-818e144a3d36',
  'henry.edeko.d6dd2763@apsl.player',
  'Henry',
  'Edeko',
  crypt('Playerw8vuetrx!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c0e3e73b-88bd-0006-5171-ddfa2c9c0612',
  'ayoub.essaoui.d6dd2763@apsl.player',
  'Ayoub',
  'Essaoui',
  crypt('Player5u612bis!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'edfd7120-4ab2-0006-c84f-02c2e467dc81',
  'jackson.fernandes.d6dd2763@apsl.player',
  'Jackson',
  'Fernandes',
  crypt('Player3mkf0q34!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ac7c1c91-5031-0006-0fe4-cf975651136d',
  'carlos.augusto.gomez.hernandez.d6dd2763@apsl.player',
  'Carlos',
  'Augusto Gomez Hernandez',
  crypt('Player6c6xs186!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '6839aa1b-1afc-0006-caad-5479792ec33e',
  'braulio.gonzalez.oliveria.d6dd2763@apsl.player',
  'Braulio',
  'Gonzalez Oliveria',
  crypt('Player4uz0kvla!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '770a8af1-322c-0006-c3d2-08727477b38e',
  'alejandro.alfonso.guerrero.vargas.d6dd2763@apsl.player',
  'Alejandro',
  'Alfonso Guerrero Vargas',
  crypt('Playerhkvvso3l!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b29f8397-0d3a-0006-f3b9-24d8cbb8331d',
  'kenneth.jared.ibarra.suarez.d6dd2763@apsl.player',
  'Kenneth',
  'Jared Ibarra Suarez',
  crypt('Playerfccu18xk!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '74591340-f72d-0006-70b2-bda972ba6a77',
  'aeshan.kapil.d6dd2763@apsl.player',
  'Aeshan',
  'Kapil',
  crypt('Playerpe7s2b6s!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b8f6b84b-3d4e-0006-6297-d154a8f0bac0',
  'jesus.gilberto.martinez.d6dd2763@apsl.player',
  'Jesus',
  'Gilberto Martinez',
  crypt('Playergzfovneg!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f9975947-d492-0006-14ac-de306351d4f7',
  'ricosta.mede.d6dd2763@apsl.player',
  'Ricosta',
  'Mede',
  crypt('Playerl2295gvp!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '2ee6e097-2dcb-0006-bb47-e316edb83617',
  'sheventz.multy.d6dd2763@apsl.player',
  'Sheventz',
  'Multy',
  crypt('Playerdad36dzy!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '62c849af-fe31-0006-5776-f9c667a10f28',
  'samuel.armando.perez.d6dd2763@apsl.player',
  'Samuel',
  'Armando Perez',
  crypt('Playern3z07dgm!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'de4f5a6f-574d-0006-531a-cccec1e6ca19',
  'aiden.thor.perry.d6dd2763@apsl.player',
  'Aiden',
  'Thor Perry',
  crypt('Playervrpw88da!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a3dc3f02-8ce8-0006-07f5-c448faef633b',
  'alex.andrade.pina.d6dd2763@apsl.player',
  'Alex',
  'Andrade Pina',
  crypt('Playerh0ei0ipd!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e74366d4-73c8-0006-ddb1-39d1296909eb',
  'connor.poliquin.d6dd2763@apsl.player',
  'Connor',
  'Poliquin',
  crypt('Playerzeedi3ja!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7ef66a1a-d185-0006-aee8-c5579114f24e',
  'timothy.singleton.d6dd2763@apsl.player',
  'Timothy',
  'Singleton',
  crypt('Playerxf9xqz7f!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '06243baf-d088-0006-eafa-67c39d788523',
  'francisco.aron.villacorta.d6dd2763@apsl.player',
  'Francisco',
  'Aron Villacorta',
  crypt('Player1o0xyr16!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ffa8e7ba-cf9d-0006-7871-c460998a4685',
  'benjamin.watts.d6dd2763@apsl.player',
  'Benjamin',
  'Watts',
  crypt('Players4mqtuc0!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Invictus FC USERS
-- ========================================
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a66b07d6-2ab5-0006-57aa-082db8b74bdf',
  'mo.amine.faleh.aa0aab49@apsl.player',
  'Mo',
  'Amine Faleh',
  crypt('Playerivppetl6!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '9a7d998e-1d25-0006-f724-d933629c8207',
  'ludwin.daniel.carranza.aa0aab49@apsl.player',
  'Ludwin',
  'Daniel Carranza',
  crypt('Player26f9328z!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '9a83db4e-1dd0-0006-32fa-54dc21a6f60f',
  'albert.daniels.aa0aab49@apsl.player',
  'Albert',
  'Daniels',
  crypt('Playert00sj5lz!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '57a816c2-bdf9-0006-e504-2ed18888c2d3',
  'yassine.elbasli.aa0aab49@apsl.player',
  'Yassine',
  'ElBasli',
  crypt('Playert4jo2z5y!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a3b2ed71-39cd-0006-5ecc-0aeaba491fcb',
  'eduardo.engst.mansilla.aa0aab49@apsl.player',
  'Eduardo',
  'Engst-Mansilla',
  crypt('Playeroj4o7eq3!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '06a72c5f-1933-0006-15c4-5ff419ac14a0',
  'kerllon.silva.felipe.aa0aab49@apsl.player',
  'Kerllon',
  'Silva Felipe',
  crypt('Playeremzcif8n!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'daad7aae-617f-0006-1ead-adc8335cf265',
  'cole.fergusson.aa0aab49@apsl.player',
  'Cole',
  'Fergusson',
  crypt('Playergvnvdxr4!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '79168662-5a95-0006-79a6-50ce7e49bc60',
  'joao.victor.ferreira.aa0aab49@apsl.player',
  'Joao',
  'Victor Ferreira',
  crypt('Playersa1xhjpv!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '4e3dbb85-2833-0006-2e3c-7d8afa40a7cb',
  'carl.foming.aa0aab49@apsl.player',
  'Carl',
  'Foming',
  crypt('Playeri11eyh1i!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '0d6c31d5-4891-0006-4d5d-32081b61a344',
  'jackson.c.gilstrap.aa0aab49@apsl.player',
  'Jackson',
  'C Gilstrap',
  crypt('Playerqv5wx99k!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '9d9fa60a-db7d-0006-8d73-bfff050ae4f4',
  'bernadin.herard.aa0aab49@apsl.player',
  'Bernadin',
  'Herard',
  crypt('Playeru4rnma48!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '80a6f9b6-f7fe-0006-0fa0-84a1e86ec589',
  'juan.camilo.hern.ndez.aa0aab49@apsl.player',
  'Juan',
  'camilo Hernández',
  crypt('Player115j7095!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '1b1f5065-833d-0006-4c44-eb08b66ac909',
  'delices.keyri.aa0aab49@apsl.player',
  'Delices',
  'Keyri',
  crypt('Playerqu66kg49!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '77ea7aac-0609-0006-d415-563921a3ea66',
  'hindolo.brima.mansaray.aa0aab49@apsl.player',
  'Hindolo',
  'Brima Mansaray',
  crypt('Playerafwjnri9!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '017d8a53-30c9-0006-d1f4-aaafbdf7fa54',
  'john.massaquoi.aa0aab49@apsl.player',
  'John',
  'Massaquoi',
  crypt('Playerh1a15o86!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '910e8d67-6fb5-0006-510b-aa9a4047dece',
  'vincent.miller.aa0aab49@apsl.player',
  'Vincent',
  'Miller',
  crypt('Playerb75n03va!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e41dc2df-b495-0006-a24b-019d76ec0bd3',
  'hassan.mutaasa.aa0aab49@apsl.player',
  'Hassan',
  'Mutaasa',
  crypt('Playera2sescu6!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '4e8b195f-f1de-0006-5d6b-d7e3d196a59f',
  'amadou.moustapha.ndiaye.aa0aab49@apsl.player',
  'Amadou',
  'Moustapha Ndiaye',
  crypt('Playerr6hwnkhl!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c8b24d17-62ab-0006-9dfe-363294648bdc',
  'carl.olivier.aa0aab49@apsl.player',
  'Carl',
  'Olivier',
  crypt('Playerjkeenho9!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '6af5cba8-ed0f-0006-4be5-e819d4693911',
  'roodchyl.samuel.pauleon.aa0aab49@apsl.player',
  'Roodchyl',
  'Samuel Pauleon',
  crypt('Playerssq3prje!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5f93ebc7-c756-0006-fa25-659b100c2dc3',
  'jaydon.perez.aa0aab49@apsl.player',
  'Jaydon',
  'Perez',
  crypt('Playeroqkzddh8!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '99f05cfe-412a-0006-225a-1fe7e703fe9b',
  'joseph.saidu.aa0aab49@apsl.player',
  'Joseph',
  'Saidu',
  crypt('Player22u8hbyi!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '038eb4f3-7a89-0006-b4e2-f7dd2e34f47b',
  'destin.sleeter.aa0aab49@apsl.player',
  'Destin',
  'Sleeter',
  crypt('Playerzqsstqzr!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '275f1c7b-9a07-0006-db05-4756c954d60c',
  'pierre.st.simon.aa0aab49@apsl.player',
  'Pierre',
  'St Simon',
  crypt('Playerwg7xu6mz!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '67f4b8e1-78ab-0006-df89-1ac992184b1c',
  'isaiah.stessman.aa0aab49@apsl.player',
  'Isaiah',
  'Stessman',
  crypt('Player729yilts!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e30f59ac-9cd7-0006-ec64-2480e687cb4d',
  'carlos.teixeira.aa0aab49@apsl.player',
  'Carlos',
  'Teixeira',
  crypt('Playerhkqzn0sj!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '329491a1-e4e0-0006-da14-f249b90d3a07',
  'hamza.tribia.aa0aab49@apsl.player',
  'Hamza',
  'Tribia',
  crypt('Playerkbb45csf!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '71bf6e6e-b8e3-0006-de46-e20418c83583',
  'luiz.gustavo.zanellato.aa0aab49@apsl.player',
  'Luiz',
  'Gustavo Zanellato',
  crypt('Playerounn7tlb!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7b4104c2-0fe7-0006-654d-b4c4b6804182',
  'abraham.zepeda.aa0aab49@apsl.player',
  'Abraham',
  'Zepeda',
  crypt('Player7hk4u855!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Fitchburg FC USERS
-- ========================================
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a671dba9-3e70-0006-26f2-1c4186d54162',
  'mustapha.ait.zbair.b8ec25f4@apsl.player',
  'Mustapha',
  'Ait Zbair',
  crypt('Playerdsqc2fid!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'bca35d65-8a83-0006-1320-431e9de0c0ce',
  'joshua.atemkeng.b8ec25f4@apsl.player',
  'Joshua',
  'Atemkeng',
  crypt('Player7d0wo7o6!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'dbb7229c-8270-0006-fcb8-0e745dabcd98',
  'ousmane.balde.b8ec25f4@apsl.player',
  'Ousmane',
  'balde',
  crypt('Playerhcqxg3m9!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '758835ce-e148-0006-2ee1-3613ccf3f3d4',
  'john.brewer.b8ec25f4@apsl.player',
  'John',
  'Brewer',
  crypt('Playervhfhhabh!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'af00fbbf-c4ce-0006-708f-7358ac54bcd9',
  'oscar.castillo.b8ec25f4@apsl.player',
  'Oscar',
  'Castillo',
  crypt('Playerrt47fq9p!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '2e57d3f4-039d-0006-1959-f0aee20918a6',
  'edmond.charles.b8ec25f4@apsl.player',
  'Edmond',
  'Charles',
  crypt('Playery9gpddvz!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a715418f-b746-0006-0cd5-5f6f698465b0',
  'dimitri.costa.b8ec25f4@apsl.player',
  'Dimitri',
  'Costa',
  crypt('Playercprb7bdr!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '9fa25e9e-eef5-0006-0394-3175de0b12aa',
  'hamza.el.amane.b8ec25f4@apsl.player',
  'Hamza',
  'El Amane',
  crypt('Playermt2bdrif!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7a2016e4-8671-0006-d680-e641a1806a0a',
  'mohamed.el.rhoufi.b8ec25f4@apsl.player',
  'Mohamed',
  'El-Rhoufi',
  crypt('Playernc10kdvw!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '392c3cec-b2c2-0006-d412-7b3d6996a439',
  'hyacinth.fongang.b8ec25f4@apsl.player',
  'Hyacinth',
  'Fongang',
  crypt('Playerpiwx54ue!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '3cb5654d-6c95-0006-c730-e6f73d96e27b',
  'metayer.gassamar.b8ec25f4@apsl.player',
  'Metayer',
  'Gassamar',
  crypt('Playerg6ev7gkj!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'fcdff43d-e43b-0006-b34c-a237391d430c',
  'abubakar.sidiq.hamidu.b8ec25f4@apsl.player',
  'Abubakar',
  'Sidiq Hamidu',
  crypt('Player1z0lkal7!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '25d98e29-5e85-0006-ab24-65bc2b00484b',
  'diallo.ibrahima.b8ec25f4@apsl.player',
  'Diallo',
  'Ibrahima',
  crypt('Playergfwj7kf1!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b7cc2568-7503-0006-d130-a64c1e902d68',
  'ralph.jean.baptiste.b8ec25f4@apsl.player',
  'Ralph',
  'Jean Baptiste',
  crypt('Player4zm60p71!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '05d8fe76-30b3-0006-8751-3362b6a4febd',
  'root.mael.jean.baptiste.b8ec25f4@apsl.player',
  'Root-mael',
  'Jean Baptiste',
  crypt('Playerm5vbfdd0!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '9383a7dc-1c28-0006-ce1b-27b7cbaa0a38',
  'cedrick.labah.b8ec25f4@apsl.player',
  'Cedrick',
  'Labah',
  crypt('Playere1k6rjxr!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '77718982-2e27-0006-2419-c0d6331edb8d',
  'bruno.lana.b8ec25f4@apsl.player',
  'Bruno',
  'Lana',
  crypt('Player4eg4zfhz!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a6473cf1-c0db-0006-4eb3-5ea8059d1c1f',
  'longtse.mofor.landoh.b8ec25f4@apsl.player',
  'Longtse',
  'Mofor Landoh',
  crypt('Playerc1w8o3u8!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '95f52929-41c9-0006-bddb-59a5c18f383c',
  'roberto.martinez.b8ec25f4@apsl.player',
  'Roberto',
  'Martinez',
  crypt('Playercuec44bs!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a5468844-44db-0006-84cc-32c6775c6ad3',
  'quang.milligan.b8ec25f4@apsl.player',
  'Quang',
  'Milligan',
  crypt('Player8bad4b9l!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '18f25be9-0c86-0006-d5a9-b92e31bef6af',
  'bonjoh.ngoasong.b8ec25f4@apsl.player',
  'Bonjoh',
  'Ngoasong',
  crypt('Player0z7hqtii!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ec447434-4c7c-0006-789e-800b261905c0',
  'sydiney.nyabiosi.b8ec25f4@apsl.player',
  'Sydiney',
  'Nyabiosi',
  crypt('Playertxel20f9!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '74b629c4-a0aa-0006-4629-5802b129b2ec',
  'pedro.pedrine.b8ec25f4@apsl.player',
  'Pedro',
  'Pedrine',
  crypt('Playermv7v7k43!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c2e6c31c-0072-0006-fbee-9c750f89afb2',
  'marc.hattley.pierre.b8ec25f4@apsl.player',
  'Marc',
  'Hattley Pierre',
  crypt('Playerqa63swiq!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c1c38b99-1c40-0006-89b6-85708049f865',
  'luvensky.polycarpe.b8ec25f4@apsl.player',
  'Luvensky',
  'Polycarpe',
  crypt('Playermzt86l56!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b3a9c857-deda-0006-786e-d3de80fa274d',
  'angelo.ramirez.b8ec25f4@apsl.player',
  'Angelo',
  'Ramirez',
  crypt('Playergtza2bw9!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5c473b7c-6b1e-0006-bb55-4180e2e04496',
  'emerson.roman.b8ec25f4@apsl.player',
  'Emerson',
  'Roman',
  crypt('Playerzln58ut6!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b306474b-1ffe-0006-a735-b981a3cd1445',
  'yostin.roman.b8ec25f4@apsl.player',
  'Yostin',
  'Roman',
  crypt('Playerj568sbby!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '6592a105-8a22-0006-bcad-923a9459c8ab',
  'shelton.sidelca.b8ec25f4@apsl.player',
  'Shelton',
  'Sidelca',
  crypt('Playerz7dyhl7t!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '1858b63d-d30f-0006-3a86-388cddd478ad',
  'redwane.tinfle.b8ec25f4@apsl.player',
  'Redwane',
  'Tinfle',
  crypt('Playerd5srswzf!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '194d4334-ce0c-0006-83eb-9ab934e83366',
  'nelvin.vando.b8ec25f4@apsl.player',
  'Nelvin',
  'Vando',
  crypt('Playerjhvyszco!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '83623023-d72b-0006-ff08-074e6c44c04d',
  'jonathan.vazquez.b8ec25f4@apsl.player',
  'Jonathan',
  'Vazquez',
  crypt('Playerjbrtwkuw!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c1f9df67-2c98-0006-e46a-c9329a8e6e45',
  'ethan.vitello.b8ec25f4@apsl.player',
  'Ethan',
  'Vitello',
  crypt('Playerruzv9gkz!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '9e1e92a5-11bc-0006-816b-4bdada1e7203',
  'trevor.voisine.b8ec25f4@apsl.player',
  'Trevor',
  'Voisine',
  crypt('Playerner5gjxe!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7281b6d1-afe4-0006-123a-6f5c795fc86f',
  'zamy.youri.ansley.b8ec25f4@apsl.player',
  'Zamy',
  'Youri Ansley',
  crypt('Player5ya1obsz!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- KO Elites USERS
-- ========================================
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5f48257b-a7b5-0006-04ac-22c18c9e56b0',
  'meysar.abdulkadir.a57bd844@apsl.player',
  'Meysar',
  'Abdulkadir',
  crypt('Playerkoz6z90k!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '237d597c-50c6-0006-a342-8393585a6715',
  'joel.agebtossou.a57bd844@apsl.player',
  'Joel',
  'Agebtossou',
  crypt('Playeroog1olxn!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '45fca129-8a8b-0006-5098-ea71919a3695',
  'davaughn.anderson.a57bd844@apsl.player',
  'Davaughn',
  'Anderson',
  crypt('Player9caq2ox5!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'fdf168a7-0286-0006-b80e-36e847aeb353',
  'deante.anderson.a57bd844@apsl.player',
  'Deante',
  'Anderson',
  crypt('Player3a3s0yde!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '86ba5169-0de5-0006-292f-4fd73d64ee17',
  'jimmy.arita.a57bd844@apsl.player',
  'Jimmy',
  'Arita',
  crypt('Playerrhkdqthz!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '79210fc4-505f-0006-8d9c-be8f8d1a94ae',
  'ben.awashie.a57bd844@apsl.player',
  'Ben',
  'Awashie',
  crypt('Player9bit5rpz!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '6534d258-3549-0006-c0fe-6a2357fb307e',
  'alessandro.bacabac.a57bd844@apsl.player',
  'Alessandro',
  'Bacabac',
  crypt('Playerdv17tve3!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '14d57c63-86cf-0006-8d3f-aa11be0c7880',
  'dejaun.beckford.a57bd844@apsl.player',
  'Dejaun',
  'Beckford',
  crypt('Playerf1i6e2t1!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f580334c-e0f6-0006-10bb-7fda0692c7bb',
  'joseph.boakye.a57bd844@apsl.player',
  'Joseph',
  'Boakye',
  crypt('Playerylxalowl!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '642ae3c8-5827-0006-bbc3-6bfd378b6724',
  'alexander.clarke.a57bd844@apsl.player',
  'Alexander',
  'Clarke',
  crypt('Playerw2s8h4a9!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'cb31b213-3307-0006-fa04-c693827fb673',
  'caleb.ennin.a57bd844@apsl.player',
  'Caleb',
  'Ennin',
  crypt('Playerdxe6zns8!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '3efb2a30-fb95-0006-a230-6f961d28b22a',
  'tim.ennin.a57bd844@apsl.player',
  'Tim',
  'Ennin',
  crypt('Playerztnrtte2!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'eda54837-0d78-0006-c453-6a01929cede9',
  'shaquan.facey.a57bd844@apsl.player',
  'Shaquan',
  'Facey',
  crypt('Player2jvutmih!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '8b077d33-9688-0006-fb1b-db44abff91ea',
  'jahvanni.grant.a57bd844@apsl.player',
  'Jahvanni',
  'Grant',
  crypt('Player66ju9jkt!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ab4496ad-bb66-0006-b0d6-de990feece38',
  'elian.guaman.a57bd844@apsl.player',
  'Elian',
  'Guaman',
  crypt('Playermmjgygja!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd7e9cb9e-9080-0006-1cf6-e8df22fcf626',
  'dax.hoffman.a57bd844@apsl.player',
  'Dax',
  'Hoffman',
  crypt('Playertava03yj!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '28a701f3-5454-0006-022e-df02a0ab4469',
  'george.jimenez.a57bd844@apsl.player',
  'George',
  'Jimenez',
  crypt('Playerc6ftpjda!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '9b971125-784e-0006-df3a-33271e15435b',
  'gideon.kadiri.a57bd844@apsl.player',
  'Gideon',
  'Kadiri',
  crypt('Playerfeuumtr4!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '455f1f4e-9c57-0006-1de6-a4857a83995b',
  'jaheim.kennedy.a57bd844@apsl.player',
  'Jaheim',
  'Kennedy',
  crypt('Playerz4a9ldfc!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd76a8c4a-8ee3-0006-01f6-4af2f451eae7',
  'brenden.landry.a57bd844@apsl.player',
  'Brenden',
  'Landry',
  crypt('Playerbh9xnge1!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '1fcb7ab6-f801-0006-b409-63fdaebdb1a1',
  'shani.miller.a57bd844@apsl.player',
  'Shani',
  'Miller',
  crypt('Playerr3xw1jxj!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '46499662-a1fa-0006-a2a1-7fa4bcaec798',
  'kwesi.mills.odoi.a57bd844@apsl.player',
  'Kwesi',
  'Mills-Odoi',
  crypt('Player1z2zmmr5!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f1fae5ea-f343-0006-2068-b3d3d2ac17a1',
  'shemar.moore.a57bd844@apsl.player',
  'Shemar',
  'Moore',
  crypt('Playerjzsrefz1!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '486e26a6-4caf-0006-adae-65576a75a8f0',
  'andre.morrison.a57bd844@apsl.player',
  'Andre',
  'Morrison',
  crypt('Playerf8zpv19n!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '18e5bb9b-c6a4-0006-30b7-8d677e0d58da',
  'yaw.nimo.agyare.a57bd844@apsl.player',
  'Yaw',
  'Nimo-Agyare',
  crypt('Playerbqhkp90v!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '83613426-3646-0006-01ac-f6c53a5d87cf',
  'kenny.ofori.a57bd844@apsl.player',
  'Kenny',
  'Ofori',
  crypt('Playerw7h5lyr8!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ed6b8b8f-0666-0006-bff0-b5d63fa24462',
  'diwash.pun.a57bd844@apsl.player',
  'Diwash',
  'Pun',
  crypt('Player1msmovn7!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '9a822f11-984a-0006-4b2e-43da6a7ca569',
  'shamar.smith.a57bd844@apsl.player',
  'Shamar',
  'Smith',
  crypt('Playerpivp83kw!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'be8de552-01d2-0006-ab9e-3d6a6ea17b21',
  'sholay.sock.a57bd844@apsl.player',
  'Sholay',
  'Sock',
  crypt('Player2vtdomsl!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '4d30f313-9519-0006-7cd2-3956e8e1c040',
  'dane.stephens.a57bd844@apsl.player',
  'Dane',
  'Stephens',
  crypt('Playermmutasa1!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a00ee1da-be10-0006-cf62-ce8777b8a716',
  'romaine.walters.a57bd844@apsl.player',
  'Romaine',
  'Walters',
  crypt('Player0t8m2tyw!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Glastonbury Celtic USERS
-- ========================================
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c3339080-371f-0006-b846-195e8a7129f9',
  'colin.branigan.265404b6@apsl.player',
  'Colin',
  'Branigan',
  crypt('Playerw87xdkgq!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '2e579f16-b693-0006-b0c9-079d7eee97e7',
  'colin.brocksieper.265404b6@apsl.player',
  'Colin',
  'Brocksieper',
  crypt('Player0e6m3xts!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c0c29f9e-d2e7-0006-0341-f1af62179ab5',
  'nick.burkle.265404b6@apsl.player',
  'Nick',
  'Burkle',
  crypt('Playerhahf0wdw!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'fac956dc-b3b0-0006-152c-eea9cd675ad5',
  'rocco.d.arcangelo.265404b6@apsl.player',
  'Rocco',
  'D’Arcangelo',
  crypt('Playerc93hstz5!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'fe449959-47ce-0006-699e-7d492b4164d3',
  'massimo.eichner.265404b6@apsl.player',
  'Massimo',
  'Eichner',
  crypt('Playernd71pizs!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '41076868-69ac-0006-fe1e-dde20908c978',
  'eddy.enowbi.265404b6@apsl.player',
  'Eddy',
  'Enowbi',
  crypt('Playerj18pbvep!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f7879279-e76a-0006-1b99-6e0dea2b2ac2',
  'sean.gannon.265404b6@apsl.player',
  'Sean',
  'Gannon',
  crypt('Playerwkb4cozc!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '51ddf26e-40d9-0006-51d4-de0169d12fa4',
  'andrew.hayden.geres.265404b6@apsl.player',
  'Andrew',
  'Hayden Geres',
  crypt('Playeriz8p3d65!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '3027c9fe-a44c-0006-148f-22936d73fa40',
  'donovan.harris.265404b6@apsl.player',
  'Donovan',
  'Harris',
  crypt('Player1hbk0wlk!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '00a0f3cf-c733-0006-fdac-e8845a36e72f',
  'john.hess.265404b6@apsl.player',
  'John',
  'Hess',
  crypt('Playerwmu1yufj!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '240f84b5-1159-0006-a6c2-01d0ae45db78',
  'jalen.jean.265404b6@apsl.player',
  'Jalen',
  'Jean',
  crypt('Playere0ux2fch!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '8c90360c-5857-0006-5cb4-23328f2cc254',
  'eric.bertin.kalumbwe.265404b6@apsl.player',
  'Eric-Bertin',
  'Kalumbwe',
  crypt('Playerw6u5sju1!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '91bb200c-876d-0006-8db2-7612a79ceb83',
  'sevon.komlan.koudaya.265404b6@apsl.player',
  'Sevon',
  'Komlan Koudaya',
  crypt('Playerak8fyj4q!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '77c86f8e-e67f-0006-2e05-94fce7800388',
  'senan.lonergan.265404b6@apsl.player',
  'Senan',
  'Lonergan',
  crypt('Playerqgcfvwf3!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '13d839d0-f3db-0006-a4c9-939bc6a16dca',
  'luke.mcnabb.265404b6@apsl.player',
  'Luke',
  'McNabb',
  crypt('Playerwdx4vern!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd04bbad1-0262-0006-a99d-8293a5aa5a8e',
  'aidan.nolan.265404b6@apsl.player',
  'Aidan',
  'Nolan',
  crypt('Playergkkxodso!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '6df79880-4a58-0006-0fc7-72b6e3d27d26',
  'aidan.o.brien.265404b6@apsl.player',
  'Aidan',
  'O''Brien',
  crypt('Playergzavxwsz!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f055065a-bae3-0006-d54f-bd44c47a25cd',
  'liam.o.brien.265404b6@apsl.player',
  'Liam',
  'O''Brien',
  crypt('Playerxdpncoyp!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f8266ef4-1b48-0006-859d-55839d40c533',
  'ronan.o.brien.265404b6@apsl.player',
  'Ronan',
  'O''Brien',
  crypt('Player58w3g2hw!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f4452a30-4c56-0006-85d7-c562441ebfbb',
  'marco.parisi.265404b6@apsl.player',
  'Marco',
  'Parisi',
  crypt('Playerca3ey3le!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'bf74a458-0b20-0006-7f1d-88ca87521688',
  'christian.rivas.plata.265404b6@apsl.player',
  'Christian',
  'Rivas-Plata',
  crypt('Playerp056bh0l!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c906d766-3582-0006-bfc5-d4cb05081be9',
  'colm.ryan.265404b6@apsl.player',
  'Colm',
  'Ryan',
  crypt('Playersfcbvtbk!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'da3374b3-4ded-0006-1ddc-d1edd12a847d',
  'ian.slattery.265404b6@apsl.player',
  'Ian',
  'Slattery',
  crypt('Playergz74lw1s!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'df75ca93-0ab5-0006-6ca2-5ff7da31268b',
  'marcris.webb.265404b6@apsl.player',
  'Marcris',
  'Webb',
  crypt('Player7ixjj8a6!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'fb537ad1-6d1e-0006-09f6-5c9adfeb34a3',
  'nick.wlodarcyk.265404b6@apsl.player',
  'Nick',
  'Wlodarcyk',
  crypt('Playeryfcr57er!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Wildcat FC USERS
-- ========================================
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'df5b154f-7409-0006-2e6e-5220e856488f',
  'kaio.ramos.araujo.7f09e1bb@apsl.player',
  'Kaio',
  'Ramos Araujo',
  crypt('Playertydopqcq!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ed98f9fc-45af-0006-0cb0-223ebc6fd69e',
  'luciano.artaza.7f09e1bb@apsl.player',
  'Luciano',
  'Artaza',
  crypt('Player8fypc3ja!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7cff48dd-9993-0006-b922-3c1534a96716',
  'luke.bello.7f09e1bb@apsl.player',
  'Luke',
  'Bello',
  crypt('Player5g0s3c5j!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '290f225e-59ea-0006-0318-eddbe2dfd69c',
  'marc.calle.7f09e1bb@apsl.player',
  'Marc',
  'Calle',
  crypt('Playerr40p8uwr!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '46af404f-4f93-0006-728e-e6e783b7b474',
  'leonardo.da.graca.7f09e1bb@apsl.player',
  'Leonardo',
  'Da Graca',
  crypt('Player220lz35s!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a1c34d59-234a-0006-982a-a093f109a573',
  'ricardo.dias.7f09e1bb@apsl.player',
  'Ricardo',
  'Dias',
  crypt('Player4pa00we8!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'df8c3322-9ddc-0006-f0c2-e144e5587b87',
  'matthew.evora.7f09e1bb@apsl.player',
  'Matthew',
  'Evora',
  crypt('Playero6wuqnzu!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '9e8988b0-f05e-0006-c3b0-8ab21e18b994',
  'anthony.faienza.7f09e1bb@apsl.player',
  'Anthony',
  'Faienza',
  crypt('Playervh2gwifz!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '8bd984ef-793c-0006-a805-60a2c5304b8b',
  'thomas.fernandez.wolff.7f09e1bb@apsl.player',
  'Thomas',
  'Fernandez-Wolff',
  crypt('Player15pqvfhc!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '80f07d6a-da37-0006-8270-8653355dc779',
  'nicholas.fern.ndez.wolff.7f09e1bb@apsl.player',
  'Nicholas',
  'Fernández-Wolff',
  crypt('Playertvdnwym5!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '33c0f5bb-d37b-0006-9af3-9f3d6218c94f',
  'abdulmohaymen.gadoush.7f09e1bb@apsl.player',
  'Abdulmohaymen',
  'Gadoush',
  crypt('Playerxg6qu0bk!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f7b000d3-f1c4-0006-18c2-06c7199ccb6c',
  'eurico.gomes.7f09e1bb@apsl.player',
  'Eurico',
  'Gomes',
  crypt('Playerupf0ohy3!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '9c6781cb-a72c-0006-865d-74275cd19f37',
  'javier.hernandez.7f09e1bb@apsl.player',
  'Javier',
  'Hernandez',
  crypt('Player5xkl6mir!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '82b4490c-a296-0006-1541-c4f1f2ad2b86',
  'joni.kadrioski.7f09e1bb@apsl.player',
  'Joni',
  'Kadrioski',
  crypt('Playermfsjnt21!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '23cad7b2-21f2-0006-beb6-4a7f2d287b32',
  'chavez.mbeki.7f09e1bb@apsl.player',
  'Chavez',
  'Mbeki',
  crypt('Player7sztn1rx!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a95d2c01-6992-0006-ff8b-600b626b5e58',
  'kenan.mujic.7f09e1bb@apsl.player',
  'Kenan',
  'Mujic',
  crypt('Playerdk6z5vqj!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5e2f348b-40d5-0006-3102-0d7f66a5dfc7',
  'ermis.paguada.7f09e1bb@apsl.player',
  'Ermis',
  'Paguada',
  crypt('Player6sms9n8s!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '2ccbb8dd-ea97-0006-57ca-228830624803',
  'paulo.paris.7f09e1bb@apsl.player',
  'Paulo',
  'Paris',
  crypt('Playerkb5i3hvs!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '9da83806-e9a9-0006-77d0-d9b933e9bfdd',
  'juan.saca.7f09e1bb@apsl.player',
  'Juan',
  'Saca',
  crypt('Playerwijo2qxd!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '1c41f6f3-e71c-0006-8abf-8bf33bfeb0cc',
  'bruno.silva.7f09e1bb@apsl.player',
  'Bruno',
  'Silva',
  crypt('Player5wjvyue4!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'abba3694-b109-0006-566e-85a1e07b0ca3',
  'matthew.silva.7f09e1bb@apsl.player',
  'Matthew',
  'Silva',
  crypt('Playern02k3m4m!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a0f021ae-23d3-0006-aeee-013e41a4f19a',
  'michel.souza.7f09e1bb@apsl.player',
  'Michel',
  'Souza',
  crypt('Playerttu5byvp!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '87673440-5c13-0006-764c-1f8feaa7f962',
  'kadin.talho.7f09e1bb@apsl.player',
  'Kadin',
  'Talho',
  crypt('Playergzemisb7!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a6a679f2-9ad4-0006-fcf7-eec486003c80',
  'diego.vasquez.7f09e1bb@apsl.player',
  'Diego',
  'Vasquez',
  crypt('Playerf9oku4w4!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f402abc6-88aa-0006-a225-ba47b179dd9b',
  'jannik.wille.7f09e1bb@apsl.player',
  'Jannik',
  'Wille',
  crypt('Playerszchnrvt!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '60bb5a8c-3549-0006-d8d5-87901d3dcc8b',
  'caleb.wu.7f09e1bb@apsl.player',
  'Caleb',
  'Wu',
  crypt('Playeror0z1xzb!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'cdc01c0d-855f-0006-9bc7-80dc5c6302f8',
  'alan.xavier.7f09e1bb@apsl.player',
  'Alan',
  'Xavier',
  crypt('Playermm97smj9!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Hermandad Connecticut USERS
-- ========================================
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '37887734-1c9e-0006-2a9f-ea4402a033ea',
  'bright.agyemang.5c979af3@apsl.player',
  'Bright',
  'Agyemang',
  crypt('Playerrdwehdbh!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '2c1274f4-35c4-0006-9927-edb92f123fec',
  'wander.alves.5c979af3@apsl.player',
  'Wander',
  'Alves',
  crypt('Playerocjkfhz8!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b6ad791d-c033-0006-c6bc-42b641d90681',
  'guilherme.andrade.5c979af3@apsl.player',
  'Guilherme',
  'Andrade',
  crypt('Player0kef3qy7!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '6d21bfe3-90d9-0006-409a-dce7d26f0992',
  'hayllan.batista.5c979af3@apsl.player',
  'Hayllan',
  'Batista',
  crypt('Playerf44wxjeh!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '141b275f-f275-0006-08be-5d3104d7e115',
  'gabriel.berthoud.5c979af3@apsl.player',
  'Gabriel',
  'Berthoud',
  crypt('Player5zkvdgae!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '481d1f8b-a183-0006-b1d2-070a083d5af1',
  'gabriel.carrelo.5c979af3@apsl.player',
  'Gabriel',
  'Carrelo',
  crypt('Playerbgqhx5e2!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '87b316fb-5f4c-0006-5da8-083ad5676203',
  'rodney.delgado.5c979af3@apsl.player',
  'Rodney',
  'Delgado',
  crypt('Playervd07ttk6!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'af9832ff-88e9-0006-662b-469af229cf59',
  'gregorio.espinoza.5c979af3@apsl.player',
  'Gregorio',
  'Espinoza',
  crypt('Playerine2sru0!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'dbc9f3e6-fa84-0006-cc5d-5d8b35b2fb03',
  'wilmer.flores.5c979af3@apsl.player',
  'Wilmer',
  'Flores',
  crypt('Player5e0xpm9a!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '938d0a54-db68-0006-74bd-7c4b37323ad5',
  'zouhair.khal.5c979af3@apsl.player',
  'Zouhair',
  'Khal',
  crypt('Playerl10tsziz!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5d7e9ac2-9e17-0006-eeca-6764ca4395b0',
  'shamar.j.kingston.5c979af3@apsl.player',
  'Shamar',
  'J Kingston',
  crypt('Playere7ltspc7!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '09e4ba92-944c-0006-ef6f-2f4a54583d93',
  'bruno.luiz.5c979af3@apsl.player',
  'Bruno',
  'Luiz',
  crypt('Player8skvwy4r!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '0978b528-8643-0006-d96b-e6d4ecced09c',
  'colton.lukuc.5c979af3@apsl.player',
  'Colton',
  'Lukuc',
  crypt('Playerrzqaclsq!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '8adf97db-d8d4-0006-a68b-b687f5009701',
  'abdessamad.machi.5c979af3@apsl.player',
  'Abdessamad',
  'Machi',
  crypt('Playermcz64yk6!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ffda714f-7247-0006-d86a-769e482cfce4',
  'david.mollenthiel.5c979af3@apsl.player',
  'David',
  'Mollenthiel',
  crypt('Playerze2825x3!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e52b0058-1362-0006-73ce-fad00c2ce970',
  'phila.nxumalo.5c979af3@apsl.player',
  'Phila',
  'Nxumalo',
  crypt('Playernkoo3l9b!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '65ede4cb-28c0-0006-b2bc-f58d518e479b',
  'johan.pineda.5c979af3@apsl.player',
  'Johan',
  'Pineda',
  crypt('Player2zq2bjdh!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '756a1940-6a88-0006-c40f-e403f8dad736',
  'patrick.pineda.5c979af3@apsl.player',
  'Patrick',
  'Pineda',
  crypt('Playerjvq3g0pz!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '763f3b0b-ede4-0006-4a23-2068df5686fa',
  'andrew.ranieri.5c979af3@apsl.player',
  'Andrew',
  'Ranieri',
  crypt('Player4jldvgx1!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e849dbbe-14a5-0006-de04-028a01a21dce',
  'anthony.ranieri.5c979af3@apsl.player',
  'Anthony',
  'Ranieri',
  crypt('Playeryetavns6!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '63952863-ed62-0006-719b-1e1658d07bec',
  'steven.rivera.5c979af3@apsl.player',
  'Steven',
  'Rivera',
  crypt('Playerator4wm5!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '6584e60d-7170-0006-eb1c-1db9bff85c20',
  'maynor.robles.5c979af3@apsl.player',
  'Maynor',
  'Robles',
  crypt('Playeriq60aoqj!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ca77f3b9-8757-0006-d381-c497f6b5ec1c',
  'michael.rodriguez.5c979af3@apsl.player',
  'Michael',
  'Rodriguez',
  crypt('Playerolxua83x!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '9f25fe99-fe02-0006-dc3b-11426a5d14f7',
  'walter.romero.5c979af3@apsl.player',
  'Walter',
  'Romero',
  crypt('Playeriylc3lwq!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '084a82e2-1cd3-0006-4ab1-f6199d988008',
  'edwin.rosano.5c979af3@apsl.player',
  'Edwin',
  'Rosano',
  crypt('Playeru5wop9qs!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '9940e7a1-906a-0006-4126-9668daa86be8',
  'bairon.tejada.5c979af3@apsl.player',
  'Bairon',
  'Tejada',
  crypt('Playerdua2l79b!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '9bd30a1f-a719-0006-5c63-13cadb08e706',
  'diego.vega.toledo.5c979af3@apsl.player',
  'Diego',
  'Vega Toledo',
  crypt('Playerl0y8vsrr!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '64946898-0458-0006-35d0-ca2b76486505',
  'oscar.eduardo.velasquez.centeno.5c979af3@apsl.player',
  'Oscar',
  'Eduardo Velasquez Centeno',
  crypt('Playercri5lt4y!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a6e03e26-3e59-0006-041d-4156de289f32',
  'anderson.velez.5c979af3@apsl.player',
  'Anderson',
  'Velez',
  crypt('Playerge3di4k7!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'cbfd2ed9-308f-0006-b0ea-0b84f3095327',
  'tristan.vincent.5c979af3@apsl.player',
  'Tristan',
  'Vincent',
  crypt('Playerexoizwup!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'cd839d32-0465-0006-8865-a353942547c8',
  'tyler.wrenn.5c979af3@apsl.player',
  'Tyler',
  'Wrenn',
  crypt('Playerve68yhk9!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '2f187c1a-669a-0006-0753-18c18c70c0a9',
  'javier.yanez.5c979af3@apsl.player',
  'Javier',
  'Yanez',
  crypt('Player4b2tm75a!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- NY Greek Americans USERS
-- ========================================
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '301196cc-85f6-0006-46aa-3fdf9b6ca61f',
  'hermanus.achterkamp.a9e2b1a8@apsl.player',
  'Hermanus',
  'Achterkamp',
  crypt('Playerhv0f99p4!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c32b2e33-3e0e-0006-defa-e19017caee35',
  'christopher.diego.anderson.a9e2b1a8@apsl.player',
  'Christopher',
  'Diego Anderson',
  crypt('Playerc6qykou6!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'be39983a-d3ce-0006-9c69-32c274a01322',
  'daniel.bedoya.a9e2b1a8@apsl.player',
  'Daniel',
  'Bedoya',
  crypt('Playerpsx0jqy6!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c339a18b-6b92-0006-9352-0ffca788db0f',
  'etienne.botty.a9e2b1a8@apsl.player',
  'Etienne',
  'Botty',
  crypt('Playermab8gmvu!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'aa2b3a30-9783-0006-3012-c96de69bf414',
  'francesco.caorsi.a9e2b1a8@apsl.player',
  'Francesco',
  'Caorsi',
  crypt('Playerd8l94zuj!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a461ba94-9d65-0006-98fb-d0616298ee94',
  'roc.carles.puig.a9e2b1a8@apsl.player',
  'Roc',
  'Carles Puig',
  crypt('Playerb2onvpg4!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e0447b79-71f8-0006-1f44-1048e4e1c030',
  'myson.colo.a9e2b1a8@apsl.player',
  'Myson',
  'Colo',
  crypt('Playerem44j2fg!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c72e17a8-0705-0006-c881-cc11c1b5894e',
  'rodrigo.descalzo.rocca.a9e2b1a8@apsl.player',
  'Rodrigo',
  'Descalzo Rocca',
  crypt('Player0nlrqm3r!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '8ff592e8-588d-0006-333d-e751e33c7887',
  'miguel.mauricio.diaz.cubas.a9e2b1a8@apsl.player',
  'Miguel',
  'Mauricio Diaz Cubas',
  crypt('Playercabp76u0!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '0b9b759a-2039-0006-e0f1-a134ab519a8a',
  'timothy.joseph.gallagher.de.meij.a9e2b1a8@apsl.player',
  'Timothy',
  'Joseph Gallagher-De Meij',
  crypt('Player0tr5cy74!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ba2dd9ea-4e93-0006-1076-f501632aac0f',
  'miguel.soto.gonzalez.a9e2b1a8@apsl.player',
  'Miguel',
  'Soto Gonzalez',
  crypt('Playerdvtf18n4!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '8333d962-2e91-0006-ddd2-de335577c25c',
  'adam.marcu.a9e2b1a8@apsl.player',
  'Adam',
  'Marcu',
  crypt('Playerwqfonxzu!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '3f39782c-0495-0006-fbf6-3934468be92e',
  'patrick.mccann.a9e2b1a8@apsl.player',
  'Patrick',
  'McCann',
  crypt('Playerc8oeivkr!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '305f9af7-7a9f-0006-e22f-ae7bd9172048',
  'paul.mcveigh.a9e2b1a8@apsl.player',
  'Paul',
  'McVeigh',
  crypt('Player1e2bitq2!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f9d3f733-fd4b-0006-70a6-0ce9b4f7e95c',
  'james.nealis.a9e2b1a8@apsl.player',
  'James',
  'Nealis',
  crypt('Playereeqwwue0!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c0042e32-75ba-0006-78fa-456d5779221f',
  'jack.o.malley.a9e2b1a8@apsl.player',
  'Jack',
  'O''Malley',
  crypt('Playerigfw7ugb!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '9b22def6-74f1-0006-6d08-1699cd51fd91',
  'george.o.malley.a9e2b1a8@apsl.player',
  'George',
  'O`Malley',
  crypt('Playere81rmecz!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e4c8d49f-b0c4-0006-d2e4-f419788dae13',
  'nicholas.oberrauch.a9e2b1a8@apsl.player',
  'Nicholas',
  'Oberrauch',
  crypt('Player0obf6dx0!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a06987e3-0303-0006-6868-acecdef7ba3d',
  'alberto.pangrazzi.a9e2b1a8@apsl.player',
  'Alberto',
  'Pangrazzi',
  crypt('Playertmix3zi3!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'fe81d03e-69ca-0006-cd96-7f80fc1497ca',
  'francesco.perinelli.a9e2b1a8@apsl.player',
  'Francesco',
  'Perinelli',
  crypt('Playerf5map1bk!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a1731888-6639-0006-b7ec-68f8ca919f85',
  'nicholas.petridis.a9e2b1a8@apsl.player',
  'Nicholas',
  'Petridis',
  crypt('Player3lkzc9h3!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '9495766c-4298-0006-3f17-da33fafaed51',
  'cormac.pike.a9e2b1a8@apsl.player',
  'Cormac',
  'Pike',
  crypt('Playerfm3pv5dl!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c837a663-b04d-0006-45b3-df013bd682b2',
  'saeed.robinson.a9e2b1a8@apsl.player',
  'Saeed',
  'Robinson',
  crypt('Player77ms60sb!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '52e3b16a-8058-0006-d8cd-a2675e5cb7c3',
  'john.sabal.a9e2b1a8@apsl.player',
  'John',
  'Sabal',
  crypt('Player2q17cyof!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ba2d6091-0a3f-0006-db9f-ac243be4023d',
  'brian.sousa.saramago.a9e2b1a8@apsl.player',
  'Brian',
  'Sousa Saramago',
  crypt('Playerlopo4w3m!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '360fc8da-30d7-0006-df1d-2e4e1d1582d6',
  'elijah.george.sawyers.a9e2b1a8@apsl.player',
  'Elijah',
  'George Sawyers',
  crypt('Playerx2amyrh7!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '12cb46f3-5dd0-0006-4b3a-766d1902670e',
  'joshua.schaffer.a9e2b1a8@apsl.player',
  'Joshua',
  'Schaffer',
  crypt('Playerohdfi34n!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '55c03c6e-182b-0006-b9b8-d22d982ac4a1',
  'barakatulla.sharifi.a9e2b1a8@apsl.player',
  'Barakatulla',
  'Sharifi',
  crypt('Playerii41twmk!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f83a32f0-758f-0006-98cf-52ea4b6774ed',
  'yacine.sidi.aissa.a9e2b1a8@apsl.player',
  'Yacine',
  'Sidi Aissa',
  crypt('Playerh0upagep!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '1d7bb63d-1131-0006-4dac-9ef5900a4ea3',
  'carl.viggo.sjoberg.a9e2b1a8@apsl.player',
  'Carl',
  'Viggo Sjoberg',
  crypt('Playernasys1fe!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a101716d-dd0e-0006-511c-13e7829942f8',
  'leo.wei.pinto.a9e2b1a8@apsl.player',
  'Leo',
  'Wei Pinto',
  crypt('Playerzzr52fyb!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '17f5e376-b286-0006-7f0f-c432d68ad3af',
  'joseph.wright.a9e2b1a8@apsl.player',
  'Joseph',
  'Wright',
  crypt('Playerxmyftxls!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'fa28096f-ce43-0006-25e3-e703808e45d5',
  'el.mahdi.youssoufi.a9e2b1a8@apsl.player',
  'El',
  'Mahdi Youssoufi',
  crypt('Playerm9s7wgky!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Hoboken FC 1912 USERS
-- ========================================
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7d34d8bc-79c9-0006-0ca7-da9e5e7098cd',
  'santiago.arroyave.49df0225@apsl.player',
  'Santiago',
  'Arroyave',
  crypt('Player8ctekjah!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '776ac1ef-e719-0006-392f-6f3018ffa05a',
  'tristan.barquin.49df0225@apsl.player',
  'Tristan',
  'Barquin',
  crypt('Playern3iguhuh!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'dc59256f-e35f-0006-14a7-28bce22acbdc',
  'ethan.bazan.49df0225@apsl.player',
  'Ethan',
  'Bazan',
  crypt('Playervsrmu57c!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '1b6d8052-5f37-0006-b5c4-e84efa7ee1c8',
  'steven.bednarsky.49df0225@apsl.player',
  'Steven',
  'Bednarsky',
  crypt('Playerr3q3clea!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '49fa6860-fa1e-0006-6a87-21cc547b7d2e',
  'isimohi.mike.bello.49df0225@apsl.player',
  'Isimohi',
  'Mike Bello',
  crypt('Playerg8p04mnj!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c07df1fb-6f49-0006-be75-510b4083549e',
  'kouadio.bolaty.49df0225@apsl.player',
  'Kouadio',
  'Bolaty',
  crypt('Playerw1y8miyn!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a505ea71-79e5-0006-a589-e2ef4dce5622',
  'andrew.bortey.49df0225@apsl.player',
  'Andrew',
  'Bortey',
  crypt('Playere8s3jd16!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '9b529b5d-9eaa-0006-ab8b-d899f0365ee2',
  'kelvin.brito.49df0225@apsl.player',
  'Kelvin',
  'Brito',
  crypt('Playerga71nf9w!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '3c9e3d11-7853-0006-1f0c-babcb15d5ed3',
  'dorgeles.coulibaly.49df0225@apsl.player',
  'Dorgeles',
  'Coulibaly',
  crypt('Playerrpegamoy!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e2632be1-c983-0006-e4ec-ac4f5123a3f1',
  'tyler.diaz.49df0225@apsl.player',
  'Tyler',
  'Diaz',
  crypt('Player76cic6iq!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b2bbc4d6-6654-0006-0880-a3b79927b1de',
  'samuel.epitime.49df0225@apsl.player',
  'Samuel',
  'Epitime',
  crypt('Playerwsd3e8l1!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '59e8261d-3426-0006-03e5-b19fae529f67',
  'adam.garner.49df0225@apsl.player',
  'Adam',
  'Garner',
  crypt('Playero7k3vgtb!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c4cca3e3-1ecd-0006-ed84-e2a4962ab429',
  'matthew.gotrell.49df0225@apsl.player',
  'Matthew',
  'Gotrell',
  crypt('Playerss2myqzp!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '6de1c4f9-94bd-0006-0a3a-505ef7ae6e5a',
  'ivan.enrique.hurtado.49df0225@apsl.player',
  'Ivan',
  'Enrique Hurtado',
  crypt('Player8fndivi1!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '2d9e0689-418a-0006-4841-4e2f14c33289',
  'stefan.koroman.49df0225@apsl.player',
  'Stefan',
  'Koroman',
  crypt('Player3dcaqs84!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7851e92c-264b-0006-aba3-b728ae6dfc82',
  'keeroy.lionel.49df0225@apsl.player',
  'Keeroy',
  'Lionel',
  crypt('Playerolnxi4pv!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '836c656f-c985-0006-3268-260d1aac7afd',
  'yamil.macias.49df0225@apsl.player',
  'Yamil',
  'Macias',
  crypt('Playerqtuht8lp!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '1eeb8012-e8ea-0006-40bc-992347b04575',
  'cameron.mcgregor.49df0225@apsl.player',
  'Cameron',
  'McGregor',
  crypt('Playerbinsru7q!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd4573209-6662-0006-05a0-7130381b62a4',
  'coby.mcgregor.49df0225@apsl.player',
  'Coby',
  'Mcgregor',
  crypt('Player57c0dzw3!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'bb857711-8f53-0006-7820-47f2c5cacb02',
  'joseph.moon.49df0225@apsl.player',
  'Joseph',
  'Moon',
  crypt('Player0tid0vam!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '82e727f0-f912-0006-af62-6bd3b076f113',
  'israel.neto.49df0225@apsl.player',
  'Israel',
  'Neto',
  crypt('Playerptw8ru40!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '37d5e396-215d-0006-004a-94246c0a5144',
  'abdoul.ouedraogo.49df0225@apsl.player',
  'Abdoul',
  'Ouedraogo',
  crypt('Playerg9tt2mbn!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '14ef5b9c-c20d-0006-b86d-084bbb0e58cd',
  'brian.paredes.49df0225@apsl.player',
  'Brian',
  'Paredes',
  crypt('Player204qe7cw!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'da967792-2afb-0006-63e7-e8d522725a17',
  'jung.park.49df0225@apsl.player',
  'Jung',
  'Park',
  crypt('Player9x0ybl43!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b28c2d64-6759-0006-189a-b7c9f1e31487',
  'ewan.sanchez.49df0225@apsl.player',
  'Ewan',
  'Sanchez',
  crypt('Playerz71yfg4o!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '66d5082d-9c7c-0006-e276-95bafed41de7',
  'jossimar.sanchez.49df0225@apsl.player',
  'Jossimar',
  'Sanchez',
  crypt('Player2w0xdzyu!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e788aa21-dddc-0006-8a72-79cd47baf379',
  'kevin.santamaria.49df0225@apsl.player',
  'Kevin',
  'Santamaria',
  crypt('Playerpev05dhi!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a85fbe60-64e9-0006-05c3-ebce0212c4b5',
  'rodrigo.santiago.49df0225@apsl.player',
  'Rodrigo',
  'Santiago',
  crypt('Playerzytvrj9o!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c244669f-3d2a-0006-b722-121835bd745b',
  'luc.smith.49df0225@apsl.player',
  'Luc',
  'Smith',
  crypt('Player3tg2klg4!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '16c7bd74-ccdb-0006-a2ff-6dcffd12b32d',
  'ramchwy.st.vil.49df0225@apsl.player',
  'Ramchwy',
  'St Vil',
  crypt('Playerwdh9f00d!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c6d4a358-0660-0006-1e0a-20f8f92754e4',
  'mohamed.tall.49df0225@apsl.player',
  'Mohamed',
  'Tall',
  crypt('Playerh9voixev!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '0220f79d-d177-0006-1d33-498fa52c6485',
  'christian.villegas.libreros.49df0225@apsl.player',
  'Christian',
  'Villegas Libreros',
  crypt('Playerqiqteifi!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'bc8312ea-2301-0006-3e60-14898c745702',
  'andrew.weiner.49df0225@apsl.player',
  'Andrew',
  'Weiner',
  crypt('Playeru7lll70j!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- NY Pancyprian Freedoms USERS
-- ========================================
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ad95defb-0e84-0006-1f5d-01700a7f7d39',
  'pablo.ablanedo.llaneza.cd0f7cdf@apsl.player',
  'Pablo',
  'Ablanedo Llaneza',
  crypt('Playerosq0ades!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '0b9f6a24-f6d0-0006-927e-3a09b6633c9a',
  'jordan.bailon.cd0f7cdf@apsl.player',
  'Jordan',
  'Bailon',
  crypt('Playeruw23oaxv!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ca9319b0-6b21-0006-e70c-ad5a74350686',
  'filip.basili.cd0f7cdf@apsl.player',
  'Filip',
  'Basili',
  crypt('Playeruk6ii6w2!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '8d84cee1-a81b-0006-1981-af5d5556e1c7',
  'christopher.bermudez.cd0f7cdf@apsl.player',
  'Christopher',
  'Bermudez',
  crypt('Playerqzy7h3gy!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '9f0d6c6e-1a3c-0006-e375-a79fe5238b21',
  'victor.castel.cd0f7cdf@apsl.player',
  'Victor',
  'Castel',
  crypt('Playerldldqi6o!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7f28b126-0afc-0006-71b8-cbc6f9f0ac78',
  'rikard.cederberg.cd0f7cdf@apsl.player',
  'Rikard',
  'Cederberg',
  crypt('Playerlq7w51l1!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd149f49b-acc5-0006-2c7c-eb2074be7674',
  'nicolas.cifuentes.diaz.cd0f7cdf@apsl.player',
  'Nicolas',
  'Cifuentes DIaz',
  crypt('Player0hss0o7c!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '375d9aff-512e-0006-9d11-705d57b38f2c',
  'davide.clarkson.cd0f7cdf@apsl.player',
  'Davide',
  'Clarkson',
  crypt('Playerp27zfqa5!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '2a9d2882-1fba-0006-a423-f0addab7b5be',
  'sergio.diaz.cd0f7cdf@apsl.player',
  'Sergio',
  'Diaz',
  crypt('Playerjpd85f8u!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '0cd0b9b4-7a59-0006-bf55-9fe2f7b63d74',
  'eric.frimpong.cd0f7cdf@apsl.player',
  'Eric',
  'Frimpong',
  crypt('Playerswlrve3l!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '0a912565-84ec-0006-d1c3-e33df55ab126',
  'george.gantalis.cd0f7cdf@apsl.player',
  'George',
  'Gantalis',
  crypt('Player2stnuasn!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '269a1762-04e0-0006-9e08-cc7f73150dae',
  'jose.gil.mejia.cd0f7cdf@apsl.player',
  'Jose',
  'Gil Mejia',
  crypt('Playero2wdgo0d!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'de85cb97-a39a-0006-04de-e4895788f723',
  'ede.mateo.gramberg.cd0f7cdf@apsl.player',
  'Ede',
  'Mateo Gramberg',
  crypt('Playerle41bj7s!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7b22c55c-b1dc-0006-d308-fdeabb970179',
  'thomas.gray.cd0f7cdf@apsl.player',
  'Thomas',
  'Gray',
  crypt('Player2716klc1!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c4e6b96e-ed58-0006-d9cb-06c2ac156021',
  'antreas.hadjigavriel.cd0f7cdf@apsl.player',
  'Antreas',
  'Hadjigavriel',
  crypt('Playergwhz8kv0!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e617b3b8-f880-0006-1cae-01ab200de6d8',
  'devin.heanue.cd0f7cdf@apsl.player',
  'Devin',
  'Heanue',
  crypt('Playerbfj0pfbx!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '10ba9b74-a1b3-0006-a65f-c8d6498e0e22',
  'kevin.hernandez.cd0f7cdf@apsl.player',
  'Kevin',
  'Hernandez',
  crypt('Playeri9bir6nk!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'aa860b38-a098-0006-ae66-66d4c5dbe941',
  'jens.mannhart.hoff.cd0f7cdf@apsl.player',
  'Jens',
  'Mannhart Hoff',
  crypt('Player98oh78nu!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd6cdd6ad-4891-0006-7814-665e6c6fcd4f',
  'joseph.holland.cd0f7cdf@apsl.player',
  'Joseph',
  'Holland',
  crypt('Playercoe5fyh2!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '9812044e-02b4-0006-f0df-fc72fb89b3dd',
  'filip.jauk.cd0f7cdf@apsl.player',
  'Filip',
  'Jauk',
  crypt('Playerwu8zbeir!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '233f1298-8ddb-0006-74d3-74647a81d1f0',
  'soren.jensen.cd0f7cdf@apsl.player',
  'Soren',
  'Jensen',
  crypt('Player7xrlf7ae!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd3804ae3-e7d1-0006-c3b9-8fb7248015c7',
  'konstantinos.karousis.cd0f7cdf@apsl.player',
  'Konstantinos',
  'Karousis',
  crypt('Playerw1rmxmme!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '3653f472-7432-0006-739a-5b47b8569883',
  'connor.kelly.cd0f7cdf@apsl.player',
  'Connor',
  'Kelly',
  crypt('Player9jw776f7!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '0e410dd4-6f65-0006-b6ee-75a2056d1964',
  'benny.lafortune.cd0f7cdf@apsl.player',
  'Benny',
  'Lafortune',
  crypt('Playern26iwhrr!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '36a0fa14-0977-0006-a6a1-ce6c0722f049',
  'joshua.levine.cd0f7cdf@apsl.player',
  'Joshua',
  'Levine',
  crypt('Playermzgmdkhm!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e6d97a8a-7919-0006-e19e-b468acb0046a',
  'juan.martinez.moreno.cd0f7cdf@apsl.player',
  'Juan',
  'Martinez Moreno',
  crypt('Playertm9fjs7z!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '843caf24-a2a3-0006-000b-e7d1b47bfdea',
  'filip.mirkovic.cd0f7cdf@apsl.player',
  'Filip',
  'Mirkovic',
  crypt('Playerwkbs53k5!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd8bf5fa7-6122-0006-8719-4e35e266f779',
  'christoforos.moulinos.cd0f7cdf@apsl.player',
  'Christoforos',
  'Moulinos',
  crypt('Player2iewl80t!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a1d91af4-baf6-0006-21b8-e578411a9741',
  'stephen.o.connell.cd0f7cdf@apsl.player',
  'Stephen',
  'O’ Connell',
  crypt('Playerj8igd40p!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '2b2cfb6b-fefa-0006-1d4c-00ebdad5c0f1',
  'alex.palas.cd0f7cdf@apsl.player',
  'Alex',
  'Palas',
  crypt('Playerrfjzt3az!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '71a41f70-ae60-0006-9b7a-2ab4a48b664c',
  'sebastian.ruiz.cd0f7cdf@apsl.player',
  'Sebastian',
  'Ruiz',
  crypt('Playermbtnjdu8!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'fa6ef07f-217e-0006-3d14-934fa4e539d5',
  'athanasis.shehadeh.cd0f7cdf@apsl.player',
  'Athanasis',
  'Shehadeh',
  crypt('Player9nm8xy6d!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '439f4875-fe30-0006-6033-eceda3120c9c',
  'jack.sluys.cd0f7cdf@apsl.player',
  'Jack',
  'Sluys',
  crypt('Playerjxdy3e2l!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '84f23cf4-c102-0006-6e4e-021e447badea',
  'james.thristino.cd0f7cdf@apsl.player',
  'James',
  'Thristino',
  crypt('Playererfs5801!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '59f47a10-9f5d-0006-3980-2cf779b8e785',
  'sean.towey.cd0f7cdf@apsl.player',
  'Sean',
  'Towey',
  crypt('Playerftuha0ct!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Lansdowne Yonkers FC USERS
-- ========================================
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '59993596-e37e-0006-eb45-ce2067821294',
  'john.bernardi.fd2f4fc8@apsl.player',
  'John',
  'Bernardi',
  crypt('Playerdmv7t3ws!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '8151f31a-42d3-0006-84c3-16e1657f1ee6',
  'james.peter.boote.fd2f4fc8@apsl.player',
  'James',
  'Peter Boote',
  crypt('Playero4iwp0i4!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '542c61bf-23cc-0006-5b9b-9e47513f06ef',
  'aidan.borra.fd2f4fc8@apsl.player',
  'Aidan',
  'Borra',
  crypt('Player8r3ervsp!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '8c5f2aaf-060f-0006-ca44-bc11978ad32f',
  'tajee.campbell.fd2f4fc8@apsl.player',
  'Tajee',
  'Campbell',
  crypt('Playern27966cl!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '1f80a10c-2dbb-0006-f563-1fcb5f80c6f6',
  'marco.charnas.fd2f4fc8@apsl.player',
  'Marco',
  'Charnas',
  crypt('Players9vf4b9f!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '324477f5-4b71-0006-c97d-33ec70b6f835',
  'constantine.christodoulou.fd2f4fc8@apsl.player',
  'Constantine',
  'Christodoulou',
  crypt('Playerk767phl3!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '8f87a43e-a21b-0006-0f9e-0e6341598a27',
  'stefan.copetti.fd2f4fc8@apsl.player',
  'Stefan',
  'Copetti',
  crypt('Player87vz7es3!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '0a26b622-a633-0006-aeea-d25be4cce5d1',
  'carlos.cortes.fd2f4fc8@apsl.player',
  'Carlos',
  'Cortes',
  crypt('Playerk2i2y595!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '8aef3fbf-5667-0006-a7d8-4f2ea899ebc6',
  'musa.bala.danso.fd2f4fc8@apsl.player',
  'Musa',
  'Bala Danso',
  crypt('Playerhlvox2ks!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '0fa8333c-30ca-0006-a175-a4baa2c2d7a3',
  'ali.dawha.fd2f4fc8@apsl.player',
  'Ali',
  'Dawha',
  crypt('Player1hxw1itw!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '0a77640d-8df1-0006-4871-8519314a2fe7',
  'daniel.dimarco.fd2f4fc8@apsl.player',
  'Daniel',
  'Dimarco',
  crypt('Playerkdumgylx!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '4b5c2ad0-c1fa-0006-8023-bf505cf2dae0',
  'sean.doran.fd2f4fc8@apsl.player',
  'Sean',
  'Doran',
  crypt('Playergfl24fae!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '9528e132-5250-0006-8e6f-7ea8894ba9ac',
  'dino.feratovic.fd2f4fc8@apsl.player',
  'Dino',
  'Feratovic',
  crypt('Playersrutkli1!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '41a442f6-c9b1-0006-bedc-940830335d05',
  'ethan.furphy.fd2f4fc8@apsl.player',
  'Ethan',
  'Furphy',
  crypt('Playerjs62mzkg!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ea04ced7-5034-0006-0f54-e769b07caf06',
  'michael.gallagher.fd2f4fc8@apsl.player',
  'Michael',
  'Gallagher',
  crypt('Playeryttc2w04!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'fbeba52d-c0ef-0006-bd13-ac959470c068',
  'kyle.galloway.fd2f4fc8@apsl.player',
  'Kyle',
  'Galloway',
  crypt('Playerzn6f5vmf!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f64b0b59-376d-0006-9d9f-25ba56d0af6b',
  'cillian.heaney.fd2f4fc8@apsl.player',
  'Cillian',
  'Heaney',
  crypt('Playerj86kvv3f!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f2930979-f5b3-0006-265e-136e45b28d1d',
  'michael.hewes.fd2f4fc8@apsl.player',
  'Michael',
  'Hewes',
  crypt('Playeryyrm33gk!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '15eaa056-d846-0006-9c0f-175666a4fd1a',
  'ethan.homler.fd2f4fc8@apsl.player',
  'Ethan',
  'Homler',
  crypt('Player79gzuqxn!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'eb1412c8-e287-0006-4e93-303dd7c39dec',
  'jared.juleau.fd2f4fc8@apsl.player',
  'Jared',
  'Juleau',
  crypt('Playerwv3nllw3!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '40702513-5295-0006-a8c7-5d74accaee01',
  'andy.kasza.fd2f4fc8@apsl.player',
  'Andy',
  'Kasza',
  crypt('Playerhs9s1523!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '889220c7-9111-0006-3b6d-83cacc26c343',
  'daryl.kavanagh.fd2f4fc8@apsl.player',
  'Daryl',
  'Kavanagh',
  crypt('Playerg6bgdb8e!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '49b2014d-cea6-0006-d060-8911a5d1ef78',
  'seamus.keogh.fd2f4fc8@apsl.player',
  'Seamus',
  'Keogh',
  crypt('Player5obq3ilh!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a793c8b6-ceae-0006-7a5c-bb1e984a89ac',
  'sean.kerrigan.fd2f4fc8@apsl.player',
  'Sean',
  'Kerrigan',
  crypt('Playerbgv7b2jo!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '85ed3843-48b3-0006-8f5d-13e45c73c4fb',
  'danu.kinsella.bishop.fd2f4fc8@apsl.player',
  'Danu',
  'Kinsella-Bishop',
  crypt('Playerk3po2c5y!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'cce91945-afd7-0006-7554-2810eef95e96',
  'nicolas.macri.badessich.fd2f4fc8@apsl.player',
  'Nicolas',
  'Macri Badessich',
  crypt('Playerl6gb5nh0!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '55c93f52-566a-0006-fe47-e093a3f91c8d',
  'malcolm.moreno.fd2f4fc8@apsl.player',
  'Malcolm',
  'Moreno',
  crypt('Playerxi5so72u!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '1f53cfbb-7254-0006-61a5-d57a93d42ed4',
  'luis.puchol.del.pozo.fd2f4fc8@apsl.player',
  'Luis',
  'Puchol Del Pozo',
  crypt('Playeri15qaebo!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f713870a-4ee0-0006-36fe-30cace47d5d5',
  'sebastian.rojek.fd2f4fc8@apsl.player',
  'Sebastian',
  'Rojek',
  crypt('Player2vnnew2h!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '6fb5e046-e079-0006-ed16-e5ff4f7e1ad7',
  'liam.salmon.fd2f4fc8@apsl.player',
  'Liam',
  'Salmon',
  crypt('Playertbs7q0s5!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '86b76e74-2a1b-0006-5819-f17fcc240b4c',
  'harry.sankey.fd2f4fc8@apsl.player',
  'Harry',
  'Sankey',
  crypt('Playerv62is4qe!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '42f7c932-6f92-0006-3527-d6b4f16a1708',
  'edward.speed.fd2f4fc8@apsl.player',
  'Edward',
  'Speed',
  crypt('Playerhdw6s2n6!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5d719a69-2fc5-0006-b01c-84d4449c7493',
  'benjamin.stitz.fd2f4fc8@apsl.player',
  'Benjamin',
  'Stitz',
  crypt('Player2wnuiztz!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '75854c8a-34e5-0006-def8-40f438cd0ad0',
  'liam.walsh.fd2f4fc8@apsl.player',
  'Liam',
  'Walsh',
  crypt('Playerxzwlcaah!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b0f0e842-7fd5-0006-f8a2-653ed9376c3a',
  'oskar.zywiec.fd2f4fc8@apsl.player',
  'Oskar',
  'Zywiec',
  crypt('Player1gyrlweb!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Leros SC USERS
-- ========================================
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '414f2572-fddf-0006-3a45-d6ee22d678c4',
  'keirol.aaron.77717fe0@apsl.player',
  'Keirol',
  'Aaron',
  crypt('Players1l6zpoz!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '65464fd3-4a6e-0006-6f38-22d9d1881c9b',
  'matthais.adamek.77717fe0@apsl.player',
  'Matthais',
  'Adamek',
  crypt('Playeriosub68n!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e978ab5e-a1c0-0006-d059-3e564e18b1fb',
  'yohance.alexander.77717fe0@apsl.player',
  'Yohance',
  'Alexander',
  crypt('Player5yzbq68i!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '381f3765-2083-0006-6f4d-3841bd909aba',
  'andrea.andreou.77717fe0@apsl.player',
  'Andrea',
  'Andreou',
  crypt('Player6jlf9xw7!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '85224882-93cb-0006-6634-9f484cd2da58',
  'luis.argudo.77717fe0@apsl.player',
  'Luis',
  'Argudo',
  crypt('Player2476sj6p!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'be8d6c47-4e8a-0006-a5ad-6ad150cdcdcf',
  'theodore.bernhard.77717fe0@apsl.player',
  'Theodore',
  'Bernhard',
  crypt('Playerzpmqm70m!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5007e41e-9ba6-0006-ce0f-877f8a328038',
  'antonio.biggs.77717fe0@apsl.player',
  'Antonio',
  'Biggs',
  crypt('Playerlctg2ycp!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '9d0729d8-ab23-0006-dcac-13b89a78b448',
  'mason.chetti.77717fe0@apsl.player',
  'Mason',
  'Chetti',
  crypt('Playera8e2iixu!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd64244a7-ce94-0006-0005-ed6ebe4cb28d',
  'jarvis.cleal.77717fe0@apsl.player',
  'Jarvis',
  'Cleal',
  crypt('Playerml4s8pcf!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f197bffc-ca2a-0006-2730-7acf60e6aa26',
  'joel.cunningham.77717fe0@apsl.player',
  'Joel',
  'Cunningham',
  crypt('Playerxhfieb42!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '617414fa-4c77-0006-3d61-94cb8986268b',
  'caleb.danquah.77717fe0@apsl.player',
  'Caleb',
  'Danquah',
  crypt('Playerq6xuba94!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '13d66bb3-8fe8-0006-04f8-7028251009c9',
  'eric.danquah.77717fe0@apsl.player',
  'Eric',
  'Danquah',
  crypt('Player05gv9d7h!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '49f6aa3a-3ab0-0006-271c-4ce5048d698a',
  'sameer.fathazada.77717fe0@apsl.player',
  'Sameer',
  'Fathazada',
  crypt('Playervtmpvcx7!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '60416857-810d-0006-adc3-d0c3b974f62e',
  'leo.folla.77717fe0@apsl.player',
  'Leo',
  'Folla',
  crypt('Player9tdovjil!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '9f69d7f1-48d5-0006-0434-e25a91b2002f',
  'jakob.friedman.77717fe0@apsl.player',
  'Jakob',
  'Friedman',
  crypt('Player3gohzxyk!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '86a78668-d490-0006-507c-c63cbe981cd4',
  'cesar.manuel.garcia.peralta.77717fe0@apsl.player',
  'Cesar',
  'Manuel Garcia Peralta',
  crypt('Playerzw1h519b!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5fcece2e-4f5d-0006-6334-93a1764a38bf',
  'sebastian.goicochea.77717fe0@apsl.player',
  'Sebastian',
  'Goicochea',
  crypt('Playerb2eqhxwn!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e6a3268a-f969-0006-b947-49b105511976',
  'juan.antonio.gomez.77717fe0@apsl.player',
  'Juan',
  'Antonio Gomez',
  crypt('Player2j8bhdph!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '01bc95c9-ebf3-0006-3908-51d74696b381',
  'alessio.hernandez.77717fe0@apsl.player',
  'Alessio',
  'Hernandez',
  crypt('Playeredgitvwy!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '55aa0a89-1333-0006-b9c3-e796842f5e4a',
  'benjamin.jones.77717fe0@apsl.player',
  'Benjamin',
  'Jones',
  crypt('Playerhvm5sskp!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '63fb84cf-c36b-0006-6c30-9f561178bfad',
  'selcuk.kahveci.77717fe0@apsl.player',
  'Selcuk',
  'Kahveci',
  crypt('Playerlrpcgra2!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '4e3f35f9-419a-0006-2b84-c039cf774337',
  'chad.mark.77717fe0@apsl.player',
  'Chad',
  'Mark',
  crypt('Player41unznl2!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '549c604a-6c05-0006-8afb-b8364faeef3c',
  'leonardo.martinelli.77717fe0@apsl.player',
  'Leonardo',
  'Martinelli',
  crypt('Playerfqncgvso!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5d9518ee-d056-0006-1792-4ca69133d10a',
  'alexander.mclachlan.77717fe0@apsl.player',
  'Alexander',
  'McLachlan',
  crypt('Playereqqptm8p!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '441e00f6-91b9-0006-ae48-da96496c6b24',
  'giovanny.morales.77717fe0@apsl.player',
  'Giovanny',
  'Morales',
  crypt('Playervjw7clr2!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'fa4fc325-734d-0006-257f-61160483af45',
  'bradley.nestor.77717fe0@apsl.player',
  'Bradley',
  'Nestor',
  crypt('Player7xm0tp71!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b1f9ddd9-2d2f-0006-9c7c-c17b0413f6e7',
  'godwin.partey.77717fe0@apsl.player',
  'Godwin',
  'Partey',
  crypt('Playerrhms71r3!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '0990a3e5-73da-0006-4bee-936357ce3b05',
  'kevin.piedrahita.77717fe0@apsl.player',
  'Kevin',
  'Piedrahita',
  crypt('Playerunti3yts!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '59776b14-d92f-0006-7c21-acc132ee5372',
  'junior.rosero.77717fe0@apsl.player',
  'Junior',
  'Rosero',
  crypt('Playerg29s5rec!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f7471293-2b2d-0006-a6af-0f5bfe705f06',
  'karim.russell.77717fe0@apsl.player',
  'Karim',
  'Russell',
  crypt('Playerfqur55fa!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ea425cb3-cb0e-0006-42ab-63e39811f9ec',
  'sanoussi.sangary.77717fe0@apsl.player',
  'Sanoussi',
  'Sangary',
  crypt('Player10k59enc!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '96d07dfc-7d4e-0006-23cb-315fd5dac2bb',
  'shaquille.saunchez.77717fe0@apsl.player',
  'Shaquille',
  'Saunchez',
  crypt('Playerc0bhkxcy!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '96e928a1-380e-0006-0399-a4c5edd55f2c',
  'kendell.thomas.77717fe0@apsl.player',
  'Kendell',
  'Thomas',
  crypt('Playeru4icrfwh!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '26b7d142-5aaf-0006-39ea-39a5af77dfdb',
  'dillon.woods.77717fe0@apsl.player',
  'Dillon',
  'Woods',
  crypt('Player6d5ppc5j!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '1cc2f56c-2f29-0006-00a4-11ffd36b837a',
  'george.yusuff.77717fe0@apsl.player',
  'George',
  'Yusuff',
  crypt('Playerzuyygagj!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Doxa FCW USERS
-- ========================================
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '8553283e-0bc5-0006-ab93-d578af73abc5',
  'adrian.aguilera.68b50f22@apsl.player',
  'Adrian',
  'Aguilera',
  crypt('Playerrrfuq84c!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b807f992-6c9f-0006-8fe6-9e67409b66b6',
  'balint.barabas.68b50f22@apsl.player',
  'Balint',
  'Barabas',
  crypt('Playerklkipdye!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '9dfcf283-1554-0006-47f4-f999e499c15c',
  'vasilios.brisnovalis.68b50f22@apsl.player',
  'Vasilios',
  'Brisnovalis',
  crypt('Playerd247sjfd!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e8b6dbbf-15a0-0006-ab8d-3d73a99ad0b5',
  'robert.cabrera.68b50f22@apsl.player',
  'Robert',
  'Cabrera',
  crypt('Playerkyqgaefh!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '136850cb-6768-0006-7d88-0968d7a98f4f',
  'murat.edgar.calkap.68b50f22@apsl.player',
  'Murat',
  'Edgar Calkap',
  crypt('Player9fsizqk7!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '82a13ab1-cfc2-0006-8bc3-f33d80f586e1',
  'daniel.curmi.68b50f22@apsl.player',
  'Daniel',
  'Curmi',
  crypt('Playerwic3cnqc!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e354b1b6-cec7-0006-6b0b-ae698e5ee5b4',
  'duga.dambelly.68b50f22@apsl.player',
  'Duga',
  'Dambelly',
  crypt('Playerryuummot!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a9b8178b-ffcf-0006-0a01-3d678f53ff7e',
  'khaled.daoud.68b50f22@apsl.player',
  'Khaled',
  'Daoud',
  crypt('Playerr9r7mvp4!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '96e324e8-3075-0006-8275-dfa60b361080',
  'julio.espinal.68b50f22@apsl.player',
  'Julio',
  'Espinal',
  crypt('Playerdedos036!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd80e6914-bf79-0006-a5db-9b406a0f25c8',
  'jeison.gonzalez.sanchez.68b50f22@apsl.player',
  'Jeison',
  'Gonzalez Sanchez',
  crypt('Playero24wwc5d!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '16652c73-e63c-0006-817c-3e33ca1327fa',
  'james.greco.68b50f22@apsl.player',
  'James',
  'Greco',
  crypt('Player7kegj0uu!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f4684a76-c17a-0006-c1ec-c80b80a9d5f5',
  'grady.kozak.68b50f22@apsl.player',
  'Grady',
  'Kozak',
  crypt('Player0yw9izz7!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '6fc4c8b3-be27-0006-d6cc-9d92536c7ead',
  'antonio.linge.68b50f22@apsl.player',
  'Antonio',
  'Linge',
  crypt('Player86i6oyxa!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '6d9c5821-5a40-0006-e297-99756d01cc20',
  'kevin.lucero.68b50f22@apsl.player',
  'Kevin',
  'Lucero',
  crypt('Playerw1y8c4yd!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '31e30e09-6459-0006-f52e-29d2146f24ba',
  'tyrone.malango.68b50f22@apsl.player',
  'Tyrone',
  'Malango',
  crypt('Player6fm8jwjw!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a78962bf-9a98-0006-39ee-9f19a504be4e',
  'william.marment.68b50f22@apsl.player',
  'William',
  'Marment',
  crypt('Playeraf5c9nnu!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '58bc203e-e5c3-0006-c8f1-e511a51f0b1e',
  'augustus.manuel.mcgiff.68b50f22@apsl.player',
  'Augustus',
  'Manuel Mcgiff',
  crypt('Player197i63ia!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c7559bdd-b14e-0006-5a4c-428b6409759f',
  'christopher.morandi.68b50f22@apsl.player',
  'Christopher',
  'Morandi',
  crypt('Playerlpxeqha2!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e1978acf-a2db-0006-fcdb-245d371706c6',
  'richard.morel.68b50f22@apsl.player',
  'Richard',
  'Morel',
  crypt('Player7wucao0y!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ff98ae93-b10a-0006-86d4-c2923fd89ad4',
  'peter.myrianthopoulos.68b50f22@apsl.player',
  'Peter',
  'Myrianthopoulos',
  crypt('Player4lch6z94!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '00f5fd37-aced-0006-9734-daf0d702148d',
  'jorge.alberto.nieto.zambrano.68b50f22@apsl.player',
  'Jorge',
  'Alberto Nieto Zambrano',
  crypt('Playertzvig0va!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a2b8a7c5-b649-0006-cce0-a7bd93543da6',
  'stefen.nikolic.68b50f22@apsl.player',
  'Stefen',
  'Nikolic',
  crypt('Player0a1dv420!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5365bc6b-7090-0006-06c6-b79ce5aac6c2',
  'martin.nikprelaj.68b50f22@apsl.player',
  'Martin',
  'Nikprelaj',
  crypt('Player2p238820!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '402bdfcc-c09b-0006-1155-cc6a9044c704',
  'sergio.peralta.68b50f22@apsl.player',
  'Sergio',
  'Peralta',
  crypt('Playerrkdmk05x!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '8768a116-0221-0006-25bf-cfb6e9d0442c',
  'paolo.cerruto.primavera.68b50f22@apsl.player',
  'Paolo',
  'Cerruto Primavera',
  crypt('Playerqgibzrin!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd1c1bb4d-6783-0006-186d-c12447516d68',
  'chris.riordan.68b50f22@apsl.player',
  'Chris',
  'Riordan',
  crypt('Playerz3ta1woa!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '15edf299-22ff-0006-24cd-e91f642aeb47',
  'david.rodriguez.68b50f22@apsl.player',
  'David',
  'Rodriguez',
  crypt('Player5ekxi470!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e04b2828-5b2c-0006-b352-a80109558d4c',
  'ronaldo.rodriguez.jurado.68b50f22@apsl.player',
  'Ronaldo',
  'Rodriguez Jurado',
  crypt('Player4sobei6r!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c7cff871-f78f-0006-a535-a62155edc074',
  'fredy.rosales.68b50f22@apsl.player',
  'Fredy',
  'Rosales',
  crypt('Player3e1eer9w!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '6295c243-c1e4-0006-d160-eb71b9ce4ad5',
  'duvan.sanchez.68b50f22@apsl.player',
  'Duvan',
  'Sanchez',
  crypt('Playerjyzi3ppj!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e44e575c-135d-0006-5bae-085489cbb696',
  'giuliano.santucci.68b50f22@apsl.player',
  'Giuliano',
  'Santucci',
  crypt('Playerkdjog917!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7526effd-5575-0006-4b12-bba489538263',
  'navruz.shukroev.68b50f22@apsl.player',
  'Navruz',
  'Shukroev',
  crypt('Playergu4m9zbn!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '95623388-791f-0006-aac5-7ce51887876c',
  'milorad.sobot.68b50f22@apsl.player',
  'Milorad',
  'Sobot',
  crypt('Playerkrr4i4yp!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '99357ccf-ed73-0006-03f8-c5d7c22911b2',
  'michalis.stylianou.68b50f22@apsl.player',
  'Michalis',
  'Stylianou',
  crypt('Playerfaud3928!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '733b8d31-f7dd-0006-a386-88c38d3814df',
  'jorge.bladimir.zambrano.68b50f22@apsl.player',
  'Jorge',
  'Bladimir Zambrano',
  crypt('Playernd5azygz!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- NY International FC USERS
-- ========================================
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'da11023f-75d1-0006-31ec-5f8725c570f8',
  'joshua.adejokun.c99ade72@apsl.player',
  'Joshua',
  'Adejokun',
  crypt('Playerdxs1spq9!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a0b93ed1-0371-0006-0019-02f58a70793b',
  'saad.afif.c99ade72@apsl.player',
  'Saad',
  'Afif',
  crypt('Playeryvrm1de6!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '6a0674ac-94f3-0006-a9a5-9c94612b911b',
  'youssef.afif.c99ade72@apsl.player',
  'Youssef',
  'Afif',
  crypt('Playerz406yeap!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '08634319-2781-0006-dfdb-6fd18e60fc06',
  'osama.al.sahybi.c99ade72@apsl.player',
  'Osama',
  'Al Sahybi',
  crypt('Playerz5yvisnt!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c2780cd9-2043-0006-11f1-042bb40eae9d',
  'eric.anderson.c99ade72@apsl.player',
  'Eric',
  'Anderson',
  crypt('Playereqrw4rpq!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '4d2f1838-300c-0006-617f-04debd1eb0c6',
  'oscar.champigneulle.c99ade72@apsl.player',
  'Oscar',
  'Champigneulle',
  crypt('Playerbgug0qzx!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f4be107b-41e5-0006-1de2-23992501bc4c',
  'ryan.chuang.c99ade72@apsl.player',
  'Ryan',
  'Chuang',
  crypt('Playersn81cw3j!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '9f8e5d31-a1f0-0006-a234-3344918bd80f',
  'michael.dempsey.c99ade72@apsl.player',
  'Michael',
  'Dempsey',
  crypt('Playerd9m0ahs8!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7d345240-5184-0006-3a30-17c55cabe0a3',
  'byran.dia.c99ade72@apsl.player',
  'Byran',
  'Dia',
  crypt('Playerewmlej9q!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f4db866f-e2e1-0006-f1d7-878a45e9e6a0',
  'yohance.douglas.c99ade72@apsl.player',
  'Yohance',
  'Douglas',
  crypt('Player3y8f4zx5!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'cd0ab36f-22a6-0006-f49b-ae71ee5f279b',
  'jeffrey.gad.c99ade72@apsl.player',
  'Jeffrey',
  'Gad',
  crypt('Playerm7srh17y!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b8347f17-2aa3-0006-05a7-6e06d27bf528',
  'jahdea.gildin.c99ade72@apsl.player',
  'Jahdea',
  'Gildin',
  crypt('Playern13wcvq4!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c9243d59-0f6a-0006-085a-af39bee83bb7',
  'ross.holden.c99ade72@apsl.player',
  'Ross',
  'Holden',
  crypt('Playerts2tvga5!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ee7e4197-801a-0006-2112-d89d75e5b13b',
  'hugo.howard.c99ade72@apsl.player',
  'Hugo',
  'Howard',
  crypt('Playerxpoy7pw1!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b3726b38-086b-0006-301c-91d24e5cfa80',
  'ikrom.husanov.c99ade72@apsl.player',
  'Ikrom',
  'Husanov',
  crypt('Playerbx5bdndz!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '0fe80dea-a7da-0006-12a8-61e8e623d47d',
  'geireann.lindfield.c99ade72@apsl.player',
  'Geireann',
  'Lindfield',
  crypt('Playernx84w45b!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '93863025-3322-0006-c9d4-cffc6653cb4c',
  'sean.molloy.c99ade72@apsl.player',
  'Sean',
  'Molloy',
  crypt('Playeruu8aong4!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '3b2c6fa5-2920-0006-d424-57fb89ad4a05',
  'shamir.mullings.c99ade72@apsl.player',
  'Shamir',
  'Mullings',
  crypt('Player91r4eg2x!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '91708f14-86aa-0006-9f16-1893bf050cda',
  'ridwan.olawin.c99ade72@apsl.player',
  'Ridwan',
  'Olawin',
  crypt('Player3sffx8x9!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5272fa1c-7995-0006-2dc6-e45bf6200869',
  'gary.philpott.c99ade72@apsl.player',
  'Gary',
  'Philpott',
  crypt('Playersonmz68b!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ae03dfad-1bde-0006-8220-e144a12d7fa2',
  'sean.reilly.c99ade72@apsl.player',
  'Sean',
  'Reilly',
  crypt('Playeru697m7mh!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5ae84ac0-8c22-0006-139e-955db58f24c9',
  'faissal.sanfo.c99ade72@apsl.player',
  'Faissal',
  'Sanfo',
  crypt('Playera3dktv5c!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'aaa0b7d4-af86-0006-687c-0afc97197b3c',
  'ensa.sanneh.c99ade72@apsl.player',
  'Ensa',
  'Sanneh',
  crypt('Playerropdz96e!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '900b1ebd-3e5d-0006-95b5-c0564c3f1ccc',
  'avinash.singh.c99ade72@apsl.player',
  'Avinash',
  'Singh',
  crypt('Playerobpv3lh6!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '4096ec7a-118b-0006-d968-3e19aa35297c',
  'john.stevens.c99ade72@apsl.player',
  'John',
  'Stevens',
  crypt('Player3n8gx3ht!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '03d5af41-d440-0006-db41-25dabf295dad',
  'alexandru.teodorescu.c99ade72@apsl.player',
  'Alexandru',
  'Teodorescu',
  crypt('Playerv7k8fa67!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e6db93de-0ef0-0006-ea37-fd688fefc784',
  'maurice.vermeulen.c99ade72@apsl.player',
  'Maurice',
  'Vermeulen',
  crypt('Player26kaebdu!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Richmond County FC USERS
-- ========================================
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'bce1161c-8a20-0006-c0d0-95b6c66eeeb3',
  'hermes.ademovi.bad8aee7@apsl.player',
  'Hermes',
  'Ademovi',
  crypt('Player080iohu3!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e485bb60-e873-0006-bca7-63763ea70cd3',
  'mamadou.bah.bad8aee7@apsl.player',
  'Mamadou',
  'Bah',
  crypt('Playervjeo1kdg!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '8c7d4b82-ae75-0006-396b-2e68ecd51e28',
  'bljedi.bardic.bad8aee7@apsl.player',
  'Bljedi',
  'Bardic',
  crypt('Playeruj3mmq1j!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7e777131-a30d-0006-d1c6-1b14c183ce4f',
  'giuseppe.barone.bad8aee7@apsl.player',
  'Giuseppe',
  'Barone',
  crypt('Playerkx1lokdo!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '0b80437b-f9d9-0006-9d55-84ad74e321ba',
  'salvatore.barone.bad8aee7@apsl.player',
  'Salvatore',
  'Barone',
  crypt('Playerarfgbf4y!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '8beeea2d-7b6c-0006-1628-f3b2815c5c02',
  'kemal.brkanovic.bad8aee7@apsl.player',
  'Kemal',
  'Brkanovic',
  crypt('Playeroun3lrsf!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '287a050f-094b-0006-ccec-08c2669d1d4b',
  'cesare.cali.bad8aee7@apsl.player',
  'Cesare',
  'Cali',
  crypt('Playertkhnmrdo!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd99f371d-90cd-0006-72f1-85fac4052ece',
  'keithlend.cesar.bad8aee7@apsl.player',
  'Keithlend',
  'Cesar',
  crypt('Player52dlfwwf!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'dbb797c4-0df7-0006-5c6a-01944c09e188',
  'kyaire.clarke.bad8aee7@apsl.player',
  'Kyaire',
  'Clarke',
  crypt('Playerj9q9qs3u!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f25d0c35-a284-0006-e480-317e1eb03217',
  'luis.cueva.bad8aee7@apsl.player',
  'Luis',
  'Cueva',
  crypt('Playerfifj874s!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'aea90e37-c643-0006-376d-a3c5e6c8b432',
  'bradley.espejo.bad8aee7@apsl.player',
  'Bradley',
  'Espejo',
  crypt('Playerxmxp9l84!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7df3844d-8dd6-0006-6d5f-7dfac0f54ecd',
  'roberto.gioffre.bad8aee7@apsl.player',
  'Roberto',
  'Gioffre',
  crypt('Playerq5zze6hl!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b27dafc4-a86b-0006-5e3f-3e455b109671',
  'pietro.giove.bad8aee7@apsl.player',
  'Pietro',
  'Giove',
  crypt('Playeryrdkweq6!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '21c6e29c-5af7-0006-258a-1d25ec801ff3',
  'christopher.gjini.bad8aee7@apsl.player',
  'Christopher',
  'Gjini',
  crypt('Playerlkgbj2ne!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e0adf473-fe6d-0006-7294-233eb2365fbc',
  'peter.gjini.bad8aee7@apsl.player',
  'Peter',
  'Gjini',
  crypt('Playersov8ar3z!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f9dcfd4b-bfa1-0006-7611-9be226bdba33',
  'armando.guarnera.bad8aee7@apsl.player',
  'Armando',
  'Guarnera',
  crypt('Playerhq9vtfyg!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'acd787f5-aa56-0006-8da8-8344e205a251',
  'james.haddad.bad8aee7@apsl.player',
  'James',
  'Haddad',
  crypt('Player3t8u5beu!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '0f64c776-35e1-0006-64c9-6c93a2cd1832',
  'yassin.hairane.bad8aee7@apsl.player',
  'Yassin',
  'Hairane',
  crypt('Playermr7m7vcf!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '2dce9028-0149-0006-594f-429575a87a2e',
  'amir.islami.bad8aee7@apsl.player',
  'Amir',
  'Islami',
  crypt('Playerirn0un9r!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e22ef105-39cb-0006-b5e2-153fa15f1d25',
  'timothy.francis.kane.bad8aee7@apsl.player',
  'Timothy',
  'Francis Kane',
  crypt('Playerek0j0pe1!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'da40f677-135e-0006-5a50-eb52bc0b4430',
  'brian.kerliu.bad8aee7@apsl.player',
  'Brian',
  'Kerliu',
  crypt('Player2cl289m4!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f196192d-1511-0006-529c-b35d76c429b3',
  'peterson.larose.bad8aee7@apsl.player',
  'Peterson',
  'Larose',
  crypt('Playerj1en2drg!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f8ecceba-6f7b-0006-b174-8f6bd4b0c533',
  'dylan.meadows.bad8aee7@apsl.player',
  'Dylan',
  'Meadows',
  crypt('Player5nqryukd!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '28fd501f-630e-0006-5824-6c22ac2bafc7',
  'gerald.mehja.bad8aee7@apsl.player',
  'Gerald',
  'Mehja',
  crypt('Playert8ch4bt9!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '10249ce5-05d1-0006-0776-8926a01291bb',
  'michael.mollica.bad8aee7@apsl.player',
  'Michael',
  'Mollica',
  crypt('Playerkls2z0mt!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '53b61c25-83f8-0006-588f-4439c483b14f',
  'anthony.oliveira.bad8aee7@apsl.player',
  'Anthony',
  'Oliveira',
  crypt('Playerxs6xh88b!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b2aa37b8-b942-0006-c9b0-08c69bd71116',
  'cristiano.oliveira.bad8aee7@apsl.player',
  'Cristiano',
  'Oliveira',
  crypt('Playerafpzfnlz!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '2de3d2cc-16dd-0006-7349-f11e1d8abe77',
  'andrea.ruggiero.bad8aee7@apsl.player',
  'Andrea',
  'Ruggiero',
  crypt('Playerxrnq0rfs!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5957a3f6-b96c-0006-227f-3eff7b8a9171',
  'leutrim.saiti.bad8aee7@apsl.player',
  'Leutrim',
  'Saiti',
  crypt('Player4pl90l79!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '971cd727-111d-0006-d68c-1df8069ee8f1',
  'valeriy.saramoutin.bad8aee7@apsl.player',
  'Valeriy',
  'Saramoutin',
  crypt('Playery86ic973!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '41d9d017-e552-0006-32dd-f4da36bceace',
  'mark.shnadshteyn.bad8aee7@apsl.player',
  'Mark',
  'Shnadshteyn',
  crypt('Playerjx4mpzu4!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '3cea49a3-cbe8-0006-36f7-2e2850a8304a',
  'demyan.turiy.bad8aee7@apsl.player',
  'Demyan',
  'Turiy',
  crypt('Playerb89gk6q0!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'fd4aaa73-51cb-0006-dd76-41e8170e8901',
  'dominik.urban.bad8aee7@apsl.player',
  'Dominik',
  'Urban',
  crypt('Player6lu0fl6q!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b9f831be-2af6-0006-597a-108e95db60f6',
  'bryant.vidals.bad8aee7@apsl.player',
  'Bryant',
  'Vidals',
  crypt('Playerwfp45uv6!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ca787b8d-9fa4-0006-1d9b-2c9386b04b5c',
  'dani.villa.bad8aee7@apsl.player',
  'Dani',
  'Villa',
  crypt('Player51jrcxii!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Zum Schneider FC 03 USERS
-- ========================================
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '49c3a3a1-574c-0006-614d-dda5233ffa63',
  'jimmy.barrios.5951a8c4@apsl.player',
  'Jimmy',
  'Barrios',
  crypt('Playerijlopic5!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '76877460-9405-0006-21f2-54b9e1c25045',
  'richard.bastian.5951a8c4@apsl.player',
  'Richard',
  'Bastian',
  crypt('Playeri1ni1hed!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '19a21d5c-9974-0006-01e0-3c18768f7de7',
  'tal.benhamou.5951a8c4@apsl.player',
  'Tal',
  'Benhamou',
  crypt('Playeravqcgtim!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c10629cb-3295-0006-14da-5ea2ab2f05ec',
  'nathan.bennett.5951a8c4@apsl.player',
  'Nathan',
  'Bennett',
  crypt('Playermt8g3wyd!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '078bba28-5537-0006-bf21-78ab7580545e',
  'jason.budhai.5951a8c4@apsl.player',
  'Jason',
  'Budhai',
  crypt('Playerrfe2j7vb!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '9eeb251b-70cf-0006-0f36-b7b55b09448c',
  'dennis.coke.jr.5951a8c4@apsl.player',
  'Dennis',
  'Coke Jr',
  crypt('Player305zetxq!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'bcea2412-8f7d-0006-3fd3-9dbb4726db23',
  'sully.corneille.5951a8c4@apsl.player',
  'Sully',
  'Corneille',
  crypt('Playerty7wgs4c!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '22174273-ed2f-0006-3d69-e3406836c4d9',
  'dario.giovanni.cruz.5951a8c4@apsl.player',
  'Dario',
  'Giovanni Cruz',
  crypt('Playerux7omwjy!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b6924d73-37de-0006-2267-13682493f9fa',
  'juan.cruz.5951a8c4@apsl.player',
  'Juan',
  'Cruz',
  crypt('Playerw7ok4fq3!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '02a45a5f-37ad-0006-8cd9-9f18754af64b',
  'tomas.de.andrade.gomes.5951a8c4@apsl.player',
  'Tomas',
  'de Andrade Gomes',
  crypt('Playerwncjeokz!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f40824e5-0bc2-0006-7499-9dc0d2d4e044',
  'felix.dyckerhoff.5951a8c4@apsl.player',
  'Felix',
  'Dyckerhoff',
  crypt('Playerdrjp8nqc!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd5a40e0a-5b95-0006-89a5-aab3b10298d6',
  'salim.dziri.5951a8c4@apsl.player',
  'Salim',
  'Dziri',
  crypt('Playerasqcrvx1!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '40c14827-209d-0006-6aa2-204d9f8623a7',
  'glenford.gentle.5951a8c4@apsl.player',
  'Glenford',
  'Gentle',
  crypt('Playerpj4hfgx6!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '785224fb-086d-0006-9237-706419cd8767',
  'boris.grubic.5951a8c4@apsl.player',
  'Boris',
  'Grubic',
  crypt('Player3cp2m0x3!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b9b61877-eb8d-0006-0f43-8352cc3face7',
  'wisdom.hountondji.5951a8c4@apsl.player',
  'Wisdom',
  'Hountondji',
  crypt('Playerqczxsph2!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '4aa9360b-92c0-0006-8887-c1935e7a0738',
  'tom.hultsch.5951a8c4@apsl.player',
  'Tom',
  'Hultsch',
  crypt('Playerr830aui4!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '6128cd53-4dcf-0006-ce08-eaad819a7fb4',
  'raphael.john.5951a8c4@apsl.player',
  'Raphael',
  'John',
  crypt('Playergjbdehb8!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'fe670433-3fb3-0006-a064-98cb336bb46a',
  'ryo.koiso.5951a8c4@apsl.player',
  'Ryo',
  'Koiso',
  crypt('Playerfb6qut19!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd367d0f1-232f-0006-fc14-0dcab7c29330',
  'michael.laret.5951a8c4@apsl.player',
  'Michael',
  'Laret',
  crypt('Player6v51vufr!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ab08f853-6ea2-0006-f2e3-e6b4d49b539b',
  'jason.lee.5951a8c4@apsl.player',
  'Jason',
  'Lee',
  crypt('Playerm9ob6lq3!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'db262a89-1b94-0006-95ca-89715dab850c',
  'cesare.marconi.5951a8c4@apsl.player',
  'Cesare',
  'Marconi',
  crypt('Playercqia7d9y!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '00ea6a8e-3545-0006-271a-5ad09a1f0abf',
  'denny.morinigo.arce.5951a8c4@apsl.player',
  'Denny',
  'Morinigo-Arce',
  crypt('Playerr0hnpy4s!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b2b8090e-a6eb-0006-8e39-359e41a7b097',
  'mateo.munoz.5951a8c4@apsl.player',
  'Mateo',
  'Munoz',
  crypt('Player79iflau2!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7d44aa99-7614-0006-da89-abdb7b5a2ca1',
  'deniz.oncu.5951a8c4@apsl.player',
  'Deniz',
  'Oncu',
  crypt('Playerdx5th4in!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e8990e9c-5426-0006-a8a5-9a8d72e894ea',
  'mubarak.ouro.5951a8c4@apsl.player',
  'Mubarak',
  'Ouro',
  crypt('Playergalyahcw!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '51d5d67e-6556-0006-7e55-1e3086afbedd',
  'jean.carlo.perez.5951a8c4@apsl.player',
  'Jean',
  'Carlo Perez',
  crypt('Player1o20lu9d!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '80f7e57a-c7ca-0006-06c0-227c75724030',
  'mario.ramirez.5951a8c4@apsl.player',
  'Mario',
  'Ramirez',
  crypt('Player3npm7b9h!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '0a039ea1-dc67-0006-01d0-280bfe57a233',
  'paul.restrepo.5951a8c4@apsl.player',
  'Paul',
  'Restrepo',
  crypt('Playerrbmk5rs0!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '4f9c1a37-70d2-0006-8910-85ca9fafcef3',
  'ely.schartz.5951a8c4@apsl.player',
  'Ely',
  'Schartz',
  crypt('Playerkwseu097!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '971f1615-30bc-0006-8c44-0c4aa4aabba5',
  'diego.silva.5951a8c4@apsl.player',
  'Diego',
  'Silva',
  crypt('Player5vm20pfw!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd8683cfd-50b9-0006-1627-7d5a28d65c15',
  'tyler.swaby.5951a8c4@apsl.player',
  'Tyler',
  'Swaby',
  crypt('Playeruv2nrnad!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '8437099b-1363-0006-371c-65b5b6f737c6',
  'anderson.velazquez.mendoza.5951a8c4@apsl.player',
  'Anderson',
  'Velazquez-Mendoza',
  crypt('Player0mpl6tzw!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '73473ad7-30f2-0006-3739-85cd61eccf2b',
  'andrade.wright.5951a8c4@apsl.player',
  'Andrade',
  'Wright',
  crypt('Playerhjtmvqxb!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- SC Vistula Garfield USERS
-- ========================================
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '3f3733e7-657f-0006-0e24-cf9ff3f0d0fa',
  'johannes.alvarez.741624af@apsl.player',
  'Johannes',
  'Alvarez',
  crypt('Playerjwducn4c!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5d4de7c8-3d9a-0006-9cc9-fa85928a7164',
  'jason.alves.741624af@apsl.player',
  'Jason',
  'Alves',
  crypt('Player925khket!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c8800a92-b539-0006-192b-1ddffe904d4c',
  'christopher.barnas.741624af@apsl.player',
  'Christopher',
  'Barnas',
  crypt('Playere5ojcje5!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ee7b0564-1987-0006-df37-e8f7b5f9dd76',
  'roberto.chernez.741624af@apsl.player',
  'Roberto',
  'Chernez',
  crypt('Playere8q2iizu!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '18fd44e9-26b7-0006-049a-959bd6819e24',
  'gabriel.costa.741624af@apsl.player',
  'Gabriel',
  'Costa',
  crypt('Playerz5cz7giy!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a1d48fd8-87cd-0006-b41c-5a9298f76871',
  'keijon.davis.741624af@apsl.player',
  'Keijon',
  'Davis',
  crypt('Player3gssiyg3!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '3f6cfe4c-d473-0006-63b6-2361a70149e2',
  'shaunavon.desouza.741624af@apsl.player',
  'Shaunavon',
  'DeSouza',
  crypt('Playeryle58sst!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd5ac0372-aa40-0006-2590-f7318d99bcce',
  'gabriel.dipierro.741624af@apsl.player',
  'Gabriel',
  'DiPierro',
  crypt('Playerhv75w99j!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '31cf0a9e-12de-0006-a6fe-fa064ba8cb10',
  'emiland.elezaj.741624af@apsl.player',
  'Emiland',
  'Elezaj',
  crypt('Players1clnnbv!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '0910c7ca-7a43-0006-4244-2bd46eacedee',
  'andres.gonzalez.rios.741624af@apsl.player',
  'Andres',
  'Gonzalez-Rios',
  crypt('Player66ottrxz!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a1b59e16-e6df-0006-15a9-27edaa41d6bc',
  'jonathan.gutierrez.741624af@apsl.player',
  'Jonathan',
  'Gutierrez',
  crypt('Player1bgn5n2b!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '56efd39a-9a30-0006-6460-837eca786e62',
  'oscar.horwitz.741624af@apsl.player',
  'Oscar',
  'Horwitz',
  crypt('Playern59gpiim!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '21bdcefa-10df-0006-06ff-9eaf90f68733',
  'jashar.jashar.741624af@apsl.player',
  'Jashar',
  'Jashar',
  crypt('Player0hpetfiw!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '782d35a8-d9da-0006-3f41-70c449e58d4b',
  'christopher.karcz.741624af@apsl.player',
  'Christopher',
  'Karcz',
  crypt('Playerd0f3wcr7!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ccbdfeb5-1e21-0006-1246-f1359776c8aa',
  'wiktor.kiszkiel.741624af@apsl.player',
  'Wiktor',
  'Kiszkiel',
  crypt('Playerj5ck7jj4!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '78bc5527-3031-0006-caeb-56e915e6a0d9',
  'christopher.kondratowicz.741624af@apsl.player',
  'Christopher',
  'Kondratowicz',
  crypt('Playerxm2atxhj!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '895dae53-ddad-0006-d28c-f016c5bb511f',
  'paul.kondratowicz.741624af@apsl.player',
  'Paul',
  'Kondratowicz',
  crypt('Playerxg8rsa4k!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7a21ec10-1a2f-0006-e404-93a5ffb92593',
  'nicholas.kozdron.741624af@apsl.player',
  'Nicholas',
  'Kozdron',
  crypt('Playerwy74oirq!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '47b018da-72df-0006-6037-a51843d19e84',
  'sebastian.lapczynski.741624af@apsl.player',
  'Sebastian',
  'Lapczynski',
  crypt('Playerbgk9x8gd!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '1c3783c6-bdca-0006-3ac9-65682be5e4db',
  'john.mcgeechan.741624af@apsl.player',
  'John',
  'McGeechan',
  crypt('Playerq5hvm4em!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7fcb56e5-35da-0006-93db-2ebc97d0418a',
  'mark.mikanik.741624af@apsl.player',
  'Mark',
  'Mikanik',
  crypt('Playermz8guou2!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ecf7a8ef-b691-0006-9b3c-f2bb27ec8829',
  'aldo.munoz.741624af@apsl.player',
  'Aldo',
  'Munoz',
  crypt('Playersoqqjwl8!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '86300470-6cda-0006-8570-a0807605134c',
  'cyrus.nasseri.741624af@apsl.player',
  'Cyrus',
  'Nasseri',
  crypt('Playero5qxad0d!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b93c06bf-4171-0006-e850-ab4fd6ea9a68',
  'krystian.nitek.741624af@apsl.player',
  'Krystian',
  'Nitek',
  crypt('Playervrf8obyx!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '807a6936-b907-0006-f97c-ea276db8d942',
  'viktor.pervushkin.741624af@apsl.player',
  'Viktor',
  'Pervushkin',
  crypt('Playerkqg9voi4!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e70c8183-460a-0006-d92f-a24a40fbec8f',
  'tyler.pinho.741624af@apsl.player',
  'Tyler',
  'Pinho',
  crypt('Playerh71ih7ut!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '01de1cd6-c809-0006-e0a7-f06314e40991',
  'alvaro.rodriguez.741624af@apsl.player',
  'Alvaro',
  'Rodriguez',
  crypt('Playeryfdz9t41!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '67324332-16ad-0006-8dfd-3be7f08de349',
  'daniel.sawicki.741624af@apsl.player',
  'Daniel',
  'Sawicki',
  crypt('Playerjngyxnul!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7a382673-a77c-0006-23de-562d8868122b',
  'gabriel.serafin.741624af@apsl.player',
  'Gabriel',
  'Serafin',
  crypt('Playeril02w920!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ed105191-f1e0-0006-7616-da426caa21c9',
  'william.tomlinson.741624af@apsl.player',
  'William',
  'Tomlinson',
  crypt('Player7lkaiqwp!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '4020ae27-181e-0006-29b3-21dfc09e6e18',
  'igor.trajceski.741624af@apsl.player',
  'Igor',
  'Trajceski',
  crypt('Playerq2s593tf!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '8791a6a4-41ef-0006-a249-a284f3a9aa48',
  'kevin.valdivia.741624af@apsl.player',
  'Kevin',
  'Valdivia',
  crypt('Playera0dpc2d2!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- NY Athletic Club USERS
-- ========================================
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '424aa738-9a99-0006-07f1-afd4796d44e7',
  'dominik.brulinski.7fd5026d@apsl.player',
  'Dominik',
  'Brulinski',
  crypt('Players6fm9ot0!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '4facf928-18fe-0006-01bc-be92f391c06b',
  'mathew.contino.7fd5026d@apsl.player',
  'Mathew',
  'Contino',
  crypt('Playerhrhmqyd8!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '8b10ada8-4aea-0006-52d4-7bc16fd93d53',
  'joseph.core.7fd5026d@apsl.player',
  'Joseph',
  'Core',
  crypt('Player3qu78dkh!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '0dd2b243-5b0d-0006-71ef-0599cb8ca0fa',
  'jacob.denison.7fd5026d@apsl.player',
  'Jacob',
  'Denison',
  crypt('Playerc7rhx2v6!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5a358224-ba04-0006-2d21-0af9ac4e2f39',
  'jack.doran.7fd5026d@apsl.player',
  'Jack',
  'Doran',
  crypt('Playerxochek1w!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '16f96f66-54cd-0006-9a4d-10d9fa94dde9',
  'javiar.edwards.7fd5026d@apsl.player',
  'Javiar',
  'Edwards',
  crypt('Playergi5h1rkg!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '18e3aaad-b08e-0006-b5e1-7413d805fd35',
  'humbert.ferrer.7fd5026d@apsl.player',
  'Humbert',
  'Ferrer',
  crypt('Player6u378y48!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '3aad862a-a0e4-0006-faa0-7bd7be16f4da',
  'spencer.fleurant.7fd5026d@apsl.player',
  'Spencer',
  'Fleurant',
  crypt('Playerpvskfdv5!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '95f064c5-f725-0006-8f09-cab36284516c',
  'jason.gaylord.7fd5026d@apsl.player',
  'Jason',
  'Gaylord',
  crypt('Playerr7zcxal4!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '26967907-e703-0006-5f9a-2a25c57d4d46',
  'daniel.giorgi.7fd5026d@apsl.player',
  'Daniel',
  'Giorgi',
  crypt('Playertct43l4c!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b946b12b-cfff-0006-254a-6bb70d5a4122',
  'kevin.harrington.7fd5026d@apsl.player',
  'Kevin',
  'Harrington',
  crypt('Players33wqfbf!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'dd882c44-0d60-0006-d0be-366d480388fa',
  'stephanos.hondrakis.7fd5026d@apsl.player',
  'Stephanos',
  'Hondrakis',
  crypt('Playersuu5vao0!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b155a0c4-7b1d-0006-7522-3f5e75a4f1c7',
  'cris.huacon.7fd5026d@apsl.player',
  'Cris',
  'Huacon',
  crypt('Playerusuw7oa7!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'cd066a82-4806-0006-2e80-9392fae48ad6',
  'samuka.kenneh.7fd5026d@apsl.player',
  'Samuka',
  'Kenneh',
  crypt('Player1gderyfh!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd0bb1d8b-2d88-0006-425a-cba7604cccf6',
  'evan.kim.7fd5026d@apsl.player',
  'Evan',
  'Kim',
  crypt('Playerfeq000wi!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '43550c1f-ebee-0006-7a52-62f5c95f5482',
  'brent.mckeown.7fd5026d@apsl.player',
  'Brent',
  'McKeown',
  crypt('Playerclnqrxde!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7aef160c-eaf2-0006-f671-8485b9437a57',
  'enrique.montana.iii.7fd5026d@apsl.player',
  'Enrique',
  'Montana III',
  crypt('Playeroqyggj3z!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '89cdfd6c-d787-0006-d900-491e7ce24064',
  'jack.mulhare.7fd5026d@apsl.player',
  'Jack',
  'Mulhare',
  crypt('Playeryy1nj6vz!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '0cfae6e2-c65b-0006-aa6f-6fbf00f42df0',
  'curtis.oberg.7fd5026d@apsl.player',
  'Curtis',
  'Oberg',
  crypt('Playeri1fz2tpa!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'eb9c3771-5d7c-0006-5f30-8ac16610de94',
  'farouk.osman.7fd5026d@apsl.player',
  'Farouk',
  'Osman',
  crypt('Playertj9w5hjd!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '648e0435-0fef-0006-9f01-2453924d5327',
  'cole.parete.7fd5026d@apsl.player',
  'Cole',
  'Parete',
  crypt('Player9pbvn6ao!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '4a3c8d2a-51af-0006-aa71-61202c127768',
  'william.pearce.7fd5026d@apsl.player',
  'William',
  'Pearce',
  crypt('Playera7f8uj1k!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '322981c0-1fe1-0006-dd98-91f8eaaec451',
  'akeem.phipps.7fd5026d@apsl.player',
  'Akeem',
  'Phipps',
  crypt('Playerz7kr8vbb!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a4cd1fe6-b5a5-0006-060f-e4ba3e5bbf88',
  'layton.purchase.7fd5026d@apsl.player',
  'Layton',
  'Purchase',
  crypt('Playerwfesax5a!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd1b3680e-ebf9-0006-9f5b-e06dbf0b1606',
  'nabeel.qawasmi.7fd5026d@apsl.player',
  'Nabeel',
  'Qawasmi',
  crypt('Playercrbxh0i2!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '3cf2ea8e-c9ec-0006-f0e4-0903b7189ce3',
  'yannick.rihs.7fd5026d@apsl.player',
  'Yannick',
  'Rihs',
  crypt('Player19vt0dyg!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f2eb412d-cd5f-0006-31dd-f288cdc65d05',
  'antonio.rocha.7fd5026d@apsl.player',
  'Antonio',
  'Rocha',
  crypt('Playerqn2jor21!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c4b69158-1295-0006-380b-9d5f50052611',
  'jake.rozhansky.7fd5026d@apsl.player',
  'Jake',
  'Rozhansky',
  crypt('Playerlwaap3wd!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '3e3322ca-d940-0006-f329-c8cbd23c60be',
  'yahli.saltsberg.7fd5026d@apsl.player',
  'Yahli',
  'Saltsberg',
  crypt('Playeroincwdw5!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '33ff1ee8-0488-0006-9ef1-ce5436ff921c',
  'frank.shkreli.7fd5026d@apsl.player',
  'Frank',
  'Shkreli',
  crypt('Player7zu3cjca!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '2ad4f0ec-6ae6-0006-6705-c122d3a28def',
  'michael.soboff.7fd5026d@apsl.player',
  'Michael',
  'Soboff',
  crypt('Player8o5q0wv2!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '19afdc23-6ed6-0006-962b-f6078457bf46',
  'tom.wallenstein.7fd5026d@apsl.player',
  'Tom',
  'Wallenstein',
  crypt('Playerfd5snhph!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'bd5fcc93-54be-0006-632a-eb4a87111153',
  'michael.wampler.7fd5026d@apsl.player',
  'Michael',
  'Wampler',
  crypt('Playersluy3h5j!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '6c593aa2-c9d2-0006-118b-a45da93ed968',
  'peter.wentzel.7fd5026d@apsl.player',
  'Peter',
  'Wentzel',
  crypt('Playerdxsgu3b9!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '30471c7b-f4fe-0006-2daf-ff0aa57c8207',
  'edwin.zuniga.lopez.7fd5026d@apsl.player',
  'Edwin',
  'Zuniga Lopez',
  crypt('Playerorbwavk0!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Central Park Rangers FC USERS
-- ========================================
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '6400a53a-c0b1-0006-c2c1-f06107272338',
  'abdul.karim.bah.48a40f97@apsl.player',
  'Abdul',
  'Karim Bah',
  crypt('Playerhcxrmd41!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '4321140e-41f3-0006-2016-23c06cc59555',
  'ibrahima.bah.48a40f97@apsl.player',
  'Ibrahima',
  'Bah',
  crypt('Player9f29iwvu!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '8ce5236a-2665-0006-3ac1-a727e3ea8299',
  'matthew.baringer.48a40f97@apsl.player',
  'Matthew',
  'Baringer',
  crypt('Playerw807l3be!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'bdf66c42-99b7-0006-16bd-e883a6fa027e',
  'cesar.buitrago.48a40f97@apsl.player',
  'Cesar',
  'Buitrago',
  crypt('Playerbidupkge!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '909c8051-a601-0006-3b21-a4f4f60d56cf',
  'vassiriki.diaby.48a40f97@apsl.player',
  'Vassiriki',
  'Diaby',
  crypt('Playertmjih38l!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ebf5c86e-f594-0006-ca66-af82c13adc03',
  'elhadj.diallo.48a40f97@apsl.player',
  'Elhadj',
  'Diallo',
  crypt('Playernnhnvqw5!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '299ea506-ab3f-0006-079e-bff363d76130',
  'youssouf.diallo.48a40f97@apsl.player',
  'Youssouf',
  'Diallo',
  crypt('Playerxlydcbcg!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '4809998f-c160-0006-eadb-62d3159b9b84',
  'ighoghoe.erediauwa.48a40f97@apsl.player',
  'Ighoghoe',
  'Erediauwa',
  crypt('Player67t2mnut!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '97caf7ea-0c49-0006-48fb-474ee9b98fcf',
  'luis.granados.48a40f97@apsl.player',
  'Luis',
  'Granados',
  crypt('Playeroc1itlcu!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '0d6325f7-952e-0006-a692-5239c5d09c23',
  'radouane.guissi.48a40f97@apsl.player',
  'Radouane',
  'Guissi',
  crypt('Playermzlrrd52!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '59634929-83ef-0006-b2ee-558c0e43e7cd',
  'joseph.kalilwa.48a40f97@apsl.player',
  'Joseph',
  'Kalilwa',
  crypt('Player7d0jmirv!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '4263e408-4561-0006-a2d8-a906585e185c',
  'nicholas.king.48a40f97@apsl.player',
  'Nicholas',
  'King',
  crypt('Playerfqeo4m8s!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7d6d06ee-6694-0006-521c-6497d921ea56',
  'anyolo.makatiani.48a40f97@apsl.player',
  'Anyolo',
  'Makatiani',
  crypt('Player9yjnpx2o!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e6c42fb3-bd7d-0006-7672-3d1915509a2e',
  'matthew.mcdonnell.48a40f97@apsl.player',
  'Matthew',
  'McDonnell',
  crypt('Player1fmu3p56!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '19138c23-bd1a-0006-33bf-096185790ea3',
  'mohamad.miri.48a40f97@apsl.player',
  'Mohamad',
  'Miri',
  crypt('Playerivcslalw!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '70de6205-b31e-0006-2231-eca9806af0f9',
  'aymen.mohamed.48a40f97@apsl.player',
  'Aymen',
  'Mohamed',
  crypt('Playerf4w8o4pi!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '90e689e4-0c8a-0006-ea38-c85229492500',
  'eoghan.morgan.48a40f97@apsl.player',
  'Eoghan',
  'Morgan',
  crypt('Playerusci59dg!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '4a35132b-ed78-0006-35b0-cc73a216abcd',
  'luca.natale.48a40f97@apsl.player',
  'Luca',
  'Natale',
  crypt('Playernoc2i2wg!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'edf2fe1b-e561-0006-8856-a74938f2a735',
  'ezekiel.omosanya.48a40f97@apsl.player',
  'Ezekiel',
  'Omosanya',
  crypt('Player2091wqx5!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a0926711-47b9-0006-0b99-23e5c63844b6',
  'maynor.palacios.48a40f97@apsl.player',
  'Maynor',
  'Palacios',
  crypt('Player3sbs0r4d!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '1040a9c0-2d96-0006-72b9-a56a1ed8dd85',
  'justin.peters.48a40f97@apsl.player',
  'Justin',
  'Peters',
  crypt('Playerfctwdsi7!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '1d8c2a48-325c-0006-fca1-96ba294a5d04',
  'jaidon.selden.48a40f97@apsl.player',
  'Jaidon',
  'Selden',
  crypt('Playerya5qpj3a!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'fee01806-73fb-0006-ec40-e60461e53f22',
  'ismaila.tall.48a40f97@apsl.player',
  'Ismaila',
  'Tall',
  crypt('Player3tilbdun!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '77314a44-b988-0006-9617-9e7a0e61fd66',
  'james.terpak.48a40f97@apsl.player',
  'James',
  'Terpak',
  crypt('Playerql9m4qlc!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b5d17042-4464-0006-c762-ec4e66379275',
  'dominic.tomety.48a40f97@apsl.player',
  'Dominic',
  'Tomety',
  crypt('Playerixgqqq39!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '913e8618-6262-0006-3674-3abdd9a89db4',
  'samuel.urban.48a40f97@apsl.player',
  'Samuel',
  'Urban',
  crypt('Playerbx0v04ba!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f6ed8295-6ae4-0006-e301-49a4ef4f02fe',
  'christopher.valentine.48a40f97@apsl.player',
  'Christopher',
  'Valentine',
  crypt('Playerm4ud13kk!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '02071ec5-affd-0006-efc7-b35131388eb1',
  'marcial.viveros.48a40f97@apsl.player',
  'Marcial',
  'Viveros',
  crypt('Playerpwrfc054!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '6001a807-29e9-0006-7e2b-4e92d522ed9e',
  'timothy.williams.48a40f97@apsl.player',
  'Timothy',
  'Williams',
  crypt('Playerzo73ptg3!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- WC Predators USERS
-- ========================================
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '73e80cff-7b6b-0006-bb21-6322f3d274b5',
  'brahim.hadj.abboud.84a1029b@apsl.player',
  'Brahim',
  'Hadj Abboud',
  crypt('Playerh7552grf!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5e3f4cca-bea8-0006-a670-46771038170f',
  'tomas.ascoli.84a1029b@apsl.player',
  'Tomas',
  'Ascoli',
  crypt('Playerpy50ph4g!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '77470338-c623-0006-c548-0aa3a6e330ee',
  'august.axtman.84a1029b@apsl.player',
  'August',
  'Axtman',
  crypt('Playerbzx22d1m!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '0ab541cb-335c-0006-74a6-3d7ea57f27d4',
  'edwin.bedolla.84a1029b@apsl.player',
  'Edwin',
  'Bedolla',
  crypt('Playerpcttxbu9!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f141d474-787a-0006-d45e-47bc6736ffec',
  'noah.sutton.beltran.84a1029b@apsl.player',
  'Noah',
  'Sutton Beltran',
  crypt('Playerd0nj5r1g!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '147fb591-8d3d-0006-be4d-9c0dc25d4184',
  'ammit.bhogal.84a1029b@apsl.player',
  'Ammit',
  'Bhogal',
  crypt('Playero344xtc4!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '72e5127a-0420-0006-195f-ba747905cb41',
  'john.bonas.84a1029b@apsl.player',
  'John',
  'Bonas',
  crypt('Playeraxyc75rb!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a0860460-a8d9-0006-485b-c66645a15db5',
  'marcus.brenes.84a1029b@apsl.player',
  'Marcus',
  'Brenes',
  crypt('Playerxpd37qwp!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '8e26679f-a4e5-0006-f878-c76a25672fb7',
  'carter.burris.84a1029b@apsl.player',
  'Carter',
  'Burris',
  crypt('Player6w43e1l0!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a836e83f-94cf-0006-8043-2d8885a74c04',
  'colin.forster.davis.84a1029b@apsl.player',
  'Colin',
  'Forster Davis',
  crypt('Playerj23z6d5p!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'abccd0b4-b8fd-0006-0d6f-bc1f68a9dca2',
  'alex.demars.84a1029b@apsl.player',
  'Alex',
  'Demars',
  crypt('Playerd6ajvdf3!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '21a198c1-c1be-0006-5275-35e5e2d03bb3',
  'oliver.garcia.84a1029b@apsl.player',
  'Oliver',
  'Garcia',
  crypt('Player2sfe5lml!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f236924a-f93c-0006-0133-9296ae3556e0',
  'michael.gonzalez.84a1029b@apsl.player',
  'Michael',
  'Gonzalez',
  crypt('Playeraqnxstrp!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '356a7d21-6e82-0006-3470-dc8fc101267b',
  'emmanuel.hewitt.84a1029b@apsl.player',
  'Emmanuel',
  'Hewitt',
  crypt('Playern9og1zho!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '1821dd74-7def-0006-5d0d-8fc2237b95a9',
  'bobby.dwayne.hickerson.84a1029b@apsl.player',
  'Bobby',
  'Dwayne Hickerson',
  crypt('Playerzb0vpfsm!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '8e947f42-3cf8-0006-843e-60f8b5fea83d',
  'luke.hill.84a1029b@apsl.player',
  'Luke',
  'Hill',
  crypt('Playerhlmclxgu!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '2915f812-2eaf-0006-3247-a3ee3a2c7d3d',
  'dylan.leonid.lacy.84a1029b@apsl.player',
  'Dylan',
  'Leonid Lacy',
  crypt('Playerwc8c9nwv!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '163628c2-89d1-0006-d1af-bb18a863454e',
  'joel.lopez.84a1029b@apsl.player',
  'Joel',
  'Lopez',
  crypt('Playerenwkfvsf!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '409dde8f-23a4-0006-e141-4d64030234e5',
  'dominick.martinez.84a1029b@apsl.player',
  'Dominick',
  'Martinez',
  crypt('Player5dxztte7!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '717e4cbd-f435-0006-5502-e6c0727b7c97',
  'brian.mcdaid.84a1029b@apsl.player',
  'Brian',
  'McDaid',
  crypt('Playerj50di12v!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7b7896a2-c6e0-0006-957c-616ed64dd685',
  'luca.mellor.84a1029b@apsl.player',
  'Luca',
  'Mellor',
  crypt('Playernz6yk35c!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f99e964d-eaa9-0006-c8ae-032e285b76b7',
  'mason.miller.84a1029b@apsl.player',
  'Mason',
  'Miller',
  crypt('Playerrk5x91is!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a719d07e-0517-0006-4eae-bc3d71aa524d',
  'ayoub.mouhou.84a1029b@apsl.player',
  'Ayoub',
  'Mouhou',
  crypt('Playerqqds3z9e!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7d34576c-c7d0-0006-dbc9-d786cde27cac',
  'riley.porter.84a1029b@apsl.player',
  'Riley',
  'Porter',
  crypt('Playerad8ktatc!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '59d24fd9-50d0-0006-54f4-e73ab264adca',
  'luke.pressler.84a1029b@apsl.player',
  'Luke',
  'Pressler',
  crypt('Playerezw5as8p!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5f863b85-eea9-0006-40a9-1840f613e7de',
  'ridge.robinson.84a1029b@apsl.player',
  'Ridge',
  'Robinson',
  crypt('Playeremmt1xss!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b5c3d2b2-4c4a-0006-896b-98221bce19b9',
  'miguel.ross.84a1029b@apsl.player',
  'Miguel',
  'Ross',
  crypt('Player6w07yg8a!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'eb392240-6123-0006-ab7b-66e5e6335dc2',
  'maximos.sacarellos.84a1029b@apsl.player',
  'Maximos',
  'Sacarellos',
  crypt('Playerhki3rx7q!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '9df4a12e-0f4b-0006-42a6-9dc70077a9c7',
  'justin.thomas.84a1029b@apsl.player',
  'Justin',
  'Thomas',
  crypt('Playerbfxn5qha!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c65439ba-734b-0006-b92b-69fae3536a62',
  'luke.thomas.84a1029b@apsl.player',
  'Luke',
  'Thomas',
  crypt('Playeriuh1vmc0!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '78567556-1970-0006-3861-b9e49089ccf1',
  'sama.tima.84a1029b@apsl.player',
  'Sama',
  'Tima',
  crypt('Playero4xtg8jd!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '293f3da0-7fe3-0006-9f2c-8e940b99a09c',
  'kyle.tucker.84a1029b@apsl.player',
  'Kyle',
  'Tucker',
  crypt('Playeryo9oeg08!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '6bfd6b45-130a-0006-04a3-db60a109c0cc',
  'nikhil.ashish.verma.84a1029b@apsl.player',
  'Nikhil',
  'Ashish Verma',
  crypt('Playernq8016fn!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '111652fa-a72d-0006-615c-f27cf2316ff8',
  'jacob.weaver.84a1029b@apsl.player',
  'Jacob',
  'Weaver',
  crypt('Player261nquf0!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'aa703ec6-38af-0006-7896-981f05f6694e',
  'charles.wilson.84a1029b@apsl.player',
  'Charles',
  'Wilson',
  crypt('Player820i8uh6!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Alloy Soccer Club USERS
-- ========================================
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '16d92ff3-9a57-0006-147d-280de1b7db40',
  'matteo.adiletta.0223b314@apsl.player',
  'Matteo',
  'Adiletta',
  crypt('Player65swu7r1!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '814a9c1d-8620-0006-fc65-3b86fdfbac20',
  'william.ardiles.0223b314@apsl.player',
  'William',
  'Ardiles',
  crypt('Playerb97by6tv!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '84d2ee83-7c45-0006-1dab-59de9792906c',
  'serge.biket.0223b314@apsl.player',
  'Serge',
  'Biket',
  crypt('Playerthxt76nr!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '8ceeaa55-f225-0006-08cc-ffb7de4701a8',
  'ryan.butler.0223b314@apsl.player',
  'Ryan',
  'Butler',
  crypt('Playerp9ep5axb!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'dfe87512-0319-0006-8548-325bd5838ee9',
  'obiazie.chinatu.0223b314@apsl.player',
  'Obiazie',
  'Chinatu',
  crypt('Playerrz6iychc!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '17c9c8e7-1315-0006-bb2f-416ce8a18678',
  'seth.crabbe.0223b314@apsl.player',
  'Seth',
  'Crabbe',
  crypt('Playerjsm8ncme!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '985ebafc-5269-0006-25fc-ad8f0dc32b3c',
  'leo.dunia.0223b314@apsl.player',
  'Leo',
  'Dunia',
  crypt('Playeres0maikn!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '492ea2dd-919e-0006-644c-293da698aae6',
  'ivan.fombu.0223b314@apsl.player',
  'Ivan',
  'Fombu',
  crypt('Playeru8ugfq30!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '64afe88d-0fe3-0006-5a43-346701077142',
  'nikolaos.gousios.0223b314@apsl.player',
  'Nikolaos',
  'Gousios',
  crypt('Player4pyhr9gx!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '1f2de849-cb2d-0006-2909-7ee022ed5674',
  'isaac.hollinger.0223b314@apsl.player',
  'Isaac',
  'Hollinger',
  crypt('Playerlrau22yj!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '4686541b-cf02-0006-3704-ffda942ae37b',
  'micah.hostetter.0223b314@apsl.player',
  'Micah',
  'Hostetter',
  crypt('Playerb5umzkey!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b4e19a88-ed02-0006-16f6-954571f73f18',
  'abdoul.issoufou.0223b314@apsl.player',
  'Abdoul',
  'Issoufou',
  crypt('Player9mxrn4xc!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '1ec1357e-f099-0006-9e77-85c72c0f7eb3',
  'clovis.kabre.0223b314@apsl.player',
  'Clovis',
  'Kabre',
  crypt('Playeryovgb8fx!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '50b1a6e6-ab05-0006-facb-7d8d04b79397',
  'justin.keefer.0223b314@apsl.player',
  'Justin',
  'Keefer',
  crypt('Player6n1vcnvd!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '66f7cd58-be5d-0006-8bf3-4a46a6245a00',
  'mehluko.letsoalo.0223b314@apsl.player',
  'Mehluko',
  'Letsoalo',
  crypt('Playerin1fcm1n!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '6fa99191-236c-0006-9c0e-142c5199daac',
  'kel.merckel.0223b314@apsl.player',
  'Kel',
  'Merckel',
  crypt('Playertlmurhz5!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '46b93ff5-4a41-0006-513d-fab5d6778c83',
  'caden.mullen.0223b314@apsl.player',
  'Caden',
  'Mullen',
  crypt('Playeryx0950oy!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '4f04250a-4984-0006-8f4a-4961b600ac45',
  'babunga.mulumeoderwa.0223b314@apsl.player',
  'Babunga',
  'Mulumeoderwa',
  crypt('Playerdj5n5cph!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '222b5834-d814-0006-8243-9a84fbf3efa7',
  'luke.nall.0223b314@apsl.player',
  'Luke',
  'Nall',
  crypt('Playerwyvxlfu7!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '48930eb9-5f31-0006-6cb0-abb280213e4c',
  'sivpheng.phann.0223b314@apsl.player',
  'Sivpheng',
  'Phann',
  crypt('Playerb73dyvef!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '0b634a77-de63-0006-5f0b-c219e2d3314e',
  'derek.ramirez.0223b314@apsl.player',
  'Derek',
  'Ramirez',
  crypt('Player8wc763ck!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a576fe92-034d-0006-ef52-0f7ac0658a1a',
  'josiah.ramirez.0223b314@apsl.player',
  'Josiah',
  'Ramirez',
  crypt('Playerbm18vobk!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '82284f64-89cc-0006-10c8-8fe9b7e7d46e',
  'chris.richards.0223b314@apsl.player',
  'Chris',
  'Richards',
  crypt('Playerfe5pmof6!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '142189da-3562-0006-c670-f7a826da045d',
  'daniel.rowe.0223b314@apsl.player',
  'Daniel',
  'Rowe',
  crypt('Playerny7i8c6o!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd0123234-a6ba-0006-20fd-9b1ee7e590e2',
  'lazaro.salazar.0223b314@apsl.player',
  'Lazaro',
  'Salazar',
  crypt('Player9f6gaj2j!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '829e0d25-5eec-0006-40be-c05fa9fedd68',
  'david.tai.san.0223b314@apsl.player',
  'David',
  'Tai San',
  crypt('Playerytfu0gta!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '69e8d194-ff48-0006-c460-a912f7fc942d',
  'dawson.schreck.0223b314@apsl.player',
  'Dawson',
  'Schreck',
  crypt('Player6dqyckbq!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5f21b05f-63cb-0006-70b8-cbe8e5e79b42',
  'owen.shea.0223b314@apsl.player',
  'Owen',
  'Shea',
  crypt('Playerv81a8lg0!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '2512eac1-4e1f-0006-f908-b74a67ea1df7',
  'denis.tarasov.0223b314@apsl.player',
  'Denis',
  'Tarasov',
  crypt('Playeriu0krn5l!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a305845b-886c-0006-870f-5bd1836fecf8',
  'babo.tereffe.0223b314@apsl.player',
  'Babo',
  'Tereffe',
  crypt('Playerp1jssxzn!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd4fd6fa0-6e88-0006-589d-a3de0ad19a5a',
  'william.vasquez.0223b314@apsl.player',
  'William',
  'Vasquez',
  crypt('Player0b7lfgk3!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'bd5686cf-ff37-0006-ab7d-7b1f782c12a4',
  'joel.walker.0223b314@apsl.player',
  'Joel',
  'Walker',
  crypt('Playertbcjwpax!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '2bd72cfd-a1b1-0006-5bd2-7d60d55e868f',
  'christian.wieand.0223b314@apsl.player',
  'Christian',
  'Wieand',
  crypt('Player5urb1iyk!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '868ba230-c422-0006-edb3-2d111bc2f2d0',
  'kedric.yoder.0223b314@apsl.player',
  'Kedric',
  'Yoder',
  crypt('Playervilzrydm!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Philadelphia Heritage SC USERS
-- ========================================
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '9f528086-f1dc-0006-02d3-129c1a89f217',
  'eric.adamo.294a08ff@apsl.player',
  'Eric',
  'Adamo',
  crypt('Playerp7oq35k5!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '61766419-79ba-0006-0d2c-67d82acac321',
  'salam.ashurmamadov.294a08ff@apsl.player',
  'Salam',
  'Ashurmamadov',
  crypt('Playerszw6t98j!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '3534290b-8ac7-0006-cfde-3d2307bc6777',
  'matthew.bergmaier.294a08ff@apsl.player',
  'Matthew',
  'Bergmaier',
  crypt('Playernx3bg8qh!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '9da04c79-4301-0006-981b-20a78277623a',
  'daniel.bloyou.294a08ff@apsl.player',
  'Daniel',
  'Bloyou',
  crypt('Playerdottzhu1!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '696479a2-a4dc-0006-e7d9-4f413577ba63',
  'lawrence.buigbo.294a08ff@apsl.player',
  'Lawrence',
  'Buigbo',
  crypt('Playerixoyb767!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'faa898f0-7e7d-0006-cc5f-7588ef4c6c67',
  'diego.cabrera.294a08ff@apsl.player',
  'Diego',
  'Cabrera',
  crypt('Player0lwbzj5o!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '584d92d6-3f6a-0006-5138-2b12bbd10beb',
  'emanuel.caire.294a08ff@apsl.player',
  'Emanuel',
  'Caire',
  crypt('Player39lo0onj!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '773910ac-70bb-0006-1347-bffa895dabbe',
  'sebastian.carmona.294a08ff@apsl.player',
  'Sebastian',
  'Carmona',
  crypt('Playerubhd05sc!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '675b867c-0b93-0006-0afb-24743fad4132',
  'chad.catalana.294a08ff@apsl.player',
  'Chad',
  'Catalana',
  crypt('Playery7g631i8!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '01181b06-fd26-0006-a9b5-e37fb0513489',
  'nyles.cayemitte.294a08ff@apsl.player',
  'Nyles',
  'Cayemitte',
  crypt('Player7yixg0oq!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '42fa29b2-81ec-0006-4921-e5d1d785ed98',
  'justin.cooper.294a08ff@apsl.player',
  'Justin',
  'Cooper',
  crypt('Playerw0auzenc!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b3652ce9-2860-0006-5640-e94c61724552',
  'kevin.davis.294a08ff@apsl.player',
  'Kevin',
  'Davis',
  crypt('Playerzrwslsdl!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '61cf4157-f653-0006-b5c6-39c24fd9866a',
  'alvin.deegon.294a08ff@apsl.player',
  'Alvin',
  'Deegon',
  crypt('Player1vtecbu5!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e53ed71e-debf-0006-7a8e-6520d161bc2f',
  'yousouf.doucoure.294a08ff@apsl.player',
  'Yousouf',
  'Doucoure',
  crypt('Player3ys6waig!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e0d5e932-646a-0006-1004-33bb89698dcd',
  'nick.dudek.294a08ff@apsl.player',
  'Nick',
  'Dudek',
  crypt('Player4agfzi5c!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '195add2e-8735-0006-4171-644823d4a00f',
  'andres.freire.294a08ff@apsl.player',
  'Andres',
  'Freire',
  crypt('Playerpuu0kfz2!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b63c6d5f-6693-0006-bcbf-383487120e1a',
  'luka.gogidze.294a08ff@apsl.player',
  'Luka',
  'Gogidze',
  crypt('Player4qf3ew6y!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '2d975247-9777-0006-523d-193f2d2cab53',
  'andres.gomez.294a08ff@apsl.player',
  'Andres',
  'Gomez',
  crypt('Playercrhclinn!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5f795242-1de4-0006-0aa6-6482c08358ec',
  'brendan.gorman.294a08ff@apsl.player',
  'Brendan',
  'Gorman',
  crypt('Player0er2ghtq!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '87449ab5-c81a-0006-9188-c8cd09391777',
  'ermir.hoti.294a08ff@apsl.player',
  'Ermir',
  'Hoti',
  crypt('Player3up6e5uo!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '10c00684-5530-0006-9e75-64bb24a81c8d',
  'hamin.kim.294a08ff@apsl.player',
  'Hamin',
  'Kim',
  crypt('Player7sbqlhxn!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '821024ec-6e2e-0006-3551-960d684ab8dc',
  'kalvin.matischak.294a08ff@apsl.player',
  'Kalvin',
  'Matischak',
  crypt('Playerqdmnf2as!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '4cb51f6b-50be-0006-cf9c-25c385f61e40',
  'gabriel.matute.294a08ff@apsl.player',
  'Gabriel',
  'Matute',
  crypt('Playerpsbvm26g!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e5d4d925-f466-0006-f20a-032c43eb1d7f',
  'aidan.meissler.294a08ff@apsl.player',
  'Aidan',
  'Meissler',
  crypt('Playeryizypzci!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '1d318d31-a7df-0006-b874-24cbd65e7938',
  'glenn.moyer.294a08ff@apsl.player',
  'Glenn',
  'Moyer',
  crypt('Playerzv17osw9!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c569a669-6ad3-0006-1674-025adc8f95a5',
  'kyle.mtshazo.294a08ff@apsl.player',
  'Kyle',
  'Mtshazo',
  crypt('Playerf8iso58x!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '445eaea8-b547-0006-520a-df103335510e',
  'daniel.murtagh.294a08ff@apsl.player',
  'Daniel',
  'Murtagh',
  crypt('Playereixmz8gm!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd2ff88b2-4803-0006-614c-3f5861963ff9',
  'justin.odoemene.294a08ff@apsl.player',
  'Justin',
  'Odoemene',
  crypt('Playerjqeibl8n!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f3f76a07-6ebb-0006-5864-e904be625495',
  'ryan.pereus.294a08ff@apsl.player',
  'Ryan',
  'Pereus',
  crypt('Player59cq57k8!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '9b1b152b-fd16-0006-82cb-df0e8f9c03ac',
  'christopher.rodriguez.294a08ff@apsl.player',
  'Christopher',
  'Rodriguez',
  crypt('Playerfb8t4hgr!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '77b15275-e972-0006-c1a5-9fb831d3b337',
  'eran.shifris.294a08ff@apsl.player',
  'Eran',
  'Shifris',
  crypt('Playertgbhf1kt!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '287bd74a-b462-0006-448f-0174adcd134d',
  'andres.velez.294a08ff@apsl.player',
  'Andres',
  'Velez',
  crypt('Playerrlli9j4c!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '30939ef1-3caf-0006-f5c3-842dc5a6597e',
  'seth.walker.294a08ff@apsl.player',
  'Seth',
  'Walker',
  crypt('Player4vhiygzs!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7e36ec31-3ad0-0006-96c9-d37bd0f48623',
  'john.steven.warren.294a08ff@apsl.player',
  'John',
  'Steven Warren',
  crypt('Playero0dwra1f!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Real Central NJ Soccer USERS
-- ========================================
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '86d51aa0-be25-0006-193b-db3e2adc4631',
  'djibi.tata.bah.5d95682c@apsl.player',
  'Djibi',
  'Tata Bah',
  crypt('Playergj8hvdee!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '35b1bc42-4f1e-0006-ded9-b9df3a34c5cf',
  'walter.barreto.5d95682c@apsl.player',
  'Walter',
  'Barreto',
  crypt('Playervbqd1fle!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '43413162-7882-0006-5d56-b71e555f9691',
  'james.bernstein.5d95682c@apsl.player',
  'James',
  'Bernstein',
  crypt('Playerhy3w011n!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd0292f9f-02dc-0006-06ee-75cf7adf5925',
  'pierre.bosquet.5d95682c@apsl.player',
  'Pierre',
  'Bosquet',
  crypt('Player05ljpir0!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c244cfb8-b093-0006-774a-eacd70542335',
  'erik.carchipulla.5d95682c@apsl.player',
  'Erik',
  'Carchipulla',
  crypt('Playera6entwop!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '18147fb2-d96a-0006-4857-e033c4bc4f26',
  'filippo.d.anna.5d95682c@apsl.player',
  'Filippo',
  'D''Anna',
  crypt('Player8w6wxceo!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b4526f39-7e27-0006-eee2-a89b63af889e',
  'jonathan.firmino.5d95682c@apsl.player',
  'Jonathan',
  'Firmino',
  crypt('Playermdbqqzjq!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'fe568cfe-11cb-0006-3574-4e8e598c776e',
  'jose.tony.flores.5d95682c@apsl.player',
  'Jose',
  '(Tony) Flores',
  crypt('Player5gzluldg!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e45c7edf-df0e-0006-1633-4653a2f8a3c2',
  'liam.fredericks.5d95682c@apsl.player',
  'Liam',
  'Fredericks',
  crypt('Playerur588197!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '6d4f96c4-14e0-0006-e08b-170b463b4edf',
  'eric.goldberg.5d95682c@apsl.player',
  'Eric',
  'Goldberg',
  crypt('Playeran0mt7ld!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b1bbae49-4fc5-0006-1db2-7b7fd6536ad4',
  'lorenzo.jayakanthan.5d95682c@apsl.player',
  'Lorenzo',
  'Jayakanthan',
  crypt('Playernb1b31bz!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c873d9ec-eef6-0006-a865-3f32b5e09c36',
  'taeus.jones.5d95682c@apsl.player',
  'Taeus',
  'Jones',
  crypt('Playerc91z1ot4!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5093c74f-9ade-0006-a102-19d78a9aac18',
  'brendan.kerins.5d95682c@apsl.player',
  'Brendan',
  'Kerins',
  crypt('Playeraxaj8i6g!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'dab4223f-fc7f-0006-4d2d-a7ff6c296cd5',
  'sean.ryan.milelli.5d95682c@apsl.player',
  'Sean',
  'Ryan Milelli',
  crypt('Playertyy7hso5!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5f8f41f3-183f-0006-a400-f08ef20db0e1',
  'conlan.michael.paventi.5d95682c@apsl.player',
  'Conlan',
  'Michael Paventi',
  crypt('Playermvwfd4hn!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a95fd652-5fce-0006-4adb-c8d9dbfe5421',
  'kevin.perez.5d95682c@apsl.player',
  'Kevin',
  'Perez',
  crypt('Player3pg4cluh!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '2268ea79-4d94-0006-0405-8b7d22b68d60',
  'giovanni.pierleonardi.5d95682c@apsl.player',
  'Giovanni',
  'Pierleonardi',
  crypt('Player0y9lu58v!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'cd79bce6-dcf9-0006-efbc-6da8fe9f09b5',
  'giuseppe.pierleonardi.5d95682c@apsl.player',
  'Giuseppe',
  'Pierleonardi',
  crypt('Playerruq12v0v!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a47a3208-71ee-0006-f734-0e9edf876ad6',
  'guiliano.pierleonardi.5d95682c@apsl.player',
  'Guiliano',
  'Pierleonardi',
  crypt('Playerni2dedx5!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '1b2b5528-15b8-0006-17e4-bb120dbed317',
  'vincenzo.pugliese.5d95682c@apsl.player',
  'Vincenzo',
  'Pugliese',
  crypt('Playerenz55xwu!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f8c2ad45-eb32-0006-558f-9243f57f3d01',
  'joel.quist.5d95682c@apsl.player',
  'Joel',
  'Quist',
  crypt('Playere4urca7v!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd500b3ed-3494-0006-be2c-242a2025d9d0',
  'dennis.rooney.5d95682c@apsl.player',
  'Dennis',
  'Rooney',
  crypt('Playerafh6atyg!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '1ac818b2-8c87-0006-0c07-ee686030fe48',
  'ilia.sakheishvili.5d95682c@apsl.player',
  'Ilia',
  'Sakheishvili',
  crypt('Playerchavum9o!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'bfd119b4-ce47-0006-27fc-97aeb536d1f6',
  'cole.sotack.5d95682c@apsl.player',
  'Cole',
  'Sotack',
  crypt('Playerb39ghhgp!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'fcb29f52-86c8-0006-9d89-d9194f1d9477',
  'reed.sviben.5d95682c@apsl.player',
  'Reed',
  'Sviben',
  crypt('Playerekhs5moj!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '68a552ca-73e0-0006-9f60-eb800ec5e1bd',
  'brandon.d.valeri.5d95682c@apsl.player',
  'Brandon',
  'D Valeri',
  crypt('Playerli6e6cci!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '6b595c01-24db-0006-8754-89f6298a6d58',
  'ronald.ventura.5d95682c@apsl.player',
  'Ronald',
  'Ventura',
  crypt('Playerufh6pydh!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Vidas United FC USERS
-- ========================================
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '07e8cd0c-8ccf-0006-707d-3add15aeb8da',
  'emani.arroyo.3dd92f09@apsl.player',
  'Emani',
  'Arroyo',
  crypt('Playerhcwihha2!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c466ff26-125b-0006-da01-94c3ece9fe2f',
  'nolan.bair.3dd92f09@apsl.player',
  'Nolan',
  'Bair',
  crypt('Player1yqtxnyg!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b3a4953a-6ccc-0006-2a2c-e8f00911e2ae',
  'almuthenna.hseen.baled.3dd92f09@apsl.player',
  'Almuthenna',
  'Hseen Baled',
  crypt('Playerzj3g8nof!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '3852c479-f1e8-0006-5176-079202b770c4',
  'richard.blanchard.3dd92f09@apsl.player',
  'Richard',
  'Blanchard',
  crypt('Player7doubjor!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ee0829ea-5c96-0006-da85-f155a15be98c',
  'bakuri.buadze.3dd92f09@apsl.player',
  'Bakuri',
  'Buadze',
  crypt('Playeres3di3t7!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e1f24d22-9ee9-0006-fbaa-bb38bb3a5375',
  'maximo.chavez.3dd92f09@apsl.player',
  'Maximo',
  'Chavez',
  crypt('Playerl4d0lmtm!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7f88e917-d531-0006-6b0f-714b3dc1994d',
  'evan.chinwendu.azoro.3dd92f09@apsl.player',
  'Evan',
  'Chinwendu Azoro',
  crypt('Playerro7ju1zh!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '1fabdff6-2b87-0006-c19a-56b2f4cbd91d',
  'adan.crispin.morales.3dd92f09@apsl.player',
  'Adan',
  'Crispin-Morales',
  crypt('Player5ajpf6mk!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f10de78a-a2f5-0006-c690-2a8d548fc5ce',
  'jorge.luis.diaz.lobo.3dd92f09@apsl.player',
  'Jorge',
  'Luis Diaz Lobo',
  crypt('Playero5jdvy47!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b10aa613-4f83-0006-a7ba-ff36dec80c0c',
  'spencer.dickinson.3dd92f09@apsl.player',
  'Spencer',
  'Dickinson',
  crypt('Playerq8nph4dp!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd93b3955-5647-0006-a808-2755eac9fdb8',
  'isaiah.fox.3dd92f09@apsl.player',
  'Isaiah',
  'Fox',
  crypt('Playerewlto06l!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '8e84bde8-8c61-0006-bcbd-908578cfc12d',
  'goga.gogoladze.3dd92f09@apsl.player',
  'Goga',
  'Gogoladze',
  crypt('Playerhvd1csod!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '43315a90-8c07-0006-c8bb-808a1ef36cec',
  'stephen.grazioli.3dd92f09@apsl.player',
  'Stephen',
  'Grazioli',
  crypt('Playerzdwmouxf!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '28f09349-70fa-0006-9b86-deeb6f3a865b',
  'mohamed.ibrahim.3dd92f09@apsl.player',
  'Mohamed',
  'Ibrahim',
  crypt('Playerzu2ou1gq!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c1cef24c-cd31-0006-2a5f-fe542053ae27',
  'matthew.jeanpierre.3dd92f09@apsl.player',
  'Matthew',
  'JeanPierre',
  crypt('Playerxp56gxj9!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '8ee042d2-ec1b-0006-7365-4300a9657803',
  'mohammadzain.kazi.3dd92f09@apsl.player',
  'Mohammadzain',
  'Kazi',
  crypt('Playerzlr2rajc!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '47331ae4-1b98-0006-0aaa-114c9e6e8c72',
  'guilherme.martins.3dd92f09@apsl.player',
  'Guilherme',
  'Martins',
  crypt('Player0zafllql!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'fcc5d2b9-0379-0006-eea1-57755f8fb2c5',
  'john.miller.3dd92f09@apsl.player',
  'John',
  'Miller',
  crypt('Playerodjp03yc!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '04f6fa3d-fe6e-0006-ae7a-861415434260',
  'edwin.owusu.siaw.3dd92f09@apsl.player',
  'Edwin',
  'Owusu Siaw',
  crypt('Playernrwswtr2!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '64ef506d-0c36-0006-43c7-b8d26236d30e',
  'juan.polanco.3dd92f09@apsl.player',
  'Juan',
  'Polanco',
  crypt('Playerpstjmg7p!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ff7f3a3b-4770-0006-439f-ead095ec0449',
  'angel.javier.rodriguez.3dd92f09@apsl.player',
  'Angel',
  'Javier Rodriguez',
  crypt('Player07nblqsi!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ac8d9e83-4310-0006-4509-180df564e5db',
  'ahmed.saedahmed.3dd92f09@apsl.player',
  'Ahmed',
  'Saedahmed',
  crypt('Player80o5o5ti!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7267e085-fbd2-0006-1d8d-0b5af04a0261',
  'edi.schwartz.3dd92f09@apsl.player',
  'Edi',
  'Schwartz',
  crypt('Playerb9sxgfiq!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e70c4f3f-eae7-0006-ed35-3fe58a4fee37',
  'maksym.shevchenko.3dd92f09@apsl.player',
  'Maksym',
  'Shevchenko',
  crypt('Player5wy9xi5g!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '2bfde7e9-6e52-0006-fdd6-a94d0989fe28',
  'alexander.simon.3dd92f09@apsl.player',
  'Alexander',
  'Simon',
  crypt('Playerhizlqmna!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5565c7c4-c50d-0006-8e55-b704a3cac296',
  'daniel.smith.3dd92f09@apsl.player',
  'Daniel',
  'Smith',
  crypt('Playerwvv016qt!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '13b1aaa4-f205-0006-4f9d-e6476b707f5b',
  'christian.sorteberg.3dd92f09@apsl.player',
  'Christian',
  'Sorteberg',
  crypt('Playeryxl0xj9o!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '03ec51ee-52f3-0006-910c-ba2407fb16b9',
  'sekou.sylla.3dd92f09@apsl.player',
  'Sekou',
  'Sylla',
  crypt('Player1yrenm2f!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '8aa059ed-5b5b-0006-da67-6538d4b43523',
  'abraham.waldman.3dd92f09@apsl.player',
  'Abraham',
  'Waldman',
  crypt('Playerrlxkaq77!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Philadelphia Soccer Club USERS
-- ========================================
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a9ba68f3-0f7f-0006-358d-fd63a7689123',
  'mark.abbonizio.907ece9f@apsl.player',
  'Mark',
  'Abbonizio',
  crypt('Playerlud9x7en!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ae04becd-a47b-0006-5a96-4c38531d03d4',
  'sergio.abelardy.907ece9f@apsl.player',
  'Sergio',
  'Abelardy',
  crypt('Playerls24mwda!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '72e4776c-5809-0006-e317-9cf118445bd7',
  'pedro.barbosa.907ece9f@apsl.player',
  'Pedro',
  'Barbosa',
  crypt('Playeranzrcob9!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '719d9258-cf7e-0006-8eb2-ffb5f0a6d894',
  'hunter.bell.907ece9f@apsl.player',
  'Hunter',
  'Bell',
  crypt('Player57nphvl9!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '6b4d97c5-783b-0006-e858-7e43a4e3a710',
  'mohamed.elgayar.907ece9f@apsl.player',
  'Mohamed',
  'Elgayar',
  crypt('Player6z3dwlwj!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '2c0045fc-8936-0006-4901-3005a950d5fb',
  'salvatore.ficarotta.907ece9f@apsl.player',
  'Salvatore',
  'Ficarotta',
  crypt('Playerwx4tqqwy!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd0fa7536-1fb8-0006-b191-b96070d0cd69',
  'henry.guzman.907ece9f@apsl.player',
  'Henry',
  'Guzman',
  crypt('Playercbm65ld3!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '965482bc-020a-0006-7e19-24e46a2f2557',
  'theophilus.ijeboi.907ece9f@apsl.player',
  'Theophilus',
  'Ijeboi',
  crypt('Player4gfou8wm!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'dfb495f3-ad0d-0006-4a63-f277ab99a9e5',
  'mohamed.jawara.907ece9f@apsl.player',
  'Mohamed',
  'Jawara',
  crypt('Player06jl0tme!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c962643d-da84-0006-abf0-3cee898b0284',
  'sean.murray.907ece9f@apsl.player',
  'Sean',
  'Murray',
  crypt('Playera5202vqv!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '1bace6e6-6191-0006-654e-438eae1d01c7',
  'laurence.narcisi.907ece9f@apsl.player',
  'Laurence',
  'Narcisi',
  crypt('Player4qi4b7sn!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '64205475-7ea5-0006-c157-b58d5f8e7352',
  'michael.newell.907ece9f@apsl.player',
  'Michael',
  'Newell',
  crypt('Playerfc98gao2!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '9d94f51c-9581-0006-b91e-6704c9277f7e',
  'kaleb.raymond.907ece9f@apsl.player',
  'Kaleb',
  'Raymond',
  crypt('Playerzx12eclj!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '43cd8a37-250f-0006-0f1f-2dc468827103',
  'joel.richmond.907ece9f@apsl.player',
  'Joel',
  'Richmond',
  crypt('Playere2c9iwjw!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '52e2cae2-d9ac-0006-554f-de40933cc1c8',
  'benjamin.richter.907ece9f@apsl.player',
  'Benjamin',
  'Richter',
  crypt('Playerxxd3duxt!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e92ba81a-e412-0006-e30c-0ed3b9f606e2',
  'joshua.rifkin.907ece9f@apsl.player',
  'Joshua',
  'Rifkin',
  crypt('Playerhjjbx259!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '4f0ca7b3-0687-0006-b5ca-ae8876879ca5',
  'daniel.saint.pol.907ece9f@apsl.player',
  'Daniel',
  'Saint-Pol',
  crypt('Playerqtfv92y5!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '2933ab46-31c8-0006-221d-5f7dfabcd0a9',
  'david.skiendzielewski.907ece9f@apsl.player',
  'David',
  'Skiendzielewski',
  crypt('Playerm21s5pse!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '33988cd2-c5b4-0006-6f0e-764693b44a97',
  'owen.stock.907ece9f@apsl.player',
  'Owen',
  'Stock',
  crypt('Playerxobv21hm!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '20223cdc-63ce-0006-8a49-05e9f504fa48',
  'ryan.stock.907ece9f@apsl.player',
  'Ryan',
  'Stock',
  crypt('Playerw878teh6!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'bf24ae90-55f7-0006-180e-162c9b2c4f35',
  'rasheed.thomas.907ece9f@apsl.player',
  'Rasheed',
  'Thomas',
  crypt('Playerm56odx7k!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ef84510d-4ce7-0006-43ca-f65fc4d0ede9',
  'sean.touey.907ece9f@apsl.player',
  'Sean',
  'Touey',
  crypt('Player17fgyxyi!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '2d7f675c-563a-0006-2dfd-c9692bbc5d9f',
  'jesse.weick.907ece9f@apsl.player',
  'Jesse',
  'Weick',
  crypt('Playertktoqnm7!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Oaklyn United FC USERS
-- ========================================
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '71df8607-2764-0006-be4f-f62b9022a409',
  'osman.barrie.c2402f6c@apsl.player',
  'Osman',
  'Barrie',
  crypt('Playerl1kj0v1e!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5799be88-db80-0006-f9ef-3df307a698c3',
  'paul.bechtelheimer.c2402f6c@apsl.player',
  'Paul',
  'Bechtelheimer',
  crypt('Playerx9p78uvq!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'cbd4f193-e8d8-0006-b980-4cce087170b4',
  'nathan.biersbach.c2402f6c@apsl.player',
  'Nathan',
  'Biersbach',
  crypt('Playerz05ji5hz!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '78c995a8-6426-0006-330c-e738344e92fa',
  'brayden.birnstiel.c2402f6c@apsl.player',
  'Brayden',
  'Birnstiel',
  crypt('Playerq09pwnsa!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '85f9b46e-9ec5-0006-998b-b595bfef6d83',
  'theo.da.silva.c2402f6c@apsl.player',
  'Theo',
  'Da Silva',
  crypt('Playerobvrac1f!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '35f70e2e-8c57-0006-5f5d-a7f450d84339',
  'kaelan.debbage.c2402f6c@apsl.player',
  'Kaelan',
  'Debbage',
  crypt('Player2h9note9!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd846eb32-8018-0006-f104-98587d54395d',
  'blake.driehuis.c2402f6c@apsl.player',
  'Blake',
  'Driehuis',
  crypt('Playeri5nfwpo6!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '106939cb-a4c7-0006-03ac-8261cc90d806',
  'gavin.faracchio.c2402f6c@apsl.player',
  'Gavin',
  'Faracchio',
  crypt('Playerjcnpcf7k!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '9d5dce99-7e66-0006-dcf4-6880c44244c1',
  'emin.gunaydin.c2402f6c@apsl.player',
  'Emin',
  'Gunaydin',
  crypt('Playerdip4auzf!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd39431ba-d80b-0006-a7d5-62fddc3a4727',
  'vincent.guzzo.c2402f6c@apsl.player',
  'Vincent',
  'Guzzo',
  crypt('Playerk3hem7rv!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '60a07d61-7b5e-0006-0b32-d3677eb2dcfc',
  'maxwell.byrd.hawk.c2402f6c@apsl.player',
  'Maxwell',
  'Byrd Hawk',
  crypt('Playert84uczlk!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '02cd6efc-7b96-0006-ca40-f23545453cb5',
  'anthony.jenkins.c2402f6c@apsl.player',
  'Anthony',
  'Jenkins',
  crypt('Playerbbljt8sj!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '029f4f0c-02ac-0006-18e9-3c393b8d02d6',
  'austin.johnson.c2402f6c@apsl.player',
  'Austin',
  'Johnson',
  crypt('Playermz1zz6sr!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '06afadb4-7733-0006-4d6d-191596b99910',
  'sincere.kato.c2402f6c@apsl.player',
  'Sincere',
  'Kato',
  crypt('Playernyg5n7u6!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '562059bc-79d0-0006-f3f2-b383e1e8ddf3',
  'muhammed.ali.kol.c2402f6c@apsl.player',
  'Muhammed',
  'Ali Kol',
  crypt('Player6zgh8cmu!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '8ea1cdc4-0882-0006-5a0b-c3a308b287f2',
  'berlenz.lumarque.c2402f6c@apsl.player',
  'Berlenz',
  'Lumarque',
  crypt('Playerho1iatdq!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '0dfa7220-ee26-0006-829d-a9265ac259c3',
  'jason.mancuso.c2402f6c@apsl.player',
  'Jason',
  'Mancuso',
  crypt('Playeror7t43o5!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c22c0a10-052b-0006-ee1e-9ffac117ebea',
  'jade.mesias.c2402f6c@apsl.player',
  'Jade',
  'Mesias',
  crypt('Playerp7vhyrq2!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b7c66ebe-25a9-0006-9eaf-6715c42b61c2',
  'jeff.morgan.c2402f6c@apsl.player',
  'Jeff',
  'Morgan',
  crypt('Playerj36ve1rg!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '03685128-c258-0006-7b3e-65e96d6cb14e',
  'jake.mulinge.c2402f6c@apsl.player',
  'Jake',
  'Mulinge',
  crypt('Playerulgimaf5!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '80b973f9-ae54-0006-2fab-9bf2c4583f2f',
  'joseph.nguyen.c2402f6c@apsl.player',
  'Joseph',
  'Nguyen',
  crypt('Playerbozqzk0m!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ae70b5a1-d1de-0006-48b1-ed3fd75f5c55',
  'matthew.perrella.c2402f6c@apsl.player',
  'Matthew',
  'Perrella',
  crypt('Playerwpojizlu!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '31ce6bd2-40c1-0006-a3f0-0c57e0a14847',
  'samuel.quaye.c2402f6c@apsl.player',
  'Samuel',
  'Quaye',
  crypt('Playerprd9dc73!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '8a0a6f35-57d8-0006-ad2d-18b037714c72',
  'julito.quintana.c2402f6c@apsl.player',
  'Julito',
  'Quintana',
  crypt('Playerpbjvtqe0!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '2c2c7d61-fde8-0006-1396-b9747a713457',
  'ethan.romito.c2402f6c@apsl.player',
  'Ethan',
  'Romito',
  crypt('Player5ja8xff2!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'fdea7ec3-67b0-0006-2e92-7876591b7854',
  'ahmed.saidi.c2402f6c@apsl.player',
  'Ahmed',
  'Saidi',
  crypt('Playerixwidgx1!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd2509fe2-42ad-0006-bf78-24ba4885ea4c',
  'seth.sidle.c2402f6c@apsl.player',
  'Seth',
  'Sidle',
  crypt('Playersd851bkw!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '85308641-904a-0006-265b-a8660dd49ced',
  'adam.sternberger.c2402f6c@apsl.player',
  'Adam',
  'Sternberger',
  crypt('Playerf97qfi3m!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a02363ec-3315-0006-1d6e-e6943eee6ca5',
  'steven.thompson.c2402f6c@apsl.player',
  'Steven',
  'Thompson',
  crypt('Playerkfu58h6s!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ee75d842-1ae6-0006-8c53-9d885fc74c26',
  'nico.tramontana.c2402f6c@apsl.player',
  'Nico',
  'Tramontana',
  crypt('Player2d08fx90!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- GAK USERS
-- ========================================
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c6634ec4-3116-0006-97cb-10929f847d88',
  'geovany.acevedo.f11cc01a@apsl.player',
  'Geovany',
  'Acevedo',
  crypt('Playerwzd0ombr!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '8c057fae-c618-0006-afe4-0bca248a8f23',
  'axel.bladimir.f11cc01a@apsl.player',
  'Axel',
  'Bladimir',
  crypt('Playera9cxfxai!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd7fbbe6c-af7c-0006-a7f5-21289ec00427',
  'julien.carraha.f11cc01a@apsl.player',
  'Julien',
  'Carraha',
  crypt('Player4sc27gr8!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f51d3955-418f-0006-7089-6cba763c51ba',
  'nicholas.cruz.f11cc01a@apsl.player',
  'Nicholas',
  'Cruz',
  crypt('Player7c54ktt6!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7a6f6516-397c-0006-7d94-d1ea3c0ca3f9',
  'aba.david.f11cc01a@apsl.player',
  'Aba',
  'David',
  crypt('Player5jjapezo!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '35d32d60-a2ed-0006-341a-55683e159c03',
  'jonah.dias.f11cc01a@apsl.player',
  'Jonah',
  'Dias',
  crypt('Playerc8k0mk2o!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '8aab63f1-c4c6-0006-32ff-583e6a12263c',
  'mamadou.diouf.f11cc01a@apsl.player',
  'Mamadou',
  'Diouf',
  crypt('Playere774ncsk!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '9fb18392-3760-0006-95a4-ef5fddde7950',
  'oliver.dyson.f11cc01a@apsl.player',
  'Oliver',
  'Dyson',
  crypt('Playerkrlnbcod!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '81751f47-3547-0006-ed06-174be04b84dd',
  'robert.ellerson.f11cc01a@apsl.player',
  'Robert',
  'Ellerson',
  crypt('Player4o8c9yfk!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '0888b0b4-487c-0006-fa70-cea0d131771c',
  'carlos.fuentes.f11cc01a@apsl.player',
  'Carlos',
  'Fuentes',
  crypt('Playerr61yxv6t!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a0ba6bb8-a359-0006-957a-b3c1a5111aed',
  'randy.gonzalez.f11cc01a@apsl.player',
  'Randy',
  'Gonzalez',
  crypt('Playerhwfrpuat!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5030ea77-ddfe-0006-1fb4-428e8701c150',
  'daniel.grund.f11cc01a@apsl.player',
  'Daniel',
  'Grund',
  crypt('Player23h0231f!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c1a269c4-7f62-0006-2b52-f4665c63f46c',
  'ryan.grund.f11cc01a@apsl.player',
  'Ryan',
  'Grund',
  crypt('Playerykaw4w2e!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e79a8f46-0fdb-0006-ad87-40a83df9316a',
  'chidi.iloka.f11cc01a@apsl.player',
  'Chidi',
  'Iloka',
  crypt('Playersgdp7df7!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd8d39dca-cf6c-0006-d693-02d484a00311',
  'davenson.joinvilmar.f11cc01a@apsl.player',
  'Davenson',
  'Joinvilmar',
  crypt('Player12xrk6g2!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd8ba57f8-b7bd-0006-4e4c-956bac1c2900',
  'dylan.kotch.f11cc01a@apsl.player',
  'Dylan',
  'Kotch',
  crypt('Playersnggpr7h!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '75401479-549d-0006-01f2-505157115e85',
  'liam.macdonald.f11cc01a@apsl.player',
  'Liam',
  'MacDonald',
  crypt('Playery04msic2!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '3c37f45a-0aed-0006-7fa2-77f3467e5de7',
  'anderson.martinez.f11cc01a@apsl.player',
  'Anderson',
  'Martinez',
  crypt('Playerbeq5urst!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '9d527478-a389-0006-46aa-2dfb9aac6b3a',
  'arnaldo.mendoza.f11cc01a@apsl.player',
  'Arnaldo',
  'Mendoza',
  crypt('Playerjcm7p3px!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7e42fc98-b13e-0006-1dc3-c70b98e4b21d',
  'dani.morales.f11cc01a@apsl.player',
  'Dani',
  'Morales',
  crypt('Player4qq259u6!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '9c7f4fef-d2d3-0006-8a52-407f71a1ea9f',
  'lucknerson.pierre.f11cc01a@apsl.player',
  'Lucknerson',
  'Pierre',
  crypt('Playerr60zhq9r!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a695b106-8071-0006-ec89-9777f3460789',
  'kyle.pilliteri.f11cc01a@apsl.player',
  'Kyle',
  'Pilliteri',
  crypt('Player9dqkt3o2!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '3f57ba68-1014-0006-bc01-aa1cf4c3698e',
  'alex.quezada.f11cc01a@apsl.player',
  'Alex',
  'Quezada',
  crypt('Playeru0w28hgy!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '3f240fc1-f882-0006-09d4-058b0609ab21',
  'wesley.reyes.f11cc01a@apsl.player',
  'Wesley',
  'Reyes',
  crypt('Playersfiusb9k!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a9792982-fd05-0006-a548-363d171b95e9',
  'arnol.rodriguez.f11cc01a@apsl.player',
  'Arnol',
  'Rodriguez',
  crypt('Playern1xfvljr!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '652319d6-5062-0006-a0aa-018bace24cc1',
  'nick.sample.f11cc01a@apsl.player',
  'Nick',
  'Sample',
  crypt('Playeri90hygda!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c05fc6df-acb1-0006-62db-d02e7a9e6960',
  'melvin.sapon.f11cc01a@apsl.player',
  'Melvin',
  'Sapon',
  crypt('Playernk9ug718!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a9d06281-f304-0006-521e-1adca8723c9b',
  'chefetson.simeus.f11cc01a@apsl.player',
  'Chefetson',
  'Simeus',
  crypt('Playern4llc44k!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '54d14e1e-2f6d-0006-32cd-f0d343e0cca1',
  'emerson.vicente.f11cc01a@apsl.player',
  'Emerson',
  'Vicente',
  crypt('Playermsjn5375!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '0478cdd5-c6a4-0006-de9e-aa4ccd100674',
  'mate.vilagosi.f11cc01a@apsl.player',
  'Mate',
  'Vilagosi',
  crypt('Player0smmum3p!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a845b6de-d2ac-0006-cb5f-fec49ee7bda0',
  'john.warwick.f11cc01a@apsl.player',
  'John',
  'Warwick',
  crypt('Playern5aeg056!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Lighthouse 1893 SC USERS
-- ========================================
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '01aca9b0-ae64-0006-e96d-7e69a00ffec4',
  'musa.abdelgadir.d37eb44b@apsl.player',
  'Musa',
  'Abdelgadir',
  crypt('Player4mvaf2q1!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e7b6e3e7-4b6c-0006-c471-183c094b8b51',
  'amar.abdelrazek.d37eb44b@apsl.player',
  'Amar',
  'Abdelrazek',
  crypt('Playerd06hbju2!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '326e6bc0-e8ed-0006-62b1-b4e94dd6a079',
  'abdelrahman.ali.d37eb44b@apsl.player',
  'Abdelrahman',
  'Ali',
  crypt('Playertp97aqzt!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '1089a0ee-8eb6-0006-d3d5-20bf6ba6ee7a',
  'ahmed.ali.d37eb44b@apsl.player',
  'Ahmed',
  'Ali',
  crypt('Player5k26yspv!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '52737162-6e42-0006-4a28-377d5fbdb22a',
  'erwa.babiker.d37eb44b@apsl.player',
  'Erwa',
  'Babiker',
  crypt('Playeraopx3su5!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '769b5796-c33c-0006-69b6-bc37abae18bf',
  'arsene.bado.d37eb44b@apsl.player',
  'Arsene',
  'Bado',
  crypt('Playeraubfriw6!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f5dfe66e-8e08-0006-ff59-107bf2898b1a',
  'logan.bersani.d37eb44b@apsl.player',
  'Logan',
  'Bersani',
  crypt('Playerr831kmyf!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'dd7d3571-d69e-0006-7979-7a2ce126dac6',
  'mohamed.bility.d37eb44b@apsl.player',
  'Mohamed',
  'Bility',
  crypt('Player3ewacw3a!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '326e8020-b576-0006-761c-7e233e2fbba2',
  'hamzah.dabbour.d37eb44b@apsl.player',
  'Hamzah',
  'Dabbour',
  crypt('Playermswgfjuq!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '97b0d643-5b54-0006-be6b-066460c214b1',
  'terrence.doe.d37eb44b@apsl.player',
  'Terrence',
  'Doe',
  crypt('Player9qnuden7!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f9e55725-38a4-0006-4da9-32f792737ce3',
  'musa.donza.d37eb44b@apsl.player',
  'Musa',
  'Donza',
  crypt('Player9xvu20ny!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '8194c8f3-e9b5-0006-1b83-b544991ee783',
  'alexander.duopu.d37eb44b@apsl.player',
  'Alexander',
  'Duopu',
  crypt('Playerb2va3jga!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '6f56fb40-d2e7-0006-962f-ecf2b2125067',
  'luis.espejo.d37eb44b@apsl.player',
  'Luis',
  'Espejo',
  crypt('Playeraqos3455!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '68b0bb11-c853-0006-7aca-7a06730bac1c',
  'christopher.fletcher.d37eb44b@apsl.player',
  'Christopher',
  'Fletcher',
  crypt('Player69r50yyl!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '49385a1c-d37b-0006-f0c9-dac164502d9b',
  'mujtaba.galas.d37eb44b@apsl.player',
  'Mujtaba',
  'Galas',
  crypt('Playerv0zsw12v!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'df029c0e-28c8-0006-5da8-18ab2837dcaa',
  'mustafa.galas.d37eb44b@apsl.player',
  'Mustafa',
  'Galas',
  crypt('Playerb3vv2lwg!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ce93b48a-1f6b-0006-e2c1-47799cfcfff5',
  'john.gonzalez.d37eb44b@apsl.player',
  'John',
  'Gonzalez',
  crypt('Playerxx0qw5y9!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b128734e-616a-0006-94f9-740b7dab4b61',
  'ahmed.gosie.d37eb44b@apsl.player',
  'Ahmed',
  'Gosie',
  crypt('Playeri65wn6et!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '3cb5f823-9e5d-0006-e69f-35b97baec652',
  'maccarrey.guillaume.d37eb44b@apsl.player',
  'Maccarrey',
  'Guillaume',
  crypt('Playerq9jzwj6x!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'aecf8394-3dea-0006-c777-facfc9af77f9',
  'otmane.houasli.d37eb44b@apsl.player',
  'Otmane',
  'Houasli',
  crypt('Player5lizlm8n!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '4d8fb2ee-241e-0006-98a8-9f87f7b4be5a',
  'esnayder.josue.d37eb44b@apsl.player',
  'Esnayder',
  'Josue',
  crypt('Playerq9f1kpg6!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '57ae3eff-d209-0006-409d-b97ebabee860',
  'abdoulaye.kamagate.d37eb44b@apsl.player',
  'Abdoulaye',
  'Kamagate',
  crypt('Playernzxdgxka!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '1058e8dc-f991-0006-3421-156e9aae5a81',
  'amadou.kamagate.d37eb44b@apsl.player',
  'Amadou',
  'Kamagate',
  crypt('Playerlwd8oskl!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '70b36e4b-b5bd-0006-dd9c-f58dfcd5c239',
  'majid.kawa.d37eb44b@apsl.player',
  'Majid',
  'Kawa',
  crypt('Playernq9z8oo9!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '23dd5826-bb2e-0006-4dd3-59927f01b65e',
  'mohamed.khalafalla.d37eb44b@apsl.player',
  'Mohamed',
  'Khalafalla',
  crypt('Playerjivn5vov!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '87d3f035-c0d4-0006-ee7b-0637fb8b40fd',
  'kouassi.nguessan.d37eb44b@apsl.player',
  'Kouassi',
  'Nguessan',
  crypt('Playerlpy8cdd9!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f57ec0ec-24ef-0006-a2f7-0aad81711c11',
  'benell.saygarn.d37eb44b@apsl.player',
  'Benell',
  'Saygarn',
  crypt('Player3nic8kya!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '0af0fa43-db02-0006-b625-bf47c0eb6099',
  'oumar.sylla.d37eb44b@apsl.player',
  'Oumar',
  'Sylla',
  crypt('Player2mtdwq76!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Jersey Shore Boca USERS
-- ========================================
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e5489cab-1ff6-0006-7ba7-7b04f178d0f9',
  'justin.alves.7288846b@apsl.player',
  'Justin',
  'Alves',
  crypt('Playerne3n23mm!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '1bbff203-f549-0006-9605-bfe8251d9914',
  'rob.andrade.7288846b@apsl.player',
  'Rob',
  'Andrade',
  crypt('Playeryfa2xvh1!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '9e91d86b-35c2-0006-b841-c082d5825af0',
  'tyler.andreas.7288846b@apsl.player',
  'Tyler',
  'Andreas',
  crypt('Player86iq6uoq!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '31994764-1fe4-0006-bc86-ce0a4b68bbbe',
  'william.bartels.7288846b@apsl.player',
  'William',
  'Bartels',
  crypt('Playervietu726!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '52936b80-8e59-0006-0fc4-85ccda24d91c',
  'harmony.bell.gam.7288846b@apsl.player',
  'Harmony',
  'Bell-Gam',
  crypt('Playerr4wzt2ji!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e25db64e-fe6e-0006-190f-d87dcf9dad2d',
  'dane.calhoun.7288846b@apsl.player',
  'Dane',
  'Calhoun',
  crypt('Playerf8j5gqa4!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '73f34efc-6372-0006-9dc0-d133eefe09c6',
  'adrian.dilascio.7288846b@apsl.player',
  'Adrian',
  'Dilascio',
  crypt('Playerbfttkv8m!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '8abc7a91-74ac-0006-8d9c-15adf9f405ab',
  'grady.edwards.7288846b@apsl.player',
  'Grady',
  'Edwards',
  crypt('Player95hkiom0!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '921bc389-af8a-0006-313c-7cd6526a255d',
  'matt.fuentes.7288846b@apsl.player',
  'Matt',
  'Fuentes',
  crypt('Playerg9ks16ko!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '4a253e7a-7dfc-0006-2a37-2ee6bc89c4e3',
  'douglas.jensen.7288846b@apsl.player',
  'Douglas',
  'Jensen',
  crypt('Playerxrep5cyx!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ecec0332-f886-0006-960c-691a358e9193',
  'dylan.kanson.7288846b@apsl.player',
  'Dylan',
  'Kanson',
  crypt('Player5bog425i!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e33aff11-c818-0006-d022-1628d35160a9',
  'marcus.mason.7288846b@apsl.player',
  'Marcus',
  'Mason',
  crypt('Player5a1i6dni!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '52ce4b42-dcd8-0006-a26b-381fe16ff2f7',
  'carter.mathis.7288846b@apsl.player',
  'Carter',
  'Mathis',
  crypt('Playern8slhtm6!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '801582d5-d5a2-0006-8a55-ff1041b1d21b',
  'alex.matos.7288846b@apsl.player',
  'Alex',
  'Matos',
  crypt('Playerg4bl9g4s!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f8174808-81f6-0006-8c36-49a9fe9967f7',
  'rafael.pereira.7288846b@apsl.player',
  'Rafael',
  'Pereira',
  crypt('Playerg7x69ha8!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '6dcbe7ad-949d-0006-397c-138e5a82286d',
  'anthony.ryan.7288846b@apsl.player',
  'Anthony',
  'Ryan',
  crypt('Player3itflbq8!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b9dce495-41bd-0006-fde2-328e8693d33c',
  'bryan.sanchez.7288846b@apsl.player',
  'Bryan',
  'Sanchez',
  crypt('Playergcx7v9o8!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'fd714f3e-bd0e-0006-c240-7afae08290ec',
  'dante.shenkin.7288846b@apsl.player',
  'Dante',
  'Shenkin',
  crypt('Playerr539z5co!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a28a3152-af47-0006-f2d4-cd47e151ae81',
  'gianni.smith.7288846b@apsl.player',
  'Gianni',
  'Smith',
  crypt('Playercygrmmpa!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '3ad2a010-eaa8-0006-65bb-0ca2bc2067e1',
  'kieran.sundermann.7288846b@apsl.player',
  'Kieran',
  'Sundermann',
  crypt('Playerlf5xmyl9!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '422465c2-9bd8-0006-b5d4-898e2e13cb35',
  'albert.truszkowski.7288846b@apsl.player',
  'Albert',
  'Truszkowski',
  crypt('Playeryt6zo4i4!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd9739566-e50e-0006-d8c7-c2de6c5d715c',
  'uche.wokocha.7288846b@apsl.player',
  'Uche',
  'Wokocha',
  crypt('Playerxafnw0ho!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '461fb060-2fe3-0006-1aa1-5ab6b5312e57',
  'clay.yannazzone.7288846b@apsl.player',
  'Clay',
  'Yannazzone',
  crypt('Player7rtq9i97!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b7472afb-4a7e-0006-96bb-0e68d3872ae0',
  'alex.zargo.7288846b@apsl.player',
  'Alex',
  'Zargo',
  crypt('Playerele6qapd!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Sewell Old Boys FC USERS
-- ========================================
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f67ada13-a784-0006-ebe9-25878029ac0a',
  'dylan.frank.aportela.50720c09@apsl.player',
  'Dylan',
  'Frank Aportela',
  crypt('Playerozufazg2!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '9654b13d-c906-0006-5155-d62bf939456e',
  'monsif.atify.50720c09@apsl.player',
  'Monsif',
  'Atify',
  crypt('Playergrmknxlr!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'cd58ffbb-6004-0006-5e18-c6a854913706',
  'shane.baker.50720c09@apsl.player',
  'Shane',
  'Baker',
  crypt('Playervs5h9npv!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '40400f0a-dc66-0006-9cac-c6f2a3164647',
  'mava.mboko.celestin.50720c09@apsl.player',
  'Mava',
  'Mboko Celestin',
  crypt('Playera725ijew!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c3722096-f4b0-0006-dca0-cadb9fbf40e2',
  'gunnar.william.christensen.50720c09@apsl.player',
  'Gunnar',
  'William Christensen',
  crypt('Player6nzihzlk!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a424af65-6f03-0006-058c-a7a48d6652af',
  'bailey.cifone.50720c09@apsl.player',
  'Bailey',
  'Cifone',
  crypt('Playersy0yoy8p!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '99bedb6f-ad6f-0006-e76f-b805ceaac7c5',
  'emmett.dougherty.50720c09@apsl.player',
  'Emmett',
  'Dougherty',
  crypt('Playermsg9bt16!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7f78a7a4-91f8-0006-8b1e-e20ca1f4f8c4',
  'sean.fatiga.50720c09@apsl.player',
  'Sean',
  'Fatiga',
  crypt('Player2kfienc6!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '44f85cae-c76d-0006-01db-6b4a9d57cbaa',
  'gil.ferreira.50720c09@apsl.player',
  'Gil',
  'Ferreira',
  crypt('Playeragaj8dvw!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '9ca63f04-9f10-0006-8037-ea09de9c3d8d',
  'ryan.gale.50720c09@apsl.player',
  'Ryan',
  'Gale',
  crypt('Playerlq1z3qe0!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c302c071-2de9-0006-ebe8-64dfecdc632d',
  'elvis.gboho.50720c09@apsl.player',
  'Elvis',
  'Gboho',
  crypt('Playerpqhpk602!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'fc451354-f699-0006-52c2-7b35e330721e',
  'mccarthy.tyler.gomes.50720c09@apsl.player',
  'McCarthy',
  'Tyler Gomes',
  crypt('Playernx79jref!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b6902b1a-2cea-0006-91ca-d82ff4c21b47',
  'jeshohaih.hernandez.50720c09@apsl.player',
  'Jeshohaih',
  'Hernandez',
  crypt('Playerk1lni0ul!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a485bb5f-cf03-0006-4c35-e1ee86746e77',
  'ahmir.lamar.johnson.50720c09@apsl.player',
  'Ahmir',
  'Lamar Johnson',
  crypt('Playerqe88p8fw!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7f8471af-d9d1-0006-1cbb-2f3b3dd5302a',
  'ahsan.johnson.50720c09@apsl.player',
  'Ahsan',
  'Johnson',
  crypt('Playerxwgpqntc!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '6fb1b484-4160-0006-e010-9dcf7ad6f1b6',
  'bugra.kumas.50720c09@apsl.player',
  'Bugra',
  'Kumas',
  crypt('Playero8er7fx7!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '9d9d8ce8-2804-0006-8ea5-b78420c974c6',
  'jake.kuzmick.50720c09@apsl.player',
  'Jake',
  'Kuzmick',
  crypt('Playerxy3mihur!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b032397d-d4bf-0006-1bba-abd247ca1a2b',
  'dominic.antonio.lodise.50720c09@apsl.player',
  'Dominic',
  'Antonio lodise',
  crypt('Playervwe1zgar!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '88fb1858-e71e-0006-59d5-73ed0c8e84bb',
  'gavin.o.neill.50720c09@apsl.player',
  'Gavin',
  'O''Neill',
  crypt('Playerekjk8b0v!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '1110bdd3-0313-0006-7007-74dc84613e90',
  'krish.olmedo.50720c09@apsl.player',
  'Krish',
  'Olmedo',
  crypt('Playerooaovqym!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd87d3cb5-33a5-0006-c1e6-f9e0579402ec',
  'alexander.charles.patton.50720c09@apsl.player',
  'Alexander',
  'Charles Patton',
  crypt('Players951drj8!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f3fe8146-5c97-0006-399f-699797bf0c2a',
  'mason.james.regan.50720c09@apsl.player',
  'Mason',
  'James Regan',
  crypt('Playera9kgg0ha!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '03994c64-9574-0006-6b6b-201159b7c622',
  'fred.renzulli.50720c09@apsl.player',
  'Fred',
  'Renzulli',
  crypt('Playerpsaxdbzo!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '17212409-140e-0006-bde1-d2882b37c526',
  'joseph.romano.50720c09@apsl.player',
  'Joseph',
  'Romano',
  crypt('Playereewummns!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '0075015c-43a6-0006-70ee-053e5befbd02',
  'joshua.rossell.50720c09@apsl.player',
  'Joshua',
  'Rossell',
  crypt('Player7h3r4wk1!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '07c30bdf-4953-0006-f93d-1432d91d5e79',
  'brian.sharkey.50720c09@apsl.player',
  'Brian',
  'Sharkey',
  crypt('Playeran8u7wrc!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b1aba238-fa67-0006-cdd6-41b151d70e65',
  'christopher.john.spicer.50720c09@apsl.player',
  'Christopher',
  'John Spicer',
  crypt('Playerjt94z0rq!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '3338fb82-78cc-0006-1a2a-3cbeb8946181',
  'kyle.william.stone.50720c09@apsl.player',
  'Kyle',
  'William Stone',
  crypt('Playerri544erm!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f5d2b265-4455-0006-401b-db41d2589cef',
  'owen.strohm.50720c09@apsl.player',
  'Owen',
  'Strohm',
  crypt('Playera11ilof6!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '22d562ae-e529-0006-54ec-c0631e593f17',
  'melcohol.velasquez.50720c09@apsl.player',
  'Melcohol',
  'Velasquez',
  crypt('Playerhiav2jc1!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'fbb69e9a-d0c2-0006-cbcc-00f3224ca188',
  'christian.vetter.50720c09@apsl.player',
  'Christian',
  'Vetter',
  crypt('Playervpx8yall!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Medford Strikers USERS
-- ========================================
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '10c64bf2-6baa-0006-73e1-c4dc5e7159fb',
  'anthony.alexis.ali.77b6674f@apsl.player',
  'Anthony',
  'Alexis Ali',
  crypt('Player8vtq0wco!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'af9a3985-e5f8-0006-e9fc-85939aaced32',
  'dylan.bednarek.77b6674f@apsl.player',
  'Dylan',
  'Bednarek',
  crypt('Playeryu4ceyz4!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'fbb56593-54a4-0006-4579-9065523a45c3',
  'garrett.blankinship.77b6674f@apsl.player',
  'Garrett',
  'Blankinship',
  crypt('Player16ppdxne!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'dffe5dbe-040b-0006-bd85-8db2f3135b36',
  'matthew.david.dottavi.77b6674f@apsl.player',
  'Matthew',
  'David Dottavi',
  crypt('Playerbpsco90v!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '30037147-8072-0006-0f81-6c31d0c21693',
  'mohamed.kasongo.doukoure.77b6674f@apsl.player',
  'Mohamed',
  'Kasongo Doukoure',
  crypt('Playertaxv58rj!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '48c20dcb-2f20-0006-c5ca-5295605fbfd4',
  'noel.fernadez.77b6674f@apsl.player',
  'Noel',
  'Fernadez',
  crypt('Playerju3l8bb9!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '0fa923fb-0199-0006-0419-4bc4478fbe0d',
  'patrick.james.fluharty.77b6674f@apsl.player',
  'Patrick',
  'James Fluharty',
  crypt('Playeru3o3jeu0!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '925a13c5-0dc4-0006-3d67-8bbc8278fcf1',
  'astin.timothy.galanis.77b6674f@apsl.player',
  'Astin',
  'Timothy Galanis',
  crypt('Playerfddeblly!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '508d8fca-1304-0006-d82d-702bd061894d',
  'anthony.frank.giafaglione.77b6674f@apsl.player',
  'Anthony',
  'Frank Giafaglione',
  crypt('Player7qt2g7pc!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd122ea4b-af14-0006-d112-d22449afa224',
  'amir.khan.77b6674f@apsl.player',
  'Amir',
  'Khan',
  crypt('Playerdc3byv5i!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a264f3b0-56ec-0006-bb04-3475d211c2b3',
  'anthony.konah.77b6674f@apsl.player',
  'Anthony',
  'Konah',
  crypt('Playeril5rbdiy!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ad2ac504-c1a4-0006-b9ad-45d0a61406b5',
  'brian.lorenz.77b6674f@apsl.player',
  'Brian',
  'Lorenz',
  crypt('Playercx3jqyaf!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '01f3092d-f59c-0006-7cd8-09762ee218dd',
  'yoni.andre.moussodou.77b6674f@apsl.player',
  'Yoni',
  'Andre Moussodou',
  crypt('Playerl6fm4mf1!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '6710150b-5316-0006-957e-e1d5dfcd1ef6',
  'oguzhan.mutaf.77b6674f@apsl.player',
  'Oguzhan',
  'Mutaf',
  crypt('Playerdkbn4qet!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '15b07594-13e7-0006-5f64-04fef9b634be',
  'rami.mahmoud.nasr.77b6674f@apsl.player',
  'Rami',
  'Mahmoud Nasr',
  crypt('Playerf3yin5lb!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a63e54b5-c115-0006-610c-5b7582453ac8',
  'michael.negrete.77b6674f@apsl.player',
  'Michael',
  'Negrete',
  crypt('Playerng2o558r!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'aae5f4bb-bb9e-0006-4655-622b22a3613a',
  'juan.oliveira.77b6674f@apsl.player',
  'Juan',
  'Oliveira',
  crypt('Playerccms1wc3!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5799b4ee-1915-0006-27e9-7c2f5000413e',
  'edwin.perez.77b6674f@apsl.player',
  'Edwin',
  'Perez',
  crypt('Playerz7uo9i73!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '61af1611-575b-0006-cc22-1b1a6b52ebf3',
  'antonio.ramos.77b6674f@apsl.player',
  'Antonio',
  'Ramos',
  crypt('Playeruaix5bzo!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '0a1d578c-6e52-0006-3e41-8a204df067f4',
  'ethan.rosado.77b6674f@apsl.player',
  'Ethan',
  'Rosado',
  crypt('Playerr5ihfywr!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5470a7b5-3fb1-0006-90cd-f00b52a6a456',
  'todd.richard.salmon.77b6674f@apsl.player',
  'Todd',
  'Richard Salmon',
  crypt('Playersk6nweu4!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '4e0f1372-36c2-0006-8095-0fce0252e408',
  'aiden.francis.schmitt.77b6674f@apsl.player',
  'Aiden',
  'Francis Schmitt',
  crypt('Playersnjds3e1!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a66e9339-a1a8-0006-2513-a75c735cc502',
  'liam.smith.77b6674f@apsl.player',
  'Liam',
  'Smith',
  crypt('Playervjbvip4c!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '26afb7be-8fb0-0006-33c8-bcda9fb77992',
  'jovanny.trinidad.romero.77b6674f@apsl.player',
  'Jovanny',
  'Trinidad-Romero',
  crypt('Playerzm5sjea8!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '9fbb2268-1902-0006-13b8-219c6ec5a61e',
  'isaiah.roman.woods.kolsky.77b6674f@apsl.player',
  'Isaiah',
  'Roman Woods-Kolsky',
  crypt('Playerctrd0taz!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '92598d33-3c31-0006-e423-efa9e7501110',
  'chenyu.yi.77b6674f@apsl.player',
  'Chenyu',
  'Yi',
  crypt('Playerjt6037vg!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd342c508-d98d-0006-da46-8f27574bf1db',
  'samuel.tony.zonoe.77b6674f@apsl.player',
  'Samuel',
  'Tony Zonoe',
  crypt('Player110yop8g!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '460081a2-2618-0006-fedd-a9ade5eb0e62',
  'skylar.zugay.77b6674f@apsl.player',
  'Skylar',
  'Zugay',
  crypt('Playerh2x6mzfy!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Nova FC USERS
-- ========================================
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '8a6a205a-7cca-0006-ee76-3e7f59fc0eab',
  'soheyl.ali.rafi.4975b02e@apsl.player',
  'Soheyl',
  'Ali Rafi',
  crypt('Playerkirw9x5u!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '45d5a4c4-ef5c-0006-eb0e-09c8cd4e46b4',
  'jonathan.arguta.4975b02e@apsl.player',
  'Jonathan',
  'Arguta',
  crypt('Playerj75ey6ac!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '48aab16d-fb20-0006-681b-67bd4f4cfd91',
  'jean.ayolmbong.4975b02e@apsl.player',
  'Jean',
  'Ayolmbong',
  crypt('Playerivehfcc0!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c37ca36e-55a2-0006-bc10-4a17704f2aba',
  'eric.calvillo.4975b02e@apsl.player',
  'Eric',
  'Calvillo',
  crypt('Playertnnakyg8!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f0827d85-abc0-0006-7f13-2634c79e0ca8',
  'jhonny.de.souza.4975b02e@apsl.player',
  'Jhonny',
  'De Souza',
  crypt('Playere3o8pv8y!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c7a36261-dc54-0006-6b62-6aea5179115a',
  'valdir.de.souza.4975b02e@apsl.player',
  'Valdir',
  'De Souza',
  crypt('Playerpxnlk8th!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '8ce4b98f-bddc-0006-0d98-1338435df600',
  'isiah.dorsey.4975b02e@apsl.player',
  'Isiah',
  'Dorsey',
  crypt('Player3msvya6v!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '60c49765-32d8-0006-431d-dc5ad9b18356',
  'ricardo.espinoza.4975b02e@apsl.player',
  'Ricardo',
  'Espinoza',
  crypt('Playerflrqx21d!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b1a6c4ac-10bb-0006-5e23-0dff3660db9b',
  'jerry.felix.4975b02e@apsl.player',
  'Jerry',
  'Felix',
  crypt('Playerwsbc81im!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'bc7181a2-4b25-0006-af63-0e246c4037cd',
  'caleb.ghannam.4975b02e@apsl.player',
  'Caleb',
  'Ghannam',
  crypt('Playertlr3wowu!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e177526e-2320-0006-f5ba-a8f1e234f3be',
  'jose.gonzlaez.4975b02e@apsl.player',
  'Jose',
  'Gonzlaez',
  crypt('Playerltxac0no!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '2d7e92c3-5921-0006-28e6-f2137efdfb9e',
  'adsam.guennouni.4975b02e@apsl.player',
  'Adsam',
  'Guennouni',
  crypt('Playerb2cihc1z!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '71bb9e82-4cb7-0006-40d7-936076c8e8ec',
  'jackson.hall.4975b02e@apsl.player',
  'Jackson',
  'Hall',
  crypt('Player5uivq5jl!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '001e3f63-03ff-0006-e0cb-b68637bc78b0',
  'emmitt.inestroza.4975b02e@apsl.player',
  'Emmitt',
  'Inestroza',
  crypt('Playerqw65yzz8!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd3cce29f-cce8-0006-39a9-9607eaaf5d59',
  'abdul.azim.ismail.4975b02e@apsl.player',
  'Abdul-Azim',
  'Ismail',
  crypt('Playerochcmi46!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b26687b7-c0ad-0006-40a7-048372c8ff0c',
  'abdul.rahman.ismail.4975b02e@apsl.player',
  'Abdul-Rahman',
  'Ismail',
  crypt('Playerzv6uydtj!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '2c55d1a3-6031-0006-fadb-27e9d829d446',
  'ethan.lee.4975b02e@apsl.player',
  'Ethan',
  'Lee',
  crypt('Player49amc2n5!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5bca2e0e-cda8-0006-d1d9-33cf56343833',
  'huber.letona.4975b02e@apsl.player',
  'Huber',
  'Letona',
  crypt('Playerfwpd91y5!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '2b8a0534-c0d8-0006-726b-83f07f31876c',
  'ethan.lloyd.4975b02e@apsl.player',
  'Ethan',
  'Lloyd',
  crypt('Playereu97cbcs!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f84cb700-50b2-0006-9928-6e32e60feb13',
  'bernardo.majano.4975b02e@apsl.player',
  'Bernardo',
  'Majano',
  crypt('Playerofp90y1j!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e1149adc-7f7a-0006-0210-ea26443b3b5d',
  'reda.manafi.4975b02e@apsl.player',
  'Reda',
  'Manafi',
  crypt('Playerb75jt7cl!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'dc43183b-098f-0006-ab96-acbd14956817',
  'jack.pinson.4975b02e@apsl.player',
  'Jack',
  'Pinson',
  crypt('Playerd5x7huo6!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a1159155-0905-0006-880e-7923df18e59e',
  'jaime.quintanilla.4975b02e@apsl.player',
  'Jaime',
  'Quintanilla',
  crypt('Playerog91frkn!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7b3211b1-ff0f-0006-6f39-4aba9902f2c2',
  'michael.radomski.4975b02e@apsl.player',
  'Michael',
  'Radomski',
  crypt('Playerdpekc4ht!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '4c3e723e-57cd-0006-54b5-b1bc2e6cc04b',
  'ahmed.sheta.4975b02e@apsl.player',
  'Ahmed',
  'Sheta',
  crypt('Playergeoiyjl1!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5d99de83-596b-0006-92f2-61221f51b7c5',
  'roman.topler.4975b02e@apsl.player',
  'Roman',
  'Topler',
  crypt('Player00xq6pu9!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '0e184784-501e-0006-560b-114ceac199af',
  'marques.vagner.4975b02e@apsl.player',
  'Marques',
  'Vagner',
  crypt('Playerdfiot277!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '3ff56ceb-c246-0006-b53c-fc1fbfad202a',
  'alton.west.4975b02e@apsl.player',
  'Alton',
  'West',
  crypt('Player8d0vw7xw!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Wave FC USERS
-- ========================================
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '20e6091b-ef8a-0006-b6dc-5cace4e9062a',
  'kelechi.akujuobi.5cb8a2b2@apsl.player',
  'Kelechi',
  'Akujuobi',
  crypt('Playerirrrrqjo!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '87387418-7b00-0006-077b-bdb995f8c3e2',
  'faisal.alay.5cb8a2b2@apsl.player',
  'Faisal',
  'Alay',
  crypt('Player5fwshk6m!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'df498f7d-636c-0006-9732-fa812c1f3664',
  'victorine.kwame.appohsam.5cb8a2b2@apsl.player',
  'Victorine',
  'Kwame Appohsam',
  crypt('Playerftbt629c!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'fc21351c-aae7-0006-6442-3945dac8b4fc',
  'hector.avila.hernandez.5cb8a2b2@apsl.player',
  'Hector',
  'Avila Hernandez',
  crypt('Playerv2rofzoq!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '2c9a88cd-82fb-0006-2c5e-2f62c52a4464',
  'eduardo.g.barria.5cb8a2b2@apsl.player',
  'Eduardo',
  'G Barria',
  crypt('Playercsxi5cvf!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '81b97b1d-984e-0006-5515-ca68706b841a',
  'zavier.bell.5cb8a2b2@apsl.player',
  'Zavier',
  'Bell',
  crypt('Playerzesblwjh!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a84aae62-0d93-0006-cd06-f8356af5e028',
  'zach.boyd.5cb8a2b2@apsl.player',
  'Zach',
  'Boyd',
  crypt('Player1n1ch7ud!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '62c2d5b3-c033-0006-6db4-512430ec4220',
  'julio.bravo.guzman.5cb8a2b2@apsl.player',
  'Julio',
  'Bravo-Guzman',
  crypt('Playerv4kot7bo!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a2a4e33a-12ee-0006-2a86-feceb991b495',
  'deontae.campbell.5cb8a2b2@apsl.player',
  'Deontae',
  'Campbell',
  crypt('Playeruqh86i9m!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a5249549-ad69-0006-c1de-c3d6cd2a33d0',
  'brandon.chambers.5cb8a2b2@apsl.player',
  'Brandon',
  'Chambers',
  crypt('Playerqroxsvfo!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7a2f2756-e33a-0006-a3ea-d7a18d4209b6',
  'aiden.chen.5cb8a2b2@apsl.player',
  'Aiden',
  'Chen',
  crypt('Playerf3ce17rq!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a273ff71-c957-0006-6070-a1e27e7ca0b2',
  'marckensley.constant.5cb8a2b2@apsl.player',
  'Marckensley',
  'Constant',
  crypt('Playerzwss5kn6!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '239583df-4fe8-0006-3034-9dfc2bdd9482',
  'tim.cooley.5cb8a2b2@apsl.player',
  'Tim',
  'Cooley',
  crypt('Player7s1lh5f4!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '640c3a9c-b6c6-0006-e83f-323b6ce3beaa',
  'christian.cruz.5cb8a2b2@apsl.player',
  'Christian',
  'Cruz',
  crypt('Player2gs2qpo9!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'bc24c6de-a0d3-0006-a3cf-1f60497856f2',
  'danilo.duric.5cb8a2b2@apsl.player',
  'Danilo',
  'Duric',
  crypt('Player0tyi7vfa!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'db125199-f694-0006-0d79-f905a10a14ca',
  'logan.flanagan.5cb8a2b2@apsl.player',
  'Logan',
  'Flanagan',
  crypt('Playery0e1az7p!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c0f033c9-099c-0006-e1cc-c6ef0905036f',
  'colin.foley.5cb8a2b2@apsl.player',
  'Colin',
  'Foley',
  crypt('Playervd6x7f8z!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '1a244857-4875-0006-d0c7-8a57ad9bdcf6',
  'nathan.gichuhi.5cb8a2b2@apsl.player',
  'Nathan',
  'Gichuhi',
  crypt('Playernr34eql1!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '99151dfb-a66d-0006-8760-66833514e424',
  'jeremy.gonzalez.5cb8a2b2@apsl.player',
  'Jeremy',
  'Gonzalez',
  crypt('Playerjgg92g3j!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '9a681699-c706-0006-d690-cd03c0af65bb',
  'josh.gutierrez.5cb8a2b2@apsl.player',
  'Josh',
  'Gutierrez',
  crypt('Player16nqznjc!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '116361d2-5a35-0006-6f45-7a44bb6aef3b',
  'jonah.harvey.5cb8a2b2@apsl.player',
  'Jonah',
  'Harvey',
  crypt('Playere7h70sk1!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '4ef606d4-a361-0006-0c7b-54c98cd1d702',
  'josh.haynie.5cb8a2b2@apsl.player',
  'Josh',
  'Haynie',
  crypt('Player8hm7e4ca!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '52dfa7e3-1ecb-0006-4988-91aaf12b3e53',
  'mitchell.hopkins.5cb8a2b2@apsl.player',
  'Mitchell',
  'Hopkins',
  crypt('Playermikef8c2!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '1acd7741-fa53-0006-85e6-46da5dc5c984',
  'tanner.johnston.5cb8a2b2@apsl.player',
  'Tanner',
  'Johnston',
  crypt('Playeropc7t9v9!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '2cf19d93-a04a-0006-c947-5da7b9df7ad9',
  'david.miller.5cb8a2b2@apsl.player',
  'David',
  'Miller',
  crypt('Player0y9kp0mf!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '4a163bd5-9295-0006-0263-2d7d93b3eecf',
  'abdul.mokhtar.5cb8a2b2@apsl.player',
  'Abdul',
  'Mokhtar',
  crypt('Playerbvtlyifj!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5226f800-990b-0006-9d53-fad17a37e1db',
  'bijan.morshedi.5cb8a2b2@apsl.player',
  'Bijan',
  'Morshedi',
  crypt('Player5ue68gre!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c3aa1522-f07a-0006-c2f6-b9c72d4dcd6c',
  'ander.ochoa.5cb8a2b2@apsl.player',
  'Ander',
  'Ochoa',
  crypt('Playerk5zo6vdv!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '3402a511-9820-0006-14cd-a657dbbc7768',
  'victor.oladeinde.5cb8a2b2@apsl.player',
  'Victor',
  'Oladeinde',
  crypt('Playereb0ecx5n!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7e52798f-e99b-0006-c264-9155c44f309d',
  'oved.ortega.5cb8a2b2@apsl.player',
  'Oved',
  'Ortega',
  crypt('Playerdwqd8on1!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '86e35fb6-59bb-0006-c9d2-3adacb7eac51',
  'kameron.payne.5cb8a2b2@apsl.player',
  'Kameron',
  'Payne',
  crypt('Playerc90awaub!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'cb80d2e0-2811-0006-688d-4f0227005854',
  'jayden.rodriguez.5cb8a2b2@apsl.player',
  'Jayden',
  'Rodriguez',
  crypt('Playerbxns4feh!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '85ca48c0-51a6-0006-7f1d-890682279cf4',
  'oumar.thiandoum.5cb8a2b2@apsl.player',
  'Oumar',
  'Thiandoum',
  crypt('Playerjljomhc9!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'efa170cb-fb00-0006-c691-39d6f16942d3',
  'ronju.walters.5cb8a2b2@apsl.player',
  'Ronju',
  'Walters',
  crypt('Player87caoslt!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- VA Marauders FC USERS
-- ========================================
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ea38911e-019d-0006-81cf-bfc1c41cfcd0',
  'mohamed.abdelrehman.8d88ffe1@apsl.player',
  'Mohamed',
  'Abdelrehman',
  crypt('Playery3n04l7h!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '0dd7c57d-e353-0006-d135-0774bfa60140',
  'nyliek.allen.8d88ffe1@apsl.player',
  'Nyliek',
  'Allen',
  crypt('Playera2o38hst!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '92c1fcf6-6001-0006-4635-14bea9e9460f',
  'jared.benedict.8d88ffe1@apsl.player',
  'Jared',
  'Benedict',
  crypt('Player4t181pfg!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '435d0f98-c5c5-0006-a17d-dcc67e5cd7ca',
  'david.bernal.clark.8d88ffe1@apsl.player',
  'David',
  'Bernal-Clark',
  crypt('Playerkv4r51eg!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '29398684-3ef4-0006-c080-d3c3059cfd2a',
  'alex.bilski.8d88ffe1@apsl.player',
  'Alex',
  'Bilski',
  crypt('Playera6ixykhy!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd37e87f6-7532-0006-fe63-7fce9ece4af2',
  'nicholas.blake.8d88ffe1@apsl.player',
  'Nicholas',
  'Blake',
  crypt('Player72m3yo3y!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '6f057637-94c4-0006-6792-2c7c3ee81d0b',
  'edwardo.chavez.8d88ffe1@apsl.player',
  'Edwardo',
  'Chavez',
  crypt('Playerki5dyicp!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '277e6125-119d-0006-6a56-2940e99d02d5',
  'charles.evangelos.8d88ffe1@apsl.player',
  'Charles',
  'Evangelos',
  crypt('Playerntbzsokd!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '1d32585f-3f4a-0006-8be7-04c981cb85c3',
  'jessi.e.garcia.8d88ffe1@apsl.player',
  'Jessi',
  'e Garcia',
  crypt('Playerpbl8lubs!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '0baccd7f-4b0a-0006-926d-dac754e8ffb6',
  'daniel.gonzalez.8d88ffe1@apsl.player',
  'Daniel',
  'Gonzalez',
  crypt('Playertk5vvol8!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'acefe636-051e-0006-d10e-3ed76f115f9e',
  'sayed.hashemi.8d88ffe1@apsl.player',
  'Sayed',
  'Hashemi',
  crypt('Playerwratxg73!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7ece1a85-0658-0006-ed39-949b915ae36b',
  'vasilios.kazakos.8d88ffe1@apsl.player',
  'Vasilios',
  'Kazakos',
  crypt('Playerh6r5gnom!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5fbf7c9c-03ed-0006-4a3b-2ba971fc7696',
  'alejandro.lenz.8d88ffe1@apsl.player',
  'Alejandro',
  'Lenz',
  crypt('Playerr3n7k41w!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '0aabd123-2a74-0006-8c42-c9dace9a21f0',
  'josaphat.letona.8d88ffe1@apsl.player',
  'Josaphat',
  'Letona',
  crypt('Playert1q1nk42!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a16b014e-2c6d-0006-ac02-4c627c4e655a',
  'braden.lopez.8d88ffe1@apsl.player',
  'Braden',
  'Lopez',
  crypt('Playervc47kar3!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '1009b741-c6e6-0006-76eb-9010e50b2993',
  'gabriel.maguire.8d88ffe1@apsl.player',
  'Gabriel',
  'Maguire',
  crypt('Playeryhzs1bhz!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '658e515c-2ef6-0006-be04-29dc186dcb09',
  'moussa.mahama.8d88ffe1@apsl.player',
  'Moussa',
  'Mahama',
  crypt('Player23zr3yd6!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '91aeff3b-dff6-0006-8456-e080dd721d51',
  'louis.manyele.8d88ffe1@apsl.player',
  'Louis',
  'Manyele',
  crypt('Playerevsv411u!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a6ff11bf-d379-0006-f617-671c8a047de9',
  'carlos.mareno.8d88ffe1@apsl.player',
  'Carlos',
  'Mareno',
  crypt('Playergun85w9b!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '0b378add-0d84-0006-d943-5a550f1dd937',
  'george.mavronis.8d88ffe1@apsl.player',
  'George',
  'Mavronis',
  crypt('Playermelx56v8!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a2354141-8f01-0006-8593-be6028f61131',
  'michael.medina.8d88ffe1@apsl.player',
  'Michael',
  'Medina',
  crypt('Playere6ahtf49!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '62fb4994-83a7-0006-698e-b2e4013a26f9',
  'roman.milian.8d88ffe1@apsl.player',
  'Roman',
  'Milian',
  crypt('Playern8uvqdvi!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f9211e29-5fd2-0006-4600-8c2076b8fd22',
  'johnny.paletar.8d88ffe1@apsl.player',
  'Johnny',
  'Paletar',
  crypt('Player38tx55cc!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f70c9844-16f8-0006-6c22-7cc383ed3c09',
  'danish.saeedi.8d88ffe1@apsl.player',
  'Danish',
  'Saeedi',
  crypt('Playerfbnfxruu!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '39b58c47-9ace-0006-e346-42d6004e3c86',
  'jordon.salvi.8d88ffe1@apsl.player',
  'Jordon',
  'Salvi',
  crypt('Playeree44kdmy!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5a9b1fa9-15a0-0006-5c98-46671150599d',
  'leonel.sanchez.8d88ffe1@apsl.player',
  'Leonel',
  'Sanchez',
  crypt('Player89plerw0!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '12272fb5-404e-0006-03ea-f3f0271ac232',
  'selim.senel.8d88ffe1@apsl.player',
  'Selim',
  'Senel',
  crypt('Player7hot3f1q!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '3a2385ea-ca52-0006-e0fb-6814ce92615d',
  'ahmadi.shayan.8d88ffe1@apsl.player',
  'Ahmadi',
  'Shayan',
  crypt('Player8bqokxif!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'cba566f5-e1e1-0006-cdd0-495973f019da',
  'akimanzi.siibo.8d88ffe1@apsl.player',
  'Akimanzi',
  'Siibo',
  crypt('Player6jnivxpt!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7ef2ec8a-d549-0006-e78e-14edbbe77b3b',
  'alex.sosa.8d88ffe1@apsl.player',
  'Alex',
  'Sosa',
  crypt('Playerz17cq0ws!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5e4eb7b1-35f0-0006-34dc-8df8d72eb5c9',
  'viktor.tachev.8d88ffe1@apsl.player',
  'Viktor',
  'Tachev',
  crypt('Playerqq8ltbxk!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '21232c35-692c-0006-7b68-abe14089578e',
  'matthew.zelaya.8d88ffe1@apsl.player',
  'Matthew',
  'Zelaya',
  crypt('Playersouzo5d5!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '3da5238e-ee63-0006-eb33-103b30f768c3',
  'nebeyo.zerihun.8d88ffe1@apsl.player',
  'Nebeyo',
  'Zerihun',
  crypt('Playerj3pl1dlb!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '1f9abd6d-6fed-0006-f5b3-8727016e1dab',
  'ossy.zubiria.8d88ffe1@apsl.player',
  'Ossy',
  'Zubiria',
  crypt('Playerj4onmfqs!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Grove Soccer United USERS
-- ========================================
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '23ea29e7-81cf-0006-4e02-a09554130215',
  'sami.afiouni.cf7f17f3@apsl.player',
  'Sami',
  'Afiouni',
  crypt('Playeru9ljbe2g!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '6fb82b85-82c8-0006-c127-b5810aefd1bd',
  'samuel.amedeker.cf7f17f3@apsl.player',
  'Samuel',
  'Amedeker',
  crypt('Player3odxp9vk!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f0463993-b06b-0006-2a7a-6850c655de78',
  'owen.blount.cf7f17f3@apsl.player',
  'Owen',
  'Blount',
  crypt('Player8rz6go4n!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e0806b14-5724-0006-9037-6b74f806841a',
  'jordan.bonnett.cf7f17f3@apsl.player',
  'Jordan',
  'Bonnett',
  crypt('Player1u1qkrnx!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '50f1bece-6c6b-0006-357c-e3b45fd115c4',
  'evan.bosak.cf7f17f3@apsl.player',
  'Evan',
  'Bosak',
  crypt('Playerezg979ny!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a30d63ca-d94c-0006-a72e-6dcc1d5bf020',
  'gerard.broussard.cf7f17f3@apsl.player',
  'Gerard',
  'Broussard',
  crypt('Playercj4xospk!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a4ef4295-5ca9-0006-96e3-479449289fe9',
  'brian.chidzvondo.cf7f17f3@apsl.player',
  'Brian',
  'Chidzvondo',
  crypt('Playerk17ar156!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c39ad8aa-5a3f-0006-c2d0-a54413adba27',
  'matthew.do.cf7f17f3@apsl.player',
  'Matthew',
  'Do',
  crypt('Playerhq2eeulx!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd0d33fce-1b6c-0006-afc1-56aaa6df65fa',
  'joseph.enebeli.cf7f17f3@apsl.player',
  'Joseph',
  'Enebeli',
  crypt('Player51qrtphw!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '561848c2-b312-0006-0783-7fff45415975',
  'adam.grace.cf7f17f3@apsl.player',
  'Adam',
  'Grace',
  crypt('Playerezfzd3hy!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7cdb0545-2f44-0006-1096-5dc302f5286d',
  'demetrius.howe.cf7f17f3@apsl.player',
  'Demetrius',
  'Howe',
  crypt('Player8yq78e9z!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '52c76170-7887-0006-8b05-19da43b3c2f4',
  'massimo.johnson.cf7f17f3@apsl.player',
  'Massimo',
  'Johnson',
  crypt('Playeriuiysbwh!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a26325bd-5481-0006-6b38-74140bd26764',
  'benjamin.jones.cf7f17f3@apsl.player',
  'Benjamin',
  'Jones',
  crypt('Playeretjggcy1!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b5090f1e-9518-0006-9c87-34cfb1fd341e',
  'aidan.krivanec.cf7f17f3@apsl.player',
  'Aidan',
  'Krivanec',
  crypt('Player8pm9zn37!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '151e4a1c-3e30-0006-c975-e47bef2f2278',
  'leighton.langenhoven.cf7f17f3@apsl.player',
  'Leighton',
  'Langenhoven',
  crypt('Playert5f1vwb0!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '08030ed2-2cd9-0006-c708-be58ec3dcc2c',
  'salah.mahmoud.cf7f17f3@apsl.player',
  'Salah',
  'Mahmoud',
  crypt('Playery8w15fll!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '6dc0cea6-2e8c-0006-e11d-230cf0743d4f',
  'treyvon.medley.green.cf7f17f3@apsl.player',
  'Treyvon',
  'Medley-Green',
  crypt('Playerogpp2su5!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '36cd179d-bdfb-0006-b2e6-1456e0915c14',
  'museba.mwape.cf7f17f3@apsl.player',
  'Museba',
  'Mwape',
  crypt('Playerlaidl52e!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b4fa1466-18e0-0006-4f5a-73d74b61be16',
  'jake.nelson.cf7f17f3@apsl.player',
  'Jake',
  'Nelson',
  crypt('Playercp3wuebc!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '38441d7e-c4d3-0006-022e-5717d61a3c7d',
  'abulfazl.panahi.cf7f17f3@apsl.player',
  'Abulfazl',
  'Panahi',
  crypt('Playerjr5tkqwv!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '68c28c9c-92d5-0006-f9f6-098659f55cbb',
  'dame.pene.cf7f17f3@apsl.player',
  'Dame',
  'Pene',
  crypt('Player6ep57qrg!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '2e342b93-a22f-0006-8be0-75886cd2ca2b',
  'henry.pittman.cf7f17f3@apsl.player',
  'Henry',
  'Pittman',
  crypt('Player4ppxdv6w!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'fcebd2a9-8da2-0006-2d89-353c07835885',
  'yoskar.alejandro.quintanilla.cf7f17f3@apsl.player',
  'Yoskar',
  'Alejandro Quintanilla',
  crypt('Playern0amh9m7!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '8debf748-486f-0006-84c6-ad67e6441dbf',
  'emerson.reyes.cf7f17f3@apsl.player',
  'Emerson',
  'Reyes',
  crypt('Playeropro8huq!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '8920a87e-34d2-0006-a308-cede08b5bc85',
  'mahdi.reza.cf7f17f3@apsl.player',
  'Mahdi',
  'Reza',
  crypt('Player6ong70nz!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e26fc5a5-aae4-0006-1ed6-c958d572a650',
  'mourtala.seck.cf7f17f3@apsl.player',
  'Mourtala',
  'Seck',
  crypt('Player463xjisv!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a092dbbc-19fe-0006-ff40-6dbb0d8cd7ab',
  'alakhe.sibeko.cf7f17f3@apsl.player',
  'Alakhe',
  'Sibeko',
  crypt('Playerwy00dno9!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e2301c14-3b50-0006-62c0-fec1e02ea225',
  'noe.soriano.cf7f17f3@apsl.player',
  'Noe',
  'Soriano',
  crypt('Playeri8kaergm!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '87aafe06-e1bc-0006-8719-606a00d56566',
  'sharief.stancil.cf7f17f3@apsl.player',
  'Sharief',
  'Stancil',
  crypt('Playergo15wnvg!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '8aaa0937-ebcc-0006-f7b5-9bf199cfeb71',
  'max.taliaferro.cf7f17f3@apsl.player',
  'Max',
  'Taliaferro',
  crypt('Playerum49mu2k!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f734dd37-51b8-0006-01f9-8fb693083318',
  'asanda.tom.cf7f17f3@apsl.player',
  'Asanda',
  'Tom',
  crypt('Playerunixcin0!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd2297d62-19c2-0006-954a-159d8224b632',
  'caleb.underwood.cf7f17f3@apsl.player',
  'Caleb',
  'Underwood',
  crypt('Playernb5jqt6p!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '34fa5e05-0285-0006-6072-68514344a498',
  'callum.vellozzi.cf7f17f3@apsl.player',
  'Callum',
  'Vellozzi',
  crypt('Playerkij1wxud!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'bb5ddd63-4504-0006-63a6-e06d34a35778',
  'chrisendo.wentzel.cf7f17f3@apsl.player',
  'Chrisendo',
  'Wentzel',
  crypt('Playerwo1n14o6!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '92497df4-e9a9-0006-e063-27471ad9ef92',
  'john.williams.cf7f17f3@apsl.player',
  'John',
  'Williams',
  crypt('Player8il1zx6f!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Christos FC USERS
-- ========================================
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'dd409a66-46d7-0006-70f8-0a14e258eaf7',
  'felix.amankwah.226c892a@apsl.player',
  'Felix',
  'Amankwah',
  crypt('Playerywhtw1dp!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7a2c7c6a-2f56-0006-a6e4-2a8f83ded7b4',
  'daniel.baxter.226c892a@apsl.player',
  'Daniel',
  'Baxter',
  crypt('Player8asqd0h3!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b0e131c5-5e29-0006-7695-a6fd033a0f6c',
  'drew.belcher.226c892a@apsl.player',
  'Drew',
  'Belcher',
  crypt('Playerxztyy7hy!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '52e7ca86-5766-0006-f79a-a21a61517a7c',
  'elijah.belcher.226c892a@apsl.player',
  'Elijah',
  'Belcher',
  crypt('Player17ofzy1w!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5255f81f-10fa-0006-1930-cd1789821549',
  'ethan.belcher.226c892a@apsl.player',
  'Ethan',
  'Belcher',
  crypt('Player9jufr66w!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '63bf5588-9ee9-0006-2f7e-77aabf55da30',
  'jacob.bender.226c892a@apsl.player',
  'Jacob',
  'Bender',
  crypt('Playerhwdxcxic!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '8fe190e3-c920-0006-68cd-218cf87f60fd',
  'jalen.boston.226c892a@apsl.player',
  'Jalen',
  'Boston',
  crypt('Playerrh7s5y37!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '84c7faec-4ba6-0006-5c3f-d2bdecdad548',
  'brandon.burkholder.226c892a@apsl.player',
  'Brandon',
  'Burkholder',
  crypt('Playerwru9h13x!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '91ef5b6d-6015-0006-60e4-624cbb154c49',
  'nero.cooper.226c892a@apsl.player',
  'Nero',
  'Cooper',
  crypt('Playerohorw40h!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '22136d87-cbbb-0006-2f69-71538eff6273',
  'anthony.dragisics.226c892a@apsl.player',
  'Anthony',
  'Dragisics',
  crypt('Playerrrxzy65b!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '356a928a-8f0a-0006-c418-7e71522a839c',
  'alejandro.estrada.226c892a@apsl.player',
  'Alejandro',
  'Estrada',
  crypt('Playermh3noefe!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7d0d00de-c7c6-0006-0130-6004ba5e4c19',
  'justin.gielen.226c892a@apsl.player',
  'Justin',
  'Gielen',
  crypt('Player1ef9kksy!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'dc532d6e-59de-0006-c495-e77acdb897e8',
  'brian.graham.226c892a@apsl.player',
  'Brian',
  'Graham',
  crypt('Playerq2hsnsc7!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '99a88530-8f78-0006-f5d3-333681f52037',
  'brett.joyner.226c892a@apsl.player',
  'Brett',
  'Joyner',
  crypt('Playerwtkztnvn!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e7c75c11-eef1-0006-2405-af8d26aa95e9',
  'tanner.kennard.226c892a@apsl.player',
  'Tanner',
  'Kennard',
  crypt('Playercurz2a0x!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '0ed2c9cd-97db-0006-e9e4-21702bfc1f3c',
  'tyler.lee.226c892a@apsl.player',
  'Tyler',
  'Lee',
  crypt('Player8uatdmxs!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '96f11540-24ce-0006-f53e-9d589d007775',
  'stiven.llano.226c892a@apsl.player',
  'Stiven',
  'Llano',
  crypt('Playerbldd4kjy!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd672e7ef-09bd-0006-eb6b-a2a032fa1bc5',
  'morgan.lussi.226c892a@apsl.player',
  'Morgan',
  'Lussi',
  crypt('Playero9vhx1o6!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7552f1c4-bd1f-0006-1940-c6ed38817eb5',
  'raffaele.mazzone.226c892a@apsl.player',
  'Raffaele',
  'Mazzone',
  crypt('Player3fgf8mgp!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5314308f-b807-0006-a1f0-8790e46cd3c0',
  'daniel.mccleary.226c892a@apsl.player',
  'Daniel',
  'McCleary',
  crypt('Playerbav53ruf!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c2b0d43d-1aed-0006-fe44-7c74442372c6',
  'edixon.moreira.226c892a@apsl.player',
  'Edixon',
  'Moreira',
  crypt('Player78zteesi!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '106523d4-7801-0006-884c-2b45f2ebe99c',
  'david.ogbonna.226c892a@apsl.player',
  'David',
  'Ogbonna',
  crypt('Playeriinjuc7j!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '73f5c0b1-dea1-0006-b51a-3c7e146bf1e2',
  'garrett.peters.226c892a@apsl.player',
  'Garrett',
  'Peters',
  crypt('Playerv9700jc0!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '82df00b4-306f-0006-4b3c-b72835c5a454',
  'juston.rainey.226c892a@apsl.player',
  'Juston',
  'Rainey',
  crypt('Playeryo8aphgq!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c15eff76-d18e-0006-0ed3-b1cc0ebdffb4',
  'cesar.ramos.226c892a@apsl.player',
  'Cesar',
  'Ramos',
  crypt('Playerw7seggip!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '72af4ed6-8aa7-0006-9f51-cf2fc23d99a0',
  'aaron.rilling.226c892a@apsl.player',
  'Aaron',
  'Rilling',
  crypt('Playerldcwanyy!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '53a94b23-4dda-0006-5cee-f00a7e789ce3',
  'jackson.ruckman.226c892a@apsl.player',
  'Jackson',
  'Ruckman',
  crypt('Player4ob0he2e!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '450c8fe9-f510-0006-7532-c98bd3223028',
  'kyle.saunderson.226c892a@apsl.player',
  'Kyle',
  'Saunderson',
  crypt('Playerypb578ul!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5d528abd-6bb7-0006-4e82-ccaf432fa1b8',
  'luis.soria.226c892a@apsl.player',
  'Luis',
  'Soria',
  crypt('Player3e4hvj4f!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5fa60a7c-73a8-0006-d11e-a434cca23aa0',
  'brett.st.martin.226c892a@apsl.player',
  'Brett',
  'St Martin',
  crypt('Playersbog1hza!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e053c640-4464-0006-bec5-cff27b9876d2',
  'alexander.wardle.226c892a@apsl.player',
  'Alexander',
  'Wardle',
  crypt('Playerfyd7hk2u!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- PFA EPSL USERS
-- ========================================
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '41672236-053b-0006-463b-fafde1f83fae',
  'kennison.akuro.d8e57bbb@apsl.player',
  'Kennison',
  'Akuro',
  crypt('Playerzixsij0o!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ed7beb1e-57c6-0006-a964-c023ca33f018',
  'melvin.asanji.d8e57bbb@apsl.player',
  'Melvin',
  'Asanji',
  crypt('Player4whgicqh!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '4cdb4fec-a108-0006-3024-21c1b0e93639',
  'brandon.betts.d8e57bbb@apsl.player',
  'Brandon',
  'Betts',
  crypt('Playere006o0gx!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '1e9c5a6b-2745-0006-0d37-2dedaf509ac5',
  'isaac.carvajal.d8e57bbb@apsl.player',
  'Isaac',
  'Carvajal',
  crypt('Playerwq346b74!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '964640a2-b0cf-0006-4e8d-81e9aae27abd',
  'jenovic.elumbu.d8e57bbb@apsl.player',
  'Jenovic',
  'Elumbu',
  crypt('Player99x1nlwa!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd54ec81f-b9e7-0006-1d81-59496222bc4f',
  'anderson.fernandez.d8e57bbb@apsl.player',
  'Anderson',
  'Fernandez',
  crypt('Players990mbtg!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a49747f8-58b4-0006-8041-226baa7079e7',
  'angello.fernandez.d8e57bbb@apsl.player',
  'Angello',
  'Fernandez',
  crypt('Playerectrg3fe!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e0c00c53-343a-0006-26d7-66a07377ce63',
  'terry.fon.d8e57bbb@apsl.player',
  'Terry',
  'Fon',
  crypt('Playerd5rlwppx!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '84632a56-d3a0-0006-e06c-cd25e193c0ad',
  'eduardo.fuentes.d8e57bbb@apsl.player',
  'Eduardo',
  'Fuentes',
  crypt('Playerj4r3pk0z!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a78dba3d-3536-0006-8d37-50d5efe78a6c',
  'christian.garavito.d8e57bbb@apsl.player',
  'Christian',
  'Garavito',
  crypt('Player3tyuflh4!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b4bf0347-1334-0006-5e3e-39d900d3586a',
  'thaddeus.goddard.d8e57bbb@apsl.player',
  'Thaddeus',
  'Goddard',
  crypt('Player7mdd6oiw!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '685cc3fa-5ca9-0006-65da-2672fa97abb0',
  'alexis.gonzalez.ayala.d8e57bbb@apsl.player',
  'Alexis',
  'Gonzalez Ayala',
  crypt('Playerjxsbxo06!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e1f2ff52-2f1e-0006-5751-60640491d25a',
  'chayton.kuidlan.d8e57bbb@apsl.player',
  'Chayton',
  'Kuidlan',
  crypt('Playert4oszmty!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '60d1ae3b-be7e-0006-87eb-488dd99cd9ae',
  'tobias.lane.d8e57bbb@apsl.player',
  'Tobias',
  'Lane',
  crypt('Playerpw1a6fzx!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7f6fe638-59cb-0006-bebe-1f409a3cdb5e',
  'jonathan.lemus.morales.d8e57bbb@apsl.player',
  'Jonathan',
  'Lemus Morales',
  crypt('Playeryeh67wxj!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '6fe26ee6-c0a5-0006-1027-eeb53062dbf3',
  'creasy.lopez.d8e57bbb@apsl.player',
  'Creasy',
  'Lopez',
  crypt('Playertk1aut24!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '2df93f06-45fc-0006-1abf-ce95b342a265',
  'lutho.mlunguza.d8e57bbb@apsl.player',
  'Lutho',
  'Mlunguza',
  crypt('Playerp2ovlsjs!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '61d004c0-a7db-0006-70c5-ce75941d3c80',
  'toju.okonedo.d8e57bbb@apsl.player',
  'Toju',
  'Okonedo',
  crypt('Playerj16bx6gp!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '91c7c07c-ddd4-0006-bb1d-ab37cffcd990',
  'david.pawlowski.d8e57bbb@apsl.player',
  'David',
  'Pawlowski',
  crypt('Playeryce50rld!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd95fdaf2-6af8-0006-3428-4a34e9ac6d8e',
  'danny.paz.d8e57bbb@apsl.player',
  'Danny',
  'Paz',
  crypt('Playersgw59cmi!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a2c3b15d-df06-0006-c45f-c7e1d63c8dd0',
  'brayan.perez.mendez.d8e57bbb@apsl.player',
  'Brayan',
  'Perez Mendez',
  crypt('Playerfp6z0uot!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b1fe8bfd-cc5e-0006-7327-3b331cfbf6ca',
  'nicholas.tziamouranis.d8e57bbb@apsl.player',
  'Nicholas',
  'Tziamouranis',
  crypt('Playere0ckkr3z!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '06e0323c-007c-0006-25c3-983115664737',
  'william.villatoro.velasquez.d8e57bbb@apsl.player',
  'William',
  'Villatoro Velasquez',
  crypt('Player7g6p9ciy!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f7594491-6bda-0006-bcd1-ce32af311366',
  'brian.ware.d8e57bbb@apsl.player',
  'Brian',
  'Ware',
  crypt('Player5zhyhyy1!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- PW Nova USERS
-- ========================================
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '55d1669d-900d-0006-5b25-e71fbd385c73',
  'david.alverez.7425cb8d@apsl.player',
  'David',
  'Alverez',
  crypt('Playerk87e5hes!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'bde03f16-fc9e-0006-7f1f-07a163e91845',
  'carlos.amador.7425cb8d@apsl.player',
  'Carlos',
  'Amador',
  crypt('Player1v8g0cvu!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ba79f6c0-bcb7-0006-713d-a8c8dddac61b',
  'chris.avila.7425cb8d@apsl.player',
  'Chris',
  'Avila',
  crypt('Playerrvz9ed4q!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '138b9956-acd0-0006-4107-074bd3b6dbef',
  'yaseen.ben.chouikha.7425cb8d@apsl.player',
  'Yaseen',
  'Ben Chouikha',
  crypt('Playerefcyhyd4!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '79cc1fc6-bc7e-0006-c036-109fa270d075',
  'amir.bentaleb.7425cb8d@apsl.player',
  'Amir',
  'Bentaleb',
  crypt('Player817ph0m8!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '560f1dc3-425c-0006-415e-ffe391d03afa',
  'angel.viera.castro.7425cb8d@apsl.player',
  'Angel',
  'Viera Castro',
  crypt('Playertiie7ow8!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'aa0e7838-9814-0006-aaaf-177c9b90771f',
  'jesse.conteh.7425cb8d@apsl.player',
  'Jesse',
  'Conteh',
  crypt('Playerm6impgxw!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e3cb0bf1-21f0-0006-00b6-55fe561e7371',
  'gio.cruz.7425cb8d@apsl.player',
  'Gio',
  'Cruz',
  crypt('Playerlqtlfvul!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ec9059d1-f21f-0006-1a51-67dbe179846f',
  'german.del.cid.7425cb8d@apsl.player',
  'German',
  'Del Cid',
  crypt('Player6zcefuek!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c4f5143c-3027-0006-389a-c34b7ed10779',
  'mohammed.ahmed.elsir.7425cb8d@apsl.player',
  'Mohammed',
  'Ahmed Elsir',
  crypt('Playerd8bpne2o!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '1b7630a0-58b9-0006-0c92-653497774368',
  'collins.frimpong.7425cb8d@apsl.player',
  'Collins',
  'Frimpong',
  crypt('Playero9g0owmz!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e84e4e0e-71bd-0006-6001-3df5c8c793c8',
  'roy.alex.galeano.7425cb8d@apsl.player',
  'Roy',
  'Alex Galeano',
  crypt('Player88oufpxt!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '8310d12a-836d-0006-fd98-a07a5a1e1540',
  'oscar.garcia.7425cb8d@apsl.player',
  'Oscar',
  'Garcia',
  crypt('Playergxg98loh!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '8a9537a0-0219-0006-01a7-1778cb8c9b31',
  'sam.garcia.7425cb8d@apsl.player',
  'Sam',
  'Garcia',
  crypt('Playerux59fqbe!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '96f78927-1d19-0006-b38f-dc3f61f4251d',
  'anthony.juarez.7425cb8d@apsl.player',
  'Anthony',
  'Juarez',
  crypt('Player1ays6o26!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '9046189c-6711-0006-f0c5-d30a2fb3076e',
  'kwasi.kotoko.7425cb8d@apsl.player',
  'Kwasi',
  'Kotoko',
  crypt('Player3cbambtq!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '45729472-c51e-0006-fe6f-0e753e8b8afb',
  'orlando.martinez.7425cb8d@apsl.player',
  'Orlando',
  'Martinez',
  crypt('Playerx3upyhmb!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '4e81c397-aef4-0006-5edf-a413084725ad',
  'andrew.mejia.7425cb8d@apsl.player',
  'Andrew',
  'Mejia',
  crypt('Player52w1pdnb!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a0369371-a33c-0006-38ae-b188c26a944d',
  'chris.mejia.7425cb8d@apsl.player',
  'Chris',
  'Mejia',
  crypt('Playerjhv5shrc!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a003a024-0d8d-0006-b362-bd3ccb101be6',
  'milton.miranda.7425cb8d@apsl.player',
  'Milton',
  'Miranda',
  crypt('Player8atwq59p!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7f600291-3408-0006-c9fb-3becdd65d33e',
  'nasrullah.muhammed.7425cb8d@apsl.player',
  'Nasrullah',
  'Muhammed',
  crypt('Playerg1pj7g78!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'aabf10b4-aed3-0006-a6be-0b0a9387a781',
  'alexis.palma.7425cb8d@apsl.player',
  'Alexis',
  'Palma',
  crypt('Playerm7l5cggp!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c0dccfef-274c-0006-3e8e-041705d89e6b',
  'luis.reyes.7425cb8d@apsl.player',
  'Luis',
  'Reyes',
  crypt('Player22efxhs8!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '6b0da0e1-9b13-0006-fb5b-718214ecc9b5',
  'romel.reyes.7425cb8d@apsl.player',
  'Romel',
  'Reyes',
  crypt('Playerftv660ks!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '85dc854f-1a69-0006-4d8d-3c0edec106ad',
  'jason.rodriguez.7425cb8d@apsl.player',
  'Jason',
  'Rodriguez',
  crypt('Playerbj2m5sid!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '59badf67-b54a-0006-8b52-717225792ff0',
  'elias.san.juan.7425cb8d@apsl.player',
  'Elias',
  'San Juan',
  crypt('Playerw0isfcct!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '1e23a983-d928-0006-0401-c2dcdd4c5031',
  'ricardo.vega.7425cb8d@apsl.player',
  'Ricardo',
  'Vega',
  crypt('Playeryxltqiwp!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '3d8e5af9-d934-0006-2664-5e4954728710',
  'raul.villalta.7425cb8d@apsl.player',
  'Raul',
  'Villalta',
  crypt('Playeryyymu6eo!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Delmarva Thunder USERS
-- ========================================
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '92c7fd2d-0956-0006-c58e-974aad93603e',
  'joseph.daly.aigner.171f448b@apsl.player',
  'Joseph',
  'Daly Aigner',
  crypt('Playerz2pz5fps!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '693872a4-1638-0006-cfb1-21f6ca72498d',
  'liam.charles.aigner.171f448b@apsl.player',
  'Liam',
  'Charles Aigner',
  crypt('Player18kk5ooo!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd021a016-576f-0006-f8cf-781488e10e72',
  'jacob.l.amon.171f448b@apsl.player',
  'Jacob',
  'L Amon',
  crypt('Playerxblbwg5q!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '43078a08-625a-0006-a088-f4dc212fd2cf',
  'samuel.amon.171f448b@apsl.player',
  'Samuel',
  'Amon',
  crypt('Playerzlgmyw56!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5a2933c3-68d5-0006-1061-7d748e76f09d',
  'walner.anescar.171f448b@apsl.player',
  'Walner',
  'Anescar',
  crypt('Playerzuz3fvtt!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '9119582c-7aa5-0006-0103-e2ad241d37f0',
  'samuel.burbage.171f448b@apsl.player',
  'Samuel',
  'Burbage',
  crypt('Playerum4jdp57!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '56261293-85c9-0006-b9ad-ffa41a506817',
  'joshua.alexander.carey.171f448b@apsl.player',
  'Joshua',
  'Alexander Carey',
  crypt('Playere5fvps77!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '1982193e-8595-0006-8694-0fbe5675a948',
  'corvens.jay.corvil.171f448b@apsl.player',
  'Corvens',
  'Jay Corvil',
  crypt('Playerwvc5l1cx!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '019a6065-9008-0006-00de-c3bfe9df1b9c',
  'zechariah.dapaah.171f448b@apsl.player',
  'Zechariah',
  'Dapaah',
  crypt('Playeryabxk133!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '2be2940a-4e87-0006-aae7-23295bfd3521',
  'adam.stephen.delizza.171f448b@apsl.player',
  'Adam',
  'Stephen DeLizza',
  crypt('Player8o79sa4e!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'de88499a-816d-0006-d519-84669bc9dc2a',
  'heberson.edouard.171f448b@apsl.player',
  'Heberson',
  'Edouard',
  crypt('Player34uby95f!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '3b224c58-8fcc-0006-c4d8-dea542d1e6d4',
  'christ.daniel.fils.171f448b@apsl.player',
  'Christ-Daniel',
  'Fils',
  crypt('Playerl0zqfkxz!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '9a2f0952-a124-0006-f9e1-a7d6a8a85e13',
  'caleb.james.gragg.171f448b@apsl.player',
  'Caleb',
  'James Gragg',
  crypt('Player3uvfii41!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '05087429-19ac-0006-a922-d439e442fd19',
  'colin.benjamin.hofmann.171f448b@apsl.player',
  'Colin',
  'Benjamin Hofmann',
  crypt('Player7lq725s3!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '50b5320a-d42a-0006-a077-97402d75fd15',
  'elijah.jabagat.171f448b@apsl.player',
  'Elijah',
  'Jabagat',
  crypt('Playerq1aikysp!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '0dff08a2-e20a-0006-1eb5-df6e1773a43e',
  'rickelmy.jeune.171f448b@apsl.player',
  'Rickelmy',
  'Jeune',
  crypt('Playerhakeeydy!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7e3c58c3-b6db-0006-2628-a4b5650cd31c',
  'damarius.kelley.171f448b@apsl.player',
  'Damarius',
  'Kelley',
  crypt('Playerxjfyl880!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5efff8a3-972b-0006-4b6a-21d187681606',
  'goran.mijalkovski.171f448b@apsl.player',
  'Goran',
  'Mijalkovski',
  crypt('Player5vkg03wm!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '49fe28bc-a75a-0006-7d22-e92916225840',
  'sean.chidozie.morse.171f448b@apsl.player',
  'Sean',
  'Chidozie Morse',
  crypt('Player4kp6brgp!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '07873d72-4c7a-0006-3f5d-382a721bde4d',
  'abdelazim.osman.171f448b@apsl.player',
  'Abdelazim',
  'Osman',
  crypt('Playerjh5azmge!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '02df80f8-3d73-0006-8a04-8ff897bdf24d',
  'ahmed.osman.171f448b@apsl.player',
  'Ahmed',
  'Osman',
  crypt('Playerjeh50clm!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5c8f377b-97e1-0006-c210-37bacb1f5c3b',
  'pat.parrish.171f448b@apsl.player',
  'Pat',
  'Parrish',
  crypt('Playerjwdr9m57!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c517a51e-338b-0006-31ca-7a2f4cd09107',
  'caden.mark.pollard.171f448b@apsl.player',
  'Caden',
  'Mark Pollard',
  crypt('Player7bjbgg1k!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '4db891a8-781d-0006-5658-8fd6c9066eb6',
  'ivan.sanchez.gonzalez.171f448b@apsl.player',
  'Ivan',
  'Sanchez-Gonzalez',
  crypt('Player1e7jxihk!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'acddbcaa-5078-0006-0f1a-ee04c78c227b',
  'gianluca.secondi.171f448b@apsl.player',
  'Gianluca',
  'Secondi',
  crypt('Player7utotjvi!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '1d20df32-8a34-0006-768d-940cc715c343',
  'mourad.shalaby.171f448b@apsl.player',
  'Mourad',
  'Shalaby',
  crypt('Playerg638bezk!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd4b1edd1-35bd-0006-acab-605fb73933ef',
  'kenny.spock.171f448b@apsl.player',
  'Kenny',
  'Spock',
  crypt('Playerelqipm5x!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '3f58adda-b22f-0006-f20c-59992f115d09',
  'guy.holmeade.talbott.v.171f448b@apsl.player',
  'Guy',
  'Holmeade Talbott V',
  crypt('Playerkg3xp11o!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '0698dad4-90f8-0006-0b38-11232c0e77f4',
  'devon.warman.171f448b@apsl.player',
  'Devon',
  'Warman',
  crypt('Playerqir9gc3g!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd1b3c475-bf75-0006-6d20-a8d4ce9ce349',
  'skyler.williams.171f448b@apsl.player',
  'Skyler',
  'Williams',
  crypt('Playerun4bupd8!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Terminus FC USERS
-- ========================================
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5053aa8b-ef5d-0006-dec7-1ca9be3bc782',
  'nour.alamri.f05b54ff@apsl.player',
  'Nour',
  'Alamri',
  crypt('Playernhkzd48o!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '15aabcde-ef4a-0006-e979-f856816be467',
  'henry.asbill.f05b54ff@apsl.player',
  'Henry',
  'Asbill',
  crypt('Playernjvic00d!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5ad009e2-8a43-0006-f91b-d3c88f1da44c',
  'asad.bashir.f05b54ff@apsl.player',
  'Asad',
  'Bashir',
  crypt('Player72ayrhjn!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ef507504-2c44-0006-572d-08e6d528bfa9',
  'kai.bennett.f05b54ff@apsl.player',
  'Kai',
  'Bennett',
  crypt('Player9i971vuo!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '1d41ac2a-b3fd-0006-5b09-ed26efa22472',
  'alex.caskey.f05b54ff@apsl.player',
  'Alex',
  'Caskey',
  crypt('Playerpoewebdp!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a7ffe2c4-9759-0006-b23d-f3f2e42482e5',
  'damian.charles.f05b54ff@apsl.player',
  'Damian',
  'Charles',
  crypt('Playerr8ped6qs!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '2b034d6d-f28a-0006-70a8-817a6b996d6d',
  'jamie.gleeson.f05b54ff@apsl.player',
  'Jamie',
  'Gleeson',
  crypt('Player2yprgrxv!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '009b1c25-3f31-0006-757e-db7713467e82',
  'noah.goodman.f05b54ff@apsl.player',
  'Noah',
  'Goodman',
  crypt('Playerhn8tosc6!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'cc9ba7ea-c562-0006-c70d-a3b54afecbc6',
  'anthony.gourdine.f05b54ff@apsl.player',
  'Anthony',
  'Gourdine',
  crypt('Playeryavqzel0!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '6933ec21-d0f0-0006-4098-500ac2691f2a',
  'morgan.hall.f05b54ff@apsl.player',
  'Morgan',
  'Hall',
  crypt('Playert3mdzlqo!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a44bcf66-b651-0006-acd5-d239e10218fc',
  'josh.hughes.f05b54ff@apsl.player',
  'Josh',
  'Hughes',
  crypt('Playerrm3vid3d!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '6d8cb093-9da7-0006-9adb-3f239abce839',
  'gad.kabwende.f05b54ff@apsl.player',
  'Gad',
  'Kabwende',
  crypt('Playerzzr88h9u!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '608a0969-1c4b-0006-aec5-fb33f7060455',
  'jason.kayne.f05b54ff@apsl.player',
  'Jason',
  'Kayne',
  crypt('Playerifdp85ix!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ac544f2d-c290-0006-23d2-c44fe4d79813',
  'jt.keiffer.f05b54ff@apsl.player',
  'JT',
  'Keiffer',
  crypt('Playerbw3czk7s!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a77f656f-1780-0006-6237-8e4afac163fd',
  'sebastian.lopez.f05b54ff@apsl.player',
  'Sebastian',
  'Lopez',
  crypt('Playerttgkb5mx!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '004f2caf-0688-0006-8e9c-070e72ee2a0f',
  'jean.malilo.f05b54ff@apsl.player',
  'Jean',
  'Malilo',
  crypt('Playeroo15p69y!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '19347387-8fd3-0006-38cd-2f250bea5369',
  'zion.jediah.jason.mcclean.f05b54ff@apsl.player',
  'Zion',
  'Jediah-Jason McClean',
  crypt('Playerap5e879m!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5cb0b072-a930-0006-4b42-11438606322d',
  'gregg.mcpheely.f05b54ff@apsl.player',
  'Gregg',
  'McPheely',
  crypt('Playerv7vvnvtv!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '9e7238e6-8004-0006-6317-b985df73f054',
  'nathan.miles.f05b54ff@apsl.player',
  'Nathan',
  'Miles',
  crypt('Playerlkoz4h46!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '8625253b-3933-0006-0217-6d47db9dc69b',
  'alex.rotoloni.f05b54ff@apsl.player',
  'Alex',
  'Rotoloni',
  crypt('Playera6sdr8te!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd3e30f53-3bc0-0006-4439-50bdb5c7db0b',
  'jack.snyder.f05b54ff@apsl.player',
  'Jack',
  'Snyder',
  crypt('Playeroqz8o24x!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '2ff6669c-b6d8-0006-4f23-5f0140a1aa4a',
  'brynn.thompson.f05b54ff@apsl.player',
  'Brynn',
  'Thompson',
  crypt('Playerlf5ibdr3!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '0ac3d864-f5d3-0006-2ee2-d188a1c7d859',
  'tyler.vogt.f05b54ff@apsl.player',
  'Tyler',
  'Vogt',
  crypt('Player7o9d7uz1!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '054400ab-80b8-0006-e4a2-984a3add5e1c',
  'renaldo.walters.f05b54ff@apsl.player',
  'Renaldo',
  'Walters',
  crypt('Player5r2tzwx0!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'fbd28e47-6125-0006-a22a-dd7b08276f5d',
  'matt.williams.f05b54ff@apsl.player',
  'Matt',
  'Williams',
  crypt('Playerr2uuclij!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '1b776436-699a-0006-beb5-ee8d690e183f',
  'nick.york.f05b54ff@apsl.player',
  'Nick',
  'York',
  crypt('Player6eukzs5p!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Majestic SC USERS
-- ========================================
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '18bd3372-e461-0006-fa41-5bb46a9b1dc1',
  'rashid.alarape.55bd7a24@apsl.player',
  'Rashid',
  'Alarape',
  crypt('Playerwhmiokq1!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '83745656-5720-0006-1ec7-c86b8aa76b42',
  'alex.archambeau.55bd7a24@apsl.player',
  'Alex',
  'Archambeau',
  crypt('Playerl4ne4w5a!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7254d086-ebd7-0006-c394-48c68776da0a',
  'christopher.avery.55bd7a24@apsl.player',
  'Christopher',
  'Avery',
  crypt('Playerx3lipnph!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '15927f34-49ae-0006-85a7-fcbf81bafe33',
  'carlos.ayala.viera.55bd7a24@apsl.player',
  'Carlos',
  'Ayala-Viera',
  crypt('Player71a3hlv4!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5f202405-211a-0006-4754-d97519d0888b',
  'carlos.becerra.gomez.55bd7a24@apsl.player',
  'Carlos',
  'Becerra-Gomez',
  crypt('Playerf6nazmf9!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'cb3dba76-73c8-0006-1d0d-d6be03c25f72',
  'elliot.curtin.55bd7a24@apsl.player',
  'Elliot',
  'Curtin',
  crypt('Player5d4xtaz0!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '85148961-4ccf-0006-62cc-030f0cf42e88',
  'eli.dent.55bd7a24@apsl.player',
  'Eli',
  'Dent',
  crypt('Player732z5t6k!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '6c45c931-85d9-0006-e514-397d19787fd1',
  'jackson.eskay.55bd7a24@apsl.player',
  'Jackson',
  'Eskay',
  crypt('Player2akfalam!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '3efb5865-788e-0006-1baf-7f9dd37bf51e',
  'andrew.fitton.55bd7a24@apsl.player',
  'Andrew',
  'Fitton',
  crypt('Playerlbw8lh24!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '59e41f4c-e413-0006-1edb-5e6ba072fb83',
  'mike.foutsop.55bd7a24@apsl.player',
  'Mike',
  'Foutsop',
  crypt('Playerm0u5xnz7!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '3b2f0a78-ba07-0006-f038-69f2576600ad',
  'neema.gharib.55bd7a24@apsl.player',
  'Neema',
  'Gharib',
  crypt('Playerewnewvbr!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd5de72db-584f-0006-621e-d2b75fe48c8a',
  'andrew.halloran.55bd7a24@apsl.player',
  'Andrew',
  'Halloran',
  crypt('Playerwprplpme!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a22980eb-3044-0006-ca16-5c3c911c48d1',
  'thierno.issabre.55bd7a24@apsl.player',
  'Thierno',
  'Issabre',
  crypt('Playeru4gxo0st!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '93a8d0cd-ec1d-0006-eefc-d4fbdb90e896',
  'michael.johnson.55bd7a24@apsl.player',
  'Michael',
  'Johnson',
  crypt('Playerwo731q9y!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ad965ae0-6702-0006-3180-99a7e70e2a0a',
  'brennan.koslow.55bd7a24@apsl.player',
  'Brennan',
  'Koslow',
  crypt('Playermscknef4!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '4999ad84-dd4b-0006-f470-024b80b2db5f',
  'mitchell.kupstas.55bd7a24@apsl.player',
  'Mitchell',
  'Kupstas',
  crypt('Player3issetq6!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '8ab06db9-7ffc-0006-e347-a1dba37b0698',
  'adrian.lollar.55bd7a24@apsl.player',
  'Adrian',
  'Lollar',
  crypt('Playerby24f093!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '1cac3e46-a5a9-0006-90c5-4ef7f35b9733',
  'mckinley.mercer.iii.55bd7a24@apsl.player',
  'McKinley',
  'Mercer III',
  crypt('Player4l8iteem!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f9386d75-8e8a-0006-6b26-25e0ebdd5758',
  'luke.narker.55bd7a24@apsl.player',
  'Luke',
  'Narker',
  crypt('Player9mstxzpq!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5b5042e1-28be-0006-650b-f7ef67ada2b8',
  'hassan.pinto.55bd7a24@apsl.player',
  'Hassan',
  'Pinto',
  crypt('Player1axrf87y!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e698698f-86cb-0006-dfdd-b8b296971737',
  'cory.plasker.55bd7a24@apsl.player',
  'Cory',
  'Plasker',
  crypt('Playernoc69l3h!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd5fe16b6-d486-0006-003d-4cb836f13de0',
  'max.poore.55bd7a24@apsl.player',
  'Max',
  'Poore',
  crypt('Playerdkrh6upw!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '9a4a00f9-924d-0006-4573-3693c5d6041b',
  'kevin.reyes.55bd7a24@apsl.player',
  'Kevin',
  'Reyes',
  crypt('Playerwmxrnyxq!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '2d6265b1-253e-0006-cc14-ed318220a368',
  'sharpe.sablon.55bd7a24@apsl.player',
  'Sharpe',
  'Sablon',
  crypt('Playern2e41izd!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '970313b2-94c8-0006-8fec-5f18f915290a',
  'iain.smith.55bd7a24@apsl.player',
  'Iain',
  'Smith',
  crypt('Playercvr2p4l1!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '1c0174b6-5432-0006-541b-cd449efcc7d1',
  'thor.svienbjorsson.55bd7a24@apsl.player',
  'Thor',
  'Svienbjorsson',
  crypt('Playerkx6u8r1b!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c1036a25-e2de-0006-8a70-68ab51170558',
  'thomas.toney.55bd7a24@apsl.player',
  'Thomas',
  'Toney',
  crypt('Player9k994afs!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '0487e9d0-0181-0006-18d8-02f40df4aa20',
  'zachary.paul.young.55bd7a24@apsl.player',
  'Zachary',
  'Paul Young',
  crypt('Playerelyfqyej!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Peachtree FC USERS
-- ========================================
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '52f86506-b899-0006-e304-e601997b9c2e',
  'bilal.ahmed.ec1718e1@apsl.player',
  'Bilal',
  'Ahmed',
  crypt('Playerjteojmmy!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ea26b1b1-cb54-0006-821b-a6d301f142fa',
  'tim.amoui.ec1718e1@apsl.player',
  'Tim',
  'Amoui',
  crypt('Player5kvpsk6h!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '498f385c-3957-0006-a1e5-9a699de6be68',
  'badr.el.yazami.ec1718e1@apsl.player',
  'Badr',
  'El Yazami',
  crypt('Playerxf3f1x8c!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '2b945af7-cdc8-0006-78dd-e619fa32962d',
  'stan.lee.etienne.ec1718e1@apsl.player',
  'Stan-Lee',
  'Etienne',
  crypt('Playernineuw7j!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ef86c172-542a-0006-04fa-2c534d58d487',
  'sylvi.mahmood.ec1718e1@apsl.player',
  'Sylvi',
  'Mahmood',
  crypt('Playerbkj29t4m!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '93a498fb-a70a-0006-a1e1-3991ba21c677',
  'pedro.marinho.ec1718e1@apsl.player',
  'Pedro',
  'Marinho',
  crypt('Player0ltf2upi!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '14145f3a-4794-0006-2b1f-0e9155b0041a',
  'juan.martinez.ec1718e1@apsl.player',
  'Juan',
  'Martinez',
  crypt('Playerals42zjf!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '39e859f3-11d8-0006-9c15-0711da626eed',
  'david.michaelson.ec1718e1@apsl.player',
  'David',
  'Michaelson',
  crypt('Player53198b9b!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '8063071f-b57e-0006-5ce3-ffab43fa5242',
  'metsantika.mokgoatsana.ec1718e1@apsl.player',
  'Metsantika',
  'Mokgoatsana',
  crypt('Playeroj6a41cu!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '257e6ff6-b2c0-0006-7297-f76cfc123f39',
  'ali.niang.ec1718e1@apsl.player',
  'Ali',
  'Niang',
  crypt('Player80a4j0wq!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '92d69d87-c612-0006-6d8f-9379b771a731',
  'javier.pace.ec1718e1@apsl.player',
  'Javier',
  'Pace',
  crypt('Playerp0z47n4b!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ff05a9d3-7c8d-0006-26d2-a45f24cb78ee',
  'osman.rodriguez.ec1718e1@apsl.player',
  'Osman',
  'Rodriguez',
  crypt('Player919sm78e!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '6c76d517-d4a9-0006-f761-17c854e78335',
  'aaron.shiffman.ec1718e1@apsl.player',
  'Aaron',
  'Shiffman',
  crypt('Playerosmlfi5i!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f69c1672-6dea-0006-be5c-c84dd2296418',
  'miwoned.siraj.ec1718e1@apsl.player',
  'Miwoned',
  'Siraj',
  crypt('Playert4p7riwh!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '801b1e30-0a36-0006-a3ce-7f8d45d5043d',
  'tyler.swinehart.ec1718e1@apsl.player',
  'Tyler',
  'Swinehart',
  crypt('Playerfjpir8do!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a1743c4a-f809-0006-aeb5-cc5802df6539',
  'gabriel.villar.ec1718e1@apsl.player',
  'Gabriel',
  'Villar',
  crypt('Playerct2prgrh!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '2f17c28d-7780-0006-f293-e630663fba56',
  'michael.walsh.ec1718e1@apsl.player',
  'Michael',
  'Walsh',
  crypt('Playeroyqwmlml!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ff317d6c-7e60-0006-e5f7-404306adce9c',
  'joshua.warde.ec1718e1@apsl.player',
  'Joshua',
  'Warde',
  crypt('Playermrhtxsc3!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '0e363b75-23a6-0006-be3e-7aaebd6032ad',
  'christopher.wilson.ec1718e1@apsl.player',
  'Christopher',
  'Wilson',
  crypt('Playergfltn9ld!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '1a392f98-9da7-0006-1a53-6dbc563e6a10',
  'kyle.xhajanka.ec1718e1@apsl.player',
  'Kyle',
  'Xhajanka',
  crypt('Playeridfgwd4w!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Prima FC USERS
-- ========================================
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f15d6958-7484-0006-c037-657c85b1ae38',
  'zackeriah.aday.nicholson.07e8c5da@apsl.player',
  'Zackeriah',
  'Aday-Nicholson',
  crypt('Playerfw9hedrn!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e60ac574-f2cd-0006-4b5d-d76ee6adc628',
  'gabriel.alvarez.07e8c5da@apsl.player',
  'Gabriel',
  'Alvarez',
  crypt('Player7a7t8ni3!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '0d0bc3b1-617c-0006-0ca4-ac355679760e',
  'dylan.bapst.07e8c5da@apsl.player',
  'Dylan',
  'Bapst',
  crypt('Player0jod0gpd!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '61796fe0-4ef5-0006-40ae-e9d3f36a597f',
  'mitchell.barry.07e8c5da@apsl.player',
  'Mitchell',
  'Barry',
  crypt('Player303hfqve!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a82f72e6-c197-0006-abd2-2de08516908f',
  'charles.blakenship.07e8c5da@apsl.player',
  'Charles',
  'Blakenship',
  crypt('Playera9ky3pm6!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '1ca12f32-d400-0006-7206-5f58c95d959d',
  'kevin.carvalho.07e8c5da@apsl.player',
  'Kevin',
  'Carvalho',
  crypt('Playerzydwywop!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '3e8d7a95-b863-0006-b8db-9ea871cfe3d7',
  'stefan.gojic.07e8c5da@apsl.player',
  'Stefan',
  'Gojic',
  crypt('Player84v1li31!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '3ff14c9b-20cc-0006-7a9b-5f7593a0c84e',
  'andrew.grodhaus.07e8c5da@apsl.player',
  'Andrew',
  'Grodhaus',
  crypt('Player3fswjfdg!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5fe9912f-c785-0006-c7d1-538ccbf4ae91',
  'colton.huebner.07e8c5da@apsl.player',
  'Colton',
  'Huebner',
  crypt('Playerra7aw3ls!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '9f15468d-3c73-0006-204f-d2263be1c97d',
  'joshua.james.07e8c5da@apsl.player',
  'Joshua',
  'James',
  crypt('Player5pexnf10!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '4c11f19d-a362-0006-0d43-df83659861dc',
  'william.keegan.07e8c5da@apsl.player',
  'William',
  'Keegan',
  crypt('Playerjuyj5npp!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '2ab8ee61-bd29-0006-23d7-7f56fd290ffb',
  'konrad.knap.07e8c5da@apsl.player',
  'Konrad',
  'Knap',
  crypt('Playerjpm7arzc!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5169e942-a093-0006-c028-bd204017359f',
  'jordan.locke.07e8c5da@apsl.player',
  'Jordan',
  'Locke',
  crypt('Playeriybw35p5!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '0de960d5-64e9-0006-aa98-badd0aa017b4',
  'christopher.marshall.07e8c5da@apsl.player',
  'Christopher',
  'Marshall',
  crypt('Playerza7lagw6!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'bcb4f1a9-6840-0006-74bf-a31fe146b7d8',
  'javier.martinez.07e8c5da@apsl.player',
  'Javier',
  'Martinez',
  crypt('Playerypszs8oc!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '3c66a94d-42e1-0006-a6f6-cce213a54dfb',
  'cain.mcmillan.07e8c5da@apsl.player',
  'Cain',
  'McMillan',
  crypt('Playerlyozoxv6!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7644c73d-5a0b-0006-94c6-c6177a87a0d9',
  'anthony.norman.07e8c5da@apsl.player',
  'Anthony',
  'Norman',
  crypt('Playermazr5cu4!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e594e343-368c-0006-5996-dce06cd0dcfa',
  'sampson.nsemoh.07e8c5da@apsl.player',
  'Sampson',
  'Nsemoh',
  crypt('Playergrv56fws!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ca6343cb-5d14-0006-4562-d5b64127dab7',
  'thomas.powers.07e8c5da@apsl.player',
  'Thomas',
  'Powers',
  crypt('Playerg8ybrhuj!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '99c86369-da29-0006-9704-3d5552dcead7',
  'seth.prieto.07e8c5da@apsl.player',
  'Seth',
  'Prieto',
  crypt('Playern05h9iko!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5a791d6c-7ff7-0006-4031-de562ad81dce',
  'adam.rooney.07e8c5da@apsl.player',
  'Adam',
  'Rooney',
  crypt('Playerwje2hy56!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '87673ffe-2b0b-0006-b73b-4abde057abe4',
  'jacob.sayer.07e8c5da@apsl.player',
  'Jacob',
  'Sayer',
  crypt('Playerqod3dvtk!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '22faa896-9be8-0006-9d24-3bda3579c08b',
  'zachary.smith.07e8c5da@apsl.player',
  'Zachary',
  'Smith',
  crypt('Player6gfn8z89!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '43212e19-925a-0006-52b0-aca62ed0d5ff',
  'christian.waeglin.07e8c5da@apsl.player',
  'Christian',
  'Waeglin',
  crypt('Playernhiyz2dv!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f7d36655-c443-0006-8ac5-78a0bbd5903d',
  'christopher.witmond.07e8c5da@apsl.player',
  'Christopher',
  'Witmond',
  crypt('Player9pcheun5!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Bel Calcio FC USERS
-- ========================================
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '09d33dd8-9416-0006-67ec-8326bbeb0fb2',
  'nathan.bio.268164a2@apsl.player',
  'Nathan',
  'Bio',
  crypt('Playerxut5dsx6!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '26333b66-701b-0006-f490-b40467188a5d',
  'rob.bonet.268164a2@apsl.player',
  'Rob',
  'Bonet',
  crypt('Playerzx5xppmc!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ebd6e635-936f-0006-17ed-5d87219f8bb6',
  'aziymu.shamil.burns.268164a2@apsl.player',
  'Aziymu',
  'Shamil Burns',
  crypt('Playerxz4a2dqv!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '2f05bd4a-cf23-0006-4e12-0bd459133d35',
  'jackson.cavenaugh.268164a2@apsl.player',
  'Jackson',
  'Cavenaugh',
  crypt('Playerebr5djfr!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '91be8151-889f-0006-1a47-e4ca10e09600',
  'kyle.crawford.268164a2@apsl.player',
  'Kyle',
  'Crawford',
  crypt('Playerbks2z2er!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd3793838-381f-0006-534c-49b50580b7b9',
  'eduardo.delgado.268164a2@apsl.player',
  'Eduardo',
  'Delgado',
  crypt('Playerpthqd62w!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'dd723fbb-b34f-0006-abbe-7d105ebcc0e5',
  'matheus.fineto.268164a2@apsl.player',
  'Matheus',
  'Fineto',
  crypt('Player8a37wek8!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a8cbc1a7-608f-0006-dbf6-2c64b8372997',
  'enrique.gonzalez.plaza.268164a2@apsl.player',
  'Enrique',
  'Gonzalez Plaza',
  crypt('Player23g9sjxd!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7b2321d4-35cd-0006-5ac8-3b60f32d59cf',
  'chris.griffith.268164a2@apsl.player',
  'Chris',
  'Griffith',
  crypt('Player2cig5v77!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ed937721-2e32-0006-150d-778b8d7419b7',
  'philip.harris.268164a2@apsl.player',
  'Philip',
  'Harris',
  crypt('Playeregyhygs9!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '2beabf16-26d4-0006-198e-73e5939c02b7',
  'justin.heimerl.268164a2@apsl.player',
  'Justin',
  'Heimerl',
  crypt('Playerw64sfszc!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '2225523c-19d1-0006-7331-3379c90a6a05',
  'lucas.horton.268164a2@apsl.player',
  'Lucas',
  'Horton',
  crypt('Playerda8y1hum!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '9f8bf572-09e7-0006-0cfc-2ced73776715',
  'karson.reese.kendall.268164a2@apsl.player',
  'Karson',
  'Reese Kendall',
  crypt('Playerxcwguzle!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '93916a6c-3912-0006-9c0d-1095cf2523fc',
  'konner.kendall.268164a2@apsl.player',
  'Konner',
  'Kendall',
  crypt('Playerue2hbctm!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'cd983245-a660-0006-2f72-541e59202e9b',
  'mouad.labied.268164a2@apsl.player',
  'Mouad',
  'Labied',
  crypt('Playerk1b8ibc8!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd4fefc80-25ea-0006-41d0-edf53c08b333',
  'jake.langton.268164a2@apsl.player',
  'Jake',
  'Langton',
  crypt('Player6oxpa0y3!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '8c997c27-8525-0006-9be6-694cf8adaaaf',
  'myles.levelle.268164a2@apsl.player',
  'Myles',
  'Levelle',
  crypt('Playerv4wg5f72!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c863a6a6-8ba3-0006-b896-f6c26b9ee9dc',
  'randy.mallar.calvillo.268164a2@apsl.player',
  'Randy',
  'Mallar-Calvillo',
  crypt('Playerxafy7zlp!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c299b0e4-a978-0006-9c4b-dc0430d07e29',
  'matt.mitchell.268164a2@apsl.player',
  'Matt',
  'Mitchell',
  crypt('Playern3zfg9cn!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'de60f99d-d8ae-0006-149d-1fba66a5bf3e',
  'nikos.papanikolopoulos.268164a2@apsl.player',
  'Nikos',
  'Papanikolopoulos',
  crypt('Playeruh62h3vx!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'da7e0b9d-2448-0006-7ee7-7d7b9b2aac2a',
  'cade.quinto.268164a2@apsl.player',
  'Cade',
  'Quinto',
  crypt('Playerkdlnpl3o!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'cb7de99c-a2da-0006-b86c-9acb3f1fbe1d',
  'juandi.riley.268164a2@apsl.player',
  'Juandi',
  'Riley',
  crypt('Playerbay6o2lu!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '76e8d381-bbf1-0006-86be-df0ec9e64eb7',
  'luis.romero.268164a2@apsl.player',
  'Luis',
  'Romero',
  crypt('Playerzsdxir8d!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ba4c1420-36e5-0006-9817-60976e01e18a',
  'eduardo.ernesto.salmeron.268164a2@apsl.player',
  'Eduardo',
  'Ernesto Salmeron',
  crypt('Playerew08ga1m!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '888f33dd-c99b-0006-c158-4e6413a860a1',
  'aswin.sembu.268164a2@apsl.player',
  'Aswin',
  'Sembu',
  crypt('Playerghg2fmzx!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'fec78a36-aec8-0006-a6df-1cbc76d446b7',
  'adam.sole.268164a2@apsl.player',
  'Adam',
  'Sole',
  crypt('Playerpg9jgmox!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '05d44070-70a3-0006-3128-a8f89ac11946',
  'zaid.takrouri.268164a2@apsl.player',
  'Zaid',
  'Takrouri',
  crypt('Playerfua8c7m4!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '65b83388-5051-0006-5e4c-7b3117013677',
  'michael.touihri.268164a2@apsl.player',
  'Michael',
  'Touihri',
  crypt('Playerorukbya7!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '6a27f8b7-700f-0006-08f3-dcd43f81b028',
  'ivan.verdezoto.268164a2@apsl.player',
  'Ivan',
  'Verdezoto',
  crypt('Player8ezrw2md!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '98a982b4-e3dd-0006-a7eb-c107c716b5ad',
  'min.yoo.268164a2@apsl.player',
  'Min',
  'Yoo',
  crypt('Playerqz7hhdwl!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Buckhead SC USERS
-- ========================================
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '67c717f9-0e22-0006-a160-6f0b0af633ec',
  'jonathan.adabi.3ae0fc91@apsl.player',
  'Jonathan',
  'Adabi',
  crypt('Playeryt8rsik6!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7edd3143-8eae-0006-f999-9848f54d30b6',
  'tishe.adekanmbi.3ae0fc91@apsl.player',
  'Tishe',
  'Adekanmbi',
  crypt('Playergscdfoq2!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '154447ed-44c1-0006-bc8c-8a2c58749b78',
  'abdoulmalik.adesanya.3ae0fc91@apsl.player',
  'Abdoulmalik',
  'Adesanya',
  crypt('Player6m2vcfkv!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'fe4d0dea-8ee6-0006-8c10-b1891334cda1',
  'caleb.ayan.3ae0fc91@apsl.player',
  'Caleb',
  'Ayan',
  crypt('Playerd22q4k8g!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '8c6f22ca-0469-0006-7a53-5dfa7b1dc1d1',
  'olumide.ayo.ajibike.3ae0fc91@apsl.player',
  'Olumide',
  'Ayo-Ajibike',
  crypt('Playerg18l60zh!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '943b61f3-6d76-0006-37ea-410450964c10',
  'elad.khaleef.bogle.3ae0fc91@apsl.player',
  'Elad',
  'Khaleef Bogle',
  crypt('Playerkte4cqnl!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '35e548cf-d0c9-0006-c19c-ddcb23dde64c',
  'tobias.ciho.3ae0fc91@apsl.player',
  'Tobias',
  'Ciho',
  crypt('Players3k3g6xk!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'aa6d515d-7bfd-0006-15ad-f251c2b7c979',
  'nixon.manuel.condolo.3ae0fc91@apsl.player',
  'Nixon',
  'Manuel Condolo',
  crypt('Playern5u08bvq!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '79e7c669-0541-0006-0d28-9821dd9dc9fe',
  'felipe.correa.3ae0fc91@apsl.player',
  'Felipe',
  'Correa',
  crypt('Playerftpsl3wv!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b5ea4dc4-80f0-0006-4645-a1178a1fb88b',
  'michael.dardis.3ae0fc91@apsl.player',
  'Michael',
  'Dardis',
  crypt('Player8otjn3n5!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b2c3bcac-93df-0006-0ef5-3f9597f635ec',
  'abdoulaye.diba.3ae0fc91@apsl.player',
  'Abdoulaye',
  'Diba',
  crypt('Playeraqestucw!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '8a8f94f7-62da-0006-4bdb-6055ca84b233',
  'lech.dunser.3ae0fc91@apsl.player',
  'Lech',
  'Dunser',
  crypt('Playerw6genwy3!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '67a4045c-e53f-0006-b26a-7fb0b9af295d',
  'daniel.duran.gonzalez.3ae0fc91@apsl.player',
  'Daniel',
  'Duran Gonzalez',
  crypt('Playerbq1wq1vg!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7629c0b7-fcf3-0006-3b4a-b74a2ef45a10',
  'david.alejandro.fierro.3ae0fc91@apsl.player',
  'David',
  'Alejandro Fierro',
  crypt('Playerqf65yp0g!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e7655121-b366-0006-75b8-2de65542c573',
  'caleb.johnson.3ae0fc91@apsl.player',
  'Caleb',
  'Johnson',
  crypt('Playerrnideems!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5ca21ef1-623e-0006-ff8b-c1141e0bce59',
  'ian.thomas.kunkel.3ae0fc91@apsl.player',
  'Ian',
  'Thomas Kunkel',
  crypt('Player9x8bmbq0!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5255297c-d992-0006-4de2-8306b24109e7',
  'jelle.lansdaal.3ae0fc91@apsl.player',
  'Jelle',
  'Lansdaal',
  crypt('Playert15ds8ht!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '3b0d79af-38c8-0006-970a-2877cfc59131',
  'ruari.eamonn.o.rourke.3ae0fc91@apsl.player',
  'Ruari',
  'Eamonn O’Rourke',
  crypt('Playerqgzl92d9!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'fc49af75-7fb6-0006-e311-bf38ab82a796',
  'siddharth.rajesh.3ae0fc91@apsl.player',
  'Siddharth',
  'Rajesh',
  crypt('Player1f2qcpmk!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7d32ad87-9bcc-0006-6d63-031bcceb1b7e',
  'anel.ramic.3ae0fc91@apsl.player',
  'Anel',
  'Ramic',
  crypt('Playernquhktat!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '40cf4020-29c7-0006-6bce-361774fc2ced',
  'sumner.richardson.3ae0fc91@apsl.player',
  'Sumner',
  'Richardson',
  crypt('Player0o3wyxe4!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5b22976d-62cc-0006-d50f-8277a6bb2af1',
  'george.bishop.rodi.3ae0fc91@apsl.player',
  'George',
  'Bishop Rodi',
  crypt('Player5y5qcifp!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '0b049e08-e6e9-0006-44e8-efd2fe719ac5',
  'connor.rosenthal.3ae0fc91@apsl.player',
  'Connor',
  'Rosenthal',
  crypt('Player172kzlne!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7fd110a7-4f2b-0006-85c1-a10ce80701f0',
  'godfred.nii.tettey.3ae0fc91@apsl.player',
  'Godfred',
  'Nii Tettey',
  crypt('Playerrzf4cp4y!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '9102d5a1-ac5f-0006-a057-6393aef813e1',
  'joshua.parbie.tettey.3ae0fc91@apsl.player',
  'Joshua',
  'Parbie Tettey',
  crypt('Playerflqo1d2d!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd69142ce-1550-0006-5cf7-b8a659857391',
  'robert.a.thomas.3ae0fc91@apsl.player',
  'Robert',
  'A Thomas',
  crypt('Playerwu3y6a6d!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '779cbd46-c4d9-0006-ff5c-9f228c0b4da5',
  'chris.arturo.vitela.3ae0fc91@apsl.player',
  'Chris',
  'Arturo Vitela',
  crypt('Playerrttjn3rr!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b4f8606a-abf1-0006-8e3c-d48051f0b659',
  'noah.wieland.3ae0fc91@apsl.player',
  'Noah',
  'Wieland',
  crypt('Player2x1t768y!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd5aa9ec2-8926-0006-5b24-ce213b96f3aa',
  'olanrewaju.yusuff.3ae0fc91@apsl.player',
  'Olanrewaju',
  'Yusuff',
  crypt('Playerflbk8ylp!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Alliance SC USERS
-- ========================================
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'eff0ad86-a9c6-0006-e5f7-ca4d37ad5cb5',
  'roberto.carlos.calix.6778fbca@apsl.player',
  'Roberto',
  'Carlos Calix',
  crypt('Player7wue7t2c!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'caec3d52-c03a-0006-ec65-5b08d4d3dc0a',
  'eli.francisco.carrasco.6778fbca@apsl.player',
  'Eli',
  'Francisco Carrasco',
  crypt('Playerz3xguwst!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '36f71167-5317-0006-d0aa-acbe201f774f',
  'axel.castrejon.6778fbca@apsl.player',
  'Axel',
  'Castrejon',
  crypt('Playero4lcj370!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd835978e-f207-0006-65ee-6333880b7597',
  'gael.jared.castrejon.6778fbca@apsl.player',
  'Gael',
  'Jared Castrejon',
  crypt('Playerc5cvaufq!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'cf6a8c79-cf8d-0006-170f-bacbe88aba4c',
  'jared.scott.childs.6778fbca@apsl.player',
  'Jared',
  'Scott Childs',
  crypt('Player1ofw530l!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '51861750-b8fa-0006-56be-e7346cd0d220',
  'dylan.bright.edmonds.6778fbca@apsl.player',
  'Dylan',
  'Bright Edmonds',
  crypt('Playernwjn2p1l!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '02f9d145-bb1a-0006-eb8b-f4d1277cae78',
  'mason.mcgill.fifer.6778fbca@apsl.player',
  'Mason',
  'McGill Fifer',
  crypt('Playerfddu9ckv!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5cf2478b-4c5d-0006-237a-a8271f4e02c1',
  'omar.guadarrama.6778fbca@apsl.player',
  'Omar',
  'Guadarrama',
  crypt('Playertcbfny2g!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7751451a-65bc-0006-1ae7-6733ae9bf858',
  'brandon.gutierrez.6778fbca@apsl.player',
  'Brandon',
  'Gutierrez',
  crypt('Playert8ri56v0!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e13cfeb9-343a-0006-36bb-a0f0088ff3e2',
  'maury.ibarra.6778fbca@apsl.player',
  'Maury',
  'Ibarra',
  crypt('Playerqlxwksll!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'cc9f00af-45b7-0006-6cbc-bea9832c7fc1',
  'sebastian.tyler.jones.6778fbca@apsl.player',
  'Sebastian',
  'Tyler Jones',
  crypt('Playerc0shurpf!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'fadea840-662e-0006-9701-5fd9f1dfb3b0',
  'dino.kalac.6778fbca@apsl.player',
  'Dino',
  'Kalac',
  crypt('Playergqbgjsk7!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '96edb7ca-eada-0006-eaeb-c388fd6bdd7d',
  'taylor.benjamin.lemmon.6778fbca@apsl.player',
  'Taylor',
  'Benjamin Lemmon',
  crypt('Player1hz04i1y!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '3a82f7f6-9f2d-0006-93e8-aa6ab33d8f7c',
  'ivan.israel.lopez.6778fbca@apsl.player',
  'Ivan',
  'Israel Lopez',
  crypt('Playerd7ok5791!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '270cc341-a114-0006-ec56-3a9fccb6a6bc',
  'sebastian.lopez.6778fbca@apsl.player',
  'Sebastian',
  'Lopez',
  crypt('Playerm1xx41s2!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'df9caa89-de4c-0006-3f71-64b0a257e243',
  'juanes.martinez.6778fbca@apsl.player',
  'Juanes',
  'Martinez',
  crypt('Playerk7zm7wsf!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '121da025-6ba1-0006-3ac3-ab2bf02690e0',
  'sebastian.nu.ez.6778fbca@apsl.player',
  'Sebastian',
  'Nuñez',
  crypt('Playerwxx7ah9z!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'fc3700a0-3105-0006-8a86-1eb6e452103f',
  'ashton.thomas.parnell.6778fbca@apsl.player',
  'Ashton',
  'Thomas Parnell',
  crypt('Player39dknv5t!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '74c48423-50fe-0006-9b5e-a91db71a02f6',
  'tyler.pineda.6778fbca@apsl.player',
  'Tyler',
  'Pineda',
  crypt('Playerl9rs8edf!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '39de285a-25e2-0006-ea15-cd1589ff6fa5',
  'voshon.ramcharan.6778fbca@apsl.player',
  'Voshon',
  'Ramcharan',
  crypt('Playerhweaj6fx!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '9d8c4573-6c25-0006-c96a-87176662bddd',
  'marvin.rodriguez.6778fbca@apsl.player',
  'Marvin',
  'Rodriguez',
  crypt('Playerxcxwus85!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '1b7fda65-9e7e-0006-37fe-fb946d2d152c',
  'fabian.rodriguez.escobedo.6778fbca@apsl.player',
  'Fabian',
  'Rodriguez-Escobedo',
  crypt('Playermfiye8ec!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'babbeebc-37b5-0006-f336-d6856f8dfb5b',
  'blair.springhall.6778fbca@apsl.player',
  'Blair',
  'Springhall',
  crypt('Playerm30tw7zk!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '79446aef-a5c9-0006-e301-c46029ca3cca',
  'bradley.hamilton.tidwell.6778fbca@apsl.player',
  'Bradley',
  'Hamilton Tidwell',
  crypt('Playerv0afhhny!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b0cdf812-577c-0006-107a-5dc16237f88f',
  'edward.trejo.6778fbca@apsl.player',
  'Edward',
  'Trejo',
  crypt('Player4psiv5eg!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c309c35d-f4a0-0006-d13b-4f5ebaa12765',
  'johan.miguel.trigo.rios.6778fbca@apsl.player',
  'Johan',
  'Miguel Trigo-Rios',
  crypt('Player4xtzim3r!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'cfebbeb5-b3e5-0006-cf3b-41499bb8bae7',
  'luis.albert.ventura.6778fbca@apsl.player',
  'Luis',
  'Albert Ventura',
  crypt('Player4ayuxyyb!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '668558ba-53a6-0006-ea66-abd8ce89a6fd',
  'patrick.ventura.6778fbca@apsl.player',
  'Patrick',
  'Ventura',
  crypt('Playerrmgcm7qx!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '445838aa-5a02-0006-ef8f-f6d5b3f499d8',
  'nicholas.wheeler.6778fbca@apsl.player',
  'Nicholas',
  'Wheeler',
  crypt('Playery5tnhzf0!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- SC Gwinnett USERS
-- ========================================
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '5663ac0e-d6f3-0006-5a6b-7e4768d01481',
  'adam.abdullahi.d2c80f1f@apsl.player',
  'Adam',
  'Abdullahi',
  crypt('Player1bdwprs2!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '94885f0d-b8a2-0006-bb09-90aeda2b88f6',
  'mohammed.al.asady.d2c80f1f@apsl.player',
  'Mohammed',
  'Al-Asady',
  crypt('Player7z50gzoe!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'bb67c0f6-6f3b-0006-c4c2-980cc8207f19',
  'malek.almariri.d2c80f1f@apsl.player',
  'Malek',
  'Almariri',
  crypt('Player2bijpatq!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '2f66afc0-9bd4-0006-7e7e-5238f40eebb0',
  'mario.arreguin.d2c80f1f@apsl.player',
  'Mario',
  'Arreguin',
  crypt('Player71km2pgr!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '6b3af454-9681-0006-6961-1c23eccaf4a4',
  'ali.bazz.d2c80f1f@apsl.player',
  'Ali',
  'Bazz',
  crypt('Player2wlw5gar!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ea689bee-87e8-0006-4e2d-26cd2b50973f',
  'monchu.camara.d2c80f1f@apsl.player',
  'Monchu',
  'Camara',
  crypt('Playero7ymogy3!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'eed85bda-375a-0006-24d3-11a2c8be7ef6',
  'steven.carrillo.d2c80f1f@apsl.player',
  'Steven',
  'Carrillo',
  crypt('Player0c37f0eu!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '4470d8a6-f46b-0006-b2ad-6eb29365be8b',
  'karl.christiansen.d2c80f1f@apsl.player',
  'Karl',
  'Christiansen',
  crypt('Playersefl77oa!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'ca696aae-8c13-0006-5072-1ddfb011d2ac',
  'franklin.contreras.d2c80f1f@apsl.player',
  'Franklin',
  'Contreras',
  crypt('Playerzzmzb8u0!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c4dc2286-4ae0-0006-0a46-28a0f2736353',
  'vitor.de.souza.d2c80f1f@apsl.player',
  'Vitor',
  'De Souza',
  crypt('Playerz6c3zza8!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd3f94877-31c5-0006-0c0a-40d566403b17',
  'adrian.garcia.d2c80f1f@apsl.player',
  'Adrian',
  'Garcia',
  crypt('Player8sntx4g3!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '1fa147ea-b8e7-0006-b883-cc3b1c41483d',
  'josue.gomez.d2c80f1f@apsl.player',
  'Josue',
  'Gomez',
  crypt('Playerjpawv5h5!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '2cf5fff2-7e09-0006-d248-a063ebd814a8',
  'jafet.higuera.d2c80f1f@apsl.player',
  'Jafet',
  'Higuera',
  crypt('Player5unnn7gd!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '8d7d943d-cf15-0006-d21f-0a0b28cc9f98',
  'rui.james.pereira.d2c80f1f@apsl.player',
  'Rui',
  'James-Pereira',
  crypt('Playertbqy3xcm!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '96ed43c4-4720-0006-5f8c-a3e24a9f67b0',
  'kendrick.jean.d2c80f1f@apsl.player',
  'Kendrick',
  'Jean',
  crypt('Playerg4ycpfpv!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '47a34124-dedf-0006-4230-a2a3eff9cde2',
  'sanaa.listenbee.d2c80f1f@apsl.player',
  'Sanaa',
  'Listenbee',
  crypt('Playerliprgxcm!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '93e5c8c8-d4dd-0006-97aa-7a8760a98cba',
  'chris.louissaint.d2c80f1f@apsl.player',
  'Chris',
  'Louissaint',
  crypt('Playerpjt5dvyl!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '04008f6e-0f84-0006-f7ab-b3e397a27570',
  'david.martinez.d2c80f1f@apsl.player',
  'David',
  'Martinez',
  crypt('Player7xzw2dp1!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f982d691-2b9d-0006-2134-eed4cd86be4e',
  'ramsis.martinez.d2c80f1f@apsl.player',
  'Ramsis',
  'Martinez',
  crypt('Player7m8bebvt!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'fe6ecd1b-23e1-0006-5a4f-21d23c208945',
  'ruben.martinez.d2c80f1f@apsl.player',
  'Ruben',
  'Martinez',
  crypt('Player90vr5f8c!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '73b685ec-39e7-0006-881e-7f5476bdd43c',
  'jonathan.may.d2c80f1f@apsl.player',
  'Jonathan',
  'May',
  crypt('Playeraqzn4bkf!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'cd34aae8-c306-0006-10aa-cc66434b135a',
  'jaylen.mccray.d2c80f1f@apsl.player',
  'Jaylen',
  'McCray',
  crypt('Playerj8j16xer!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7adb4c64-82c4-0006-2798-f01ed6ec79f6',
  'tariq.mohammed.d2c80f1f@apsl.player',
  'Tariq',
  'Mohammed',
  crypt('Player60czg2oh!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c83d9d36-0b03-0006-52d3-742c46bf54af',
  'geovanni.oboh.d2c80f1f@apsl.player',
  'Geovanni',
  'Oboh',
  crypt('Player6es01orx!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '79b9e4cc-05ae-0006-59a2-7d43db57580c',
  'jordan.paul.d2c80f1f@apsl.player',
  'Jordan',
  'Paul',
  crypt('Player21h3eojn!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'da170cc8-0375-0006-2972-9b67eb8176a3',
  'nicolas.pegorer.d2c80f1f@apsl.player',
  'Nicolas',
  'Pegorer',
  crypt('Playerpkjfwawo!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b0ba7e22-61ef-0006-32b7-a9256a34347c',
  'pablo.piraquive.d2c80f1f@apsl.player',
  'Pablo',
  'Piraquive',
  crypt('Playerzht22971!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '8b0f37c3-c302-0006-2b4b-0245b5403fd5',
  'roney.rubio.d2c80f1f@apsl.player',
  'Roney',
  'Rubio',
  crypt('Player1wdasgy9!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '7dc91d0e-f073-0006-31bd-d9616e9771d7',
  'anakin.ruiz.d2c80f1f@apsl.player',
  'Anakin',
  'Ruiz',
  crypt('Playeri1ehje97!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '819b01bb-63ca-0006-74f7-1a50fe600419',
  'jazeime.russell.d2c80f1f@apsl.player',
  'Jazeime',
  'Russell',
  crypt('Playerifl9suek!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '1ce8e347-3f93-0006-bb0f-72263aaf51ba',
  'jonathan.sandoval.d2c80f1f@apsl.player',
  'Jonathan',
  'Sandoval',
  crypt('Playereaxw6nrc!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '02367907-63f3-0006-073c-06dafa1e1789',
  'ayman.saudin.d2c80f1f@apsl.player',
  'Ayman',
  'Saudin',
  crypt('Playerlggmttii!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'cb5bb2a3-ba01-0006-ca9a-05009b4c8825',
  'manuel.simental.d2c80f1f@apsl.player',
  'Manuel',
  'Simental',
  crypt('Playerjwotoyug!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '73a05d99-04fd-0006-32a6-c41b3add7e85',
  'mahmoud.tasslak.d2c80f1f@apsl.player',
  'Mahmoud',
  'Tasslak',
  crypt('Playericqeqbxm!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '2190ac37-15a8-0006-456d-119506e76681',
  'myles.williams.d2c80f1f@apsl.player',
  'Myles',
  'Williams',
  crypt('Playern4pe4fdh!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


-- ========================================
-- Lithonia City FC USERS
-- ========================================
INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'c739b13a-6576-0006-5bb2-2f93ba74cbb6',
  'ochuko.asibelua.fcccc73d@apsl.player',
  'Ochuko',
  'Asibelua',
  crypt('Playerkh3nzhti!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b6d97c5d-90b2-0006-37b6-5a2303eb163a',
  'sang.bawi.fcccc73d@apsl.player',
  'Sang',
  'Bawi',
  crypt('Player8a090m6u!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b87af906-b8b3-0006-29f7-0ddfa1ac3862',
  'kanye.alexander.blake.fcccc73d@apsl.player',
  'Kanye',
  'Alexander Blake',
  crypt('Playerh7v4mxw1!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'b1aae734-0d27-0006-66fc-a13ddc50bfca',
  'jackson.cherfils.fcccc73d@apsl.player',
  'Jackson',
  'Cherfils',
  crypt('Playeryvmzy3m3!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'fee02eb6-dd59-0006-5d57-7b75d5b12b9e',
  'okikiade.leo.faduyile.fcccc73d@apsl.player',
  'Okikiade',
  'Leo Faduyile',
  crypt('Player0lu6fcoq!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e9961d8f-b74d-0006-5056-6efe24b3bbbe',
  'alivic.fossem.fcccc73d@apsl.player',
  'Alivic',
  'Fossem',
  crypt('Player3xoka5jo!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '08913780-7bf7-0006-d3df-41e01b27d88d',
  'didier.lehman.fresh.fcccc73d@apsl.player',
  'Didier',
  'Lehman Fresh',
  crypt('Playerhdeyv6o8!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '67201bda-2955-0006-b71f-927618f5ae53',
  'daniel.gonzalez.fcccc73d@apsl.player',
  'Daniel',
  'Gonzalez',
  crypt('Playeru5d51u7u!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'f7514e41-5757-0006-80fc-b9c5f31fa934',
  'james.wedson.jean.fcccc73d@apsl.player',
  'James',
  'Wedson Jean',
  crypt('Player6apqwafk!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'de1fe14e-bb12-0006-827b-b1012f5d69de',
  'maxinio.joseph.fcccc73d@apsl.player',
  'Maxinio',
  'Joseph',
  crypt('Player5q9l9pdx!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '1d4e2c2d-30b6-0006-3bc6-2e7c2ff30140',
  'berlin.marcelin.fcccc73d@apsl.player',
  'Berlin',
  'Marcelin',
  crypt('Playerjnq4tcqq!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'd8c47625-808c-0006-61ee-ae7cb3e3a52c',
  'hachem.alaoui.mhamdi.fcccc73d@apsl.player',
  'Hachem',
  'Alaoui Mhamdi',
  crypt('Playeruekl9h4r!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e27e77a2-a2d8-0006-a353-bc685f147361',
  'olivier.a.momplaisir.fcccc73d@apsl.player',
  'Olivier',
  'A. Momplaisir',
  crypt('Playerhsc4u1ff!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a2e665d8-ffb4-0006-f969-a936d7d7ca41',
  'aaron.morales.fcccc73d@apsl.player',
  'Aaron',
  'Morales',
  crypt('Playerbm2ub4ol!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '3f422c12-7367-0006-e9c7-5e73cb0fd6fd',
  'taft.parsons.fcccc73d@apsl.player',
  'Taft',
  'Parsons',
  crypt('Playerlfycmxbg!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'a96fb340-d6a4-0006-5451-e428593dcc62',
  'edmar.pere.de.leon.fcccc73d@apsl.player',
  'Edmar',
  'Pere-de Leon',
  crypt('Playerk2q4pczg!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  'e7f2f206-b43d-0006-5b70-cd9a8a9f4292',
  'paul.phillips.fcccc73d@apsl.player',
  'Paul',
  'Phillips',
  crypt('Playerqrlzvax5!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '0fbec5c8-2659-0006-c844-9742e6b518ca',
  'moise.pierre.fcccc73d@apsl.player',
  'Moise',
  'Pierre',
  crypt('Playerof8iq7jd!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '258ebc29-8db9-0006-affd-8026eaa7d7d6',
  'neo.ramos.lorza.fcccc73d@apsl.player',
  'Neo',
  'Ramos Lorza',
  crypt('Player5j0cqme0!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '6cfa8eb7-033a-0006-5b54-6e5d0bed1f7e',
  'edwin.rios.zapata.fcccc73d@apsl.player',
  'Edwin',
  'Rios Zapata',
  crypt('Player9fgok745!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '401961e9-22fc-0006-e710-dc480de22552',
  'jose.ruben.fcccc73d@apsl.player',
  'Jose',
  'Ruben',
  crypt('Playerw3jyt1wy!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '0244d2b0-f028-0006-4cd6-b4055957613b',
  'emmanuel.michael.rwakabuba.fcccc73d@apsl.player',
  'Emmanuel',
  'Michael Rwakabuba',
  crypt('Playerktkyixbc!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '9e344863-6949-0006-201e-cd6a0c3876eb',
  'rickenson.saint.quitte.fcccc73d@apsl.player',
  'Rickenson',
  'Saint Quitte',
  crypt('Playerpewspe1e!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;

INSERT INTO users (id, email, first_name, last_name, password_hash, is_active)
VALUES (
  '23051d8c-96d9-0006-db80-f0fba977bafa',
  'calvin.ventura.fcccc73d@apsl.player',
  'Calvin',
  'Ventura',
  crypt('Playervi9zct57!', gen_salt('bf')),
  true
)
ON CONFLICT (email) DO UPDATE SET
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  updated_at = CURRENT_TIMESTAMP;


