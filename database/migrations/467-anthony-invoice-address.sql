-- 467 (2026-09-27) — Anthony Acevedo's From block on the invoice sheet.
-- Owner: "anthony address is 3129 Arbor street philadlephia".  Zip 19134
-- (Arbor St at Allegheny, Kensington) filled in by Claude; fix on the
-- page's Details button if it is wrong.
UPDATE invoice_issuers
   SET address = '3129 Arbor Street', city_state_zip = 'Philadelphia, PA 19134', updated_at = now()
 WHERE person_id = 22397 AND address IS NULL;
