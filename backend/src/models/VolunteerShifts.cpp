#include "VolunteerShifts.h"

#include "../database/Database.h"

using json = nlohmann::json;

namespace {
VolunteerShifts::Result fail(int status, const std::string& error) {
    VolunteerShifts::Result r; r.ok = false; r.status = status; r.error = error; return r;
}
}

json VolunteerShifts::mine(long long personId) {
    auto* db = Database::getInstance();
    const std::string pid = std::to_string(personId);
    json out = {{"offer", false}, {"shifts", json::array()}, {"pick", nullptr}};

    auto offer = db->query("SELECT fh_volunteer_offer($1::int) AS ok", {pid});
    out["offer"] = !offer.empty() && offer[0]["ok"].as<bool>();

    // The live pick (pending or approved) shows even once he is a
    // volunteer — his balance is $0 then, so the offer itself is off.
    auto pick = db->query(
        "SELECT r.id, r.shift_id, r.status, fh_volunteer_shift_label(r.shift_id) AS shift "
        "  FROM volunteer_requests r "
        " WHERE r.person_id = $1::int AND r.status IN ('pending', 'approved') "
        " ORDER BY r.id DESC LIMIT 1", {pid});
    if (!pick.empty())
        out["pick"] = {{"id", pick[0]["id"].as<long long>()}, {"shift_id", pick[0]["shift_id"].as<long long>()},
                       {"status", pick[0]["status"].c_str()}, {"shift", pick[0]["shift"].c_str()}};

    if (out["offer"].get<bool>() || !pick.empty()) {
        for (const auto& r : db->query(
                 "SELECT s.id, fh_volunteer_shift_label(s.id) AS label "
                 "  FROM volunteer_shifts s "
                 " WHERE s.is_active AND s.club_section_id IN (SELECT fh_volunteer_sections($1::int)) "
                 " ORDER BY s.weekday, s.starts_at, s.sort_order", {pid}))
            out["shifts"].push_back({{"id", r["id"].as<long long>()}, {"label", r["label"].c_str()}});
    }
    return out;
}

VolunteerShifts::Result VolunteerShifts::pick(long long personId, long long shiftId, bool agreed) {
    if (!agreed) return fail(400, "Tick that you understand the commitment first.");
    if (shiftId <= 0) return fail(400, "shift_id required");
    auto* db = Database::getInstance();
    const std::string pid = std::to_string(personId), sid = std::to_string(shiftId);
    auto ok = db->query(
        "SELECT fh_volunteer_offer($1::int) AS offer, "
        "       EXISTS (SELECT 1 FROM volunteer_shifts s WHERE s.id = $2::int AND s.is_active "
        "                 AND s.club_section_id IN (SELECT fh_volunteer_sections($1::int))) AS shift_ok, "
        "       EXISTS (SELECT 1 FROM volunteer_requests r WHERE r.person_id = $1::int AND r.status = 'approved') AS approved",
        {pid, sid});
    if (ok.empty() || !ok[0]["shift_ok"].as<bool>()) return fail(400, "That evening isn't one you can pick.");
    if (ok[0]["approved"].as<bool>()) return fail(409, "You're already a club volunteer — reply to the club to change your day.");
    if (!ok[0]["offer"].as<bool>()) return fail(409, "Volunteering is offered when dues are owed.");

    auto tx = db->beginTransaction();
    tx->exec_params("UPDATE volunteer_requests SET status = 'withdrawn', decided_at = now() "
                    " WHERE person_id = $1 AND status = 'pending'", personId);
    tx->exec_params("INSERT INTO volunteer_requests (person_id, shift_id, agreed_at) VALUES ($1, $2, now())",
                    personId, shiftId);
    db->commit(tx);
    Result r; r.body = mine(personId); return r;
}

VolunteerShifts::Result VolunteerShifts::withdraw(long long personId) {
    auto* db = Database::getInstance();
    db->query("UPDATE volunteer_requests SET status = 'withdrawn', decided_at = now() "
              " WHERE person_id = $1::int AND status = 'pending'", {std::to_string(personId)});
    Result r; r.body = mine(personId); return r;
}

json VolunteerShifts::pending() {
    json out = json::array();
    for (const auto& r : Database::getInstance()->query(R"SQL(
            SELECT r.id, r.person_id, TRIM(COALESCE(p.first_name,'') || ' ' || COALESCE(p.last_name,'')) AS name,
                   fh_volunteer_shift_label(r.shift_id) AS shift,
                   COALESCE(fh_dues_balance_usd(r.person_id), 0)::numeric(10,2)::text AS owed,
                   to_char(r.created_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"') AS created_at
              FROM volunteer_requests r
              JOIN persons p ON p.id = r.person_id
             WHERE r.status = 'pending'
             ORDER BY r.created_at)SQL")) {
        out.push_back({{"id", r["id"].as<long long>()}, {"person_id", r["person_id"].as<long long>()},
                       {"name", r["name"].c_str()}, {"shift", r["shift"].c_str()},
                       {"owed", std::atof(r["owed"].c_str())}, {"created_at", r["created_at"].c_str()}});
    }
    return out;
}

VolunteerShifts::Result VolunteerShifts::decide(long long requestId, const std::string& decision, long long userId) {
    if (requestId <= 0 || (decision != "approve" && decision != "deny"))
        return fail(400, "decision must be approve or deny");
    auto* db = Database::getInstance();
    auto tx = db->beginTransaction();
    auto d = tx->exec_params(
        "UPDATE volunteer_requests SET status = $2, decided_by_user_id = NULLIF($3, 0), decided_at = now() "
        " WHERE id = $1 AND status = 'pending' "
        " RETURNING person_id, fh_volunteer_shift_label(shift_id) AS shift",
        requestId, decision == "approve" ? "approved" : "denied", userId);
    if (d.empty()) { db->rollback(tx); return fail(409, "Already decided."); }
    if (decision == "approve") {
        // 🙋 Volunteer (mig 704): $0 balance, no notices, not an alternate.
        tx->exec_params(
            "INSERT INTO club_volunteers (person_id, helps_with) VALUES ($1, $2) "
            "ON CONFLICT (person_id) DO UPDATE SET helps_with = EXCLUDED.helps_with",
            d[0]["person_id"].as<long long>(), std::string("Volunteer shift: ") + d[0]["shift"].c_str());
    }
    db->commit(tx);
    Result r; r.body = {{"status", decision == "approve" ? "approved" : "denied"}}; return r;
}
