#include "ChargeFlags.h"

#include <iostream>
#include <stdexcept>

#include <pqxx/pqxx>

#include "../database/Database.h"

namespace {

// Parse column, tolerating NULL.
template <typename T>
T colOr(const pqxx::row& r, const char* col, T fallback) {
    if (r[col].is_null()) return fallback;
    return r[col].as<T>();
}

std::string colStr(const pqxx::row& r, const char* col) {
    if (r[col].is_null()) return {};
    return r[col].c_str();
}

ChargeFlags::Row fromRow(const pqxx::row& r) {
    ChargeFlags::Row out;
    out.id            = colOr<long long>(r, "id", 0);
    out.laUserId      = colOr<long long>(r, "la_user_id", 0);
    out.laProgramId   = colOr<long long>(r, "la_program_id", 0);
    out.amountCents   = colOr<int>       (r, "amount_cents", 0);
    out.reason        = colStr           (r, "reason");
    out.status        = colStr           (r, "status");
    out.createdBy     = colOr<int>       (r, "created_by", 0);
    out.createdAt     = colStr           (r, "created_at_iso");
    if (!r["resolved_by"].is_null()) {
        out.resolvedBy    = r["resolved_by"].as<int>();
        out.hasResolvedBy = true;
    }
    out.resolvedAt    = colStr(r, "resolved_at_iso");
    out.resolvedNote  = colStr(r, "resolved_note");
    // First/last name backfilled via LEFT JOIN external_person_aliases in
    // list/get queries; blank on plain SELECTs.
    if (r.column_number("first_name") != -1) out.firstName = colStr(r, "first_name");
    if (r.column_number("last_name")  != -1) out.lastName  = colStr(r, "last_name");
    return out;
}

// SELECT list used by every read path.  Joins `external_person_aliases`
// (provider='leagueapps') to denormalise the person's name into each row
// so the queue UI doesn't need a per-row lookup.  Left join — a flag for
// an LA userId with no alias row is still returned (blank name).
const char* kBaseSelect =
    "SELECT f.id, f.la_user_id, f.la_program_id, f.amount_cents, f.reason, "
    "       f.status, f.created_by, "
    "       TO_CHAR(f.created_at  AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS created_at_iso, "
    "       f.resolved_by, "
    "       CASE WHEN f.resolved_at IS NULL THEN NULL "
    "            ELSE TO_CHAR(f.resolved_at AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') END AS resolved_at_iso, "
    "       f.resolved_note, "
    "       a.alias_first_name AS first_name, "
    "       a.alias_last_name  AS last_name "
    "  FROM person_charge_flags f "
    "  LEFT JOIN external_person_aliases a "
    "         ON a.provider = 'leagueapps' "
    "        AND a.external_user_id = f.la_user_id::text ";

} // namespace

ChargeFlags::ChargeFlags()
    : db_(Database::getInstance()) {}

ChargeFlags::~ChargeFlags() = default;

ChargeFlags::Row ChargeFlags::create(const CreateInput& in) {
    if (in.laUserId    <= 0) throw std::invalid_argument("laUserId required");
    if (in.laProgramId <= 0) throw std::invalid_argument("laProgramId required");
    if (in.amountCents <= 0) throw std::invalid_argument("amountCents must be > 0");
    if (in.createdBy   <= 0) throw std::invalid_argument("createdBy required");

    // INSERT.  The partial-unique-on-status='pending' constraint means a
    // second call with the same (userId, programId) while the first row is
    // still pending will raise pqxx::unique_violation — we let that
    // propagate so the controller can return 409 Conflict.
    auto ins = db_->query(
        "INSERT INTO person_charge_flags "
        "  (la_user_id, la_program_id, amount_cents, reason, created_by) "
        "VALUES ($1::bigint, $2::bigint, $3::int, NULLIF($4,''), $5::int) "
        "RETURNING id",
        {
            std::to_string(in.laUserId),
            std::to_string(in.laProgramId),
            std::to_string(in.amountCents),
            in.reason,
            std::to_string(in.createdBy),
        }
    );
    if (ins.empty()) throw std::runtime_error("INSERT returned no rows");
    const long long newId = ins[0]["id"].as<long long>();
    return getById(newId);
}

ChargeFlags::Row ChargeFlags::getById(long long id) {
    std::string sql = std::string(kBaseSelect) + " WHERE f.id = $1::bigint LIMIT 1";
    auto rows = db_->query(sql, {std::to_string(id)});
    if (rows.empty()) throw std::runtime_error("charge flag not found");
    return fromRow(rows[0]);
}

std::vector<ChargeFlags::Row>
ChargeFlags::list(long long programId, const std::string& status) {
    // Build the WHERE clause dynamically but with parameter binding, not
    // string interpolation, to keep this immune to SQL injection.
    std::string where;
    std::vector<std::string> params;
    int p = 1;
    auto add = [&](const std::string& col, const std::string& val) {
        if (!where.empty()) where += " AND ";
        else                where += "WHERE ";
        where += col + " = $" + std::to_string(p++);
        params.push_back(val);
    };
    if (programId > 0)      add("f.la_program_id::text", std::to_string(programId));
    if (!status.empty())    add("f.status",              status);

    // ORDER BY: pending first (FIFO — oldest first, that's the work queue
    // order), then everything else newest-resolved-first.
    const std::string sql = std::string(kBaseSelect) + " " + where +
        " ORDER BY CASE f.status WHEN 'pending' THEN 0 ELSE 1 END, "
        "          CASE WHEN f.status = 'pending' "
        "               THEN f.created_at "
        "               ELSE '-infinity'::timestamptz END ASC, "
        "          f.resolved_at DESC NULLS LAST, "
        "          f.created_at  DESC";

    auto rows = db_->query(sql, params);
    std::vector<Row> out;
    out.reserve(rows.size());
    for (const auto& r : rows) out.push_back(fromRow(r));
    return out;
}

ChargeFlags::Row ChargeFlags::updateStatus(long long id,
                                           const std::string& newStatus,
                                           int resolvedBy,
                                           const std::string& resolvedNote) {
    if (newStatus != "ran" && newStatus != "canceled") {
        throw std::invalid_argument("newStatus must be 'ran' or 'canceled'");
    }
    if (resolvedBy <= 0) throw std::invalid_argument("resolvedBy required");

    // Only allow transition FROM 'pending'.  Any concurrent second
    // resolution (or a stale UI trying to re-resolve) fails the WHERE and
    // updates zero rows → we throw so the controller returns 409.
    auto res = db_->query(
        "UPDATE person_charge_flags "
        "   SET status        = $1, "
        "       resolved_by   = $2::int, "
        "       resolved_at   = now(), "
        "       resolved_note = NULLIF($3,''), "
        "       updated_at    = now() "
        " WHERE id = $4::bigint AND status = 'pending' "
        " RETURNING id",
        {
            newStatus,
            std::to_string(resolvedBy),
            resolvedNote,
            std::to_string(id),
        }
    );
    if (res.empty()) {
        throw std::runtime_error(
            "charge flag not found or already resolved (id=" + std::to_string(id) + ")");
    }
    return getById(id);
}
