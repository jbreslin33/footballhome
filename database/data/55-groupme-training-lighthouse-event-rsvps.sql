-- Training Lighthouse - Event RSVPs

INSERT INTO groupme_event_rsvps (id, groupme_event_id, groupme_user_id, status, responded_at)
VALUES
  ('55e86573-14f8-43de-8f92-e2f4e0ee2b73', 'db1adebc-2e80-4f6b-8e4f-2dd5d1524063', '686c0de7-5380-4fa2-861b-dfba29b1cb41', 'going', '2025-12-26T23:04:29.895Z'),
  ('f705f88c-16f0-45ad-8441-3ba638508b60', '38838d7f-02e7-4436-8e4e-9fc3565412a3', '686c0de7-5380-4fa2-861b-dfba29b1cb41', 'going', '2025-12-26T23:04:29.895Z'),
  ('1f1c69a5-6bd1-4abd-8cca-44c38d5c32a3', '2f4c6ff2-e8d8-4000-8264-64190daf3835', '686c0de7-5380-4fa2-861b-dfba29b1cb41', 'going', '2025-12-26T23:04:29.895Z'),
  ('c8f26e6d-b729-47bd-8d8b-33f314a5f135', 'afb47723-1fb6-4b43-852f-fb4632f7ca8c', '686c0de7-5380-4fa2-861b-dfba29b1cb41', 'going', '2025-12-26T23:04:29.896Z'),
  ('5c56c4d7-d182-47c1-8f09-46bf924817b4', '3b7861e0-d5ff-4e05-874e-1cc6045751d5', '686c0de7-5380-4fa2-861b-dfba29b1cb41', 'going', '2025-12-26T23:04:29.896Z'),
  ('6be8a183-5910-41ee-8dac-d6885d514570', 'b44059c4-c217-44af-85d7-1e6d6ff70b8c', '686c0de7-5380-4fa2-861b-dfba29b1cb41', 'going', '2025-12-26T23:04:29.896Z'),
  ('cd1a88ec-3fad-4f22-87d4-25d806fefd4f', '8aa0fa55-f5a2-4adb-82d8-2656e0e5fe9d', '686c0de7-5380-4fa2-861b-dfba29b1cb41', 'going', '2025-12-26T23:04:29.896Z'),
  ('786f50d3-5f8e-4cb4-8c8d-6ae6ebe16df4', '20ae424f-ddaf-44af-8bfe-5a5f1a129a3a', '686c0de7-5380-4fa2-861b-dfba29b1cb41', 'going', '2025-12-26T23:04:29.896Z'),
  ('b975fb3d-a95e-4d2b-8bb2-6db88d44bb60', 'b94ba29c-69ec-44a1-88aa-4fc097736543', '686c0de7-5380-4fa2-861b-dfba29b1cb41', 'going', '2025-12-26T23:04:29.896Z'),
  ('6f43eb6c-0e8a-4be8-8300-330315ba974c', 'b30327e1-1152-4560-8a34-e8eb58a2d832', '686c0de7-5380-4fa2-861b-dfba29b1cb41', 'going', '2025-12-26T23:04:29.896Z'),
  ('5aa33622-0da2-4bcb-83e1-6a8ccd97106c', 'c98a9857-c89f-4949-8408-aa2cb6d44d3e', '686c0de7-5380-4fa2-861b-dfba29b1cb41', 'going', '2025-12-26T23:04:29.896Z'),
  ('2af0cf14-7b9e-4db1-8fde-3db75626b215', '3ca1a1ab-fdf9-4853-85be-2c5e3c455db0', '686c0de7-5380-4fa2-861b-dfba29b1cb41', 'going', '2025-12-26T23:04:29.896Z')
ON CONFLICT (id) DO UPDATE SET
  groupme_event_id = EXCLUDED.groupme_event_id,
  groupme_user_id = EXCLUDED.groupme_user_id,
  status = EXCLUDED.status,
  responded_at = EXCLUDED.responded_at
;

