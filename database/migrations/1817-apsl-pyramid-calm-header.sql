-- 1817 (2026-11-24) — 🔺 #apsl-pyramid calmed down (owner: "i feel like its
-- too busy and confusing the whole apsl page" · "i think the conf pills
-- need to go but don't know how").  The page opens on the title line and
-- the view; ▾ Options brings ONE row: three view pills + More ▾ (the other
-- four views), ONE conference pill that opens the on/off list, and the
-- club search.  New labels (public); the two row labels that went with the
-- old View / Conferences rows are deleted.
BEGIN;
INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side, is_public)
SELECT 'APSL pyramid', v.label, 'apsl_pyramid', v.tier, v.body, v.so, true, true
FROM (VALUES
  ('APSL pyramid — More views pill', 'view_more', 'More ▾', 40),
  ('APSL pyramid — More views pill, one of its views open', 'view_more_on', '{view} ▾', 41),
  ('APSL pyramid — the one conference pill', 'conf_pill', 'Conferences: {which} ▾', 42),
  ('APSL pyramid — conference pill, some lit', 'conf_some', '{n} of {total}', 43)
) AS v(label, tier, body, so)
WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = v.tier);
UPDATE message_templates SET body = '▾ Options' WHERE kind = 'apsl_pyramid' AND tier = 'bar_show';
UPDATE message_templates SET body = '▴ Hide options' WHERE kind = 'apsl_pyramid' AND tier = 'bar_hide';
DELETE FROM message_templates WHERE kind = 'apsl_pyramid' AND tier IN ('menu_view', 'menu_conf');
COMMIT;
