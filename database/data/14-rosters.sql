-- ========================================
-- ROSTERS
-- ========================================
-- Generated: 2025-12-03T18:05:02.873Z
-- Source: https://apslsoccer.com/standings/
-- AUTO-GENERATED - DO NOT EDIT MANUALLY
-- Run scraper to regenerate: node database/scripts/apsl-scraper/scrape-apsl.js
-- ========================================

-- ========================================
-- Falcons FC ROSTER
-- ========================================
INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('053b624f-fff9-0007-8a45-a3033e56fbce', '093a47d2-4a1d-0005-6ab0-93e9e96847d7', 'bc489e31-18bc-0006-a453-a1da54ab1446', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f73537cb-6152-0007-0187-863719bc863f', '093a47d2-4a1d-0005-6ab0-93e9e96847d7', '5c49e2e2-ad5a-0006-4ee3-c305215128b6', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f204a1cd-6033-0007-8aac-00fd1058b3e5', '093a47d2-4a1d-0005-6ab0-93e9e96847d7', '44233d63-78ce-0006-fba1-efb396772745', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('94ffd6b4-e4a8-0007-78c1-6efb79e6feb3', '093a47d2-4a1d-0005-6ab0-93e9e96847d7', 'cef50d30-87ca-0006-e62e-586822754925', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0041d251-a542-0007-a332-0523312e7a95', '093a47d2-4a1d-0005-6ab0-93e9e96847d7', '12a2383c-60bb-0006-1dda-c7de7f7d611b', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9c78414f-17b2-0007-599d-6a3a2a1d594d', '093a47d2-4a1d-0005-6ab0-93e9e96847d7', '96edffa8-9590-0006-537d-d1cf9698b6af', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('43335e4e-1ad7-0007-5ad4-80842ccfee17', '093a47d2-4a1d-0005-6ab0-93e9e96847d7', '5f7550f1-4427-0006-e9b4-17fcb0616453', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('988ffd70-9741-0007-a450-79405fa9151f', '093a47d2-4a1d-0005-6ab0-93e9e96847d7', '0525d425-621f-0006-62de-510cae6fd084', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('015230c3-d6ca-0007-c139-a91e658ad32d', '093a47d2-4a1d-0005-6ab0-93e9e96847d7', '6fe50e6b-0e35-0006-bb79-8e7972576724', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('cbb70c0e-f7d8-0007-0cff-366ece48b8f3', '093a47d2-4a1d-0005-6ab0-93e9e96847d7', '7105e742-14b9-0006-8794-9e89e12909af', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0d467f63-2092-0007-27cd-b97fc8e30b04', '093a47d2-4a1d-0005-6ab0-93e9e96847d7', '65e6160f-d2cf-0006-eb04-f6fb96833838', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3d043209-f7f6-0007-92ef-22ad715a400a', '093a47d2-4a1d-0005-6ab0-93e9e96847d7', 'c34fb70d-e482-0006-7754-fede765c55c5', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('acb92ca0-4b34-0007-910a-da221eb56da8', '093a47d2-4a1d-0005-6ab0-93e9e96847d7', '2150f8f1-31b3-0006-bb23-de553501906f', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d299ad09-2774-0007-5240-38ae3edf9ac7', '093a47d2-4a1d-0005-6ab0-93e9e96847d7', '555ce01d-d87c-0006-7f51-f5c20b9eadd9', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('83547a9a-2895-0007-5215-f335d6f6fb87', '093a47d2-4a1d-0005-6ab0-93e9e96847d7', '27cff52f-9ae4-0006-bbbf-a7e052013510', 4, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e24b94dc-bdd2-0007-1dd7-22ff2cc68821', '093a47d2-4a1d-0005-6ab0-93e9e96847d7', 'c599e90f-95a9-0006-2a35-9f8b78e00617', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('48308918-3024-0007-f268-9ece235c6992', '093a47d2-4a1d-0005-6ab0-93e9e96847d7', 'd8ca8762-1ceb-0006-c985-141d72472997', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('824d67a3-792b-0007-d19a-ebd786a70b50', '093a47d2-4a1d-0005-6ab0-93e9e96847d7', '5697dad8-3dda-0006-4855-fed317e341f4', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('572ca84c-6b85-0007-1906-25533dae17e6', '093a47d2-4a1d-0005-6ab0-93e9e96847d7', '3e76b025-3d56-0006-84b9-5988816cdf5d', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('17f42bce-040d-0007-5282-30c68cb10d97', '093a47d2-4a1d-0005-6ab0-93e9e96847d7', 'c7e8e40b-a6ee-0006-665e-a1cff34e8344', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3ef87087-8978-0007-d80e-6f9456cf364d', '093a47d2-4a1d-0005-6ab0-93e9e96847d7', '6dacb1d8-4f2c-0006-ff1f-f12c5be652fb', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('36716ec4-a1f1-0007-2b52-fb76e77b54c4', '093a47d2-4a1d-0005-6ab0-93e9e96847d7', '98edbbe5-bedf-0006-9640-a2fae231a640', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('34791b0b-85f9-0007-9d53-11615d1d88bc', '093a47d2-4a1d-0005-6ab0-93e9e96847d7', 'e3147dfa-0665-0006-60ba-048be198d406', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3ef31a19-537d-0007-d904-494742c60076', '093a47d2-4a1d-0005-6ab0-93e9e96847d7', 'e502d959-35b0-0006-483a-ae7c34bff8f0', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('890ba217-7d18-0007-ec4b-d556d3864027', '093a47d2-4a1d-0005-6ab0-93e9e96847d7', '52ff2ff0-b13e-0006-c23e-e5e01fdfa7fa', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9bda3040-eef0-0007-94c4-1d425733995c', '093a47d2-4a1d-0005-6ab0-93e9e96847d7', 'ccc170f7-1eb6-0006-d33d-d1f71448291b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1c7b1503-84b8-0007-a632-1477060f1d9c', '093a47d2-4a1d-0005-6ab0-93e9e96847d7', 'fb16d670-27ac-0006-f947-7b777ef10d1a', 4, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('942bdc54-712d-0007-a792-4774eeabd464', '093a47d2-4a1d-0005-6ab0-93e9e96847d7', 'd41ea3ec-cd94-0006-234d-aacf9edfc357', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0f4cbacb-b269-0007-549b-8f4f621e144d', '093a47d2-4a1d-0005-6ab0-93e9e96847d7', '2afa19f0-f49f-0006-c547-1ccd646572a1', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('cbb17df3-9e0d-0007-69bc-d8eac063081e', '093a47d2-4a1d-0005-6ab0-93e9e96847d7', 'b4c0189d-9672-0006-4213-e0b09465c3a8', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;


-- ========================================
-- Praia Kapital ROSTER
-- ========================================
INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('551d5744-bfa5-0007-b0f3-366a5f1ce462', '2a1d62b2-aa71-0005-a6eb-1657e21800bf', 'e31dba3c-4c9e-0006-fdf0-2ce96a1d0cf1', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c73288aa-081c-0007-6afd-92ced139815a', '2a1d62b2-aa71-0005-a6eb-1657e21800bf', 'fd343c92-76fb-0006-ca08-e3a723a8cc6b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4390eb6c-fd21-0007-2296-c4f74cd0e4f3', '2a1d62b2-aa71-0005-a6eb-1657e21800bf', 'f851644e-6cb9-0006-5aa8-a632a57078c0', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a08e01fb-4f07-0007-a5db-ce7454d67832', '2a1d62b2-aa71-0005-a6eb-1657e21800bf', '87b7b08f-477a-0006-c0de-6d9d207b87da', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('8d0331d3-a5af-0007-1dd6-b6815afb8ee7', '2a1d62b2-aa71-0005-a6eb-1657e21800bf', 'a2ebd11d-73f2-0006-22d7-108df2b98cad', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('078b4e43-4a96-0007-c096-d5b4ad36c068', '2a1d62b2-aa71-0005-a6eb-1657e21800bf', 'c3292d68-7400-0006-97b9-a6ffe6203b7d', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7f445d69-c315-0007-22cb-3a02d82e321c', '2a1d62b2-aa71-0005-a6eb-1657e21800bf', '7c1d32d7-e7ce-0006-ae30-5a70828f17fc', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('28244322-a7ed-0007-8c52-6ec64335afbe', '2a1d62b2-aa71-0005-a6eb-1657e21800bf', 'fccb2dbc-232f-0006-1f9b-144f11e0d69e', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('20ebab4d-4023-0007-e46f-d6c8dbbb58cb', '2a1d62b2-aa71-0005-a6eb-1657e21800bf', '86409dff-160f-0006-54e3-3fdb87d5cb6a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ce81c872-b4cd-0007-0668-fed4f98a1ae2', '2a1d62b2-aa71-0005-a6eb-1657e21800bf', 'fd088c7b-7038-0006-1bd0-8b78434937f3', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('58f0ee5a-a3bc-0007-6dc8-716be631c486', '2a1d62b2-aa71-0005-a6eb-1657e21800bf', 'e83b1a8e-c742-0006-5175-c43e0dffcef9', 5, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e2275b3b-1952-0007-d41c-c6d8c31903dc', '2a1d62b2-aa71-0005-a6eb-1657e21800bf', '88844133-cc21-0006-a9fb-dacb5b6b84bb', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e6276e9a-2685-0007-b67d-debc8a6a97b7', '2a1d62b2-aa71-0005-a6eb-1657e21800bf', '2e0c45ff-6275-0006-9117-e96c2ed11875', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d3b09192-cda6-0007-145c-8d9a7abb9354', '2a1d62b2-aa71-0005-a6eb-1657e21800bf', '3dfb6f5b-096c-0006-c0de-68202a0d9faa', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c79fc3cb-5275-0007-0c6f-163a9c2a7004', '2a1d62b2-aa71-0005-a6eb-1657e21800bf', 'f95dbd22-4646-0006-aada-9a12965ee8ae', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c056a78d-6f06-0007-a19f-ceb40864df99', '2a1d62b2-aa71-0005-a6eb-1657e21800bf', 'd90af098-0a64-0006-3c03-d13566b89e37', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0a8e54c5-2870-0007-f916-dc6de1679df6', '2a1d62b2-aa71-0005-a6eb-1657e21800bf', 'ee7421f3-c84c-0006-1ca0-c982c2fcb5d9', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('84aadd9f-aa30-0007-a577-70f41729b499', '2a1d62b2-aa71-0005-a6eb-1657e21800bf', '387aa92c-35b5-0006-9106-89bf626a2a9b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9bb26bdd-b2e4-0007-ecbc-28eb298c1b0f', '2a1d62b2-aa71-0005-a6eb-1657e21800bf', 'd84b1454-08e0-0006-9959-17e52024b912', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a2d6c8c6-96e2-0007-56a1-5f300545b203', '2a1d62b2-aa71-0005-a6eb-1657e21800bf', '861a9259-8263-0006-cba5-08bb38bed8b1', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1169d4f3-8903-0007-b874-0de7979dc771', '2a1d62b2-aa71-0005-a6eb-1657e21800bf', 'c319fa3b-42fc-0006-2d45-554b851e072d', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ca24a4ea-faab-0007-e768-6784ba175bda', '2a1d62b2-aa71-0005-a6eb-1657e21800bf', '61811672-a748-0006-471a-ff078e1d948a', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9e4b086c-aca7-0007-a23c-8044eaf788d5', '2a1d62b2-aa71-0005-a6eb-1657e21800bf', '143a5631-da25-0006-934a-d1948f94e21b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('54393d65-fe2e-0007-b9b2-1e534f95ec0f', '2a1d62b2-aa71-0005-a6eb-1657e21800bf', 'f977223a-11d9-0006-9961-46111a0a54c8', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7a9dec08-81bf-0007-3165-ed01eb5b51cf', '2a1d62b2-aa71-0005-a6eb-1657e21800bf', 'ee9f6275-f535-0006-51f3-ff103380cd5d', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('decb6460-fb1a-0007-aa46-e5b418233524', '2a1d62b2-aa71-0005-a6eb-1657e21800bf', '7f8e5e32-65a7-0006-9a6c-ac1ffb0b2091', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('74ab4cb1-a668-0007-9fc3-7f62826bd1f9', '2a1d62b2-aa71-0005-a6eb-1657e21800bf', '91df8aa5-b523-0006-893e-b6fad4068325', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('14b565da-34de-0007-9828-295a095911a6', '2a1d62b2-aa71-0005-a6eb-1657e21800bf', '7e7daebe-d025-0006-e8b6-600df20ada67', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a3ea7748-f2d3-0007-4de4-8ddd4f790c3d', '2a1d62b2-aa71-0005-a6eb-1657e21800bf', '18dc5113-3f83-0006-81fc-f69045394f51', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ee7b52cd-28d8-0007-6d93-a7a20bbe8e22', '2a1d62b2-aa71-0005-a6eb-1657e21800bf', '460efcef-562c-0006-8924-923906fa19fa', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('761d69ec-4868-0007-3f6e-fc8b4d50d33b', '2a1d62b2-aa71-0005-a6eb-1657e21800bf', '54f00ed5-af3a-0006-4804-3c28b8407d25', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ddcfec95-d1e8-0007-f6d5-d9e688b02458', '2a1d62b2-aa71-0005-a6eb-1657e21800bf', 'aa8cdd1f-2f60-0006-7d61-82fcf619ca06', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b4df6cd8-db0b-0007-567e-dd30e53ead10', '2a1d62b2-aa71-0005-a6eb-1657e21800bf', '1a62fb6b-513c-0006-eb2b-803d32eeb8c1', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('26bdb7f5-a172-0007-56c8-7018705cce43', '2a1d62b2-aa71-0005-a6eb-1657e21800bf', '46d71052-d92c-0006-5590-45bdde73a9c4', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;


-- ========================================
-- Scrub Nation ROSTER
-- ========================================
INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('6f7e984e-163b-0007-f2d2-7a38ceb7087d', 'cd2f494d-83b2-0005-7009-2d86f0e05d52', 'be3d7a2f-4376-0006-68de-3edfc7b28db2', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9d16c065-3516-0007-48f4-87daed1efe21', 'cd2f494d-83b2-0005-7009-2d86f0e05d52', '4d2a7ae1-7725-0006-6808-c3504221f691', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('5caf4fe0-91bd-0007-d1e9-a1376b1aea42', 'cd2f494d-83b2-0005-7009-2d86f0e05d52', '344bb3ac-f5c7-0006-a175-b4f77514ee1e', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d94e6de4-ae32-0007-0782-b179fb45b090', 'cd2f494d-83b2-0005-7009-2d86f0e05d52', '915c256d-cd85-0006-5dae-e10ff96b98b1', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ad9a933a-2a2c-0007-5c97-61b66af8d5c9', 'cd2f494d-83b2-0005-7009-2d86f0e05d52', '6aa8ad86-e544-0006-c25c-13cf3bc8a7b8', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1a882673-d4ec-0007-a40c-1a731cede343', 'cd2f494d-83b2-0005-7009-2d86f0e05d52', '1a804906-0737-0006-ead8-7359e6369a82', 3, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e92e9ac0-4751-0007-fcb1-bbe5de9f43de', 'cd2f494d-83b2-0005-7009-2d86f0e05d52', 'cfae0a60-470c-0006-dec9-0921dfe37b17', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b59c314b-d7b4-0007-5687-27a4b98b05f9', 'cd2f494d-83b2-0005-7009-2d86f0e05d52', 'f7f32808-0086-0006-9153-171e8d9ca239', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ac83e061-7b96-0007-5e80-ec5085c22ae4', 'cd2f494d-83b2-0005-7009-2d86f0e05d52', '38771ca6-bb8d-0006-b759-dd63ba4aebc0', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0dc4e3bb-f4ca-0007-f766-9b5cd9c60d15', 'cd2f494d-83b2-0005-7009-2d86f0e05d52', 'ff2c7239-bf24-0006-f246-bb2a8f522ce8', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9b37a8a2-d3c9-0007-3f17-72f4d0617620', 'cd2f494d-83b2-0005-7009-2d86f0e05d52', 'b11ac0fc-30c2-0006-c648-7fa2f00debcf', 6, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('77dafa3b-a03e-0007-6f89-950ee07a5066', 'cd2f494d-83b2-0005-7009-2d86f0e05d52', '3edd6e07-6c67-0006-2909-80d45f2e7f98', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b4b6b23b-7147-0007-f450-5a948c8dc753', 'cd2f494d-83b2-0005-7009-2d86f0e05d52', '98a0f920-cfc2-0006-b109-c9ec48b1ea03', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('89aefecc-f107-0007-0434-f5652d2a7c91', 'cd2f494d-83b2-0005-7009-2d86f0e05d52', 'e87e38b3-aeaf-0006-5e85-a29f4b90b609', 5, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('13b0f5df-3e4a-0007-0b82-c561e7575c08', 'cd2f494d-83b2-0005-7009-2d86f0e05d52', '549cbadd-88ab-0006-fc0f-bd5e4dec4835', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2a1fc42f-a388-0007-c5a4-e2bf12ad41ae', 'cd2f494d-83b2-0005-7009-2d86f0e05d52', 'ce0cf326-8d32-0006-ec20-e214cca9d975', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c4ae144b-14f8-0007-3207-7121a8b161e3', 'cd2f494d-83b2-0005-7009-2d86f0e05d52', '01337fcc-e21f-0006-b2c6-f34a59455b17', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('46f6e5de-0a30-0007-d186-d42edce899e7', 'cd2f494d-83b2-0005-7009-2d86f0e05d52', 'a0306b79-daa2-0006-f039-827bf55a2191', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e9992292-77ee-0007-2f78-24f09e518f27', 'cd2f494d-83b2-0005-7009-2d86f0e05d52', '77bfd936-9f9e-0006-2674-a6c08b37d6c5', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('93608c23-3fbb-0007-f9c4-ea5a91337ce5', 'cd2f494d-83b2-0005-7009-2d86f0e05d52', '7ef823de-425f-0006-2d47-2e5452ea2530', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('143dcc1d-01b3-0007-6cba-f5f3fd771093', 'cd2f494d-83b2-0005-7009-2d86f0e05d52', '796ba022-c23e-0006-e946-77db796e9276', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('02a0ecae-1b38-0007-048f-d4c3904d832a', 'cd2f494d-83b2-0005-7009-2d86f0e05d52', 'f364b18e-75ce-0006-23b6-8ea676bd145b', 4, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('39cca858-250c-0007-f52e-bd2555a89127', 'cd2f494d-83b2-0005-7009-2d86f0e05d52', 'e5ca9bf6-52a9-0006-1daa-611075d43f4f', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('98126436-bf74-0007-a1cb-1c200326ae6a', 'cd2f494d-83b2-0005-7009-2d86f0e05d52', 'a7173bd9-7c14-0006-4e7c-08f8efab1643', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9f482fdb-55ff-0007-14d2-5817ada6357a', 'cd2f494d-83b2-0005-7009-2d86f0e05d52', 'be3bd06d-a787-0006-b39c-2ae228eea7e7', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ae4a7c3f-6495-0007-8379-454c75b244cc', 'cd2f494d-83b2-0005-7009-2d86f0e05d52', 'a5d9baf3-6a3a-0006-e6fd-4794e43fbbe1', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('75b6f8a3-bd65-0007-3de5-66b20a337031', 'cd2f494d-83b2-0005-7009-2d86f0e05d52', '45eb279e-b74f-0006-f259-aea2be6a1d51', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a3977465-d616-0007-0941-b14392d13e78', 'cd2f494d-83b2-0005-7009-2d86f0e05d52', '4edd8614-2f67-0006-3a05-0892d106456d', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c1880db9-26ce-0007-7e5e-8d6ecec0b78b', 'cd2f494d-83b2-0005-7009-2d86f0e05d52', 'e599b337-fac7-0006-f3c5-90909853eaff', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('82121d24-0179-0007-2cfb-9b0733ba6272', 'cd2f494d-83b2-0005-7009-2d86f0e05d52', 'fbfbf8d3-8ee0-0006-fe9c-29d05b143241', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('264edf61-0114-0007-1354-04ce4a0bd0ba', 'cd2f494d-83b2-0005-7009-2d86f0e05d52', 'd7ffb471-2676-0006-f95d-26a39cc04bbb', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('bdcd6f1d-e863-0007-8901-5118ab30f132', 'cd2f494d-83b2-0005-7009-2d86f0e05d52', 'a9de40d1-c601-0006-0711-84658df6ac16', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;


-- ========================================
-- Sete Setembro USA ROSTER
-- ========================================
INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('dc93c805-016b-0007-d008-9896c4fe217e', 'a9f395bc-b644-0005-057d-97f0afc4ca9c', 'b805f9cd-d99f-0006-2b30-0e5e9efc5d9e', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('20cece39-63a0-0007-e438-b3e20b608901', 'a9f395bc-b644-0005-057d-97f0afc4ca9c', 'ad0a7afa-cbbf-0006-beea-1cdb62b3bc04', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('6df8dbd1-6134-0007-421a-e800b86586cf', 'a9f395bc-b644-0005-057d-97f0afc4ca9c', '2ba78fb6-7730-0006-4172-22a034b34088', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c4f2caf0-83ec-0007-7cd1-217f1d39e0d8', 'a9f395bc-b644-0005-057d-97f0afc4ca9c', 'fbd55b3f-5e27-0006-883d-e046fe290291', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c49cb985-feea-0007-5222-0559be28111f', 'a9f395bc-b644-0005-057d-97f0afc4ca9c', '96c53b27-5d7e-0006-65b6-b0f3fbaca193', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('aaae1fd8-3000-0007-44b6-3c485e882fe5', 'a9f395bc-b644-0005-057d-97f0afc4ca9c', 'aa22f51e-5de6-0006-98e2-f9079d1613ea', 3, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d4ec91c1-d68e-0007-fba2-af5e254dd37a', 'a9f395bc-b644-0005-057d-97f0afc4ca9c', 'f0655170-d9e9-0006-978b-483b31983cdd', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9cd2f092-6b1c-0007-84ea-107dd0c8afb6', 'a9f395bc-b644-0005-057d-97f0afc4ca9c', '67740030-97a4-0006-280f-cc1f13b1e255', 3, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('67b73f53-7240-0007-443a-29a9c86efea4', 'a9f395bc-b644-0005-057d-97f0afc4ca9c', '4fe2b6e1-8d05-0006-226a-a28657994c74', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('6c205b1a-a337-0007-3e1a-b707e161a3ca', 'a9f395bc-b644-0005-057d-97f0afc4ca9c', '2e2cb1a2-fe0a-0006-2649-bcdeb4436bc5', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c926f2ac-1b3f-0007-e4d2-127e18eb93e6', 'a9f395bc-b644-0005-057d-97f0afc4ca9c', '88b47d44-a149-0006-9444-2cc4d4fb2961', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f06b1852-2f0f-0007-6503-c9113e0b9c1a', 'a9f395bc-b644-0005-057d-97f0afc4ca9c', '1418c449-fd62-0006-a285-55b329394a2a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c6300db8-617c-0007-a625-8a970f9a91de', 'a9f395bc-b644-0005-057d-97f0afc4ca9c', 'faa11526-7892-0006-dc3d-fd57456a213a', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('05ba77e9-1fc6-0007-1b52-d3d4e75bd3be', 'a9f395bc-b644-0005-057d-97f0afc4ca9c', 'cd99faae-a3d3-0006-4af4-e571024a2595', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0f546c1b-5e18-0007-f28e-d961c286b87a', 'a9f395bc-b644-0005-057d-97f0afc4ca9c', '1fcc7b93-56ab-0006-be90-7186bbe5b70e', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c9c77094-7bba-0007-a273-aed69c67af9f', 'a9f395bc-b644-0005-057d-97f0afc4ca9c', '4c17c769-2841-0006-1f40-9924e0f0d5a3', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7c5892f6-c9f2-0007-bf3c-efc4d5ed2006', 'a9f395bc-b644-0005-057d-97f0afc4ca9c', '8b2b26ad-a878-0006-b329-4a6e0f9d8134', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d2c99071-205a-0007-59a8-68938e4b0255', 'a9f395bc-b644-0005-057d-97f0afc4ca9c', '7fb6aeee-b8cc-0006-30ca-9c09bacd6752', 3, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0caa40cf-6801-0007-d0a9-901932e6f3c9', 'a9f395bc-b644-0005-057d-97f0afc4ca9c', '15c20db8-1cfb-0006-572f-598bbe571d36', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d1d138e0-32ff-0007-31ed-8d01bf1f0b29', 'a9f395bc-b644-0005-057d-97f0afc4ca9c', '02e633e0-a6f0-0006-2d5f-e6142c7d5ab0', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4bba618f-c8b8-0007-2c7c-3671d7e9961e', 'a9f395bc-b644-0005-057d-97f0afc4ca9c', '4d77edc1-3134-0006-e066-c85ad5063669', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3f766e09-6f8e-0007-cf9c-61b2a6a80acb', 'a9f395bc-b644-0005-057d-97f0afc4ca9c', '5f0673f4-88a9-0006-efbe-97103612c96f', 4, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1e8df185-6c24-0007-e4c0-448a1e6e2d9c', 'a9f395bc-b644-0005-057d-97f0afc4ca9c', '91c9e28d-a721-0006-c1d6-20afcb47bffd', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ec0ccfaf-1075-0007-bbed-115c6d651a60', 'a9f395bc-b644-0005-057d-97f0afc4ca9c', '994b69a3-0902-0006-bd7d-303d49fed728', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a4874416-220a-0007-0648-065467005b0b', 'a9f395bc-b644-0005-057d-97f0afc4ca9c', 'd2e64ce3-0004-0006-500e-c570d51f7d55', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c9823146-98cd-0007-c09a-3c4c5058ebc8', 'a9f395bc-b644-0005-057d-97f0afc4ca9c', 'f836061e-6ad9-0006-b2c3-fa14a5e0b392', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c71770bb-ec9b-0007-c74f-183f6a95290e', 'a9f395bc-b644-0005-057d-97f0afc4ca9c', '60638c8d-c0ec-0006-cfef-41dc7bb448f3', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('66e4e7d7-0a63-0007-c358-f719b843848a', 'a9f395bc-b644-0005-057d-97f0afc4ca9c', 'e2e1a231-9e79-0006-c658-4d7ed24665a0', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d62e0031-b61e-0007-643e-27013048f139', 'a9f395bc-b644-0005-057d-97f0afc4ca9c', '6e02be28-fe46-0006-f2d2-378d8760f22e', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('66f3e1cc-1581-0007-cd1d-cefde72fdd34', 'a9f395bc-b644-0005-057d-97f0afc4ca9c', '442c991c-6a42-0006-02fb-cec5e84d2754', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('28c0c93a-fcae-0007-fc02-1c53816357ee', 'a9f395bc-b644-0005-057d-97f0afc4ca9c', 'db11cca5-236b-0006-ffa5-74c46334b09c', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('96b415fa-7dfd-0007-3a28-08353a147bc2', 'a9f395bc-b644-0005-057d-97f0afc4ca9c', 'cab797c0-61ba-0006-993d-f655a32eceee', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0272640a-5456-0007-a215-103e6ef62bdb', 'a9f395bc-b644-0005-057d-97f0afc4ca9c', '5e53ea04-acc2-0006-8a4d-7b054044dd2b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('41eadf51-04a1-0007-05d9-bfa165ffb401', 'a9f395bc-b644-0005-057d-97f0afc4ca9c', '6f17adcc-822c-0006-9e1f-5281b9caff2b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7d38194a-6029-0007-4c55-54247e503c4c', 'a9f395bc-b644-0005-057d-97f0afc4ca9c', '3ead43ee-e5ff-0006-76d1-0395147c4c2f', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;


-- ========================================
-- South Coast Union ROSTER
-- ========================================
INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2d352dd3-8530-0007-35aa-0500814c0d2a', '3b1d4171-c61d-0005-82fe-0b134f83622d', '10ecbb9b-0bd0-0006-bdd8-445c5d1717bc', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('72c1cf25-1703-0007-4a81-3922de65374c', '3b1d4171-c61d-0005-82fe-0b134f83622d', '34f1600f-adf8-0006-dfda-15462bac8226', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('eb596ae4-3146-0007-85aa-2b4712372427', '3b1d4171-c61d-0005-82fe-0b134f83622d', 'c23c93e0-9cad-0006-afc1-6235a4ad738e', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('08405664-b002-0007-d0aa-b9dabb677f15', '3b1d4171-c61d-0005-82fe-0b134f83622d', 'ff674b3a-faef-0006-fbe4-4a3b144c9ecc', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('5e8d9635-152a-0007-eb53-189208e1b4f5', '3b1d4171-c61d-0005-82fe-0b134f83622d', '5c805dc1-2758-0006-ac5c-462d53a94e2e', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('02bc4a44-421f-0007-d006-84e1c803be1d', '3b1d4171-c61d-0005-82fe-0b134f83622d', '3a3719c7-2f13-0006-15c1-c40303655920', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1bd4b82b-1c81-0007-e6f8-13884d843d90', '3b1d4171-c61d-0005-82fe-0b134f83622d', '8a6fcc5e-1bc5-0006-3068-79046e5cae88', 3, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('254fd7e6-0992-0007-a3ad-cdb1ffe12544', '3b1d4171-c61d-0005-82fe-0b134f83622d', '651b275c-f3cc-0006-4bb5-990300b973fd', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('284402e3-02e2-0007-67a8-e89fc82db34d', '3b1d4171-c61d-0005-82fe-0b134f83622d', '4c6ea97a-d6df-0006-8a7b-a93004d8d5ae', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a934bb6c-836a-0007-a733-a9443d21d1d4', '3b1d4171-c61d-0005-82fe-0b134f83622d', 'b1748e0b-510e-0006-6e09-5b8d25bdf091', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a4979ce7-ac65-0007-c86c-f920741bce04', '3b1d4171-c61d-0005-82fe-0b134f83622d', '81a73122-bcf3-0006-f11a-f206cd1745a6', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('cdab8f96-58c8-0007-da64-bc593ff765bd', '3b1d4171-c61d-0005-82fe-0b134f83622d', 'f1ed8d5a-33c2-0006-115c-9eb7f9d9b888', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('abe9ab7f-564f-0007-dd0a-9d5b699b4749', '3b1d4171-c61d-0005-82fe-0b134f83622d', 'd0d24d06-6d6b-0006-18c7-9575e2e2e069', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0fbec81a-ada1-0007-e277-5663868a4727', '3b1d4171-c61d-0005-82fe-0b134f83622d', '94fb4cb6-a95d-0006-f754-e6466e24dee3', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('81b02e46-9891-0007-2d09-88a5f791f3a1', '3b1d4171-c61d-0005-82fe-0b134f83622d', '552ce04a-b591-0006-88f7-de0f94e2b1a9', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c9d44de6-bda5-0007-c71a-e2c655dfed98', '3b1d4171-c61d-0005-82fe-0b134f83622d', '28a8bb17-4d16-0006-0028-da0580db557d', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ad1b48da-87cd-0007-67f3-039ee254758e', '3b1d4171-c61d-0005-82fe-0b134f83622d', '6c83864c-6e38-0006-28da-f08583c72161', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e8ff5809-9557-0007-6231-c20119ac81e6', '3b1d4171-c61d-0005-82fe-0b134f83622d', 'e243f53c-85e7-0006-766e-5ccb69f3784f', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1487f4f4-0e09-0007-e608-7601a7a5fdac', '3b1d4171-c61d-0005-82fe-0b134f83622d', 'cf933db5-a8bf-0006-3336-30343a66d5d1', 4, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3a81d6da-829d-0007-c6a3-da045bee661a', '3b1d4171-c61d-0005-82fe-0b134f83622d', '079f7d10-c366-0006-fa39-78982b0f039a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e6ac5f33-611b-0007-eeb8-7b1ac7e1dc93', '3b1d4171-c61d-0005-82fe-0b134f83622d', '3c41b15d-252e-0006-5f38-cf97c6e10144', 9, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('81411795-b5ee-0007-0528-ca2911f28708', '3b1d4171-c61d-0005-82fe-0b134f83622d', '1a1027b0-f8b9-0006-3db6-7a4f3dba6a79', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3983f8b4-e9dc-0007-2570-c642817fbdbd', '3b1d4171-c61d-0005-82fe-0b134f83622d', '395e2bcd-42dc-0006-7916-9b2466201f24', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a6be9baf-aa21-0007-285c-feceaef40ecf', '3b1d4171-c61d-0005-82fe-0b134f83622d', 'fc9fbe96-6ecd-0006-be37-ca4dda669e73', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a388155e-3fd5-0007-99f2-a77caafdb6f5', '3b1d4171-c61d-0005-82fe-0b134f83622d', '5faa0ce1-4a64-0006-5522-0902ddefe4bd', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('6b9b1332-21e8-0007-f5af-7864c2d9bef3', '3b1d4171-c61d-0005-82fe-0b134f83622d', '278a5f89-bea1-0006-e887-428d019e47ea', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('6ce65108-7f8c-0007-5471-6e682c71b0f3', '3b1d4171-c61d-0005-82fe-0b134f83622d', '52a44609-34de-0006-094d-33f59224d07f', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c28739df-cb9b-0007-91ad-aa0fb8e76c5d', '3b1d4171-c61d-0005-82fe-0b134f83622d', '321bd71d-8542-0006-7c9d-2fe8ae1e0eaa', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9e46f894-8877-0007-a2dc-77dd320ff953', '3b1d4171-c61d-0005-82fe-0b134f83622d', '6a37adef-bedf-0006-ddd0-9a36ebec529e', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e849deb9-1221-0007-692b-76ee9d7593cf', '3b1d4171-c61d-0005-82fe-0b134f83622d', '5c419fc1-ab1a-0006-f3b5-f351e84df834', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('edbfe38e-ccee-0007-d555-9989caa33c06', '3b1d4171-c61d-0005-82fe-0b134f83622d', 'd8e97420-1285-0006-5513-404fa75107dd', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('dfb96904-237d-0007-e046-36fa1d038449', '3b1d4171-c61d-0005-82fe-0b134f83622d', 'ba018c0d-f768-0006-d9cf-2193f8f2f02e', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1f5a6eaa-9aa4-0007-26cb-59bea6c6680b', '3b1d4171-c61d-0005-82fe-0b134f83622d', '1f74c66f-9602-0006-68a0-662831cf0bdb', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;


-- ========================================
-- Project Football ROSTER
-- ========================================
INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ccc56f7c-5055-0007-6618-483b61af5a50', 'd6dd2763-bfe0-0005-76b6-634bdffc6f2a', 'c204662d-9f60-0006-caee-ac59cfb099d0', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4dd53456-6091-0007-6ce1-7f8ea9718bf5', 'd6dd2763-bfe0-0005-76b6-634bdffc6f2a', '239eb9d0-3eee-0006-bb8a-f09144263e3c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('56324086-0975-0007-8cef-e1f06ab23207', 'd6dd2763-bfe0-0005-76b6-634bdffc6f2a', '9ed8d835-8faa-0006-e5f7-12baeea8b890', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('8df5e287-d19f-0007-ff3a-400fbcb21ba1', 'd6dd2763-bfe0-0005-76b6-634bdffc6f2a', 'c4180da0-d916-0006-1eee-ce86df4d0bc3', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f27f0159-1e5d-0007-88a8-1ddc6b4b15bb', 'd6dd2763-bfe0-0005-76b6-634bdffc6f2a', '3f4e76f5-fef0-0006-891d-f85b037d8c25', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7fff8bb1-4c5d-0007-822b-b81d063ed600', 'd6dd2763-bfe0-0005-76b6-634bdffc6f2a', '8bfdfed4-85cf-0006-70e1-52988ce09171', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1620ee5b-7e09-0007-37c8-a6791c9cca42', 'd6dd2763-bfe0-0005-76b6-634bdffc6f2a', '7c94eb3f-e6f9-0006-6112-e9a564fc6ddc', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7c1efee6-c2ba-0007-a2ea-7ff2bb9052ac', 'd6dd2763-bfe0-0005-76b6-634bdffc6f2a', '621baa97-98c1-0006-1aee-818e144a3d36', 4, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3b8bb2dd-fca7-0007-8cb5-e69c208f3fa6', 'd6dd2763-bfe0-0005-76b6-634bdffc6f2a', 'c0e3e73b-88bd-0006-5171-ddfa2c9c0612', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('bce556ae-8492-0007-c75b-42448d5123a9', 'd6dd2763-bfe0-0005-76b6-634bdffc6f2a', 'edfd7120-4ab2-0006-c84f-02c2e467dc81', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('647b2c9f-e9a2-0007-60ca-874fd19e5a29', 'd6dd2763-bfe0-0005-76b6-634bdffc6f2a', 'ac7c1c91-5031-0006-0fe4-cf975651136d', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1a8b4eb1-23f0-0007-146c-1d50ad6ae249', 'd6dd2763-bfe0-0005-76b6-634bdffc6f2a', '6839aa1b-1afc-0006-caad-5479792ec33e', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f41dd83d-8f21-0007-ffd8-21990b938fa1', 'd6dd2763-bfe0-0005-76b6-634bdffc6f2a', '770a8af1-322c-0006-c3d2-08727477b38e', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('547fa864-d726-0007-3f7e-00b7342a191a', 'd6dd2763-bfe0-0005-76b6-634bdffc6f2a', 'b29f8397-0d3a-0006-f3b9-24d8cbb8331d', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('271c27ad-869a-0007-6008-be4e4a2360af', 'd6dd2763-bfe0-0005-76b6-634bdffc6f2a', '74591340-f72d-0006-70b2-bda972ba6a77', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e7dc8bf1-2b6a-0007-ad1c-20b6aeb0c54c', 'd6dd2763-bfe0-0005-76b6-634bdffc6f2a', 'b8f6b84b-3d4e-0006-6297-d154a8f0bac0', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('dd7cb062-f4fe-0007-330f-591576aebd38', 'd6dd2763-bfe0-0005-76b6-634bdffc6f2a', 'f9975947-d492-0006-14ac-de306351d4f7', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('104b95fb-87c7-0007-399c-784fcfb257e3', 'd6dd2763-bfe0-0005-76b6-634bdffc6f2a', '2ee6e097-2dcb-0006-bb47-e316edb83617', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('016abb5d-5b9f-0007-c14a-b668ffe24e81', 'd6dd2763-bfe0-0005-76b6-634bdffc6f2a', '62c849af-fe31-0006-5776-f9c667a10f28', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2c8eeea5-8bc0-0007-0c1c-3ce02e950ba7', 'd6dd2763-bfe0-0005-76b6-634bdffc6f2a', 'de4f5a6f-574d-0006-531a-cccec1e6ca19', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('814d5d78-a870-0007-3bfb-2efa53d34a57', 'd6dd2763-bfe0-0005-76b6-634bdffc6f2a', 'a3dc3f02-8ce8-0006-07f5-c448faef633b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('df782be2-f7d3-0007-3676-ca7b66aff768', 'd6dd2763-bfe0-0005-76b6-634bdffc6f2a', 'e74366d4-73c8-0006-ddb1-39d1296909eb', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('cc8b9a1e-2a2e-0007-dea9-660cba8281ec', 'd6dd2763-bfe0-0005-76b6-634bdffc6f2a', '7ef66a1a-d185-0006-aee8-c5579114f24e', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('84f668a0-3fa6-0007-fe29-86f9a11b25ca', 'd6dd2763-bfe0-0005-76b6-634bdffc6f2a', '06243baf-d088-0006-eafa-67c39d788523', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7f0b409d-b935-0007-209d-20e6d3659b97', 'd6dd2763-bfe0-0005-76b6-634bdffc6f2a', 'ffa8e7ba-cf9d-0006-7871-c460998a4685', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;


-- ========================================
-- Invictus FC ROSTER
-- ========================================
INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('572a65a9-34fb-0007-bf33-6500996a03e1', 'aa0aab49-a007-0005-2697-8c6ceac5beb7', 'a66b07d6-2ab5-0006-57aa-082db8b74bdf', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4c4904ab-f5e7-0007-0339-4ce81c49234a', 'aa0aab49-a007-0005-2697-8c6ceac5beb7', '9a7d998e-1d25-0006-f724-d933629c8207', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7b39e51a-39c6-0007-4b82-9238e07243e2', 'aa0aab49-a007-0005-2697-8c6ceac5beb7', '9a83db4e-1dd0-0006-32fa-54dc21a6f60f', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1638f9c3-2d36-0007-fc5b-e708de94ab9f', 'aa0aab49-a007-0005-2697-8c6ceac5beb7', '57a816c2-bdf9-0006-e504-2ed18888c2d3', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1c0db400-0492-0007-ebd1-c977ab34b8af', 'aa0aab49-a007-0005-2697-8c6ceac5beb7', 'a3b2ed71-39cd-0006-5ecc-0aeaba491fcb', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('dc66fb81-80b2-0007-bacb-1481003c95c2', 'aa0aab49-a007-0005-2697-8c6ceac5beb7', '06a72c5f-1933-0006-15c4-5ff419ac14a0', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('256c8482-921e-0007-9231-ee0d7613690c', 'aa0aab49-a007-0005-2697-8c6ceac5beb7', 'daad7aae-617f-0006-1ead-adc8335cf265', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a483ca6a-8583-0007-842a-b751a6a637fd', 'aa0aab49-a007-0005-2697-8c6ceac5beb7', '79168662-5a95-0006-79a6-50ce7e49bc60', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c345eb3c-8b95-0007-206d-71e4e6ed8375', 'aa0aab49-a007-0005-2697-8c6ceac5beb7', '4e3dbb85-2833-0006-2e3c-7d8afa40a7cb', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('5dc4166f-a744-0007-38ef-8c84ac2ac1f5', 'aa0aab49-a007-0005-2697-8c6ceac5beb7', '0d6c31d5-4891-0006-4d5d-32081b61a344', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3e2f05cb-1077-0007-9748-0bc0a049faaa', 'aa0aab49-a007-0005-2697-8c6ceac5beb7', '9d9fa60a-db7d-0006-8d73-bfff050ae4f4', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e13e8975-8ee2-0007-fc72-76c25f388017', 'aa0aab49-a007-0005-2697-8c6ceac5beb7', '80a6f9b6-f7fe-0006-0fa0-84a1e86ec589', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('17ef26bd-5e8a-0007-30cf-86761dc68077', 'aa0aab49-a007-0005-2697-8c6ceac5beb7', '1b1f5065-833d-0006-4c44-eb08b66ac909', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e582cd04-c4e9-0007-cddb-8fc2cf88724c', 'aa0aab49-a007-0005-2697-8c6ceac5beb7', '77ea7aac-0609-0006-d415-563921a3ea66', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4a11f714-75f2-0007-3a10-dcfbfcea5e18', 'aa0aab49-a007-0005-2697-8c6ceac5beb7', '017d8a53-30c9-0006-d1f4-aaafbdf7fa54', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4a95da11-862e-0007-59f7-f7441215d463', 'aa0aab49-a007-0005-2697-8c6ceac5beb7', '910e8d67-6fb5-0006-510b-aa9a4047dece', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('53ad8bfe-9e3a-0007-a8a4-90b83f0bd722', 'aa0aab49-a007-0005-2697-8c6ceac5beb7', 'e41dc2df-b495-0006-a24b-019d76ec0bd3', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c4b12920-4f58-0007-54b0-db3f55f54840', 'aa0aab49-a007-0005-2697-8c6ceac5beb7', '4e8b195f-f1de-0006-5d6b-d7e3d196a59f', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('11b6bb23-0d0c-0007-9736-1787f5ef85bf', 'aa0aab49-a007-0005-2697-8c6ceac5beb7', 'c8b24d17-62ab-0006-9dfe-363294648bdc', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('94716bfe-e5a3-0007-2c9a-cd90f8728754', 'aa0aab49-a007-0005-2697-8c6ceac5beb7', '6af5cba8-ed0f-0006-4be5-e819d4693911', 4, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4f04d9e6-1ac1-0007-5e44-ac12f1412e1d', 'aa0aab49-a007-0005-2697-8c6ceac5beb7', '5f93ebc7-c756-0006-fa25-659b100c2dc3', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d1b4a8ea-fcd3-0007-f17c-938b43db91b8', 'aa0aab49-a007-0005-2697-8c6ceac5beb7', '99f05cfe-412a-0006-225a-1fe7e703fe9b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('5769afbf-38f5-0007-f096-d290b58ea0cc', 'aa0aab49-a007-0005-2697-8c6ceac5beb7', '038eb4f3-7a89-0006-b4e2-f7dd2e34f47b', 3, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('58d02adf-8a78-0007-9935-6ca598dfb9fe', 'aa0aab49-a007-0005-2697-8c6ceac5beb7', '275f1c7b-9a07-0006-db05-4756c954d60c', 3, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f75506b8-5b39-0007-74d1-00fe856ab060', 'aa0aab49-a007-0005-2697-8c6ceac5beb7', '67f4b8e1-78ab-0006-df89-1ac992184b1c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('98f6f35e-b1e2-0007-3264-174f78332b21', 'aa0aab49-a007-0005-2697-8c6ceac5beb7', 'e30f59ac-9cd7-0006-ec64-2480e687cb4d', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2ad7650e-40e5-0007-9083-b4931caa3a8c', 'aa0aab49-a007-0005-2697-8c6ceac5beb7', '329491a1-e4e0-0006-da14-f249b90d3a07', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('af02025e-1287-0007-9aad-b866979cc8f1', 'aa0aab49-a007-0005-2697-8c6ceac5beb7', '71bf6e6e-b8e3-0006-de46-e20418c83583', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c58e3299-222c-0007-b6ea-f4cc1bd51768', 'aa0aab49-a007-0005-2697-8c6ceac5beb7', '7b4104c2-0fe7-0006-654d-b4c4b6804182', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;


-- ========================================
-- Fitchburg FC ROSTER
-- ========================================
INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('efdb23c2-62f7-0007-d848-025d13eae937', 'b8ec25f4-b6b4-0005-ce33-0da183347d70', 'a671dba9-3e70-0006-26f2-1c4186d54162', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('fba0ab65-50c8-0007-7fd7-c5de86384568', 'b8ec25f4-b6b4-0005-ce33-0da183347d70', 'bca35d65-8a83-0006-1320-431e9de0c0ce', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e5db5bab-162c-0007-f176-392427e90dbe', 'b8ec25f4-b6b4-0005-ce33-0da183347d70', 'dbb7229c-8270-0006-fcb8-0e745dabcd98', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7939b910-0bac-0007-5e7c-4ccd8d849719', 'b8ec25f4-b6b4-0005-ce33-0da183347d70', '758835ce-e148-0006-2ee1-3613ccf3f3d4', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('61a342e6-9526-0007-1daf-531812358c8f', 'b8ec25f4-b6b4-0005-ce33-0da183347d70', 'af00fbbf-c4ce-0006-708f-7358ac54bcd9', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2dab2761-c193-0007-ea86-18c9f55a6227', 'b8ec25f4-b6b4-0005-ce33-0da183347d70', '2e57d3f4-039d-0006-1959-f0aee20918a6', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2b04906c-98ba-0007-fda1-cf79930f95b0', 'b8ec25f4-b6b4-0005-ce33-0da183347d70', 'a715418f-b746-0006-0cd5-5f6f698465b0', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('22d11acd-bb1c-0007-b495-7085c97c0b43', 'b8ec25f4-b6b4-0005-ce33-0da183347d70', '9fa25e9e-eef5-0006-0394-3175de0b12aa', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d2b343e1-844b-0007-9187-a0582b36dc07', 'b8ec25f4-b6b4-0005-ce33-0da183347d70', '7a2016e4-8671-0006-d680-e641a1806a0a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('68606314-7975-0007-fd91-0e1fa8fd9a59', 'b8ec25f4-b6b4-0005-ce33-0da183347d70', '392c3cec-b2c2-0006-d412-7b3d6996a439', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d549510e-2b94-0007-fc6b-2b9a37d70bea', 'b8ec25f4-b6b4-0005-ce33-0da183347d70', '3cb5654d-6c95-0006-c730-e6f73d96e27b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('48456966-26e0-0007-0460-3a49d9d5b680', 'b8ec25f4-b6b4-0005-ce33-0da183347d70', 'fcdff43d-e43b-0006-b34c-a237391d430c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('653a6e4d-2f06-0007-03a3-b7219827f05d', 'b8ec25f4-b6b4-0005-ce33-0da183347d70', '25d98e29-5e85-0006-ab24-65bc2b00484b', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c67fbbea-3edc-0007-50fc-336abf04b924', 'b8ec25f4-b6b4-0005-ce33-0da183347d70', 'b7cc2568-7503-0006-d130-a64c1e902d68', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4e6d5990-5d10-0007-ba1a-c3952920f126', 'b8ec25f4-b6b4-0005-ce33-0da183347d70', '05d8fe76-30b3-0006-8751-3362b6a4febd', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('924ce090-8c26-0007-b191-8ac1bccf9099', 'b8ec25f4-b6b4-0005-ce33-0da183347d70', '9383a7dc-1c28-0006-ce1b-27b7cbaa0a38', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('51488cfa-1e93-0007-c25b-b6118d2b9085', 'b8ec25f4-b6b4-0005-ce33-0da183347d70', '77718982-2e27-0006-2419-c0d6331edb8d', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('fc941cac-82cd-0007-9ac5-80e389e2dd21', 'b8ec25f4-b6b4-0005-ce33-0da183347d70', 'a6473cf1-c0db-0006-4eb3-5ea8059d1c1f', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d044f7f0-c80d-0007-3057-3ee67ac0df82', 'b8ec25f4-b6b4-0005-ce33-0da183347d70', '95f52929-41c9-0006-bddb-59a5c18f383c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0bba2be2-c34c-0007-f279-9b4b16246475', 'b8ec25f4-b6b4-0005-ce33-0da183347d70', 'a5468844-44db-0006-84cc-32c6775c6ad3', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b0528d68-00d0-0007-242b-aba6329a25b9', 'b8ec25f4-b6b4-0005-ce33-0da183347d70', '18f25be9-0c86-0006-d5a9-b92e31bef6af', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b8cdef71-90fa-0007-eccc-ad8392a1a693', 'b8ec25f4-b6b4-0005-ce33-0da183347d70', 'ec447434-4c7c-0006-789e-800b261905c0', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9c0c049c-79fd-0007-0372-0ee202201c4a', 'b8ec25f4-b6b4-0005-ce33-0da183347d70', '74b629c4-a0aa-0006-4629-5802b129b2ec', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b985a440-b580-0007-c89a-249969d75688', 'b8ec25f4-b6b4-0005-ce33-0da183347d70', 'c2e6c31c-0072-0006-fbee-9c750f89afb2', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2d54ceb7-01eb-0007-6691-387ca92ed1c8', 'b8ec25f4-b6b4-0005-ce33-0da183347d70', 'c1c38b99-1c40-0006-89b6-85708049f865', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0bc1eef1-ef87-0007-90c5-d36644820129', 'b8ec25f4-b6b4-0005-ce33-0da183347d70', 'b3a9c857-deda-0006-786e-d3de80fa274d', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('84de138b-c1ef-0007-bffd-8167b3d4a0b9', 'b8ec25f4-b6b4-0005-ce33-0da183347d70', '5c473b7c-6b1e-0006-bb55-4180e2e04496', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('698bc212-15de-0007-c850-40444cdc5ea3', 'b8ec25f4-b6b4-0005-ce33-0da183347d70', 'b306474b-1ffe-0006-a735-b981a3cd1445', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d795f6b6-4a54-0007-a379-9b58e58e227b', 'b8ec25f4-b6b4-0005-ce33-0da183347d70', '6592a105-8a22-0006-bcad-923a9459c8ab', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1a8c566f-8c0a-0007-e3ad-561d656b85a0', 'b8ec25f4-b6b4-0005-ce33-0da183347d70', '1858b63d-d30f-0006-3a86-388cddd478ad', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('66ae19f0-ddb7-0007-2eb9-6cee27c0132e', 'b8ec25f4-b6b4-0005-ce33-0da183347d70', '194d4334-ce0c-0006-83eb-9ab934e83366', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('919ff0e9-c8ec-0007-5e6a-168e0d802220', 'b8ec25f4-b6b4-0005-ce33-0da183347d70', '83623023-d72b-0006-ff08-074e6c44c04d', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7f393cb8-6a97-0007-4c23-ffa895781daf', 'b8ec25f4-b6b4-0005-ce33-0da183347d70', 'c1f9df67-2c98-0006-e46a-c9329a8e6e45', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('24013d48-d4bb-0007-5810-e02e1c032327', 'b8ec25f4-b6b4-0005-ce33-0da183347d70', '9e1e92a5-11bc-0006-816b-4bdada1e7203', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('18b3fe63-5404-0007-9248-82bd011fd8ff', 'b8ec25f4-b6b4-0005-ce33-0da183347d70', '7281b6d1-afe4-0006-123a-6f5c795fc86f', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;


-- ========================================
-- KO Elites ROSTER
-- ========================================
INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0843da6d-827e-0007-01f2-827aefd32508', 'a57bd844-e059-0005-1ea8-768f2a07223e', '5f48257b-a7b5-0006-04ac-22c18c9e56b0', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('8f8b89e3-3675-0007-c350-b7743dc5ad7d', 'a57bd844-e059-0005-1ea8-768f2a07223e', '237d597c-50c6-0006-a342-8393585a6715', 5, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3d7f1656-d7d6-0007-9542-239b4dd7138b', 'a57bd844-e059-0005-1ea8-768f2a07223e', '45fca129-8a8b-0006-5098-ea71919a3695', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('84ad55e1-25de-0007-616e-06eddf90e47c', 'a57bd844-e059-0005-1ea8-768f2a07223e', 'fdf168a7-0286-0006-b80e-36e847aeb353', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('acd337fe-6c42-0007-f5c0-be73c97ed22a', 'a57bd844-e059-0005-1ea8-768f2a07223e', '86ba5169-0de5-0006-292f-4fd73d64ee17', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ac93482f-bb36-0007-2408-4cbf09e2006a', 'a57bd844-e059-0005-1ea8-768f2a07223e', '79210fc4-505f-0006-8d9c-be8f8d1a94ae', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f244f238-b5ba-0007-5dcf-c8c02b9a5270', 'a57bd844-e059-0005-1ea8-768f2a07223e', '6534d258-3549-0006-c0fe-6a2357fb307e', 3, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('918e246b-fd3f-0007-10fb-7dc076b17223', 'a57bd844-e059-0005-1ea8-768f2a07223e', '14d57c63-86cf-0006-8d3f-aa11be0c7880', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('867108ea-942a-0007-4211-616df9ea28d3', 'a57bd844-e059-0005-1ea8-768f2a07223e', 'f580334c-e0f6-0006-10bb-7fda0692c7bb', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('824986b6-f652-0007-144d-8ad214095cf6', 'a57bd844-e059-0005-1ea8-768f2a07223e', '642ae3c8-5827-0006-bbc3-6bfd378b6724', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f1dbfae6-a853-0007-3386-a0156f85d1f0', 'a57bd844-e059-0005-1ea8-768f2a07223e', 'cb31b213-3307-0006-fa04-c693827fb673', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e97d81f3-11c2-0007-612d-0ca7e30f7f18', 'a57bd844-e059-0005-1ea8-768f2a07223e', '3efb2a30-fb95-0006-a230-6f961d28b22a', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ff21095f-57f6-0007-0bdd-2331161718f6', 'a57bd844-e059-0005-1ea8-768f2a07223e', 'eda54837-0d78-0006-c453-6a01929cede9', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a5125858-954d-0007-b469-6f2a6f2f7ca1', 'a57bd844-e059-0005-1ea8-768f2a07223e', '8b077d33-9688-0006-fb1b-db44abff91ea', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('aeca4cbc-862b-0007-4914-a9299f308408', 'a57bd844-e059-0005-1ea8-768f2a07223e', 'ab4496ad-bb66-0006-b0d6-de990feece38', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('925e214a-e188-0007-1600-b0d5e7f9104b', 'a57bd844-e059-0005-1ea8-768f2a07223e', 'd7e9cb9e-9080-0006-1cf6-e8df22fcf626', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0f9c6da8-f247-0007-0a48-fac5a6b18f7f', 'a57bd844-e059-0005-1ea8-768f2a07223e', '28a701f3-5454-0006-022e-df02a0ab4469', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('24c6cfde-e5ed-0007-641e-2e95b5a0b8a0', 'a57bd844-e059-0005-1ea8-768f2a07223e', '9b971125-784e-0006-df3a-33271e15435b', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e6c65713-34b8-0007-48d4-a7d682356a52', 'a57bd844-e059-0005-1ea8-768f2a07223e', '455f1f4e-9c57-0006-1de6-a4857a83995b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1a2daec7-627e-0007-9372-95eb24269a43', 'a57bd844-e059-0005-1ea8-768f2a07223e', 'd76a8c4a-8ee3-0006-01f6-4af2f451eae7', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4ed83a54-1e97-0007-35d2-f0ddd784a34a', 'a57bd844-e059-0005-1ea8-768f2a07223e', '1fcb7ab6-f801-0006-b409-63fdaebdb1a1', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('838fb3f8-ad28-0007-8d5b-80522c8ffa82', 'a57bd844-e059-0005-1ea8-768f2a07223e', '46499662-a1fa-0006-a2a1-7fa4bcaec798', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e6363b09-a5ce-0007-5f9e-9bf9bca9a9f9', 'a57bd844-e059-0005-1ea8-768f2a07223e', 'f1fae5ea-f343-0006-2068-b3d3d2ac17a1', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('5f768d77-5d79-0007-1f08-1233ff37d64c', 'a57bd844-e059-0005-1ea8-768f2a07223e', '486e26a6-4caf-0006-adae-65576a75a8f0', 5, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a916c74b-b1f2-0007-7a5e-9cf1179ec2bc', 'a57bd844-e059-0005-1ea8-768f2a07223e', '18e5bb9b-c6a4-0006-30b7-8d677e0d58da', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('8e930675-3f30-0007-e02e-15c679792f56', 'a57bd844-e059-0005-1ea8-768f2a07223e', '83613426-3646-0006-01ac-f6c53a5d87cf', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('570c6fcd-f272-0007-ad42-86b50ff97566', 'a57bd844-e059-0005-1ea8-768f2a07223e', 'ed6b8b8f-0666-0006-bff0-b5d63fa24462', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('581cf34c-0754-0007-3e9d-fc2e81640903', 'a57bd844-e059-0005-1ea8-768f2a07223e', '9a822f11-984a-0006-4b2e-43da6a7ca569', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b115ad1a-5f5c-0007-7fa7-ee3ce68b4808', 'a57bd844-e059-0005-1ea8-768f2a07223e', 'be8de552-01d2-0006-ab9e-3d6a6ea17b21', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('db236e37-3b7c-0007-8bd4-485e6d9c6840', 'a57bd844-e059-0005-1ea8-768f2a07223e', '4d30f313-9519-0006-7cd2-3956e8e1c040', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('aeaf8614-f80c-0007-8ee3-54aab1cb1fc9', 'a57bd844-e059-0005-1ea8-768f2a07223e', 'a00ee1da-be10-0006-cf62-ce8777b8a716', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;


-- ========================================
-- Glastonbury Celtic ROSTER
-- ========================================
INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c6bf9553-1673-0007-f17d-cd13fd2cfe50', '265404b6-e493-0005-2586-5ba8bae74fcc', 'c3339080-371f-0006-b846-195e8a7129f9', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ea04bcd6-4d10-0007-9e2a-bd5a9cd52d2b', '265404b6-e493-0005-2586-5ba8bae74fcc', '2e579f16-b693-0006-b0c9-079d7eee97e7', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f9a37bae-d9f2-0007-411e-c9f90d2dbbfe', '265404b6-e493-0005-2586-5ba8bae74fcc', 'c0c29f9e-d2e7-0006-0341-f1af62179ab5', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('5fdbb616-1446-0007-b121-cf975c40a36b', '265404b6-e493-0005-2586-5ba8bae74fcc', 'fac956dc-b3b0-0006-152c-eea9cd675ad5', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ca0638c7-5a6b-0007-ae2b-2675d0c44340', '265404b6-e493-0005-2586-5ba8bae74fcc', 'fe449959-47ce-0006-699e-7d492b4164d3', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7ef898ba-cc18-0007-45aa-f1b6a8deae2c', '265404b6-e493-0005-2586-5ba8bae74fcc', '41076868-69ac-0006-fe1e-dde20908c978', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0ce51f8a-39e0-0007-adf0-a2c4a952830b', '265404b6-e493-0005-2586-5ba8bae74fcc', 'f7879279-e76a-0006-1b99-6e0dea2b2ac2', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7e192692-8b8b-0007-0dfb-40e2f0dd5397', '265404b6-e493-0005-2586-5ba8bae74fcc', '51ddf26e-40d9-0006-51d4-de0169d12fa4', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d1e79a9a-5692-0007-ffed-47505fd81ba4', '265404b6-e493-0005-2586-5ba8bae74fcc', '3027c9fe-a44c-0006-148f-22936d73fa40', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2b4bdc2e-a8ee-0007-e770-1625fd04cb74', '265404b6-e493-0005-2586-5ba8bae74fcc', '00a0f3cf-c733-0006-fdac-e8845a36e72f', 3, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9b7075ce-7238-0007-0901-8fab7e83b6df', '265404b6-e493-0005-2586-5ba8bae74fcc', '240f84b5-1159-0006-a6c2-01d0ae45db78', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('8f5c842e-1e16-0007-e656-1a45e924fa69', '265404b6-e493-0005-2586-5ba8bae74fcc', '8c90360c-5857-0006-5cb4-23328f2cc254', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0a3448ef-6c7e-0007-2637-d6f9b541d047', '265404b6-e493-0005-2586-5ba8bae74fcc', '91bb200c-876d-0006-8db2-7612a79ceb83', 4, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a89ef8f5-e9d6-0007-3320-89e6dba31ba0', '265404b6-e493-0005-2586-5ba8bae74fcc', '77c86f8e-e67f-0006-2e05-94fce7800388', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7d32c9bd-5e6d-0007-633b-5db20a7c61c6', '265404b6-e493-0005-2586-5ba8bae74fcc', '13d839d0-f3db-0006-a4c9-939bc6a16dca', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7616ad94-fd72-0007-bcaf-b4e329f45a89', '265404b6-e493-0005-2586-5ba8bae74fcc', 'd04bbad1-0262-0006-a99d-8293a5aa5a8e', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e47c5c4e-1d6d-0007-9739-09ac651ae3d7', '265404b6-e493-0005-2586-5ba8bae74fcc', '6df79880-4a58-0006-0fc7-72b6e3d27d26', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3ccdea6f-131e-0007-d376-d06802d9aebc', '265404b6-e493-0005-2586-5ba8bae74fcc', 'f055065a-bae3-0006-d54f-bd44c47a25cd', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ed6cefbb-2ea3-0007-9178-45f3faa9ad08', '265404b6-e493-0005-2586-5ba8bae74fcc', 'f8266ef4-1b48-0006-859d-55839d40c533', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('75d3cd7d-bcfc-0007-725f-6d3a9d2a90a4', '265404b6-e493-0005-2586-5ba8bae74fcc', 'f4452a30-4c56-0006-85d7-c562441ebfbb', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('6841b1bc-eeda-0007-d9f3-fa81c7d619da', '265404b6-e493-0005-2586-5ba8bae74fcc', 'bf74a458-0b20-0006-7f1d-88ca87521688', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('fe0cf3c0-042c-0007-336a-7d9de0f5c0e3', '265404b6-e493-0005-2586-5ba8bae74fcc', 'c906d766-3582-0006-bfc5-d4cb05081be9', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('471d6162-e2d1-0007-2e22-6f43d099fee8', '265404b6-e493-0005-2586-5ba8bae74fcc', 'da3374b3-4ded-0006-1ddc-d1edd12a847d', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('fc16b3e5-fa93-0007-6268-3123fc41149d', '265404b6-e493-0005-2586-5ba8bae74fcc', 'df75ca93-0ab5-0006-6ca2-5ff7da31268b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('6c77a88f-f031-0007-d09b-b3b5d720ed09', '265404b6-e493-0005-2586-5ba8bae74fcc', 'fb537ad1-6d1e-0006-09f6-5c9adfeb34a3', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;


-- ========================================
-- Wildcat FC ROSTER
-- ========================================
INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1df233b5-092c-0007-dff4-2832afdac46e', '7f09e1bb-ee7f-0005-739b-caf0f540a273', 'df5b154f-7409-0006-2e6e-5220e856488f', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f65db8af-a55b-0007-3d25-4c81d8bb6b0e', '7f09e1bb-ee7f-0005-739b-caf0f540a273', 'ed98f9fc-45af-0006-0cb0-223ebc6fd69e', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('71e216d0-7b38-0007-dbab-b8e95ec5776e', '7f09e1bb-ee7f-0005-739b-caf0f540a273', '7cff48dd-9993-0006-b922-3c1534a96716', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e10cecff-ee51-0007-3050-703aca7f5725', '7f09e1bb-ee7f-0005-739b-caf0f540a273', '290f225e-59ea-0006-0318-eddbe2dfd69c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7f100184-edaa-0007-7598-c8f2bd465a0c', '7f09e1bb-ee7f-0005-739b-caf0f540a273', '46af404f-4f93-0006-728e-e6e783b7b474', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4748f728-85c8-0007-87dc-5218d3aa1ddc', '7f09e1bb-ee7f-0005-739b-caf0f540a273', 'a1c34d59-234a-0006-982a-a093f109a573', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b2a1b8af-4881-0007-d8cf-28f81c69fad6', '7f09e1bb-ee7f-0005-739b-caf0f540a273', 'df8c3322-9ddc-0006-f0c2-e144e5587b87', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e01ca7a1-4be1-0007-e5f9-da4525bf6d76', '7f09e1bb-ee7f-0005-739b-caf0f540a273', '9e8988b0-f05e-0006-c3b0-8ab21e18b994', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1aed235a-fb87-0007-c9c1-4184a655e726', '7f09e1bb-ee7f-0005-739b-caf0f540a273', '8bd984ef-793c-0006-a805-60a2c5304b8b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9cd1cc0a-a0a6-0007-65fa-f250ed6a4ce0', '7f09e1bb-ee7f-0005-739b-caf0f540a273', '80f07d6a-da37-0006-8270-8653355dc779', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('94692fe0-6899-0007-4aa2-baddc6d7278f', '7f09e1bb-ee7f-0005-739b-caf0f540a273', '33c0f5bb-d37b-0006-9af3-9f3d6218c94f', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c6ec9206-857d-0007-af54-a1a2e1c41fff', '7f09e1bb-ee7f-0005-739b-caf0f540a273', 'f7b000d3-f1c4-0006-18c2-06c7199ccb6c', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c3083344-9fb2-0007-e74a-9553a8f0718d', '7f09e1bb-ee7f-0005-739b-caf0f540a273', '9c6781cb-a72c-0006-865d-74275cd19f37', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('5a235a33-6c4d-0007-ec5f-6b8cdb17e043', '7f09e1bb-ee7f-0005-739b-caf0f540a273', '82b4490c-a296-0006-1541-c4f1f2ad2b86', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('59cc35a9-789d-0007-8b71-b364bb46d8e7', '7f09e1bb-ee7f-0005-739b-caf0f540a273', '23cad7b2-21f2-0006-beb6-4a7f2d287b32', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e21e0980-8f69-0007-b8f9-6461803cf6a4', '7f09e1bb-ee7f-0005-739b-caf0f540a273', 'a95d2c01-6992-0006-ff8b-600b626b5e58', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3174e806-e232-0007-5bcb-5c596772ce2a', '7f09e1bb-ee7f-0005-739b-caf0f540a273', '5e2f348b-40d5-0006-3102-0d7f66a5dfc7', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('cda778a6-a9ee-0007-9542-641f99ec23e2', '7f09e1bb-ee7f-0005-739b-caf0f540a273', '2ccbb8dd-ea97-0006-57ca-228830624803', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0e0b8fc8-643a-0007-2ad2-5001f4c4d80d', '7f09e1bb-ee7f-0005-739b-caf0f540a273', '9da83806-e9a9-0006-77d0-d9b933e9bfdd', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c1400b4b-dd2e-0007-e826-8ee4aff7c5dd', '7f09e1bb-ee7f-0005-739b-caf0f540a273', '1c41f6f3-e71c-0006-8abf-8bf33bfeb0cc', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2d63cd29-0752-0007-bb8e-0256083d6157', '7f09e1bb-ee7f-0005-739b-caf0f540a273', 'abba3694-b109-0006-566e-85a1e07b0ca3', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('cc6e4c27-2571-0007-698f-fc0f8ccd0d0d', '7f09e1bb-ee7f-0005-739b-caf0f540a273', 'a0f021ae-23d3-0006-aeee-013e41a4f19a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a1ce7f07-eb23-0007-9ba0-210c99ef50c0', '7f09e1bb-ee7f-0005-739b-caf0f540a273', '87673440-5c13-0006-764c-1f8feaa7f962', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c5c6a21a-d94b-0007-4f56-5a4710584c2b', '7f09e1bb-ee7f-0005-739b-caf0f540a273', 'a6a679f2-9ad4-0006-fcf7-eec486003c80', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('eeb9356c-bbd1-0007-172b-44810a837a72', '7f09e1bb-ee7f-0005-739b-caf0f540a273', 'f402abc6-88aa-0006-a225-ba47b179dd9b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('32537879-f852-0007-2c38-52be76c193dc', '7f09e1bb-ee7f-0005-739b-caf0f540a273', '60bb5a8c-3549-0006-d8d5-87901d3dcc8b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('018aa02a-a4fb-0007-524f-3a6587a08bbb', '7f09e1bb-ee7f-0005-739b-caf0f540a273', 'cdc01c0d-855f-0006-9bc7-80dc5c6302f8', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;


-- ========================================
-- Hermandad Connecticut ROSTER
-- ========================================
INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('aea5060c-c023-0007-22df-8cbec9b3ea5b', '5c979af3-1b0d-0005-afb1-07227c8fb58c', '37887734-1c9e-0006-2a9f-ea4402a033ea', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ddef138e-965b-0007-378c-36d3dd5f93d2', '5c979af3-1b0d-0005-afb1-07227c8fb58c', '2c1274f4-35c4-0006-9927-edb92f123fec', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e5d3c1bc-09b4-0007-1081-4711618bfe4a', '5c979af3-1b0d-0005-afb1-07227c8fb58c', 'b6ad791d-c033-0006-c6bc-42b641d90681', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('925d86dc-50d4-0007-af2e-15c616dcb2d2', '5c979af3-1b0d-0005-afb1-07227c8fb58c', '6d21bfe3-90d9-0006-409a-dce7d26f0992', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3a31ee6a-5941-0007-02b0-f286b6ce6bc8', '5c979af3-1b0d-0005-afb1-07227c8fb58c', '141b275f-f275-0006-08be-5d3104d7e115', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('8e6879fb-441f-0007-7ee6-e15acf4be6b5', '5c979af3-1b0d-0005-afb1-07227c8fb58c', '481d1f8b-a183-0006-b1d2-070a083d5af1', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7fc39d30-99a8-0007-b7cf-e78ad0f9b8a1', '5c979af3-1b0d-0005-afb1-07227c8fb58c', '87b316fb-5f4c-0006-5da8-083ad5676203', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('fe94defa-72be-0007-5fb5-79d055593195', '5c979af3-1b0d-0005-afb1-07227c8fb58c', 'af9832ff-88e9-0006-662b-469af229cf59', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('6c624617-6903-0007-0159-c59e8a2a1208', '5c979af3-1b0d-0005-afb1-07227c8fb58c', 'dbc9f3e6-fa84-0006-cc5d-5d8b35b2fb03', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d7df69bb-d151-0007-636a-a43fff7d6f9d', '5c979af3-1b0d-0005-afb1-07227c8fb58c', '938d0a54-db68-0006-74bd-7c4b37323ad5', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('170f372a-cbbb-0007-bfd5-bd6f8e0a0339', '5c979af3-1b0d-0005-afb1-07227c8fb58c', '5d7e9ac2-9e17-0006-eeca-6764ca4395b0', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('76ead4fb-8c9b-0007-d516-1142e9da30ba', '5c979af3-1b0d-0005-afb1-07227c8fb58c', '09e4ba92-944c-0006-ef6f-2f4a54583d93', 4, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e8d3bd8d-c2c6-0007-9ffc-42f686b715ce', '5c979af3-1b0d-0005-afb1-07227c8fb58c', '0978b528-8643-0006-d96b-e6d4ecced09c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('165606cf-e3d9-0007-219c-be06f2ef7f7e', '5c979af3-1b0d-0005-afb1-07227c8fb58c', '8adf97db-d8d4-0006-a68b-b687f5009701', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2ca7648a-0ddc-0007-1fd3-633eaec900e0', '5c979af3-1b0d-0005-afb1-07227c8fb58c', 'ffda714f-7247-0006-d86a-769e482cfce4', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('16bc9a8e-baf8-0007-c461-99dceebd4e85', '5c979af3-1b0d-0005-afb1-07227c8fb58c', 'e52b0058-1362-0006-73ce-fad00c2ce970', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4f7c1195-9407-0007-c907-03bb48f96e92', '5c979af3-1b0d-0005-afb1-07227c8fb58c', '65ede4cb-28c0-0006-b2bc-f58d518e479b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d1afb7ff-dd67-0007-1239-13d880f2ab0f', '5c979af3-1b0d-0005-afb1-07227c8fb58c', '756a1940-6a88-0006-c40f-e403f8dad736', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ff827b58-e43a-0007-4ee0-c58dcd1c347b', '5c979af3-1b0d-0005-afb1-07227c8fb58c', '763f3b0b-ede4-0006-4a23-2068df5686fa', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1b815b7d-7012-0007-a4d0-c1dd105aa2fc', '5c979af3-1b0d-0005-afb1-07227c8fb58c', 'e849dbbe-14a5-0006-de04-028a01a21dce', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d0aaf372-eae2-0007-9b42-6bba57ea3f0f', '5c979af3-1b0d-0005-afb1-07227c8fb58c', '63952863-ed62-0006-719b-1e1658d07bec', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('efbfea70-d5f1-0007-eb55-99d226aadcb0', '5c979af3-1b0d-0005-afb1-07227c8fb58c', '6584e60d-7170-0006-eb1c-1db9bff85c20', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('71a57841-51da-0007-789c-80e897711902', '5c979af3-1b0d-0005-afb1-07227c8fb58c', 'ca77f3b9-8757-0006-d381-c497f6b5ec1c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b4cf77e4-14b8-0007-cfb9-cadd3070c981', '5c979af3-1b0d-0005-afb1-07227c8fb58c', '9f25fe99-fe02-0006-dc3b-11426a5d14f7', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c4515400-1dec-0007-5ebc-fd3c90a3c6e9', '5c979af3-1b0d-0005-afb1-07227c8fb58c', '084a82e2-1cd3-0006-4ab1-f6199d988008', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f3305fd6-d549-0007-1235-9a6aabc2c481', '5c979af3-1b0d-0005-afb1-07227c8fb58c', '9940e7a1-906a-0006-4126-9668daa86be8', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('cd8dab9a-0fea-0007-b2d8-83c622a082dc', '5c979af3-1b0d-0005-afb1-07227c8fb58c', '9bd30a1f-a719-0006-5c63-13cadb08e706', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('42377369-ab77-0007-82e3-d64b08072f4a', '5c979af3-1b0d-0005-afb1-07227c8fb58c', '64946898-0458-0006-35d0-ca2b76486505', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('5d01be63-9a45-0007-4dc0-2b9537620fde', '5c979af3-1b0d-0005-afb1-07227c8fb58c', 'a6e03e26-3e59-0006-041d-4156de289f32', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('612975b7-182e-0007-d31e-06fee3788171', '5c979af3-1b0d-0005-afb1-07227c8fb58c', 'cbfd2ed9-308f-0006-b0ea-0b84f3095327', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b0f627c9-02ef-0007-6df2-2ef820478435', '5c979af3-1b0d-0005-afb1-07227c8fb58c', 'cd839d32-0465-0006-8865-a353942547c8', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('15e17511-058d-0007-377c-9c478e84c92c', '5c979af3-1b0d-0005-afb1-07227c8fb58c', '2f187c1a-669a-0006-0753-18c18c70c0a9', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;


-- ========================================
-- NY Greek Americans ROSTER
-- ========================================
INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('df2b671f-a631-0007-7cdf-2ac17c8d3eeb', 'a9e2b1a8-5969-0005-f674-2f918d293250', '301196cc-85f6-0006-46aa-3fdf9b6ca61f', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0e798e1c-1eb9-0007-964a-af6454e67ef8', 'a9e2b1a8-5969-0005-f674-2f918d293250', 'c32b2e33-3e0e-0006-defa-e19017caee35', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('5873a5f7-65a4-0007-89ae-2b26f90355a3', 'a9e2b1a8-5969-0005-f674-2f918d293250', 'be39983a-d3ce-0006-9c69-32c274a01322', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a5e076eb-f368-0007-4987-8e31859ba717', 'a9e2b1a8-5969-0005-f674-2f918d293250', 'c339a18b-6b92-0006-9352-0ffca788db0f', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('180c7dd3-8b86-0007-dffb-00f4f29b3fae', 'a9e2b1a8-5969-0005-f674-2f918d293250', 'aa2b3a30-9783-0006-3012-c96de69bf414', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ad672939-1d21-0007-9105-43ccdb10b225', 'a9e2b1a8-5969-0005-f674-2f918d293250', 'a461ba94-9d65-0006-98fb-d0616298ee94', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b02bef18-ed70-0007-2968-ac322d15495b', 'a9e2b1a8-5969-0005-f674-2f918d293250', 'e0447b79-71f8-0006-1f44-1048e4e1c030', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('55ef2b53-df1f-0007-ef72-4c1d7af3dd58', 'a9e2b1a8-5969-0005-f674-2f918d293250', 'c72e17a8-0705-0006-c881-cc11c1b5894e', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f81088b2-81ce-0007-9722-b81a9fc03c5f', 'a9e2b1a8-5969-0005-f674-2f918d293250', '8ff592e8-588d-0006-333d-e751e33c7887', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1a309683-c003-0007-9fbe-3428b9c82b54', 'a9e2b1a8-5969-0005-f674-2f918d293250', '0b9b759a-2039-0006-e0f1-a134ab519a8a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('74f830ac-7693-0007-9573-5055118ca913', 'a9e2b1a8-5969-0005-f674-2f918d293250', 'ba2dd9ea-4e93-0006-1076-f501632aac0f', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7fe75954-9960-0007-3c36-331a9eec1914', 'a9e2b1a8-5969-0005-f674-2f918d293250', 'd7a0a679-edbb-0006-abdb-2464cb1460d0', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('68315551-944d-0007-c498-a019141b92b2', 'a9e2b1a8-5969-0005-f674-2f918d293250', '8333d962-2e91-0006-ddd2-de335577c25c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ec9e3778-b76f-0007-7c4c-6d2656d8b0f8', 'a9e2b1a8-5969-0005-f674-2f918d293250', '3f39782c-0495-0006-fbf6-3934468be92e', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c1095eb8-342b-0007-4351-db4cc078e0d9', 'a9e2b1a8-5969-0005-f674-2f918d293250', '305f9af7-7a9f-0006-e22f-ae7bd9172048', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('5c87684a-2059-0007-4cdd-64d8a63627e0', 'a9e2b1a8-5969-0005-f674-2f918d293250', 'f9d3f733-fd4b-0006-70a6-0ce9b4f7e95c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2a5e8ce4-548d-0007-d9c2-50015e223c95', 'a9e2b1a8-5969-0005-f674-2f918d293250', 'c0042e32-75ba-0006-78fa-456d5779221f', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0cdd0bfa-25a0-0007-5a6d-cb143fd563aa', 'a9e2b1a8-5969-0005-f674-2f918d293250', '9b22def6-74f1-0006-6d08-1699cd51fd91', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c20ca7f3-7757-0007-3425-ef25f069fb3d', 'a9e2b1a8-5969-0005-f674-2f918d293250', 'e4c8d49f-b0c4-0006-d2e4-f419788dae13', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('74d9a9fb-8fe4-0007-8bad-1f262181e078', 'a9e2b1a8-5969-0005-f674-2f918d293250', 'a06987e3-0303-0006-6868-acecdef7ba3d', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d3396ce7-cb27-0007-471a-ffff089c10a3', 'a9e2b1a8-5969-0005-f674-2f918d293250', 'fe81d03e-69ca-0006-cd96-7f80fc1497ca', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('513622d4-b0d2-0007-0094-e9856258f8e6', 'a9e2b1a8-5969-0005-f674-2f918d293250', 'a1731888-6639-0006-b7ec-68f8ca919f85', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2dda66d6-209b-0007-f0cb-b212a843cccd', 'a9e2b1a8-5969-0005-f674-2f918d293250', '9495766c-4298-0006-3f17-da33fafaed51', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('960e5cd3-dab7-0007-5c35-d9079ee43eb6', 'a9e2b1a8-5969-0005-f674-2f918d293250', 'c837a663-b04d-0006-45b3-df013bd682b2', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f363e005-31b4-0007-6e1f-b30c2ef96351', 'a9e2b1a8-5969-0005-f674-2f918d293250', '52e3b16a-8058-0006-d8cd-a2675e5cb7c3', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('fa192988-e35f-0007-ff9e-34b85d10b050', 'a9e2b1a8-5969-0005-f674-2f918d293250', 'ba2d6091-0a3f-0006-db9f-ac243be4023d', 11, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ab8d9113-4b80-0007-a4ac-234a2c7a8c5a', 'a9e2b1a8-5969-0005-f674-2f918d293250', '360fc8da-30d7-0006-df1d-2e4e1d1582d6', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('39ce1a96-01ad-0007-a6ff-e84e88cdb935', 'a9e2b1a8-5969-0005-f674-2f918d293250', '12cb46f3-5dd0-0006-4b3a-766d1902670e', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('286f5156-f709-0007-252c-7c6d8e69a745', 'a9e2b1a8-5969-0005-f674-2f918d293250', '55c03c6e-182b-0006-b9b8-d22d982ac4a1', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1023a170-7e50-0007-8b9e-b9fb01dba544', 'a9e2b1a8-5969-0005-f674-2f918d293250', 'f83a32f0-758f-0006-98cf-52ea4b6774ed', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('144b16e7-10d7-0007-eba4-e870ff39eee9', 'a9e2b1a8-5969-0005-f674-2f918d293250', '1d7bb63d-1131-0006-4dac-9ef5900a4ea3', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('8c2f3f3a-7ce4-0007-3ce2-4c0000cbfa12', 'a9e2b1a8-5969-0005-f674-2f918d293250', 'a101716d-dd0e-0006-511c-13e7829942f8', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('cd86be60-0a6b-0007-8fce-a23437ccc0d5', 'a9e2b1a8-5969-0005-f674-2f918d293250', '17f5e376-b286-0006-7f0f-c432d68ad3af', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9ab95d89-1154-0007-690c-10c692b35171', 'a9e2b1a8-5969-0005-f674-2f918d293250', 'fa28096f-ce43-0006-25e3-e703808e45d5', 8, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;


-- ========================================
-- Hoboken FC 1912 ROSTER
-- ========================================
INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0b0e30fd-f0b0-0007-dedc-74080aa94243', '49df0225-be54-0005-699c-ee6cd5da686b', '7d34d8bc-79c9-0006-0ca7-da9e5e7098cd', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4a9f16cc-6660-0007-e32e-7eef94ba77d2', '49df0225-be54-0005-699c-ee6cd5da686b', '776ac1ef-e719-0006-392f-6f3018ffa05a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('09cd3744-a6c1-0007-2793-a694480b4ba6', '49df0225-be54-0005-699c-ee6cd5da686b', 'dc59256f-e35f-0006-14a7-28bce22acbdc', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('86183aa3-83a7-0007-3d95-4fa55635c4fc', '49df0225-be54-0005-699c-ee6cd5da686b', '1b6d8052-5f37-0006-b5c4-e84efa7ee1c8', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('fcb8a75e-3b61-0007-c2da-2764dd73996b', '49df0225-be54-0005-699c-ee6cd5da686b', '49fa6860-fa1e-0006-6a87-21cc547b7d2e', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('fec96adb-e469-0007-b373-1cdb3c329316', '49df0225-be54-0005-699c-ee6cd5da686b', 'c07df1fb-6f49-0006-be75-510b4083549e', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0044901d-793d-0007-0086-de66f24e5892', '49df0225-be54-0005-699c-ee6cd5da686b', 'a505ea71-79e5-0006-a589-e2ef4dce5622', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ac9b631e-be91-0007-fb7f-98a47d4ef7c0', '49df0225-be54-0005-699c-ee6cd5da686b', '9b529b5d-9eaa-0006-ab8b-d899f0365ee2', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d1b25017-c096-0007-c635-9b2d19d543b3', '49df0225-be54-0005-699c-ee6cd5da686b', '3c9e3d11-7853-0006-1f0c-babcb15d5ed3', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3e528635-8609-0007-2fc9-04d1d40b000e', '49df0225-be54-0005-699c-ee6cd5da686b', 'e2632be1-c983-0006-e4ec-ac4f5123a3f1', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('fcd92756-17bd-0007-f6a4-7b13e264799e', '49df0225-be54-0005-699c-ee6cd5da686b', 'b2bbc4d6-6654-0006-0880-a3b79927b1de', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3dc7d583-a57f-0007-e1d3-61fbd3a22d93', '49df0225-be54-0005-699c-ee6cd5da686b', '59e8261d-3426-0006-03e5-b19fae529f67', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('dd443733-4b50-0007-291a-c23d53fb1b7d', '49df0225-be54-0005-699c-ee6cd5da686b', 'c4cca3e3-1ecd-0006-ed84-e2a4962ab429', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b4f302f7-323e-0007-2997-1bc145a2189e', '49df0225-be54-0005-699c-ee6cd5da686b', '6de1c4f9-94bd-0006-0a3a-505ef7ae6e5a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b654409d-8bd6-0007-393e-451122c3df01', '49df0225-be54-0005-699c-ee6cd5da686b', '2d9e0689-418a-0006-4841-4e2f14c33289', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a4cf1d23-091d-0007-b7ec-d838d0d663c0', '49df0225-be54-0005-699c-ee6cd5da686b', '7851e92c-264b-0006-aba3-b728ae6dfc82', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e06c8d9e-9ed9-0007-b85c-90ceb4e292ce', '49df0225-be54-0005-699c-ee6cd5da686b', '836c656f-c985-0006-3268-260d1aac7afd', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('5f31b280-049c-0007-c64b-793dcb96ae0c', '49df0225-be54-0005-699c-ee6cd5da686b', '1eeb8012-e8ea-0006-40bc-992347b04575', 8, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f28dd504-8833-0007-3f7b-0fe072ce4e24', '49df0225-be54-0005-699c-ee6cd5da686b', 'd4573209-6662-0006-05a0-7130381b62a4', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('50ffb7d4-02eb-0007-83f7-36689ac4033d', '49df0225-be54-0005-699c-ee6cd5da686b', 'bb857711-8f53-0006-7820-47f2c5cacb02', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b927927e-6593-0007-24d9-291a56ac7f5a', '49df0225-be54-0005-699c-ee6cd5da686b', '82e727f0-f912-0006-af62-6bd3b076f113', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('fa25a318-4d4b-0007-1f6b-03896f135233', '49df0225-be54-0005-699c-ee6cd5da686b', '37d5e396-215d-0006-004a-94246c0a5144', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f7b91da0-da18-0007-1e9a-52187678284a', '49df0225-be54-0005-699c-ee6cd5da686b', '14ef5b9c-c20d-0006-b86d-084bbb0e58cd', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('68938c90-24b9-0007-eba4-e5e90634f9d2', '49df0225-be54-0005-699c-ee6cd5da686b', 'da967792-2afb-0006-63e7-e8d522725a17', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('52204058-bbd5-0007-79fe-4f5d2a4c3fc6', '49df0225-be54-0005-699c-ee6cd5da686b', 'b28c2d64-6759-0006-189a-b7c9f1e31487', 4, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('73f0ba55-cfe2-0007-530c-3d935c54ddb0', '49df0225-be54-0005-699c-ee6cd5da686b', '66d5082d-9c7c-0006-e276-95bafed41de7', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('11af3255-40b1-0007-1f18-8e7d593e494d', '49df0225-be54-0005-699c-ee6cd5da686b', 'e788aa21-dddc-0006-8a72-79cd47baf379', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7be1f81a-f8f4-0007-7a71-f6e50eec39a5', '49df0225-be54-0005-699c-ee6cd5da686b', 'a85fbe60-64e9-0006-05c3-ebce0212c4b5', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('887f1126-271b-0007-95c3-17d2ed801f13', '49df0225-be54-0005-699c-ee6cd5da686b', 'f2730927-fc3e-0006-f91a-449c19d19b37', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a7ede384-5663-0007-0d6a-035b2daf5f70', '49df0225-be54-0005-699c-ee6cd5da686b', 'c244669f-3d2a-0006-b722-121835bd745b', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c56fafa5-5a37-0007-41fc-fa326e79bae9', '49df0225-be54-0005-699c-ee6cd5da686b', '16c7bd74-ccdb-0006-a2ff-6dcffd12b32d', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('532562ae-cb9f-0007-046e-7d82c454527b', '49df0225-be54-0005-699c-ee6cd5da686b', 'c6d4a358-0660-0006-1e0a-20f8f92754e4', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('791844c3-237f-0007-55cc-eb5e4d84db77', '49df0225-be54-0005-699c-ee6cd5da686b', '0220f79d-d177-0006-1d33-498fa52c6485', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('689d1cba-311b-0007-3dd3-8faa58058ef5', '49df0225-be54-0005-699c-ee6cd5da686b', 'bc8312ea-2301-0006-3e60-14898c745702', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('6f52d3bf-d084-0007-820c-e4727f0b7b24', '49df0225-be54-0005-699c-ee6cd5da686b', '2a717cb8-51f9-0006-424b-7076d7b8094d', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e796746c-e0c2-0007-23fc-9b3bba670cbb', '49df0225-be54-0005-699c-ee6cd5da686b', 'a6b9182f-2fb2-0006-4a50-4af2135fa73e', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('13808e25-cb17-0007-b9ff-d2e3872d0a1d', '49df0225-be54-0005-699c-ee6cd5da686b', '8491030a-f94b-0006-fd55-bafaf47c0edd', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('da8da5b3-1d0d-0007-7d84-c51636ab1814', '49df0225-be54-0005-699c-ee6cd5da686b', 'd6fc4bf2-d8d4-0006-bfc0-4af2eb2fac02', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c3d30e68-e1e8-0007-507f-38c7be1ae9d3', '49df0225-be54-0005-699c-ee6cd5da686b', 'd6e5cc1e-3ac2-0006-4679-69265ffb7db4', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;


-- ========================================
-- NY Pancyprian Freedoms ROSTER
-- ========================================
INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7af5516d-d7e4-0007-db6f-1dbc5eca67bf', 'cd0f7cdf-7018-0005-51d9-cafefed696e5', 'ad95defb-0e84-0006-1f5d-01700a7f7d39', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('acef4e80-bd5f-0007-1a50-80d461b50481', 'cd0f7cdf-7018-0005-51d9-cafefed696e5', '0b9f6a24-f6d0-0006-927e-3a09b6633c9a', 3, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('bd94fede-dbab-0007-b9f5-add864c7942b', 'cd0f7cdf-7018-0005-51d9-cafefed696e5', 'ca9319b0-6b21-0006-e70c-ad5a74350686', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2be163f2-967d-0007-2615-b8c1d4e60f38', 'cd0f7cdf-7018-0005-51d9-cafefed696e5', '8d84cee1-a81b-0006-1981-af5d5556e1c7', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2b18153b-7e2a-0007-0890-24841b500190', 'cd0f7cdf-7018-0005-51d9-cafefed696e5', '9f0d6c6e-1a3c-0006-e375-a79fe5238b21', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('8729514f-e415-0007-1fdc-4108b11b82ac', 'cd0f7cdf-7018-0005-51d9-cafefed696e5', '7f28b126-0afc-0006-71b8-cbc6f9f0ac78', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d969f915-4ef3-0007-0149-d534c681b04a', 'cd0f7cdf-7018-0005-51d9-cafefed696e5', 'd149f49b-acc5-0006-2c7c-eb2074be7674', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('10bbb029-99b6-0007-a4d9-02618f6a6fae', 'cd0f7cdf-7018-0005-51d9-cafefed696e5', '2a9d2882-1fba-0006-a423-f0addab7b5be', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('16bd80c2-34eb-0007-38b5-4b22858e9861', 'cd0f7cdf-7018-0005-51d9-cafefed696e5', '0cd0b9b4-7a59-0006-bf55-9fe2f7b63d74', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d46ec8df-4125-0007-5dc1-d9c83e814eaa', 'cd0f7cdf-7018-0005-51d9-cafefed696e5', '0a912565-84ec-0006-d1c3-e33df55ab126', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('8588e8c5-9d1c-0007-e797-23d4d454cfe9', 'cd0f7cdf-7018-0005-51d9-cafefed696e5', '85b51d2d-23a3-0006-7452-c1380cce73cc', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('51f800dd-6da7-0007-3a87-b10ffb81ee43', 'cd0f7cdf-7018-0005-51d9-cafefed696e5', '269a1762-04e0-0006-9e08-cc7f73150dae', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f11cb2d8-17c7-0007-e823-fc13e5545887', 'cd0f7cdf-7018-0005-51d9-cafefed696e5', 'de85cb97-a39a-0006-04de-e4895788f723', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('befe27a6-d9ba-0007-0427-287b9bcc4d68', 'cd0f7cdf-7018-0005-51d9-cafefed696e5', '7b22c55c-b1dc-0006-d308-fdeabb970179', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2d36b17e-2945-0007-054a-eee533dffe2f', 'cd0f7cdf-7018-0005-51d9-cafefed696e5', 'c4e6b96e-ed58-0006-d9cb-06c2ac156021', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0a7b11de-85bd-0007-4b1b-25e6c74e878f', 'cd0f7cdf-7018-0005-51d9-cafefed696e5', 'e617b3b8-f880-0006-1cae-01ab200de6d8', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('96c9ab66-af33-0007-82d6-4b55781ba428', 'cd0f7cdf-7018-0005-51d9-cafefed696e5', '10ba9b74-a1b3-0006-a65f-c8d6498e0e22', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e237b4a9-36d9-0007-2c35-62da79a1dbe3', 'cd0f7cdf-7018-0005-51d9-cafefed696e5', 'aa860b38-a098-0006-ae66-66d4c5dbe941', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0b6c3d75-a5d2-0007-2617-efc760a5b226', 'cd0f7cdf-7018-0005-51d9-cafefed696e5', 'd6cdd6ad-4891-0006-7814-665e6c6fcd4f', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('fafe7c4a-5a08-0007-9c19-5ca0ff554e22', 'cd0f7cdf-7018-0005-51d9-cafefed696e5', '9812044e-02b4-0006-f0df-fc72fb89b3dd', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9df8ade6-bf23-0007-e9af-07e8e632b7f0', 'cd0f7cdf-7018-0005-51d9-cafefed696e5', 'd3804ae3-e7d1-0006-c3b9-8fb7248015c7', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0d84992f-bdb5-0007-cf07-a55717ec40df', 'cd0f7cdf-7018-0005-51d9-cafefed696e5', '3653f472-7432-0006-739a-5b47b8569883', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('023f364a-623e-0007-eaab-5e3343a13e92', 'cd0f7cdf-7018-0005-51d9-cafefed696e5', '0e410dd4-6f65-0006-b6ee-75a2056d1964', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a67bc14a-e0e6-0007-cef7-b2089b515e35', 'cd0f7cdf-7018-0005-51d9-cafefed696e5', '36a0fa14-0977-0006-a6a1-ce6c0722f049', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('6434117e-e56f-0007-a77c-3a233e5dafc3', 'cd0f7cdf-7018-0005-51d9-cafefed696e5', 'e6d97a8a-7919-0006-e19e-b468acb0046a', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9177ec9d-9bd2-0007-f68e-10b9b9a9537c', 'cd0f7cdf-7018-0005-51d9-cafefed696e5', '843caf24-a2a3-0006-000b-e7d1b47bfdea', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e94cd926-a2eb-0007-e710-c8e7ecb292fe', 'cd0f7cdf-7018-0005-51d9-cafefed696e5', 'd8bf5fa7-6122-0006-8719-4e35e266f779', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('fabb2742-59c9-0007-f3ff-ff464555b704', 'cd0f7cdf-7018-0005-51d9-cafefed696e5', 'a1d91af4-baf6-0006-21b8-e578411a9741', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1ad36255-44bc-0007-8bc0-6934e2affd0e', 'cd0f7cdf-7018-0005-51d9-cafefed696e5', '2b2cfb6b-fefa-0006-1d4c-00ebdad5c0f1', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9e2e5b34-e419-0007-2a1b-d0922e34ffff', 'cd0f7cdf-7018-0005-51d9-cafefed696e5', '71a41f70-ae60-0006-9b7a-2ab4a48b664c', 3, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e58b2209-7fcc-0007-eb9a-d561478b51e5', 'cd0f7cdf-7018-0005-51d9-cafefed696e5', 'fa6ef07f-217e-0006-3d14-934fa4e539d5', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('846e9d1b-1b9d-0007-06a1-181b6ae4ac96', 'cd0f7cdf-7018-0005-51d9-cafefed696e5', '439f4875-fe30-0006-6033-eceda3120c9c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0e74ed1d-c70e-0007-cacf-8b42c92f44a8', 'cd0f7cdf-7018-0005-51d9-cafefed696e5', '84f23cf4-c102-0006-6e4e-021e447badea', 9, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('8f5083f4-0f5b-0007-e869-3e053a3f031e', 'cd0f7cdf-7018-0005-51d9-cafefed696e5', '59f47a10-9f5d-0006-3980-2cf779b8e785', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;


-- ========================================
-- Lansdowne Yonkers FC ROSTER
-- ========================================
INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('8b2cf354-9c35-0007-5e12-4f267a3ba97f', 'fd2f4fc8-6cbd-0005-8199-96a395b40d55', '59993596-e37e-0006-eb45-ce2067821294', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3df696f0-db91-0007-43ea-6b57fbeb197a', 'fd2f4fc8-6cbd-0005-8199-96a395b40d55', '8151f31a-42d3-0006-84c3-16e1657f1ee6', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('275da0ec-3282-0007-1d78-5de9c1969b55', 'fd2f4fc8-6cbd-0005-8199-96a395b40d55', '542c61bf-23cc-0006-5b9b-9e47513f06ef', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a0fcfd30-fbf2-0007-2ac8-0518ae1c8cf9', 'fd2f4fc8-6cbd-0005-8199-96a395b40d55', '1f80a10c-2dbb-0006-f563-1fcb5f80c6f6', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d7e6ae27-c83f-0007-7ac6-1f188821f940', 'fd2f4fc8-6cbd-0005-8199-96a395b40d55', '324477f5-4b71-0006-c97d-33ec70b6f835', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2b3ba232-f908-0007-d73b-9a7e20e505bc', 'fd2f4fc8-6cbd-0005-8199-96a395b40d55', '8f87a43e-a21b-0006-0f9e-0e6341598a27', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('541b722f-d185-0007-cfef-4d182710bc13', 'fd2f4fc8-6cbd-0005-8199-96a395b40d55', '0a26b622-a633-0006-aeea-d25be4cce5d1', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e0e0170c-aebb-0007-8b36-4a0357bf922d', 'fd2f4fc8-6cbd-0005-8199-96a395b40d55', '8aef3fbf-5667-0006-a7d8-4f2ea899ebc6', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('14c98796-1b6d-0007-9324-e204eb7582d3', 'fd2f4fc8-6cbd-0005-8199-96a395b40d55', '0fa8333c-30ca-0006-a175-a4baa2c2d7a3', 3, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('281d4606-2c71-0007-33d4-676e4eca0a63', 'fd2f4fc8-6cbd-0005-8199-96a395b40d55', '0a77640d-8df1-0006-4871-8519314a2fe7', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('327878fb-ae7e-0007-16df-3a89bbaf98d5', 'fd2f4fc8-6cbd-0005-8199-96a395b40d55', '4b5c2ad0-c1fa-0006-8023-bf505cf2dae0', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d204907f-ec5d-0007-c5d4-fd579e994d42', 'fd2f4fc8-6cbd-0005-8199-96a395b40d55', '9528e132-5250-0006-8e6f-7ea8894ba9ac', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('108b05ad-c66a-0007-e13b-9525c867f1c1', 'fd2f4fc8-6cbd-0005-8199-96a395b40d55', '41a442f6-c9b1-0006-bedc-940830335d05', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4be08b35-8cb4-0007-00c1-2e50eeda56d2', 'fd2f4fc8-6cbd-0005-8199-96a395b40d55', 'ea04ced7-5034-0006-0f54-e769b07caf06', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('643bd8f5-b2ea-0007-03b1-1f9829cd02f4', 'fd2f4fc8-6cbd-0005-8199-96a395b40d55', 'fbeba52d-c0ef-0006-bd13-ac959470c068', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('eeb02e45-630f-0007-d20a-7a4ba85b7168', 'fd2f4fc8-6cbd-0005-8199-96a395b40d55', 'f64b0b59-376d-0006-9d9f-25ba56d0af6b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('40ebdc93-bd64-0007-c0d6-cc3ce29d9327', 'fd2f4fc8-6cbd-0005-8199-96a395b40d55', 'f2930979-f5b3-0006-265e-136e45b28d1d', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('816598d8-1950-0007-1fb2-dbae6d823e9e', 'fd2f4fc8-6cbd-0005-8199-96a395b40d55', '15eaa056-d846-0006-9c0f-175666a4fd1a', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0fc3a438-9338-0007-9872-395441f2733f', 'fd2f4fc8-6cbd-0005-8199-96a395b40d55', 'eb1412c8-e287-0006-4e93-303dd7c39dec', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('cde89882-34a1-0007-e1d6-691df3e9a5e6', 'fd2f4fc8-6cbd-0005-8199-96a395b40d55', '40702513-5295-0006-a8c7-5d74accaee01', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e39a5e6c-b790-0007-3acd-731f88667bba', 'fd2f4fc8-6cbd-0005-8199-96a395b40d55', '889220c7-9111-0006-3b6d-83cacc26c343', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ec05ea08-165e-0007-448c-38d37eb4aab3', 'fd2f4fc8-6cbd-0005-8199-96a395b40d55', '49b2014d-cea6-0006-d060-8911a5d1ef78', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('179b5ea0-c40b-0007-560f-c0a67894dce8', 'fd2f4fc8-6cbd-0005-8199-96a395b40d55', 'a793c8b6-ceae-0006-7a5c-bb1e984a89ac', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('88eca4c7-6992-0007-a5cd-bad98ad847c1', 'fd2f4fc8-6cbd-0005-8199-96a395b40d55', '85ed3843-48b3-0006-8f5d-13e45c73c4fb', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7a16f74c-55d8-0007-ff6f-6da9b3084a85', 'fd2f4fc8-6cbd-0005-8199-96a395b40d55', 'cce91945-afd7-0006-7554-2810eef95e96', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('5897d2ba-8c5c-0007-4830-a2b123e4c857', 'fd2f4fc8-6cbd-0005-8199-96a395b40d55', '1f53cfbb-7254-0006-61a5-d57a93d42ed4', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c6b7a779-a300-0007-0e0c-1f12748597cd', 'fd2f4fc8-6cbd-0005-8199-96a395b40d55', 'f713870a-4ee0-0006-36fe-30cace47d5d5', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('82d7fa45-175f-0007-f0cf-962263aa4343', 'fd2f4fc8-6cbd-0005-8199-96a395b40d55', '6fb5e046-e079-0006-ed16-e5ff4f7e1ad7', 4, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f2e9b886-b021-0007-1c1b-8837d40c835f', 'fd2f4fc8-6cbd-0005-8199-96a395b40d55', '86b76e74-2a1b-0006-5819-f17fcc240b4c', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d1f73cf3-9843-0007-9c97-e49cb2ead860', 'fd2f4fc8-6cbd-0005-8199-96a395b40d55', '42f7c932-6f92-0006-3527-d6b4f16a1708', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('bbc5a2da-87bd-0007-abf3-51395e335095', 'fd2f4fc8-6cbd-0005-8199-96a395b40d55', '5d719a69-2fc5-0006-b01c-84d4449c7493', 3, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('20aa3827-8248-0007-cced-e073051f3935', 'fd2f4fc8-6cbd-0005-8199-96a395b40d55', '75854c8a-34e5-0006-def8-40f438cd0ad0', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('bad9442a-1a44-0007-30dd-9d9058c402cb', 'fd2f4fc8-6cbd-0005-8199-96a395b40d55', 'b0f0e842-7fd5-0006-f8a2-653ed9376c3a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;


-- ========================================
-- Leros SC ROSTER
-- ========================================
INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e6b61d90-80af-0007-651c-acba161343f2', '77717fe0-fb4f-0005-cef3-260a0c447980', '414f2572-fddf-0006-3a45-d6ee22d678c4', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0250efb2-7752-0007-a258-efe9b748dd45', '77717fe0-fb4f-0005-cef3-260a0c447980', '65464fd3-4a6e-0006-6f38-22d9d1881c9b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('93826b9c-b154-0007-8103-7ab90ebb5a99', '77717fe0-fb4f-0005-cef3-260a0c447980', 'e978ab5e-a1c0-0006-d059-3e564e18b1fb', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a86a8e6e-979a-0007-c4df-c6a5c2b51c2e', '77717fe0-fb4f-0005-cef3-260a0c447980', '381f3765-2083-0006-6f4d-3841bd909aba', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('58a062d2-06cc-0007-4168-7e1b6cb9659d', '77717fe0-fb4f-0005-cef3-260a0c447980', '85224882-93cb-0006-6634-9f484cd2da58', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('327df0ac-d78e-0007-ad9a-943cfeacf696', '77717fe0-fb4f-0005-cef3-260a0c447980', 'be8d6c47-4e8a-0006-a5ad-6ad150cdcdcf', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a4b36017-749c-0007-2255-0944c1b8738e', '77717fe0-fb4f-0005-cef3-260a0c447980', '5007e41e-9ba6-0006-ce0f-877f8a328038', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('44a91fd3-543b-0007-ee17-00c173d45efc', '77717fe0-fb4f-0005-cef3-260a0c447980', '9d0729d8-ab23-0006-dcac-13b89a78b448', 5, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('077ee313-39df-0007-596a-b34446baead1', '77717fe0-fb4f-0005-cef3-260a0c447980', 'd64244a7-ce94-0006-0005-ed6ebe4cb28d', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e4cf0d1d-34e2-0007-ac30-6fe818197db8', '77717fe0-fb4f-0005-cef3-260a0c447980', 'f197bffc-ca2a-0006-2730-7acf60e6aa26', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ba4a2225-be36-0007-a5fd-95abbd21c7d6', '77717fe0-fb4f-0005-cef3-260a0c447980', '617414fa-4c77-0006-3d61-94cb8986268b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e5590426-1096-0007-58b1-4406326f3873', '77717fe0-fb4f-0005-cef3-260a0c447980', '13d66bb3-8fe8-0006-04f8-7028251009c9', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c2d6b170-8c8e-0007-f0f9-671d6b2830d6', '77717fe0-fb4f-0005-cef3-260a0c447980', '49f6aa3a-3ab0-0006-271c-4ce5048d698a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('84cc7982-e2f9-0007-e310-1abf2c149c53', '77717fe0-fb4f-0005-cef3-260a0c447980', '60416857-810d-0006-adc3-d0c3b974f62e', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('42da9566-77b7-0007-5e9e-1276d679af9e', '77717fe0-fb4f-0005-cef3-260a0c447980', '9f69d7f1-48d5-0006-0434-e25a91b2002f', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1c59a420-8b33-0007-41f7-90959ece5fd3', '77717fe0-fb4f-0005-cef3-260a0c447980', '86a78668-d490-0006-507c-c63cbe981cd4', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d5f17be3-3e62-0007-80dc-5bc18969950c', '77717fe0-fb4f-0005-cef3-260a0c447980', '5fcece2e-4f5d-0006-6334-93a1764a38bf', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('21f27fdc-d104-0007-cb17-a91ceb226626', '77717fe0-fb4f-0005-cef3-260a0c447980', 'e6a3268a-f969-0006-b947-49b105511976', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('79e00c0f-dfad-0007-88e6-cde1b33eb939', '77717fe0-fb4f-0005-cef3-260a0c447980', '01bc95c9-ebf3-0006-3908-51d74696b381', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c9210183-a2e8-0007-e77f-517ddb693346', '77717fe0-fb4f-0005-cef3-260a0c447980', '55aa0a89-1333-0006-b9c3-e796842f5e4a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4a87060f-ac15-0007-fe2d-f8adde000fbd', '77717fe0-fb4f-0005-cef3-260a0c447980', '63fb84cf-c36b-0006-6c30-9f561178bfad', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('8d497c00-e2b9-0007-1b48-d4d9457a1d9c', '77717fe0-fb4f-0005-cef3-260a0c447980', '4e3f35f9-419a-0006-2b84-c039cf774337', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('45236085-2138-0007-7410-1891e10a0ee0', '77717fe0-fb4f-0005-cef3-260a0c447980', '549c604a-6c05-0006-8afb-b8364faeef3c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('495a297f-ef27-0007-c733-f3340b070d4d', '77717fe0-fb4f-0005-cef3-260a0c447980', '5d9518ee-d056-0006-1792-4ca69133d10a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('6d22b944-7633-0007-af00-530aa77e22bb', '77717fe0-fb4f-0005-cef3-260a0c447980', '441e00f6-91b9-0006-ae48-da96496c6b24', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('91670359-e74a-0007-f776-530cbb628e31', '77717fe0-fb4f-0005-cef3-260a0c447980', 'fa4fc325-734d-0006-257f-61160483af45', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('02b0d109-b2d4-0007-fab0-622895cbbe00', '77717fe0-fb4f-0005-cef3-260a0c447980', 'b1f9ddd9-2d2f-0006-9c7c-c17b0413f6e7', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('cd7950a1-7b5d-0007-1f35-bf55b75f142b', '77717fe0-fb4f-0005-cef3-260a0c447980', '0990a3e5-73da-0006-4bee-936357ce3b05', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('10342460-efaf-0007-9ca5-8121338e07ac', '77717fe0-fb4f-0005-cef3-260a0c447980', '59776b14-d92f-0006-7c21-acc132ee5372', 6, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4458b47c-d60f-0007-aaa4-b6efde7312af', '77717fe0-fb4f-0005-cef3-260a0c447980', 'f7471293-2b2d-0006-a6af-0f5bfe705f06', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d128b37c-90ce-0007-44e0-a22fda995da9', '77717fe0-fb4f-0005-cef3-260a0c447980', 'ea425cb3-cb0e-0006-42ab-63e39811f9ec', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ffde8831-532f-0007-d534-4f010616c092', '77717fe0-fb4f-0005-cef3-260a0c447980', '96d07dfc-7d4e-0006-23cb-315fd5dac2bb', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3170548d-4717-0007-88ca-0270db3d3ab1', '77717fe0-fb4f-0005-cef3-260a0c447980', '96e928a1-380e-0006-0399-a4c5edd55f2c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c1591eb2-0a4c-0007-7966-6d0cbce90946', '77717fe0-fb4f-0005-cef3-260a0c447980', '26b7d142-5aaf-0006-39ea-39a5af77dfdb', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e7df4cd4-edd5-0007-52a1-101f1544e2ed', '77717fe0-fb4f-0005-cef3-260a0c447980', '1cc2f56c-2f29-0006-00a4-11ffd36b837a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;


-- ========================================
-- Doxa FCW ROSTER
-- ========================================
INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('931a418e-5cb4-0007-6e9c-fc6a002b01a7', '68b50f22-dddc-0005-06ca-622f3a3a0ea4', '8553283e-0bc5-0006-ab93-d578af73abc5', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f85e672d-178b-0007-d9fb-4dfb02bcfcb4', '68b50f22-dddc-0005-06ca-622f3a3a0ea4', 'b807f992-6c9f-0006-8fe6-9e67409b66b6', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('06436022-1f0c-0007-6205-090e012f7bfb', '68b50f22-dddc-0005-06ca-622f3a3a0ea4', '9dfcf283-1554-0006-47f4-f999e499c15c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d97d35da-1d05-0007-9bc8-7ab32624d468', '68b50f22-dddc-0005-06ca-622f3a3a0ea4', 'e8b6dbbf-15a0-0006-ab8d-3d73a99ad0b5', 3, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('50f4e114-29e6-0007-0bed-163b8313cc0c', '68b50f22-dddc-0005-06ca-622f3a3a0ea4', '136850cb-6768-0006-7d88-0968d7a98f4f', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('6a1ccf20-2bde-0007-69b6-3a22fdbe3eac', '68b50f22-dddc-0005-06ca-622f3a3a0ea4', '82a13ab1-cfc2-0006-8bc3-f33d80f586e1', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d68acdcd-803e-0007-2f5b-fe2e6f0b9fdd', '68b50f22-dddc-0005-06ca-622f3a3a0ea4', 'e354b1b6-cec7-0006-6b0b-ae698e5ee5b4', 7, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a001d3a7-ff53-0007-1596-b9099639cf37', '68b50f22-dddc-0005-06ca-622f3a3a0ea4', 'a9b8178b-ffcf-0006-0a01-3d678f53ff7e', 3, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('02a1f4fe-6524-0007-5f3d-5f3519913bfa', '68b50f22-dddc-0005-06ca-622f3a3a0ea4', '96e324e8-3075-0006-8275-dfa60b361080', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('5ab5790c-408e-0007-04ed-16a9b4780b3e', '68b50f22-dddc-0005-06ca-622f3a3a0ea4', 'd80e6914-bf79-0006-a5db-9b406a0f25c8', 3, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('cdf3d8ee-d809-0007-57cd-e3c9062fb7d8', '68b50f22-dddc-0005-06ca-622f3a3a0ea4', '16652c73-e63c-0006-817c-3e33ca1327fa', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e22e1c18-2442-0007-d346-c5ef37db342c', '68b50f22-dddc-0005-06ca-622f3a3a0ea4', 'f4684a76-c17a-0006-c1ec-c80b80a9d5f5', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('01300a4e-49cf-0007-b918-641995407f2d', '68b50f22-dddc-0005-06ca-622f3a3a0ea4', '6fc4c8b3-be27-0006-d6cc-9d92536c7ead', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('02326ee4-6483-0007-e803-099b902061e4', '68b50f22-dddc-0005-06ca-622f3a3a0ea4', '6d9c5821-5a40-0006-e297-99756d01cc20', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e4541656-a126-0007-3cc4-cb59226ac0ff', '68b50f22-dddc-0005-06ca-622f3a3a0ea4', '31e30e09-6459-0006-f52e-29d2146f24ba', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c83f7e0d-9e8c-0007-3dfa-e6a406682820', '68b50f22-dddc-0005-06ca-622f3a3a0ea4', 'a78962bf-9a98-0006-39ee-9f19a504be4e', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c10a6af9-a4e8-0007-a347-8e11ed9f0c7c', '68b50f22-dddc-0005-06ca-622f3a3a0ea4', '58bc203e-e5c3-0006-c8f1-e511a51f0b1e', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c6fa3f1f-be6c-0007-c639-3c2833cda468', '68b50f22-dddc-0005-06ca-622f3a3a0ea4', 'c7559bdd-b14e-0006-5a4c-428b6409759f', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('8e2d5de9-d0b8-0007-8de2-bc9b38dcfcda', '68b50f22-dddc-0005-06ca-622f3a3a0ea4', 'e1978acf-a2db-0006-fcdb-245d371706c6', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d58efca2-ff0c-0007-8376-608044fcd5f8', '68b50f22-dddc-0005-06ca-622f3a3a0ea4', 'ff98ae93-b10a-0006-86d4-c2923fd89ad4', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('da294204-8584-0007-feb8-561c9e975555', '68b50f22-dddc-0005-06ca-622f3a3a0ea4', '00f5fd37-aced-0006-9734-daf0d702148d', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0d09c345-1e62-0007-0cce-c33a5f7e2f39', '68b50f22-dddc-0005-06ca-622f3a3a0ea4', 'a2b8a7c5-b649-0006-cce0-a7bd93543da6', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9acd7aab-a29b-0007-5d7b-b3bb6ba366ba', '68b50f22-dddc-0005-06ca-622f3a3a0ea4', '5365bc6b-7090-0006-06c6-b79ce5aac6c2', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('93929e08-e201-0007-4ccb-e601a161eb93', '68b50f22-dddc-0005-06ca-622f3a3a0ea4', '402bdfcc-c09b-0006-1155-cc6a9044c704', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b1a0e60a-f26c-0007-16d6-825892707f14', '68b50f22-dddc-0005-06ca-622f3a3a0ea4', '8768a116-0221-0006-25bf-cfb6e9d0442c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3044c9a1-8941-0007-259d-8dc31661aa38', '68b50f22-dddc-0005-06ca-622f3a3a0ea4', 'd1c1bb4d-6783-0006-186d-c12447516d68', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('21a9be6d-f1d4-0007-1ec6-e5c77aa544c8', '68b50f22-dddc-0005-06ca-622f3a3a0ea4', '15edf299-22ff-0006-24cd-e91f642aeb47', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a74a9466-2674-0007-8c92-ccc5f72d4840', '68b50f22-dddc-0005-06ca-622f3a3a0ea4', 'e04b2828-5b2c-0006-b352-a80109558d4c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a6249673-09cf-0007-3d49-aa07a35e9b38', '68b50f22-dddc-0005-06ca-622f3a3a0ea4', 'c7cff871-f78f-0006-a535-a62155edc074', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('460803eb-7bd1-0007-79f9-518b08a8234a', '68b50f22-dddc-0005-06ca-622f3a3a0ea4', '6295c243-c1e4-0006-d160-eb71b9ce4ad5', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e7fcf175-5bb2-0007-2161-464951cc3ff7', '68b50f22-dddc-0005-06ca-622f3a3a0ea4', 'e44e575c-135d-0006-5bae-085489cbb696', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('94ef111a-f1cf-0007-6544-24d72cc39a2c', '68b50f22-dddc-0005-06ca-622f3a3a0ea4', '7526effd-5575-0006-4b12-bba489538263', 3, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('67104cf5-6bb7-0007-4c8e-a8b377c84e8d', '68b50f22-dddc-0005-06ca-622f3a3a0ea4', '95623388-791f-0006-aac5-7ce51887876c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b0d59635-c7ba-0007-cf6b-49ec2ce9be29', '68b50f22-dddc-0005-06ca-622f3a3a0ea4', '99357ccf-ed73-0006-03f8-c5d7c22911b2', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1d96b322-acba-0007-54b2-29ff8d557555', '68b50f22-dddc-0005-06ca-622f3a3a0ea4', '733b8d31-f7dd-0006-a386-88c38d3814df', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;


-- ========================================
-- NY International FC ROSTER
-- ========================================
INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b6ecc33c-a96b-0007-6d91-cd213edc2410', 'c99ade72-80a1-0005-bb2a-e36057334cac', 'da11023f-75d1-0006-31ec-5f8725c570f8', 6, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('97804626-9d99-0007-9caf-e2391dd24ec8', 'c99ade72-80a1-0005-bb2a-e36057334cac', 'a0b93ed1-0371-0006-0019-02f58a70793b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('fa838a85-da31-0007-0ef6-f21da5a36de1', 'c99ade72-80a1-0005-bb2a-e36057334cac', '6a0674ac-94f3-0006-a9a5-9c94612b911b', 3, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c15211c9-6172-0007-442f-5fc9b267363a', 'c99ade72-80a1-0005-bb2a-e36057334cac', '08634319-2781-0006-dfdb-6fd18e60fc06', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3da8f29e-609a-0007-68d5-01e279c89d3e', 'c99ade72-80a1-0005-bb2a-e36057334cac', 'c2780cd9-2043-0006-11f1-042bb40eae9d', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('dfbdfdf6-bfdb-0007-3bde-5bc6e48ed52e', 'c99ade72-80a1-0005-bb2a-e36057334cac', '4d2f1838-300c-0006-617f-04debd1eb0c6', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7721f153-8bdb-0007-dff9-5710165cc63a', 'c99ade72-80a1-0005-bb2a-e36057334cac', 'f4be107b-41e5-0006-1de2-23992501bc4c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('238298a6-b276-0007-c521-8829939cde99', 'c99ade72-80a1-0005-bb2a-e36057334cac', '9f8e5d31-a1f0-0006-a234-3344918bd80f', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('fddea67b-e010-0007-e6b2-8a34aa227dd9', 'c99ade72-80a1-0005-bb2a-e36057334cac', '7d345240-5184-0006-3a30-17c55cabe0a3', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e623475e-e4fa-0007-d75c-756fc735c434', 'c99ade72-80a1-0005-bb2a-e36057334cac', 'f4db866f-e2e1-0006-f1d7-878a45e9e6a0', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7515c56b-cd63-0007-0b10-fa28f46dcb8d', 'c99ade72-80a1-0005-bb2a-e36057334cac', 'cd0ab36f-22a6-0006-f49b-ae71ee5f279b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('43c4baa3-1f3e-0007-0b46-1cc5a6726a04', 'c99ade72-80a1-0005-bb2a-e36057334cac', 'b8347f17-2aa3-0006-05a7-6e06d27bf528', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2bbfcbed-f0d7-0007-41bb-94a59342f4b4', 'c99ade72-80a1-0005-bb2a-e36057334cac', 'c9243d59-0f6a-0006-085a-af39bee83bb7', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('76877f07-1910-0007-7f60-d83498a7a5f8', 'c99ade72-80a1-0005-bb2a-e36057334cac', 'ee7e4197-801a-0006-2112-d89d75e5b13b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('83a574e1-278f-0007-bd45-afeb570ec649', 'c99ade72-80a1-0005-bb2a-e36057334cac', 'b3726b38-086b-0006-301c-91d24e5cfa80', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c06b3cc0-7d0a-0007-424b-94a897593049', 'c99ade72-80a1-0005-bb2a-e36057334cac', '0fe80dea-a7da-0006-12a8-61e8e623d47d', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d09b4b36-243e-0007-6a55-df729bd20053', 'c99ade72-80a1-0005-bb2a-e36057334cac', '93863025-3322-0006-c9d4-cffc6653cb4c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2308da15-e166-0007-45fa-0cfa34984be9', 'c99ade72-80a1-0005-bb2a-e36057334cac', '3b2c6fa5-2920-0006-d424-57fb89ad4a05', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e4cbc000-d4af-0007-0706-d917cfa5174a', 'c99ade72-80a1-0005-bb2a-e36057334cac', '91708f14-86aa-0006-9f16-1893bf050cda', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('50955a01-9b2f-0007-e8b0-83376284e62b', 'c99ade72-80a1-0005-bb2a-e36057334cac', '5272fa1c-7995-0006-2dc6-e45bf6200869', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('392b4252-1531-0007-4a83-c20173250151', 'c99ade72-80a1-0005-bb2a-e36057334cac', 'ae03dfad-1bde-0006-8220-e144a12d7fa2', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('28d571f6-fb09-0007-5e01-d9f5bd50893f', 'c99ade72-80a1-0005-bb2a-e36057334cac', '5ae84ac0-8c22-0006-139e-955db58f24c9', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('fedd9fb0-9f27-0007-829e-7ac4852aa426', 'c99ade72-80a1-0005-bb2a-e36057334cac', 'aaa0b7d4-af86-0006-687c-0afc97197b3c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1e2b2331-99fe-0007-4c1c-d7c365250420', 'c99ade72-80a1-0005-bb2a-e36057334cac', '900b1ebd-3e5d-0006-95b5-c0564c3f1ccc', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('fe8665bd-0429-0007-ffea-7dee6289efc4', 'c99ade72-80a1-0005-bb2a-e36057334cac', '4096ec7a-118b-0006-d968-3e19aa35297c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f7eb4d64-ec4b-0007-9acb-98dca7b5161b', 'c99ade72-80a1-0005-bb2a-e36057334cac', '03d5af41-d440-0006-db41-25dabf295dad', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2e5f08df-ecf3-0007-4107-813cbbb40b72', 'c99ade72-80a1-0005-bb2a-e36057334cac', 'e6db93de-0ef0-0006-ea37-fd688fefc784', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('846f2339-e16e-0007-5a73-edc7ba32b82a', 'c99ade72-80a1-0005-bb2a-e36057334cac', 'c09a46ce-a1c6-0006-f7c8-d913e187a126', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('116e08cd-7aab-0007-1146-7ab8db357dfd', 'c99ade72-80a1-0005-bb2a-e36057334cac', '2be3d446-3985-0006-8c50-20605dba15ea', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('eedaa342-49f6-0007-488c-7d1f23eabb38', 'c99ade72-80a1-0005-bb2a-e36057334cac', 'e81d75ce-30f8-0006-62b6-720544945cd2', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('8a6ce06c-96d1-0007-99f7-84fd94897eab', 'c99ade72-80a1-0005-bb2a-e36057334cac', 'a3f32d5d-d1b9-0006-5597-d51d7e92fdd4', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c3d8338d-edc4-0007-d949-cee2791c9e4e', 'c99ade72-80a1-0005-bb2a-e36057334cac', 'abcbec62-7b44-0006-3fb9-3e6f2a7ed0ed', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('037c22f2-1806-0007-64d2-bb5b35dbbded', 'c99ade72-80a1-0005-bb2a-e36057334cac', 'b42b069b-4f25-0006-644c-961801f01d60', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2c376bec-1d2f-0007-865c-e762ca52ab57', 'c99ade72-80a1-0005-bb2a-e36057334cac', 'eb107333-7818-0006-7d4a-0451d6408b9f', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3ffe4012-9dda-0007-dcb7-da9714bcb298', 'c99ade72-80a1-0005-bb2a-e36057334cac', 'cc6680ef-4e03-0006-49bc-843fcb3d6dd3', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4b437c68-8ac1-0007-df13-6d09d472fca5', 'c99ade72-80a1-0005-bb2a-e36057334cac', '4bf1185a-5255-0006-bd54-555b7146fa45', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('96a668e3-b554-0007-3725-55eec81873e8', 'c99ade72-80a1-0005-bb2a-e36057334cac', 'df468722-4b96-0006-601e-58502ac14f08', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('61155651-2300-0007-79a5-3db5e81d9fb8', 'c99ade72-80a1-0005-bb2a-e36057334cac', '4f3b2d52-0dcf-0006-0641-0ecd2df7faea', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;


-- ========================================
-- Richmond County FC ROSTER
-- ========================================
INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('6fac2bd3-53d6-0007-a10d-7b22921d247c', 'bad8aee7-4cea-0005-8995-4a25b932936d', 'bce1161c-8a20-0006-c0d0-95b6c66eeeb3', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3dab96c6-2f0e-0007-480c-363f84758e22', 'bad8aee7-4cea-0005-8995-4a25b932936d', 'e485bb60-e873-0006-bca7-63763ea70cd3', 3, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1af3b195-7121-0007-a99e-de8bf5c2135c', 'bad8aee7-4cea-0005-8995-4a25b932936d', '8c7d4b82-ae75-0006-396b-2e68ecd51e28', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('940849de-1e3a-0007-52bb-9160c7a8caf2', 'bad8aee7-4cea-0005-8995-4a25b932936d', '7e777131-a30d-0006-d1c6-1b14c183ce4f', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('fe137bb3-510f-0007-2f20-afa947226660', 'bad8aee7-4cea-0005-8995-4a25b932936d', '0b80437b-f9d9-0006-9d55-84ad74e321ba', 3, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('798a9eaf-ca5e-0007-d19e-e9d4c302b917', 'bad8aee7-4cea-0005-8995-4a25b932936d', '8beeea2d-7b6c-0006-1628-f3b2815c5c02', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('504fffd3-001b-0007-8858-1c3881999682', 'bad8aee7-4cea-0005-8995-4a25b932936d', '287a050f-094b-0006-ccec-08c2669d1d4b', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('5082f4f6-f7c5-0007-0724-614d17c7b55a', 'bad8aee7-4cea-0005-8995-4a25b932936d', 'd99f371d-90cd-0006-72f1-85fac4052ece', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2f5870d7-bfbb-0007-9047-57b9a73cf83e', 'bad8aee7-4cea-0005-8995-4a25b932936d', 'dbb797c4-0df7-0006-5c6a-01944c09e188', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('28df2a69-74d8-0007-020b-7fcf2a3b2f6a', 'bad8aee7-4cea-0005-8995-4a25b932936d', 'f25d0c35-a284-0006-e480-317e1eb03217', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3c51e78a-de52-0007-2a9b-ad2127b328e3', 'bad8aee7-4cea-0005-8995-4a25b932936d', 'aea90e37-c643-0006-376d-a3c5e6c8b432', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('596a588e-c878-0007-3003-9ad8edb1e4aa', 'bad8aee7-4cea-0005-8995-4a25b932936d', '7df3844d-8dd6-0006-6d5f-7dfac0f54ecd', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('fc23d812-8dd4-0007-3c1f-d8d55aab5ff5', 'bad8aee7-4cea-0005-8995-4a25b932936d', 'b27dafc4-a86b-0006-5e3f-3e455b109671', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('813caf32-c13f-0007-e3ee-182f4be47481', 'bad8aee7-4cea-0005-8995-4a25b932936d', '21c6e29c-5af7-0006-258a-1d25ec801ff3', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1d8dce8d-defe-0007-beef-55807cc5a3a5', 'bad8aee7-4cea-0005-8995-4a25b932936d', 'e0adf473-fe6d-0006-7294-233eb2365fbc', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b43a9384-0f32-0007-f00c-a97f46dbd3d9', 'bad8aee7-4cea-0005-8995-4a25b932936d', 'f9dcfd4b-bfa1-0006-7611-9be226bdba33', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2061a477-c3f6-0007-2175-229a9c75cbe1', 'bad8aee7-4cea-0005-8995-4a25b932936d', 'acd787f5-aa56-0006-8da8-8344e205a251', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2e1bdab1-7561-0007-e2e1-560af31660d4', 'bad8aee7-4cea-0005-8995-4a25b932936d', '0f64c776-35e1-0006-64c9-6c93a2cd1832', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('97258136-af63-0007-2840-d4ff9bbd5278', 'bad8aee7-4cea-0005-8995-4a25b932936d', '2dce9028-0149-0006-594f-429575a87a2e', 3, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('06cabd21-1071-0007-954d-32fa654f37ef', 'bad8aee7-4cea-0005-8995-4a25b932936d', 'e22ef105-39cb-0006-b5e2-153fa15f1d25', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('96b32bcb-4c89-0007-a766-028849b8061a', 'bad8aee7-4cea-0005-8995-4a25b932936d', 'da40f677-135e-0006-5a50-eb52bc0b4430', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('6e7152dd-e9cb-0007-73bd-eaf8f8a6da0a', 'bad8aee7-4cea-0005-8995-4a25b932936d', 'f196192d-1511-0006-529c-b35d76c429b3', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('8e8fa474-e937-0007-f9d6-3bef780ff229', 'bad8aee7-4cea-0005-8995-4a25b932936d', 'f8ecceba-6f7b-0006-b174-8f6bd4b0c533', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d1583899-b5e8-0007-413d-19ab7172aa65', 'bad8aee7-4cea-0005-8995-4a25b932936d', '28fd501f-630e-0006-5824-6c22ac2bafc7', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('6fb1a389-c20a-0007-6947-7dceb8a65a7d', 'bad8aee7-4cea-0005-8995-4a25b932936d', '10249ce5-05d1-0006-0776-8926a01291bb', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a5b5900e-bedf-0007-ab20-73bd631d49ff', 'bad8aee7-4cea-0005-8995-4a25b932936d', '53b61c25-83f8-0006-588f-4439c483b14f', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a2fe420f-b36a-0007-986a-390999b2dfae', 'bad8aee7-4cea-0005-8995-4a25b932936d', 'b2aa37b8-b942-0006-c9b0-08c69bd71116', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('96dc4634-e4f3-0007-bc2f-1c5c14243249', 'bad8aee7-4cea-0005-8995-4a25b932936d', '2de3d2cc-16dd-0006-7349-f11e1d8abe77', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4d1e4530-81ad-0007-b00c-74db4f79d8a5', 'bad8aee7-4cea-0005-8995-4a25b932936d', '5957a3f6-b96c-0006-227f-3eff7b8a9171', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('fae21057-7780-0007-3866-065e0ae2fa19', 'bad8aee7-4cea-0005-8995-4a25b932936d', '971cd727-111d-0006-d68c-1df8069ee8f1', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('12afe123-604b-0007-e07a-b0d594fb5183', 'bad8aee7-4cea-0005-8995-4a25b932936d', '41d9d017-e552-0006-32dd-f4da36bceace', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f6f12544-5e54-0007-bde7-54b255463762', 'bad8aee7-4cea-0005-8995-4a25b932936d', '3cea49a3-cbe8-0006-36f7-2e2850a8304a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b690fbb2-86b3-0007-661e-98588420c88d', 'bad8aee7-4cea-0005-8995-4a25b932936d', 'fd4aaa73-51cb-0006-dd76-41e8170e8901', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('82212a4b-2ac9-0007-2980-b4295cc0d534', 'bad8aee7-4cea-0005-8995-4a25b932936d', 'b9f831be-2af6-0006-597a-108e95db60f6', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7ba2dbb2-329d-0007-f5c7-5ca2cfa3fc94', 'bad8aee7-4cea-0005-8995-4a25b932936d', 'ca787b8d-9fa4-0006-1d9b-2c9386b04b5c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;


-- ========================================
-- Zum Schneider FC 03 ROSTER
-- ========================================
INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('bbeb2eba-392f-0007-ff28-98c74c4c126c', '5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34', '49c3a3a1-574c-0006-614d-dda5233ffa63', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('aeda56ff-346c-0007-d5cb-ba9fc24bdfcb', '5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34', '76877460-9405-0006-21f2-54b9e1c25045', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a915289a-f3a4-0007-a85f-888126411f37', '5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34', '19a21d5c-9974-0006-01e0-3c18768f7de7', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('5a6b9a31-b594-0007-db35-07752c3727a5', '5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34', 'c10629cb-3295-0006-14da-5ea2ab2f05ec', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1823a509-385e-0007-9b92-452738c88b3b', '5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34', '078bba28-5537-0006-bf21-78ab7580545e', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3379cdc1-8615-0007-306d-95a16722eb7d', '5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34', '9eeb251b-70cf-0006-0f36-b7b55b09448c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('642b4deb-3eb1-0007-192b-045ad1f12539', '5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34', 'bcea2412-8f7d-0006-3fd3-9dbb4726db23', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('efcc151f-59f7-0007-c559-212ecff8ad23', '5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34', '22174273-ed2f-0006-3d69-e3406836c4d9', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3b3fd6be-1110-0007-0cfb-6ed49ac91a02', '5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34', 'b6924d73-37de-0006-2267-13682493f9fa', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3a868544-d3ae-0007-4003-77a252c8b9ca', '5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34', '02a45a5f-37ad-0006-8cd9-9f18754af64b', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('248b48d5-bdae-0007-0175-c3a3df27e606', '5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34', 'f40824e5-0bc2-0006-7499-9dc0d2d4e044', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0de88b95-43c2-0007-5a9f-cdd74f13d225', '5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34', 'd5a40e0a-5b95-0006-89a5-aab3b10298d6', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1f6f5bb9-ea6f-0007-c7c3-b3c3cdda633b', '5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34', '40c14827-209d-0006-6aa2-204d9f8623a7', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('db1bc5ec-68e6-0007-09dc-b4e1131bc7e7', '5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34', '785224fb-086d-0006-9237-706419cd8767', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('21c32a38-9942-0007-793e-a44db3ec466e', '5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34', 'b9b61877-eb8d-0006-0f43-8352cc3face7', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('195de3ee-2b50-0007-9bde-cfdc590c137f', '5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34', '4aa9360b-92c0-0006-8887-c1935e7a0738', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e6654ea1-47ee-0007-9b3e-87af732e7541', '5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34', '6128cd53-4dcf-0006-ce08-eaad819a7fb4', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a2470d49-8256-0007-6d49-708da44d3409', '5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34', 'fe670433-3fb3-0006-a064-98cb336bb46a', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f8f41b1d-ff86-0007-8792-fdced341c1ea', '5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34', 'd367d0f1-232f-0006-fc14-0dcab7c29330', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('33bf9aac-0b9a-0007-3eaf-940e26c2b638', '5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34', 'ab08f853-6ea2-0006-f2e3-e6b4d49b539b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('301a5b4f-6afd-0007-227a-c169a1fdcd46', '5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34', 'db262a89-1b94-0006-95ca-89715dab850c', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('479c7433-cb1f-0007-6735-d5bbfbd38966', '5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34', '00ea6a8e-3545-0006-271a-5ad09a1f0abf', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('6d90d7eb-77af-0007-25a9-cfcea2fd7ad3', '5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34', 'b2b8090e-a6eb-0006-8e39-359e41a7b097', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('796a2cd3-7211-0007-1ce0-c23db6488c1d', '5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34', '7d44aa99-7614-0006-da89-abdb7b5a2ca1', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('fd42bf03-e7a3-0007-54b0-be2ab54fd757', '5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34', 'e8990e9c-5426-0006-a8a5-9a8d72e894ea', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c1c54419-8295-0007-5244-ca29938f3d02', '5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34', '51d5d67e-6556-0006-7e55-1e3086afbedd', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('360ba0f2-e77e-0007-40a2-4dcc5a5f9451', '5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34', '80f7e57a-c7ca-0006-06c0-227c75724030', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1c9d7fe7-ef88-0007-3792-519fd07753b5', '5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34', '0a039ea1-dc67-0006-01d0-280bfe57a233', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9ca71957-f15d-0007-b51b-22a08b3a46af', '5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34', '4f9c1a37-70d2-0006-8910-85ca9fafcef3', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('05cceb5c-ca83-0007-1011-97c938f484f8', '5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34', '971f1615-30bc-0006-8c44-0c4aa4aabba5', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('6974036c-0ba7-0007-b702-04ce2658c4a6', '5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34', 'd8683cfd-50b9-0006-1627-7d5a28d65c15', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('476b5c08-cd40-0007-aec7-16cb75f828bc', '5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34', '8437099b-1363-0006-371c-65b5b6f737c6', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2c412134-c4d0-0007-26e5-7d604b82faea', '5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34', '73473ad7-30f2-0006-3739-85cd61eccf2b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b13430ff-d3cf-0007-bc1c-9307ae5cbf35', '5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34', 'ff2cd3c5-3806-0006-50c1-505b0a8faf9b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f0186fda-901b-0007-0d20-50b27f04f60a', '5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34', '94c15fb3-06da-0006-1cf1-2fbe68fcb74a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('01717200-99b9-0007-85ed-c3f069d01ca9', '5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34', '5629afc8-5aca-0006-ace4-95e66613719a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('6922707c-d1f1-0007-4766-512114f01851', '5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34', 'be318990-e936-0006-d560-86a007610418', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('de29e7d3-ef93-0007-9dbe-b50e6c4b40d8', '5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34', '8c8c0782-7447-0006-dde9-53e926ea773b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b8c16f41-7134-0007-cfba-1c39f0c9d441', '5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34', '6633acfc-5236-0006-75e8-dd996453d84c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('91ed9ea3-9c92-0007-9d42-fe76e603ee1e', '5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34', '039abdc6-5af2-0006-54a3-cc5235454322', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a73ecc48-93db-0007-9dbe-c517fc238f07', '5951a8c4-ca8a-0005-8cb6-0cfaa8ed8a34', 'fb1ca8eb-808f-0006-46e9-98af456c584b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;


-- ========================================
-- SC Vistula Garfield ROSTER
-- ========================================
INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('cc1d721f-294b-0007-1211-a6b16fc01f75', '741624af-fbb6-0005-5186-2697c8c058e6', '3f3733e7-657f-0006-0e24-cf9ff3f0d0fa', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('06faad85-ac65-0007-3ef9-b0780b44354f', '741624af-fbb6-0005-5186-2697c8c058e6', '5d4de7c8-3d9a-0006-9cc9-fa85928a7164', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('63c6597e-a8f8-0007-44d0-111d04d46c70', '741624af-fbb6-0005-5186-2697c8c058e6', 'c8800a92-b539-0006-192b-1ddffe904d4c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('398586f6-838f-0007-b87a-8ef8b8c05f56', '741624af-fbb6-0005-5186-2697c8c058e6', 'ee7b0564-1987-0006-df37-e8f7b5f9dd76', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e11af05d-0e6b-0007-588d-c3d688b8fea7', '741624af-fbb6-0005-5186-2697c8c058e6', '18fd44e9-26b7-0006-049a-959bd6819e24', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9e246e9f-a58a-0007-d997-49800cfa1bf7', '741624af-fbb6-0005-5186-2697c8c058e6', 'a1d48fd8-87cd-0006-b41c-5a9298f76871', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ad90fedc-67c1-0007-69b9-9c6e8773e9c0', '741624af-fbb6-0005-5186-2697c8c058e6', '3f6cfe4c-d473-0006-63b6-2361a70149e2', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7360eed6-9753-0007-01ea-1dea3a0eb285', '741624af-fbb6-0005-5186-2697c8c058e6', 'd5ac0372-aa40-0006-2590-f7318d99bcce', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9689b3b8-4148-0007-94d8-29566ae023c2', '741624af-fbb6-0005-5186-2697c8c058e6', '31cf0a9e-12de-0006-a6fe-fa064ba8cb10', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4076bf31-3459-0007-b77d-cc1d8ee964ba', '741624af-fbb6-0005-5186-2697c8c058e6', '0910c7ca-7a43-0006-4244-2bd46eacedee', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f02767fd-cc6d-0007-10af-f416fa9e6d10', '741624af-fbb6-0005-5186-2697c8c058e6', 'a1b59e16-e6df-0006-15a9-27edaa41d6bc', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('be706af4-615c-0007-e2a4-7a4261a3ffbc', '741624af-fbb6-0005-5186-2697c8c058e6', '56efd39a-9a30-0006-6460-837eca786e62', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c372e287-0c36-0007-a5e8-76dc20b16f36', '741624af-fbb6-0005-5186-2697c8c058e6', '21bdcefa-10df-0006-06ff-9eaf90f68733', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ecf0ac7d-366c-0007-7447-dc5406add4f0', '741624af-fbb6-0005-5186-2697c8c058e6', '782d35a8-d9da-0006-3f41-70c449e58d4b', 3, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('6c8d5135-e962-0007-67b9-e0cbe19ad67a', '741624af-fbb6-0005-5186-2697c8c058e6', 'ccbdfeb5-1e21-0006-1246-f1359776c8aa', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7f767d9a-8a3d-0007-39d9-ac0b11730ed2', '741624af-fbb6-0005-5186-2697c8c058e6', '78bc5527-3031-0006-caeb-56e915e6a0d9', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f790a42a-5e1c-0007-5118-e9010a57e7c5', '741624af-fbb6-0005-5186-2697c8c058e6', '895dae53-ddad-0006-d28c-f016c5bb511f', 3, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f9db8d9b-a3f8-0007-1d81-e36cfbe74fa0', '741624af-fbb6-0005-5186-2697c8c058e6', '7a21ec10-1a2f-0006-e404-93a5ffb92593', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('fe15d51d-41a4-0007-2689-71274e70ef30', '741624af-fbb6-0005-5186-2697c8c058e6', '47b018da-72df-0006-6037-a51843d19e84', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d0a3b126-df1b-0007-5344-f9855ac3b0d5', '741624af-fbb6-0005-5186-2697c8c058e6', '1c3783c6-bdca-0006-3ac9-65682be5e4db', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e82f47a3-5dd4-0007-c01b-b7f8b61d60c6', '741624af-fbb6-0005-5186-2697c8c058e6', '7fcb56e5-35da-0006-93db-2ebc97d0418a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('320ca5ac-e4e1-0007-34ae-9f28199ff514', '741624af-fbb6-0005-5186-2697c8c058e6', 'ecf7a8ef-b691-0006-9b3c-f2bb27ec8829', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('dcf471b0-d135-0007-068b-ea8e8ddb19b9', '741624af-fbb6-0005-5186-2697c8c058e6', '86300470-6cda-0006-8570-a0807605134c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('22084776-112d-0007-98ea-18f7ef7f0019', '741624af-fbb6-0005-5186-2697c8c058e6', 'b93c06bf-4171-0006-e850-ab4fd6ea9a68', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('96597c0f-6802-0007-85c7-19fb40f7ea5b', '741624af-fbb6-0005-5186-2697c8c058e6', '807a6936-b907-0006-f97c-ea276db8d942', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('6dbbddf1-8125-0007-108f-73d49bb76d47', '741624af-fbb6-0005-5186-2697c8c058e6', 'e70c8183-460a-0006-d92f-a24a40fbec8f', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('5755f6bb-dc6d-0007-67f6-ca146ce69751', '741624af-fbb6-0005-5186-2697c8c058e6', '01de1cd6-c809-0006-e0a7-f06314e40991', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('66f223ef-15d3-0007-ee2c-0d09dce808e6', '741624af-fbb6-0005-5186-2697c8c058e6', '67324332-16ad-0006-8dfd-3be7f08de349', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('13ed2b50-bd41-0007-20fc-00acf757967c', '741624af-fbb6-0005-5186-2697c8c058e6', '7a382673-a77c-0006-23de-562d8868122b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('6bb638dd-fe10-0007-f858-19cb00622e4c', '741624af-fbb6-0005-5186-2697c8c058e6', 'ed105191-f1e0-0006-7616-da426caa21c9', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('bd7157bd-91b2-0007-2839-1139b8b010f3', '741624af-fbb6-0005-5186-2697c8c058e6', '4020ae27-181e-0006-29b3-21dfc09e6e18', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c64d6b39-20df-0007-76a3-c1e4e752f0cb', '741624af-fbb6-0005-5186-2697c8c058e6', '8791a6a4-41ef-0006-a249-a284f3a9aa48', 3, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('82f13f25-8dbd-0007-2f08-294b870f793b', '741624af-fbb6-0005-5186-2697c8c058e6', 'c5caf3a5-b03e-0006-0096-b53a64d135a4', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('02a91493-1cbe-0007-5bc9-912a29ced9af', '741624af-fbb6-0005-5186-2697c8c058e6', '30793206-aca9-0006-6d1c-107456eda201', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('645693bd-637f-0007-16b8-5ce52194a4fc', '741624af-fbb6-0005-5186-2697c8c058e6', '3a7f7277-fcd2-0006-ed5d-1c567ef5045e', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('31c790a6-d5e0-0007-08ab-2e2951385013', '741624af-fbb6-0005-5186-2697c8c058e6', 'e5bc7598-0a1a-0006-02f9-2fb99c94386e', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('84726bff-95e3-0007-2f5d-02fbc492c338', '741624af-fbb6-0005-5186-2697c8c058e6', 'f150be8f-7b35-0006-fc41-fc0667884a98', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a174e665-551d-0007-da66-4d3759cf4422', '741624af-fbb6-0005-5186-2697c8c058e6', 'b215972e-ce8c-0006-5b41-36fd5385a491', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('8587f48f-30f8-0007-dbae-7db7d8c1237a', '741624af-fbb6-0005-5186-2697c8c058e6', '3bfc9c8e-200c-0006-dbb3-aecfe4e5acdf', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4f01cc2d-8ef2-0007-33c0-b9bbc8ea1569', '741624af-fbb6-0005-5186-2697c8c058e6', '897431e9-f88a-0006-e564-471e85555182', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('992da4a1-32ef-0007-52ec-790a0c01503e', '741624af-fbb6-0005-5186-2697c8c058e6', '4b338326-9839-0006-0fed-e87a8cd60e03', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('18bcebf3-71e7-0007-9d99-5362e01df71b', '741624af-fbb6-0005-5186-2697c8c058e6', '5cf381b9-e911-0006-72d7-497ffb00919e', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9258954f-1557-0007-d770-3553bb4c4065', '741624af-fbb6-0005-5186-2697c8c058e6', 'f0a6f957-b179-0006-58cc-37d9001b4100', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('60dc1028-1a35-0007-cc95-0b67fde01917', '741624af-fbb6-0005-5186-2697c8c058e6', '94696aee-2fab-0006-27a0-97e67db0601a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('822f80ab-ea7f-0007-caba-8afa344b2e27', '741624af-fbb6-0005-5186-2697c8c058e6', 'e2191327-bf13-0006-2977-991710192c29', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3e842361-3b5d-0007-9522-8d82e8731a8d', '741624af-fbb6-0005-5186-2697c8c058e6', 'ce1534ec-dfcc-0006-f2f6-759520cd9c1c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('db473dba-eaab-0007-4441-13507c35a55b', '741624af-fbb6-0005-5186-2697c8c058e6', '673f66f4-a2fe-0006-aa06-6bc5b95e352c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;


-- ========================================
-- NY Athletic Club ROSTER
-- ========================================
INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d10d0d80-6371-0007-5d5b-242b51464775', '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', '424aa738-9a99-0006-07f1-afd4796d44e7', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1ee23561-2643-0007-3143-107082a89df1', '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', '4facf928-18fe-0006-01bc-be92f391c06b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b769dbc8-19de-0007-156d-3e4fa90b6d32', '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', '8b10ada8-4aea-0006-52d4-7bc16fd93d53', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('26d958a7-0604-0007-db6a-e6d5bc4f7aa3', '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', '0dd2b243-5b0d-0006-71ef-0599cb8ca0fa', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a8aa6a5c-199b-0007-d49b-49d7e37917aa', '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', '5a358224-ba04-0006-2d21-0af9ac4e2f39', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('5ea7eb5c-71bf-0007-1d85-58df3d2b6df2', '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', '16f96f66-54cd-0006-9a4d-10d9fa94dde9', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('fb73cb10-00da-0007-d715-9fca9f9a66a1', '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', '18e3aaad-b08e-0006-b5e1-7413d805fd35', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('cc8ade51-28f7-0007-2713-b36bea323dc2', '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', '3aad862a-a0e4-0006-faa0-7bd7be16f4da', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('451f7652-d741-0007-c921-5e5df01e1262', '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', '95f064c5-f725-0006-8f09-cab36284516c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('37a7ed42-1908-0007-108b-8d1252d23a0c', '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', '26967907-e703-0006-5f9a-2a25c57d4d46', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a5c83b62-c6ce-0007-0613-9420a9cf26ef', '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', 'b946b12b-cfff-0006-254a-6bb70d5a4122', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('560c281d-4599-0007-0037-061826a7d253', '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', 'dd882c44-0d60-0006-d0be-366d480388fa', 3, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0d87ab80-5fbe-0007-09f0-0b294e1cd5cb', '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', 'b155a0c4-7b1d-0006-7522-3f5e75a4f1c7', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3739c06f-e803-0007-ceec-0670fd6bc78e', '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', 'cd066a82-4806-0006-2e80-9392fae48ad6', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e8a01259-dc48-0007-6b1b-6027361289c0', '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', 'd0bb1d8b-2d88-0006-425a-cba7604cccf6', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('84fc1cd1-017b-0007-c8d1-7ef3c920b356', '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', '43550c1f-ebee-0006-7a52-62f5c95f5482', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('24267941-a05e-0007-bc94-4d13b174dee9', '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', '7aef160c-eaf2-0006-f671-8485b9437a57', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('53b18ca2-a162-0007-bad9-afc7903d4509', '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', '89cdfd6c-d787-0006-d900-491e7ce24064', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('07a735e2-54ec-0007-27e8-7e3c88b67d97', '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', '0cfae6e2-c65b-0006-aa6f-6fbf00f42df0', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c942fc33-4967-0007-db44-0f2cf116f0a2', '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', 'eb9c3771-5d7c-0006-5f30-8ac16610de94', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1c968401-8763-0007-1201-2994693e4b4a', '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', '648e0435-0fef-0006-9f01-2453924d5327', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('94cf738c-d957-0007-3be8-30ab1dd63297', '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', '4a3c8d2a-51af-0006-aa71-61202c127768', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b2ae7e6d-8181-0007-6d58-b37ae5c1cf41', '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', '322981c0-1fe1-0006-dd98-91f8eaaec451', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a24c547c-b8f2-0007-e13f-e22ee96f8d35', '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', 'a4cd1fe6-b5a5-0006-060f-e4ba3e5bbf88', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('11cbd2d1-2770-0007-7507-6e8ebed34f8f', '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', 'd1b3680e-ebf9-0006-9f5b-e06dbf0b1606', 5, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7e06f3f0-12f3-0007-15b3-f770c99d1aaa', '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', '3cf2ea8e-c9ec-0006-f0e4-0903b7189ce3', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('cf21ca62-0df6-0007-f764-99b132899b8e', '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', 'f2eb412d-cd5f-0006-31dd-f288cdc65d05', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('59c98ba5-e6cf-0007-9a80-38794d6b7f31', '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', 'c4b69158-1295-0006-380b-9d5f50052611', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3f5043a8-c857-0007-f866-40a6746874d2', '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', '3e3322ca-d940-0006-f329-c8cbd23c60be', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('53acb701-0790-0007-6ca1-fa070ae22730', '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', '33ff1ee8-0488-0006-9ef1-ce5436ff921c', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b38dffeb-c0b8-0007-c221-6745489d002a', '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', '2ad4f0ec-6ae6-0006-6705-c122d3a28def', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('18a6e50e-52e3-0007-d543-01aa2a2d0425', '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', '19afdc23-6ed6-0006-962b-f6078457bf46', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f0749802-67e2-0007-4009-ce498118eda9', '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', 'bd5fcc93-54be-0006-632a-eb4a87111153', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9d4ce922-ecb5-0007-d09f-2b899ca55e88', '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', '6c593aa2-c9d2-0006-118b-a45da93ed968', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('5af0689c-3116-0007-eafc-c433cd9804cf', '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', '30471c7b-f4fe-0006-2daf-ff0aa57c8207', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('5b41cf50-e8a5-0007-8b69-23487c14115a', '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', 'b66fe0cf-00cb-0006-e270-e009e16942d6', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('168703a9-3eb3-0007-fa2c-c27851b012fd', '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', '77645e85-bc2f-0006-8c53-482252c4d6e3', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('55da52c7-739b-0007-8af7-3d40b408884b', '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', '8632a457-a762-0006-7340-657a7b3c58e9', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c073fb52-39a0-0007-6c6d-1b87c97ed9a1', '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', 'a0e5c989-25ea-0006-6d41-c906d5aa6e56', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('eeb1c789-460e-0007-8ac5-b471a7c21ab8', '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', '5056c009-3e27-0006-bd36-a76da19227ad', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a0d8bbfa-873d-0007-1f8d-5e2fde3e1386', '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', 'cf5fa5f5-9be7-0006-91fd-00cfb960370f', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a7560006-63e8-0007-b4d3-811bcdc7394e', '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', '8d8d2411-b126-0006-7ff9-66f00112ff5c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('5a0234ec-0733-0007-014e-245d60210bc7', '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', 'ce3861d2-3e87-0006-4ad8-ca93c2ef2804', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('586b96b1-3421-0007-6763-848ee4ab58e7', '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', '4e032211-f613-0006-d4eb-8f3d2213f370', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1030246b-dcb7-0007-2b81-292990f857ea', '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', '0a9556d8-0f8c-0006-cdcd-6664eacf55bc', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b3fde377-da17-0007-79af-c0bb8b01067e', '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', '26f2cb1d-cc63-0006-29f2-ed1b0ffc4b1c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('18cb736a-49c7-0007-8dc9-05a6055f2e39', '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', 'f4919dae-990c-0006-d5e4-e20d274b760f', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('44e313ba-b719-0007-06c3-1a84e8d598e7', '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', '8a329194-4c19-0006-cdc4-f36ed2c2faea', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('20da1e5f-ad4f-0007-c83a-a5c019b119a4', '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', '31452cc5-8845-0006-3734-b46cfb3793af', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1a1f1958-e888-0007-5146-bdcb0f7a1781', '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', '52f50f14-d44b-0006-5054-605a1c3b10cc', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ca175741-4e84-0007-ef4f-eda49a9948b1', '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', '76ef3f9b-803f-0006-e3d7-72e54f0c2141', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ec564483-6031-0007-d4f0-283e78d88449', '7fd5026d-e9e6-0005-c04a-3c9bdf5901b6', 'ae6b8570-672e-0006-92a9-c48683a9b732', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;


-- ========================================
-- Central Park Rangers FC ROSTER
-- ========================================
INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('5c414191-84c2-0007-7d91-567ea90e728e', '48a40f97-9111-0005-2e29-709bd3953df2', '6400a53a-c0b1-0006-c2c1-f06107272338', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3f764087-c4b6-0007-c00b-25f9dbfce531', '48a40f97-9111-0005-2e29-709bd3953df2', '4321140e-41f3-0006-2016-23c06cc59555', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c1b447e2-685e-0007-7038-c2791e9508fa', '48a40f97-9111-0005-2e29-709bd3953df2', '8ce5236a-2665-0006-3ac1-a727e3ea8299', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3dc4a1e3-1ef9-0007-0fef-8a5ecc493f45', '48a40f97-9111-0005-2e29-709bd3953df2', 'bdf66c42-99b7-0006-16bd-e883a6fa027e', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1128adad-ed92-0007-0294-09d3f9311840', '48a40f97-9111-0005-2e29-709bd3953df2', '909c8051-a601-0006-3b21-a4f4f60d56cf', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('aa89e492-425f-0007-77c5-1268c837fb4b', '48a40f97-9111-0005-2e29-709bd3953df2', 'ebf5c86e-f594-0006-ca66-af82c13adc03', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9dcece8a-484f-0007-b526-fe97a8e7392f', '48a40f97-9111-0005-2e29-709bd3953df2', '299ea506-ab3f-0006-079e-bff363d76130', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ce5b6dee-b030-0007-e2c2-9d17df89390d', '48a40f97-9111-0005-2e29-709bd3953df2', '4809998f-c160-0006-eadb-62d3159b9b84', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e77f11eb-bbdc-0007-0114-e18bbdef7647', '48a40f97-9111-0005-2e29-709bd3953df2', '97caf7ea-0c49-0006-48fb-474ee9b98fcf', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('13e171c3-8ee5-0007-d5f4-329df6c2ee4e', '48a40f97-9111-0005-2e29-709bd3953df2', '0d6325f7-952e-0006-a692-5239c5d09c23', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a475e30e-811c-0007-b7dd-e49c0c3e6274', '48a40f97-9111-0005-2e29-709bd3953df2', '59634929-83ef-0006-b2ee-558c0e43e7cd', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('df31094b-0e25-0007-2e66-52fd3f8830aa', '48a40f97-9111-0005-2e29-709bd3953df2', '4263e408-4561-0006-a2d8-a906585e185c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('059ceb04-1cae-0007-3268-14802a58ddad', '48a40f97-9111-0005-2e29-709bd3953df2', '7d6d06ee-6694-0006-521c-6497d921ea56', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('fe85113e-6596-0007-030b-09444aa81c07', '48a40f97-9111-0005-2e29-709bd3953df2', 'e6c42fb3-bd7d-0006-7672-3d1915509a2e', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('101372a6-b6d3-0007-80eb-ac292f7d2577', '48a40f97-9111-0005-2e29-709bd3953df2', '19138c23-bd1a-0006-33bf-096185790ea3', 3, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a9c4095d-2ae7-0007-e973-53f21d7a9968', '48a40f97-9111-0005-2e29-709bd3953df2', '70de6205-b31e-0006-2231-eca9806af0f9', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f19dc303-cf9b-0007-f345-9a2e8720fdee', '48a40f97-9111-0005-2e29-709bd3953df2', '90e689e4-0c8a-0006-ea38-c85229492500', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3c98dd00-4fc1-0007-3707-0bed4b2c04c0', '48a40f97-9111-0005-2e29-709bd3953df2', '4a35132b-ed78-0006-35b0-cc73a216abcd', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('744be9e0-6d81-0007-2aba-6ca3c6e2288a', '48a40f97-9111-0005-2e29-709bd3953df2', 'edf2fe1b-e561-0006-8856-a74938f2a735', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2ee91519-f684-0007-fcd4-8f7b4cb435c5', '48a40f97-9111-0005-2e29-709bd3953df2', 'a0926711-47b9-0006-0b99-23e5c63844b6', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9f3e3ef4-46e8-0007-b27c-cfca46f8a418', '48a40f97-9111-0005-2e29-709bd3953df2', '1040a9c0-2d96-0006-72b9-a56a1ed8dd85', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('179b1e4c-6c02-0007-a866-ea49915fa151', '48a40f97-9111-0005-2e29-709bd3953df2', '1d8c2a48-325c-0006-fca1-96ba294a5d04', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('927d76e5-422d-0007-b090-18a7a3282e6a', '48a40f97-9111-0005-2e29-709bd3953df2', 'fee01806-73fb-0006-ec40-e60461e53f22', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1ca8ca15-79fd-0007-1cea-81b6743f1b9c', '48a40f97-9111-0005-2e29-709bd3953df2', '77314a44-b988-0006-9617-9e7a0e61fd66', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1df9ffc7-445a-0007-9919-d55e200f2632', '48a40f97-9111-0005-2e29-709bd3953df2', 'b5d17042-4464-0006-c762-ec4e66379275', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('503a6529-0f17-0007-54bf-e9a185123755', '48a40f97-9111-0005-2e29-709bd3953df2', '913e8618-6262-0006-3674-3abdd9a89db4', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('6e7b46b4-e6de-0007-12a6-b0685c2f00cc', '48a40f97-9111-0005-2e29-709bd3953df2', 'f6ed8295-6ae4-0006-e301-49a4ef4f02fe', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d196ec21-3dd6-0007-2fa9-6678a838ca86', '48a40f97-9111-0005-2e29-709bd3953df2', '02071ec5-affd-0006-efc7-b35131388eb1', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2321f255-99fb-0007-efa6-c675bde466b7', '48a40f97-9111-0005-2e29-709bd3953df2', '6001a807-29e9-0006-7e2b-4e92d522ed9e', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ff2d3119-9e8d-0007-dc15-ad38e471b5d8', '48a40f97-9111-0005-2e29-709bd3953df2', '0c2a8623-c3b7-0006-fbed-f2c04867e4a9', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a784a4bb-ef5b-0007-de0e-2e81f657e50e', '48a40f97-9111-0005-2e29-709bd3953df2', 'f7d93c24-473a-0006-9a43-34971cec523a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3d7fc452-2db1-0007-8a5e-03e77c575a9f', '48a40f97-9111-0005-2e29-709bd3953df2', 'bbd66182-b0af-0006-3499-7ed040eb3aca', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('751958da-d482-0007-9f76-e23d8d4921a1', '48a40f97-9111-0005-2e29-709bd3953df2', 'e6b295ec-3d53-0006-eaf4-0db3d7663e1e', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('64221844-0705-0007-700a-07165c289410', '48a40f97-9111-0005-2e29-709bd3953df2', '266b5c1f-ffac-0006-e203-ca3800df58f9', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('86e75f24-cc77-0007-d91d-8845dd36cc33', '48a40f97-9111-0005-2e29-709bd3953df2', '874751e2-eda6-0006-9563-b52731fbd89e', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f75b99b8-7f1c-0007-f10d-244ae0e0a70b', '48a40f97-9111-0005-2e29-709bd3953df2', 'dac3dbb4-c206-0006-97b6-15e253b128e6', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('88cc05b0-29d3-0007-2c83-e3838d92b200', '48a40f97-9111-0005-2e29-709bd3953df2', 'ca1d95af-79dc-0006-c41f-4240f243d1e0', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e2bd78e2-2b73-0007-add8-a99676a54024', '48a40f97-9111-0005-2e29-709bd3953df2', 'a7801a4e-8f4f-0006-f313-01f7fc81d0d0', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b526b126-97fd-0007-b80e-97d494ad2536', '48a40f97-9111-0005-2e29-709bd3953df2', '7fadfa95-3ec5-0006-b93d-b0842ac2fdc8', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9bc7f47b-2cb7-0007-2749-00a12049d042', '48a40f97-9111-0005-2e29-709bd3953df2', 'd452a72e-511a-0006-0792-6d63151dd438', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d4c81303-945d-0007-d88d-4e0309477306', '48a40f97-9111-0005-2e29-709bd3953df2', '8b16ca48-948f-0006-9963-6ecdbe9f4f8b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a573c5c0-2ffa-0007-a0f5-82643a9a5bc9', '48a40f97-9111-0005-2e29-709bd3953df2', 'f83444d3-3d7c-0006-774c-4e26e20c2a1d', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('aad8dcd5-2982-0007-8be9-47d3b1f959ee', '48a40f97-9111-0005-2e29-709bd3953df2', '52f84ecb-dbdc-0006-b743-97a47fa22a59', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('70789083-a3a8-0007-5888-cef4348fdfdf', '48a40f97-9111-0005-2e29-709bd3953df2', '508b39c3-1168-0006-427d-fd04ab0e707f', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('29a3c743-0c34-0007-6edd-57f656a1aae0', '48a40f97-9111-0005-2e29-709bd3953df2', '64dcecf5-7b40-0006-13da-2d5717f2640b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;


-- ========================================
-- WC Predators ROSTER
-- ========================================
INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('454fea98-f1a4-0007-23e8-3433edc92400', '84a1029b-04c8-0005-5548-e180ad338d6b', '73e80cff-7b6b-0006-bb21-6322f3d274b5', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b41c6a97-87ca-0007-f4c6-82b50fc2a3ed', '84a1029b-04c8-0005-5548-e180ad338d6b', '5e3f4cca-bea8-0006-a670-46771038170f', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('414a426e-f4e5-0007-1122-e74a562c8e98', '84a1029b-04c8-0005-5548-e180ad338d6b', '77470338-c623-0006-c548-0aa3a6e330ee', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2d1288cc-4e8f-0007-238c-d3ed7be545c4', '84a1029b-04c8-0005-5548-e180ad338d6b', '0ab541cb-335c-0006-74a6-3d7ea57f27d4', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e7bad83c-0a94-0007-1c4f-87a36130705b', '84a1029b-04c8-0005-5548-e180ad338d6b', 'f141d474-787a-0006-d45e-47bc6736ffec', 3, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ef31aa94-88c3-0007-10f7-62fdc2f1877c', '84a1029b-04c8-0005-5548-e180ad338d6b', '147fb591-8d3d-0006-be4d-9c0dc25d4184', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('8fe0f2aa-2810-0007-92ef-2fbe55277c81', '84a1029b-04c8-0005-5548-e180ad338d6b', '72e5127a-0420-0006-195f-ba747905cb41', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('8b68ed5f-860d-0007-63fe-60b945ebedf8', '84a1029b-04c8-0005-5548-e180ad338d6b', 'a0860460-a8d9-0006-485b-c66645a15db5', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e3e861f7-1c44-0007-50e1-533a038dbacd', '84a1029b-04c8-0005-5548-e180ad338d6b', '8e26679f-a4e5-0006-f878-c76a25672fb7', 3, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c26dcfae-4073-0007-426a-3938feb2ee76', '84a1029b-04c8-0005-5548-e180ad338d6b', 'a836e83f-94cf-0006-8043-2d8885a74c04', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('dd76b6cf-12cd-0007-236c-6ce5dcb4e147', '84a1029b-04c8-0005-5548-e180ad338d6b', 'abccd0b4-b8fd-0006-0d6f-bc1f68a9dca2', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('262ad076-2525-0007-4b6a-fbf0b3f9460e', '84a1029b-04c8-0005-5548-e180ad338d6b', '21a198c1-c1be-0006-5275-35e5e2d03bb3', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('68435d21-7036-0007-76c3-de90ed110596', '84a1029b-04c8-0005-5548-e180ad338d6b', 'f236924a-f93c-0006-0133-9296ae3556e0', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('42e7f1c8-463b-0007-58c5-bd6ffbd2df31', '84a1029b-04c8-0005-5548-e180ad338d6b', '356a7d21-6e82-0006-3470-dc8fc101267b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('79bebf65-acaf-0007-0544-7ebb95b9d5ec', '84a1029b-04c8-0005-5548-e180ad338d6b', '8e947f42-3cf8-0006-843e-60f8b5fea83d', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('95a29ddd-f0c1-0007-fddb-8213b75bd82b', '84a1029b-04c8-0005-5548-e180ad338d6b', '36922a3a-f659-0006-9c4d-0e16a1ca9095', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c281beda-b0ee-0007-1f47-f7444d4df992', '84a1029b-04c8-0005-5548-e180ad338d6b', '2915f812-2eaf-0006-3247-a3ee3a2c7d3d', 4, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a9869ec1-c3fb-0007-bb9c-9bde7a434f17', '84a1029b-04c8-0005-5548-e180ad338d6b', '163628c2-89d1-0006-d1af-bb18a863454e', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e380d6ce-75c7-0007-3293-445252b77f37', '84a1029b-04c8-0005-5548-e180ad338d6b', '409dde8f-23a4-0006-e141-4d64030234e5', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ff0bdce2-421d-0007-a857-f9f637e445b1', '84a1029b-04c8-0005-5548-e180ad338d6b', '717e4cbd-f435-0006-5502-e6c0727b7c97', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('adcfed64-e8b3-0007-d7c4-66da28efd92c', '84a1029b-04c8-0005-5548-e180ad338d6b', '7b7896a2-c6e0-0006-957c-616ed64dd685', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2be66f08-a9ef-0007-dcb3-81f3209fd810', '84a1029b-04c8-0005-5548-e180ad338d6b', 'f99e964d-eaa9-0006-c8ae-032e285b76b7', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2de71723-30c5-0007-d7ee-5099cdfc5a39', '84a1029b-04c8-0005-5548-e180ad338d6b', 'a719d07e-0517-0006-4eae-bc3d71aa524d', 7, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3fc95fa2-2cf6-0007-74b5-502a48944bc2', '84a1029b-04c8-0005-5548-e180ad338d6b', '7d34576c-c7d0-0006-dbc9-d786cde27cac', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4aabfb58-670a-0007-80f4-d71b8ef5bdb9', '84a1029b-04c8-0005-5548-e180ad338d6b', '59d24fd9-50d0-0006-54f4-e73ab264adca', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3afe6439-f8c9-0007-5db5-2b7ca9ad9b1a', '84a1029b-04c8-0005-5548-e180ad338d6b', '5f863b85-eea9-0006-40a9-1840f613e7de', 22, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3e0d458b-8b36-0007-6802-4a33bab4e476', '84a1029b-04c8-0005-5548-e180ad338d6b', 'b5c3d2b2-4c4a-0006-896b-98221bce19b9', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('547aeb1b-7545-0007-7dab-b51f8cb2e7a1', '84a1029b-04c8-0005-5548-e180ad338d6b', 'eb392240-6123-0006-ab7b-66e5e6335dc2', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('fe38cab5-30a3-0007-3f62-a227ab759135', '84a1029b-04c8-0005-5548-e180ad338d6b', '9df4a12e-0f4b-0006-42a6-9dc70077a9c7', 4, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0286bf76-8f4b-0007-8714-3bee8759077a', '84a1029b-04c8-0005-5548-e180ad338d6b', 'c65439ba-734b-0006-b92b-69fae3536a62', 4, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2d4c78c5-9627-0007-42c5-625931bb0773', '84a1029b-04c8-0005-5548-e180ad338d6b', '78567556-1970-0006-3861-b9e49089ccf1', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7ce9e850-78c8-0007-ab7d-d5ef4370bd46', '84a1029b-04c8-0005-5548-e180ad338d6b', '293f3da0-7fe3-0006-9f2c-8e940b99a09c', 5, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2ef00cd4-841d-0007-135b-d34f621ffc20', '84a1029b-04c8-0005-5548-e180ad338d6b', '6bfd6b45-130a-0006-04a3-db60a109c0cc', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('42059cda-0724-0007-17eb-5b643bb6eefa', '84a1029b-04c8-0005-5548-e180ad338d6b', '111652fa-a72d-0006-615c-f27cf2316ff8', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1d05ef66-d830-0007-a539-fbc929a41330', '84a1029b-04c8-0005-5548-e180ad338d6b', 'aa703ec6-38af-0006-7896-981f05f6694e', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;


-- ========================================
-- Alloy Soccer Club ROSTER
-- ========================================
INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f6e96a87-cad9-0007-b7bd-77dc60a06c85', '0223b314-0973-0005-f017-a5527b76a814', '16d92ff3-9a57-0006-147d-280de1b7db40', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e47d7617-b7c5-0007-fe3f-b44da2052728', '0223b314-0973-0005-f017-a5527b76a814', '814a9c1d-8620-0006-fc65-3b86fdfbac20', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a84cb650-7f4b-0007-fbce-480f2a96fd35', '0223b314-0973-0005-f017-a5527b76a814', '84d2ee83-7c45-0006-1dab-59de9792906c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('97a2aca1-ff42-0007-727b-5e994cd7970a', '0223b314-0973-0005-f017-a5527b76a814', '8ceeaa55-f225-0006-08cc-ffb7de4701a8', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b7c142a7-a81a-0007-7566-348de772b0d3', '0223b314-0973-0005-f017-a5527b76a814', 'dfe87512-0319-0006-8548-325bd5838ee9', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4a6763bf-f3d6-0007-1dd8-9359c79e7b30', '0223b314-0973-0005-f017-a5527b76a814', '17c9c8e7-1315-0006-bb2f-416ce8a18678', 8, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f0a734ce-cf90-0007-a0e7-0280a7081552', '0223b314-0973-0005-f017-a5527b76a814', '985ebafc-5269-0006-25fc-ad8f0dc32b3c', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('13036241-9d3e-0007-13d7-f391fd803364', '0223b314-0973-0005-f017-a5527b76a814', '492ea2dd-919e-0006-644c-293da698aae6', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3486d83d-4f54-0007-377b-8707c0ca7a1e', '0223b314-0973-0005-f017-a5527b76a814', '64afe88d-0fe3-0006-5a43-346701077142', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0a3d6917-2b73-0007-edb8-a39626bba547', '0223b314-0973-0005-f017-a5527b76a814', '1f2de849-cb2d-0006-2909-7ee022ed5674', 7, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('6e7f11b0-59fc-0007-e6ae-90e3a0eb5c3b', '0223b314-0973-0005-f017-a5527b76a814', '4686541b-cf02-0006-3704-ffda942ae37b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('31d35e94-59b4-0007-c7a1-54bd558722d2', '0223b314-0973-0005-f017-a5527b76a814', 'b4e19a88-ed02-0006-16f6-954571f73f18', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('5e3c57a5-9ad4-0007-1f7f-44685900cd1f', '0223b314-0973-0005-f017-a5527b76a814', '1ec1357e-f099-0006-9e77-85c72c0f7eb3', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b0c5e94f-1b5e-0007-d7ba-9c44a35c14ea', '0223b314-0973-0005-f017-a5527b76a814', '50b1a6e6-ab05-0006-facb-7d8d04b79397', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1ef1d21a-8012-0007-8d91-9b0e87385a37', '0223b314-0973-0005-f017-a5527b76a814', '66f7cd58-be5d-0006-8bf3-4a46a6245a00', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ff29509f-fa2e-0007-f2da-4c5f41017f60', '0223b314-0973-0005-f017-a5527b76a814', '6fa99191-236c-0006-9c0e-142c5199daac', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('67749db5-ed80-0007-a934-c23f70234ae8', '0223b314-0973-0005-f017-a5527b76a814', '46b93ff5-4a41-0006-513d-fab5d6778c83', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f1a15e3a-1eb4-0007-1fc8-28e3feaa039f', '0223b314-0973-0005-f017-a5527b76a814', '4f04250a-4984-0006-8f4a-4961b600ac45', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('053642ca-6635-0007-d149-043f7b10d322', '0223b314-0973-0005-f017-a5527b76a814', '222b5834-d814-0006-8243-9a84fbf3efa7', 8, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('85a58d39-de4d-0007-6ee5-2d97dae934c3', '0223b314-0973-0005-f017-a5527b76a814', '48930eb9-5f31-0006-6cb0-abb280213e4c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9a7be9a8-2764-0007-cb03-4defe4558837', '0223b314-0973-0005-f017-a5527b76a814', '0b634a77-de63-0006-5f0b-c219e2d3314e', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('cf065e52-3136-0007-8db6-25a2ac0c850a', '0223b314-0973-0005-f017-a5527b76a814', 'a576fe92-034d-0006-ef52-0f7ac0658a1a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a1689f95-da72-0007-d2f3-1d7b47803c43', '0223b314-0973-0005-f017-a5527b76a814', '82284f64-89cc-0006-10c8-8fe9b7e7d46e', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('85cdedc4-e3bd-0007-f0fd-b5566458ce76', '0223b314-0973-0005-f017-a5527b76a814', '142189da-3562-0006-c670-f7a826da045d', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('506d4c52-77ed-0007-f89a-a81cb2be5e35', '0223b314-0973-0005-f017-a5527b76a814', 'd0123234-a6ba-0006-20fd-9b1ee7e590e2', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('bd3f6b1c-b4da-0007-1d2f-2ed4a2a3cec7', '0223b314-0973-0005-f017-a5527b76a814', '829e0d25-5eec-0006-40be-c05fa9fedd68', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b0d418ba-3807-0007-df29-9479b0a6fd0c', '0223b314-0973-0005-f017-a5527b76a814', '69e8d194-ff48-0006-c460-a912f7fc942d', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b291b5d8-629a-0007-4799-62543163f186', '0223b314-0973-0005-f017-a5527b76a814', '5f21b05f-63cb-0006-70b8-cbe8e5e79b42', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('98c3e6e7-a97d-0007-595a-3f83c344d9bf', '0223b314-0973-0005-f017-a5527b76a814', '2512eac1-4e1f-0006-f908-b74a67ea1df7', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3a1fce91-2547-0007-de9f-d747d0104d07', '0223b314-0973-0005-f017-a5527b76a814', 'a305845b-886c-0006-870f-5bd1836fecf8', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('531b1f09-b053-0007-6d16-bb4b86ebdd0c', '0223b314-0973-0005-f017-a5527b76a814', 'd4fd6fa0-6e88-0006-589d-a3de0ad19a5a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9648a6f7-4cdb-0007-de84-95ede972ac5b', '0223b314-0973-0005-f017-a5527b76a814', 'bd5686cf-ff37-0006-ab7d-7b1f782c12a4', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('5936f456-f4bb-0007-aaca-22ebfce4b53c', '0223b314-0973-0005-f017-a5527b76a814', '2bd72cfd-a1b1-0006-5bd2-7d60d55e868f', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c5f3aca0-36c1-0007-133a-c5cea3a3347f', '0223b314-0973-0005-f017-a5527b76a814', '868ba230-c422-0006-edb3-2d111bc2f2d0', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('08949f35-a50d-0007-52a6-14404904b6a6', '0223b314-0973-0005-f017-a5527b76a814', 'ab2f2171-acd0-0006-1d76-66f484986a88', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0e02654a-d284-0007-be31-a9c135003bc8', '0223b314-0973-0005-f017-a5527b76a814', '0dfada6f-6e39-0006-0d0b-1202a61f2898', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0d7a5489-3b2b-0007-c1e9-652d67d18c36', '0223b314-0973-0005-f017-a5527b76a814', 'bde9976e-b29f-0006-f68e-27c84ac2bba0', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2247cb5f-edf8-0007-0b78-ab0378102263', '0223b314-0973-0005-f017-a5527b76a814', 'be102653-0955-0006-39b8-5c0c1e846f82', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e64c08d4-3e51-0007-900f-085d2f002382', '0223b314-0973-0005-f017-a5527b76a814', 'e913e933-33d5-0006-ad23-6586ec9c5813', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('754c8c43-7d82-0007-875d-d97a7d6553e2', '0223b314-0973-0005-f017-a5527b76a814', 'ff827088-9e31-0006-c5f7-5139d0f0f61b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d6579760-5b3c-0007-af1f-ca2fda3f5e9e', '0223b314-0973-0005-f017-a5527b76a814', '10ce28e8-95b4-0006-53f1-e2d400c6835f', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f0aa4087-4c65-0007-b71f-fe939c2d221a', '0223b314-0973-0005-f017-a5527b76a814', 'c617bd8d-57f9-0006-f358-44242c9be1bb', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('6a5b280d-0241-0007-7b1d-6196dc8bfa4a', '0223b314-0973-0005-f017-a5527b76a814', '5cd2aeb0-5546-0006-14c9-4c1eb91b2ca4', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a428c2df-94f8-0007-ba88-cf32ef7513d3', '0223b314-0973-0005-f017-a5527b76a814', '4ff4b866-91a4-0006-dccd-13a06549e8dd', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('15b9347c-60e5-0007-b67e-34442d440619', '0223b314-0973-0005-f017-a5527b76a814', '0154cbde-3c60-0006-28a0-a934584a407a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('45a7d42e-aa25-0007-0c0f-61c6bc9fbe09', '0223b314-0973-0005-f017-a5527b76a814', '8abe654b-1bab-0006-a261-3e20ea138164', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('45422e81-38d4-0007-08b7-f7b1e13b901b', '0223b314-0973-0005-f017-a5527b76a814', '6f191c57-1dc6-0006-0d6e-e737bb1694b1', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;


-- ========================================
-- Philadelphia Heritage SC ROSTER
-- ========================================
INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e9ce3149-7ee1-0007-e3a1-642914cf4864', '294a08ff-4f18-0005-c42b-a5fb0d5f0896', '9f528086-f1dc-0006-02d3-129c1a89f217', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('89b49ce0-7ca4-0007-767c-922f66b6c397', '294a08ff-4f18-0005-c42b-a5fb0d5f0896', '61766419-79ba-0006-0d2c-67d82acac321', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9236d140-15a2-0007-41af-8a65ad5ab568', '294a08ff-4f18-0005-c42b-a5fb0d5f0896', '3534290b-8ac7-0006-cfde-3d2307bc6777', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('cc195882-c305-0007-5a15-f7d33a4ee470', '294a08ff-4f18-0005-c42b-a5fb0d5f0896', '9da04c79-4301-0006-981b-20a78277623a', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2ffd1713-4888-0007-2846-073108dd8d0c', '294a08ff-4f18-0005-c42b-a5fb0d5f0896', '696479a2-a4dc-0006-e7d9-4f413577ba63', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('db9890d7-ca3c-0007-66f7-429d726e561d', '294a08ff-4f18-0005-c42b-a5fb0d5f0896', 'faa898f0-7e7d-0006-cc5f-7588ef4c6c67', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4cad94a1-d804-0007-f754-52d2ce7aaca5', '294a08ff-4f18-0005-c42b-a5fb0d5f0896', '584d92d6-3f6a-0006-5138-2b12bbd10beb', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('8e63fb52-9f74-0007-fd11-0b9ae182de9c', '294a08ff-4f18-0005-c42b-a5fb0d5f0896', '773910ac-70bb-0006-1347-bffa895dabbe', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('856550c2-5e09-0007-7aab-c6cfceb2ac85', '294a08ff-4f18-0005-c42b-a5fb0d5f0896', '675b867c-0b93-0006-0afb-24743fad4132', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('af548b2e-4a59-0007-c09d-f48c102c1512', '294a08ff-4f18-0005-c42b-a5fb0d5f0896', '01181b06-fd26-0006-a9b5-e37fb0513489', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('dae7a18b-89c5-0007-c256-86183b6e39a3', '294a08ff-4f18-0005-c42b-a5fb0d5f0896', '42fa29b2-81ec-0006-4921-e5d1d785ed98', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2a8a79a8-2cb4-0007-0b02-97900318281d', '294a08ff-4f18-0005-c42b-a5fb0d5f0896', 'b3652ce9-2860-0006-5640-e94c61724552', 7, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7a6fe5f7-9635-0007-5324-9d66d2437073', '294a08ff-4f18-0005-c42b-a5fb0d5f0896', '61cf4157-f653-0006-b5c6-39c24fd9866a', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3a860691-ca29-0007-e742-776fecab8401', '294a08ff-4f18-0005-c42b-a5fb0d5f0896', 'e53ed71e-debf-0006-7a8e-6520d161bc2f', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7a8afdce-bca2-0007-2bef-aa68387f500b', '294a08ff-4f18-0005-c42b-a5fb0d5f0896', 'e0d5e932-646a-0006-1004-33bb89698dcd', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('13b3c0bd-1016-0007-971e-9ef55c2e90fe', '294a08ff-4f18-0005-c42b-a5fb0d5f0896', '195add2e-8735-0006-4171-644823d4a00f', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('623b64d5-5bd4-0007-0cb5-de3834eeee9f', '294a08ff-4f18-0005-c42b-a5fb0d5f0896', 'b63c6d5f-6693-0006-bcbf-383487120e1a', 7, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('fe595ede-330d-0007-2a9a-4f6555afa27a', '294a08ff-4f18-0005-c42b-a5fb0d5f0896', '2d975247-9777-0006-523d-193f2d2cab53', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ac569ba1-df88-0007-fece-577705bf79ac', '294a08ff-4f18-0005-c42b-a5fb0d5f0896', '5f795242-1de4-0006-0aa6-6482c08358ec', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('de26bfad-a223-0007-b1dd-dd91cb971d6a', '294a08ff-4f18-0005-c42b-a5fb0d5f0896', '87449ab5-c81a-0006-9188-c8cd09391777', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('62ee2711-9365-0007-27ee-807ac7d1934a', '294a08ff-4f18-0005-c42b-a5fb0d5f0896', '10c00684-5530-0006-9e75-64bb24a81c8d', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('42275ca2-cf80-0007-1cda-c3d7bc148c16', '294a08ff-4f18-0005-c42b-a5fb0d5f0896', '821024ec-6e2e-0006-3551-960d684ab8dc', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9a195a7f-8d16-0007-ad29-86aed946d1f0', '294a08ff-4f18-0005-c42b-a5fb0d5f0896', '4cb51f6b-50be-0006-cf9c-25c385f61e40', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ed3798c9-5b16-0007-8b1b-05c03a1d642a', '294a08ff-4f18-0005-c42b-a5fb0d5f0896', 'e5d4d925-f466-0006-f20a-032c43eb1d7f', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ccfb03f0-db58-0007-32a7-ab474ff55452', '294a08ff-4f18-0005-c42b-a5fb0d5f0896', '1d318d31-a7df-0006-b874-24cbd65e7938', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('05c967ae-7351-0007-fbea-0860b79a75dd', '294a08ff-4f18-0005-c42b-a5fb0d5f0896', 'c569a669-6ad3-0006-1674-025adc8f95a5', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1682f114-1fd2-0007-ce83-91a8ec6eebb0', '294a08ff-4f18-0005-c42b-a5fb0d5f0896', '445eaea8-b547-0006-520a-df103335510e', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('70becd4f-32ac-0007-1401-9c689015a647', '294a08ff-4f18-0005-c42b-a5fb0d5f0896', 'd2ff88b2-4803-0006-614c-3f5861963ff9', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('126a5eb0-c3e3-0007-c269-53a014f04a06', '294a08ff-4f18-0005-c42b-a5fb0d5f0896', 'f3f76a07-6ebb-0006-5864-e904be625495', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9e3dae78-3948-0007-184e-6d3cc3dd3361', '294a08ff-4f18-0005-c42b-a5fb0d5f0896', '9b1b152b-fd16-0006-82cb-df0e8f9c03ac', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('bbe5b425-effd-0007-3477-9153e10afd74', '294a08ff-4f18-0005-c42b-a5fb0d5f0896', '77b15275-e972-0006-c1a5-9fb831d3b337', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('bb17d3d6-2455-0007-da32-ff50fa1c93c9', '294a08ff-4f18-0005-c42b-a5fb0d5f0896', '287bd74a-b462-0006-448f-0174adcd134d', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e4752238-3c8a-0007-60d4-5bfc90ef36ec', '294a08ff-4f18-0005-c42b-a5fb0d5f0896', '30939ef1-3caf-0006-f5c3-842dc5a6597e', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f76c84c6-0267-0007-cc0a-a6f2694f7b3c', '294a08ff-4f18-0005-c42b-a5fb0d5f0896', '7e36ec31-3ad0-0006-96c9-d37bd0f48623', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;


-- ========================================
-- Real Central NJ Soccer ROSTER
-- ========================================
INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2c681c32-6e01-0007-d051-0b30d3b79c18', '5d95682c-0ec8-0005-0728-deae7986a2e0', '86d51aa0-be25-0006-193b-db3e2adc4631', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e8156505-a59f-0007-2c6d-5a11329a9f3a', '5d95682c-0ec8-0005-0728-deae7986a2e0', '43413162-7882-0006-5d56-b71e555f9691', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('98ba9d9e-039e-0007-741b-30b5fbf19e0d', '5d95682c-0ec8-0005-0728-deae7986a2e0', 'd0292f9f-02dc-0006-06ee-75cf7adf5925', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c238fe76-0b8c-0007-12f3-182d48cab93b', '5d95682c-0ec8-0005-0728-deae7986a2e0', 'c244cfb8-b093-0006-774a-eacd70542335', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('960f6985-9006-0007-d303-2ce7af04f35b', '5d95682c-0ec8-0005-0728-deae7986a2e0', '18147fb2-d96a-0006-4857-e033c4bc4f26', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4d11cac6-98c5-0007-cf55-e7398b6e356b', '5d95682c-0ec8-0005-0728-deae7986a2e0', 'b4526f39-7e27-0006-eee2-a89b63af889e', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1fa14ab1-f966-0007-b8e3-5110c03ce6e7', '5d95682c-0ec8-0005-0728-deae7986a2e0', 'fe568cfe-11cb-0006-3574-4e8e598c776e', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('8b6d266d-5931-0007-a2c4-a21253a56217', '5d95682c-0ec8-0005-0728-deae7986a2e0', 'e45c7edf-df0e-0006-1633-4653a2f8a3c2', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('fa42df22-95fa-0007-6cb3-df2824392ac4', '5d95682c-0ec8-0005-0728-deae7986a2e0', '6d4f96c4-14e0-0006-e08b-170b463b4edf', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4fd3d5df-d18f-0007-0502-40b392e9f92f', '5d95682c-0ec8-0005-0728-deae7986a2e0', 'c873d9ec-eef6-0006-a865-3f32b5e09c36', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('47ad71f6-da52-0007-c1d1-c1df7975a21e', '5d95682c-0ec8-0005-0728-deae7986a2e0', '5093c74f-9ade-0006-a102-19d78a9aac18', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c6b7af7c-e966-0007-e919-a767f36f156a', '5d95682c-0ec8-0005-0728-deae7986a2e0', 'dab4223f-fc7f-0006-4d2d-a7ff6c296cd5', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c17ac5a3-4531-0007-df56-b13fee720023', '5d95682c-0ec8-0005-0728-deae7986a2e0', '5f8f41f3-183f-0006-a400-f08ef20db0e1', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('119b36b9-3d8f-0007-d545-be03ffb1a475', '5d95682c-0ec8-0005-0728-deae7986a2e0', 'a95fd652-5fce-0006-4adb-c8d9dbfe5421', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('094e5eaa-bfc6-0007-d64b-6aad17181d11', '5d95682c-0ec8-0005-0728-deae7986a2e0', '2268ea79-4d94-0006-0405-8b7d22b68d60', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e988b7d2-b091-0007-ecda-38ecf7f99118', '5d95682c-0ec8-0005-0728-deae7986a2e0', 'cd79bce6-dcf9-0006-efbc-6da8fe9f09b5', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b4130033-f95b-0007-ed13-7de5cc9ef1bd', '5d95682c-0ec8-0005-0728-deae7986a2e0', 'a47a3208-71ee-0006-f734-0e9edf876ad6', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1a85373f-e611-0007-71e5-dec7a09edb6e', '5d95682c-0ec8-0005-0728-deae7986a2e0', '1b2b5528-15b8-0006-17e4-bb120dbed317', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('049a0b43-01f1-0007-b106-7d81d1f9ac5d', '5d95682c-0ec8-0005-0728-deae7986a2e0', 'f8c2ad45-eb32-0006-558f-9243f57f3d01', 3, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c308aebd-6181-0007-00dc-97bc2deca75c', '5d95682c-0ec8-0005-0728-deae7986a2e0', 'd500b3ed-3494-0006-be2c-242a2025d9d0', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ec03ae48-2908-0007-d5a1-16af9bb99db4', '5d95682c-0ec8-0005-0728-deae7986a2e0', '1ac818b2-8c87-0006-0c07-ee686030fe48', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('fa5afb24-1ae2-0007-80ac-a18c48c27883', '5d95682c-0ec8-0005-0728-deae7986a2e0', 'bfd119b4-ce47-0006-27fc-97aeb536d1f6', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('bab46709-befa-0007-8262-d34254fc30d9', '5d95682c-0ec8-0005-0728-deae7986a2e0', 'fcb29f52-86c8-0006-9d89-d9194f1d9477', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('40b66b10-8fa5-0007-12b1-b1c427470192', '5d95682c-0ec8-0005-0728-deae7986a2e0', '68a552ca-73e0-0006-9f60-eb800ec5e1bd', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('abab60fb-650a-0007-7067-d9fc35355808', '5d95682c-0ec8-0005-0728-deae7986a2e0', '6b595c01-24db-0006-8754-89f6298a6d58', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3f42e8a1-7060-0007-936f-533d8f306f11', '5d95682c-0ec8-0005-0728-deae7986a2e0', '0deec1cf-7b49-0006-b6fe-f722f94aa079', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('6e014a3e-b98c-0007-c341-4c9067d931e7', '5d95682c-0ec8-0005-0728-deae7986a2e0', '4495ad80-9927-0006-fca1-f88692b55feb', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('704e73f3-8a0c-0007-3053-ddab3e3147b5', '5d95682c-0ec8-0005-0728-deae7986a2e0', 'ff20f743-4dba-0006-0e6f-f5ff73f37778', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('8dfa5aa3-2a89-0007-1af4-0993308d9fd4', '5d95682c-0ec8-0005-0728-deae7986a2e0', 'c24c9895-f2ba-0006-4df1-3fb92429acff', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c4bfe2cd-3dce-0007-4645-8b714027dfc3', '5d95682c-0ec8-0005-0728-deae7986a2e0', '7b281ced-cfd9-0006-1869-fe06c0cc4d0e', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f13b1b36-9447-0007-71c1-05d1ef259fba', '5d95682c-0ec8-0005-0728-deae7986a2e0', 'b6b89033-4acf-0006-e766-0b728504f01f', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('503c7b52-83a0-0007-1e4d-bbcd2f138168', '5d95682c-0ec8-0005-0728-deae7986a2e0', '36de4112-9d5b-0006-5c1b-0e7bbad8e3e5', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('cb745b88-cf05-0007-ae17-a6f0f511a7f9', '5d95682c-0ec8-0005-0728-deae7986a2e0', 'ffa0f384-3e92-0006-3533-706f91e6f75f', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e3b52cd2-0674-0007-0156-64844f91c18a', '5d95682c-0ec8-0005-0728-deae7986a2e0', 'aedd070a-30c8-0006-8228-744f4dfa7612', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;


-- ========================================
-- Vidas United FC ROSTER
-- ========================================
INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('527260e6-b82e-0007-efce-5db45a63315e', '3dd92f09-4a7d-0005-c554-60df95cfb846', '07e8cd0c-8ccf-0006-707d-3add15aeb8da', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('360db8ea-3741-0007-9a50-72c5ce9ddfda', '3dd92f09-4a7d-0005-c554-60df95cfb846', 'c466ff26-125b-0006-da01-94c3ece9fe2f', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('98ca5c35-e69b-0007-18c1-a811a549adfc', '3dd92f09-4a7d-0005-c554-60df95cfb846', 'b3a4953a-6ccc-0006-2a2c-e8f00911e2ae', 3, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a5e68b18-3edd-0007-0630-d74e51d0f487', '3dd92f09-4a7d-0005-c554-60df95cfb846', '3852c479-f1e8-0006-5176-079202b770c4', 6, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('04c63c34-fc2f-0007-c493-91e68305b241', '3dd92f09-4a7d-0005-c554-60df95cfb846', 'ee0829ea-5c96-0006-da85-f155a15be98c', 4, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('5b40514c-6666-0007-0693-c5e617cd3bcf', '3dd92f09-4a7d-0005-c554-60df95cfb846', 'e1f24d22-9ee9-0006-fbaa-bb38bb3a5375', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4baa8afc-f87f-0007-8c03-6f8f9a47f52f', '3dd92f09-4a7d-0005-c554-60df95cfb846', '7f88e917-d531-0006-6b0f-714b3dc1994d', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('41396abf-0607-0007-80df-3f09b35e3db7', '3dd92f09-4a7d-0005-c554-60df95cfb846', '1fabdff6-2b87-0006-c19a-56b2f4cbd91d', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a12dbaa3-0b24-0007-a73e-eb22a288bfe5', '3dd92f09-4a7d-0005-c554-60df95cfb846', 'f10de78a-a2f5-0006-c690-2a8d548fc5ce', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e6164c2f-2e29-0007-7286-7b78782186c2', '3dd92f09-4a7d-0005-c554-60df95cfb846', 'b10aa613-4f83-0006-a7ba-ff36dec80c0c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('156e7ef3-78eb-0007-6281-86e8be0c998a', '3dd92f09-4a7d-0005-c554-60df95cfb846', 'd93b3955-5647-0006-a808-2755eac9fdb8', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3afe9f0a-a702-0007-9e9a-cdef8f415793', '3dd92f09-4a7d-0005-c554-60df95cfb846', '8e84bde8-8c61-0006-bcbd-908578cfc12d', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4ccf939b-d3ec-0007-1cd2-7c15a9d38803', '3dd92f09-4a7d-0005-c554-60df95cfb846', '43315a90-8c07-0006-c8bb-808a1ef36cec', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('af597e7f-3d24-0007-49d9-a6afbdeef1ee', '3dd92f09-4a7d-0005-c554-60df95cfb846', '28f09349-70fa-0006-9b86-deeb6f3a865b', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('30cd4441-2d7d-0007-9449-646d2bd1216e', '3dd92f09-4a7d-0005-c554-60df95cfb846', 'c1cef24c-cd31-0006-2a5f-fe542053ae27', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('05c889ae-50f7-0007-84a0-e489a8192237', '3dd92f09-4a7d-0005-c554-60df95cfb846', '8ee042d2-ec1b-0006-7365-4300a9657803', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ac85e488-9b97-0007-4026-ec052e1b86fa', '3dd92f09-4a7d-0005-c554-60df95cfb846', '47331ae4-1b98-0006-0aaa-114c9e6e8c72', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('8bbfb16f-febb-0007-e34b-57cb58cef060', '3dd92f09-4a7d-0005-c554-60df95cfb846', 'fcc5d2b9-0379-0006-eea1-57755f8fb2c5', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('6d9d5ba8-ff02-0007-71ac-c7553094e8d2', '3dd92f09-4a7d-0005-c554-60df95cfb846', '04f6fa3d-fe6e-0006-ae7a-861415434260', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c4bd93c8-3dd6-0007-14dd-b2880bf7af20', '3dd92f09-4a7d-0005-c554-60df95cfb846', '64ef506d-0c36-0006-43c7-b8d26236d30e', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('6a98e67b-1a55-0007-f5bc-a0a6160409e8', '3dd92f09-4a7d-0005-c554-60df95cfb846', 'ff7f3a3b-4770-0006-439f-ead095ec0449', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('242c87db-c350-0007-c552-9f9ecae85ba3', '3dd92f09-4a7d-0005-c554-60df95cfb846', 'ac8d9e83-4310-0006-4509-180df564e5db', 3, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('93fabf1d-314d-0007-7e61-35ae3a00c60d', '3dd92f09-4a7d-0005-c554-60df95cfb846', '7267e085-fbd2-0006-1d8d-0b5af04a0261', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('5c4ceb6e-df08-0007-868b-342df2d7baa9', '3dd92f09-4a7d-0005-c554-60df95cfb846', 'e70c4f3f-eae7-0006-ed35-3fe58a4fee37', 6, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('67d0aedc-6d6d-0007-f96e-bc2aa93feaf7', '3dd92f09-4a7d-0005-c554-60df95cfb846', '2bfde7e9-6e52-0006-fdd6-a94d0989fe28', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('cf74d74f-9dd3-0007-92f5-3c7118312b77', '3dd92f09-4a7d-0005-c554-60df95cfb846', '5565c7c4-c50d-0006-8e55-b704a3cac296', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('080ba40d-c4a2-0007-bd75-8ededfbd513c', '3dd92f09-4a7d-0005-c554-60df95cfb846', '13b1aaa4-f205-0006-4f9d-e6476b707f5b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a0ca7c55-a86c-0007-00cc-a6dc2f5f38ef', '3dd92f09-4a7d-0005-c554-60df95cfb846', '03ec51ee-52f3-0006-910c-ba2407fb16b9', 3, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4505b5fc-02c7-0007-ccc1-1414a1f4e237', '3dd92f09-4a7d-0005-c554-60df95cfb846', '8aa059ed-5b5b-0006-da67-6538d4b43523', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;


-- ========================================
-- Philadelphia Soccer Club ROSTER
-- ========================================
INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('da96914c-a65d-0007-b762-05570c0a0689', '907ece9f-5926-0005-cff6-7672dec05648', 'a9ba68f3-0f7f-0006-358d-fd63a7689123', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d8ad3ed1-e291-0007-a97c-f16c847d31c9', '907ece9f-5926-0005-cff6-7672dec05648', 'ae04becd-a47b-0006-5a96-4c38531d03d4', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('49d598a6-aee2-0007-68fe-e0370b220884', '907ece9f-5926-0005-cff6-7672dec05648', '72e4776c-5809-0006-e317-9cf118445bd7', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7ba1c63b-e8ff-0007-a4c9-ed4ddd6f694a', '907ece9f-5926-0005-cff6-7672dec05648', '719d9258-cf7e-0006-8eb2-ffb5f0a6d894', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('40cc9221-860d-0007-73df-6c57a0a89d7e', '907ece9f-5926-0005-cff6-7672dec05648', '6b4d97c5-783b-0006-e858-7e43a4e3a710', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7e06553b-271a-0007-2f3b-f3037fea867e', '907ece9f-5926-0005-cff6-7672dec05648', '2c0045fc-8936-0006-4901-3005a950d5fb', 4, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('141395bb-c83e-0007-22e1-548268c0c4e2', '907ece9f-5926-0005-cff6-7672dec05648', 'd0fa7536-1fb8-0006-b191-b96070d0cd69', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('930d7812-7cf4-0007-1207-dfcd40863924', '907ece9f-5926-0005-cff6-7672dec05648', '965482bc-020a-0006-7e19-24e46a2f2557', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('64accb59-beeb-0007-5d51-f2f761603525', '907ece9f-5926-0005-cff6-7672dec05648', 'dfb495f3-ad0d-0006-4a63-f277ab99a9e5', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4a37abae-6572-0007-3752-27cdf405d298', '907ece9f-5926-0005-cff6-7672dec05648', 'c962643d-da84-0006-abf0-3cee898b0284', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b0b2d067-c9e8-0007-49c7-4b1f9bd6104e', '907ece9f-5926-0005-cff6-7672dec05648', '1bace6e6-6191-0006-654e-438eae1d01c7', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('93bde3b2-4851-0007-62db-25b22a2e5393', '907ece9f-5926-0005-cff6-7672dec05648', '64205475-7ea5-0006-c157-b58d5f8e7352', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b8e9287f-7153-0007-a3bf-7833a2a22319', '907ece9f-5926-0005-cff6-7672dec05648', '9d94f51c-9581-0006-b91e-6704c9277f7e', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9dddf9e5-316a-0007-1f86-48ba2ada769e', '907ece9f-5926-0005-cff6-7672dec05648', '43cd8a37-250f-0006-0f1f-2dc468827103', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d58fe0bf-1fc0-0007-af81-328581add4e9', '907ece9f-5926-0005-cff6-7672dec05648', '52e2cae2-d9ac-0006-554f-de40933cc1c8', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('5a99ecb6-c600-0007-af5f-a48d548ec51c', '907ece9f-5926-0005-cff6-7672dec05648', 'e92ba81a-e412-0006-e30c-0ed3b9f606e2', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('20a55dc5-7b5e-0007-d915-8328c1c2504f', '907ece9f-5926-0005-cff6-7672dec05648', '4f0ca7b3-0687-0006-b5ca-ae8876879ca5', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4ac2027d-462c-0007-635d-f5d11a291536', '907ece9f-5926-0005-cff6-7672dec05648', '2933ab46-31c8-0006-221d-5f7dfabcd0a9', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f6837393-3bd6-0007-1939-88ac7195c563', '907ece9f-5926-0005-cff6-7672dec05648', '33988cd2-c5b4-0006-6f0e-764693b44a97', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0941ff9b-0a51-0007-c25a-fe8e30915621', '907ece9f-5926-0005-cff6-7672dec05648', '20223cdc-63ce-0006-8a49-05e9f504fa48', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4f1b6f1c-126e-0007-227d-3ce46e98b4c2', '907ece9f-5926-0005-cff6-7672dec05648', 'bf24ae90-55f7-0006-180e-162c9b2c4f35', 3, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('6c9513b4-0258-0007-0f27-7f998cb1b23d', '907ece9f-5926-0005-cff6-7672dec05648', 'ef84510d-4ce7-0006-43ca-f65fc4d0ede9', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4f0cf423-8fd1-0007-ef14-efb615a0bba7', '907ece9f-5926-0005-cff6-7672dec05648', '2d7f675c-563a-0006-2dfd-c9692bbc5d9f', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('391968d4-1185-0007-acd5-3f7996fdc977', '907ece9f-5926-0005-cff6-7672dec05648', 'd9b9dbe9-421f-0006-71f5-e268353a1a24', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9856ba5b-3b4d-0007-9cc5-69236884bca0', '907ece9f-5926-0005-cff6-7672dec05648', '15795f0d-798c-0006-0f94-f23eb5da1d56', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('8ebffc10-2dd9-0007-5fac-04ebae956ced', '907ece9f-5926-0005-cff6-7672dec05648', '3b78428a-fd24-0006-b0cd-f4ce638c7227', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7c75fa33-be8b-0007-a8bf-6687eb54efe9', '907ece9f-5926-0005-cff6-7672dec05648', '2822dd63-d8d2-0006-17d1-95086cd6be97', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('36c394e5-592d-0007-78f7-327c9b966654', '907ece9f-5926-0005-cff6-7672dec05648', '618090fe-345d-0006-52b7-079e35e707ad', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('db89f9e9-e1ae-0007-4ad1-a0a81216a18c', '907ece9f-5926-0005-cff6-7672dec05648', 'cdc083cb-54e7-0006-8315-aa39a765a10e', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1a612482-c2b0-0007-a727-de7839a41dff', '907ece9f-5926-0005-cff6-7672dec05648', '598c162e-bac7-0006-27b2-b1288cbf9b82', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2306bb65-0ec0-0007-3613-12d5dd787bcc', '907ece9f-5926-0005-cff6-7672dec05648', 'a6c42a10-4c7f-0006-47f3-f37eb86cc16d', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('088e0c5f-f2fe-0007-6c2b-9b1fe5ebd13b', '907ece9f-5926-0005-cff6-7672dec05648', '963d94fa-eb7f-0006-7ce7-cbede87d1de2', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;


-- ========================================
-- Oaklyn United FC ROSTER
-- ========================================
INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2fa0c481-2a46-0007-c46a-5d059f601d8d', 'c2402f6c-0036-0005-d453-d68637ee8277', '71df8607-2764-0006-be4f-f62b9022a409', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('8688b4c4-3dfd-0007-16c2-1faf742f3651', 'c2402f6c-0036-0005-d453-d68637ee8277', '5799be88-db80-0006-f9ef-3df307a698c3', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0afc3511-49c1-0007-bbec-c06b55018e25', 'c2402f6c-0036-0005-d453-d68637ee8277', 'cbd4f193-e8d8-0006-b980-4cce087170b4', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('fd4c67b3-fb30-0007-3f90-c8d2f389b6de', 'c2402f6c-0036-0005-d453-d68637ee8277', '78c995a8-6426-0006-330c-e738344e92fa', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4071e59b-023c-0007-1d67-b5cf8288a872', 'c2402f6c-0036-0005-d453-d68637ee8277', '85f9b46e-9ec5-0006-998b-b595bfef6d83', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('be9bfc95-f617-0007-7c15-ba6da228d521', 'c2402f6c-0036-0005-d453-d68637ee8277', '35f70e2e-8c57-0006-5f5d-a7f450d84339', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('027faff2-e25e-0007-2d7e-bf47c86c6101', 'c2402f6c-0036-0005-d453-d68637ee8277', 'd846eb32-8018-0006-f104-98587d54395d', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('75abfa63-6b1d-0007-d5e7-7053f58c6f44', 'c2402f6c-0036-0005-d453-d68637ee8277', '106939cb-a4c7-0006-03ac-8261cc90d806', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('cf95c3f3-6597-0007-82f0-5fef67794fca', 'c2402f6c-0036-0005-d453-d68637ee8277', '9d5dce99-7e66-0006-dcf4-6880c44244c1', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d76d346f-b2c8-0007-e613-f8de7af1f7b5', 'c2402f6c-0036-0005-d453-d68637ee8277', 'd39431ba-d80b-0006-a7d5-62fddc3a4727', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d811abdc-6ef4-0007-e6d0-2f66f3dfeca7', 'c2402f6c-0036-0005-d453-d68637ee8277', '60a07d61-7b5e-0006-0b32-d3677eb2dcfc', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e2722bd2-95f9-0007-21ed-536d96b2eb0c', 'c2402f6c-0036-0005-d453-d68637ee8277', '02cd6efc-7b96-0006-ca40-f23545453cb5', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('64a65d6a-3f36-0007-0d94-01b28f701f40', 'c2402f6c-0036-0005-d453-d68637ee8277', '029f4f0c-02ac-0006-18e9-3c393b8d02d6', 4, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9c2fdd64-cb5d-0007-532d-e4bfce0f478f', 'c2402f6c-0036-0005-d453-d68637ee8277', '06afadb4-7733-0006-4d6d-191596b99910', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2095996b-d93a-0007-13ee-9d8a7247a464', 'c2402f6c-0036-0005-d453-d68637ee8277', '562059bc-79d0-0006-f3f2-b383e1e8ddf3', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4d3807f1-8a1a-0007-0b71-bf7e3cab54c9', 'c2402f6c-0036-0005-d453-d68637ee8277', '8ea1cdc4-0882-0006-5a0b-c3a308b287f2', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1e2f4ba3-e4ae-0007-3844-ad56043e1f27', 'c2402f6c-0036-0005-d453-d68637ee8277', '0dfa7220-ee26-0006-829d-a9265ac259c3', 3, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1b41eb30-00ad-0007-9fca-99789525c7fe', 'c2402f6c-0036-0005-d453-d68637ee8277', 'c22c0a10-052b-0006-ee1e-9ffac117ebea', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('014171d4-b9e3-0007-c5aa-c7f9b5f4e34b', 'c2402f6c-0036-0005-d453-d68637ee8277', 'b7c66ebe-25a9-0006-9eaf-6715c42b61c2', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('8797071b-da4f-0007-0c52-1e5b1a3be096', 'c2402f6c-0036-0005-d453-d68637ee8277', '03685128-c258-0006-7b3e-65e96d6cb14e', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f2ff9e48-1fac-0007-25fa-b9380e3257ad', 'c2402f6c-0036-0005-d453-d68637ee8277', '80b973f9-ae54-0006-2fab-9bf2c4583f2f', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('188a5813-a233-0007-1848-8cddc1f68504', 'c2402f6c-0036-0005-d453-d68637ee8277', 'ae70b5a1-d1de-0006-48b1-ed3fd75f5c55', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a4c8793f-507c-0007-20a2-a9de513c4d94', 'c2402f6c-0036-0005-d453-d68637ee8277', '31ce6bd2-40c1-0006-a3f0-0c57e0a14847', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('5e3eaccd-17cb-0007-c9a4-cf0b22482ecc', 'c2402f6c-0036-0005-d453-d68637ee8277', '8a0a6f35-57d8-0006-ad2d-18b037714c72', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('25968d08-ac3c-0007-589a-4a2266238b8c', 'c2402f6c-0036-0005-d453-d68637ee8277', '2c2c7d61-fde8-0006-1396-b9747a713457', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f46e9235-2ae6-0007-cf16-c6fb07b71a33', 'c2402f6c-0036-0005-d453-d68637ee8277', 'fdea7ec3-67b0-0006-2e92-7876591b7854', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('065c9ca4-0e44-0007-2602-4731c1a02600', 'c2402f6c-0036-0005-d453-d68637ee8277', 'd2509fe2-42ad-0006-bf78-24ba4885ea4c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('974fb506-a1e9-0007-23fe-997eb5336e0e', 'c2402f6c-0036-0005-d453-d68637ee8277', '85308641-904a-0006-265b-a8660dd49ced', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0e3898f0-6b33-0007-e4ff-43cadbbd8280', 'c2402f6c-0036-0005-d453-d68637ee8277', 'a02363ec-3315-0006-1d6e-e6943eee6ca5', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('dad5778d-6954-0007-e71e-ff2265664ab4', 'c2402f6c-0036-0005-d453-d68637ee8277', 'ee75d842-1ae6-0006-8c53-9d885fc74c26', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('647a4fdb-0d94-0007-6a0c-61c28d52eb12', 'c2402f6c-0036-0005-d453-d68637ee8277', '32670b1a-3a0f-0006-b697-6cbdc80ba419', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2c6e499e-8d1a-0007-35ec-25fb88945aab', 'c2402f6c-0036-0005-d453-d68637ee8277', '70095c63-411d-0006-2f78-7aaae8d50f52', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f1b05eae-d403-0007-3efd-314a9b108887', 'c2402f6c-0036-0005-d453-d68637ee8277', '1c6f3935-cb7c-0006-c8ac-8b8e98679203', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e5ed2c39-dc6d-0007-5b56-93acc098cc8b', 'c2402f6c-0036-0005-d453-d68637ee8277', '07f578ac-f462-0006-c49b-0d55f4461954', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('fba2c0e3-5236-0007-d6a6-9a256bee9c66', 'c2402f6c-0036-0005-d453-d68637ee8277', '54afd9f7-24cb-0006-63ff-ba2c3aaeb1a1', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4a67b434-e59a-0007-73bd-6e249b2f7434', 'c2402f6c-0036-0005-d453-d68637ee8277', 'cba11569-a188-0006-23d1-4042202515a2', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c4a4e5cb-7c7d-0007-6209-b912be36d65b', 'c2402f6c-0036-0005-d453-d68637ee8277', '8fd618a2-11f9-0006-2185-cbd6708400e7', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('05e1104f-3ca8-0007-7530-a01bdafc61a6', 'c2402f6c-0036-0005-d453-d68637ee8277', '5b5b0a37-666b-0006-681e-df64c0541f5d', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('95f7cc95-5893-0007-65ae-fec50f473f07', 'c2402f6c-0036-0005-d453-d68637ee8277', 'ee36a913-4506-0006-8fb1-25a7198f1db8', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a2764816-f96d-0007-c755-4c0f43f89765', 'c2402f6c-0036-0005-d453-d68637ee8277', '2f2e2baa-d232-0006-c825-bbfa8314cd2a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('00ec05fb-99c6-0007-ce18-d04eeaa299b7', 'c2402f6c-0036-0005-d453-d68637ee8277', 'f1fd3567-ef4f-0006-1529-4f842b97f6ec', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c5607726-01fb-0007-a9ac-22457bd32e0f', 'c2402f6c-0036-0005-d453-d68637ee8277', '9d86fae5-6620-0006-d19f-d6833d2a0027', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;


-- ========================================
-- GAK ROSTER
-- ========================================
INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b8723750-ef84-0007-1002-fab1d0e8e36d', 'f11cc01a-e8d3-0005-74f0-b00c38923236', 'c6634ec4-3116-0006-97cb-10929f847d88', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('55edf463-e757-0007-ef69-18c5ebd7aa34', 'f11cc01a-e8d3-0005-74f0-b00c38923236', '8c057fae-c618-0006-afe4-0bca248a8f23', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('5725e83e-dfff-0007-c7e0-50944cb39b74', 'f11cc01a-e8d3-0005-74f0-b00c38923236', 'd7fbbe6c-af7c-0006-a7f5-21289ec00427', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('8b021cc2-c819-0007-95e1-cdf5b12c5372', 'f11cc01a-e8d3-0005-74f0-b00c38923236', 'f51d3955-418f-0006-7089-6cba763c51ba', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('bbd3595d-6b1c-0007-e40a-a3571dc5b82b', 'f11cc01a-e8d3-0005-74f0-b00c38923236', '7a6f6516-397c-0006-7d94-d1ea3c0ca3f9', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('82db859e-b170-0007-7fe0-642bbb7f9032', 'f11cc01a-e8d3-0005-74f0-b00c38923236', '35d32d60-a2ed-0006-341a-55683e159c03', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b602306b-da7e-0007-5b1a-aeb52997f8b1', 'f11cc01a-e8d3-0005-74f0-b00c38923236', '8aab63f1-c4c6-0006-32ff-583e6a12263c', 5, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('23149ff6-ae81-0007-d13f-a9e4d8386cd0', 'f11cc01a-e8d3-0005-74f0-b00c38923236', '9fb18392-3760-0006-95a4-ef5fddde7950', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0ffafbdd-a74a-0007-2484-91f71f530cf5', 'f11cc01a-e8d3-0005-74f0-b00c38923236', '81751f47-3547-0006-ed06-174be04b84dd', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c5ddf8c5-090a-0007-e5f5-c87052a49a8c', 'f11cc01a-e8d3-0005-74f0-b00c38923236', '0888b0b4-487c-0006-fa70-cea0d131771c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('dc309d17-9002-0007-9ddd-d5c7528cd9f2', 'f11cc01a-e8d3-0005-74f0-b00c38923236', 'a0ba6bb8-a359-0006-957a-b3c1a5111aed', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('40af6a0a-bff8-0007-bf1b-eb45261bf55c', 'f11cc01a-e8d3-0005-74f0-b00c38923236', '5030ea77-ddfe-0006-1fb4-428e8701c150', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('27a0c6c6-a901-0007-5296-afe4dbde0ced', 'f11cc01a-e8d3-0005-74f0-b00c38923236', 'c1a269c4-7f62-0006-2b52-f4665c63f46c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c0162128-fec9-0007-33e3-9bca385bb305', 'f11cc01a-e8d3-0005-74f0-b00c38923236', 'e79a8f46-0fdb-0006-ad87-40a83df9316a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1d8e37c9-f423-0007-0bac-c97e18aedf7d', 'f11cc01a-e8d3-0005-74f0-b00c38923236', 'd8d39dca-cf6c-0006-d693-02d484a00311', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e2f2007e-8fc1-0007-4440-b934de0721d1', 'f11cc01a-e8d3-0005-74f0-b00c38923236', 'd8ba57f8-b7bd-0006-4e4c-956bac1c2900', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9679af2c-aec5-0007-cadc-1876b3878d2d', 'f11cc01a-e8d3-0005-74f0-b00c38923236', '75401479-549d-0006-01f2-505157115e85', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('191ffe97-0150-0007-c460-ce8bfce310ae', 'f11cc01a-e8d3-0005-74f0-b00c38923236', '3c37f45a-0aed-0006-7fa2-77f3467e5de7', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('123b7006-dd19-0007-3d1b-a671c8d5b69a', 'f11cc01a-e8d3-0005-74f0-b00c38923236', '9d527478-a389-0006-46aa-2dfb9aac6b3a', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f1896142-b562-0007-4e86-8cb78d7af88e', 'f11cc01a-e8d3-0005-74f0-b00c38923236', '7e42fc98-b13e-0006-1dc3-c70b98e4b21d', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b4914ea3-1985-0007-1cab-7dd9dbdb094c', 'f11cc01a-e8d3-0005-74f0-b00c38923236', '9c7f4fef-d2d3-0006-8a52-407f71a1ea9f', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3ac5d59e-0934-0007-7a37-029e1f7a35eb', 'f11cc01a-e8d3-0005-74f0-b00c38923236', 'a695b106-8071-0006-ec89-9777f3460789', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('58d69451-810d-0007-3af7-770b5d76557e', 'f11cc01a-e8d3-0005-74f0-b00c38923236', '3f57ba68-1014-0006-bc01-aa1cf4c3698e', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c6aa8533-dbc6-0007-bd45-e9ccc680ece6', 'f11cc01a-e8d3-0005-74f0-b00c38923236', '3f240fc1-f882-0006-09d4-058b0609ab21', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('37527d59-71cf-0007-dd80-d6a357d77250', 'f11cc01a-e8d3-0005-74f0-b00c38923236', 'a9792982-fd05-0006-a548-363d171b95e9', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('59c62a0d-db4b-0007-1567-274e444a8fb5', 'f11cc01a-e8d3-0005-74f0-b00c38923236', '652319d6-5062-0006-a0aa-018bace24cc1', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('5d04c3ca-6565-0007-b0aa-6c367398fae9', 'f11cc01a-e8d3-0005-74f0-b00c38923236', 'c05fc6df-acb1-0006-62db-d02e7a9e6960', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('95d5e821-5372-0007-1c76-835b590ca5da', 'f11cc01a-e8d3-0005-74f0-b00c38923236', 'a9d06281-f304-0006-521e-1adca8723c9b', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e5daca0a-a121-0007-063a-75efd1c085b9', 'f11cc01a-e8d3-0005-74f0-b00c38923236', '54d14e1e-2f6d-0006-32cd-f0d343e0cca1', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a804a337-e84c-0007-1154-57809f46764c', 'f11cc01a-e8d3-0005-74f0-b00c38923236', '0478cdd5-c6a4-0006-de9e-aa4ccd100674', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b78fa968-8977-0007-0e82-0b10b08a52e8', 'f11cc01a-e8d3-0005-74f0-b00c38923236', 'a845b6de-d2ac-0006-cb5f-fec49ee7bda0', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;


-- ========================================
-- Lighthouse 1893 SC ROSTER
-- ========================================
INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0486bc2f-580e-0007-ac0f-d8b4773dcfbe', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '01aca9b0-ae64-0006-e96d-7e69a00ffec4', 8, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c0265713-75f6-0007-0153-081d7e5cc272', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', 'e7b6e3e7-4b6c-0006-c471-183c094b8b51', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e163565b-aa0b-0007-4e6a-b8503ba0564c', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '326e6bc0-e8ed-0006-62b1-b4e94dd6a079', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('6500d820-5ac0-0007-4a0a-09327ed238a3', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '1089a0ee-8eb6-0006-d3d5-20bf6ba6ee7a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('396eb7c5-f7c3-0007-b29a-b5531cda400a', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '52737162-6e42-0006-4a28-377d5fbdb22a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9bb42ec8-0ea6-0007-0c6c-517d218f945a', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '769b5796-c33c-0006-69b6-bc37abae18bf', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3b5e79c0-f891-0007-3a44-8015dc0f0861', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', 'f5dfe66e-8e08-0006-ff59-107bf2898b1a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c5606c0b-4dce-0007-3d1c-8ddc4d0faf94', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', 'dd7d3571-d69e-0006-7979-7a2ce126dac6', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0ffba232-0d64-0007-0d39-1ef36ed16cf4', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '326e8020-b576-0006-761c-7e233e2fbba2', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('bcfdeb7b-8845-0007-8431-353b91df14aa', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '97b0d643-5b54-0006-be6b-066460c214b1', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2d2467ef-3991-0007-77f9-73c8bf46bcaf', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', 'f9e55725-38a4-0006-4da9-32f792737ce3', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('457d3c4e-b1b1-0007-ef78-c6d7bdc19a9a', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '8194c8f3-e9b5-0006-1b83-b544991ee783', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b57b663e-1cd8-0007-1854-bba8164f4310', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '6f56fb40-d2e7-0006-962f-ecf2b2125067', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('8bc89c0a-1fe3-0007-eac6-4e304111f663', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '68b0bb11-c853-0006-7aca-7a06730bac1c', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('35f0c9d1-28f9-0007-baf6-86b75688a83b', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '49385a1c-d37b-0006-f0c9-dac164502d9b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('63aa6e90-01f3-0007-46de-4dbaa24c1aa4', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', 'df029c0e-28c8-0006-5da8-18ab2837dcaa', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('78980bf3-259a-0007-9df9-4a7826711e27', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', 'ce93b48a-1f6b-0006-e2c1-47799cfcfff5', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1e4511a1-c63d-0007-45c0-a20670581da6', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', 'b128734e-616a-0006-94f9-740b7dab4b61', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3cc13982-1faf-0007-5f6c-0203895037c9', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '3cb5f823-9e5d-0006-e69f-35b97baec652', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('946e21dc-7d17-0007-de3f-9a7dcb11cc7f', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', 'aecf8394-3dea-0006-c777-facfc9af77f9', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('358bda46-2207-0007-4a50-073267fac9cd', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '4d8fb2ee-241e-0006-98a8-9f87f7b4be5a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e9b4c63f-609d-0007-60b9-a128af691d27', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '57ae3eff-d209-0006-409d-b97ebabee860', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4f301633-2290-0007-472e-862fd79b230d', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '1058e8dc-f991-0006-3421-156e9aae5a81', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a585affa-b23c-0007-b6c2-e2c29b6c319b', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '70b36e4b-b5bd-0006-dd9c-f58dfcd5c239', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b9412ffc-06e1-0007-6c69-29978d57011a', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '23dd5826-bb2e-0006-4dd3-59927f01b65e', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c7937ab7-c141-0007-73eb-55f7b69794e0', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '87d3f035-c0d4-0006-ee7b-0637fb8b40fd', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('927d2aee-c7fb-0007-386f-03f53bcb2bc1', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', 'f57ec0ec-24ef-0006-a2f7-0aad81711c11', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4455d5de-0458-0007-ec7d-41b2a8c2c9ee', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '0af0fa43-db02-0006-b625-bf47c0eb6099', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3965bb24-fc2c-0007-a17b-650568ffc81b', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '30ce494f-868f-0006-f5a6-bb7294f48b55', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('29508640-fdba-0007-fc8b-fc4b2db786cf', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '38a9c99e-c1b2-0006-f413-3b377a2f5e26', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d0955b61-6322-0007-1e1b-f9c922438b32', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '3d97ea32-b214-0006-679a-d6489302db67', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a9d6cf8c-ba45-0007-2279-c2e7ec69a4e1', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', 'bc5ccf9c-ed6b-0006-aafc-ba7b0002a837', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1eede0ce-a511-0007-e235-eb9670ea5809', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', 'c56e0026-ce36-0006-a667-30493706f607', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a1719fa2-6552-0007-ea42-1210679899fa', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '515aaae2-1b18-0006-42f6-9f746c261fca', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a9db5c92-2944-0007-b2a7-15529001a4ed', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', 'c0b8f774-97f0-0006-ad04-7c8af9350371', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('6b586918-2d75-0007-5ff0-df395a30bf38', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '97774ed1-60d5-0006-e0f8-4b9602517d6a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('459add6d-7943-0007-13ba-d384eb94ac09', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '376367d7-41ea-0006-6bc9-097e36813802', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('cdda3f16-334b-0007-046a-db5e11e89ba6', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '80c1d8bb-e0ce-0006-853b-ba21e898befc', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b216af9d-fefc-0007-95fa-20e8c3dbdc4b', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', 'ee690b3a-7840-0006-709a-c2bd3b274870', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4f359bdd-a43e-0007-4826-7608f28b3aa7', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', 'a0bcb0c0-a561-0006-6c6f-4cbe60070f91', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0a743ceb-ba19-0007-dd70-6944755c8206', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '3547790a-f69c-0006-bf2e-4c9711255702', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a0e7a2af-48b1-0007-115a-0b233e06422b', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', 'c03e3cbf-b5ca-0006-3a41-498cadc325ea', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('5e9565a1-ac11-0007-3886-a925729fdb39', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '38e42fd0-2eb6-0006-fcc5-d4f0c871b852', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4afe6386-6532-0007-cf0c-224907dc7db1', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '3aa05eea-e677-0006-a25b-7d72278f6cde', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b42cfe0a-84c9-0007-5df9-4d458db1ffeb', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '22d21f30-49b6-0006-c153-13bcd11bd208', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('723820d7-8d1c-0007-6742-51e5745eb67b', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', 'd8d6f8fe-5812-0006-3abe-34da60c79cb6', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('006a17f5-0cb0-0007-fc4c-ae5aa2d9a513', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', 'd1b23fe2-7c0b-0006-0827-31fca413a5d3', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a4b26732-9a49-0007-dcb8-ec561c90e06d', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', 'cf3a5601-e677-0006-2a24-d05c220c4b6a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a9a4e1bb-a2c0-0007-28c9-4b4283a4320a', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '300b5c50-5d0e-0006-3ad2-8611c1d6196f', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('668ee18f-e822-0007-a503-7d76f4612299', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', 'dc43b8da-fa16-0006-8d04-2653b7b59ae0', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('40617ad7-643d-0007-7011-103895cdfea2', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '401bf4d5-8869-0006-947a-957f0b2ea1c9', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d59e74c3-3c12-0007-1a61-3a09d933dc31', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '2b59f3e5-efd7-0006-db76-62c2276703db', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0d16fd09-dc9a-0007-66bb-03377061ac9b', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', 'f8cb832f-60ab-0006-4c2d-5eafd093e888', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2c73ffaf-136a-0007-b866-f4d128739bd2', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', 'fccdb158-2076-0006-a2eb-2b0b488507ee', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b60a7452-afe9-0007-4046-9c02cc28d562', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', 'c3be71d8-03da-0006-261b-d099c7bdc46c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0406bbe1-fa0c-0007-e549-e36b91a48eff', 'd37eb44b-8e47-0005-9060-f0cbe96fe089', '4b8f7643-2044-0006-6b76-1d334fe7ca14', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;


-- ========================================
-- Jersey Shore Boca ROSTER
-- ========================================
INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4c01185a-6e9c-0007-761d-0a293935cb0e', '7288846b-402d-0005-9d60-70d5ffcc5588', 'e5489cab-1ff6-0006-7ba7-7b04f178d0f9', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ba3e78c4-3ecb-0007-a382-66d5fab5457f', '7288846b-402d-0005-9d60-70d5ffcc5588', '1bbff203-f549-0006-9605-bfe8251d9914', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('5ea9c0f9-d12b-0007-4363-91c2c1f00e18', '7288846b-402d-0005-9d60-70d5ffcc5588', '9e91d86b-35c2-0006-b841-c082d5825af0', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('89026b32-e455-0007-5856-7d87b2a83ea7', '7288846b-402d-0005-9d60-70d5ffcc5588', '31994764-1fe4-0006-bc86-ce0a4b68bbbe', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0173e3b0-32ca-0007-f7ae-671ad6743b6f', '7288846b-402d-0005-9d60-70d5ffcc5588', '52936b80-8e59-0006-0fc4-85ccda24d91c', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('30ce6890-5202-0007-3fc5-c2ae3bfb5531', '7288846b-402d-0005-9d60-70d5ffcc5588', 'e25db64e-fe6e-0006-190f-d87dcf9dad2d', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('96b404fb-8aef-0007-5941-315ffb7a23dd', '7288846b-402d-0005-9d60-70d5ffcc5588', '73f34efc-6372-0006-9dc0-d133eefe09c6', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e9698b8d-aa21-0007-fc96-d70e3e4e0df8', '7288846b-402d-0005-9d60-70d5ffcc5588', '8abc7a91-74ac-0006-8d9c-15adf9f405ab', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('aeb99c06-53e8-0007-28b6-db50ee9991e0', '7288846b-402d-0005-9d60-70d5ffcc5588', '921bc389-af8a-0006-313c-7cd6526a255d', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('5f1fedfb-816a-0007-6df4-4a5cf46a97eb', '7288846b-402d-0005-9d60-70d5ffcc5588', '4a253e7a-7dfc-0006-2a37-2ee6bc89c4e3', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('99e49e92-fe8b-0007-dae3-fa136145f673', '7288846b-402d-0005-9d60-70d5ffcc5588', 'ecec0332-f886-0006-960c-691a358e9193', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('bc3c6247-dc0c-0007-6eb8-5c198dcec386', '7288846b-402d-0005-9d60-70d5ffcc5588', 'e33aff11-c818-0006-d022-1628d35160a9', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e463bf52-6a47-0007-e508-4f2399d57ec9', '7288846b-402d-0005-9d60-70d5ffcc5588', '52ce4b42-dcd8-0006-a26b-381fe16ff2f7', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b11edfba-143b-0007-ffee-0f8878a7401a', '7288846b-402d-0005-9d60-70d5ffcc5588', '801582d5-d5a2-0006-8a55-ff1041b1d21b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('43aebe1e-a855-0007-58d4-49accb58c198', '7288846b-402d-0005-9d60-70d5ffcc5588', 'f8174808-81f6-0006-8c36-49a9fe9967f7', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3d6a825f-1c86-0007-c781-a03330fe8e97', '7288846b-402d-0005-9d60-70d5ffcc5588', '6dcbe7ad-949d-0006-397c-138e5a82286d', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7ce37ef7-ba9b-0007-7650-dca68aed7e92', '7288846b-402d-0005-9d60-70d5ffcc5588', 'b9dce495-41bd-0006-fde2-328e8693d33c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('158395fb-8562-0007-08f9-56ab65b6f343', '7288846b-402d-0005-9d60-70d5ffcc5588', 'fd714f3e-bd0e-0006-c240-7afae08290ec', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('cda29bf8-0a55-0007-2321-8ac903d8f2c1', '7288846b-402d-0005-9d60-70d5ffcc5588', 'a28a3152-af47-0006-f2d4-cd47e151ae81', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('8999f09a-5c9e-0007-56b9-53ca02463f04', '7288846b-402d-0005-9d60-70d5ffcc5588', '3ad2a010-eaa8-0006-65bb-0ca2bc2067e1', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('5590e7d4-14d2-0007-cb21-cfc73d4f8046', '7288846b-402d-0005-9d60-70d5ffcc5588', '422465c2-9bd8-0006-b5d4-898e2e13cb35', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('cec50627-d96f-0007-4b21-7a795ca77fd7', '7288846b-402d-0005-9d60-70d5ffcc5588', 'd9739566-e50e-0006-d8c7-c2de6c5d715c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('36d5c248-00f2-0007-c15d-ed5bf8daef27', '7288846b-402d-0005-9d60-70d5ffcc5588', '461fb060-2fe3-0006-1aa1-5ab6b5312e57', 3, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('753e0234-9992-0007-95d8-9f98aa977822', '7288846b-402d-0005-9d60-70d5ffcc5588', 'b7472afb-4a7e-0006-96bb-0e68d3872ae0', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('eed85286-45aa-0007-2ac2-db1eb1e49b3e', '7288846b-402d-0005-9d60-70d5ffcc5588', '113a8374-52fc-0006-c4c6-82adad11f39a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9395bfa4-b4cb-0007-dca6-98e053c134e1', '7288846b-402d-0005-9d60-70d5ffcc5588', 'b0577756-ba35-0006-a8d4-188544af41a3', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f6dd5a87-2e09-0007-24fa-c363ed063b23', '7288846b-402d-0005-9d60-70d5ffcc5588', 'c88f59df-3723-0006-c120-d48c05b7bb5d', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3ee4ca8b-8801-0007-492e-153e297137c6', '7288846b-402d-0005-9d60-70d5ffcc5588', 'e9020c06-732e-0006-f407-09e2955d090b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c70426e5-6a6c-0007-d9ea-ad301b19500d', '7288846b-402d-0005-9d60-70d5ffcc5588', '93987ac8-e588-0006-2f83-a20f599bf277', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('75f548b7-faf5-0007-27e0-58dee493fab8', '7288846b-402d-0005-9d60-70d5ffcc5588', '0b91119b-27fe-0006-06f7-36a20f9bbf28', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('693a9feb-ce26-0007-6baa-b0f96711aa7c', '7288846b-402d-0005-9d60-70d5ffcc5588', '84828d5b-79fa-0006-4e1e-a6ecfad9f56d', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d093942b-3b6d-0007-8351-49c4832b002a', '7288846b-402d-0005-9d60-70d5ffcc5588', 'f5b8c9c0-8699-0006-9f72-4aef1d1e4322', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('593ef74b-2934-0007-6514-9e16fb24178c', '7288846b-402d-0005-9d60-70d5ffcc5588', '0961e655-5692-0006-4fba-9ef162a0778e', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4482f404-30b2-0007-d413-56d0fef2c1ad', '7288846b-402d-0005-9d60-70d5ffcc5588', '4e1d0810-bd2f-0006-f6b0-7e9947c4ba64', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a782ef78-e291-0007-6776-04bb058a048d', '7288846b-402d-0005-9d60-70d5ffcc5588', '4d6fd5f7-e54b-0006-dc66-f44cc929ce86', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0387fb6d-6c32-0007-7ead-304c85ea7312', '7288846b-402d-0005-9d60-70d5ffcc5588', '754dc8bf-55d6-0006-f86c-c86bcba8e4e5', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;


-- ========================================
-- Sewell Old Boys FC ROSTER
-- ========================================
INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e6909521-58ce-0007-227a-16e1e76c5e26', '50720c09-2e57-0005-da39-afc85228aaa9', 'f67ada13-a784-0006-ebe9-25878029ac0a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b085154b-ed1b-0007-4d05-1676f54cbb3a', '50720c09-2e57-0005-da39-afc85228aaa9', '9654b13d-c906-0006-5155-d62bf939456e', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a8ff47f4-ea43-0007-2aa1-312590f78673', '50720c09-2e57-0005-da39-afc85228aaa9', 'cd58ffbb-6004-0006-5e18-c6a854913706', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('35c3eed7-575f-0007-fdd4-a2fa7d5d4ec2', '50720c09-2e57-0005-da39-afc85228aaa9', '40400f0a-dc66-0006-9cac-c6f2a3164647', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('42947e41-41b5-0007-a4df-480486c8569d', '50720c09-2e57-0005-da39-afc85228aaa9', 'c3722096-f4b0-0006-dca0-cadb9fbf40e2', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('cc13d9f7-9a2e-0007-ec76-b938bff6a62a', '50720c09-2e57-0005-da39-afc85228aaa9', 'a424af65-6f03-0006-058c-a7a48d6652af', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e0e1a8fc-17f4-0007-54bd-1738f3ebe8fe', '50720c09-2e57-0005-da39-afc85228aaa9', '99bedb6f-ad6f-0006-e76f-b805ceaac7c5', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2ccb90c8-14c2-0007-ea99-975a1d19b5e3', '50720c09-2e57-0005-da39-afc85228aaa9', '7f78a7a4-91f8-0006-8b1e-e20ca1f4f8c4', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('65c0ad48-6a44-0007-8e66-126175eacbc2', '50720c09-2e57-0005-da39-afc85228aaa9', '44f85cae-c76d-0006-01db-6b4a9d57cbaa', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3f71e37a-ffac-0007-69c0-4f462bec68a1', '50720c09-2e57-0005-da39-afc85228aaa9', '9ca63f04-9f10-0006-8037-ea09de9c3d8d', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4f3eb086-7611-0007-3cb5-a08baae126b5', '50720c09-2e57-0005-da39-afc85228aaa9', 'c302c071-2de9-0006-ebe8-64dfecdc632d', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0cc69b1a-c0cf-0007-28eb-b8ceb4c88296', '50720c09-2e57-0005-da39-afc85228aaa9', 'fc451354-f699-0006-52c2-7b35e330721e', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2eaa4d66-8e86-0007-ccea-ed74e468e76f', '50720c09-2e57-0005-da39-afc85228aaa9', 'b6902b1a-2cea-0006-91ca-d82ff4c21b47', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('899683e3-7242-0007-67a6-bc1ea87fd37d', '50720c09-2e57-0005-da39-afc85228aaa9', 'a485bb5f-cf03-0006-4c35-e1ee86746e77', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2b5f364b-2503-0007-3763-9c260fa557a3', '50720c09-2e57-0005-da39-afc85228aaa9', '7f8471af-d9d1-0006-1cbb-2f3b3dd5302a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9ccbbd17-d97e-0007-b24a-e6d332370186', '50720c09-2e57-0005-da39-afc85228aaa9', '6fb1b484-4160-0006-e010-9dcf7ad6f1b6', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('54768b74-6afc-0007-3b03-eb3d6491ddea', '50720c09-2e57-0005-da39-afc85228aaa9', '9d9d8ce8-2804-0006-8ea5-b78420c974c6', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('8d46fb2b-f7de-0007-9895-04ab35071c26', '50720c09-2e57-0005-da39-afc85228aaa9', 'b032397d-d4bf-0006-1bba-abd247ca1a2b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c34a91e5-bebd-0007-1e87-4db136362eec', '50720c09-2e57-0005-da39-afc85228aaa9', '88fb1858-e71e-0006-59d5-73ed0c8e84bb', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d5e2e7ef-155b-0007-dbbc-0bd81afd27f3', '50720c09-2e57-0005-da39-afc85228aaa9', '1110bdd3-0313-0006-7007-74dc84613e90', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d6e16ada-991c-0007-4ca6-8e855e04d223', '50720c09-2e57-0005-da39-afc85228aaa9', 'd87d3cb5-33a5-0006-c1e6-f9e0579402ec', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f6f4ee98-cc6a-0007-c66b-4521791a4178', '50720c09-2e57-0005-da39-afc85228aaa9', 'f3fe8146-5c97-0006-399f-699797bf0c2a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ed7f8157-d03b-0007-7377-e482e8deaa1a', '50720c09-2e57-0005-da39-afc85228aaa9', '03994c64-9574-0006-6b6b-201159b7c622', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b85becea-793d-0007-c12f-c7776de52063', '50720c09-2e57-0005-da39-afc85228aaa9', '17212409-140e-0006-bde1-d2882b37c526', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('6b6c3aca-58c9-0007-9f77-3632130d5d64', '50720c09-2e57-0005-da39-afc85228aaa9', '0075015c-43a6-0006-70ee-053e5befbd02', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('224cf338-d2a1-0007-4da3-3d3e999390de', '50720c09-2e57-0005-da39-afc85228aaa9', '07c30bdf-4953-0006-f93d-1432d91d5e79', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('02a94fc2-2116-0007-b8d3-efd91d6358af', '50720c09-2e57-0005-da39-afc85228aaa9', 'b1aba238-fa67-0006-cdd6-41b151d70e65', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('6a0378fc-fc80-0007-f0d3-d017120e63da', '50720c09-2e57-0005-da39-afc85228aaa9', '3338fb82-78cc-0006-1a2a-3cbeb8946181', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('64e50f46-cbe2-0007-a91f-f369817c370e', '50720c09-2e57-0005-da39-afc85228aaa9', 'f5d2b265-4455-0006-401b-db41d2589cef', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4fc27254-1e7c-0007-54ac-fa846b10e4c5', '50720c09-2e57-0005-da39-afc85228aaa9', '22d562ae-e529-0006-54ec-c0631e593f17', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('dc0f4e00-5036-0007-c517-3e8537540710', '50720c09-2e57-0005-da39-afc85228aaa9', 'fbb69e9a-d0c2-0006-cbcc-00f3224ca188', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;


-- ========================================
-- Medford Strikers ROSTER
-- ========================================
INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a151bac4-c7cc-0007-efaf-39805fc13d64', '77b6674f-d598-0005-fd48-227b9e088c41', '10c64bf2-6baa-0006-73e1-c4dc5e7159fb', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a7d03258-1217-0007-7d01-c6aded2f04e4', '77b6674f-d598-0005-fd48-227b9e088c41', 'af9a3985-e5f8-0006-e9fc-85939aaced32', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0407a2b9-bf1c-0007-07d9-09876a794ae2', '77b6674f-d598-0005-fd48-227b9e088c41', 'fbb56593-54a4-0006-4579-9065523a45c3', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e3113214-390b-0007-14aa-bb3338f032af', '77b6674f-d598-0005-fd48-227b9e088c41', 'dffe5dbe-040b-0006-bd85-8db2f3135b36', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d84c6bea-06c5-0007-ad64-782a0baa7b7e', '77b6674f-d598-0005-fd48-227b9e088c41', '30037147-8072-0006-0f81-6c31d0c21693', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('77db0566-0714-0007-0a90-9fab3a96cb19', '77b6674f-d598-0005-fd48-227b9e088c41', '48c20dcb-2f20-0006-c5ca-5295605fbfd4', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f9ecec25-5f0f-0007-6387-bb7c9986f0fb', '77b6674f-d598-0005-fd48-227b9e088c41', '0fa923fb-0199-0006-0419-4bc4478fbe0d', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('56339dbc-7b10-0007-c2dd-d76c34bf5184', '77b6674f-d598-0005-fd48-227b9e088c41', '925a13c5-0dc4-0006-3d67-8bbc8278fcf1', 4, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d0646b05-7160-0007-f37a-454de0666569', '77b6674f-d598-0005-fd48-227b9e088c41', '508d8fca-1304-0006-d82d-702bd061894d', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b40e1e9a-b8e4-0007-82ab-62633d033428', '77b6674f-d598-0005-fd48-227b9e088c41', 'd122ea4b-af14-0006-d112-d22449afa224', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('78eceb24-1a31-0007-a42f-83ec071b389e', '77b6674f-d598-0005-fd48-227b9e088c41', 'a264f3b0-56ec-0006-bb04-3475d211c2b3', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('996afa8a-569e-0007-ceaf-d8e2a43269b9', '77b6674f-d598-0005-fd48-227b9e088c41', 'ad2ac504-c1a4-0006-b9ad-45d0a61406b5', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('901b03a5-4baa-0007-ac44-e1018637298d', '77b6674f-d598-0005-fd48-227b9e088c41', '01f3092d-f59c-0006-7cd8-09762ee218dd', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('931c045d-7459-0007-9cb1-6053ab8ca814', '77b6674f-d598-0005-fd48-227b9e088c41', '6710150b-5316-0006-957e-e1d5dfcd1ef6', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0edbfbd2-27e0-0007-dac4-990e23695822', '77b6674f-d598-0005-fd48-227b9e088c41', '15b07594-13e7-0006-5f64-04fef9b634be', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('79fa8377-0f99-0007-44c4-6cd2d586a7b0', '77b6674f-d598-0005-fd48-227b9e088c41', 'a63e54b5-c115-0006-610c-5b7582453ac8', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e43c0819-beec-0007-851c-8854b82e56ff', '77b6674f-d598-0005-fd48-227b9e088c41', 'aae5f4bb-bb9e-0006-4655-622b22a3613a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('17d601a6-d1ef-0007-131f-14d37389d99a', '77b6674f-d598-0005-fd48-227b9e088c41', '5799b4ee-1915-0006-27e9-7c2f5000413e', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('53c39ce9-b7ae-0007-fe3d-c425ae531d74', '77b6674f-d598-0005-fd48-227b9e088c41', '61af1611-575b-0006-cc22-1b1a6b52ebf3', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('adfc7617-14d3-0007-a8e9-64a36879af7f', '77b6674f-d598-0005-fd48-227b9e088c41', '0a1d578c-6e52-0006-3e41-8a204df067f4', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7a29bc4d-314d-0007-ba0e-d1a1ca6b477e', '77b6674f-d598-0005-fd48-227b9e088c41', '5470a7b5-3fb1-0006-90cd-f00b52a6a456', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ecb8037c-2b8f-0007-e179-f043c0d6f984', '77b6674f-d598-0005-fd48-227b9e088c41', '4e0f1372-36c2-0006-8095-0fce0252e408', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('21dce42d-03e4-0007-aac0-3eb75f07d090', '77b6674f-d598-0005-fd48-227b9e088c41', 'a66e9339-a1a8-0006-2513-a75c735cc502', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2bf24933-a72e-0007-b282-579521aea52b', '77b6674f-d598-0005-fd48-227b9e088c41', '26afb7be-8fb0-0006-33c8-bcda9fb77992', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c32c0f1b-c53c-0007-1dda-5308ca50d52f', '77b6674f-d598-0005-fd48-227b9e088c41', '9fbb2268-1902-0006-13b8-219c6ec5a61e', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('05948ba4-e205-0007-a061-b4955dc36031', '77b6674f-d598-0005-fd48-227b9e088c41', '92598d33-3c31-0006-e423-efa9e7501110', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('cd3ff698-2e21-0007-faed-4cd9e67a79e0', '77b6674f-d598-0005-fd48-227b9e088c41', 'd342c508-d98d-0006-da46-8f27574bf1db', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('cf819208-c5a9-0007-4163-0858d4670d85', '77b6674f-d598-0005-fd48-227b9e088c41', '460081a2-2618-0006-fedd-a9ade5eb0e62', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;


-- ========================================
-- Nova FC ROSTER
-- ========================================
INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('af146eab-9a76-0007-3b0a-ae937db18a0c', '4975b02e-8e62-0005-2030-8e154013c759', '8a6a205a-7cca-0006-ee76-3e7f59fc0eab', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4f6ae11b-fe53-0007-2d62-7472f6302163', '4975b02e-8e62-0005-2030-8e154013c759', '45d5a4c4-ef5c-0006-eb0e-09c8cd4e46b4', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('639b09e4-f3ab-0007-6df2-1f7222462721', '4975b02e-8e62-0005-2030-8e154013c759', '48aab16d-fb20-0006-681b-67bd4f4cfd91', 8, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('bda7219c-654f-0007-5663-3570779b2509', '4975b02e-8e62-0005-2030-8e154013c759', 'c37ca36e-55a2-0006-bc10-4a17704f2aba', 6, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('cfd690eb-4911-0007-8c25-de38c6edd963', '4975b02e-8e62-0005-2030-8e154013c759', 'f0827d85-abc0-0006-7f13-2634c79e0ca8', 3, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e06ae1e7-fe8c-0007-dec6-caa6db7acb9c', '4975b02e-8e62-0005-2030-8e154013c759', 'c7a36261-dc54-0006-6b62-6aea5179115a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1ccd063b-5199-0007-1f3b-4a3b9e8a9aa4', '4975b02e-8e62-0005-2030-8e154013c759', '8ce4b98f-bddc-0006-0d98-1338435df600', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1a285b2f-c673-0007-f32f-65a1cff79887', '4975b02e-8e62-0005-2030-8e154013c759', '60c49765-32d8-0006-431d-dc5ad9b18356', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2b3398f6-21cd-0007-4a3b-3e648917a8d0', '4975b02e-8e62-0005-2030-8e154013c759', 'b1a6c4ac-10bb-0006-5e23-0dff3660db9b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('5666180e-e0aa-0007-fa0f-09c3a4574210', '4975b02e-8e62-0005-2030-8e154013c759', 'bc7181a2-4b25-0006-af63-0e246c4037cd', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e6e94e61-85c8-0007-86bf-bf82497a80ed', '4975b02e-8e62-0005-2030-8e154013c759', 'e177526e-2320-0006-f5ba-a8f1e234f3be', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('52a20a2e-6bba-0007-1e8c-c433f0163bf4', '4975b02e-8e62-0005-2030-8e154013c759', '2d7e92c3-5921-0006-28e6-f2137efdfb9e', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('8fb2a524-0525-0007-b493-b4bd44d363fb', '4975b02e-8e62-0005-2030-8e154013c759', '71bb9e82-4cb7-0006-40d7-936076c8e8ec', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('6f9f0eda-3278-0007-9766-2e60776928b4', '4975b02e-8e62-0005-2030-8e154013c759', '001e3f63-03ff-0006-e0cb-b68637bc78b0', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('661e922b-11b6-0007-91cd-87ca5082fb9c', '4975b02e-8e62-0005-2030-8e154013c759', 'd3cce29f-cce8-0006-39a9-9607eaaf5d59', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c09d7d45-b1a8-0007-aaba-8f463a8324af', '4975b02e-8e62-0005-2030-8e154013c759', 'b26687b7-c0ad-0006-40a7-048372c8ff0c', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('687cb0b6-15e9-0007-5a91-c4b97a392667', '4975b02e-8e62-0005-2030-8e154013c759', '2c55d1a3-6031-0006-fadb-27e9d829d446', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9ca2a2e8-305f-0007-7070-cce97d81e33f', '4975b02e-8e62-0005-2030-8e154013c759', '5bca2e0e-cda8-0006-d1d9-33cf56343833', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9383a202-85bd-0007-351f-a3fb5d43e475', '4975b02e-8e62-0005-2030-8e154013c759', '2b8a0534-c0d8-0006-726b-83f07f31876c', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('14b33d50-dd84-0007-c8ed-68698eb8d9f7', '4975b02e-8e62-0005-2030-8e154013c759', 'f84cb700-50b2-0006-9928-6e32e60feb13', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('5f3dbb7c-853f-0007-8de8-bab09311eaf5', '4975b02e-8e62-0005-2030-8e154013c759', 'e1149adc-7f7a-0006-0210-ea26443b3b5d', 3, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d472ff15-a0c3-0007-7f7e-76abbbf140b4', '4975b02e-8e62-0005-2030-8e154013c759', 'dc43183b-098f-0006-ab96-acbd14956817', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4b8c7ada-9f32-0007-6e52-cb0ef4e5156f', '4975b02e-8e62-0005-2030-8e154013c759', 'a1159155-0905-0006-880e-7923df18e59e', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e3326fb1-3743-0007-d704-82d0b9fb0583', '4975b02e-8e62-0005-2030-8e154013c759', '7b3211b1-ff0f-0006-6f39-4aba9902f2c2', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a44f3e73-0c48-0007-4b68-594f7eed890a', '4975b02e-8e62-0005-2030-8e154013c759', '4c3e723e-57cd-0006-54b5-b1bc2e6cc04b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('63df6151-ee95-0007-b446-2a7dc5bc1108', '4975b02e-8e62-0005-2030-8e154013c759', '5d99de83-596b-0006-92f2-61221f51b7c5', 3, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('620876d8-8508-0007-98f9-6aac44a1dbe0', '4975b02e-8e62-0005-2030-8e154013c759', '0e184784-501e-0006-560b-114ceac199af', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4022fff5-9ce1-0007-7b03-3589f1a7a6dc', '4975b02e-8e62-0005-2030-8e154013c759', '3ff56ceb-c246-0006-b53c-fc1fbfad202a', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;


-- ========================================
-- Wave FC ROSTER
-- ========================================
INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ca422d81-7478-0007-ab60-fd7f42bee1cd', '5cb8a2b2-4ca8-0005-2d81-819249f89f0d', '20e6091b-ef8a-0006-b6dc-5cace4e9062a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('87387e2c-3582-0007-8cab-06e775347f77', '5cb8a2b2-4ca8-0005-2d81-819249f89f0d', '87387418-7b00-0006-077b-bdb995f8c3e2', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e3c30fec-8d9c-0007-5f6c-7cd912d7780f', '5cb8a2b2-4ca8-0005-2d81-819249f89f0d', 'df498f7d-636c-0006-9732-fa812c1f3664', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e7d12fb1-a418-0007-00b3-37863b185aa2', '5cb8a2b2-4ca8-0005-2d81-819249f89f0d', 'fc21351c-aae7-0006-6442-3945dac8b4fc', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b6dabdc8-e5aa-0007-7ada-a91813e480e1', '5cb8a2b2-4ca8-0005-2d81-819249f89f0d', '2c9a88cd-82fb-0006-2c5e-2f62c52a4464', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0e136234-7c3a-0007-39f5-b0804f32784f', '5cb8a2b2-4ca8-0005-2d81-819249f89f0d', '81b97b1d-984e-0006-5515-ca68706b841a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('47786ec2-265a-0007-d641-50bf63369d9f', '5cb8a2b2-4ca8-0005-2d81-819249f89f0d', 'a84aae62-0d93-0006-cd06-f8356af5e028', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e901cfdb-21a2-0007-6f96-32f893ff98af', '5cb8a2b2-4ca8-0005-2d81-819249f89f0d', '62c2d5b3-c033-0006-6db4-512430ec4220', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('641a2dd3-58ab-0007-b4c3-06b2d883b5f0', '5cb8a2b2-4ca8-0005-2d81-819249f89f0d', 'a2a4e33a-12ee-0006-2a86-feceb991b495', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1e9fa4d7-6072-0007-f756-e6758ce34d33', '5cb8a2b2-4ca8-0005-2d81-819249f89f0d', 'a5249549-ad69-0006-c1de-c3d6cd2a33d0', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('33e114b3-6712-0007-4f02-d4de5d439155', '5cb8a2b2-4ca8-0005-2d81-819249f89f0d', '7a2f2756-e33a-0006-a3ea-d7a18d4209b6', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('aaee8dd0-7d3b-0007-0ceb-5badf31b543e', '5cb8a2b2-4ca8-0005-2d81-819249f89f0d', 'a273ff71-c957-0006-6070-a1e27e7ca0b2', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0ccc68d9-8020-0007-96c4-d81af4baddbe', '5cb8a2b2-4ca8-0005-2d81-819249f89f0d', '239583df-4fe8-0006-3034-9dfc2bdd9482', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('23840064-cb30-0007-d957-325f328251e3', '5cb8a2b2-4ca8-0005-2d81-819249f89f0d', '640c3a9c-b6c6-0006-e83f-323b6ce3beaa', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7a424e55-22ea-0007-8d78-323204b8f538', '5cb8a2b2-4ca8-0005-2d81-819249f89f0d', 'bc24c6de-a0d3-0006-a3cf-1f60497856f2', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('838a3d5e-a9c1-0007-4fb5-f31492999580', '5cb8a2b2-4ca8-0005-2d81-819249f89f0d', 'db125199-f694-0006-0d79-f905a10a14ca', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('cec9121b-790d-0007-7c79-60d0d167b52f', '5cb8a2b2-4ca8-0005-2d81-819249f89f0d', 'c0f033c9-099c-0006-e1cc-c6ef0905036f', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('5a6dcb85-e5d3-0007-f9ae-a0aa7cd6bd7b', '5cb8a2b2-4ca8-0005-2d81-819249f89f0d', '1a244857-4875-0006-d0c7-8a57ad9bdcf6', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c60fd37c-ff3a-0007-dcce-dd4c534a53ad', '5cb8a2b2-4ca8-0005-2d81-819249f89f0d', '99151dfb-a66d-0006-8760-66833514e424', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('35920cc0-0d99-0007-4334-d1c71e7b99b5', '5cb8a2b2-4ca8-0005-2d81-819249f89f0d', '9a681699-c706-0006-d690-cd03c0af65bb', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9d8a5a0f-a56d-0007-044d-a461c9ca1a25', '5cb8a2b2-4ca8-0005-2d81-819249f89f0d', '116361d2-5a35-0006-6f45-7a44bb6aef3b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e1721345-238a-0007-b651-f4607a401946', '5cb8a2b2-4ca8-0005-2d81-819249f89f0d', '4ef606d4-a361-0006-0c7b-54c98cd1d702', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7a66cf67-3117-0007-64bc-e2836842f608', '5cb8a2b2-4ca8-0005-2d81-819249f89f0d', '52dfa7e3-1ecb-0006-4988-91aaf12b3e53', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d513c4d0-4fb7-0007-eb80-eab89f48f3ac', '5cb8a2b2-4ca8-0005-2d81-819249f89f0d', '1acd7741-fa53-0006-85e6-46da5dc5c984', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('6241c0a9-26a3-0007-86e8-2853f0bf973b', '5cb8a2b2-4ca8-0005-2d81-819249f89f0d', '2cf19d93-a04a-0006-c947-5da7b9df7ad9', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ff9f8175-70e5-0007-f56e-9c5ec05f951e', '5cb8a2b2-4ca8-0005-2d81-819249f89f0d', '4a163bd5-9295-0006-0263-2d7d93b3eecf', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('8f8caef1-54a2-0007-f45f-b69c5a3cfa15', '5cb8a2b2-4ca8-0005-2d81-819249f89f0d', '5226f800-990b-0006-9d53-fad17a37e1db', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('5f6c1139-bcc2-0007-f874-81cd5995ef48', '5cb8a2b2-4ca8-0005-2d81-819249f89f0d', 'c3aa1522-f07a-0006-c2f6-b9c72d4dcd6c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('5133cd7b-55f1-0007-2b6a-6750758ec047', '5cb8a2b2-4ca8-0005-2d81-819249f89f0d', '3402a511-9820-0006-14cd-a657dbbc7768', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('dd81b095-6b3f-0007-97bb-4ff3d0dd6cd4', '5cb8a2b2-4ca8-0005-2d81-819249f89f0d', '7e52798f-e99b-0006-c264-9155c44f309d', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7ba680d8-d295-0007-f060-1774cf64878b', '5cb8a2b2-4ca8-0005-2d81-819249f89f0d', '86e35fb6-59bb-0006-c9d2-3adacb7eac51', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('28d339b4-9ed5-0007-0ade-84e51ade4ba1', '5cb8a2b2-4ca8-0005-2d81-819249f89f0d', 'cb80d2e0-2811-0006-688d-4f0227005854', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('6f711e56-e776-0007-a624-931e9e2af7d7', '5cb8a2b2-4ca8-0005-2d81-819249f89f0d', '85ca48c0-51a6-0006-7f1d-890682279cf4', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e80e0396-eb47-0007-b0f1-c3a3f623fa75', '5cb8a2b2-4ca8-0005-2d81-819249f89f0d', 'efa170cb-fb00-0006-c691-39d6f16942d3', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;


-- ========================================
-- VA Marauders FC ROSTER
-- ========================================
INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2f7448eb-6e5c-0007-30cf-78a3ddbe8427', '8d88ffe1-06ae-0005-6f19-0e9432e55afa', 'ea38911e-019d-0006-81cf-bfc1c41cfcd0', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('868a849d-5197-0007-7b9f-2fa7f88b6c5d', '8d88ffe1-06ae-0005-6f19-0e9432e55afa', '0dd7c57d-e353-0006-d135-0774bfa60140', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d2f550f2-44e3-0007-99d0-87e5ffd244c9', '8d88ffe1-06ae-0005-6f19-0e9432e55afa', '92c1fcf6-6001-0006-4635-14bea9e9460f', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('70177e7c-1272-0007-348f-95701407a0de', '8d88ffe1-06ae-0005-6f19-0e9432e55afa', '435d0f98-c5c5-0006-a17d-dcc67e5cd7ca', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ece29cbf-2157-0007-cdc8-47487da4cd1e', '8d88ffe1-06ae-0005-6f19-0e9432e55afa', '29398684-3ef4-0006-c080-d3c3059cfd2a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('da019c74-af09-0007-e667-0116ea4c71c4', '8d88ffe1-06ae-0005-6f19-0e9432e55afa', 'd37e87f6-7532-0006-fe63-7fce9ece4af2', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('aac726ca-afb2-0007-6dc8-799c82bd4601', '8d88ffe1-06ae-0005-6f19-0e9432e55afa', '6f057637-94c4-0006-6792-2c7c3ee81d0b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9a466e2b-245c-0007-df2c-9b80e649dd99', '8d88ffe1-06ae-0005-6f19-0e9432e55afa', '277e6125-119d-0006-6a56-2940e99d02d5', 4, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e50736d8-2aa7-0007-8230-48572ab92e1e', '8d88ffe1-06ae-0005-6f19-0e9432e55afa', '1d32585f-3f4a-0006-8be7-04c981cb85c3', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('6be2d4aa-9496-0007-f67b-8e49af4fdce3', '8d88ffe1-06ae-0005-6f19-0e9432e55afa', '0baccd7f-4b0a-0006-926d-dac754e8ffb6', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('75b66cc9-9fa3-0007-a270-3bcfb348451d', '8d88ffe1-06ae-0005-6f19-0e9432e55afa', 'acefe636-051e-0006-d10e-3ed76f115f9e', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c01a7b1e-20ca-0007-3caf-9c477c42e4e6', '8d88ffe1-06ae-0005-6f19-0e9432e55afa', '7ece1a85-0658-0006-ed39-949b915ae36b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9859909b-4bf8-0007-472a-1af83fd1f8a8', '8d88ffe1-06ae-0005-6f19-0e9432e55afa', '5fbf7c9c-03ed-0006-4a3b-2ba971fc7696', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('5ff1db33-b764-0007-b003-f161ca79c56f', '8d88ffe1-06ae-0005-6f19-0e9432e55afa', '0aabd123-2a74-0006-8c42-c9dace9a21f0', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('17a1979c-0f54-0007-83e6-81122c7bf4e1', '8d88ffe1-06ae-0005-6f19-0e9432e55afa', 'a16b014e-2c6d-0006-ac02-4c627c4e655a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ea817084-fa16-0007-f581-d77cd4da9692', '8d88ffe1-06ae-0005-6f19-0e9432e55afa', '1009b741-c6e6-0006-76eb-9010e50b2993', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('5d3ab356-b702-0007-11a3-97ac91871c55', '8d88ffe1-06ae-0005-6f19-0e9432e55afa', '658e515c-2ef6-0006-be04-29dc186dcb09', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('19e12e67-ba23-0007-2f96-a23e0881d749', '8d88ffe1-06ae-0005-6f19-0e9432e55afa', '91aeff3b-dff6-0006-8456-e080dd721d51', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0243cbf4-94a0-0007-6a3f-da945386ab02', '8d88ffe1-06ae-0005-6f19-0e9432e55afa', 'a6ff11bf-d379-0006-f617-671c8a047de9', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f85becf6-1f26-0007-b658-011b28e0c9ff', '8d88ffe1-06ae-0005-6f19-0e9432e55afa', '0b378add-0d84-0006-d943-5a550f1dd937', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('18877c4d-5543-0007-1cef-b168e7e81711', '8d88ffe1-06ae-0005-6f19-0e9432e55afa', 'a2354141-8f01-0006-8593-be6028f61131', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('58caf081-4951-0007-3588-1d01c3ddf191', '8d88ffe1-06ae-0005-6f19-0e9432e55afa', '62fb4994-83a7-0006-698e-b2e4013a26f9', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('5d4fe3e5-1721-0007-dc62-f18781f92421', '8d88ffe1-06ae-0005-6f19-0e9432e55afa', 'f9211e29-5fd2-0006-4600-8c2076b8fd22', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('366a996c-9d1d-0007-4318-95728f935655', '8d88ffe1-06ae-0005-6f19-0e9432e55afa', 'f70c9844-16f8-0006-6c22-7cc383ed3c09', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('30f6da0e-49ef-0007-49ec-fc6e60abb842', '8d88ffe1-06ae-0005-6f19-0e9432e55afa', '39b58c47-9ace-0006-e346-42d6004e3c86', 4, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('352ecea0-9216-0007-55ee-62b417b2cc55', '8d88ffe1-06ae-0005-6f19-0e9432e55afa', '5a9b1fa9-15a0-0006-5c98-46671150599d', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2efe7aac-44af-0007-4b19-07d290f3e20f', '8d88ffe1-06ae-0005-6f19-0e9432e55afa', '12272fb5-404e-0006-03ea-f3f0271ac232', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e650cdd6-347a-0007-4acd-48896000ccc3', '8d88ffe1-06ae-0005-6f19-0e9432e55afa', '3a2385ea-ca52-0006-e0fb-6814ce92615d', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('85812fef-309a-0007-f825-7c7ebe5e56d2', '8d88ffe1-06ae-0005-6f19-0e9432e55afa', 'cba566f5-e1e1-0006-cdd0-495973f019da', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0d05e752-800b-0007-edb7-f5215fa6003f', '8d88ffe1-06ae-0005-6f19-0e9432e55afa', '7ef2ec8a-d549-0006-e78e-14edbbe77b3b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('521b033d-a642-0007-00e1-ab863473740e', '8d88ffe1-06ae-0005-6f19-0e9432e55afa', '5e4eb7b1-35f0-0006-34dc-8df8d72eb5c9', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('217528bd-822f-0007-7651-3492682cf6bb', '8d88ffe1-06ae-0005-6f19-0e9432e55afa', '21232c35-692c-0006-7b68-abe14089578e', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('43dd1bdf-c45e-0007-f91f-f58d72da8f6b', '8d88ffe1-06ae-0005-6f19-0e9432e55afa', '3da5238e-ee63-0006-eb33-103b30f768c3', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f6a5c072-bdb9-0007-264f-0e096bc420b1', '8d88ffe1-06ae-0005-6f19-0e9432e55afa', '1f9abd6d-6fed-0006-f5b3-8727016e1dab', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;


-- ========================================
-- Grove Soccer United ROSTER
-- ========================================
INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e3ebf647-b87b-0007-8218-f932d546df9a', 'cf7f17f3-b83d-0005-856e-8a0b8da24008', '23ea29e7-81cf-0006-4e02-a09554130215', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('8c6d98ea-6daa-0007-4065-41a3faa538e9', 'cf7f17f3-b83d-0005-856e-8a0b8da24008', '6fb82b85-82c8-0006-c127-b5810aefd1bd', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1f6c739a-ff4f-0007-e95b-28f257094ad2', 'cf7f17f3-b83d-0005-856e-8a0b8da24008', 'f0463993-b06b-0006-2a7a-6850c655de78', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('43e8b9f8-522d-0007-b280-459824ba32be', 'cf7f17f3-b83d-0005-856e-8a0b8da24008', 'e0806b14-5724-0006-9037-6b74f806841a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('08acdfb6-5303-0007-c4d3-ffed0993f381', 'cf7f17f3-b83d-0005-856e-8a0b8da24008', '50f1bece-6c6b-0006-357c-e3b45fd115c4', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d25063d7-b4f6-0007-f78a-ab8e5c0d4e04', 'cf7f17f3-b83d-0005-856e-8a0b8da24008', 'a30d63ca-d94c-0006-a72e-6dcc1d5bf020', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('bf32fac5-e205-0007-4e1d-a0891f99065a', 'cf7f17f3-b83d-0005-856e-8a0b8da24008', 'a4ef4295-5ca9-0006-96e3-479449289fe9', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b603dc15-6aac-0007-438e-e0be49049574', 'cf7f17f3-b83d-0005-856e-8a0b8da24008', 'c39ad8aa-5a3f-0006-c2d0-a54413adba27', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c8cde3cb-06dc-0007-3652-be616c3a1708', 'cf7f17f3-b83d-0005-856e-8a0b8da24008', 'd0d33fce-1b6c-0006-afc1-56aaa6df65fa', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('31cf0f10-3d49-0007-59a2-acb500906368', 'cf7f17f3-b83d-0005-856e-8a0b8da24008', '561848c2-b312-0006-0783-7fff45415975', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2579d53b-052e-0007-1b8c-008879300133', 'cf7f17f3-b83d-0005-856e-8a0b8da24008', '7cdb0545-2f44-0006-1096-5dc302f5286d', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1577673d-1f40-0007-4ade-5d4ce2321a7b', 'cf7f17f3-b83d-0005-856e-8a0b8da24008', '52c76170-7887-0006-8b05-19da43b3c2f4', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f3ebdf61-9a67-0007-971c-576049130101', 'cf7f17f3-b83d-0005-856e-8a0b8da24008', 'a26325bd-5481-0006-6b38-74140bd26764', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3039ee91-9689-0007-91f5-f706a847384b', 'cf7f17f3-b83d-0005-856e-8a0b8da24008', 'b5090f1e-9518-0006-9c87-34cfb1fd341e', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ddc400e7-5174-0007-62a7-9ad53e9d5012', 'cf7f17f3-b83d-0005-856e-8a0b8da24008', '151e4a1c-3e30-0006-c975-e47bef2f2278', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f1350010-f0de-0007-81ff-59e33d4bcedd', 'cf7f17f3-b83d-0005-856e-8a0b8da24008', '08030ed2-2cd9-0006-c708-be58ec3dcc2c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d89b118e-dba0-0007-76aa-120f2a618798', 'cf7f17f3-b83d-0005-856e-8a0b8da24008', '6dc0cea6-2e8c-0006-e11d-230cf0743d4f', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f966e34b-3626-0007-43b3-81231faa3bd9', 'cf7f17f3-b83d-0005-856e-8a0b8da24008', '36cd179d-bdfb-0006-b2e6-1456e0915c14', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4c9af78a-a856-0007-0752-78ae5f47b178', 'cf7f17f3-b83d-0005-856e-8a0b8da24008', 'b4fa1466-18e0-0006-4f5a-73d74b61be16', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4c4b9c0c-2acd-0007-58e5-5b6966dbc6e3', 'cf7f17f3-b83d-0005-856e-8a0b8da24008', '38441d7e-c4d3-0006-022e-5717d61a3c7d', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3fd078b5-3b29-0007-c431-afc4c64774b7', 'cf7f17f3-b83d-0005-856e-8a0b8da24008', '68c28c9c-92d5-0006-f9f6-098659f55cbb', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('372167a0-a77b-0007-1855-68098f17ef28', 'cf7f17f3-b83d-0005-856e-8a0b8da24008', '2e342b93-a22f-0006-8be0-75886cd2ca2b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b2717407-64e0-0007-085f-01e261edce07', 'cf7f17f3-b83d-0005-856e-8a0b8da24008', 'fcebd2a9-8da2-0006-2d89-353c07835885', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('15bbb237-15a6-0007-77d6-77f9cbb03a28', 'cf7f17f3-b83d-0005-856e-8a0b8da24008', '8debf748-486f-0006-84c6-ad67e6441dbf', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e3dad4db-9132-0007-7230-723ba231ab21', 'cf7f17f3-b83d-0005-856e-8a0b8da24008', '8920a87e-34d2-0006-a308-cede08b5bc85', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('08ed1962-adf9-0007-edd2-555498f341c9', 'cf7f17f3-b83d-0005-856e-8a0b8da24008', 'e26fc5a5-aae4-0006-1ed6-c958d572a650', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2eef885d-f612-0007-33ca-eb3d9890ef24', 'cf7f17f3-b83d-0005-856e-8a0b8da24008', 'a092dbbc-19fe-0006-ff40-6dbb0d8cd7ab', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('186b367c-3fd6-0007-1019-38ed51d5cdf3', 'cf7f17f3-b83d-0005-856e-8a0b8da24008', 'e2301c14-3b50-0006-62c0-fec1e02ea225', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('392ef55d-caf4-0007-60bb-996537344407', 'cf7f17f3-b83d-0005-856e-8a0b8da24008', '87aafe06-e1bc-0006-8719-606a00d56566', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('27b9fa9d-83d3-0007-ffff-fbb1cd87525c', 'cf7f17f3-b83d-0005-856e-8a0b8da24008', '8aaa0937-ebcc-0006-f7b5-9bf199cfeb71', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a7369bf2-3e86-0007-fcd3-a1c3bed8a6e6', 'cf7f17f3-b83d-0005-856e-8a0b8da24008', 'f734dd37-51b8-0006-01f9-8fb693083318', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('265911c6-d8d2-0007-11f0-9295b28223ba', 'cf7f17f3-b83d-0005-856e-8a0b8da24008', 'd2297d62-19c2-0006-954a-159d8224b632', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('abb2f36a-43d5-0007-bcf2-0db8f946c103', 'cf7f17f3-b83d-0005-856e-8a0b8da24008', '34fa5e05-0285-0006-6072-68514344a498', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('18a9433b-6986-0007-d0f9-bd396daf34db', 'cf7f17f3-b83d-0005-856e-8a0b8da24008', 'bb5ddd63-4504-0006-63a6-e06d34a35778', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('956ba091-77af-0007-ba58-38a0b9d9171f', 'cf7f17f3-b83d-0005-856e-8a0b8da24008', '92497df4-e9a9-0006-e063-27471ad9ef92', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;


-- ========================================
-- Christos FC ROSTER
-- ========================================
INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('566e49df-4ee4-0007-84d3-145cad1a53d5', '226c892a-a28d-0005-ad0a-f9435e13f4e2', 'dd409a66-46d7-0006-70f8-0a14e258eaf7', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('02936f98-4f00-0007-9428-564ba6052360', '226c892a-a28d-0005-ad0a-f9435e13f4e2', '7a2c7c6a-2f56-0006-a6e4-2a8f83ded7b4', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('88c44b34-77dc-0007-f008-a80b432d6632', '226c892a-a28d-0005-ad0a-f9435e13f4e2', 'b0e131c5-5e29-0006-7695-a6fd033a0f6c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('8d479c6f-e0a4-0007-9f3c-697190f1cd9d', '226c892a-a28d-0005-ad0a-f9435e13f4e2', '52e7ca86-5766-0006-f79a-a21a61517a7c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c5441b8c-89e8-0007-c7ab-64c561402ed4', '226c892a-a28d-0005-ad0a-f9435e13f4e2', '5255f81f-10fa-0006-1930-cd1789821549', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a10e7dde-4db1-0007-6912-09340b94a39d', '226c892a-a28d-0005-ad0a-f9435e13f4e2', '63bf5588-9ee9-0006-2f7e-77aabf55da30', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('526ee6b7-4790-0007-dada-4238e4991bf7', '226c892a-a28d-0005-ad0a-f9435e13f4e2', '8fe190e3-c920-0006-68cd-218cf87f60fd', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b863083e-e083-0007-fd5f-6dc88ae9045a', '226c892a-a28d-0005-ad0a-f9435e13f4e2', '84c7faec-4ba6-0006-5c3f-d2bdecdad548', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b2cec45c-343a-0007-f2dd-be2616915c04', '226c892a-a28d-0005-ad0a-f9435e13f4e2', '91ef5b6d-6015-0006-60e4-624cbb154c49', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3769f341-ffb7-0007-2444-3b38bafe31cb', '226c892a-a28d-0005-ad0a-f9435e13f4e2', '22136d87-cbbb-0006-2f69-71538eff6273', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d3df8ab3-c327-0007-f09a-f1ad3e3dfa93', '226c892a-a28d-0005-ad0a-f9435e13f4e2', '356a928a-8f0a-0006-c418-7e71522a839c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('dc843f58-2cd7-0007-cccc-ca11809f3d0a', '226c892a-a28d-0005-ad0a-f9435e13f4e2', '7d0d00de-c7c6-0006-0130-6004ba5e4c19', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('87cc5a91-a27d-0007-f08e-28db1e7828f9', '226c892a-a28d-0005-ad0a-f9435e13f4e2', 'dc532d6e-59de-0006-c495-e77acdb897e8', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2fde38b9-f817-0007-5bfd-996f04f3974a', '226c892a-a28d-0005-ad0a-f9435e13f4e2', '99a88530-8f78-0006-f5d3-333681f52037', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('029d1f88-e972-0007-4e22-01dd50574f87', '226c892a-a28d-0005-ad0a-f9435e13f4e2', 'e7c75c11-eef1-0006-2405-af8d26aa95e9', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d2d035e7-7440-0007-d6c9-e613f1e6f3f2', '226c892a-a28d-0005-ad0a-f9435e13f4e2', '0ed2c9cd-97db-0006-e9e4-21702bfc1f3c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('6ef7e7d7-aa0e-0007-8bbf-d84f24cf5023', '226c892a-a28d-0005-ad0a-f9435e13f4e2', '96f11540-24ce-0006-f53e-9d589d007775', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('8dc338af-fc9c-0007-9432-7e727bf7fcb8', '226c892a-a28d-0005-ad0a-f9435e13f4e2', 'd672e7ef-09bd-0006-eb6b-a2a032fa1bc5', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('246bef32-7bf9-0007-e4e2-d0718a640c32', '226c892a-a28d-0005-ad0a-f9435e13f4e2', '7552f1c4-bd1f-0006-1940-c6ed38817eb5', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d90463d9-3e7e-0007-d65b-53c895b60ace', '226c892a-a28d-0005-ad0a-f9435e13f4e2', '5314308f-b807-0006-a1f0-8790e46cd3c0', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('749c8b8c-d1f7-0007-9089-639730c3892e', '226c892a-a28d-0005-ad0a-f9435e13f4e2', 'c2b0d43d-1aed-0006-fe44-7c74442372c6', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('efe90549-40d2-0007-e359-d496cffb4daa', '226c892a-a28d-0005-ad0a-f9435e13f4e2', '106523d4-7801-0006-884c-2b45f2ebe99c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ef2276fe-dd47-0007-9a9b-53339967c9b1', '226c892a-a28d-0005-ad0a-f9435e13f4e2', '73f5c0b1-dea1-0006-b51a-3c7e146bf1e2', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('cb1f0495-dd4a-0007-be25-f9b4e00c96e2', '226c892a-a28d-0005-ad0a-f9435e13f4e2', '82df00b4-306f-0006-4b3c-b72835c5a454', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('8b8bf0b5-3f79-0007-db41-ee8f73ce35cb', '226c892a-a28d-0005-ad0a-f9435e13f4e2', 'c15eff76-d18e-0006-0ed3-b1cc0ebdffb4', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('33218d1d-9c11-0007-e5bc-dfdf713bafaa', '226c892a-a28d-0005-ad0a-f9435e13f4e2', '72af4ed6-8aa7-0006-9f51-cf2fc23d99a0', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('320f86a1-77e7-0007-e987-9b00b57ea874', '226c892a-a28d-0005-ad0a-f9435e13f4e2', '53a94b23-4dda-0006-5cee-f00a7e789ce3', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d99d537f-b613-0007-e564-ff2da0e0b9ca', '226c892a-a28d-0005-ad0a-f9435e13f4e2', '450c8fe9-f510-0006-7532-c98bd3223028', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9b5c8a3e-a596-0007-23c2-d79ef89fa5e5', '226c892a-a28d-0005-ad0a-f9435e13f4e2', '5d528abd-6bb7-0006-4e82-ccaf432fa1b8', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ccd5ad10-d2a1-0007-fa54-d42293515c75', '226c892a-a28d-0005-ad0a-f9435e13f4e2', '5fa60a7c-73a8-0006-d11e-a434cca23aa0', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('6650cfc7-674f-0007-26be-c196bef7f662', '226c892a-a28d-0005-ad0a-f9435e13f4e2', 'e053c640-4464-0006-bec5-cff27b9876d2', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;


-- ========================================
-- PFA EPSL ROSTER
-- ========================================
INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('deceb1b9-e1d2-0007-87c2-ec324a13b1be', 'd8e57bbb-92dd-0005-95c3-76a8d99bb683', '41672236-053b-0006-463b-fafde1f83fae', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7a3eea30-f79f-0007-7cb8-9b55127c1bcd', 'd8e57bbb-92dd-0005-95c3-76a8d99bb683', 'ed7beb1e-57c6-0006-a964-c023ca33f018', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3e0d3916-a168-0007-df2c-bc522e6faafa', 'd8e57bbb-92dd-0005-95c3-76a8d99bb683', '4cdb4fec-a108-0006-3024-21c1b0e93639', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0984bcea-f2c4-0007-eb99-f617e08998cb', 'd8e57bbb-92dd-0005-95c3-76a8d99bb683', '1e9c5a6b-2745-0006-0d37-2dedaf509ac5', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ea362a9a-648f-0007-1bfc-20bad4beff2d', 'd8e57bbb-92dd-0005-95c3-76a8d99bb683', '964640a2-b0cf-0006-4e8d-81e9aae27abd', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c207dc86-d5bf-0007-ce08-b73e8767abee', 'd8e57bbb-92dd-0005-95c3-76a8d99bb683', 'd54ec81f-b9e7-0006-1d81-59496222bc4f', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('980d7f92-fd9b-0007-b989-d3e9e30b3ad5', 'd8e57bbb-92dd-0005-95c3-76a8d99bb683', 'a49747f8-58b4-0006-8041-226baa7079e7', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('50b9ba3b-688a-0007-be33-bf65436ba332', 'd8e57bbb-92dd-0005-95c3-76a8d99bb683', 'e0c00c53-343a-0006-26d7-66a07377ce63', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3d0418fd-e2a7-0007-7175-dcf6c6e01150', 'd8e57bbb-92dd-0005-95c3-76a8d99bb683', '84632a56-d3a0-0006-e06c-cd25e193c0ad', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e84a8ef4-70b3-0007-b4e7-5692c6506c13', 'd8e57bbb-92dd-0005-95c3-76a8d99bb683', 'a78dba3d-3536-0006-8d37-50d5efe78a6c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d9953bae-e883-0007-2c1c-ba274bd619ca', 'd8e57bbb-92dd-0005-95c3-76a8d99bb683', 'b4bf0347-1334-0006-5e3e-39d900d3586a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1ef0b461-18a6-0007-0e3a-c1a2a5dcb58a', 'd8e57bbb-92dd-0005-95c3-76a8d99bb683', '685cc3fa-5ca9-0006-65da-2672fa97abb0', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c66e0e61-4729-0007-0a26-98379465cb0e', 'd8e57bbb-92dd-0005-95c3-76a8d99bb683', 'e1f2ff52-2f1e-0006-5751-60640491d25a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('5c04f4bb-328e-0007-93f1-e0d0c7bd1789', 'd8e57bbb-92dd-0005-95c3-76a8d99bb683', '60d1ae3b-be7e-0006-87eb-488dd99cd9ae', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('540cbbb3-fe09-0007-90fe-933b98ec8aba', 'd8e57bbb-92dd-0005-95c3-76a8d99bb683', '7f6fe638-59cb-0006-bebe-1f409a3cdb5e', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7ff30af4-47ad-0007-56b1-195b53943943', 'd8e57bbb-92dd-0005-95c3-76a8d99bb683', '6fe26ee6-c0a5-0006-1027-eeb53062dbf3', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('20b237bc-dd0f-0007-3b29-7352b4ac7031', 'd8e57bbb-92dd-0005-95c3-76a8d99bb683', '2df93f06-45fc-0006-1abf-ce95b342a265', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('899f5e0c-98ed-0007-594c-23adec7b582d', 'd8e57bbb-92dd-0005-95c3-76a8d99bb683', '61d004c0-a7db-0006-70c5-ce75941d3c80', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('29c7f9d2-46a0-0007-55fb-0562d0595a61', 'd8e57bbb-92dd-0005-95c3-76a8d99bb683', '91c7c07c-ddd4-0006-bb1d-ab37cffcd990', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e74d05a0-ead2-0007-5018-10419100e8fa', 'd8e57bbb-92dd-0005-95c3-76a8d99bb683', 'd95fdaf2-6af8-0006-3428-4a34e9ac6d8e', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9f3d7515-1db9-0007-d2f1-f09b59b76f12', 'd8e57bbb-92dd-0005-95c3-76a8d99bb683', 'a2c3b15d-df06-0006-c45f-c7e1d63c8dd0', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a62086d6-287d-0007-4700-999cb3db0374', 'd8e57bbb-92dd-0005-95c3-76a8d99bb683', 'b1fe8bfd-cc5e-0006-7327-3b331cfbf6ca', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('8b813f09-be3a-0007-d4d3-4288cf29924c', 'd8e57bbb-92dd-0005-95c3-76a8d99bb683', '06e0323c-007c-0006-25c3-983115664737', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a3788ff6-3965-0007-2a6a-cff6bbc1653e', 'd8e57bbb-92dd-0005-95c3-76a8d99bb683', 'f7594491-6bda-0006-bcd1-ce32af311366', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;


-- ========================================
-- PW Nova ROSTER
-- ========================================
INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('68dbd65e-61ce-0007-1a11-cd0a64baee6c', '7425cb8d-f81d-0005-8a67-7aa5c9dd6023', '55d1669d-900d-0006-5b25-e71fbd385c73', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2bb41ca6-3e0f-0007-9886-99db8128c934', '7425cb8d-f81d-0005-8a67-7aa5c9dd6023', 'bde03f16-fc9e-0006-7f1f-07a163e91845', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('02dabe80-454a-0007-22e7-1b172e02f186', '7425cb8d-f81d-0005-8a67-7aa5c9dd6023', 'ba79f6c0-bcb7-0006-713d-a8c8dddac61b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4fdf5eea-cb17-0007-c207-1d7aa9279435', '7425cb8d-f81d-0005-8a67-7aa5c9dd6023', '138b9956-acd0-0006-4107-074bd3b6dbef', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1e31520e-e5c0-0007-6e9b-8d9738c57b9b', '7425cb8d-f81d-0005-8a67-7aa5c9dd6023', '79cc1fc6-bc7e-0006-c036-109fa270d075', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('04263694-4809-0007-5318-ca87eb813fad', '7425cb8d-f81d-0005-8a67-7aa5c9dd6023', '560f1dc3-425c-0006-415e-ffe391d03afa', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('edc6330a-5d66-0007-0972-ea7d720d7dc2', '7425cb8d-f81d-0005-8a67-7aa5c9dd6023', 'aa0e7838-9814-0006-aaaf-177c9b90771f', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f460397f-278f-0007-fb1f-db35cd602089', '7425cb8d-f81d-0005-8a67-7aa5c9dd6023', 'e3cb0bf1-21f0-0006-00b6-55fe561e7371', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ba56f06e-1780-0007-49fd-dcc0c08968df', '7425cb8d-f81d-0005-8a67-7aa5c9dd6023', 'ec9059d1-f21f-0006-1a51-67dbe179846f', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('224764bd-09e7-0007-e3d9-c14622c628d2', '7425cb8d-f81d-0005-8a67-7aa5c9dd6023', 'c4f5143c-3027-0006-389a-c34b7ed10779', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b81a01a5-373a-0007-38c1-2cf0aeb941f8', '7425cb8d-f81d-0005-8a67-7aa5c9dd6023', '1b7630a0-58b9-0006-0c92-653497774368', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3c7f9d84-a676-0007-a2e7-b6b06cbc32fd', '7425cb8d-f81d-0005-8a67-7aa5c9dd6023', 'e84e4e0e-71bd-0006-6001-3df5c8c793c8', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('163ae1b5-b6f5-0007-9490-2697e4e246dc', '7425cb8d-f81d-0005-8a67-7aa5c9dd6023', '8310d12a-836d-0006-fd98-a07a5a1e1540', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('cc3d56b6-d907-0007-fd32-c890c3bfefc6', '7425cb8d-f81d-0005-8a67-7aa5c9dd6023', '8a9537a0-0219-0006-01a7-1778cb8c9b31', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('74e2461c-b64d-0007-477e-06e88ebf9518', '7425cb8d-f81d-0005-8a67-7aa5c9dd6023', '96f78927-1d19-0006-b38f-dc3f61f4251d', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1b1ec10a-f647-0007-f305-f2f954d5966c', '7425cb8d-f81d-0005-8a67-7aa5c9dd6023', '9046189c-6711-0006-f0c5-d30a2fb3076e', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2819bc49-b646-0007-a097-f092fedbb4ae', '7425cb8d-f81d-0005-8a67-7aa5c9dd6023', '45729472-c51e-0006-fe6f-0e753e8b8afb', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('48d0b281-08ee-0007-155f-f205e1646775', '7425cb8d-f81d-0005-8a67-7aa5c9dd6023', '4e81c397-aef4-0006-5edf-a413084725ad', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('86000d32-06a4-0007-0999-be335e7609e9', '7425cb8d-f81d-0005-8a67-7aa5c9dd6023', 'a0369371-a33c-0006-38ae-b188c26a944d', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('94f85f69-fb19-0007-5edb-5970ee531d18', '7425cb8d-f81d-0005-8a67-7aa5c9dd6023', 'a003a024-0d8d-0006-b362-bd3ccb101be6', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('07d9f9ee-0835-0007-8bbd-63fb34337a9c', '7425cb8d-f81d-0005-8a67-7aa5c9dd6023', '7f600291-3408-0006-c9fb-3becdd65d33e', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('296409a2-342a-0007-3e89-a3845f02d78f', '7425cb8d-f81d-0005-8a67-7aa5c9dd6023', 'aabf10b4-aed3-0006-a6be-0b0a9387a781', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('bf616a7c-fd1f-0007-e8a5-bf5afb6dfdf3', '7425cb8d-f81d-0005-8a67-7aa5c9dd6023', 'c0dccfef-274c-0006-3e8e-041705d89e6b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e8329413-40d4-0007-184b-54a80bfd2877', '7425cb8d-f81d-0005-8a67-7aa5c9dd6023', '6b0da0e1-9b13-0006-fb5b-718214ecc9b5', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d5d24f2f-17f6-0007-0c7f-f187ef2b051a', '7425cb8d-f81d-0005-8a67-7aa5c9dd6023', '85dc854f-1a69-0006-4d8d-3c0edec106ad', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('61be213b-c479-0007-6c07-d9b21a542976', '7425cb8d-f81d-0005-8a67-7aa5c9dd6023', '59badf67-b54a-0006-8b52-717225792ff0', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('500f347b-80d6-0007-963b-c8369dab5254', '7425cb8d-f81d-0005-8a67-7aa5c9dd6023', '1e23a983-d928-0006-0401-c2dcdd4c5031', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2c7f12eb-5962-0007-cdb1-4911abfb4b46', '7425cb8d-f81d-0005-8a67-7aa5c9dd6023', '3d8e5af9-d934-0006-2664-5e4954728710', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;


-- ========================================
-- Delmarva Thunder ROSTER
-- ========================================
INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('66a426d6-eeca-0007-cf9a-bf2040e50456', '171f448b-97a3-0005-b875-35f9861c31b6', '92c7fd2d-0956-0006-c58e-974aad93603e', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('60a18605-54b0-0007-d17e-c67b67cede56', '171f448b-97a3-0005-b875-35f9861c31b6', '693872a4-1638-0006-cfb1-21f6ca72498d', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('675b3ed6-e4b2-0007-43bd-72c0309b93ac', '171f448b-97a3-0005-b875-35f9861c31b6', 'd021a016-576f-0006-f8cf-781488e10e72', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('369db358-9eda-0007-f8b5-57da16dd1840', '171f448b-97a3-0005-b875-35f9861c31b6', '43078a08-625a-0006-a088-f4dc212fd2cf', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ef657023-dcd6-0007-882c-6f56fa26d643', '171f448b-97a3-0005-b875-35f9861c31b6', '5a2933c3-68d5-0006-1061-7d748e76f09d', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('96c85bec-7cf2-0007-ee8e-df00f43bb071', '171f448b-97a3-0005-b875-35f9861c31b6', '9119582c-7aa5-0006-0103-e2ad241d37f0', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('6bb8051b-b856-0007-5f21-8c1714137009', '171f448b-97a3-0005-b875-35f9861c31b6', '56261293-85c9-0006-b9ad-ffa41a506817', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e1311fa0-df03-0007-8288-0de2eef0145e', '171f448b-97a3-0005-b875-35f9861c31b6', '1982193e-8595-0006-8694-0fbe5675a948', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b764658c-3968-0007-364f-02e7fc37a2db', '171f448b-97a3-0005-b875-35f9861c31b6', '019a6065-9008-0006-00de-c3bfe9df1b9c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0cf637b2-3d6a-0007-0f42-702546def2ce', '171f448b-97a3-0005-b875-35f9861c31b6', '2be2940a-4e87-0006-aae7-23295bfd3521', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('bc2fc7a0-ed3f-0007-7bf7-07e074ee7d56', '171f448b-97a3-0005-b875-35f9861c31b6', 'de88499a-816d-0006-d519-84669bc9dc2a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('5111f3e8-48b1-0007-acfa-3383c319f818', '171f448b-97a3-0005-b875-35f9861c31b6', '3b224c58-8fcc-0006-c4d8-dea542d1e6d4', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b9ac9ea7-69d7-0007-e6a1-b364de0f9c97', '171f448b-97a3-0005-b875-35f9861c31b6', '9a2f0952-a124-0006-f9e1-a7d6a8a85e13', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('82382b52-4e0a-0007-545a-82d9b0ba54cf', '171f448b-97a3-0005-b875-35f9861c31b6', '05087429-19ac-0006-a922-d439e442fd19', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('6e77d5bf-a2ac-0007-7bc8-1abb2b6a20b7', '171f448b-97a3-0005-b875-35f9861c31b6', '50b5320a-d42a-0006-a077-97402d75fd15', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3a048907-fcf6-0007-f9cb-f96e9d04fe2e', '171f448b-97a3-0005-b875-35f9861c31b6', '0dff08a2-e20a-0006-1eb5-df6e1773a43e', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9946409c-caa2-0007-7a5e-8fe6ba86cb94', '171f448b-97a3-0005-b875-35f9861c31b6', '7e3c58c3-b6db-0006-2628-a4b5650cd31c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0f204e95-aee3-0007-ea7d-d2ba3f535520', '171f448b-97a3-0005-b875-35f9861c31b6', '5efff8a3-972b-0006-4b6a-21d187681606', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('5516e64d-b7f1-0007-7d6d-998b38a9351a', '171f448b-97a3-0005-b875-35f9861c31b6', '49fe28bc-a75a-0006-7d22-e92916225840', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f2e03ff9-c62a-0007-7afe-7a9b11fdec45', '171f448b-97a3-0005-b875-35f9861c31b6', '07873d72-4c7a-0006-3f5d-382a721bde4d', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f97fc484-1dcb-0007-28f9-350b8e54798f', '171f448b-97a3-0005-b875-35f9861c31b6', '02df80f8-3d73-0006-8a04-8ff897bdf24d', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a9da4935-181a-0007-d63d-c1adbfad33ad', '171f448b-97a3-0005-b875-35f9861c31b6', '5c8f377b-97e1-0006-c210-37bacb1f5c3b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0ef24c02-4f41-0007-c6dd-a1de761256b3', '171f448b-97a3-0005-b875-35f9861c31b6', 'c517a51e-338b-0006-31ca-7a2f4cd09107', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('48587ac9-39ed-0007-2cd6-8e0254ae0939', '171f448b-97a3-0005-b875-35f9861c31b6', '4db891a8-781d-0006-5658-8fd6c9066eb6', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1b1ba12e-62fb-0007-380a-9417946cf6b8', '171f448b-97a3-0005-b875-35f9861c31b6', 'acddbcaa-5078-0006-0f1a-ee04c78c227b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('97af67e9-74b4-0007-0343-a70ae81d50b9', '171f448b-97a3-0005-b875-35f9861c31b6', '1d20df32-8a34-0006-768d-940cc715c343', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2a06d111-b0af-0007-eaf2-956c35402b7a', '171f448b-97a3-0005-b875-35f9861c31b6', 'd4b1edd1-35bd-0006-acab-605fb73933ef', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('80649d56-38ec-0007-91af-b6ace603c7d5', '171f448b-97a3-0005-b875-35f9861c31b6', '3f58adda-b22f-0006-f20c-59992f115d09', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e991308b-0e8a-0007-02db-f3c128773240', '171f448b-97a3-0005-b875-35f9861c31b6', '0698dad4-90f8-0006-0b38-11232c0e77f4', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('55dc4a44-0205-0007-07b8-37becfca6256', '171f448b-97a3-0005-b875-35f9861c31b6', 'd1b3c475-bf75-0006-6d20-a8d4ce9ce349', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;


-- ========================================
-- Terminus FC ROSTER
-- ========================================
INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e4ad91a0-4923-0007-f8d0-e6c7eae46630', 'f05b54ff-8886-0005-29cd-ff42c703f657', '5053aa8b-ef5d-0006-dec7-1ca9be3bc782', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d9295407-9058-0007-9836-4a8b673d64c7', 'f05b54ff-8886-0005-29cd-ff42c703f657', '15aabcde-ef4a-0006-e979-f856816be467', 9, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('5bdb1176-7e60-0007-14ea-c7f2a52eb024', 'f05b54ff-8886-0005-29cd-ff42c703f657', '5ad009e2-8a43-0006-f91b-d3c88f1da44c', 3, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d0a14b69-4e07-0007-76ea-e990e3f80088', 'f05b54ff-8886-0005-29cd-ff42c703f657', 'ef507504-2c44-0006-572d-08e6d528bfa9', 4, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('415724fe-6351-0007-aeab-f30774c30622', 'f05b54ff-8886-0005-29cd-ff42c703f657', '1d41ac2a-b3fd-0006-5b09-ed26efa22472', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('68485314-1190-0007-079f-4e1bbbb1688f', 'f05b54ff-8886-0005-29cd-ff42c703f657', 'a7ffe2c4-9759-0006-b23d-f3f2e42482e5', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9dca95f4-4275-0007-35d9-8e9c51ef1f67', 'f05b54ff-8886-0005-29cd-ff42c703f657', '2b034d6d-f28a-0006-70a8-817a6b996d6d', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c9484a49-ea4b-0007-2371-a4c57fa1659b', 'f05b54ff-8886-0005-29cd-ff42c703f657', '009b1c25-3f31-0006-757e-db7713467e82', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ba281d42-c412-0007-a90a-2cc0b83e4051', 'f05b54ff-8886-0005-29cd-ff42c703f657', 'cc9ba7ea-c562-0006-c70d-a3b54afecbc6', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3ee06a98-aa4b-0007-b955-5eeb31707789', 'f05b54ff-8886-0005-29cd-ff42c703f657', '6933ec21-d0f0-0006-4098-500ac2691f2a', 5, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c6ccfedc-057e-0007-3aa3-69be6cdadfed', 'f05b54ff-8886-0005-29cd-ff42c703f657', 'a44bcf66-b651-0006-acd5-d239e10218fc', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7a059fb2-3e9d-0007-5039-6732a00e129f', 'f05b54ff-8886-0005-29cd-ff42c703f657', '6d8cb093-9da7-0006-9adb-3f239abce839', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('419d7c13-fa2a-0007-9ee1-7bdb7bf9e6f2', 'f05b54ff-8886-0005-29cd-ff42c703f657', '608a0969-1c4b-0006-aec5-fb33f7060455', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('406c4e14-150f-0007-4b28-d5a9027abda9', 'f05b54ff-8886-0005-29cd-ff42c703f657', 'ac544f2d-c290-0006-23d2-c44fe4d79813', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('14e774ef-2acd-0007-6efd-c5725cbff88f', 'f05b54ff-8886-0005-29cd-ff42c703f657', 'a77f656f-1780-0006-6237-8e4afac163fd', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('dc31b38a-f20c-0007-24d7-dab3e4ca3d55', 'f05b54ff-8886-0005-29cd-ff42c703f657', '004f2caf-0688-0006-8e9c-070e72ee2a0f', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4ada6a3a-55d6-0007-7a7a-6cd289a29cd7', 'f05b54ff-8886-0005-29cd-ff42c703f657', '19347387-8fd3-0006-38cd-2f250bea5369', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('60ad7fb5-aaae-0007-0c66-1a057288258f', 'f05b54ff-8886-0005-29cd-ff42c703f657', '5cb0b072-a930-0006-4b42-11438606322d', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e6fe2171-cb77-0007-3728-df4525d41f03', 'f05b54ff-8886-0005-29cd-ff42c703f657', '9e7238e6-8004-0006-6317-b985df73f054', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('35bd49f6-d3fe-0007-a86d-07b49efa8810', 'f05b54ff-8886-0005-29cd-ff42c703f657', '8625253b-3933-0006-0217-6d47db9dc69b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f9d49295-58df-0007-34e0-07673c18c5fd', 'f05b54ff-8886-0005-29cd-ff42c703f657', 'd3e30f53-3bc0-0006-4439-50bdb5c7db0b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0d5c16a7-e7de-0007-e8c9-10a09150b9af', 'f05b54ff-8886-0005-29cd-ff42c703f657', '2ff6669c-b6d8-0006-4f23-5f0140a1aa4a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d94b1a91-12c0-0007-4ec3-c297da3d319a', 'f05b54ff-8886-0005-29cd-ff42c703f657', '0ac3d864-f5d3-0006-2ee2-d188a1c7d859', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7fbbb16b-a13c-0007-fcad-c03d395a4127', 'f05b54ff-8886-0005-29cd-ff42c703f657', '054400ab-80b8-0006-e4a2-984a3add5e1c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('bc209f73-25bc-0007-1911-87cb693c0d61', 'f05b54ff-8886-0005-29cd-ff42c703f657', 'fbd28e47-6125-0006-a22a-dd7b08276f5d', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('913c057f-8e45-0007-af81-1c8e25064eee', 'f05b54ff-8886-0005-29cd-ff42c703f657', '1b776436-699a-0006-beb5-ee8d690e183f', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('61cbd4a6-c65c-0007-4d74-a4fb56b281c2', 'f05b54ff-8886-0005-29cd-ff42c703f657', '0dd5e4b5-9d7c-0006-c06b-55836931c450', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d14f6331-a986-0007-33dc-c0d71421a0b2', 'f05b54ff-8886-0005-29cd-ff42c703f657', '7b0bc186-1654-0006-48e9-cf7886427640', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c0922ad4-4d7f-0007-fb19-5c5c9ab6a79a', 'f05b54ff-8886-0005-29cd-ff42c703f657', '037a3e6f-9606-0006-4fc9-e5d314c99e84', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('20b5db65-c235-0007-43d9-fb28e826b857', 'f05b54ff-8886-0005-29cd-ff42c703f657', '4d6e8424-b0a6-0006-c6ea-b46b55f394c7', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d6852715-d277-0007-a9eb-b644c70a1c17', 'f05b54ff-8886-0005-29cd-ff42c703f657', 'e0ed8e68-be01-0006-0a0d-79d5e166f357', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a7b8af0f-5488-0007-0590-4779ae9bedaf', 'f05b54ff-8886-0005-29cd-ff42c703f657', 'e559aa1a-1249-0006-26cb-99caf1c32007', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ce3b7a42-461e-0007-8e5f-0b0df60fefba', 'f05b54ff-8886-0005-29cd-ff42c703f657', '156ba99b-42c7-0006-bd9a-4d394ecb65d6', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('cff65a9c-a5d0-0007-ff9e-ec21caf226ce', 'f05b54ff-8886-0005-29cd-ff42c703f657', '45e5d065-12d2-0006-104a-92ecbdb49799', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a5f2d02b-f6b0-0007-2463-39697c972952', 'f05b54ff-8886-0005-29cd-ff42c703f657', '73ed171b-dc8a-0006-184f-66237a3760ce', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('42dbde0f-0454-0007-7d40-1dabbeecf003', 'f05b54ff-8886-0005-29cd-ff42c703f657', '5000b170-37ab-0006-65d2-2d8a1c734954', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('cc01ea2e-3ea8-0007-bfef-7f8674879a79', 'f05b54ff-8886-0005-29cd-ff42c703f657', '65ca1823-976a-0006-7813-ab6112c48778', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('98b0129b-d22a-0007-4ff9-857303458d29', 'f05b54ff-8886-0005-29cd-ff42c703f657', 'f5d6e0fa-279d-0006-08cb-2ebbd27d8296', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('747149b6-2010-0007-99dc-784d60378953', 'f05b54ff-8886-0005-29cd-ff42c703f657', '031b1ea2-681c-0006-c27a-254ea65ba550', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('bc2e1bac-ffbf-0007-57e1-8285260656de', 'f05b54ff-8886-0005-29cd-ff42c703f657', '37c885a2-0ab9-0006-b042-3436918a5912', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('00b9a50b-af80-0007-7edf-80d66975468a', 'f05b54ff-8886-0005-29cd-ff42c703f657', '2d06ef58-fcf3-0006-02b2-af37cac565bd', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4a1d594d-c656-0007-ce2c-3d631989102c', 'f05b54ff-8886-0005-29cd-ff42c703f657', '593e4e29-c18a-0006-2410-5a3cc5ed6065', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('456db9aa-c5b4-0007-be86-a522e40cc539', 'f05b54ff-8886-0005-29cd-ff42c703f657', 'd3921aed-cc6c-0006-ec83-ab5f8aad3c8b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('cf3bd16c-b1c0-0007-b8e4-ab9760ae55e5', 'f05b54ff-8886-0005-29cd-ff42c703f657', '1c193e9f-1189-0006-3f21-293833f906da', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a5ea92db-4bb0-0007-4f4c-a0838f9237a9', 'f05b54ff-8886-0005-29cd-ff42c703f657', '79d43a34-01dd-0006-f394-b426250b5adf', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('da4aba35-4af0-0007-e3e1-6fd624360e71', 'f05b54ff-8886-0005-29cd-ff42c703f657', 'edb36eec-89de-0006-cea6-f79b04eae44f', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('08142e00-d172-0007-f4e0-2967c1589e9e', 'f05b54ff-8886-0005-29cd-ff42c703f657', '6453622f-703e-0006-a77a-568d52570586', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b6443202-49b1-0007-91c8-ec0600c16a1b', 'f05b54ff-8886-0005-29cd-ff42c703f657', '21e08479-5059-0006-720b-36880ea826b4', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('607114fb-45d1-0007-5586-2d9e58a8c8fe', 'f05b54ff-8886-0005-29cd-ff42c703f657', 'de8ff1df-ffc0-0006-8ae8-eb1927e102b1', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('64465ebd-43a4-0007-2ea3-ded7a420f5ba', 'f05b54ff-8886-0005-29cd-ff42c703f657', 'e891200f-927a-0006-cead-e97e980245da', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a2301055-d054-0007-c09e-a906af1054a0', 'f05b54ff-8886-0005-29cd-ff42c703f657', '69ccca28-f6a4-0006-d6c0-08adb6b1ada9', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('bd6211e4-36a5-0007-ffc2-4839527dd8f7', 'f05b54ff-8886-0005-29cd-ff42c703f657', '9c129616-47c7-0006-b95a-aa4bb3d373f6', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7513c769-147f-0007-3b37-b31db0f35e2b', 'f05b54ff-8886-0005-29cd-ff42c703f657', '0f2da084-0de6-0006-07a9-d0c4f4443f5c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('82442fa7-dd3d-0007-91ff-d5f4727e0b28', 'f05b54ff-8886-0005-29cd-ff42c703f657', '1b5b8580-36a4-0006-e540-1c181d5cf4cf', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('fbc329ec-69d6-0007-323b-b2ecf59dce66', 'f05b54ff-8886-0005-29cd-ff42c703f657', '91cc5490-f346-0006-6049-434cc6b89d3b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4a4e0049-e52a-0007-a438-3020357c6fad', 'f05b54ff-8886-0005-29cd-ff42c703f657', 'b1c66e96-b6a0-0006-3854-836c19b1edeb', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('172451fa-12a2-0007-c14e-b71d080fcf88', 'f05b54ff-8886-0005-29cd-ff42c703f657', '4cafb3c9-0bd7-0006-c171-5415ed6e89b7', 3, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c787f913-1fa3-0007-98ae-15d0d5175faa', 'f05b54ff-8886-0005-29cd-ff42c703f657', '77cbc057-722e-0006-cb97-7fa864aba702', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;


-- ========================================
-- Majestic SC ROSTER
-- ========================================
INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('8fca586c-433e-0007-95a4-46f9f7c095c4', '55bd7a24-ba77-0005-81a4-2f5bfb50c614', '18bd3372-e461-0006-fa41-5bb46a9b1dc1', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('029322b9-ef19-0007-2f73-b3462adc6bba', '55bd7a24-ba77-0005-81a4-2f5bfb50c614', '83745656-5720-0006-1ec7-c86b8aa76b42', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('bd99fdbb-5379-0007-89aa-a34c328b7fd5', '55bd7a24-ba77-0005-81a4-2f5bfb50c614', '7254d086-ebd7-0006-c394-48c68776da0a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('998060d5-e04b-0007-5991-cc08c9b586b9', '55bd7a24-ba77-0005-81a4-2f5bfb50c614', '15927f34-49ae-0006-85a7-fcbf81bafe33', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('6a873dc2-ce8e-0007-5475-bd55fcffcb9b', '55bd7a24-ba77-0005-81a4-2f5bfb50c614', '5f202405-211a-0006-4754-d97519d0888b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('6b8153c3-35d6-0007-b2da-ed32294d2928', '55bd7a24-ba77-0005-81a4-2f5bfb50c614', 'cb3dba76-73c8-0006-1d0d-d6be03c25f72', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7f97bacc-5d4f-0007-adce-cf770ec86623', '55bd7a24-ba77-0005-81a4-2f5bfb50c614', '85148961-4ccf-0006-62cc-030f0cf42e88', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('49182b42-0e40-0007-e8dd-1747e76e5abe', '55bd7a24-ba77-0005-81a4-2f5bfb50c614', '6c45c931-85d9-0006-e514-397d19787fd1', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9677b102-046d-0007-1fbf-d4b9c07588eb', '55bd7a24-ba77-0005-81a4-2f5bfb50c614', '3efb5865-788e-0006-1baf-7f9dd37bf51e', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f90282f7-799a-0007-7ce5-21223b627e0d', '55bd7a24-ba77-0005-81a4-2f5bfb50c614', '59e41f4c-e413-0006-1edb-5e6ba072fb83', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d6b2fc88-fbe3-0007-30b7-fb9134c94314', '55bd7a24-ba77-0005-81a4-2f5bfb50c614', '3b2f0a78-ba07-0006-f038-69f2576600ad', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ac28e95a-6582-0007-06b3-7283ace05af4', '55bd7a24-ba77-0005-81a4-2f5bfb50c614', 'd5de72db-584f-0006-621e-d2b75fe48c8a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('dee40498-85b5-0007-5f5b-6560a8fa0b34', '55bd7a24-ba77-0005-81a4-2f5bfb50c614', 'a22980eb-3044-0006-ca16-5c3c911c48d1', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('be52d515-3bc4-0007-141e-64c3a6a12295', '55bd7a24-ba77-0005-81a4-2f5bfb50c614', '93a8d0cd-ec1d-0006-eefc-d4fbdb90e896', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9b037e45-5b8d-0007-869f-102459063f25', '55bd7a24-ba77-0005-81a4-2f5bfb50c614', 'ad965ae0-6702-0006-3180-99a7e70e2a0a', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c33c98a2-3c9d-0007-892f-306101b36f84', '55bd7a24-ba77-0005-81a4-2f5bfb50c614', '4999ad84-dd4b-0006-f470-024b80b2db5f', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('95877f35-6af5-0007-e4b0-ef595970b757', '55bd7a24-ba77-0005-81a4-2f5bfb50c614', '8ab06db9-7ffc-0006-e347-a1dba37b0698', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('02b66c12-721d-0007-5137-ec8a0884f71a', '55bd7a24-ba77-0005-81a4-2f5bfb50c614', '1cac3e46-a5a9-0006-90c5-4ef7f35b9733', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e0d79d29-2001-0007-ae92-dc14e8aab164', '55bd7a24-ba77-0005-81a4-2f5bfb50c614', 'f9386d75-8e8a-0006-6b26-25e0ebdd5758', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('017ddae6-9918-0007-1a45-e70fe9e7ae6e', '55bd7a24-ba77-0005-81a4-2f5bfb50c614', '5b5042e1-28be-0006-650b-f7ef67ada2b8', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d16d476d-f00f-0007-afa7-7ba7fbbffdba', '55bd7a24-ba77-0005-81a4-2f5bfb50c614', 'e698698f-86cb-0006-dfdd-b8b296971737', 3, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e5cb7d57-888b-0007-6f4f-0801154257e4', '55bd7a24-ba77-0005-81a4-2f5bfb50c614', 'd5fe16b6-d486-0006-003d-4cb836f13de0', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('55042ff0-3031-0007-c4ac-43dafd38620a', '55bd7a24-ba77-0005-81a4-2f5bfb50c614', '9a4a00f9-924d-0006-4573-3693c5d6041b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('cd575506-e762-0007-ddd2-220c7b55700b', '55bd7a24-ba77-0005-81a4-2f5bfb50c614', '2d6265b1-253e-0006-cc14-ed318220a368', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b31d1ed6-ec02-0007-0b70-3628a9431741', '55bd7a24-ba77-0005-81a4-2f5bfb50c614', '970313b2-94c8-0006-8fec-5f18f915290a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7deb385a-887b-0007-306c-117c4fb9f78b', '55bd7a24-ba77-0005-81a4-2f5bfb50c614', '1c0174b6-5432-0006-541b-cd449efcc7d1', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d3167be8-ae4f-0007-f789-85fb00f40d12', '55bd7a24-ba77-0005-81a4-2f5bfb50c614', 'c1036a25-e2de-0006-8a70-68ab51170558', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7c6ebb4a-0f25-0007-7338-e5bccc85641a', '55bd7a24-ba77-0005-81a4-2f5bfb50c614', '0487e9d0-0181-0006-18d8-02f40df4aa20', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;


-- ========================================
-- Peachtree FC ROSTER
-- ========================================
INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ee3dd949-4d33-0007-0980-0edfe9992b5c', 'ec1718e1-142d-0005-ef5c-b49f0f144a3c', '52f86506-b899-0006-e304-e601997b9c2e', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e3e93a5c-47d3-0007-8961-d8d662c75577', 'ec1718e1-142d-0005-ef5c-b49f0f144a3c', 'ea26b1b1-cb54-0006-821b-a6d301f142fa', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('32085e27-a34c-0007-03c2-f91bad1547a8', 'ec1718e1-142d-0005-ef5c-b49f0f144a3c', '498f385c-3957-0006-a1e5-9a699de6be68', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e30e8de2-9800-0007-24ec-d466fe9a3ba6', 'ec1718e1-142d-0005-ef5c-b49f0f144a3c', '2b945af7-cdc8-0006-78dd-e619fa32962d', 16, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1f366e78-bcfb-0007-4b87-5b03cd222b7f', 'ec1718e1-142d-0005-ef5c-b49f0f144a3c', 'ef86c172-542a-0006-04fa-2c534d58d487', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('8436a473-632c-0007-a668-76e03f2d226f', 'ec1718e1-142d-0005-ef5c-b49f0f144a3c', '93a498fb-a70a-0006-a1e1-3991ba21c677', 4, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('681a501b-e70c-0007-f1bc-b969afd2f550', 'ec1718e1-142d-0005-ef5c-b49f0f144a3c', '14145f3a-4794-0006-2b1f-0e9155b0041a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7c49112b-da08-0007-2fd1-55ebcfada2b7', 'ec1718e1-142d-0005-ef5c-b49f0f144a3c', '39e859f3-11d8-0006-9c15-0711da626eed', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2ae4d0a9-eb6f-0007-79b1-39052310eeeb', 'ec1718e1-142d-0005-ef5c-b49f0f144a3c', '8063071f-b57e-0006-5ce3-ffab43fa5242', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('44aa11e6-1169-0007-a929-4d577806cbb6', 'ec1718e1-142d-0005-ef5c-b49f0f144a3c', '257e6ff6-b2c0-0006-7297-f76cfc123f39', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('792e417c-a3a6-0007-8c35-1bc8bf91647e', 'ec1718e1-142d-0005-ef5c-b49f0f144a3c', '92d69d87-c612-0006-6d8f-9379b771a731', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('237702ab-6b73-0007-fc6f-ae20932c1aba', 'ec1718e1-142d-0005-ef5c-b49f0f144a3c', 'ff05a9d3-7c8d-0006-26d2-a45f24cb78ee', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('abf71dcf-7c78-0007-4c73-62e95915368e', 'ec1718e1-142d-0005-ef5c-b49f0f144a3c', '6c76d517-d4a9-0006-f761-17c854e78335', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f5d77dda-c372-0007-80e6-f1dadd440e6a', 'ec1718e1-142d-0005-ef5c-b49f0f144a3c', 'f69c1672-6dea-0006-be5c-c84dd2296418', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('30e2444c-0b89-0007-84e5-df6fb743e57f', 'ec1718e1-142d-0005-ef5c-b49f0f144a3c', '801b1e30-0a36-0006-a3ce-7f8d45d5043d', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('34a2027d-bff1-0007-321d-17602fc54901', 'ec1718e1-142d-0005-ef5c-b49f0f144a3c', 'a1743c4a-f809-0006-aeb5-cc5802df6539', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1501aa7f-3e43-0007-78af-950835250440', 'ec1718e1-142d-0005-ef5c-b49f0f144a3c', '2f17c28d-7780-0006-f293-e630663fba56', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9d4ac630-1d2c-0007-d73d-a7f8bf748f17', 'ec1718e1-142d-0005-ef5c-b49f0f144a3c', 'ff317d6c-7e60-0006-e5f7-404306adce9c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7e9b9efd-c576-0007-bee1-bf7067beb37c', 'ec1718e1-142d-0005-ef5c-b49f0f144a3c', '0e363b75-23a6-0006-be3e-7aaebd6032ad', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('bddf97be-2b63-0007-f0cd-39f986bfe15e', 'ec1718e1-142d-0005-ef5c-b49f0f144a3c', '1a392f98-9da7-0006-1a53-6dbc563e6a10', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('80c835bd-99c6-0007-ac87-2f8361b52575', 'ec1718e1-142d-0005-ef5c-b49f0f144a3c', 'e1f15cf2-95c1-0006-bc9e-caa81976ee39', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('07385e59-43bb-0007-2e50-b002bc746cdc', 'ec1718e1-142d-0005-ef5c-b49f0f144a3c', '25e6744f-22b8-0006-02bd-a9eaf44074f1', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9ae9eaeb-ba96-0007-0ea4-eb61c5cf79ac', 'ec1718e1-142d-0005-ef5c-b49f0f144a3c', '8a2460fc-4f4c-0006-a117-986e63f6a939', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('886ae677-4dda-0007-761b-68d5854e1182', 'ec1718e1-142d-0005-ef5c-b49f0f144a3c', 'd39ddcfb-7e8f-0006-83a1-f85cf8a37c77', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1956fc65-a431-0007-b784-bbcdc056512a', 'ec1718e1-142d-0005-ef5c-b49f0f144a3c', 'f1e5a22b-179b-0006-2059-52356359f5e4', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e7fba0ff-164e-0007-1ac1-bc7043f74c56', 'ec1718e1-142d-0005-ef5c-b49f0f144a3c', 'f9d63682-bffa-0006-eff6-72dbab0365f2', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('37dfbf70-7ad3-0007-16cf-536767ab6c8b', 'ec1718e1-142d-0005-ef5c-b49f0f144a3c', '7477d2f4-761e-0006-72c0-df5c858a1210', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1942ec1c-4ed7-0007-958c-94ed1281b19f', 'ec1718e1-142d-0005-ef5c-b49f0f144a3c', '0e726fb2-55dd-0006-b617-d89d008da979', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;


-- ========================================
-- Prima FC ROSTER
-- ========================================
INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c008fd8f-4336-0007-4557-d53567a2153f', '07e8c5da-df90-0005-7ef3-b55105901be2', 'f15d6958-7484-0006-c037-657c85b1ae38', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7cd87114-942c-0007-a2d3-e3c9da84fcd2', '07e8c5da-df90-0005-7ef3-b55105901be2', 'e60ac574-f2cd-0006-4b5d-d76ee6adc628', 7, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('30cf3ad1-24d9-0007-bd09-5e6549010d68', '07e8c5da-df90-0005-7ef3-b55105901be2', '0d0bc3b1-617c-0006-0ca4-ac355679760e', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7c22baa3-428b-0007-3e6b-8509c328ae06', '07e8c5da-df90-0005-7ef3-b55105901be2', '61796fe0-4ef5-0006-40ae-e9d3f36a597f', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d2d0484c-9fff-0007-9cd5-274a0a2f40b5', '07e8c5da-df90-0005-7ef3-b55105901be2', 'a82f72e6-c197-0006-abd2-2de08516908f', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4451013e-e1a6-0007-455f-9717e26f3023', '07e8c5da-df90-0005-7ef3-b55105901be2', '1ca12f32-d400-0006-7206-5f58c95d959d', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('21996222-9015-0007-794d-f5fff719dc1d', '07e8c5da-df90-0005-7ef3-b55105901be2', '3e8d7a95-b863-0006-b8db-9ea871cfe3d7', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('fbcd0a62-40b9-0007-a4b3-42ad6377321e', '07e8c5da-df90-0005-7ef3-b55105901be2', '3ff14c9b-20cc-0006-7a9b-5f7593a0c84e', 3, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ccc71be3-a2fc-0007-27ee-547c5fe1cb5d', '07e8c5da-df90-0005-7ef3-b55105901be2', '5fe9912f-c785-0006-c7d1-538ccbf4ae91', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c49fdfeb-4a41-0007-37f1-d1253fdba926', '07e8c5da-df90-0005-7ef3-b55105901be2', '9f15468d-3c73-0006-204f-d2263be1c97d', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1078582f-30b5-0007-61a9-d5614205eb6a', '07e8c5da-df90-0005-7ef3-b55105901be2', '4c11f19d-a362-0006-0d43-df83659861dc', 6, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('cc319807-bbfd-0007-ebf3-5678226e41e2', '07e8c5da-df90-0005-7ef3-b55105901be2', '2ab8ee61-bd29-0006-23d7-7f56fd290ffb', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9b55bbcc-dfaa-0007-4059-515c8c5079be', '07e8c5da-df90-0005-7ef3-b55105901be2', '5169e942-a093-0006-c028-bd204017359f', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('13103a42-83bd-0007-7d42-a1d67d6bf9ba', '07e8c5da-df90-0005-7ef3-b55105901be2', '0de960d5-64e9-0006-aa98-badd0aa017b4', 5, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b49ed8fc-f520-0007-52be-884d43bb78ba', '07e8c5da-df90-0005-7ef3-b55105901be2', 'bcb4f1a9-6840-0006-74bf-a31fe146b7d8', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4928ca1f-6b4d-0007-ff90-40ae82ea077b', '07e8c5da-df90-0005-7ef3-b55105901be2', '3c66a94d-42e1-0006-a6f6-cce213a54dfb', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('fd75b963-433f-0007-387f-61d2d00f2876', '07e8c5da-df90-0005-7ef3-b55105901be2', '7644c73d-5a0b-0006-94c6-c6177a87a0d9', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c045aaa6-905d-0007-feb8-7e1c0f729c96', '07e8c5da-df90-0005-7ef3-b55105901be2', 'e594e343-368c-0006-5996-dce06cd0dcfa', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4dbbcf13-2f64-0007-d4b6-5c5f2435bd4a', '07e8c5da-df90-0005-7ef3-b55105901be2', 'ca6343cb-5d14-0006-4562-d5b64127dab7', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7fd4699e-a87f-0007-d946-48d32dc5b35d', '07e8c5da-df90-0005-7ef3-b55105901be2', '99c86369-da29-0006-9704-3d5552dcead7', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('85595f65-73eb-0007-6322-10f3298f98cf', '07e8c5da-df90-0005-7ef3-b55105901be2', '5a791d6c-7ff7-0006-4031-de562ad81dce', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('22b04d24-6492-0007-81b3-5f7dfbc155c2', '07e8c5da-df90-0005-7ef3-b55105901be2', '87673ffe-2b0b-0006-b73b-4abde057abe4', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f7124584-8cac-0007-ab86-4279333944df', '07e8c5da-df90-0005-7ef3-b55105901be2', '22faa896-9be8-0006-9d24-3bda3579c08b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b74ba89f-2325-0007-09f0-ba820d24c38d', '07e8c5da-df90-0005-7ef3-b55105901be2', '43212e19-925a-0006-52b0-aca62ed0d5ff', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9eb4b8c9-a9cb-0007-444c-f5c0337e9075', '07e8c5da-df90-0005-7ef3-b55105901be2', 'f7d36655-c443-0006-8ac5-78a0bbd5903d', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;


-- ========================================
-- Bel Calcio FC ROSTER
-- ========================================
INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('dcf092a4-1f10-0007-f034-e9ef4667c5e1', '268164a2-111d-0005-9ea6-900cd6c9f197', '09d33dd8-9416-0006-67ec-8326bbeb0fb2', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a20779f3-595a-0007-d1ed-5ce08313b41d', '268164a2-111d-0005-9ea6-900cd6c9f197', '26333b66-701b-0006-f490-b40467188a5d', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2230b9e4-4434-0007-2399-9c859533f282', '268164a2-111d-0005-9ea6-900cd6c9f197', 'ebd6e635-936f-0006-17ed-5d87219f8bb6', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('99b17780-d61b-0007-2cb5-6fa458ca17f1', '268164a2-111d-0005-9ea6-900cd6c9f197', '2f05bd4a-cf23-0006-4e12-0bd459133d35', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('590d7b4d-de47-0007-8267-fadc37724ff4', '268164a2-111d-0005-9ea6-900cd6c9f197', '91be8151-889f-0006-1a47-e4ca10e09600', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0cb5e63f-672c-0007-59a9-d64b09b59029', '268164a2-111d-0005-9ea6-900cd6c9f197', 'd3793838-381f-0006-534c-49b50580b7b9', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('55e629a0-8b2f-0007-f71c-7c2672acffbf', '268164a2-111d-0005-9ea6-900cd6c9f197', 'dd723fbb-b34f-0006-abbe-7d105ebcc0e5', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b70db81c-2907-0007-ecab-c04ca86be54e', '268164a2-111d-0005-9ea6-900cd6c9f197', 'a8cbc1a7-608f-0006-dbf6-2c64b8372997', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c42f531b-e279-0007-ae98-e528abc4b6be', '268164a2-111d-0005-9ea6-900cd6c9f197', '7b2321d4-35cd-0006-5ac8-3b60f32d59cf', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f743da3c-0b8a-0007-8349-b559e5469773', '268164a2-111d-0005-9ea6-900cd6c9f197', 'ed937721-2e32-0006-150d-778b8d7419b7', 3, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('486d116f-e4e6-0007-a7cb-5485956929d3', '268164a2-111d-0005-9ea6-900cd6c9f197', '2beabf16-26d4-0006-198e-73e5939c02b7', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('de553f90-0178-0007-f416-5de5be7bc9b1', '268164a2-111d-0005-9ea6-900cd6c9f197', '2225523c-19d1-0006-7331-3379c90a6a05', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c91cfb4c-41d9-0007-936a-4b3947581241', '268164a2-111d-0005-9ea6-900cd6c9f197', '9f8bf572-09e7-0006-0cfc-2ced73776715', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0c3cabb8-a843-0007-e468-c932ad5f4147', '268164a2-111d-0005-9ea6-900cd6c9f197', '93916a6c-3912-0006-9c0d-1095cf2523fc', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1715969c-77cd-0007-208a-62679dae0de6', '268164a2-111d-0005-9ea6-900cd6c9f197', 'cd983245-a660-0006-2f72-541e59202e9b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d86ae92e-d0c9-0007-6996-b70a3a15707a', '268164a2-111d-0005-9ea6-900cd6c9f197', 'd4fefc80-25ea-0006-41d0-edf53c08b333', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('cc860d6f-9b78-0007-5051-a6e00ac39eac', '268164a2-111d-0005-9ea6-900cd6c9f197', '8c997c27-8525-0006-9be6-694cf8adaaaf', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9fb3de30-c11b-0007-7131-0715163918c5', '268164a2-111d-0005-9ea6-900cd6c9f197', 'c863a6a6-8ba3-0006-b896-f6c26b9ee9dc', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e0695dda-4c70-0007-08be-c5caf1fdd112', '268164a2-111d-0005-9ea6-900cd6c9f197', 'c299b0e4-a978-0006-9c4b-dc0430d07e29', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('90852928-017e-0007-466a-b47373a79271', '268164a2-111d-0005-9ea6-900cd6c9f197', 'de60f99d-d8ae-0006-149d-1fba66a5bf3e', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7f097590-31b2-0007-b32f-6e025a80ea53', '268164a2-111d-0005-9ea6-900cd6c9f197', 'da7e0b9d-2448-0006-7ee7-7d7b9b2aac2a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f1cbfca9-774a-0007-5774-ef8ce41f5a79', '268164a2-111d-0005-9ea6-900cd6c9f197', 'cb7de99c-a2da-0006-b86c-9acb3f1fbe1d', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('dc27889b-4b26-0007-cc0e-3088878ec2f6', '268164a2-111d-0005-9ea6-900cd6c9f197', '76e8d381-bbf1-0006-86be-df0ec9e64eb7', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c8cb7488-6f70-0007-a776-a05c9c5ecce6', '268164a2-111d-0005-9ea6-900cd6c9f197', 'ba4c1420-36e5-0006-9817-60976e01e18a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3784d62c-7790-0007-0241-e322f02ddada', '268164a2-111d-0005-9ea6-900cd6c9f197', '888f33dd-c99b-0006-c158-4e6413a860a1', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7426749a-1fcb-0007-c8f9-917ed3ed3203', '268164a2-111d-0005-9ea6-900cd6c9f197', 'fec78a36-aec8-0006-a6df-1cbc76d446b7', 6, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f7ab3c66-77ed-0007-7f80-420e7b9f16a2', '268164a2-111d-0005-9ea6-900cd6c9f197', '05d44070-70a3-0006-3128-a8f89ac11946', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a1b3bde7-791d-0007-94d5-c0f897bb218a', '268164a2-111d-0005-9ea6-900cd6c9f197', '65b83388-5051-0006-5e4c-7b3117013677', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('234cee99-5cec-0007-2a80-3c65a86a0982', '268164a2-111d-0005-9ea6-900cd6c9f197', '6a27f8b7-700f-0006-08f3-dcd43f81b028', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('dd90af6e-b746-0007-b63c-44849da0b48d', '268164a2-111d-0005-9ea6-900cd6c9f197', '98a982b4-e3dd-0006-a7eb-c107c716b5ad', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1ec0f45c-969b-0007-2fa6-d949390bfaa8', '268164a2-111d-0005-9ea6-900cd6c9f197', 'a19ef09a-bb92-0006-444f-54d6137af323', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d8f34685-593d-0007-ba1f-e7d2d23066d6', '268164a2-111d-0005-9ea6-900cd6c9f197', 'ec423f37-57e5-0006-c928-4b99ce99b63b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('17667f6a-e8b9-0007-e47e-91b681fa8caf', '268164a2-111d-0005-9ea6-900cd6c9f197', '3653ed16-3a23-0006-19c0-d5f8575b4815', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;


-- ========================================
-- Buckhead SC ROSTER
-- ========================================
INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('350a14d1-ddc6-0007-34ca-d1ee46b8901e', '3ae0fc91-9acf-0005-06a7-2af9ccf19b51', '67c717f9-0e22-0006-a160-6f0b0af633ec', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7af22cfe-684f-0007-7bd2-7f64491c149a', '3ae0fc91-9acf-0005-06a7-2af9ccf19b51', '7edd3143-8eae-0006-f999-9848f54d30b6', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('fd053f62-2f04-0007-9fe3-7bf57396fae1', '3ae0fc91-9acf-0005-06a7-2af9ccf19b51', '154447ed-44c1-0006-bc8c-8a2c58749b78', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('fcdcc96d-feac-0007-6f8b-ee9c0f943dc1', '3ae0fc91-9acf-0005-06a7-2af9ccf19b51', 'fe4d0dea-8ee6-0006-8c10-b1891334cda1', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('6d2a3f96-0ab7-0007-703f-df6841c2fe14', '3ae0fc91-9acf-0005-06a7-2af9ccf19b51', '8c6f22ca-0469-0006-7a53-5dfa7b1dc1d1', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('495975a6-f409-0007-119f-3e8b0b796f0e', '3ae0fc91-9acf-0005-06a7-2af9ccf19b51', '943b61f3-6d76-0006-37ea-410450964c10', 5, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('944502e9-aa42-0007-eaf9-c583d73533b3', '3ae0fc91-9acf-0005-06a7-2af9ccf19b51', '35e548cf-d0c9-0006-c19c-ddcb23dde64c', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f36a79a8-7962-0007-3184-9de632617eed', '3ae0fc91-9acf-0005-06a7-2af9ccf19b51', 'aa6d515d-7bfd-0006-15ad-f251c2b7c979', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('888582a0-37e9-0007-7498-a584685e9805', '3ae0fc91-9acf-0005-06a7-2af9ccf19b51', '79e7c669-0541-0006-0d28-9821dd9dc9fe', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4adf7047-a472-0007-82ec-b03eb3dbd1fa', '3ae0fc91-9acf-0005-06a7-2af9ccf19b51', 'b5ea4dc4-80f0-0006-4645-a1178a1fb88b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1379281e-9270-0007-179e-6d4a6cd54ceb', '3ae0fc91-9acf-0005-06a7-2af9ccf19b51', 'b2c3bcac-93df-0006-0ef5-3f9597f635ec', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('5b07eb15-2ab3-0007-c55f-0fdcbcc9d8ce', '3ae0fc91-9acf-0005-06a7-2af9ccf19b51', '8a8f94f7-62da-0006-4bdb-6055ca84b233', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('53c53890-bc3a-0007-573d-ee0f3bcc9024', '3ae0fc91-9acf-0005-06a7-2af9ccf19b51', '67a4045c-e53f-0006-b26a-7fb0b9af295d', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1f779f83-6575-0007-7789-f2fb1b8489ed', '3ae0fc91-9acf-0005-06a7-2af9ccf19b51', '7629c0b7-fcf3-0006-3b4a-b74a2ef45a10', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7bbc2aac-0cc4-0007-7d94-78806a063c95', '3ae0fc91-9acf-0005-06a7-2af9ccf19b51', 'e7655121-b366-0006-75b8-2de65542c573', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('bcf42087-db2d-0007-89a9-d9539442dcfa', '3ae0fc91-9acf-0005-06a7-2af9ccf19b51', '5ca21ef1-623e-0006-ff8b-c1141e0bce59', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('eb95bf33-954f-0007-bceb-b20e5485ffb1', '3ae0fc91-9acf-0005-06a7-2af9ccf19b51', '5255297c-d992-0006-4de2-8306b24109e7', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('12d4187b-e3ca-0007-ed03-48221983a249', '3ae0fc91-9acf-0005-06a7-2af9ccf19b51', '3b0d79af-38c8-0006-970a-2877cfc59131', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4d97eedb-d973-0007-da06-ef0f9b38f068', '3ae0fc91-9acf-0005-06a7-2af9ccf19b51', 'fc49af75-7fb6-0006-e311-bf38ab82a796', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('31346284-3c77-0007-dfd2-3fb7fb039966', '3ae0fc91-9acf-0005-06a7-2af9ccf19b51', '7d32ad87-9bcc-0006-6d63-031bcceb1b7e', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('406b38e9-d178-0007-78f4-9e2284bd03c3', '3ae0fc91-9acf-0005-06a7-2af9ccf19b51', '40cf4020-29c7-0006-6bce-361774fc2ced', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('02d4b8f2-2de6-0007-1b9f-978ef0b85160', '3ae0fc91-9acf-0005-06a7-2af9ccf19b51', '5b22976d-62cc-0006-d50f-8277a6bb2af1', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('8b378f14-03d2-0007-3844-3d607d31574f', '3ae0fc91-9acf-0005-06a7-2af9ccf19b51', '0b049e08-e6e9-0006-44e8-efd2fe719ac5', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('6baa5091-569b-0007-53f8-7a46830949da', '3ae0fc91-9acf-0005-06a7-2af9ccf19b51', '7fd110a7-4f2b-0006-85c1-a10ce80701f0', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4695ca73-604f-0007-4254-893868096d84', '3ae0fc91-9acf-0005-06a7-2af9ccf19b51', '9102d5a1-ac5f-0006-a057-6393aef813e1', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('439d3666-6ef0-0007-dd76-4fadf4af9558', '3ae0fc91-9acf-0005-06a7-2af9ccf19b51', 'd69142ce-1550-0006-5cf7-b8a659857391', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('84bafdb5-58db-0007-b6a7-901be200eda2', '3ae0fc91-9acf-0005-06a7-2af9ccf19b51', '779cbd46-c4d9-0006-ff5c-9f228c0b4da5', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('5e28be36-7585-0007-a0e9-067f597df12e', '3ae0fc91-9acf-0005-06a7-2af9ccf19b51', 'b4f8606a-abf1-0006-8e3c-d48051f0b659', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9ba3ea6c-3ff1-0007-da07-4e0f4af6915a', '3ae0fc91-9acf-0005-06a7-2af9ccf19b51', 'd5aa9ec2-8926-0006-5b24-ce213b96f3aa', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('00ce6ccf-bbb3-0007-4492-5a0643e01074', '3ae0fc91-9acf-0005-06a7-2af9ccf19b51', '800d470d-f9d3-0006-a680-3b52a6787d59', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('cbaf2ac6-c759-0007-f1fe-138cefe61efb', '3ae0fc91-9acf-0005-06a7-2af9ccf19b51', '32fcfff3-bf52-0006-3d93-7d93ddbc3ca1', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ad89e2ed-8e62-0007-1b7c-b039ee03255a', '3ae0fc91-9acf-0005-06a7-2af9ccf19b51', '68c031f0-91c8-0006-a62c-f00e64f48603', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f05a059c-cb2d-0007-5e67-def21ce5e7b3', '3ae0fc91-9acf-0005-06a7-2af9ccf19b51', 'ba52db7d-7e19-0006-e06a-2c692eefc4de', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;


-- ========================================
-- Alliance SC ROSTER
-- ========================================
INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('3dad303e-e74b-0007-0241-c70629f5e399', '6778fbca-ca21-0005-a2e2-d5b9dfc49df6', 'eff0ad86-a9c6-0006-e5f7-ca4d37ad5cb5', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9f250af9-1da1-0007-0e74-331b2cd51e25', '6778fbca-ca21-0005-a2e2-d5b9dfc49df6', 'caec3d52-c03a-0006-ec65-5b08d4d3dc0a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d9f83b43-ef95-0007-3b8d-6f2a89636d0d', '6778fbca-ca21-0005-a2e2-d5b9dfc49df6', '36f71167-5317-0006-d0aa-acbe201f774f', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('acff1a3b-ffc1-0007-d199-4968f5df450b', '6778fbca-ca21-0005-a2e2-d5b9dfc49df6', 'd835978e-f207-0006-65ee-6333880b7597', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('98b52348-4326-0007-7bed-f0e9e296086e', '6778fbca-ca21-0005-a2e2-d5b9dfc49df6', 'cf6a8c79-cf8d-0006-170f-bacbe88aba4c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('54212034-0bbb-0007-4497-0efdd4f03c24', '6778fbca-ca21-0005-a2e2-d5b9dfc49df6', '51861750-b8fa-0006-56be-e7346cd0d220', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d48d5502-8404-0007-6888-526cee913ab6', '6778fbca-ca21-0005-a2e2-d5b9dfc49df6', '02f9d145-bb1a-0006-eb8b-f4d1277cae78', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7da02e97-5288-0007-3fac-f559183ece63', '6778fbca-ca21-0005-a2e2-d5b9dfc49df6', '5cf2478b-4c5d-0006-237a-a8271f4e02c1', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c8138f48-3e71-0007-6fd8-d923235f32e7', '6778fbca-ca21-0005-a2e2-d5b9dfc49df6', '7751451a-65bc-0006-1ae7-6733ae9bf858', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9453a916-5c02-0007-9165-98b37cd4466e', '6778fbca-ca21-0005-a2e2-d5b9dfc49df6', 'e13cfeb9-343a-0006-36bb-a0f0088ff3e2', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('8d020a13-16e6-0007-4d80-0daa3564dbd4', '6778fbca-ca21-0005-a2e2-d5b9dfc49df6', 'cc9f00af-45b7-0006-6cbc-bea9832c7fc1', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('19793e98-4710-0007-83e1-2e6d3d615e4f', '6778fbca-ca21-0005-a2e2-d5b9dfc49df6', 'fadea840-662e-0006-9701-5fd9f1dfb3b0', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7977bf54-b429-0007-896e-eaf04cd72b38', '6778fbca-ca21-0005-a2e2-d5b9dfc49df6', '96edb7ca-eada-0006-eaeb-c388fd6bdd7d', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9f0f04bb-dfaf-0007-7c1c-d89899afff7f', '6778fbca-ca21-0005-a2e2-d5b9dfc49df6', '3a82f7f6-9f2d-0006-93e8-aa6ab33d8f7c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d2d2f4b9-4a40-0007-2be5-f475f5ef5a26', '6778fbca-ca21-0005-a2e2-d5b9dfc49df6', '270cc341-a114-0006-ec56-3a9fccb6a6bc', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d7ba96a0-aed7-0007-f6cd-aa2ae28a3ae7', '6778fbca-ca21-0005-a2e2-d5b9dfc49df6', 'df9caa89-de4c-0006-3f71-64b0a257e243', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('34430e54-d156-0007-13e4-c520bf4da889', '6778fbca-ca21-0005-a2e2-d5b9dfc49df6', '121da025-6ba1-0006-3ac3-ab2bf02690e0', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d2296a1c-fe11-0007-54af-7523005f418c', '6778fbca-ca21-0005-a2e2-d5b9dfc49df6', 'fc3700a0-3105-0006-8a86-1eb6e452103f', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c82b6af6-8563-0007-baf5-014a6b252722', '6778fbca-ca21-0005-a2e2-d5b9dfc49df6', '74c48423-50fe-0006-9b5e-a91db71a02f6', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0ebe1904-e59e-0007-6888-7f664db5a358', '6778fbca-ca21-0005-a2e2-d5b9dfc49df6', '39de285a-25e2-0006-ea15-cd1589ff6fa5', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('82757a6f-2f60-0007-f209-125572b170d6', '6778fbca-ca21-0005-a2e2-d5b9dfc49df6', '9d8c4573-6c25-0006-c96a-87176662bddd', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('8a9bc9f6-7d35-0007-8079-4b01e459cf71', '6778fbca-ca21-0005-a2e2-d5b9dfc49df6', '1b7fda65-9e7e-0006-37fe-fb946d2d152c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('fe665562-78af-0007-245b-b18db704d8a6', '6778fbca-ca21-0005-a2e2-d5b9dfc49df6', 'babbeebc-37b5-0006-f336-d6856f8dfb5b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0d8b91ec-268b-0007-458a-90301aa48d75', '6778fbca-ca21-0005-a2e2-d5b9dfc49df6', '79446aef-a5c9-0006-e301-c46029ca3cca', 8, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4c66baac-3a7f-0007-557c-3d5d9f5ef50b', '6778fbca-ca21-0005-a2e2-d5b9dfc49df6', 'b0cdf812-577c-0006-107a-5dc16237f88f', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('efaa7776-ca12-0007-0030-9a0292bf83f1', '6778fbca-ca21-0005-a2e2-d5b9dfc49df6', 'c309c35d-f4a0-0006-d13b-4f5ebaa12765', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ea6d9fd5-cc88-0007-cc00-439aa76ac27e', '6778fbca-ca21-0005-a2e2-d5b9dfc49df6', 'cfebbeb5-b3e5-0006-cf3b-41499bb8bae7', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c7042346-9539-0007-b26b-22a040d8ddc4', '6778fbca-ca21-0005-a2e2-d5b9dfc49df6', '668558ba-53a6-0006-ea66-abd8ce89a6fd', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d50dbcb9-6fd9-0007-2d77-46d32625a2b7', '6778fbca-ca21-0005-a2e2-d5b9dfc49df6', '445838aa-5a02-0006-ef8f-f6d5b3f499d8', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;


-- ========================================
-- SC Gwinnett ROSTER
-- ========================================
INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c7e1ba1b-e2bf-0007-ba27-d9c7878f6715', 'd2c80f1f-3aa2-0005-9951-cacab62cb9fc', '5663ac0e-d6f3-0006-5a6b-7e4768d01481', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2016ded7-fb1f-0007-7b42-43346990269f', 'd2c80f1f-3aa2-0005-9951-cacab62cb9fc', '94885f0d-b8a2-0006-bb09-90aeda2b88f6', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('eb3cfc72-984a-0007-826a-dbd85a953cc8', 'd2c80f1f-3aa2-0005-9951-cacab62cb9fc', 'bb67c0f6-6f3b-0006-c4c2-980cc8207f19', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d5647585-0f09-0007-f733-cc35c9cc8f43', 'd2c80f1f-3aa2-0005-9951-cacab62cb9fc', '2f66afc0-9bd4-0006-7e7e-5238f40eebb0', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('480cfd05-96d5-0007-036c-f0f4eaef4301', 'd2c80f1f-3aa2-0005-9951-cacab62cb9fc', '6b3af454-9681-0006-6961-1c23eccaf4a4', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4ae74fd3-ab92-0007-d3a5-5b9c58137444', 'd2c80f1f-3aa2-0005-9951-cacab62cb9fc', 'ea689bee-87e8-0006-4e2d-26cd2b50973f', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('4a419a96-2e11-0007-de78-e20ac5580180', 'd2c80f1f-3aa2-0005-9951-cacab62cb9fc', 'eed85bda-375a-0006-24d3-11a2c8be7ef6', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('6a907e04-9847-0007-41b9-b5d3b11438f4', 'd2c80f1f-3aa2-0005-9951-cacab62cb9fc', '4470d8a6-f46b-0006-b2ad-6eb29365be8b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a3aa333c-e857-0007-54e6-32bf62001854', 'd2c80f1f-3aa2-0005-9951-cacab62cb9fc', 'ca696aae-8c13-0006-5072-1ddfb011d2ac', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f01de0b6-ff55-0007-3e80-373df480d08d', 'd2c80f1f-3aa2-0005-9951-cacab62cb9fc', 'c4dc2286-4ae0-0006-0a46-28a0f2736353', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d5554bab-9165-0007-4e2a-d3073484e81b', 'd2c80f1f-3aa2-0005-9951-cacab62cb9fc', 'd3f94877-31c5-0006-0c0a-40d566403b17', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('6372301a-1b1d-0007-2af6-31e20fc975dd', 'd2c80f1f-3aa2-0005-9951-cacab62cb9fc', '1fa147ea-b8e7-0006-b883-cc3b1c41483d', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('6d8a9ec6-c1f2-0007-1060-bf024442ef51', 'd2c80f1f-3aa2-0005-9951-cacab62cb9fc', '2cf5fff2-7e09-0006-d248-a063ebd814a8', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d00613f3-64fc-0007-9e90-123ab3531cdf', 'd2c80f1f-3aa2-0005-9951-cacab62cb9fc', '8d7d943d-cf15-0006-d21f-0a0b28cc9f98', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('33cbb69c-b9b0-0007-9470-3b2223bf471e', 'd2c80f1f-3aa2-0005-9951-cacab62cb9fc', '96ed43c4-4720-0006-5f8c-a3e24a9f67b0', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e809b708-b1e8-0007-7292-ec72de9df4ee', 'd2c80f1f-3aa2-0005-9951-cacab62cb9fc', '47a34124-dedf-0006-4230-a2a3eff9cde2', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('5df45b9c-e16b-0007-a757-5dfd47fc7110', 'd2c80f1f-3aa2-0005-9951-cacab62cb9fc', '93e5c8c8-d4dd-0006-97aa-7a8760a98cba', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ab715bf3-b27a-0007-7afa-1151f7d937d4', 'd2c80f1f-3aa2-0005-9951-cacab62cb9fc', '04008f6e-0f84-0006-f7ab-b3e397a27570', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('275ef920-ef27-0007-4198-8121df664864', 'd2c80f1f-3aa2-0005-9951-cacab62cb9fc', 'f982d691-2b9d-0006-2134-eed4cd86be4e', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('31e1b828-a9dc-0007-3f38-b8da66a8bd32', 'd2c80f1f-3aa2-0005-9951-cacab62cb9fc', 'fe6ecd1b-23e1-0006-5a4f-21d23c208945', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('25ab9704-a88b-0007-b488-6e095a3d6d4b', 'd2c80f1f-3aa2-0005-9951-cacab62cb9fc', '73b685ec-39e7-0006-881e-7f5476bdd43c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('6a4e6000-344f-0007-e525-7464c60b8b4a', 'd2c80f1f-3aa2-0005-9951-cacab62cb9fc', 'cd34aae8-c306-0006-10aa-cc66434b135a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('8c95a417-7fb1-0007-acb2-917f51f1fb82', 'd2c80f1f-3aa2-0005-9951-cacab62cb9fc', '7adb4c64-82c4-0006-2798-f01ed6ec79f6', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('955a7a4f-d437-0007-784a-c270b53e89f3', 'd2c80f1f-3aa2-0005-9951-cacab62cb9fc', 'c83d9d36-0b03-0006-52d3-742c46bf54af', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('82cf84c2-ee9c-0007-7b3c-a0f470df5a70', 'd2c80f1f-3aa2-0005-9951-cacab62cb9fc', '79b9e4cc-05ae-0006-59a2-7d43db57580c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('036975a2-785f-0007-19cb-a2ba2a0fa41a', 'd2c80f1f-3aa2-0005-9951-cacab62cb9fc', 'da170cc8-0375-0006-2972-9b67eb8176a3', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('329ac484-801c-0007-16ac-809547dbd326', 'd2c80f1f-3aa2-0005-9951-cacab62cb9fc', 'b0ba7e22-61ef-0006-32b7-a9256a34347c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('bf20d139-b414-0007-1a3a-49808f1b4d71', 'd2c80f1f-3aa2-0005-9951-cacab62cb9fc', '8b0f37c3-c302-0006-2b4b-0245b5403fd5', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('a0b4afa8-2db1-0007-7ae7-e2edb64e41b0', 'd2c80f1f-3aa2-0005-9951-cacab62cb9fc', '7dc91d0e-f073-0006-31bd-d9616e9771d7', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('fd84e0d0-99d8-0007-9085-c05d75df675c', 'd2c80f1f-3aa2-0005-9951-cacab62cb9fc', '819b01bb-63ca-0006-74f7-1a50fe600419', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1d757ab1-62a8-0007-c7ec-2944e15be1ba', 'd2c80f1f-3aa2-0005-9951-cacab62cb9fc', '1ce8e347-3f93-0006-bb0f-72263aaf51ba', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('982f19f5-b6f3-0007-b207-8eb1a8c54264', 'd2c80f1f-3aa2-0005-9951-cacab62cb9fc', '02367907-63f3-0006-073c-06dafa1e1789', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('cec0ff3c-25bb-0007-c165-7d32e5318b34', 'd2c80f1f-3aa2-0005-9951-cacab62cb9fc', 'cb5bb2a3-ba01-0006-ca9a-05009b4c8825', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('d5d4a547-362d-0007-c799-d5c78d7f47ff', 'd2c80f1f-3aa2-0005-9951-cacab62cb9fc', '73a05d99-04fd-0006-32a6-c41b3add7e85', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('66f56c89-f9f0-0007-6ce8-ddfd91361593', 'd2c80f1f-3aa2-0005-9951-cacab62cb9fc', '2190ac37-15a8-0006-456d-119506e76681', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f70b3a3e-902a-0007-7b5c-68667da28110', 'd2c80f1f-3aa2-0005-9951-cacab62cb9fc', 'f8eced56-d69a-0006-f53b-3220242f803f', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0a597feb-b098-0007-a8db-a17dbb13ff4b', 'd2c80f1f-3aa2-0005-9951-cacab62cb9fc', 'ed991c95-61ff-0006-3e72-6b4427973b28', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('1ed12de3-a1e2-0007-5754-1a85eeff3cc1', 'd2c80f1f-3aa2-0005-9951-cacab62cb9fc', 'c854eba3-7d7e-0006-ec5b-100a49fb4008', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('082f6c9a-912a-0007-1962-1ea9afd554d9', 'd2c80f1f-3aa2-0005-9951-cacab62cb9fc', '275867f1-2f1d-0006-48d9-52acdf058b53', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c2823acd-0d03-0007-e7e3-891e3f67f9de', 'd2c80f1f-3aa2-0005-9951-cacab62cb9fc', 'b979144e-f13a-0006-d073-9d7395135fce', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('24ebd8e1-855e-0007-63b2-ad569ac9be10', 'd2c80f1f-3aa2-0005-9951-cacab62cb9fc', '11a79595-d543-0006-6724-5a60f65aa447', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c58f2a5e-afbe-0007-4a7b-03f173880eb0', 'd2c80f1f-3aa2-0005-9951-cacab62cb9fc', '7bc33332-c71b-0006-11b3-91a29b1943c4', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('37ed212c-3a66-0007-2e98-477de98846e6', 'd2c80f1f-3aa2-0005-9951-cacab62cb9fc', 'bff67770-1a0b-0006-a19f-a73c7cc0776b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('63b993f3-c337-0007-d7e3-10e719cf27d0', 'd2c80f1f-3aa2-0005-9951-cacab62cb9fc', 'bf524d90-e409-0006-7dd9-a87fc8cfc4aa', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('58237c29-ba80-0007-5dba-87819be869a8', 'd2c80f1f-3aa2-0005-9951-cacab62cb9fc', '602c23d3-9a87-0006-be8f-7e4d1ff9af3c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('de424730-06d7-0007-6046-d16549e5c880', 'd2c80f1f-3aa2-0005-9951-cacab62cb9fc', '9c0bf01f-8396-0006-5e9d-937eba00a25c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9e93dba0-48ef-0007-22d1-a64988be89df', 'd2c80f1f-3aa2-0005-9951-cacab62cb9fc', '35e2ef03-fb37-0006-a18b-b41cf4b78cd3', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b47e37db-19b5-0007-2bbe-c7c68ea301af', 'd2c80f1f-3aa2-0005-9951-cacab62cb9fc', 'b59b8790-b192-0006-b675-18efd8de3040', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('055a3798-b599-0007-b6ed-d16a0af511a5', 'd2c80f1f-3aa2-0005-9951-cacab62cb9fc', 'af5f3821-d0db-0006-6569-baa423dc39f3', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;


-- ========================================
-- Lithonia City FC ROSTER
-- ========================================
INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('52b4ac7a-4009-0007-6c27-6be13221c810', 'fcccc73d-ebb9-0005-64c9-ee520c7672f8', 'c739b13a-6576-0006-5bb2-2f93ba74cbb6', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('5e34eb02-e4ab-0007-fb69-212bab0da027', 'fcccc73d-ebb9-0005-64c9-ee520c7672f8', 'b6d97c5d-90b2-0006-37b6-5a2303eb163a', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9804fa11-214c-0007-5d49-f449a13996c4', 'fcccc73d-ebb9-0005-64c9-ee520c7672f8', 'b87af906-b8b3-0006-29f7-0ddfa1ac3862', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ede9e19a-ef20-0007-80bb-4361a370b7ce', 'fcccc73d-ebb9-0005-64c9-ee520c7672f8', 'b1aae734-0d27-0006-66fc-a13ddc50bfca', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('f2df7f48-03cd-0007-61dc-3103e45a84a5', 'fcccc73d-ebb9-0005-64c9-ee520c7672f8', 'fee02eb6-dd59-0006-5d57-7b75d5b12b9e', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('67f9ccec-8818-0007-caec-1e261f894fbf', 'fcccc73d-ebb9-0005-64c9-ee520c7672f8', 'e9961d8f-b74d-0006-5056-6efe24b3bbbe', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b1841daf-480f-0007-2edb-471a536103c5', 'fcccc73d-ebb9-0005-64c9-ee520c7672f8', '08913780-7bf7-0006-d3df-41e01b27d88d', 2, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('9c88993e-1b3f-0007-fa18-f1a6a0c184aa', 'fcccc73d-ebb9-0005-64c9-ee520c7672f8', '67201bda-2955-0006-b71f-927618f5ae53', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('29d35569-2f5e-0007-3d25-a12abcfb2d73', 'fcccc73d-ebb9-0005-64c9-ee520c7672f8', 'f7514e41-5757-0006-80fc-b9c5f31fa934', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('c9087ee2-3bd0-0007-5d11-55c12de085c6', 'fcccc73d-ebb9-0005-64c9-ee520c7672f8', 'de1fe14e-bb12-0006-827b-b1012f5d69de', 1, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('78552112-e055-0007-0e2a-4f2fe41d77bc', 'fcccc73d-ebb9-0005-64c9-ee520c7672f8', '1d4e2c2d-30b6-0006-3bc6-2e7c2ff30140', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('e5e9aacd-db06-0007-0771-21af6e700066', 'fcccc73d-ebb9-0005-64c9-ee520c7672f8', 'd8c47625-808c-0006-61ee-ae7cb3e3a52c', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('82bb5d7d-112c-0007-5294-dbe5bd0c73dc', 'fcccc73d-ebb9-0005-64c9-ee520c7672f8', 'e27e77a2-a2d8-0006-a353-bc685f147361', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('b854ae57-30f4-0007-d133-f97cd7b95ee1', 'fcccc73d-ebb9-0005-64c9-ee520c7672f8', 'a2e665d8-ffb4-0006-f969-a936d7d7ca41', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('7a53b9e8-d7ed-0007-528c-96132e653815', 'fcccc73d-ebb9-0005-64c9-ee520c7672f8', '3f422c12-7367-0006-e9c7-5e73cb0fd6fd', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('68cd33bb-8201-0007-bf37-791e15d8bbc0', 'fcccc73d-ebb9-0005-64c9-ee520c7672f8', 'a96fb340-d6a4-0006-5451-e428593dcc62', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('8ecd9792-ba87-0007-fe5a-71d738f242d7', 'fcccc73d-ebb9-0005-64c9-ee520c7672f8', 'e7f2f206-b43d-0006-5b70-cd9a8a9f4292', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0cb2984c-f72a-0007-cabd-1e8254f0cb82', 'fcccc73d-ebb9-0005-64c9-ee520c7672f8', '0fbec5c8-2659-0006-c844-9742e6b518ca', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('483b9928-3496-0007-de37-453453f7c044', 'fcccc73d-ebb9-0005-64c9-ee520c7672f8', '258ebc29-8db9-0006-affd-8026eaa7d7d6', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('0d68fb9c-013a-0007-854b-115144bfe0e5', 'fcccc73d-ebb9-0005-64c9-ee520c7672f8', '6cfa8eb7-033a-0006-5b54-6e5d0bed1f7e', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ad672e17-12f1-0007-f6eb-4d4196c5961b', 'fcccc73d-ebb9-0005-64c9-ee520c7672f8', '401961e9-22fc-0006-e710-dc480de22552', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('2fb7e747-678a-0007-7ce5-250ab639892b', 'fcccc73d-ebb9-0005-64c9-ee520c7672f8', '0244d2b0-f028-0006-4cd6-b4055957613b', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ad9bd9bb-2488-0007-1464-1fa89f71acc4', 'fcccc73d-ebb9-0005-64c9-ee520c7672f8', '9e344863-6949-0006-201e-cd6a0c3876eb', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;

INSERT INTO team_players (id, team_id, player_id, jersey_number, roster_status_id, is_active)
VALUES ('ae6ec094-aedf-0007-f7f9-43e588c527c2', 'fcccc73d-ebb9-0005-64c9-ee520c7672f8', '23051d8c-96d9-0006-db80-f0fba977bafa', NULL, 1, true)
ON CONFLICT (team_id, player_id) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number,
  roster_status_id = EXCLUDED.roster_status_id,
  is_active = EXCLUDED.is_active;


