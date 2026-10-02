-- 511 (2026-10-02) — What was added to a LeagueApps invoice, read from the
-- moves in its total due.
--
-- Owner: "why does david naranjo show oct dues not posted? … i just added
-- an installment to him and ran card and it went through but either way
-- putting in a 35 installment on or around oct first friday should trigger
-- you to show it was posted".  Then: "you need to go by the individual
-- charges not total to discerne what is what … so why can't we store any
-- diff in total due from la and back engineer the amount and date and then
-- discenr what it must be for most likely?"
--
-- LeagueApps' API hands over no invoice lines: the registration export
-- carries the invoice's TOTAL due and paid, the transaction export the card
-- payments (amount and day, no description).  The dues / fines boxes on
-- #payments (mig 460) read the payments, so an installment only showed as
-- posted once a payment of exactly that amount landed — and David's card
-- was run once for $70, September's unpaid $35 and October's together.
--
-- The total due moves by exactly what was added, the moment the sync next
-- looks (hourly, and on every load of a page that reads memberships).  So:
--
--   la_total_due_changes        one row per move in a registration's total
--                               due: how much, the total after, when FH saw
--                               it, and the snapshot before (the line was
--                               added between the two).  Written by a
--                               trigger on person_la_memberships.
--   fh_la_due_log_since()       the moment this record starts.  Before it,
--                               a posting can only be read from the card
--                               payments; from it on, only from this table.
--
-- What a move was FOR is not stored: PersonFines matches it by amount and
-- date (one month's dues, last month's fines, both in one), as it did with
-- the payments.  Two lines added between two syncs arrive as one move.
--
-- Back to 2026-09-27: person_dues_balance_log (mig 461) has every balance
-- since then, and balance moved + paid that day = what was added that day.
-- Those rows are source 'reconstructed', one per person per day — or one
-- per payment when everything added that day was also paid that day.

BEGIN;

CREATE TABLE IF NOT EXISTS la_total_due_changes (
  id                 bigserial PRIMARY KEY,
  person_id          integer NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
  la_registration_id bigint,
  la_program_id      bigint REFERENCES leagueapps_programs(program_id),
  delta_usd          numeric(10,2) NOT NULL CHECK (delta_usd <> 0),
  total_due_usd      numeric(10,2),
  observed_at        timestamptz NOT NULL DEFAULT now(),
  window_started_at  timestamptz,
  source             text NOT NULL CHECK (source IN ('sync', 'reconstructed'))
);
CREATE INDEX IF NOT EXISTS la_total_due_changes_person_idx
  ON la_total_due_changes (person_id, observed_at);
COMMENT ON TABLE la_total_due_changes IS
  'Each move in a LeagueApps invoice''s total due (mig 511): delta_usd > 0 = a charge or installment was added, < 0 = one was removed or credited. observed_at = when the sync saw it, window_started_at = the snapshot before. source ''reconstructed'' = rebuilt from person_dues_balance_log + payments for the days before the trigger existed (registration and total unknown).';

CREATE OR REPLACE FUNCTION fh_membership_total_due_changed() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
  -- The same registration, both totals known, and the total moved.  A new
  -- or swapped registration starts a fresh invoice — not a posting.
  IF NEW.la_registration_id IS NOT DISTINCT FROM OLD.la_registration_id
     AND NEW.la_program_id = OLD.la_program_id
     AND OLD.la_amount_owed_cents IS NOT NULL AND NEW.la_amount_owed_cents IS NOT NULL
     AND NEW.la_amount_owed_cents <> OLD.la_amount_owed_cents THEN
    INSERT INTO la_total_due_changes
           (person_id, la_registration_id, la_program_id, delta_usd, total_due_usd, window_started_at, source)
    VALUES (NEW.person_id, NEW.la_registration_id, NEW.la_program_id,
            (NEW.la_amount_owed_cents - OLD.la_amount_owed_cents) / 100.0,
            NEW.la_amount_owed_cents / 100.0, OLD.la_snapshot_at, 'sync');
  END IF;
  RETURN NULL;
END $$;

DROP TRIGGER IF EXISTS person_la_memberships_total_due_log ON person_la_memberships;
CREATE TRIGGER person_la_memberships_total_due_log
  AFTER UPDATE OF la_amount_owed_cents ON person_la_memberships
  FOR EACH ROW EXECUTE FUNCTION fh_membership_total_due_changed();

