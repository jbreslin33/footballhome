-- 480 (2026-09-28) — A viewable-by-anyone page per invoice.
-- Owner: "the email body needs to have link to the invoice not attached.
-- we need to make sure its viewable by all."  Each invoice gets an
-- unguessable slug; https://footballhome.org/invoice.html?k=<slug> shows the
-- sheet (GET /api/invoices/public/<slug>, no sign-in) and is the {link} in
-- the email unless a Drive link was pasted over it.
ALTER TABLE invoices ADD COLUMN IF NOT EXISTS public_slug UUID NOT NULL DEFAULT gen_random_uuid();
CREATE UNIQUE INDEX IF NOT EXISTS invoices_public_slug_idx ON invoices (public_slug);
COMMENT ON COLUMN invoices.public_slug IS 'Key of the public sheet page invoice.html?k=… (mig 480).';
UPDATE message_templates SET body = 'view online' WHERE kind = 'invoices' AND tier = 'email_no_link';
