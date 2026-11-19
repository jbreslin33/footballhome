-- 1547 (2026-11-19) — Yineska is the compliance director (owner 11/19
-- "yineska compliance.director@lighthouse1893.org"): both onboarding email
-- stages go to her — clearances first, finance after — and open "Hi Yineska,".
UPDATE onboarding_stages SET email_to = 'compliance.director@lighthouse1893.org', email_to_name = 'Yineska'
 WHERE stage IN ('volunteer', 'paid');
UPDATE onboarding_policy SET compliance_name = 'Yineska' WHERE id = 1;
UPDATE message_templates SET body = replace(body, 'Hi,' || chr(10), 'Hi {to_name},' || chr(10)), updated_at = now()
 WHERE kind = 'onboarding' AND tier = 'email_compliance' AND body LIKE 'Hi,%';
UPDATE message_templates SET body = 'Email {n} file(s) for {name} to {to}, cc {name} and you?', updated_at = now()
 WHERE kind = 'onboarding' AND tier = 'send_confirm';
UPDATE message_templates SET body = '✉️ Send finance to Yineska', updated_at = now()
 WHERE kind = 'onboarding' AND tier = 'act_send_paid';
UPDATE message_templates SET body = '✉️ Send clearances to Yineska', updated_at = now()
 WHERE kind = 'onboarding' AND tier = 'act_send_volunteer';
