-- 1355 (2026-11-13): Practice card on pitches (owner: "i like it on pitch",
-- "if indoor then indoor pitch. if outdoor then outdoor", "in order of
-- highest age to lowest").  Words for the bench line and the setting tag;
-- the setting itself = fh_event_job_setting (mig 931), sent as event.setting.
BEGIN;
INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public) VALUES
  ('Event Center', 'Practice card — players beyond the pitch', 'event_center', 'card_bench',   'Rotating in', true, 1244, true, false),
  ('Event Center', 'Practice card — indoor tag',               'event_center', 'card_indoor',  'Indoor',      true, 1245, true, false),
  ('Event Center', 'Practice card — outdoor tag',              'event_center', 'card_outdoor', 'Outdoor',     true, 1246, true, false);
INSERT INTO schema_migrations (filename) VALUES ('1355-practice-card-pitch.sql') ON CONFLICT DO NOTHING;
COMMIT;
