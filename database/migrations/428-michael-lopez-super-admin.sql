-- 428 — Michael Lopez: super admin, signs in as michael.lopez@lighthouse1893.org.
--
-- 2026-09-25: Michael (person 22439, user 64) was added 7/8 at the "club"
-- level under rov.lead@lighthouse1893.org.  James asked that he hold the
-- same rights as James (admin_levels 'super': every club gate plus the
-- Super Admin context in the admin picker).  His Google login is
-- michael.lopez@lighthouse1893.org, which was not on his record — a Google
-- sign-in with it would have minted a brand-new orphan person, so it goes
-- on person 22439 as the primary address.  rov.lead@ stays on the record.

-- 1. Login email → person 22439 (primary, verified, work).
INSERT INTO person_emails (person_id, email, email_type_id, is_primary, is_verified, verified_at)
SELECT 22439, 'michael.lopez@lighthouse1893.org',
       (SELECT id FROM email_types WHERE name = 'work'), true, true, NOW()
 WHERE NOT EXISTS (SELECT 1 FROM person_emails
                    WHERE lower(email) = 'michael.lopez@lighthouse1893.org');
UPDATE person_emails
   SET is_primary = (lower(email) = 'michael.lopez@lighthouse1893.org')
 WHERE person_id = 22439;

-- 2. Admin level club → super on his existing admins row (user 64).
UPDATE admins
   SET admin_level_id = (SELECT id FROM admin_levels WHERE name = 'super'),
       notes = 'Super admin - Michael Lopez (same rights as James). Club admin 2026-07-08, super 2026-09-25.'
 WHERE user_id = (SELECT id FROM users WHERE person_id = 22439);

-- Sanity: exactly one admins row for him, and it is super.
DO $$
BEGIN
  IF (SELECT count(*) FROM admins a JOIN users u ON u.id = a.user_id
       JOIN admin_levels al ON al.id = a.admin_level_id
      WHERE u.person_id = 22439 AND al.name = 'super') <> 1 THEN
    RAISE EXCEPTION 'migration 428: Michael Lopez is not a single super admin';
  END IF;
END $$;
