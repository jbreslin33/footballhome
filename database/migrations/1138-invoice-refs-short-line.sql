-- Owner 2026-11-06: "text for ref desc is too small. can just say refs.
-- (Men,Women,Boys,Girls)" … "xofx".  The printed sheet folds referees lines
-- that are the same payment of their plans into one row:
--   Refs (Men, Women, Boys) 1 of 2 · $1,079.42 total
-- Sections come from the games' ref policies; a hand-added referees line
-- (no games) names its section on the line or its plan.
BEGIN;

ALTER TABLE club_sections ADD COLUMN IF NOT EXISTS invoice_label text;
UPDATE club_sections SET invoice_label = v.l
  FROM (VALUES ('M', 'Men'), ('W', 'Women'), ('B', 'Boys'), ('G', 'Girls')) AS v(c, l)
 WHERE club_sections.code = v.c;

ALTER TABLE invoice_installment_plans ADD COLUMN IF NOT EXISTS club_section_id int REFERENCES club_sections(id);
ALTER TABLE invoice_lines             ADD COLUMN IF NOT EXISTS club_section_id int REFERENCES club_sections(id);

-- James's Women's ref fee (plan 19, both payments): Women.
UPDATE invoice_installment_plans SET club_section_id = (SELECT id FROM club_sections WHERE code = 'W')
 WHERE id = 19 AND issuer_id = 1 AND description = 'Women''s ref fee';

INSERT INTO message_templates (category, label, kind, tier, body)
SELECT 'Finances', 'Invoices — referees row on the sheet ({sections} = Men, Women, Boys, Girls)', 'invoices', 'refs_line', 'Refs ({sections})'
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'invoices' AND tier = 'refs_line');

COMMIT;
