-- 1350 (2026-11-13): Practice card words — the auto-filled graphic atop a
-- practice's 👥 All Players (owner: "practice needs a graphic like game but
-- auto filled … separate in lineup by age. same with mens practice sep by
-- 'team' apsl or liga 1"; PracticeScreen._teamCardHtml).
BEGIN;
INSERT INTO message_templates (category, label, kind, tier, body, is_active, sort_order, client_side, is_public) VALUES
  ('Event Center', 'Practice card — title',              'event_center', 'card_title',   'LIGHTHOUSE · {kind}', true, 1240, true, false),
  ('Event Center', 'Practice card — going total',        'event_center', 'card_total',   '{n} going',           true, 1241, true, false),
  ('Event Center', 'Practice card — coaches line',       'event_center', 'card_coaches', 'Coaches: {names}',    true, 1242, true, false),
  ('Event Center', 'Practice card — players on no tagged team', 'event_center', 'card_other', 'Invited',        true, 1243, true, false);
INSERT INTO schema_migrations (filename) VALUES ('1350-practice-team-card.sql') ON CONFLICT DO NOTHING;
COMMIT;
