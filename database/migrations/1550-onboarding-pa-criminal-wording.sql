-- 1550 (2026-11-19) — step 1 (PA Criminal History) in plain, confirmed words
-- (owner 11/19 "i am focused on step 1 for them" → "yes put the safe
-- wording in").  From the State Police's pa.gov pages: volunteer checks are
-- free (2 is the employment/individual check); "No Record" comes back
-- instantly ~85% of the time and is printed by the applicant; otherwise
-- "Under Review" 2–4 weeks, PATCH emails when the status changes, the
-- control number + request date + name find it on the status page.  Exact
-- PATCH screens not seen yet — replace with button-by-button steps once the
-- owner runs a test check.
UPDATE onboarding_steps
   SET cost_usd = 0,
       how = 'Tap Apply ›, choose Volunteer, and fill in your details. Save the certificate as a PDF and upload it here. If it says "Under Review", write down your control number — PATCH will email you in 2–4 weeks; then get your certificate and upload it here. (Volunteers are free; 2 only if it''s for a paid job.)'
 WHERE code = 'pa_criminal';
