#pragma once
#include <string>
#include <vector>
#include <optional>

class Database;

// ────────────────────────────────────────────────────────────────────────────
// BillingExpectations — CRUD over the `billing_expectations` table
// (migration 090).
//
// A BillingExpectations::Row is a single per-Friday projected line-item
// for one LA registration:
//
//     (leagueAppsUserId, laProgramId, chargeDate, kind, expectedAmount)
//
// plus three monotonic lifecycle timestamps:
//
//     invoiceAddedAt  – set when the invoice was actually created on LA
//                       (either manually by an operator or auto by the
//                       reconciler once it sees LA.outstandingBalance
//                       ≥ expectedAmount).
//     paidAt          – set when the reconciler observes LA.outstandingBalance
//                       = 0 AND LA.paymentStatus = 'PAID'.
//     waivedAt        – set by admin action (skip this line, don't count
//                       it against the player).
//
// The projector is the sole *inserter* of new rows; every downstream
// caller either mutates state (invoice_added_at / paid_at / waived_at)
// or reads.
//
// The class is deliberately verbose about typing — LA ids are 64-bit
// numbers stored as bigint in Postgres; do NOT truncate to int32.
// ────────────────────────────────────────────────────────────────────────────
class BillingExpectations {
public:
    // Human-readable state derived from the three lifecycle timestamps.
    // Matches the code-and-view logic documented in migration 090.
    enum class State {
        Projected,     // future charge_date, no invoice yet
        Due,           // charge_date <= today, no invoice yet
        InvoiceAdded,  // invoice_added_at set, paid_at NULL
        Paid,          // paid_at set
        Waived         // waived_at set
    };

    struct Row {
        long long   id                = 0;
        long long   leagueAppsUserId  = 0;
        long long   laProgramId       = 0;
        std::string chargeDate;                // "YYYY-MM-DD"
        std::string kind;                      // "monthly" | "prorate"
        double      expectedAmount    = 0.0;
        std::string invoiceAddedAt;            // "" when NULL
        std::string paidAt;                    // "" when NULL
        std::string waivedAt;                  // "" when NULL
        std::string notes;                     // "" when NULL
        std::string createdAt;
        std::string updatedAt;

        // Convenience: derive the display state from the three timestamps
        // + the caller-supplied "today" (YYYY-MM-DD, America/NY).
        State state(const std::string& todayIso) const;
        static const char* stateName(State s);
    };

    struct UpsertInput {
        long long   leagueAppsUserId = 0;
        long long   laProgramId      = 0;
        std::string chargeDate;               // "YYYY-MM-DD"
        std::string kind;                     // "monthly" | "prorate"
        double      expectedAmount   = 0.0;
    };

    BillingExpectations();

    // Projector-side write: INSERT … ON CONFLICT (leagueapps_user_id,
    // la_program_id, charge_date) DO UPDATE.  Only updates `kind` and
    // `expected_amount` — never clobbers lifecycle timestamps.
    // Returns the post-write row.
    Row upsertProjection(const UpsertInput& in);

    // Reconciler / admin writes.  Idempotent — a no-op if the flag is
    // already set (so we don't churn updated_at unnecessarily).
    // Returns true if a row was updated.
    bool markInvoiceAdded(long long id, const std::string& note = "");
    bool markPaid        (long long id, const std::string& note = "");
    bool markWaived      (long long id, const std::string& note = "");

    // Row lookup helpers.
    std::optional<Row> findById(long long id);

    // All expectations for one LA user (or one user+program if program
    // > 0), newest charge_date first.  Used by the roster card drill-down
    // and by BillingReconciler's per-user scan.
    std::vector<Row> listByUser(long long leagueAppsUserId,
                                long long laProgramId = 0);

    // "Queue" scan for the admin surface: every row that is due today or
    // earlier and has no invoice_added_at and no waived_at, oldest first.
    // Optional programFilter narrows to one LA program.
    std::vector<Row> listOpenQueue(const std::string& todayIso,
                                    long long laProgramId = 0);
};
