-- 1826 (2026-11-24) — 🔺 #apsl-pyramid is a display, not a work page (owner:
-- "really think we need hamburger" · "its really a view thing and not a
-- work thing" · "we want full screens always so they can see map, pyramid,
-- standings etc" · "hamburger menu should make sense inside of itself …
-- clear and organized").  ONE title line with ☰; the view takes the rest of
-- the window; the drop-down is in sections: View, Conferences, Find a club,
-- Show on screen, This page, What this shows.  Section headings (public);
-- the labels of the Options row tried in mig 1817 and of ▴/▾ (mig 1798)
-- are deleted with those controls.
BEGIN;
INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side, is_public)
SELECT 'APSL pyramid', v.label, 'apsl_pyramid', v.tier, v.body, v.so, true, true
FROM (VALUES
  ('APSL pyramid — ☰ button', 'menu_open', '☰', 44),
  ('APSL pyramid — ☰ section: views', 'menu_view', 'View', 45),
  ('APSL pyramid — ☰ section: conferences', 'menu_conf', 'Conferences', 46),
  ('APSL pyramid — ☰ section: club search', 'menu_club', 'Find a club', 47),
  ('APSL pyramid — ☰ section: page actions', 'menu_page', 'This page', 48),
  ('APSL pyramid — ☰ section: caption + colour key', 'menu_about', 'What this shows', 49),
  ('APSL pyramid — ☰ back to the site (signed in)', 'menu_site', '← Football Home', 50)
) AS v(label, tier, body, so)
WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = v.tier);
DELETE FROM message_templates WHERE kind = 'apsl_pyramid' AND tier IN ('view_more', 'view_more_on', 'conf_pill', 'conf_some', 'bar_hide', 'bar_show');
COMMIT;
