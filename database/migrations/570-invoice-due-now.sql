-- 570 (2026-10-12) — #invoices leads with the invoice due the Friday that
-- passed.  Owner: "your showing the wrong invoice. it needs to be the ones
-- due the friday that passed."
--
-- Code side (same commit): ensureAutoDrafts only drafts the most recent
-- FINISHED period — the running one appears on its due Friday, when it
-- becomes the one to send.  Landing on the page (or tapping a pill) opens
-- the issuer's due sheet by itself, and any unsent invoice whose due date
-- has arrived wears this tag on its row.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Invoices', 'Invoices — row tag when the due date has passed unsent', 'invoices', 'due_badge', NULL,
       'due {date} — send', 769, true, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'invoices' AND tier = 'due_badge');
