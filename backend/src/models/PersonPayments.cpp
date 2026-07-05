#include "PersonPayments.h"

#include <iostream>
#include <sstream>
#include <stdexcept>

#include <pqxx/pqxx>

#include "../database/Database.h"
#include "../services/LeagueAppsService.h"
#include "../third_party/json.hpp"

using nlohmann::json;

namespace {

// Convert LA epoch-ms → ISO8601 UTC ("YYYY-MM-DD HH:MM:SS+00").  Postgres
// accepts this via a plain string parameter typed as TIMESTAMPTZ.
std::string epochMsToIso(long long ms) {
    std::time_t t = static_cast<std::time_t>(ms / 1000);
    std::tm tm{};
    if (gmtime_r(&t, &tm) == nullptr) return {};
    char buf[32];
    std::snprintf(buf, sizeof(buf), "%04d-%02d-%02d %02d:%02d:%02d+00",
                  tm.tm_year + 1900, tm.tm_mon + 1, tm.tm_mday,
                  tm.tm_hour, tm.tm_min, tm.tm_sec);
    return buf;
}

long long optLong(const json& rec, const char* key) {
    if (!rec.contains(key) || rec[key].is_null()) return 0;
    if (rec[key].is_number()) return rec[key].get<long long>();
    if (rec[key].is_string()) {
        try { return std::stoll(rec[key].get<std::string>()); }
        catch (const std::exception&) { return 0; }
    }
    return 0;
}

std::string optStr(const json& rec, const char* key) {
    if (!rec.contains(key) || rec[key].is_null()) return {};
    if (rec[key].is_string()) return rec[key].get<std::string>();
    if (rec[key].is_number()) return std::to_string(rec[key].get<double>());
    return {};
}

double optNum(const json& rec, const char* key) {
    if (!rec.contains(key) || rec[key].is_null()) return 0.0;
    if (rec[key].is_number()) return rec[key].get<double>();
    return 0.0;
}

} // namespace

PersonPayments::PersonPayments()
    : db_(Database::getInstance()) {}

PersonPayments::~PersonPayments() = default;

