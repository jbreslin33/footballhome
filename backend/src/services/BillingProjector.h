#pragma once
#include <string>

class BillingExpectations;

// ────────────────────────────────────────────────────────────────────────────
// BillingProjector — turns the current roster into per-Friday
// `billing_expectations` rows.
//
// Called by:
//   • BillingController::runProjector()          (admin manual trigger)
//   • BillingScheduler tick                      (Phase 2 — nightly cron)
//
// Rules (locked in 2026-07-05 with the operator):
//
//   Monthly ($35, first Friday of each calendar month):
//     - Every active `person_la_memberships` row generates a "monthly"
//       expectation on the first Friday of every calendar month within
//       the projection horizon whose date is on-or-after the member's
//       LA registration date (or ALL first-Fridays in horizon if the
//       registration date is unknown — see "established fallback").
//
//   Pro-rate ($8.75 per Friday between registration and F1):
//     - Applies only to memberships whose `la_registered_at` is known.
//     - F1  = first "first-Friday-of-month" on or after `la_registered_at`
//             (in America/New_York).
//     - gap = F1 - la_registered_at (in days, calendar).
//     - If gap > 5:  one "prorate" line per Friday strictly between
//                    la_registered_at and F1.
//     - If gap ≤ 5:  no pro-rate at all — LA charges $35 directly on F1.
//
//   Established fallback:
//     - Rows with NULL `la_registered_at` (all currently-synced rows —
//       column added by migration 090) are treated as "established" and
//       only accrue monthly $35 lines.  Pro-rate is skipped.  When the
//       LA-reg-date backfill (Phase 1c) fills `la_registered_at` in, the
//       next projector run will start emitting pro-rate lines for any
//       affected players.
//
// Idempotency:
//   The write path uses ON CONFLICT (leagueapps_user_id, la_program_id,
//   charge_date) DO UPDATE which only touches (kind, expected_amount) —
//   never lifecycle timestamps.  So re-running is safe: expectations
//   already in "paid" / "invoice-added" / "waived" states keep those
//   flags intact even if we re-derive their kind/amount.
//
// Concurrency:
//   run() grabs pg_try_advisory_lock(kLockKey).  If another projector
//   run is already in flight the call returns immediately with
//   didRun = false.  Lock is released on scope exit.
// ────────────────────────────────────────────────────────────────────────────
class BillingProjector {
public:
    // Postgres advisory-lock key.  Arbitrary constant — just needs to be
    // stable and not clash with other advisory locks in this DB.
    static constexpr long long kLockKey = 774'472'090LL;

    // Default projection horizon in days beyond "today".  60d covers
    // "two months ahead" which is plenty for the admin queue + roster
    // UI without producing a huge unpaid-expectation backlog.
    static constexpr int kDefaultHorizonDays = 60;

    // Default backfill span in days *before* today.  Retro-projection
    // (used by BillingReconciler on first-boot) covers the last 90d so
    // last month's + this month's expectations exist for reconciliation.
    static constexpr int kDefaultBackfillDays = 100;

    struct Summary {
        bool didRun          = false;
        int  activeMembers   = 0;
        int  monthlyInserted = 0;   // rows actually written (INSERT-side)
        int  prorateInserted = 0;
        std::string horizonStart;   // "YYYY-MM-DD"
        std::string horizonEnd;
        std::string ranAt;          // "YYYY-MM-DDTHH:MM:SSZ"
        std::string skipReason;     // populated when didRun = false
    };

    BillingProjector();

    // Full projection: horizon spans [today - backfillDays, today + horizonDays].
    // Uses defaults when arguments are omitted.
    Summary run(int horizonDays  = kDefaultHorizonDays,
                int backfillDays = kDefaultBackfillDays);

private:
    // The SQL row counts we return are the number of rows inserted (not
    // updated).  This is what an operator wants to see — "how many new
    // expectations did this run create?"
    int projectMonthly(const std::string& startIso,
                       const std::string& endIso);
    int projectProrate(const std::string& startIso,
                       const std::string& endIso);
};
