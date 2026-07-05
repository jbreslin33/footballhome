#pragma once
#include <string>
#include <unordered_map>
#include <unordered_set>
#include <vector>

class Database;

// ────────────────────────────────────────────────────────────────────────────
// PersonPayments — LA transaction history persisted from
// /v2/sites/{site}/export/transactions-2.
//
// The transactions-2 endpoint is cross-program, so we sync GLOBALLY on
// every roster page load (per user directive 2026-07-02).  A single cursor
// row (scope='global') advances forward via last-updated/last-id pagination.
//
// Roster models call:
//   1. syncFromLa() — blocks until any new transactions have been UPSERTed.
//   2. loadLastPositiveByProgram(programId) — returns userId → last positive
//                                             payment ({amount, paidAt}).
// ────────────────────────────────────────────────────────────────────────────
class PersonPayments {
public:
    PersonPayments();
    ~PersonPayments();

    // Advance the global cursor, fetch every new transaction, UPSERT
    // into person_payments, and update the cursor.  Returns the number of
    // rows inserted or updated.  Safe to call on every roster load;
    // no-ops (0 rows) once caught up.  Throws on LA / DB error.
    int syncFromLa();

    struct LastPayment {
        double      amount = 0.0;    // dollars
        std::string paidAt;          // ISO8601 timestamp (UTC), empty when none
        std::string txnType;         // "Charge" / "Bank" / "Offline Payment"
    };

    // Returns userId → most-recent positive-money payment for the given
    // program (types: Charge, Bank, Offline Payment; excludes Refund /
    // Partial Refund).  Note: for youth programs, la_user_id on the
    // transaction is the paying PARENT — use the by-registration variant
    // below to match against a child player row.
    std::unordered_map<std::string, LastPayment>
    loadLastPositiveByProgram(long long programId);

    // Same as above but keyed by la_registration_id (string).  This is
    // the reliable join key for BOTH adult programs (self-pay) and youth
    // programs (parent pays for child) because each registration has its
    // own transactions.
    std::unordered_map<std::string, LastPayment>
    loadLastPositiveByProgramByRegistration(long long programId);

    // Returns registrationId → list of the N most-recent positive-money
    // payments (Charge / Bank / Offline Payment), newest-first.  Used to
    // render the "last 3 payments" mini-table on player cards.
    std::unordered_map<std::string, std::vector<LastPayment>>
    loadRecentByProgramByRegistration(long long programId, int limit);

    struct PaymentRow {
        long long   transactionId  = 0;
        long long   userId         = 0;
        long long   registrationId = 0;      // 0 if null
        long long   invoiceId      = 0;      // 0 if null
        std::string firstName;
        std::string lastName;
        std::string programName;
        double      amount    = 0.0;
        double      netAmount = 0.0;         // 0 if null
        bool        hasNetAmount = false;
        std::string gateway;
        std::string txnType;                 // Charge / Bank / Offline Payment / Refund / Partial Refund
        std::string paidAt;                  // ISO8601 UTC
    };

    // Returns every payment row recorded for the given program, sorted
    // by paidAt DESC (newest first).  Used by the dedicated payments
    // screen — no type/amount filtering applied; refunds included so the
    // operator sees the complete audit trail.
    std::vector<PaymentRow>
    loadAllByProgram(long long programId);

    // ── Members view (payment "report card" per member) ───────────────
    //
    // One row per person on the program, joined with a "what have you
    // done for me lately?" window: only transactions whose paid_at falls
    // in the current + previous billing cycle (see cycle definition
    // below).  Older history is aggregated into lifetime totals but the
    // raw rows are hidden — the operator only cares about the recent
    // window when deciding who to charge / pause.
    //
    // Billing cycle (updated 2026-07-03):
    //   A "monthly payment" is due by the 1st Friday of the month.  A
    //   cycle runs from the 15th of the previous month through the 14th
    //   of the current month.  When today.day ≤ 14 we are still inside
    //   the cycle ending on this-month-14; when day ≥ 15 the new cycle
    //   [this-month-15, next-month-15) has begun.
    //
    // Status semantics (computed server-side to keep the UI dumb):
    //   • "current"        — some non-refund payment of $35 or above
    //                        has a "coverage window" that includes the
    //                        current cycle.  Coverage window for a
    //                        payment of $A paid in cycle C runs from C
    //                        through C + ROUND($A / $35) - 1 (min 1).
    //                        So a $35 payment covers 1 cycle, a $99
    //                        seasonal payment covers 3 cycles, a $140
    //                        pre-pay covers 4 cycles, etc.
    //   • "behind"         — not current, but a payment's coverage
    //                        window includes the PREVIOUS cycle
    //   • "overdue"        — has paid at some point but nothing whose
    //                        coverage window reaches the previous or
    //                        current cycle
    //   • "never"          — no payment on record ever
    //
    // Sort: overdue/never first (oldest last_paid_at at the top), then
    // behind, then current, so the operator's work queue lands at the
    // top of the list.
    struct RecentTxn {
        long long   transactionId = 0;
        double      amount        = 0.0;
        std::string txnType;      // Charge / Refund / etc.
        std::string paidAt;       // ISO8601
        std::string gateway;
    };
    struct MemberRow {
        int         personId = 0;
        long long   laUserId = 0;
        long long   laRegistrationId = 0;  // join key back to LA registration record
        std::string firstName;
        std::string lastName;
        std::string dob;                   // ISO date (YYYY-MM-DD) or empty
        std::string email;                 // primary email or empty
        std::string phone;                 // primary phone or empty
        bool        phoneSms   = false;    // can_receive_sms on the primary phone
        bool        phoneCall  = false;    // can_receive_calls on the primary phone
        std::string status;                // current / behind / overdue / never
        double      totalPaid     = 0.0;   // lifetime positive money
        double      totalRefunded = 0.0;   // lifetime refund money (positive value)
        int         txnCount      = 0;     // lifetime positive-money count
        std::string firstPaidAt;           // ISO8601 or empty
        std::string lastPaidAt;            // ISO8601 or empty
        double      lastAmount    = 0.0;
        std::vector<RecentTxn> recentTxns; // last-2-calendar-months window
    };
    std::vector<MemberRow>
    loadMembersForProgram(long long programId);

private:
    Database* db_;
};