int PersonPayments::syncFromLa() {
    // 1. Read the global cursor.
    long long cursorLu = 0, cursorId = 0;
    {
        auto rows = db_->query(
            "SELECT last_updated_ms, last_id "
            "  FROM leagueapps_transaction_cursor "
            " WHERE scope = 'global' "
            " LIMIT 1"
        );
        if (rows.empty()) {
            // Row is seeded by migration 078, but be defensive.
            db_->query(
                "INSERT INTO leagueapps_transaction_cursor (scope) VALUES ('global') "
                "ON CONFLICT DO NOTHING"
            );
        } else {
            cursorLu = rows[0]["last_updated_ms"].is_null() ? 0
                     : rows[0]["last_updated_ms"].as<long long>();
            cursorId = rows[0]["last_id"].is_null() ? 0
                     : rows[0]["last_id"].as<long long>();
        }
    }

    // First-run guard: skip 4+ years of historical LA transactions from
    // defunct programs that we'll never render.  Seed the cursor to
    // 2026-01-01 UTC so first sync only pulls current-year data (~1 page
    // instead of 50).  Overrideable via LEAGUEAPPS_TRANSACTION_SYNC_FROM_MS.
    if (cursorLu == 0 && cursorId == 0) {
        const char* raw = std::getenv("LEAGUEAPPS_TRANSACTION_SYNC_FROM_MS");
        long long seed = 1735689600000LL;  // 2026-01-01T00:00:00Z
        if (raw && *raw) {
            try { seed = std::stoll(raw); }
            catch (const std::exception&) { /* keep default */ }
        }
        cursorLu = seed;
        std::cerr << "[PersonPayments] first-run: seeding cursor to "
                  << seed << " ms" << std::endl;
    }

    // 2. Fetch new transactions.
    auto result = LeagueAppsService::getInstance()
                    .fetchTransactionsSince(cursorLu, cursorId);
    if (result.records.empty()) {
        // Even if empty, advance the cursor so we don't refetch the tail
        // page repeatedly.
        db_->query(
            "UPDATE leagueapps_transaction_cursor "
            "   SET last_updated_ms = $1, last_id = $2, last_synced_at = NOW() "
            " WHERE scope = 'global'",
            {std::to_string(result.newLastUpdatedMs),
             std::to_string(result.newLastId)}
        );
        return 0;
    }

    // 3. UPSERT each transaction.  Batched inside a single pqxx::work so
    //    a fresh backfill of ~50k rows doesn't spin up 50k separate
    //    round-trips.  Prepared once per invocation.
    //
    //    IMPORTANT: LA's transactions-2 feed returns one row per invoice
    //    line item, and a single Stripe charge covering N children shows
    //    up as N rows that all share the same top-level `id` but have
    //    distinct `transactionItemId` / `invoiceId` / `registrationId`.
    //    The uniqueness key is therefore `transactionItemId` (the per-
    //    line-item identifier), NOT `id`.  Keying on `id` alone caused
    //    every-but-the-last line item to be overwritten on ON CONFLICT
    //    and dropped from the DB.
    int written = 0;
    {
        auto tx = db_->beginTransaction();
        static constexpr const char* kUpsertSql =
            "INSERT INTO person_payments "
            "  (la_transaction_item_id, la_transaction_id, la_user_id, "
            "   la_registration_id, la_program_id, la_invoice_id, txn_type, "
            "   amount, net_amount, gateway, paid_at, last_updated, "
            "   first_name, last_name, program_name, raw, "
            "   inserted_at, updated_at) "
            "VALUES ($1::bigint, $2::bigint, $3::bigint, "
            "        NULLIF($4,'')::bigint, "
            "        $5::bigint, "
            "        NULLIF($6,'')::bigint, "
            "        $7, $8::numeric, $9::numeric, $10, "
            "        $11::timestamptz, $12::timestamptz, "
            "        NULLIF($13,''), NULLIF($14,''), NULLIF($15,''), "
            "        $16::jsonb, NOW(), NOW()) "
            "ON CONFLICT (la_transaction_item_id) DO UPDATE SET "
            "  la_transaction_id  = EXCLUDED.la_transaction_id, "
            "  la_user_id         = EXCLUDED.la_user_id, "
            "  la_registration_id = EXCLUDED.la_registration_id, "
            "  la_program_id      = EXCLUDED.la_program_id, "
            "  la_invoice_id      = EXCLUDED.la_invoice_id, "
            "  txn_type           = EXCLUDED.txn_type, "
            "  amount             = EXCLUDED.amount, "
            "  net_amount         = EXCLUDED.net_amount, "
            "  gateway            = EXCLUDED.gateway, "
            "  paid_at            = EXCLUDED.paid_at, "
            "  last_updated       = EXCLUDED.last_updated, "
            "  first_name         = EXCLUDED.first_name, "
            "  last_name          = EXCLUDED.last_name, "
            "  program_name       = EXCLUDED.program_name, "
            "  raw                = EXCLUDED.raw, "
            "  updated_at         = NOW()";
        for (const auto& rec : result.records) {
            const long long txnId  = optLong(rec, "id");
            if (txnId == 0) continue;
            const long long itemId = optLong(rec, "transactionItemId");
            if (itemId == 0) {
                // Every real LA transaction carries a transactionItemId.
                // Skipping the row is safer than blowing up the whole
                // batch on a malformed record.
                std::cerr << "[PersonPayments] skipping txnId=" << txnId
                          << " (no transactionItemId in record)" << std::endl;
                continue;
            }
            const long long userId = optLong(rec, "userId");
            const long long regId  = optLong(rec, "registrationId");
            const long long progId = optLong(rec, "programId");
            const long long invId  = optLong(rec, "invoiceId");
            const std::string type = optStr(rec, "type");
            const double amount    = optNum(rec, "amount");
            const double netAmt    = optNum(rec, "netAmount");
            const std::string gw   = optStr(rec, "gateway");
            const long long paidMs = optLong(rec, "created_on");
            const long long luMs   = optLong(rec, "lastUpdated");
            const std::string fn   = optStr(rec, "firstName");
            const std::string ln   = optStr(rec, "lastName");
            const std::string pn   = optStr(rec, "programName");
            try {
                tx->exec_params(kUpsertSql,
                    itemId,
                    txnId,
                    userId,
                    regId  == 0 ? std::string{} : std::to_string(regId),
                    progId,
                    invId  == 0 ? std::string{} : std::to_string(invId),
                    type,
                    amount,
                    netAmt,
                    gw,
                    epochMsToIso(paidMs),
                    epochMsToIso(luMs),
                    fn, ln, pn,
                    rec.dump());
                ++written;
            } catch (const std::exception& e) {
                std::cerr << "[PersonPayments] upsert failed itemId=" << itemId
                          << " txnId=" << txnId
                          << " userId=" << userId
                          << " program=" << progId
                          << ": " << e.what() << std::endl;
                // In pqxx a single failed statement aborts the transaction —
                // rethrow so the outer sync surfaces the error rather than
                // silently committing a partial batch.
                throw;
            }
        }
        db_->commit(tx);
    }
    std::cerr << "[PersonPayments] synced " << written << " transactions "
              << "(cursor → " << result.newLastUpdatedMs << "/"
              << result.newLastId << ")" << std::endl;

    // 4. Advance cursor.
    db_->query(
        "UPDATE leagueapps_transaction_cursor "
        "   SET last_updated_ms = $1, last_id = $2, last_synced_at = NOW() "
        " WHERE scope = 'global'",
        {std::to_string(result.newLastUpdatedMs),
         std::to_string(result.newLastId)}
    );
    return written;
}

