-- 465 (2026-09-27) — Invoices to The Lighthouse, Inc.
--
-- Owner: "i need to make it easier to make invoices for lighthouse … a top
-- level section … on a specific invoice sheet … for myself, luke breslin,
-- jamie Arevelo and Anthony Acevedo … the others will only have hours".
--
-- Until now each biweekly invoice was a hand-filled PDF of Lighthouse's
-- InvoiceTemplate (Address / City / Phone, BILL TO The Lighthouse, Inc.,
-- INVOICE# / DATE, DESCRIPTION · HOURS/UNITS · RATE · AMOUNT, TOTAL,
-- "Make all checks payable to", "Thank you for your business!").  James's
-- carries expenses paid up front and billed back in instalments ("Veo
-- Subscription 15 of 16 $862.92"), which had to be carried forward and
-- renumbered by hand every period — the error-prone part.
--
-- Model:
--   invoice_bill_to             the one payer (The Lighthouse, Inc.)
--   invoice_issuers             who invoices: a persons row + the sheet's
--                               From block, payable-to line, duty and rate
--   invoice_line_categories     the margin labels on James's sheet
--                               (Equipment:, Uniforms:, League Dues:, …)
--   invoice_installment_plans   an expense split over N invoices; each new
--                               invoice picks up the next "k of N" line
--   invoices / invoice_lines    the sheets themselves; total = SUM(amount)
--
-- INVOICE# is the pay-period number within the year, shared by everyone
-- (James 19 and Luke 18 were both period 18/19 of 2026); the PDF is
-- named Invoice<slug>-<year>.<number>.pdf.  Served by /api/invoices
-- (backend/src/models/Invoice.cpp, controllers/InvoiceController.cpp)
-- behind #invoices (frontend/js/screens/invoices.js), club/super admins.
--
-- History seeded below so the instalment counters continue correctly:
-- James 2026.17–19, Luke 2026.18, Jamie 2026.10–11 (from the PDFs in the
-- shared Drive "invoices" folder).  Anthony has no invoice yet; his
-- address and rate are blank until set on the page.

CREATE TABLE IF NOT EXISTS invoice_bill_to (
  id             SERIAL PRIMARY KEY,
  organization   TEXT NOT NULL,
  contact_name   TEXT,
  address        TEXT NOT NULL,
  city_state_zip TEXT NOT NULL,
  is_default     BOOLEAN NOT NULL DEFAULT true
);
COMMENT ON TABLE invoice_bill_to IS 'The BILL TO block of the Lighthouse invoice sheet (mig 465).';
INSERT INTO invoice_bill_to (organization, contact_name, address, city_state_zip)
SELECT 'The Lighthouse, Inc.', NULL, '152 W. Lehigh Ave.', 'Philadelphia, PA 19133'
 WHERE NOT EXISTS (SELECT 1 FROM invoice_bill_to);

CREATE TABLE IF NOT EXISTS invoice_issuers (
  id               SERIAL PRIMARY KEY,
  person_id        INT NOT NULL UNIQUE REFERENCES persons(id) ON DELETE CASCADE,
  file_slug        TEXT NOT NULL,            -- Invoice<slug>-2026.19.pdf
  address          TEXT,
  city_state_zip   TEXT,
  phone            TEXT,
  payable_to       TEXT,
  duty_description TEXT,                     -- the hours line, e.g. "Coaching Duties"
  hourly_rate      NUMERIC(8,2),
  bills_expenses   BOOLEAN NOT NULL DEFAULT false,  -- James: instalments + one-off expenses
  sort_order       INT NOT NULL DEFAULT 0,
  is_active        BOOLEAN NOT NULL DEFAULT true,
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE invoice_issuers IS 'People who invoice The Lighthouse, Inc. through #invoices, with their From block, payable-to line, duty and hourly rate (mig 465).';

INSERT INTO invoice_issuers (person_id, file_slug, address, city_state_zip, phone, payable_to, duty_description, hourly_rate, bills_expenses, sort_order)
SELECT v.* FROM (VALUES
  (1,     'JBreslin', '804 East Girard Avenue', 'Philadelphia, PA 19125', '215-828-4924', 'James Breslin', 'Manager of Soccer duties', 20.00::numeric, true,  1),
  (3463,  'LBreslin', '804 East Girard Avenue', 'Philadelphia, PA 19125', '215-839-2598', 'Luke Breslin',  'Coaching Duties',          11.50::numeric, false, 2),
  (22193, 'JArevalo', '525 East Elm Avenue',    'Lindenwold, NJ 08021',   '856-745-7905', 'Jamie Arevalo', 'Women''s Coach Duties',    15.00::numeric, false, 3),
  (22397, 'AAcevedo', NULL,                     NULL,                     '215-618-5562', 'Anthony Acevedo', 'Coaching Duties',        NULL,           false, 4)
) AS v(person_id, file_slug, address, city_state_zip, phone, payable_to, duty_description, hourly_rate, bills_expenses, sort_order)
WHERE NOT EXISTS (SELECT 1 FROM invoice_issuers i WHERE i.person_id = v.person_id);

CREATE TABLE IF NOT EXISTS invoice_line_categories (
  code       TEXT PRIMARY KEY,
  label      TEXT NOT NULL,     -- printed in the sheet's left margin; '' for the hours line
  sort_order INT NOT NULL DEFAULT 0
);
COMMENT ON TABLE invoice_line_categories IS 'Margin labels grouping lines on the invoice sheet (mig 465). Add by migration only.';
INSERT INTO invoice_line_categories (code, label, sort_order) VALUES
  ('labor',         '',               1),
  ('equipment',     'Equipment:',     2),
  ('facilities',    'Facilities:',    3),
  ('uniforms',      'Uniforms:',      4),
  ('registrations', 'Registrations:', 5),
  ('league_dues',   'League Dues:',   6),
  ('field_rentals', 'Field Rentals:', 7),
  ('referees',      'Referees:',      8),
  ('other',         'Other:',         9)
ON CONFLICT (code) DO NOTHING;

CREATE TABLE IF NOT EXISTS invoice_installment_plans (
  id                SERIAL PRIMARY KEY,
  issuer_id         INT NOT NULL REFERENCES invoice_issuers(id) ON DELETE CASCADE,
  category          TEXT NOT NULL REFERENCES invoice_line_categories(code),
  description       TEXT NOT NULL,
  total_amount      NUMERIC(10,2) NOT NULL CHECK (total_amount > 0),
  installment_count INT NOT NULL CHECK (installment_count > 0),
  show_total        BOOLEAN NOT NULL DEFAULT false,   -- print "… 15 of 16 $862.92"
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE invoice_installment_plans IS 'An expense billed back over N invoices; every new invoice takes the next "k of N" line until the plan is done (mig 465).';

CREATE TABLE IF NOT EXISTS invoices (
  id             SERIAL PRIMARY KEY,
  issuer_id      INT NOT NULL REFERENCES invoice_issuers(id) ON DELETE CASCADE,
  invoice_year   INT NOT NULL,
  invoice_number INT NOT NULL,      -- pay period of the year, shared by every issuer
  invoice_date   DATE NOT NULL,
  is_final       BOOLEAN NOT NULL DEFAULT false,
  note           TEXT,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (issuer_id, invoice_year, invoice_number)
);
COMMENT ON TABLE invoices IS 'One Lighthouse invoice sheet per row; total is SUM(invoice_lines.amount) (mig 465).';

CREATE TABLE IF NOT EXISTS invoice_lines (
  id             SERIAL PRIMARY KEY,
  invoice_id     INT NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
  category       TEXT NOT NULL DEFAULT 'other' REFERENCES invoice_line_categories(code),
  description    TEXT NOT NULL,
  quantity       NUMERIC(10,2) NOT NULL DEFAULT 1,   -- hours for the labor line, units otherwise
  rate           NUMERIC(10,2),
  amount         NUMERIC(10,2) NOT NULL DEFAULT 0,
  plan_id        INT REFERENCES invoice_installment_plans(id) ON DELETE SET NULL,
  installment_no INT,
  sort_order     INT NOT NULL DEFAULT 0
);
CREATE INDEX IF NOT EXISTS invoice_lines_invoice_idx ON invoice_lines (invoice_id, sort_order, id);
CREATE INDEX IF NOT EXISTS invoice_lines_plan_idx ON invoice_lines (plan_id) WHERE plan_id IS NOT NULL;
COMMENT ON COLUMN invoice_lines.installment_no IS 'k of the plan''s "k of N"; the next invoice takes MAX(installment_no)+1 (mig 465).';

-- ── Seed: James's open instalment plans (state as of invoice 2026.19) ─────
CREATE OR REPLACE FUNCTION pg_temp.plan(p_person int, p_cat text, p_desc text, p_total numeric, p_count int, p_show bool)
RETURNS int LANGUAGE plpgsql AS $$
DECLARE v_id int;
BEGIN
  SELECT p.id INTO v_id FROM invoice_installment_plans p JOIN invoice_issuers i ON i.id = p.issuer_id
   WHERE i.person_id = p_person AND p.description = p_desc;
  IF v_id IS NULL THEN
    INSERT INTO invoice_installment_plans (issuer_id, category, description, total_amount, installment_count, show_total)
    SELECT id, p_cat, p_desc, p_total, p_count, p_show FROM invoice_issuers WHERE person_id = p_person
    RETURNING id INTO v_id;
  END IF;
  RETURN v_id;
END $$;

CREATE OR REPLACE FUNCTION pg_temp.inv(p_person int, p_year int, p_num int, p_date date)
RETURNS int LANGUAGE plpgsql AS $$
DECLARE v_id int;
BEGIN
  SELECT v.id INTO v_id FROM invoices v JOIN invoice_issuers i ON i.id = v.issuer_id
   WHERE i.person_id = p_person AND v.invoice_year = p_year AND v.invoice_number = p_num;
  IF v_id IS NULL THEN
    INSERT INTO invoices (issuer_id, invoice_year, invoice_number, invoice_date, is_final)
    SELECT id, p_year, p_num, p_date, true FROM invoice_issuers WHERE person_id = p_person
    RETURNING id INTO v_id;
  END IF;
  RETURN v_id;
END $$;

-- line(invoice, sort, category, description, qty, rate, amount, plan, k)
CREATE OR REPLACE FUNCTION pg_temp.line(p_inv int, p_sort int, p_cat text, p_desc text, p_qty numeric, p_rate numeric, p_amt numeric, p_plan int, p_k int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO invoice_lines (invoice_id, category, description, quantity, rate, amount, plan_id, installment_no, sort_order)
  SELECT p_inv, p_cat, p_desc, p_qty, p_rate, p_amt, p_plan, p_k, p_sort
   WHERE NOT EXISTS (SELECT 1 FROM invoice_lines l WHERE l.invoice_id = p_inv AND l.sort_order = p_sort);
$$;

DO $$
DECLARE
  veo int; carts int; stands int; leds int; nums int; jerseys int; itc int; youth int; soil int; liga int; turf int;
  i17 int; i18 int; i19 int; l18 int; j10 int; j11 int;
BEGIN
  veo     := pg_temp.plan(1, 'equipment',     'Veo Subscription',                       862.92, 16, true);
  carts   := pg_temp.plan(1, 'equipment',     'Gorrila Carts #2,#3,#4',                 413.36,  4, false);
  stands  := pg_temp.plan(1, 'equipment',     'Light Stands & Water Bags',              559.23,  3, false);
  leds    := pg_temp.plan(1, 'equipment',     '2 1000W LED Lights',                     318.00,  3, false);
  nums    := pg_temp.plan(1, 'uniforms',      'Numbers for jerseys',                    219.80,  2, false);
  jerseys := pg_temp.plan(1, 'uniforms',      'Jerseys, Pinnies',                       415.10,  2, false);
  itc     := pg_temp.plan(1, 'league_dues',   'Itc Clearences for youth players',       574.98,  6, false);
  youth   := pg_temp.plan(1, 'league_dues',   'Youth u8,u10, u12',                     1200.00,  6, false);
  soil    := pg_temp.plan(1, 'facilities',    'Top Soil',                              1588.00,  4, false);
  liga    := pg_temp.plan(1, 'league_dues',   'Liga 1 payment plan Aug 29',             250.20,  2, false);
  turf    := pg_temp.plan(1, 'field_rentals', 'Liga 1 game moved to turf due to rodeo', 209.00,  2, false);

  -- James 2026.17 (08/27/2026) — total $2,076.75
  i17 := pg_temp.inv(1, 2026, 17, DATE '2026-08-27');
  PERFORM pg_temp.line(i17, 1,  'labor',         'Manager of Soccer duties', 51.5, 20.00, 1030.00, NULL, NULL);
  PERFORM pg_temp.line(i17, 2,  'equipment',     'Veo Subscription',          1, 53.93,  53.93, veo, 13);
  PERFORM pg_temp.line(i17, 3,  'facilities',    'Gorrila Carts #2,#3,#4',    1, 103.34, 103.34, carts, 1);
  PERFORM pg_temp.line(i17, 4,  'facilities',    'Light Stands & Water Bags', 1, 186.41, 186.41, stands, 1);
  PERFORM pg_temp.line(i17, 5,  'uniforms',      'Uniform baskets',           1, 71.49,  71.49, NULL, NULL);
  PERFORM pg_temp.line(i17, 6,  'uniforms',      'Manu and LH logos, Camp 6 of 6 Adjusted', 1, 106.15, 106.15, NULL, NULL);
  PERFORM pg_temp.line(i17, 7,  'registrations', 'Itc Clearences for youth players', 1, 95.83, 95.83, itc, 1);
  PERFORM pg_temp.line(i17, 8,  'league_dues',   'Youth u8,u10, u12',         1, 200.00, 200.00, youth, 1);
  PERFORM pg_temp.line(i17, 9,  'league_dues',   'Liga 1 payment plan Aug 29', 1, 125.10, 125.10, liga, 1);
  PERFORM pg_temp.line(i17, 10, 'field_rentals', 'Liga 1 game moved to turf due to rodeo', 1, 104.50, 104.50, turf, 1);

  -- James 2026.18 (09/11/2026) — total $2,977.73
  i18 := pg_temp.inv(1, 2026, 18, DATE '2026-09-11');
  PERFORM pg_temp.line(i18, 1,  'labor',         'Manager of Soccer Operations Duties', 51.5, 20.00, 1030.00, NULL, NULL);
  PERFORM pg_temp.line(i18, 2,  'equipment',     'Veo Subscription',          1, 53.93,  53.93, veo, 14);
  PERFORM pg_temp.line(i18, 3,  'facilities',    'Gorrila Carts #2,#3,#4',    1, 103.34, 103.34, carts, 2);
  PERFORM pg_temp.line(i18, 4,  'facilities',    'Light Stands & Water Bags', 1, 186.41, 186.41, stands, 2);
  PERFORM pg_temp.line(i18, 5,  'facilities',    'Field Paint',               1, 193.24, 193.24, NULL, NULL);
  PERFORM pg_temp.line(i18, 6,  'facilities',    'Top Soil',                  1, 397.00, 397.00, soil, 1);
  PERFORM pg_temp.line(i18, 7,  'uniforms',      'Youth shorts and socks + logo hoodies', 1, 197.63, 197.63, NULL, NULL);
  PERFORM pg_temp.line(i18, 8,  'uniforms',      'Youth Travel Shin Guards',  1, 140.80, 140.80, NULL, NULL);
  PERFORM pg_temp.line(i18, 9,  'uniforms',      'Numbers for Jersey Yellow', 1, 59.95,  59.95, NULL, NULL);
  PERFORM pg_temp.line(i18, 10, 'league_dues',   'Itc Clearences for youth players', 1, 95.83, 95.83, itc, 2);
  PERFORM pg_temp.line(i18, 11, 'league_dues',   'Youth u8,u10, u12',         1, 200.00, 200.00, youth, 2);
  PERFORM pg_temp.line(i18, 12, 'league_dues',   'Liga 1 payment plan Aug 29', 1, 125.10, 125.10, liga, 2);
  PERFORM pg_temp.line(i18, 13, 'field_rentals', 'Liga 1 game moved to turf due to rodeo', 1, 104.50, 104.50, turf, 2);
  PERFORM pg_temp.line(i18, 14, 'referees',      'Assignor Fee for u8,u10,u12 Parks & Rec Fall', 1, 90.00, 90.00, NULL, NULL);

  -- James 2026.19 (09/25/2026) — total $2,917.96
  i19 := pg_temp.inv(1, 2026, 19, DATE '2026-09-25');
  PERFORM pg_temp.line(i19, 1,  'labor',       'Manager of Soccer duties',   60, 20.00, 1200.00, NULL, NULL);
  PERFORM pg_temp.line(i19, 2,  'equipment',   'Veo Subscription',            1, 53.93,  53.93, veo, 15);
  PERFORM pg_temp.line(i19, 3,  'equipment',   'Gorrila Carts #2,#3,#4',      1, 103.34, 103.34, carts, 3);
  PERFORM pg_temp.line(i19, 4,  'equipment',   'Light Stands & Water Bags',   1, 186.41, 186.41, stands, 3);
  PERFORM pg_temp.line(i19, 5,  'equipment',   '2 1000W LED Lights',          1, 106.00, 106.00, leds, 1);
  PERFORM pg_temp.line(i19, 6,  'uniforms',    'Numbers for jerseys',         1, 109.90, 109.90, nums, 1);
  PERFORM pg_temp.line(i19, 7,  'uniforms',    'Jerseys, Pinnies',            1, 207.55, 207.55, jerseys, 1);
  PERFORM pg_temp.line(i19, 8,  'league_dues', 'Itc Clearences for youth players', 1, 95.83, 95.83, itc, 3);
  PERFORM pg_temp.line(i19, 9,  'league_dues', 'Youth u8,u10, u12',           1, 200.00, 200.00, youth, 3);
  PERFORM pg_temp.line(i19, 10, 'referees',    'APSL, Liga 1 x2, u8,u10,u12', 1, 655.00, 655.00, NULL, NULL);

  -- Luke 2026.18 (9/11/2026) — $172.50
  l18 := pg_temp.inv(3463, 2026, 18, DATE '2026-09-11');
  PERFORM pg_temp.line(l18, 1, 'labor', 'Coaching Duties', 15, 11.50, 172.50, NULL, NULL);

  -- Jamie 2026.10 (5/22/2026) and 2026.11 (6/4/2026) — $75.00 each
  j10 := pg_temp.inv(22193, 2026, 10, DATE '2026-05-22');
  PERFORM pg_temp.line(j10, 1, 'labor', 'Women''s Coach Duties', 5, 15.00, 75.00, NULL, NULL);
  j11 := pg_temp.inv(22193, 2026, 11, DATE '2026-06-04');
  PERFORM pg_temp.line(j11, 1, 'labor', 'Women''s Coach Duties', 5, 15.00, 75.00, NULL, NULL);
END $$;

-- ── Page copy (client_side rows, MessageCopy.block('invoices', tier)) ─────
CREATE OR REPLACE FUNCTION pg_temp.add_client_tpl(p_kind text, p_tier text, p_label text, p_body text, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
  SELECT 'System', p_label, p_kind, p_tier, NULL, p_body, p_sort, true, true
   WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = p_kind AND tier = p_tier);
$$;
SELECT pg_temp.add_client_tpl('invoices', 'subtitle',     'Invoices — page subtitle',
  'Biweekly invoices to The Lighthouse, Inc. Pick who is invoicing, start the next number, enter hours, print to PDF.', 1);
SELECT pg_temp.add_client_tpl('invoices', 'payable',      'Invoices — checks line on the sheet',
  'Make all checks payable to:', 2);
SELECT pg_temp.add_client_tpl('invoices', 'thanks',       'Invoices — closing line on the sheet',
  'Thank you for your business!', 3);
SELECT pg_temp.add_client_tpl('invoices', 'empty',        'Invoices — no invoices yet',
  'No invoices yet for {name}. Start one above.', 4);
SELECT pg_temp.add_client_tpl('invoices', 'print_hint',   'Invoices — print hint',
  'Print saves the sheet as {file}. Choose “Save as PDF” in the print dialog.', 5);
SELECT pg_temp.add_client_tpl('invoices', 'plan_hint',    'Invoices — instalment hint',
  'An instalment plan adds “{k} of {n}” to this invoice and to each new one until it is paid off.', 6);
SELECT pg_temp.add_client_tpl('invoices', 'missing_from', 'Invoices — issuer details incomplete',
  'Fill in the address, rate and payable-to line before printing.', 7);
SELECT pg_temp.add_client_tpl('invoices', 'delete_confirm','Invoices — delete confirm button',
  'Tap again to delete invoice {number}', 8);
