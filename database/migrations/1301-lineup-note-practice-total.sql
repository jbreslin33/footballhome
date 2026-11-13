-- 1301 (2026-11-12): P: on the Starters & Bench note = the week's total,
-- attended + projected (owner: "i like P: to be total of A + P so for Luke
-- for example his would be A:2,P:5").  {total} token from
-- GameCenterScreen._lineupNote.
UPDATE message_templates SET body = 'A:{attended} P:{total}'
 WHERE kind = 'eligibility' AND tier = 'lineup_note_practice' AND body = 'A:{attended} P:{projected}';
INSERT INTO schema_migrations (filename) VALUES ('1301-lineup-note-practice-total.sql') ON CONFLICT DO NOTHING;
