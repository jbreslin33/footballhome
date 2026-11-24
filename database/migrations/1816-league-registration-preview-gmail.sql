-- 1816 (2026-11-24) — 📝 League Registration: 👁 Preview each filled form on
-- the page, and ✉️ Open Gmail to the league.  Owner: "i need to be able to
-- preview on site the club commitment form and team commitment form. then 1
-- button to open gmail and email to jen cole".
--
-- The Gmail button composes with the same words the server send uses, so the
-- 'email' row becomes client_side (the page reads it).  A Gmail compose link
-- cannot carry a file: the filled forms are saved to Downloads in the same
-- click, and the note says so.  The server send stays as the second button.

UPDATE message_templates SET client_side = true
 WHERE kind = 'league_entry' AND tier = 'email';

UPDATE message_templates SET body = '📨 Or send them from Football Home to {name}'
 WHERE kind = 'league_entry' AND tier = 'btn_send' AND body = '✉️ Email the filled forms to {name}';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'League Registration', v.label, 'league_entry', v.tier, NULL, v.body, v.ord, true, true, false
  FROM (VALUES
    ('Page — preview a form', 'btn_preview', '👁 Preview', 21),
    ('Page — Gmail button ({name})', 'btn_gmail', '✉️ Open Gmail to {name}', 22),
    ('Page — Gmail note', 'gmail_note', 'Open Gmail starts the email to the league and saves the filled forms to your Downloads — drag them into the email (a Gmail link cannot attach a file). The second button sends them from Football Home with the forms attached and a copy to you.', 23)
  ) AS v(label, tier, body, ord)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'league_entry' AND m.tier = v.tier);
