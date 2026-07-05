#include "BillingExpectations.h"

#include <sstream>
#include <stdexcept>

#include "../database/Database.h"

namespace {

// pqxx field → std::string ("" if NULL).
std::string strOrEmpty(const pqxx::field& f) {
    return f.is_null() ? std::string{} : std::string(f.c_str());
}

BillingExpectations::Row rowFromResult(const pqxx::row& r) {
    BillingExpectations::Row out;
    out.id               = r["id"].is_null() ? 0 : r["id"].as<long long>();
    out.leagueAppsUserId = r["leagueapps_user_id"].is_null()
                             ? 0 : r["leagueapps_user_id"].as<long long>();
    out.laProgramId      = r["la_program_id"].is_null()
                             ? 0 : r["la_program_id"].as<long long>();
    out.chargeDate       = strOrEmpty(r["charge_date"]);
    out.kind             = strOrEmpty(r["kind"]);
    out.expectedAmount   = r["expected_amount"].is_null()
                             ? 0.0 : r["expected_amount"].as<double>();
    out.invoiceAddedAt   = strOrEmpty(r["invoice_added_at"]);
    out.paidAt           = strOrEmpty(r["paid_at"]);
    out.waivedAt         = strOrEmpty(r["waived_at"]);
    out.notes            = strOrEmpty(r["notes"]);
    out.createdAt        = strOrEmpty(r["created_at"]);
    out.updatedAt        = strOrEmpty(r["updated_at"]);
    return out;
}

// A single reused SELECT projection so every helper returns the same
// column shape (matters because rowFromResult() reads by name).
constexpr const char* kSelectCols =
    "id, leagueapps_user_id, la_program_id, "
    "TO_CHAR(charge_date, 'YYYY-MM-DD') AS charge_date, "
    "kind, expected_amount, "
    "TO_CHAR(invoice_added_at AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS invoice_added_at, "
    "TO_CHAR(paid_at          AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS paid_at, "
    "TO_CHAR(waived_at        AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS waived_at, "
    "notes, "
    "TO_CHAR(created_at AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS created_at, "
    "TO_CHAR(updated_at AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS updated_at";

} // namespace

BillingExpectations::BillingExpectations() = default;

BillingExpectations::State
BillingExpectations::Row::state(const std::string& todayIso) const {
    if (!waivedAt.empty())        return State::Waived;
    if (!paidAt.empty())          return State::Paid;
    if (!invoiceAddedAt.empty())  return State::InvoiceAdded;
    // string compare works because chargeDate is "YYYY-MM-DD" ISO.
    if (!chargeDate.empty() && chargeDate <= todayIso) return State::Due;
    return State::Projected;
}

const char* BillingExpectations::Row::stateName(State s) {
    switch (s) {
        case State::Projected:    return "projected";
        case State::Due:          return "due";
        case State::InvoiceAdded: return "invoice-added";
        case State::Paid:         return "paid";
        case State::Waived:       return "waived";
    }
    return "projected";
}

BillingExpectations::Row
BillingExpectations::upsertProjection(const UpsertInput& in) {
    if (in.leagueAppsUserId <= 0) throw std::invalid_argument("leagueAppsUserId required");
    if (in.laProgramId      <= 0) throw std::invalid_argument("laProgramId required");
    if (in.chargeDate.empty())    throw std::invalid_argument("chargeDate required");
    if (in.kind != "monthly" && in.kind != "prorate")
        throw std::invalid_argument("kind must be 'monthly' or 'prorate'");
    if (in.expectedAmount < 0.0)  throw std::invalid_argument("expectedAmount must be >= 0");

    auto* db = Database::getInstance();

    std::ostringstream amt;
    amt.precision(2);
    amt << std::fixed << in.expectedAmount;

    // Only touch kind + expected_amount on conflict.  Never clobber
    // invoice_added_at / paid_at / waived_at — those are lifecycle state.
    std::string sql;
    sql.reserve(512);
    sql += "INSERT INTO billing_expectations "
           "  (leagueapps_user_id, la_program_id, charge_date, kind, expected_amount) "
           "VALUES ($1::bigint, $2::bigint, $3::date, $4, $5::numeric) "
           "ON CONFLICT (leagueapps_user_id, la_program_id, charge_date) DO UPDATE "
           "  SET kind            = EXCLUDED.kind, "
           "      expected_amount = EXCLUDED.expected_amount "
           "RETURNING ";
    sql += kSelectCols;

    const auto res = db->query(sql, {
        std::to_string(in.leagueAppsUserId),
        std::to_string(in.laProgramId),
        in.chargeDate,
        in.kind,
        amt.str()
    });
    if (res.empty()) throw std::runtime_error("upsertProjection returned no row");
    return rowFromResult(res[0]);
}