CREATE OR REPLACE FUNCTION fh_la_due_log_since()
RETURNS timestamptz LANGUAGE sql STABLE AS $$
  SELECT min(observed_at) FROM person_dues_balance_log
$$;
COMMENT ON FUNCTION fh_la_due_log_since() IS
  'When la_total_due_changes starts (mig 511): the first balance ever logged. Postings before it are read from person_payments, from it on from la_total_due_changes.';

-- ── Rebuild 2026-09-27 → now ─────────────────────────────────────────
-- Per person per club-local day: added = balance at the end − balance at
-- the start + paid in between.  Only the registrations the balance is made
-- of (fh_dues_balance_usd: current, an active or inactive programme), and
-- only up to the person's last sync: anything newer reaches the trigger as
-- a move in the total, and must not be counted here as well.
INSERT INTO la_total_due_changes (person_id, delta_usd, observed_at, window_started_at, source)
WITH reg AS (
  SELECT m.person_id, m.la_registration_id
    FROM person_la_memberships m
    JOIN leagueapps_programs lp ON lp.program_id = m.la_program_id AND lp.variant IN ('active', 'inactive')
   WHERE m.ended_at IS NULL AND m.la_registration_id IS NOT NULL
), base AS (
  SELECT l.person_id, min(l.observed_at) AS t0,
         COALESCE((SELECT max(m.la_snapshot_at) FROM person_la_memberships m
                    WHERE m.person_id = l.person_id AND m.ended_at IS NULL), now()) AS t_end
    FROM person_dues_balance_log l GROUP BY l.person_id
), days AS (
  SELECT b.person_id,
         GREATEST(b.t0, d::timestamp AT TIME ZONE 'America/New_York') AS t_from,
         LEAST(b.t_end, (d + interval '1 day')::timestamp AT TIME ZONE 'America/New_York') AS t_to
    FROM base b
   CROSS JOIN LATERAL generate_series((b.t0 AT TIME ZONE 'America/New_York')::date,
                                      (b.t_end AT TIME ZONE 'America/New_York')::date, interval '1 day') d
   WHERE b.t_end > b.t0
), moved AS (
  SELECT d.person_id, d.t_from, d.t_to,
         fh_dues_balance_at(d.person_id, d.t_from) AS bal_from,
         fh_dues_balance_at(d.person_id, d.t_to)   AS bal_to,
         (SELECT min(l.observed_at) FROM person_dues_balance_log l
           WHERE l.person_id = d.person_id AND l.observed_at > d.t_from AND l.observed_at <= d.t_to) AS first_move,
         (SELECT COALESCE(SUM(CASE WHEN pp.txn_type IN ('Charge', 'Offline Payment', 'Bank') THEN pp.amount ELSE -pp.amount END), 0)
            FROM person_payments pp JOIN reg r ON r.la_registration_id = pp.la_registration_id AND r.person_id = d.person_id
           WHERE pp.paid_at > d.t_from AND pp.paid_at <= d.t_to) AS paid
    FROM days d
), added AS (
  SELECT m.*, (m.bal_to - m.bal_from + m.paid) AS added FROM moved m
)
-- Everything added that day was paid that day: each payment is a line.
SELECT a.person_id, pp.amount, pp.paid_at, a.t_from, 'reconstructed'
  FROM added a
  JOIN reg r ON r.person_id = a.person_id
  JOIN person_payments pp ON pp.la_registration_id = r.la_registration_id
                         AND pp.paid_at > a.t_from AND pp.paid_at <= a.t_to
                         AND pp.txn_type IN ('Charge', 'Offline Payment', 'Bank')
 WHERE a.added > 0 AND a.bal_to = a.bal_from AND a.added = a.paid
   AND NOT EXISTS (SELECT 1 FROM la_total_due_changes WHERE source = 'reconstructed')
UNION ALL
-- Otherwise the day's net, at the first balance move of the day.
SELECT a.person_id, a.added, COALESCE(a.first_move, a.t_to), a.t_from, 'reconstructed'
  FROM added a
 WHERE a.added > 0 AND NOT (a.bal_to = a.bal_from AND a.added = a.paid)
   AND NOT EXISTS (SELECT 1 FROM la_total_due_changes WHERE source = 'reconstructed');

COMMIT;
