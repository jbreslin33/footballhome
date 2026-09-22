#include "PayReminderLog.h"

#include <cmath>
#include <sstream>

#include "../database/Database.h"

PayReminderLog::PayReminderLog()
    : db_(Database::getInstance()) {}

void PayReminderLog::record(long long          laUserId,
                             const std::string& method,
                             long long          senderUserId,
                             const std::string& club,
                             const std::string& tier,
                             double             amount,
                             int                daysOverdue) {
    // Coerce optional fields to Postgres NULLs by passing empty strings
    // that pqxx renders as parameter NULLs is not directly possible via
    // the vector<string> overload used elsewhere in the code base — that
    // overload treats every entry as a non-null literal.  So instead we
    // parameterise only the required fields and inline the optionals with
    // NULLIF / CASE.  Safer: parameterise them all and let Postgres coerce.
    //
    // Approach: pass string forms; use NULLIF for the fields we want to
    // become NULL when unset.  Amount uses sentinel "" → NULL cast.
    const std::string senderStr = (senderUserId > 0) ? std::to_string(senderUserId) : std::string{};
    const std::string amountStr = (std::isfinite(amount) && amount >= 0.0)
                                    ? std::to_string(amount)
                                    : std::string{};
    const std::string daysStr   = (daysOverdue >= 0) ? std::to_string(daysOverdue) : std::string{};

    db_->query(
        "INSERT INTO pay_reminder_log "
        "  (la_user_id, method, sent_by_user_id, club, tier, amount, days_overdue) "
        "VALUES ("
        "  $1::bigint, "
        "  $2::text, "
        "  NULLIF($3, '')::integer, "
        "  NULLIF($4, '')::text, "
        "  NULLIF($5, '')::text, "
        "  NULLIF($6, '')::numeric(10,2), "
        "  NULLIF($7, '')::integer"
        ")",
        {std::to_string(laUserId), method, senderStr, club, tier, amountStr, daysStr}
    );
}

PayReminderLog::Map PayReminderLog::latestFor(const std::vector<long long>& laUserIds) {
    Map out;
    if (laUserIds.empty()) return out;

    // Inline IN (...) list of bigints.  Values come from our trusted
    // upstream (LA export → int64); the loop only ever emits digits.
    std::ostringstream idList;
    bool first = true;
    for (long long uid : laUserIds) {
        if (!first) idList << ',';
        idList << uid;
        first = false;
    }

    // One row per (user, channel): count + newest send.  The overall
    // newest is derived in the loop below.
    std::ostringstream sql;
    sql << "SELECT la_user_id, method, COUNT(*) AS n, "
        << "  TO_CHAR(MAX(sent_at) AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS.MS\"Z\"') AS sent_at_iso "
        << "FROM pay_reminder_log "
        << "WHERE la_user_id IN (" << idList.str() << ") "
        << "  AND method IN ('sms','email') "
        << "GROUP BY la_user_id, method";

    const auto rows = db_->query(sql.str());
    for (const auto& r : rows) {
        if (r["la_user_id"].is_null() || r["method"].is_null()) continue;
        Latest& v = out[r["la_user_id"].c_str()];
        const std::string method = r["method"].c_str();
        const std::string at     = r["sent_at_iso"].is_null() ? std::string{} : r["sent_at_iso"].c_str();
        const int n              = r["n"].is_null() ? 0 : r["n"].as<int>();
        if (method == "sms") { v.smsCount = n;   v.smsAtIso = at; }
        else                 { v.emailCount = n; v.emailAtIso = at; }
        // ISO-8601 UTC strings compare lexically.
        if (at > v.sentAtIso) { v.sentAtIso = at; v.method = method; }
    }
    return out;
}
