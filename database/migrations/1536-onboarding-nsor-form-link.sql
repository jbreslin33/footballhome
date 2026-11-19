-- 1536 (2026-11-19) — 🎓 the NSOR step gets the club's form (owner 11/19 "this
-- is form for nsor", the club Drive copy — PA DHS "APPLICATION: National Sex
-- Offender Registry Verification", unlisted = anyone with the link).  The
-- form goes to the state, not the club: email the scan to RA-PWNSOR@pa.gov
-- (subject "NSOR Verification <last name>"), or mail / drop it at ChildLine;
-- free; ~14 days; keep a copy as proof.  It asks for the SSN, so it never
-- comes to the club — only the copy / letter does.
UPDATE onboarding_steps
   SET link_url = 'https://drive.google.com/file/d/1aW1ZE2YeHMcHNKsOPhtlO4oI_iHlBfk5/view?usp=share_link',
       link_label = 'Get the form ›',
       how = 'Fill in the form (tick "Volunteer"), then email a scan to RA-PWNSOR@pa.gov with the subject "NSOR Verification" and your last name. Keep a copy. Send the club your copy now, and the letter when it comes (about 14 days).'
 WHERE code = 'nsor';
