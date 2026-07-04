#pragma once
#include <string>
#include <vector>

class Database;

// ────────────────────────────────────────────────────────────────────────────
// ChargeFlags — CRUD over person_charge_flags (migration 080).
//
// Operator's "run this card in LA" work queue.  LA's public API is
// read-only for payments, so we flag the intent here; a human runs the
// card in LA Manager; then marks the flag 'ran' (or 'canceled').
//
// Rows are keyed by (la_user_id, la_program_id) — the same key used by
// PersonPayments so they line up cleanly with the Members view.
//
// Status lifecycle: pending → ran / canceled.  Only one PENDING flag per
// (user, program) at a time (partial-unique index in the migration).
// ────────────────────────────────────────────────────────────────────────────
class ChargeFlags {
public:
    ChargeFlags();
    ~ChargeFlags();

    struct Row {
        long long   id            = 0;
        long long   laUserId      = 0;
        long long   laProgramId   = 0;
        int         amountCents   = 0;
        std::string reason;                  // may be empty
        std::string status;                  // pending / ran / canceled
        int         createdBy     = 0;
        std::string createdAt;               // ISO8601 UTC
        int         resolvedBy    = 0;       // 0 if null
        bool        hasResolvedBy = false;
        std::string resolvedAt;              // empty if null
        std::string resolvedNote;            // may be empty

        // Denormalised for the queue UI so it doesn't need a second query.
        // Populated by list*/get; blank on create response.
        std::string firstName;
        std::string lastName;
    };

    struct CreateInput {
        long long   laUserId    = 0;
        long long   laProgramId = 0;
        int         amountCents = 0;
        std::string reason;
        int         createdBy   = 0;
    };

    // INSERT.  Throws pqxx::unique_violation if a pending flag already
    // exists for (laUserId, laProgramId).  Returns the inserted row (with
    // denormalised name backfilled).
    Row create(const CreateInput& in);

    // GET one by id.  Throws if not found.
    Row getById(long long id);

    // List flags.  If programId <= 0, returns across all programs.
    // If status is empty, returns all statuses.  ORDER BY:
    //   pending first (oldest first — FIFO work queue),
    //   then ran / canceled by resolved_at DESC.
    std::vector<Row> list(long long programId, const std::string& status);

    // PATCH status.  Allowed transitions from 'pending':
    //   'ran'      → operator ran the card in LA
    //   'canceled' → operator decided not to run
    // Any other transition throws.  resolvedNote optional.  Returns the
    // updated row.
    Row updateStatus(long long id,
                     const std::string& newStatus,
                     int resolvedBy,
                     const std::string& resolvedNote);

private:
    Database* db_;
};
