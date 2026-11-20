#include "WelcomeLog.h"

#include <iostream>
#include <sstream>
#include <unordered_set>

#include "../database/Database.h"

using nlohmann::json;

WelcomeLog::WelcomeLog()
    : db_(Database::getInstance()) {}

void WelcomeLog::record(long long          personId,
                        long long          playerPersonId,
                        const std::string& channel,
                        const std::string& contact,
                        long long          senderUserId) {
    db_->query(
        "INSERT INTO person_welcomes "
        "  (person_id, player_person_id, channel, contact, sent_by_user_id) "
        "VALUES ($1::int, NULLIF($2, '')::int, $3::text, $4::text, NULLIF($5, '')::int)",
        {std::to_string(personId),
         playerPersonId > 0 ? std::to_string(playerPersonId) : std::string{},
         channel,
         contact,
         senderUserId > 0 ? std::to_string(senderUserId) : std::string{}});
}

WelcomeLog::Map WelcomeLog::latestFor(const std::vector<long long>& personIds) {
    Map out;
    if (personIds.empty()) return out;
    std::ostringstream idList;
    bool first = true;
    for (long long pid : personIds) {
        if (pid <= 0) continue;
        if (!first) idList << ',';
        idList << pid;
        first = false;
    }
    if (first) return out;
    std::ostringstream sql;
    sql << "SELECT DISTINCT ON (person_id) person_id, channel, contact, "
        << "  TO_CHAR(sent_at AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS.MS\"Z\"') AS sent_at_iso "
        << "FROM person_welcomes WHERE person_id IN (" << idList.str() << ") "
        << "ORDER BY person_id, sent_at DESC";
    const auto rows = db_->query(sql.str());
    out.reserve(rows.size());
    for (const auto& r : rows) {
        if (r["person_id"].is_null()) continue;
        Latest v;
        v.channel   = r["channel"].is_null()     ? std::string{} : r["channel"].c_str();
        v.contact   = r["contact"].is_null()     ? std::string{} : r["contact"].c_str();
        v.sentAtIso = r["sent_at_iso"].is_null() ? std::string{} : r["sent_at_iso"].c_str();
        out.emplace(r["person_id"].as<long long>(), std::move(v));
    }
    return out;
}

std::string WelcomeLog::policyCutoff(int clubId) {
    const auto rows = db_->query(
        "SELECT TO_CHAR(registered_on_or_after, 'YYYY-MM-DD') AS ymd "
        "  FROM welcome_outreach_policies WHERE club_id = $1::int "
        " ORDER BY created_at DESC, id DESC LIMIT 1",
        {std::to_string(clubId)});
    if (rows.empty() || rows[0]["ymd"].is_null()) return {};
    return rows[0]["ymd"].c_str();
}

void WelcomeLog::attach(json&              row,
                        long long          targetPersonId,
                        const json&        laRegisteredAt,
                        const Map&         latest,
                        const std::string& cutoffYmd) {
    if (targetPersonId <= 0) {
        row["welcome"] = json(nullptr);
        return;
    }
    json w = json::object();
    auto it = latest.find(targetPersonId);
    const bool sent = it != latest.end();
    w["lastSentAt"]  = sent ? json(it->second.sentAtIso) : json(nullptr);
    w["lastChannel"] = sent ? json(it->second.channel)   : json(nullptr);
    w["lastContact"] = sent ? json(it->second.contact)   : json(nullptr);

    bool due = false;
    if (!sent && !cutoffYmd.empty() && laRegisteredAt.is_string()) {
        // ISO timestamps sort lexically; compare the date part only so a
        // registration at any time on the cutoff day counts.
        const std::string reg = laRegisteredAt.get<std::string>();
        due = reg.size() >= 10 && reg.substr(0, 10) >= cutoffYmd;
    }
    w["due"] = due;
    row["welcome"] = std::move(w);
}

