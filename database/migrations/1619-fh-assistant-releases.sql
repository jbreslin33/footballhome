-- 1619 (2026-11-20) — FH Assistant updates itself with one tap (v1.5).
-- Owner 11/20: "can't we just have fh assistant in fuutre just do updates
-- to itself or just click update lol" → "yes do 1.5 first".
--
-- The latest row is the version the app should run.  /device/next answers
-- {update: {version_code, version_name, url}} to a phone that reports an
-- older app_version_code; the app shows "Update available", downloads the
-- APK and opens Android's installer (Install = the one tap).
-- Releasing a new build: copy the APK to frontend/app/fh-texter.apk, then
-- INSERT a row here (by migration) with its versionCode.
CREATE TABLE IF NOT EXISTS phone_app_releases (
    version_code  integer PRIMARY KEY,
    version_name  text NOT NULL,
    apk_url       text NOT NULL,
    notes         text,
    released_at   timestamptz NOT NULL DEFAULT now()
);

INSERT INTO phone_app_releases (version_code, version_name, apk_url, notes)
VALUES (6, '1.5', 'https://footballhome.org/app/fh-texter.apk',
        'FH Assistant: contacts into Google + one-tap updates')
ON CONFLICT (version_code) DO NOTHING;
