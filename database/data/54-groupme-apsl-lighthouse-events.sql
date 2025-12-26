-- APSL Lighthouse - Calendar Events

INSERT INTO groupme_events (id, groupme_event_id, groupme_group_id, name, description, start_at, end_at, location, is_cancelled, sync_status)
VALUES
  ('0fab98fb-e4f7-44bc-8958-031c32b9a351', '13d1c1ded4484cad838f882b9c76b086', '53dc80a8-5631-484e-81b6-c632d8a04f95', 'Lighthouse Vs Jersey Shore Boca', NULL, '2025-11-30T22:00:00.000Z', '2025-12-01T01:30:00.000Z', '{"lat":0,"lng":0,"name":"Toms River HS South ","address":"55 HYERS STREET, TOMS RIVER, NJ, TOMS RIVER, NJ"}', false, 'pending'),
  ('4362e150-1c1c-4792-86c4-8aef5f31d3ce', '4380b75755934f949c6a530bb7bb1b1a', '53dc80a8-5631-484e-81b6-c632d8a04f95', '1st Team APSL Vs West Chester', NULL, '2025-12-03T00:00:00.000Z', '2025-12-03T03:30:00.000Z', '{"lat":0,"lng":0,"name":"Penn Fusion Kildare''s Field ","address":"601 Westtown Road. West Chester, PA 19382"}', false, 'pending')
ON CONFLICT (id) DO UPDATE SET
  groupme_event_id = EXCLUDED.groupme_event_id,
  groupme_group_id = EXCLUDED.groupme_group_id,
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  start_at = EXCLUDED.start_at,
  end_at = EXCLUDED.end_at,
  location = EXCLUDED.location,
  is_cancelled = EXCLUDED.is_cancelled,
  sync_status = EXCLUDED.sync_status
;

