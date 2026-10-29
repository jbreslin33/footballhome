-- 866 (2026-10-29) — #apsl-pyramid map: pick a club, its data in a HUD.
--
-- Owner 2026-10-29: "we need to be able to select a club on the map! … and
-- it should show data in hud on that club … on the map we need to be able
-- to select too. it allows select in the table".
--
-- On the map a club's NAME is now a target (only a dot within 16px was),
-- and so is a team in the conference overlay's tables (the overlay kept its
-- clicks from the page).  The picked club's dots and names turn yellow, and
-- its card (mig 856) is a collapsible HUD on the left — under the
-- Conference HUD, over the map key — instead of a panel covering both.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'APSL pyramid', l, 'apsl_pyramid', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('hud_club', 'APSL pyramid — HUD title: picked club', 'Club', 183)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = v.t);

UPDATE message_templates
   SET body = 'Tap a conference to fly there and see its pyramid · tap a club (dot or name) for its card'
 WHERE kind = 'apsl_pyramid' AND tier = 'map_hint'
   AND body = 'Tap a conference to fly there and see its pyramid · tap a dot for the club';
