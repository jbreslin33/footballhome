-- 670: 📲 Installs section on the role picker (owner 2026-10-23: "link to
-- click for admin me only … make a section for app installs … or installs
-- in general?").  One home for anything you install; FH Texter (mig 667)
-- is the first tile — before this its APK link only showed as text inside
-- the desktop text panel's setup steps.  Admin-only, like the tools.

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Installs', l, 'installs', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('section',         'Installs — picker section heading',        'Installs', 10),
    ('fh_texter_title', 'Installs — FH Texter tile title',          'FH Texter (Android)', 20),
    ('fh_texter_sub',   'Installs — FH Texter tile subtitle',       'Open on your Android to install — your phone then sends the texts you click on the desktop. Pair it from any text button.', 21)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'installs' AND m.tier = v.t);
