-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Migration 272: push_subscriptions (Web Push opt-in)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--
-- Browser Push API subscriptions, one row per (person, browser install).
-- A person can have several — phone + laptop, or a re-subscribe after
-- clearing site data creates a new endpoint rather than reusing the old
-- one. endpoint is globally unique per browser install (assigned by the
-- push service — FCM for Chrome/Android, Apple's web push service for
-- Safari/iOS, Mozilla's for Firefox), so it's the natural upsert key.
--
-- p256dh_key / auth_key are the subscriber's ECDH public key and auth
-- secret from PushSubscription.toJSON().keys — required by
-- WebPushService to encrypt each payload per RFC 8291. Neither is
-- secret to us (they're sent over HTTPS at subscribe time same as any
-- other request body) but they're useless without also holding our
-- VAPID private key, so no extra encryption at rest here.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BEGIN;

CREATE TABLE IF NOT EXISTS push_subscriptions (
    id           BIGSERIAL PRIMARY KEY,
    person_id    INTEGER NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    endpoint     TEXT NOT NULL,
    p256dh_key   TEXT NOT NULL,
    auth_key     TEXT NOT NULL,
    user_agent   TEXT,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    last_used_at TIMESTAMPTZ,
    CONSTRAINT uq_push_subscriptions_endpoint UNIQUE (endpoint)
);

CREATE INDEX IF NOT EXISTS idx_push_subscriptions_person
    ON push_subscriptions (person_id);

COMMENT ON TABLE push_subscriptions IS
    'Web Push (RFC 8291) subscriptions. One row per browser install that opted in; pruned by WebPushService when a push service reports the endpoint gone (404/410).';

COMMIT;
