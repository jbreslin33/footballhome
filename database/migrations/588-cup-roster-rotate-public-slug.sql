-- 588 (2026-10-14) — rotate the USASA Amateur Cup sheet's public link.
-- The old /cup-roster?k=... link was shared when the Player Pool sheet was
-- believed to be the real USASA submission; the real one is the bulk-upload
-- .xls (mig 587).  Owner: "delete the old one. so that they don't get
-- confused. make new link ... make other dead link."  New slug = new link,
-- the old link 404s; the sheet itself stays as a template.

UPDATE cup_rosters
   SET public_slug = gen_random_uuid()
 WHERE id = 2;
