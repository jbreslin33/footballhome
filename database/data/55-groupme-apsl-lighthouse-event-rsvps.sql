-- APSL Lighthouse - Event RSVPs

INSERT INTO groupme_event_rsvps (id, groupme_event_id, groupme_user_id, status, responded_at)
VALUES
  ('6fd8cc65-b53e-4650-830e-88515e34ebcb', '0fab98fb-e4f7-44bc-8958-031c32b9a351', '686c0de7-5380-4fa2-861b-dfba29b1cb41', 'going', '2025-12-26T23:04:26.654Z'),
  ('321f8fda-b9f4-45af-8e3b-c974077432da', '4362e150-1c1c-4792-86c4-8aef5f31d3ce', '686c0de7-5380-4fa2-861b-dfba29b1cb41', 'going', '2025-12-26T23:04:26.654Z')
ON CONFLICT (id) DO UPDATE SET
  groupme_event_id = EXCLUDED.groupme_event_id,
  groupme_user_id = EXCLUDED.groupme_user_id,
  status = EXCLUDED.status,
  responded_at = EXCLUDED.responded_at
;

