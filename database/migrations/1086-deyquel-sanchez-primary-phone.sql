-- 1086: Deyquel Sanchez (person 22616) — owner 11/5: primary phone for
-- contact is 267-819-4265, primary email deyquelsanchez@gmail.com.
-- Before: the phone was already his only number but not flagged primary;
-- the email was already his only email and primary (no change).
UPDATE person_phones SET is_primary = (regexp_replace(phone_number, '\D', '', 'g') = '12678194265')
 WHERE person_id = 22616;
UPDATE person_emails SET is_primary = (lower(email) = 'deyquelsanchez@gmail.com')
 WHERE person_id = 22616;
