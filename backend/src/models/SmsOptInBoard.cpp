#include "SmsOptInBoard.h"

#include "../database/Database.h"
#include "KitBoard.h"

using nlohmann::json;

namespace {
json tsOrNull(const pqxx::row& r, const char* col) {
    return r[col].is_null() ? json(nullptr) : json(r[col].c_str());
}
}  // namespace

json SmsOptInBoard::teams(const std::vector<long long>& scopeTeamIds) {
    // One list of board teams for every per-team board.
    return KitBoard().teams(scopeTeamIds);
}

json SmsOptInBoard::roster(long long teamId) {
    auto rows = Database::getInstance()->query(R"SQL(
        SELECT p.id AS person_id, p.first_name, p.last_name, rs.display_name AS roster_status,
               (p.parent_person_id IS NOT NULL) AS youth,
               COALESCE(p.parent_person_id, p.id) AS recipient_person_id,
               COALESCE(par.first_name, p.first_name, '') AS recipient_first_name,
               (SELECT x.phone_number FROM person_phones x
                 WHERE x.person_id IN (COALESCE(p.parent_person_id, p.id), p.id)
                   AND COALESCE(x.can_receive_sms, true)
                 ORDER BY (x.person_id = COALESCE(p.parent_person_id, p.id)) DESC,
                          x.is_primary DESC NULLS LAST, x.id LIMIT 1) AS phone,
               to_char(GREATEST(fh_sms_consented_at(p.id), fh_sms_consented_at(COALESCE(p.parent_person_id, p.id)))
                       AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"') AS consented_at,
               to_char(GREATEST(fh_sms_opted_out_at(p.id), fh_sms_opted_out_at(COALESCE(p.parent_person_id, p.id)))
                       AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"') AS opted_out_at,
               (SELECT count(*) FROM sms_opt_in_nudges n WHERE n.person_id = p.id) AS nudges,
               to_char((SELECT max(n.sent_at) FROM sms_opt_in_nudges n WHERE n.person_id = p.id)
                       AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"') AS last_nudge_at
          FROM team_persons tp
          JOIN persons p ON p.id = tp.person_id
          LEFT JOIN persons par ON par.id = p.parent_person_id
          LEFT JOIN roster_statuses rs ON rs.id = tp.roster_status_id
         WHERE tp.team_id = $1::int AND tp.removed_at IS NULL
         ORDER BY p.last_name, p.first_name, p.id)SQL", {std::to_string(teamId)});
    json out = json::array();
    for (const auto& r : rows) {
        out.push_back({
            {"person_id",            r["person_id"].as<long long>()},
            {"first_name",           r["first_name"].is_null() ? "" : r["first_name"].c_str()},
            {"last_name",            r["last_name"].is_null()  ? "" : r["last_name"].c_str()},
            {"roster_status",        tsOrNull(r, "roster_status")},
            {"youth",                r["youth"].as<bool>()},
            {"recipient_person_id",  r["recipient_person_id"].as<long long>()},
            {"recipient_first_name", r["recipient_first_name"].c_str()},
            {"phone",                tsOrNull(r, "phone")},
            {"consented_at",         tsOrNull(r, "consented_at")},
            {"opted_out_at",         tsOrNull(r, "opted_out_at")},
            {"nudges",               {{"count", r["nudges"].as<int>()}, {"last_at", tsOrNull(r, "last_nudge_at")}}},
        });
    }
    return out;
}

bool SmsOptInBoard::onTeam(long long teamId, long long personId) {
    return !Database::getInstance()->query(
        "SELECT 1 FROM team_persons WHERE team_id = $1::int AND person_id = $2::int AND removed_at IS NULL",
        {std::to_string(teamId), std::to_string(personId)}).empty();
}

SmsOptInBoard::Person SmsOptInBoard::person(long long personId) {
    Person out;
    auto rows = Database::getInstance()->query(R"SQL(
        SELECT COALESCE(p.first_name,'') AS fn, p.parent_person_id, COALESCE(par.first_name,'') AS parent_fn,
               (SELECT x.phone_number FROM person_phones x
                 WHERE x.person_id IN (COALESCE(p.parent_person_id, p.id), p.id)
                   AND COALESCE(x.can_receive_sms, true)
                 ORDER BY (x.person_id = COALESCE(p.parent_person_id, p.id)) DESC,
                          x.is_primary DESC NULLS LAST, x.id LIMIT 1) AS phone
          FROM persons p LEFT JOIN persons par ON par.id = p.parent_person_id
         WHERE p.id = $1::int)SQL", {std::to_string(personId)});
    if (rows.empty()) return out;
    const auto& r = rows[0];
    out.found              = true;
    out.youth              = !r["parent_person_id"].is_null();
    out.recipientPersonId  = out.youth ? r["parent_person_id"].as<long long>() : personId;
    out.playerFirstName    = r["fn"].c_str();
    out.recipientFirstName = out.youth ? r["parent_fn"].c_str() : out.playerFirstName;
    if (!r["phone"].is_null()) out.phone = r["phone"].c_str();
    return out;
}

json SmsOptInBoard::logNudge(long long personId, long long recipientPersonId,
                             const std::string& channel, const std::string& contact,
                             long long sentByUserId) {
    auto* db = Database::getInstance();
    db->query("INSERT INTO sms_opt_in_nudges (person_id, recipient_person_id, channel, contact, sent_by_user_id) "
              "VALUES ($1::int, $2::int, $3, $4, NULLIF($5::int, 0))",
              {std::to_string(personId), std::to_string(recipientPersonId), channel, contact,
               std::to_string(sentByUserId)});
    auto t = db->query("SELECT count(*) AS n, to_char(max(sent_at) AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS last_at "
                       "  FROM sms_opt_in_nudges WHERE person_id = $1::int", {std::to_string(personId)});
    return {{"count", t[0]["n"].as<int>()}, {"last_at", tsOrNull(t[0], "last_at")}};
}
