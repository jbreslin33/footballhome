-- Insert confirmed fuzzy GroupMe → person matches
-- 9 original confirmed + 4 new (Amar, Musa x2, Majid)
INSERT INTO external_identities (person_id, provider_id, external_user_id, external_username)
VALUES
  -- Original 9 confirmed fuzzy matches
  (1223, 1, '94024150', 'Chris Fletcher'),
  (1221, 1, '134880198', 'Alex Duopu'),
  (1227, 1, '28549771', 'Gosie Ahmed'),
  (4406, 1, '123823038', 'Gangue Abouya'),
  (4463, 1, '125487699', 'Babacar'),
  (1215, 1, '93185527', 'Arsene'),
  (1214, 1, '94275062', 'Erwa'),
  (4455, 1, '121062896', 'Zuhaib Imran'),
  (1231, 1, '93667641', 'Abdoulaye'),
  -- 4 new confirmed matches
  (1211, 1, '97325370', 'Amar'),
  (1210, 1, '120781414', 'Musa'),
  (1220, 1, '122495163', 'Musa'),
  (1233, 1, '89900747', 'Majid Hamid')
ON CONFLICT (provider_id, external_user_id) DO UPDATE SET
  person_id = EXCLUDED.person_id;

-- Backfill RSVPs: set person_id from external_identities where missing
UPDATE chat_event_rsvps r
SET person_id = ei.person_id
FROM external_identities ei
WHERE r.external_user_id = ei.external_user_id
  AND ei.provider_id = 1
  AND r.person_id IS NULL;
