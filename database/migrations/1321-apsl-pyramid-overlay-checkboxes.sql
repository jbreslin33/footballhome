-- 1321 (2026-11-13) — #apsl-pyramid map ☰: "Also show" checkboxes.  The
-- radio buttons (Measured from / Measure by) pick the coloured map; each
-- ticked centre adds its border on top as a thin white line in its own
-- dash, same measure.  Replaces the one all-or-nothing "Other models'
-- borders (faint)" switch (mig 1298).  Owner 11/13: "i wanted a radio
-- buttons to do diff models" / "showing all at same time would be a mess" /
-- "it could be check boxes and we could show them on top of each other" →
-- "yes build it".  Ticks live in the browser (localStorage), none by default.

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'APSL pyramid', v.label, 'apsl_pyramid', v.t, NULL, v.body, v.s, true, true, true
  FROM (VALUES
    ('overlay_heading', 'APSL pyramid — menu: centres drawn on top heading', 'Also show (thin lines on top)', 209)
  ) AS v(t, label, body, s)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl_pyramid' AND m.tier = v.t);

UPDATE message_templates SET is_active = false WHERE kind = 'apsl_pyramid' AND tier = 'feature_ghosts';

UPDATE message_templates
   SET body = 'The coloured border is the map picked above — how it is measured (Measure by) and from where (Measured from). Thin white lines: the centres ticked under Also show, measured the same way. Shaded: counties this measure gives a different conference than Drive time does (on Drive time: than drive without traffic).'
 WHERE kind = 'apsl_pyramid' AND tier = 'proposal_lines';