std::unordered_map<std::string, PersonPayments::LastPayment>
PersonPayments::loadLastPositiveByProgram(long long programId) {
    std::unordered_map<std::string, LastPayment> out;
    // Refund / Partial Refund are excluded so a refund doesn't clear the
    // "last paid" state.  If accounting needs strict net-of-refunds later
    // we can layer it on.
    auto rows = db_->query(
        "SELECT DISTINCT ON (la_user_id) "
        "       la_user_id, amount, "
        "       TO_CHAR(paid_at AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS paid_iso, "
        "       txn_type "
        "  FROM person_payments "
        " WHERE la_program_id = $1 "
        "   AND txn_type IN ('Charge','Bank','Offline Payment') "
        "   AND amount > 0 "
        " ORDER BY la_user_id, paid_at DESC",
        {std::to_string(programId)}
    );
    out.reserve(rows.size());
    for (const auto& r : rows) {
        if (r["la_user_id"].is_null()) continue;
        LastPayment lp;
        lp.amount  = r["amount"].is_null()  ? 0.0 : r["amount"].as<double>();
        lp.paidAt  = r["paid_iso"].is_null() ? std::string{} : r["paid_iso"].c_str();
        lp.txnType = r["txn_type"].is_null() ? std::string{} : r["txn_type"].c_str();
        out.emplace(r["la_user_id"].c_str(), std::move(lp));
    }
    return out;
}

std::unordered_map<std::string, PersonPayments::LastPayment>
PersonPayments::loadLastPositiveByProgramByRegistration(long long programId) {
    std::unordered_map<std::string, LastPayment> out;
    auto rows = db_->query(
        "SELECT DISTINCT ON (la_registration_id) "
        "       la_registration_id, amount, "
        "       TO_CHAR(paid_at AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS paid_iso, "
        "       txn_type "
        "  FROM person_payments "
        " WHERE la_program_id = $1 "
        "   AND la_registration_id IS NOT NULL "
        "   AND txn_type IN ('Charge','Bank','Offline Payment') "
        "   AND amount > 0 "
        " ORDER BY la_registration_id, paid_at DESC",
        {std::to_string(programId)}
    );
    out.reserve(rows.size());
    for (const auto& r : rows) {
        if (r["la_registration_id"].is_null()) continue;
        LastPayment lp;
        lp.amount  = r["amount"].is_null()  ? 0.0 : r["amount"].as<double>();
        lp.paidAt  = r["paid_iso"].is_null() ? std::string{} : r["paid_iso"].c_str();
        lp.txnType = r["txn_type"].is_null() ? std::string{} : r["txn_type"].c_str();
        out.emplace(r["la_registration_id"].c_str(), std::move(lp));
    }
    return out;
}

