-- 589 (2026-10-15) — the USASA CUP PLAYER POOL form, as a second version of
-- the #cup-rosters sheet.  Owner: "you have old one. we talked about pills
-- for each version … this is one i have to submit today for cup: <Google
-- Sheet> call it 'USASA CUP PLAYER POOL'. make it exactly like it is in link
-- … it needs to be able to click players in and auto fill out there stuff".
--
-- The new form is the cup's bulk-upload spreadsheet: one row per player with
-- Email / First Name / Last Name / Gender / Cell Phone / DOB / Address 1 /
-- Address 2 / City / State / Zip Code.  Each sheet now carries which form it
-- renders as (cup_rosters.form_version → cup_roster_form_versions), shown as
-- pills on #cup-rosters.  The address columns need a home: person_addresses
-- (one primary address per person).  Address rows themselves are loaded into
-- the DB, never committed here (contacts-db-only rule).

CREATE TABLE IF NOT EXISTS cup_roster_form_versions (
    code       text PRIMARY KEY,
    label      text NOT NULL,
    sort_order int  NOT NULL DEFAULT 0,
    is_active  boolean NOT NULL DEFAULT true
);
COMMENT ON TABLE cup_roster_form_versions IS
  'The forms a #cup-rosters sheet can render as; one pill per row (mig 589).';

INSERT INTO cup_roster_form_versions (code, label, sort_order) VALUES
  ('cup_player_pool', 'USASA CUP PLAYER POOL',        1),
  ('region1_pool',    'USASA Region 1 Player Pool',   2)
ON CONFLICT (code) DO NOTHING;

ALTER TABLE cup_rosters
  ADD COLUMN IF NOT EXISTS form_version text NOT NULL DEFAULT 'cup_player_pool'
      REFERENCES cup_roster_form_versions(code);
COMMENT ON COLUMN cup_rosters.form_version IS
  'Which form this sheet renders as on #cup-rosters (mig 589).';

-- One primary address per person, for forms that ask where a player lives.
CREATE TABLE IF NOT EXISTS person_addresses (
    id         serial PRIMARY KEY,
    person_id  int NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    address1   text NOT NULL DEFAULT '',
    address2   text NOT NULL DEFAULT '',
    city       text NOT NULL DEFAULT '',
    state      text NOT NULL DEFAULT '',
    zip        text NOT NULL DEFAULT '',
    is_primary boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX IF NOT EXISTS person_addresses_primary_uq
    ON person_addresses (person_id) WHERE is_primary;
COMMENT ON TABLE person_addresses IS
  'Street addresses (one primary per person); rows loaded, never migrated in (mig 589).';
