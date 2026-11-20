-- 1633 (2026-11-20) — FH Assistant 1.6: the main number / email becomes the
-- phone contact's default.  Owner: "change asif contact to his main via fh
-- assistant on my phone".
--
-- The contacts list now orders each person's phones / emails main
-- (is_primary) first; 1.6 asks for {mains: true} and marks the first one
-- IS_PRIMARY + IS_SUPER_PRIMARY on contacts it owns.  Only cards with more
-- than one number or email carry the flag, so the upgrade rewrites just
-- those.  Phones on ≥1.5 get the one-tap update from this row.

INSERT INTO phone_app_releases (version_code, version_name, apk_url, notes)
SELECT 7, '1.6', 'https://footballhome.org/app/fh-texter.apk',
       'FH Assistant: main number and email set as each contact''s default'
 WHERE NOT EXISTS (SELECT 1 FROM phone_app_releases WHERE version_code = 7);
