-- 401 — Monthly dues rate and the pause threshold move into the DB.
--
-- Owner 2026-09-22: "move the $35 monthly rate into the db too".  Until
-- now $35 was a C++ constant (PersonPayments::kMonthlyDuesUsd), a literal
-- in two SQL queries, PersonBilling's default, and a frontend constant in
-- billing-badge.js.  Same shape as schedule_release_policies: one row per
-- (club, section, effective date), history kept, latest effective row
-- that is not in the future wins, section beats club-wide.
--
--   dues_policies.monthly_dues_usd     $35.00 today
--   dues_policies.pause_after_months   3 — "$105 due we basically are
--                                      cutting them" (2026-09-22)
--   fh_monthly_dues_usd(club)          } read by the backend (DuesPolicy
--   fh_dues_pause_after_months(club)   } model), its SQL, and the copy
--                                        endpoint for the browser.
--
-- To change the price: INSERT a new row with a later effective_from.
-- Never UPDATE the old one — the history is the audit trail.

CREATE TABLE IF NOT EXISTS dues_policies (
  id                 serial PRIMARY KEY,
  club_id            int NOT NULL REFERENCES clubs(id),
  club_section_id    int REFERENCES club_sections(id),          -- NULL = whole club
  monthly_dues_usd   numeric(8,2) NOT NULL CHECK (monthly_dues_usd > 0),
  pause_after_months smallint NOT NULL DEFAULT 3 CHECK (pause_after_months >= 1),
  effective_from     date NOT NULL DEFAULT CURRENT_DATE,
  created_by_user_id int REFERENCES users(id),
  created_at         timestamptz NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX IF NOT EXISTS dues_policies_scope_idx
  ON dues_policies (club_id, COALESCE(club_section_id, 0), effective_from);
COMMENT ON TABLE dues_policies IS
  'Monthly dues rate and months-behind pause threshold. Section-scoped row beats club-wide; latest effective_from <= today wins. Insert a new row to change the price; never update history.';

INSERT INTO dues_policies (club_id, club_section_id, monthly_dues_usd, pause_after_months, effective_from)
SELECT 134, NULL, 35.00, 3, DATE '2026-01-01'
 WHERE NOT EXISTS (SELECT 1 FROM dues_policies WHERE club_id = 134 AND club_section_id IS NULL);

-- Club-wide rate in force today.  NULL when the club has no policy — the
-- callers fail loudly on NULL rather than inventing a number.
CREATE OR REPLACE FUNCTION fh_monthly_dues_usd(p_club_id int, p_club_section_id int DEFAULT NULL)
RETURNS numeric LANGUAGE sql STABLE AS $$
  SELECT monthly_dues_usd
    FROM dues_policies
   WHERE club_id = p_club_id
     AND (club_section_id IS NULL OR club_section_id = p_club_section_id)
     AND effective_from <= CURRENT_DATE
   ORDER BY (club_section_id IS NOT NULL) DESC, effective_from DESC
   LIMIT 1
$$;

CREATE OR REPLACE FUNCTION fh_dues_pause_after_months(p_club_id int, p_club_section_id int DEFAULT NULL)
RETURNS int LANGUAGE sql STABLE AS $$
  SELECT pause_after_months::int
    FROM dues_policies
   WHERE club_id = p_club_id
     AND (club_section_id IS NULL OR club_section_id = p_club_section_id)
     AND effective_from <= CURRENT_DATE
   ORDER BY (club_section_id IS NOT NULL) DESC, effective_from DESC
   LIMIT 1
$$;

-- person_billing carried its own 35.00 default (migration 053); the
-- backend always supplies the amount now, so the default goes.
ALTER TABLE person_billing ALTER COLUMN next_bill_amount DROP DEFAULT;

-- The notices said "3 months" as text; it is now the {pause_months} token.
UPDATE message_templates
   SET body = replace(body, '3 months', '{pause_months} months'), updated_at = now()
 WHERE kind IN ('payment_notice_email', 'payment_notice_sms') AND is_active AND body LIKE '%3 months%';