std::unordered_map<std::string, std::vector<PersonPayments::LastPayment>>
PersonPayments::loadRecentByProgramByRegistration(long long programId, int limit) {
    std::unordered_map<std::string, std::vector<LastPayment>> out;
    if (limit <= 0) return out;
    // Newest-first per registration; caller slices to `limit` in C++.
    // Cheaper than a window function on a small table.
    auto rows = db_->query(
        "SELECT la_registration_id, amount, "
        "       TO_CHAR(paid_at AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS paid_iso, "
        "       txn_type "
        "  FROM person_payments "
        " WHERE la_program_id = $1 "
        "   AND la_registration_id IS NOT NULL "
        "   AND txn_type IN ('Charge','Bank','Offline Payment') "
        "   AND amount > 0 "
        " ORDER BY la_registration_id, paid_at DESC",
        {std::to_string(programId)}
    );
    for (const auto& r : rows) {
        if (r["la_registration_id"].is_null()) continue;
        std::string key = r["la_registration_id"].c_str();
        auto& bucket = out[key];
        if (static_cast<int>(bucket.size()) >= limit) continue;
        LastPayment lp;
        lp.amount  = r["amount"].is_null()  ? 0.0 : r["amount"].as<double>();
        lp.paidAt  = r["paid_iso"].is_null() ? std::string{} : r["paid_iso"].c_str();
        lp.txnType = r["txn_type"].is_null() ? std::string{} : r["txn_type"].c_str();
        bucket.push_back(std::move(lp));
    }
    return out;
}

std::vector<PersonPayments::PaymentRow>
PersonPayments::loadAllByProgram(long long programId) {
    std::vector<PaymentRow> out;
    // Full audit trail for the payments screen — no type filter, no
    // amount filter.  Refunds included.  Sort DESC so the newest activity
    // sits at the top of the table.
    auto rows = db_->query(
        "SELECT la_transaction_id, la_user_id, la_registration_id, la_invoice_id, "
        "       first_name, last_name, program_name, "
        "       amount, net_amount, gateway, txn_type, "
        "       TO_CHAR(paid_at AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS paid_iso "
        "  FROM person_payments "
        " WHERE la_program_id = $1 "
        " ORDER BY paid_at DESC, la_transaction_id DESC",
        {std::to_string(programId)}
    );
    out.reserve(rows.size());
    for (const auto& r : rows) {
        PaymentRow p;
        if (!r["la_transaction_id"].is_null())  p.transactionId  = r["la_transaction_id"].as<long long>();
        if (!r["la_user_id"].is_null())         p.userId         = r["la_user_id"].as<long long>();
        if (!r["la_registration_id"].is_null()) p.registrationId = r["la_registration_id"].as<long long>();
        if (!r["la_invoice_id"].is_null())      p.invoiceId      = r["la_invoice_id"].as<long long>();
        if (!r["first_name"].is_null())         p.firstName      = r["first_name"].c_str();
        if (!r["last_name"].is_null())          p.lastName       = r["last_name"].c_str();
        if (!r["program_name"].is_null())       p.programName    = r["program_name"].c_str();
        if (!r["amount"].is_null())             p.amount         = r["amount"].as<double>();
        if (!r["net_amount"].is_null()) {
            p.netAmount    = r["net_amount"].as<double>();
            p.hasNetAmount = true;
        }
        if (!r["gateway"].is_null())            p.gateway        = r["gateway"].c_str();
        if (!r["txn_type"].is_null())           p.txnType        = r["txn_type"].c_str();
        if (!r["paid_iso"].is_null())           p.paidAt          = r["paid_iso"].c_str();
        out.push_back(std::move(p));
    }
    return out;
}

