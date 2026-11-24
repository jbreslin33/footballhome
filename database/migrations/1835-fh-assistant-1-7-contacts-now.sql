-- 1835 (2026-11-24) — FH Assistant 1.7 (versionCode 8): contacts on request.
-- When /api/phone-relay/device/next answers contacts_now (a new lead's card is waiting,
-- mig 1834), the app syncs contacts at once instead of at its next 15 minutes, so the
-- lead is in the owner's contacts before his first text goes.  Phones on 1.5+ are offered
-- the update with one tap.
INSERT INTO phone_app_releases (version_code, version_name, apk_url, notes)
VALUES (8, '1.7', 'https://footballhome.org/app/fh-texter.apk', 'FH Assistant: a new lead goes into contacts right away, then gets the first text')
ON CONFLICT DO NOTHING;
