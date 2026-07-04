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
    int written = 0;
    {
        auto tx = db_->beginTransaction();
        static constexpr const char* kUpsertSql =
            "INSERT INTO person_payments "
            "  (la_transaction_id, la_user_id, la_registration_id, "
            "   la_program_id, la_invoice_id, txn_type, amount, net_amount, "
            "   gateway, paid_at, last_updated, first_name, last_name, "
            "   program_name, raw, inserted_at, updated_at) "
            "VALUES ($1::bigint, $2::bigint, "
            "        NULLIF($3,'')::bigint, "
            "        $4::bigint, "
            "        NULLIF($5,'')::bigint, "
            "        $6, $7::numeric, $8::numeric, $9, "
            "        $10::timestamptz, $11::timestamptz, "
            "        NULLIF($12,''), NULLIF($13,''), NULLIF($14,''), "
            "        $15::jsonb, NOW(), NOW()) "
            "ON CONFLICT (la_transaction_id) DO UPDATE SET "
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
                std::cerr << "[PersonPayments] upsert failed txnId=" << txnId
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
// A LEFT JOIN through external_person_aliases resolves la_user_id from
// the persons row.  Every LA-linked person has a row in that table with
// provider='leagueapps' and external_user_id populated.
// ──────────────────────────────────────────────────────────────────────────
std::vector<PersonPayments::MemberRow>
PersonPayments::loadMembersForProgram(long long programId) {
    std::vector<MemberRow> out;

    // One trip to Postgres.  The two-month window is computed via
    // date_trunc('month', now()) - '1 month' so it stays honest across
    // month boundaries (Aug 1 → shows July+Aug, Aug 4 → still July+Aug).
    auto rows = db_->query(
        "WITH win AS ("
        "  SELECT date_trunc('month', now()) - interval '1 month' AS start_ts,"
        "         date_trunc('month', now())                       AS this_month"
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
        "agg AS ("
        "  SELECT pp.la_user_id,"
        "         SUM(CASE WHEN pp.txn_type NOT IN ('Refund','Partial Refund') THEN pp.amount ELSE 0 END) AS total_paid,"
        "         SUM(CASE WHEN pp.txn_type IN ('Refund','Partial Refund')     THEN pp.amount ELSE 0 END) AS total_refunded,"
        "         COUNT(*) FILTER (WHERE pp.txn_type NOT IN ('Refund','Partial Refund')) AS txn_count,"
        "         MIN(pp.paid_at) FILTER (WHERE pp.txn_type NOT IN ('Refund','Partial Refund')) AS first_paid_at,"
        "         MAX(pp.paid_at) FILTER (WHERE pp.txn_type NOT IN ('Refund','Partial Refund')) AS last_paid_at"
        "    FROM person_payments pp"
        "   WHERE pp.la_program_id = $1::bigint"
        "   GROUP BY pp.la_user_id"
        "),"
        "last_amt AS ("
        "  SELECT DISTINCT ON (pp.la_user_id)"
        "         pp.la_user_id, pp.amount AS last_amount"
        "    FROM person_payments pp"
        "   WHERE pp.la_program_id = $1::bigint"
        "     AND pp.txn_type NOT IN ('Refund','Partial Refund')"
        "   ORDER BY pp.la_user_id, pp.paid_at DESC"
        "),"
        "recent AS ("
        "  SELECT pp.la_user_id,"
        "         jsonb_agg(jsonb_build_object("
        "             'transactionId', pp.la_transaction_id,"
        "             'amount',        pp.amount,"
        "             'txnType',       pp.txn_type,"
        "             'paidAt',        TO_CHAR(pp.paid_at AT TIME ZONE 'UTC','YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"'),"
        "             'gateway',       pp.gateway"
        "         ) ORDER BY pp.paid_at DESC) AS txns"
        "    FROM person_payments pp, win"
        "   WHERE pp.la_program_id = $1::bigint"
        "     AND pp.paid_at >= win.start_ts"
        "   GROUP BY pp.la_user_id"
        ")"
        "SELECT p.id AS person_id, p.first_name, p.last_name,"
        "       TO_CHAR(p.birth_date, 'YYYY-MM-DD') AS dob,"
        "       pe.email                  AS email,"
        "       ph.phone_number           AS phone,"
        "       COALESCE(ph.can_receive_sms,   FALSE) AS phone_sms,"
        "       COALESCE(ph.can_receive_calls, FALSE) AS phone_call,"
        "       a.la_user_id,"
        "       COALESCE(agg.total_paid,     0) AS total_paid,"
        "       COALESCE(agg.total_refunded, 0) AS total_refunded,"
        "       COALESCE(agg.txn_count,      0) AS txn_count,"
        "       TO_CHAR(agg.first_paid_at AT TIME ZONE 'UTC','YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS first_paid_iso,"
        "       TO_CHAR(agg.last_paid_at  AT TIME ZONE 'UTC','YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS last_paid_iso,"
        "       COALESCE(la.last_amount, 0) AS last_amount,"
        "       COALESCE(recent.txns, '[]'::jsonb) AS recent_txns,"
        "       CASE"
        "         WHEN agg.last_paid_at IS NULL                             THEN 'never'"
        "         WHEN agg.last_paid_at >= (SELECT this_month FROM win)     THEN 'current'"
        "         WHEN agg.last_paid_at >= (SELECT start_ts   FROM win)     THEN 'behind'"
        "         ELSE 'overdue'"
        "       END AS status"
        "  FROM person_la_memberships m"
        "  JOIN persons p ON p.id = m.person_id"
        "  LEFT JOIN aliases a       ON a.person_id       = p.id"
        "  LEFT JOIN primary_email pe ON pe.person_id     = p.id"
        "  LEFT JOIN primary_phone ph ON ph.person_id     = p.id"
        "  LEFT JOIN agg              ON agg.la_user_id   = a.la_user_id"
        "  LEFT JOIN last_amt la      ON la.la_user_id    = a.la_user_id"
        "  LEFT JOIN recent           ON recent.la_user_id = a.la_user_id"
        " WHERE m.la_program_id = $1::bigint AND m.ended_at IS NULL"
        " ORDER BY"
        "   CASE"
        "     WHEN agg.last_paid_at IS NULL THEN 0"
        "     WHEN agg.last_paid_at <  (SELECT start_ts   FROM win) THEN 1"
        "     WHEN agg.last_paid_at <  (SELECT this_month FROM win) THEN 2"
        "     ELSE 3"
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