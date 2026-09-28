-- 487 (2026-09-28) — James can sign in to Football Home with his CASA address.
-- Owner: "add my casa email as a user for fh so i can log in as that email in
-- my casa workspace on my debian plasma computer."  Google sign-in maps the
-- Google account's email to a person through person_emails (OAuthController),
-- so a second address on person 1 = the same account, same admin rights, no
-- split identity.  Not primary; the club address stays primary.
INSERT INTO person_emails (person_id, email, email_type_id, is_primary, is_verified, verified_at)
SELECT 1, 'jbreslin@casasoccerleagues.com', 2, false, true, now()
 WHERE NOT EXISTS (SELECT 1 FROM person_emails WHERE LOWER(email) = 'jbreslin@casasoccerleagues.com');
