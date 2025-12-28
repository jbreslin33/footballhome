-- Training Lighthouse - Calendar Events

INSERT INTO groupme_events (id, groupme_event_id, groupme_group_id, name, description, start_at, end_at, location, is_cancelled, sync_status)
VALUES
  ('db1adebc-2e80-4f6b-8e4f-2dd5d1524063', '05185f7920c14cb8825547ad4779afbd', '42d08e9d-1498-41c0-8538-b12f4e3663c7', 'Monday Training Indoor Flats', NULL, '2025-12-01T23:00:00.000Z', '2025-12-02T00:50:00.000Z', '{"lat":0,"lng":0,"name":"The Lighthouse Community Center ","address":"141 W Somerset St, Philadelphia, PA 19133"}', false, 'pending'),
  ('38838d7f-02e7-4436-8e4e-9fc3565412a3', 'ed035c7123da47758822572e7bbbf33e', '42d08e9d-1498-41c0-8538-b12f4e3663c7', 'Saturday Training Indoor Flats', NULL, '2025-12-06T14:00:00.000Z', '2025-12-06T16:00:00.000Z', '{"lat":0,"lng":0,"name":"The Lighthouse Community Center ","address":"141 W Somerset St, Philadelphia, PA 19133"}', false, 'pending'),
  ('2f4c6ff2-e8d8-4000-8264-64190daf3835', 'd14fb27ba4eb42138d2b7d12d841e61f', '42d08e9d-1498-41c0-8538-b12f4e3663c7', 'Sunday Training Indoor Flats', NULL, '2025-12-07T14:00:00.000Z', '2025-12-07T16:00:00.000Z', '{"lat":0,"lng":0,"name":"The Lighthouse Community Center ","address":"141 W Somerset St, Philadelphia, PA 19133"}', false, 'pending'),
  ('afb47723-1fb6-4b43-852f-fb4632f7ca8c', 'a376627892ad431888bf7a2dd556d262', '42d08e9d-1498-41c0-8538-b12f4e3663c7', 'Monday Training Indoor Flats', NULL, '2025-12-08T23:00:00.000Z', '2025-12-09T01:00:00.000Z', '{"lat":0,"lng":0,"name":"The Lighthouse Community Center ","address":"141 W Somerset St, Philadelphia, PA 19133"}', false, 'pending'),
  ('3b7861e0-d5ff-4e05-874e-1cc6045751d5', 'a3b8e835d5ba40248f10d147cba36466', '42d08e9d-1498-41c0-8538-b12f4e3663c7', 'Saturday Training Indoor Flats', NULL, '2025-12-13T14:00:00.000Z', '2025-12-13T16:00:00.000Z', '{"lat":0,"lng":0,"name":"The Lighthouse Community Center ","address":"141 W Somerset St, Philadelphia, PA 19133"}', false, 'pending'),
  ('b44059c4-c217-44af-85d7-1e6d6ff70b8c', '3515ec3d49a84940b41bc8dafca2e82f', '42d08e9d-1498-41c0-8538-b12f4e3663c7', 'Monday Training Indoor Flats', NULL, '2025-12-13T23:00:00.000Z', '2025-12-14T01:00:00.000Z', '{"lat":0,"lng":0,"name":"The Lighthouse Community Center ","address":"141 W Somerset St, Philadelphia, PA 19133"}', false, 'pending'),
  ('8aa0fa55-f5a2-4adb-82d8-2656e0e5fe9d', 'a6186a5028144d24bed24049409c39a7', '42d08e9d-1498-41c0-8538-b12f4e3663c7', 'Monday Training Indoor Flats', NULL, '2025-12-15T23:00:00.000Z', '2025-12-16T01:00:00.000Z', '{"lat":0,"lng":0,"name":"The Lighthouse Community Center ","address":"141 W Somerset St, Philadelphia, PA 19133"}', false, 'pending'),
  ('20ae424f-ddaf-44af-8bfe-5a5f1a129a3a', 'bc6c2a00a50c49a5a10e834b586b5594', '42d08e9d-1498-41c0-8538-b12f4e3663c7', 'Saturday Training Indoor Flats', NULL, '2025-12-20T14:00:00.000Z', '2025-12-20T16:00:00.000Z', '{"lat":0,"lng":0,"name":"The Lighthouse Community Center ","address":"141 W Somerset St, Philadelphia, PA 19133"}', false, 'pending'),
  ('b94ba29c-69ec-44a1-88aa-4fc097736543', 'e02876d802ad49d09577e7efe2d31965', '42d08e9d-1498-41c0-8538-b12f4e3663c7', 'Monday Training Indoor Flats', NULL, '2025-12-22T23:00:00.000Z', '2025-12-23T01:00:00.000Z', '{"lat":0,"lng":0,"name":"The Lighthouse Community Center ","address":"141 W Somerset St, Philadelphia, PA 19133"}', false, 'pending'),
  ('b30327e1-1152-4560-8a34-e8eb58a2d832', '676c0ca7f2154baeb2df5776aa1451ae', '42d08e9d-1498-41c0-8538-b12f4e3663c7', 'Saturday Training Indoor Flats', NULL, '2025-12-27T14:00:00.000Z', '2025-12-27T16:00:00.000Z', '{"lat":0,"lng":0,"name":"The Lighthouse Community Center ","address":"141 W Somerset St, Philadelphia, PA 19133"}', false, 'pending'),
  ('c98a9857-c89f-4949-8408-aa2cb6d44d3e', '7582172ef5e742648c2b8ba30bca45f6', '42d08e9d-1498-41c0-8538-b12f4e3663c7', 'Sunday Training Indoor Flats', NULL, '2025-12-28T14:00:00.000Z', '2025-12-28T16:00:00.000Z', '{"lat":0,"lng":0,"name":"The Lighthouse Community Center ","address":"141 W Somerset St, Philadelphia, PA 19133"}', false, 'pending'),
  ('3ca1a1ab-fdf9-4853-85be-2c5e3c455db0', '95343f9952964663836e65d2cb8d162e', '42d08e9d-1498-41c0-8538-b12f4e3663c7', 'Monday Training Indoor Flats', NULL, '2025-12-29T23:00:00.000Z', '2025-12-30T01:00:00.000Z', '{"lat":0,"lng":0,"name":"The Lighthouse Community Center ","address":"141 W Somerset St, Philadelphia, PA 19133"}', false, 'pending')
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

