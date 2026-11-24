-- 1825 (2026-11-24) — 🔺 #apsl-pyramid flow chart: the caption and the
-- colour key share ONE line (owner: "clutter?" · "can go on same line as
-- legend?").  The caption loses the counts the title row already shows;
-- the Legend panel title goes with the panel.
BEGIN;
UPDATE message_templates
   SET body = 'American soccer usually has no promotion or relegation. The APSL does: finish top and you can move up, finish bottom and you can drop. The arrows show who moves where.'
 WHERE kind = 'apsl_pyramid' AND tier = 'story_view_flow';
DELETE FROM message_templates WHERE kind = 'apsl_pyramid' AND tier = 'hud_legend';
COMMIT;
