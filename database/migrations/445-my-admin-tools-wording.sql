-- 445 (2026-09-25) — owner: "admin toggle better so that by default it
-- treats my page like regular players".  The toggle now covers every
-- admin extra on #my (bulk text/email, the Attendance & invites door,
-- the dues-ineligible heading); say so.
UPDATE message_templates SET body = 'Admin tools on — text & email everyone, attendance door, dues flags', updated_at = now()
 WHERE kind = 'my_admin_tools' AND tier = 'on';
UPDATE message_templates SET body = 'Admin tools off — this page looks like a player''s', updated_at = now()
 WHERE kind = 'my_admin_tools' AND tier = 'off';