// ──────────────────────────────────────────────────────────────────────────
// loadMembersForProgram
//
// Returns one row per person currently on the program (from
// person_la_memberships where ended_at IS NULL) joined with:
//   • lifetime aggregates from person_payments (totalPaid / totalRefunded
//     / txnCount / firstPaidAt / lastPaidAt / lastAmount)
//   • recent-window transactions = current calendar month + previous
//     calendar month, DESC by paid_at
//   • a computed `status` bucket for the operator's work queue
//
// Sort order: never-paid first (highest urgency), then oldest lastPaidAt
// first among those who've paid — i.e. the people who need action land
// at the top of the list.
//
// Join key: `la_registration_id` — the LA registration id uniquely
// identifies the (person, program) pair.  Both sides carry it:
//   • `person_payments.la_registration_id` — stored by the payments
//     upsert from each LA transaction's `registrationId` field.
//   • `person_la_memberships.la_registration_id` — populated by
//     PersonLinker::recordMembership from the LA registration record.
// We deliberately do NOT join by `la_user_id`, because for youth
// programs the transaction's userId is the PARENT (payer), which never
// matches the child's alias → child's membership row.
//
// A LEFT JOIN through external_person_aliases still resolves la_user_id
// for display purposes only (drives the "open in LA" link).
// ──────────────────────────────────────────────────────────────────────────
std::vector<PersonPayments::MemberRow>
PersonPayments::loadMembersForProgram(long long programId) {
    std::vector<MemberRow> out;

    // One trip to Postgres.  Billing model (user directive 2026-07-03):
    //
    // Cycles run 15th → 14th (1st-Friday-of-month monthly fee).  When
    // today.day ≤ 14 we are still in the cycle that ends this-month-14;
    // when day ≥ 15 the new cycle [this-15, next-15) has begun.
    //
    //   cur_start  = day-15-00:00 of {prev month if today.day ≤ 14
    //                else this month}
    //   cur_end    = cur_start + 1 month  (exclusive)
    //   prev_start = cur_start - 1 month
    //
    // Each non-refund payment of $35+ has a "coverage window".  For a
    // payment of $A paid_at some time within cycle C, the window
    // covers cycles [C, C + ROUND($A / $35) - 1]  (min 1 cycle).  So:
    //   $35   →  1 month coverage
    //   $70   →  2 months
    //   $99   →  3 months  (the seasonal edge case — pay in May,
    //                        covers May/June/July)
    //   $105  →  3 months
    //   $140  →  4 months
    // Cycles below the payment cycle are never covered; cycles at or
    // after are covered up to the end of the run.
    //
    // Status:
    //   never   — no payments on record
    //   current — some coverage window includes cur_start
    //   behind  — not current, but a coverage window includes prev_start
    //   overdue — has paid at some point but nothing covers the last
    //             two cycles
    //
    // Payments below $35 still count towards totalPaid / txnCount /
    // recent list (money is money), just not towards coverage.  Refunds
    // are excluded from coverage entirely (they don't buy dues).
    auto rows = db_->query(
        "WITH win AS ("
        "  SELECT ("
        "    CASE"
        "      WHEN date_part('day', now()) <= 14"
        "        THEN date_trunc('month', now() AT TIME ZONE 'UTC') - interval '1 month'"
        "      ELSE date_trunc('month', now() AT TIME ZONE 'UTC')"
        "    END + interval '14 days'"
        "  ) AS cur_start"
        "),"
        "win2 AS ("
        "  SELECT cur_start,"
        "         cur_start + interval '1 month' AS cur_end,"
        "         cur_start - interval '1 month' AS prev_start"
        "    FROM win"
        "),"
        "aliases AS ("
        "  SELECT person_id, MAX(external_user_id::bigint) AS la_user_id"
        "    FROM external_person_aliases"
        "   WHERE provider = 'leagueapps' AND external_user_id IS NOT NULL"
        "   GROUP BY person_id"
        "),"
        "primary_email AS ("
        // Prefer is_primary=true, then most-recently-created. One row per person.
        "  SELECT DISTINCT ON (pe.person_id) pe.person_id, pe.email"
        "    FROM person_emails pe"
        "   ORDER BY pe.person_id, pe.is_primary DESC NULLS LAST, pe.created_at DESC NULLS LAST, pe.id DESC"
        "),"
        "primary_phone AS ("
        "  SELECT DISTINCT ON (pp2.person_id)"
        "         pp2.person_id, pp2.phone_number, pp2.can_receive_sms, pp2.can_receive_calls"
        "    FROM person_phones pp2"
        "   ORDER BY pp2.person_id, pp2.is_primary DESC NULLS LAST, pp2.created_at DESC NULLS LAST, pp2.id DESC"
        "),"
        // All payment CTEs key on `la_registration_id` and DO NOT filter
        // by `pp.la_program_id`.  Rationale: LA sometimes tags a
        // transaction with the programId of the invoice's originating
        // cycle rather than the current cycle's programId (e.g. a Mens
        // regId currently under program 5039300 may have transactions
        // stamped with the previous cycle's 5005948).  Because a
        // `la_registration_id` is unique across all LA programs, joining
        // solely on registrationId is safe and captures ALL payments
        // that LA itself attributes to this registration (matching LA's
        // authoritative `amountPaid` field).  Rows without a
        // registrationId (rare — legacy payments prior to that field
        // being captured) are excluded from coverage math and aggregates
        // for this membership-oriented view.
        "agg AS ("
        "  SELECT pp.la_registration_id,"
        "         SUM(CASE WHEN pp.txn_type NOT IN ('Refund','Partial Refund') THEN pp.amount ELSE 0 END) AS total_paid,"
        "         SUM(CASE WHEN pp.txn_type IN ('Refund','Partial Refund')     THEN pp.amount ELSE 0 END) AS total_refunded,"
        "         COUNT(*) FILTER (WHERE pp.txn_type NOT IN ('Refund','Partial Refund')) AS txn_count,"
        "         MIN(pp.paid_at) FILTER (WHERE pp.txn_type NOT IN ('Refund','Partial Refund')) AS first_paid_at,"
        "         MAX(pp.paid_at) FILTER (WHERE pp.txn_type NOT IN ('Refund','Partial Refund')) AS last_paid_at"
        "    FROM person_payments pp"
        "   WHERE pp.la_registration_id IS NOT NULL"
        "   GROUP BY pp.la_registration_id"
        "),"
        // Per-payment coverage window.  For a $35+ non-refund payment
        // made in cycle C, the window covers cycles [C, C + N-1] where
        // N = ROUND(amount / 35), min 1.  We compute (pay_cycle_start,
        // pay_cycle_end) so downstream CTEs can check whether a given
        // reference cycle-start T falls in [pay_cycle_start, pay_cycle_end).
        //   pay_cycle_start = 15th-of-month for the cycle the payment
        //                     falls in.  Derived as:
        //                       date_trunc('month', paid_at - 14d) + 14d
        //                     (paid Apr 20 → Apr 15; paid Apr 5 → Mar 15).
        //   pay_cycle_end   = pay_cycle_start + N months  (exclusive).
        "payment_coverage AS ("
        "  SELECT pp.la_registration_id,"
        "         (date_trunc('month', pp.paid_at - interval '14 days') + interval '14 days') AS pay_cycle_start,"
        "         (date_trunc('month', pp.paid_at - interval '14 days') + interval '14 days')"
        "           + (GREATEST(1, ROUND(pp.amount / 35.0)::int) * interval '1 month') AS pay_cycle_end"
        "    FROM person_payments pp"
        "   WHERE pp.la_registration_id IS NOT NULL"
        "     AND pp.txn_type NOT IN ('Refund','Partial Refund')"
        "     AND pp.amount >= 35"
        "),"
        "covers_current AS ("
        "  SELECT DISTINCT pc.la_registration_id"
        "    FROM payment_coverage pc CROSS JOIN win2 w"
        "   WHERE pc.pay_cycle_start <= w.cur_start"
        "     AND pc.pay_cycle_end   >  w.cur_start"
        "),"
        "covers_previous AS ("
        "  SELECT DISTINCT pc.la_registration_id"
        "    FROM payment_coverage pc CROSS JOIN win2 w"
        "   WHERE pc.pay_cycle_start <= w.prev_start"
        "     AND pc.pay_cycle_end   >  w.prev_start"
        "),"
        "last_amt AS ("
        "  SELECT DISTINCT ON (pp.la_registration_id)"
        "         pp.la_registration_id, pp.amount AS last_amount"
        "    FROM person_payments pp"
        "   WHERE pp.la_registration_id IS NOT NULL"
        "     AND pp.txn_type NOT IN ('Refund','Partial Refund')"
        "   ORDER BY pp.la_registration_id, pp.paid_at DESC"
        "),"
        "recent AS ("
        // Extend the recent-txns window to the start of the previous
        // billing cycle (prev_start) so the frontend has both current
        // + previous cycles available for its own filtering.
        "  SELECT pp.la_registration_id,"
        "         jsonb_agg(jsonb_build_object("
        "             'transactionId', pp.la_transaction_id,"
        "             'amount',        pp.amount,"
        "             'txnType',       pp.txn_type,"
        "             'paidAt',        TO_CHAR(pp.paid_at AT TIME ZONE 'UTC','YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"'),"
        "             'gateway',       pp.gateway"
        "         ) ORDER BY pp.paid_at DESC) AS txns"
        "    FROM person_payments pp, win2"
        "   WHERE pp.la_registration_id IS NOT NULL"
        "     AND pp.paid_at >= win2.prev_start"
        "   GROUP BY pp.la_registration_id"
        ")"
        "SELECT p.id AS person_id, p.first_name, p.last_name,"
        "       TO_CHAR(p.birth_date, 'YYYY-MM-DD') AS dob,"
        "       pe.email                  AS email,"
        "       ph.phone_number           AS phone,"
        "       COALESCE(ph.can_receive_sms,   FALSE) AS phone_sms,"
        "       COALESCE(ph.can_receive_calls, FALSE) AS phone_call,"
        "       a.la_user_id,"
        "       m.la_registration_id      AS la_registration_id,"
        "       COALESCE(agg.total_paid,     0) AS total_paid,"        "       COALESCE(agg.total_refunded, 0) AS total_refunded,"
        "       COALESCE(agg.txn_count,      0) AS txn_count,"
        "       TO_CHAR(agg.first_paid_at AT TIME ZONE 'UTC','YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS first_paid_iso,"
        "       TO_CHAR(agg.last_paid_at  AT TIME ZONE 'UTC','YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS last_paid_iso,"
        "       COALESCE(la.last_amount, 0) AS last_amount,"
        "       COALESCE(recent.txns, '[]'::jsonb) AS recent_txns,"
        "       CASE"
        "         WHEN agg.last_paid_at IS NULL             THEN 'never'"
        "         WHEN cc.la_registration_id IS NOT NULL    THEN 'current'"
        "         WHEN cp.la_registration_id IS NOT NULL    THEN 'behind'"
        "         ELSE 'overdue'"
        "       END AS status"
        "  FROM person_la_memberships m"
        "  JOIN persons p ON p.id = m.person_id"
        "  LEFT JOIN aliases a          ON a.person_id           = p.id"
        "  LEFT JOIN primary_email pe   ON pe.person_id          = p.id"
        "  LEFT JOIN primary_phone ph   ON ph.person_id          = p.id"
        "  LEFT JOIN agg                ON agg.la_registration_id    = m.la_registration_id"
        "  LEFT JOIN last_amt la        ON la.la_registration_id     = m.la_registration_id"
        "  LEFT JOIN recent             ON recent.la_registration_id = m.la_registration_id"
        "  LEFT JOIN covers_current  cc ON cc.la_registration_id     = m.la_registration_id"
        "  LEFT JOIN covers_previous cp ON cp.la_registration_id     = m.la_registration_id"
        " WHERE m.la_program_id = $1::bigint AND m.ended_at IS NULL"
        " ORDER BY"
        "   CASE"
        "     WHEN agg.last_paid_at IS NULL             THEN 0"
        "     WHEN cc.la_registration_id IS NOT NULL    THEN 3"   // current
        "     WHEN cp.la_registration_id IS NOT NULL    THEN 2"   // behind
        "     ELSE 1"                                             // overdue
        "   END,"
        "   agg.last_paid_at ASC NULLS FIRST,"
        "   p.last_name, p.first_name",
        {std::to_string(programId)}
    );

    out.reserve(rows.size());
    for (const auto& r : rows) {
        MemberRow m;
        if (!r["person_id"].is_null()) m.personId = r["person_id"].as<int>();
        if (!r["la_user_id"].is_null()) m.laUserId = r["la_user_id"].as<long long>();
        if (!r["la_registration_id"].is_null())
            m.laRegistrationId = r["la_registration_id"].as<long long>();
        if (!r["first_name"].is_null()) m.firstName = r["first_name"].c_str();
        if (!r["last_name"].is_null())  m.lastName  = r["last_name"].c_str();
        if (!r["dob"].is_null())        m.dob       = r["dob"].c_str();
        if (!r["email"].is_null())      m.email     = r["email"].c_str();
        if (!r["phone"].is_null())      m.phone     = r["phone"].c_str();
        if (!r["phone_sms"].is_null())  m.phoneSms  = r["phone_sms"].as<bool>();
        if (!r["phone_call"].is_null()) m.phoneCall = r["phone_call"].as<bool>();
        if (!r["status"].is_null())     m.status    = r["status"].c_str();
        if (!r["total_paid"].is_null())      m.totalPaid     = r["total_paid"].as<double>();
        if (!r["total_refunded"].is_null())  m.totalRefunded = r["total_refunded"].as<double>();
        if (!r["txn_count"].is_null())       m.txnCount      = r["txn_count"].as<int>();
        if (!r["first_paid_iso"].is_null())  m.firstPaidAt   = r["first_paid_iso"].c_str();
        if (!r["last_paid_iso"].is_null())   m.lastPaidAt    = r["last_paid_iso"].c_str();
        if (!r["last_amount"].is_null())     m.lastAmount    = r["last_amount"].as<double>();

        if (!r["recent_txns"].is_null()) {
            try {
                auto arr = json::parse(r["recent_txns"].c_str());
                if (arr.is_array()) {
                    for (const auto& t : arr) {
                        RecentTxn rt;
                        if (t.contains("transactionId") && t["transactionId"].is_number())
                            rt.transactionId = t["transactionId"].get<long long>();
                        if (t.contains("amount") && t["amount"].is_number())
                            rt.amount = t["amount"].get<double>();
                        if (t.contains("txnType") && t["txnType"].is_string())
                            rt.txnType = t["txnType"].get<std::string>();
                        if (t.contains("paidAt") && t["paidAt"].is_string())
                            rt.paidAt = t["paidAt"].get<std::string>();
                        if (t.contains("gateway") && t["gateway"].is_string())
                            rt.gateway = t["gateway"].get<std::string>();
                        m.recentTxns.push_back(std::move(rt));
                    }
                }
            } catch (const std::exception& e) {
                std::cerr << "[PersonPayments::loadMembersForProgram] recent_txns parse failed: "
                          << e.what() << std::endl;
            }
        }
        out.push_back(std::move(m));
    }
    return out;
}