bool BillingExpectations::markInvoiceAdded(long long id, const std::string& note) {
    if (id <= 0) return false;
    auto* db = Database::getInstance();
    const auto res = db->query(
        "UPDATE billing_expectations "
        "   SET invoice_added_at = COALESCE(invoice_added_at, now()), "
        "       notes            = CASE "
        "                            WHEN $2 = '' THEN notes "
        "                            WHEN notes IS NULL OR notes = '' THEN $2 "
        "                            ELSE notes || E'\\n' || $2 "
        "                          END "
        " WHERE id = $1::bigint "
        "   AND invoice_added_at IS NULL "
        "RETURNING id",
        {std::to_string(id), note});
    return !res.empty();
}

bool BillingExpectations::markPaid(long long id, const std::string& note) {
    if (id <= 0) return false;
    auto* db = Database::getInstance();
    // markPaid also implies invoice_added_at (if a payment cleared, the
    // invoice was definitionally added at some earlier point).  We fill
    // it in the same update to keep the state machine monotonic.
    const auto res = db->query(
        "UPDATE billing_expectations "
        "   SET paid_at          = COALESCE(paid_at, now()), "
        "       invoice_added_at = COALESCE(invoice_added_at, now()), "
        "       notes            = CASE "
        "                            WHEN $2 = '' THEN notes "
        "                            WHEN notes IS NULL OR notes = '' THEN $2 "
        "                            ELSE notes || E'\\n' || $2 "
        "                          END "
        " WHERE id = $1::bigint "
        "   AND paid_at IS NULL "
        "RETURNING id",
        {std::to_string(id), note});
    return !res.empty();
}

bool BillingExpectations::markWaived(long long id, const std::string& note) {
    if (id <= 0) return false;
    auto* db = Database::getInstance();
    const auto res = db->query(
        "UPDATE billing_expectations "
        "   SET waived_at = COALESCE(waived_at, now()), "
        "       notes     = CASE "
        "                     WHEN $2 = '' THEN notes "
        "                     WHEN notes IS NULL OR notes = '' THEN $2 "
        "                     ELSE notes || E'\\n' || $2 "
        "                   END "
        " WHERE id = $1::bigint "
        "   AND waived_at IS NULL "
        "RETURNING id",
        {std::to_string(id), note});
    return !res.empty();
}

std::optional<BillingExpectations::Row>
BillingExpectations::findById(long long id) {
    if (id <= 0) return std::nullopt;
    auto* db = Database::getInstance();
    std::string sql = std::string("SELECT ") + kSelectCols
                    + " FROM billing_expectations WHERE id = $1::bigint";
    const auto res = db->query(sql, {std::to_string(id)});
    if (res.empty()) return std::nullopt;
    return rowFromResult(res[0]);
}

std::vector<BillingExpectations::Row>
BillingExpectations::listByUser(long long leagueAppsUserId, long long laProgramId) {
    std::vector<Row> out;
    if (leagueAppsUserId <= 0) return out;

    auto* db = Database::getInstance();
    std::string sql = std::string("SELECT ") + kSelectCols
                    + " FROM billing_expectations "
                      " WHERE leagueapps_user_id = $1::bigint";
    std::vector<std::string> params{std::to_string(leagueAppsUserId)};
    if (laProgramId > 0) {
        sql += " AND la_program_id = $2::bigint";
        params.push_back(std::to_string(laProgramId));
    }
    sql += " ORDER BY charge_date DESC";

    const auto res = db->query(sql, params);
    out.reserve(res.size());
    for (const auto& r : res) out.push_back(rowFromResult(r));
    return out;
}

std::vector<BillingExpectations::Row>
BillingExpectations::listOpenQueue(const std::string& todayIso, long long laProgramId) {
    std::vector<Row> out;
    if (todayIso.empty()) return out;

    auto* db = Database::getInstance();
    std::string sql = std::string("SELECT ") + kSelectCols
                    + " FROM billing_expectations "
                      " WHERE invoice_added_at IS NULL "
                      "   AND waived_at        IS NULL "
                      "   AND charge_date      <= $1::date";
    std::vector<std::string> params{todayIso};
    if (laProgramId > 0) {
        sql += " AND la_program_id = $2::bigint";
        params.push_back(std::to_string(laProgramId));
    }
    sql += " ORDER BY charge_date ASC, leagueapps_user_id ASC";

    const auto res = db->query(sql, params);
    out.reserve(res.size());
    for (const auto& r : res) out.push_back(rowFromResult(r));
    return out;
}
