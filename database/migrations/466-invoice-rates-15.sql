-- 466 (2026-09-27) — Coaches invoice at $15/h.
-- Owner: "each make 15 an hour" (Luke Breslin, Jamie Arevalo, Anthony
-- Acevedo).  Luke's last PDF (2026.18) was at $11.50; Jamie already $15;
-- Anthony had no rate.  James stays at $20 (Manager of Soccer duties).
UPDATE invoice_issuers SET hourly_rate = 15.00, updated_at = now()
 WHERE person_id IN (3463, 22193, 22397);