void WelcomeLog::attachToRoster(std::vector<json>& unassigned, json& buckets, bool youth) {
    auto targetOf = [youth](const json& row) -> long long {
        auto num = [&](const char* k) -> long long {
            auto it = row.find(k);
            return (it != row.end() && it->is_number_integer()) ? it->get<long long>() : 0;
        };
        if (youth) {
            const long long parent = num("parentPersonId");
            if (parent > 0) return parent;
        }
        return num("personId");
    };
    auto forEachRow = [&](auto&& fn) {
        for (auto& r : unassigned) fn(r);
        if (buckets.is_object()) {
            for (auto& kv : buckets.items()) {
                if (kv.value().is_array()) for (auto& r : kv.value()) fn(r);
            }
        } else if (buckets.is_array()) {
            for (auto& arr : buckets) {
                if (arr.is_array()) for (auto& r : arr) fn(r);
            }
        }
    };

    std::unordered_set<long long> seen;
    std::vector<long long> ids;
    forEachRow([&](json& r) {
        const long long t = targetOf(r);
        if (t > 0 && seen.insert(t).second) ids.push_back(t);
    });

    Map latest;
    std::string cutoff;
    try {
        latest = latestFor(ids);
        cutoff = policyCutoff(kLighthouseClubId);
    } catch (const std::exception& e) {
        std::cerr << "[WelcomeLog] roster attach load failed: " << e.what() << std::endl;
        forEachRow([&](json& r) { r["welcome"] = json(nullptr); });
        return;
    }
    forEachRow([&](json& r) {
        auto reg = r.find("laRegisteredAt");
        attach(r, targetOf(r), reg == r.end() ? json(nullptr) : *reg, latest, cutoff);
    });
}

json WelcomeLog::dueList(int clubId) {
    json out = json::array();
    const auto rows = db_->query(R"SQL(
        WITH cut AS (
            SELECT registered_on_or_after AS d FROM welcome_outreach_policies
             WHERE club_id = $1::int ORDER BY created_at DESC, id DESC LIMIT 1),
        reg AS (
            SELECT m.person_id, MIN(m.la_registered_at) AS reg_at,
                   string_agg(DISTINCT COALESCE(lp.program_name, lp.category), ' · ') AS programs,
                   (array_agg(lp.category ORDER BY m.la_registered_at DESC))[1] AS category
              FROM person_la_memberships m
              JOIN leagueapps_programs lp ON lp.program_id = m.la_program_id
              JOIN cut ON m.la_registered_at >= cut.d
             WHERE m.ended_at IS NULL
             GROUP BY m.person_id)
        SELECT p.id, COALESCE(p.first_name, '') AS first_name, COALESCE(p.last_name, '') AS last_name,
               CASE r.category WHEN 'men' THEN 'mens' WHEN 'women' THEN 'womens' ELSE r.category END AS section,
               TO_CHAR(r.reg_at AT TIME ZONE 'America/New_York', 'YYYY-MM-DD') AS registered_at,
               r.programs,
               COALESCE((SELECT jsonb_agg(jsonb_build_object(
                          'person_id',   x.recipient_person_id,
                          'name',        NULLIF(trim(COALESCE(rp.first_name, '') || ' ' || COALESCE(rp.last_name, '')), ''),
                          'phone',       fh_recipient_phone(x.recipient_person_id, p.id),
                          'email',       fh_recipient_email(x.recipient_person_id, p.id),
                          'is_guardian', x.is_guardian) ORDER BY x.ord)
                           FROM fh_message_recipients(p.id) x
                           JOIN persons rp ON rp.id = x.recipient_person_id), '[]'::jsonb)::text AS recipients
          FROM reg r
          JOIN persons p ON p.id = r.person_id
         WHERE NOT EXISTS (
                SELECT 1 FROM person_welcomes w
                 WHERE w.person_id = p.id OR w.player_person_id = p.id
                    OR w.person_id IN (SELECT y.recipient_person_id FROM fh_message_recipients(p.id) y))
         ORDER BY r.reg_at DESC, p.id
    )SQL", {std::to_string(clubId)});
    for (const auto& r : rows) {
        json recips = json::array();
        try { recips = json::parse(r["recipients"].c_str()); } catch (...) {}
        out.push_back({
            {"person_id",     r["id"].as<long long>()},
            {"first_name",    r["first_name"].c_str()},
            {"last_name",     r["last_name"].c_str()},
            {"section",       r["section"].is_null() ? "" : r["section"].c_str()},
            {"registered_at", r["registered_at"].is_null() ? "" : r["registered_at"].c_str()},
            {"programs",      r["programs"].is_null() ? "" : r["programs"].c_str()},
            {"recipients",    recips},
        });
    }
    return out;
}
