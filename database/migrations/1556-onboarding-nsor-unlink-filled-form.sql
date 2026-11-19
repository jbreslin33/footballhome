-- 1556 (2026-11-19) — the NSOR step's "Get the form ›" (mig 1536) pointed at
-- the club Drive copy, which turned out to be a FILLED-IN application (a real
-- applicant's name, SSN, date of birth, phone, address) shared with anyone
-- holding the link.  Link removed; the owner is told to unshare / replace it
-- with a blank.  The step says the club sends the form until a blank exists.
UPDATE onboarding_steps
   SET link_url = NULL, link_label = NULL,
       how = 'No link yet — the club sends you this form. Fill it in (tick "Volunteer"), then email a scan to RA-PWNSOR@pa.gov with the subject "NSOR Verification" and your last name. Upload your copy here now, and the letter when it comes (about 14 days).'
 WHERE code = 'nsor';
