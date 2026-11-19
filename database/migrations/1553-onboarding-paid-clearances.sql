-- 1553 (2026-11-19) — the club's clearances are the PAID versions (owner 11/19
-- "if she put a price they gotta do that one. we need to make that clear to
-- vols"): the compliance director's instructions list PA criminal $22 and
-- child abuse $13 — the employment rates — so volunteers must NOT pick the
-- free Volunteer option.  Exact screen labels not seen yet, so the words
-- say "the paid one", not a button name.
UPDATE onboarding_steps
   SET cost_usd = 22.00,
       how = 'Tap Apply › and pick the PAID $22 check — NOT the free Volunteer one (the club needs the paid version). Save the certificate as a PDF and upload it here. If it says "Under Review", write down your control number — PATCH will email you in 2–4 weeks; then get your certificate and upload it here.'
 WHERE code = 'pa_criminal';
UPDATE onboarding_steps
   SET cost_usd = 13.00,
       how = 'Tap Apply › and pick the PAID $13 clearance — NOT the free Volunteer one (the club needs the paid version). When your certificate comes, upload it here.'
 WHERE code = 'child_abuse';
