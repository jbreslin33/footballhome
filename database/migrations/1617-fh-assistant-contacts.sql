-- 1617 (2026-11-20) — FH Texter becomes FH Assistant; it also puts every
-- club contact into the owner's Google contacts.
--
-- Owner 11/20: "make fh texter just fh assistant right and expand its
-- domain. and now it just asks fh what it has for it every 6 seconds" +
-- "i just want all contacts. Leads, members etc, opponents, league
-- ofifcalsis, ref assignoers etd, i dont' think we need to group them".
--
-- • phone_contact_sync: which version (fp) of each contact card a paired
--   phone has saved — POST /api/contacts/device/pending hands it only the
--   new or changed ones, /device/ack records them.  Per phone, so a new
--   pairing starts over (the app adopts matching contacts, no duplicates).
-- • The contacts list now carries LA pickup members (most are on no
--   board team) and parents of youth pickup players — label below.
-- • Every "FH Texter" the site shows reads "FH Assistant" (same app, same
--   package — the update installs over it and keeps the pairing).

CREATE TABLE IF NOT EXISTS phone_contact_sync (
    device_id  integer NOT NULL REFERENCES phone_relay_devices(id) ON DELETE CASCADE,
    uid        text    NOT NULL,           -- fh-<kind>-<ref_id>, as in the vCard UID
    fp         text    NOT NULL,           -- fingerprint of the card the phone saved
    synced_at  timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (device_id, uid)
);

INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side)
SELECT 'Contacts', 'Team name shown for an LA pickup member (note on the contact)', 'contacts', 'pickup_label', 'Pickup', 900, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'contacts' AND tier = 'pickup_label');

UPDATE message_templates SET body = replace(body, 'FH Texter', 'FH Assistant')
 WHERE is_active AND body LIKE '%FH Texter%';
UPDATE menu_pages SET label = replace(label, 'FH Texter', 'FH Assistant') WHERE label LIKE '%FH Texter%';
