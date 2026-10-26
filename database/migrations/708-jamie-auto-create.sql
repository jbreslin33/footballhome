-- 708: Jamie (issuer 3) gets auto-drafted sheets like Luke/Anthony.  Mig 569
-- left her off because auto-drafting her usual week would bill unworked
-- Sundays — moot since mig 576 (no usual week; every issuer's hours come
-- from her own events).  Her next board open drafts 2026.21 (10/9–10/22:
-- the 10/18 home game vs Senza Nome, RSVP yes).  #20 stays a gap — the
-- women had no events 9/25–10/8 — and drafts only go forward, never back.
UPDATE invoice_issuers SET auto_create = true, updated_at = now() WHERE id = 3;
