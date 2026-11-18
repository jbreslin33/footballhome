#include "VolunteerShifts.h"

#include <algorithm>
#include <cstdio>
#include <map>
#include <set>

#include "../database/Database.h"

using json = nlohmann::json;

namespace {
VolunteerShifts::Result fail(int status, const std::string& error) {
    VolunteerShifts::Result r; r.ok = false; r.status = status; r.error = error; return r;
}

// 120 → "2 hours", 135 → "2h 15m", 45 → "45 min".
std::string fmtMinutes(int m) {
    if (m <= 0) return "0 min";
    if (m < 60) return std::to_string(m) + " min";
    const int h = m / 60, r = m % 60;
    if (r == 0) return std::to_string(h) + (h == 1 ? " hour" : " hours");
    return std::to_string(h) + "h " + std::to_string(r) + "m";
}

std::string money(double d) {
    char buf[32];
    if (d == static_cast<long long>(d)) std::snprintf(buf, sizeof buf, "$%lld", static_cast<long long>(d));
    else std::snprintf(buf, sizeof buf, "$%.2f", d);
    return buf;
}

// "Mon 4:45–5:45 PM" for a slot.
const char* kSlotLabelSql =
    "to_char(DATE '2024-01-01' + (%1$s.isodow - 1), 'FMDy') || ' ' || "
    "fh_volunteer_hours_text(%1$s.starts_at, (%1$s.starts_at + make_interval(mins => %1$s.minutes))::time)";

std::string slotLabelSql(const std::string& alias) {
    char buf[512];
    std::snprintf(buf, sizeof buf, kSlotLabelSql, alias.c_str());
    return buf;
}
}  // namespace

// ── VolunteerLedger ────────────────────────────────────────────────────────

VolunteerLedger::Policy VolunteerLedger::policyFor(long long personId) {
    Policy p;
    auto r = Database::getInstance()->query(
        "SELECT pol.min_weekly_minutes, pol.told_ahead_misses_per_month, pol.review_after_months, "
        "       COALESCE((SELECT dp.monthly_dues_usd FROM dues_policies dp "
        "                  WHERE dp.club_id = pol.club_id "
        "                    AND (dp.club_section_id IS NULL OR dp.club_section_id = pol.club_section_id) "
        "                    AND dp.effective_from <= CURRENT_DATE "
        "                  ORDER BY (dp.club_section_id IS NOT NULL) DESC, dp.effective_from DESC LIMIT 1), 0) AS dues "
        "  FROM fh_volunteer_policy($1::int) pol WHERE pol.id IS NOT NULL",
        {std::to_string(personId)});
    if (!r.empty()) {
        p.minWeeklyMinutes  = r[0]["min_weekly_minutes"].as<int>();
        p.missesPerMonth    = r[0]["told_ahead_misses_per_month"].as<int>();
        p.reviewAfterMonths = r[0]["review_after_months"].as<int>();
        p.monthlyDues       = r[0]["dues"].as<double>();
    }
    return p;
}

json VolunteerLedger::months(long long requestId, const Policy& policy, int monthsWanted) {
    auto* db = Database::getInstance();
    // One row per Mon–Sun week from his approval to this week (or his end).
    auto rows = db->query(R"SQL(
        WITH r AS (SELECT decided_at, COALESCE(ended_at, now() + interval '8 days') AS until
                     FROM volunteer_requests WHERE id = $1::int AND decided_at IS NOT NULL),
        w AS (SELECT gs::date AS monday
                FROM r, generate_series(date_trunc('week', r.decided_at AT TIME ZONE 'America/New_York'),
                                        date_trunc('week', LEAST(r.until, now()) AT TIME ZONE 'America/New_York'),
                                        interval '1 week') gs),
        o AS (SELECT o.* FROM r, fh_volunteer_occurrences($1::int, r.decided_at, r.until) o)
        SELECT to_char(w.monday, 'YYYY-MM-DD') AS monday,
               to_char(w.monday, 'Mon FMDD')   AS label,
               to_char(w.monday, 'YYYY-MM')    AS month_key,
               to_char(w.monday, 'FMMonth')    AS month_name,
               COALESCE(sum(o.minutes), 0)::int                                   AS avail,
               COALESCE(sum(o.minutes) FILTER (WHERE o.attended), 0)::int         AS done,
               count(o.day) FILTER (WHERE o.first_start > now())                  AS upcoming,
               count(o.day) FILTER (WHERE o.first_start <= now() AND NOT COALESCE(o.attended, false)
                                      AND NOT COALESCE(o.told_ahead, false) AND NOT COALESCE(o.marked, false)) AS unmarked,
               count(o.day) FILTER (WHERE o.first_start <= now() AND NOT COALESCE(o.attended, false)
                                      AND NOT COALESCE(o.told_ahead, false) AND COALESCE(o.absent, false)) AS noshow,
               count(o.day) FILTER (WHERE NOT COALESCE(o.attended, false) AND COALESCE(o.told_ahead, false)) AS told
          FROM w LEFT JOIN o ON o.day >= w.monday AND o.day < w.monday + 7
         GROUP BY w.monday
         ORDER BY w.monday
    )SQL", {std::to_string(requestId)});

    struct Month { std::string key, name; json weeks = json::array(); int misses = 0, noshows = 0, open = 0, unmarked = 0, counted = 0; };
    std::vector<Month> list;
    for (const auto& r : rows) {
        const std::string key = r["month_key"].c_str();
        if (list.empty() || list.back().key != key) { Month m; m.key = key; m.name = r["month_name"].c_str(); list.push_back(std::move(m)); }
        Month& m = list.back();
        const int avail = r["avail"].as<int>(), done = r["done"].as<int>();
        const int need = std::min(policy.minWeeklyMinutes, avail);
        std::string st;
        if (avail == 0)                         st = "off";
        else if (done >= need)                  st = "met";
        else if (r["upcoming"].as<int>() > 0)   st = "coming";
        else if (r["noshow"].as<int>() > 0)     st = "noshow";
        else if (r["unmarked"].as<int>() > 0)   st = "unmarked";
        else if (r["told"].as<int>() > 0)       st = "told";
        else                                    st = "short";
        if (st != "off") m.counted++;
        if (st == "told" || st == "short") m.misses++;
        if (st == "noshow") m.noshows++;
        if (st == "coming") m.open++;
        if (st == "unmarked") m.unmarked++;
        m.weeks.push_back({{"monday", r["monday"].c_str()}, {"date", r["label"].c_str()}, {"status", st},
                           {"done", fmtMinutes(done)}, {"need", fmtMinutes(need)}});
    }

    json out = json::array();
    int missStreak = 0;   // months running (oldest → newest) that used a miss
    std::vector<int> streakAt(list.size(), 0);
    for (size_t i = 0; i < list.size(); ++i) {
        missStreak = list[i].misses > 0 ? missStreak + 1 : 0;
        streakAt[i] = missStreak;
    }
    for (size_t k = list.size(); k-- > 0 && static_cast<int>(out.size()) < monthsWanted;) {
        const Month& m = list[k];
        std::string st, why;
        json flags = json::array();
        if (m.noshows > 0) { st = "billed"; why = "noshow"; flags.push_back({{"kind", "noshow"}}); }
        else if (m.misses > policy.missesPerMonth) { st = "billed"; why = "misses"; }
        else if (m.unmarked > 0) st = "pending";
        else if (m.open > 0) st = "open";
        else if (m.counted > 0) st = "waived";
        else st = "none";
        if (streakAt[k] >= policy.reviewAfterMonths) flags.push_back({{"kind", "pattern"}, {"n", streakAt[k]}});
        out.push_back({{"month", m.key}, {"name", m.name}, {"status", st}, {"why", why}, {"misses", m.misses},
                       {"dues", money(policy.monthlyDues)}, {"weeks", m.weeks}, {"flags", flags}});
    }
    return out;
}

// ── VolunteerShifts ────────────────────────────────────────────────────────

json VolunteerShifts::pickSlots(long long requestId) {
    json slots = json::array();
    int total = 0;
    std::string label;
    for (const auto& r : Database::getInstance()->query(
             "SELECT s.isodow, to_char(s.starts_at, 'HH24:MI') AS starts_at, s.minutes, COALESCE(s.teams, '') AS teams, "
             + slotLabelSql("s") + " AS label "
             "  FROM volunteer_request_slots s WHERE s.request_id = $1::int ORDER BY s.isodow, s.starts_at",
             {std::to_string(requestId)})) {
        slots.push_back({{"isodow", r["isodow"].as<int>()}, {"starts_at", r["starts_at"].c_str()},
                         {"minutes", r["minutes"].as<int>()}, {"teams", r["teams"].c_str()}, {"label", r["label"].c_str()}});
        total += r["minutes"].as<int>();
        if (!label.empty()) label += ", ";
        label += r["label"].c_str();
    }
    return {{"slots", slots}, {"total_minutes", total}, {"total", fmtMinutes(total)}, {"label", label}};
}

json VolunteerShifts::mine(long long personId) {
    auto* db = Database::getInstance();
    const std::string pid = std::to_string(personId);
    const VolunteerLedger::Policy pol = VolunteerLedger::policyFor(personId);
    json out = {{"offer", false}, {"slots", json::array()}, {"pick", nullptr},
                {"policy", {{"min_minutes", pol.minWeeklyMinutes}, {"min", fmtMinutes(pol.minWeeklyMinutes)},
                            {"dues", money(pol.monthlyDues)}, {"misses_per_month", pol.missesPerMonth}}}};

    auto offer = db->query("SELECT fh_volunteer_offer($1::int) AS ok", {pid});
    out["offer"] = !offer.empty() && offer[0]["ok"].as<bool>();

    auto pick = db->query(
        "SELECT r.id, r.status, r.shift_id, fh_volunteer_shift_label(r.shift_id) AS shift "
        "  FROM volunteer_requests r "
        " WHERE r.person_id = $1::int AND r.status IN ('pending', 'approved') "
        " ORDER BY r.id DESC LIMIT 1", {pid});
    if (!pick.empty()) {
        const long long rid = pick[0]["id"].as<long long>();
        json p = pickSlots(rid);
        p["id"] = rid;
        p["status"] = pick[0]["status"].c_str();
        // An old one-evening pick (mig 1222) has no slots — its label stands in.
        if (p["slots"].empty() && !pick[0]["shift"].is_null()) p["label"] = pick[0]["shift"].c_str();
        p["shift"] = p["label"];
        if (p["status"] == "approved") p["ledger"] = VolunteerLedger::months(rid, pol, 2);
        out["pick"] = p;
    }

    if (out["offer"].get<bool>() || !pick.empty()) {
        for (const auto& r : db->query(
                 "SELECT o.helps_section_id, o.isodow, to_char(o.starts_at, 'HH24:MI') AS starts_at, o.minutes, "
                 "       COALESCE(o.teams, '') AS teams, " + slotLabelSql("o") + " AS label, "
                 "       to_char(DATE '2024-01-01' + (o.isodow - 1), 'FMDay') AS day "
                 "  FROM fh_volunteer_slot_options($1::int) o", {pid}))
            out["slots"].push_back({{"isodow", r["isodow"].as<int>()}, {"starts_at", r["starts_at"].c_str()},
                                    {"minutes", r["minutes"].as<int>()}, {"teams", r["teams"].c_str()},
                                    {"label", r["label"].c_str()}, {"day", r["day"].c_str()}});
    }
    return out;
}

VolunteerShifts::Result VolunteerShifts::pick(long long personId, const json& slots, bool agreed) {
    if (!agreed) return fail(400, "Tick that you understand the commitment first.");
    if (!slots.is_array() || slots.empty()) return fail(400, "Pick at least one slot.");
    auto* db = Database::getInstance();
    const std::string pid = std::to_string(personId);
    auto ok = db->query(
        "SELECT fh_volunteer_offer($1::int) AS offer, "
        "       EXISTS (SELECT 1 FROM volunteer_requests r WHERE r.person_id = $1::int AND r.status = 'approved') AS approved",
        {pid});
    if (ok[0]["approved"].as<bool>()) return fail(409, "You're already a club volunteer — reply to the club to change your slots.");
    if (!ok[0]["offer"].as<bool>()) return fail(409, "Volunteering is offered when dues are owed.");

    // Every pick must be a slot on offer; the total must reach the minimum.
    std::map<std::pair<int, std::string>, std::pair<int, std::string>> offered;   // (dow, "HH:MM") → (minutes, teams)
    long long helps = 0;
    for (const auto& r : db->query(
             "SELECT helps_section_id, isodow, to_char(starts_at, 'HH24:MI') AS st, minutes, COALESCE(teams, '') AS teams "
             "  FROM fh_volunteer_slot_options($1::int)", {pid})) {
        offered[{r["isodow"].as<int>(), r["st"].c_str()}] = {r["minutes"].as<int>(), r["teams"].c_str()};
        helps = r["helps_section_id"].as<long long>();
    }
    std::set<std::pair<int, std::string>> chosen;
    int total = 0;
    for (const auto& s : slots) {
        if (!s.is_object() || !s.contains("isodow") || !s.contains("starts_at")) return fail(400, "Bad slot.");
        const auto key = std::make_pair(s["isodow"].get<int>(), s["starts_at"].get<std::string>());
        auto it = offered.find(key);
        if (it == offered.end()) return fail(400, "One of those slots isn't on the calendar any more — refresh and pick again.");
        if (chosen.insert(key).second) total += it->second.first;
    }
    const VolunteerLedger::Policy pol = VolunteerLedger::policyFor(personId);
    if (total < pol.minWeeklyMinutes) return fail(400, "Pick at least " + fmtMinutes(pol.minWeeklyMinutes) + " a week.");

    auto tx = db->beginTransaction();
    tx->exec_params("UPDATE volunteer_requests SET status = 'withdrawn', decided_at = now() "
                    " WHERE person_id = $1 AND status = 'pending'", personId);
    auto ins = tx->exec_params("INSERT INTO volunteer_requests (person_id, agreed_at, helps_section_id) VALUES ($1, now(), $2) RETURNING id",
                               personId, helps);
    const long long rid = ins[0]["id"].as<long long>();
    for (const auto& k : chosen) {
        const auto& v = offered[k];
        tx->exec_params("INSERT INTO volunteer_request_slots (request_id, isodow, starts_at, minutes, teams) VALUES ($1, $2, $3::time, $4, $5)",
                        rid, k.first, k.second, v.first, v.second);
    }
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
        const long long rid = r["id"].as<long long>();
        json s = pickSlots(rid);
        const std::string label = s["slots"].empty() ? std::string(r["shift"].is_null() ? "" : r["shift"].c_str())
                                                     : s["label"].get<std::string>();
        out.push_back({{"id", rid}, {"person_id", r["person_id"].as<long long>()},
                       {"name", r["name"].c_str()}, {"shift", label}, {"total", s["total"]},
                       {"owed", std::atof(r["owed"].c_str())}, {"created_at", r["created_at"].c_str()}});
    }
    return out;
}

json VolunteerShifts::ledger() {
    json out = json::array();
    for (const auto& r : Database::getInstance()->query(R"SQL(
            SELECT r.id, r.person_id, TRIM(COALESCE(p.first_name,'') || ' ' || COALESCE(p.last_name,'')) AS name,
                   COALESCE(fh_dues_balance_usd(r.person_id), 0)::numeric(10,2)::text AS owed
              FROM volunteer_requests r
              JOIN persons p ON p.id = r.person_id
             WHERE r.status = 'approved'
             ORDER BY p.last_name, p.first_name)SQL")) {
        const long long rid = r["id"].as<long long>(), pid = r["person_id"].as<long long>();
        const VolunteerLedger::Policy pol = VolunteerLedger::policyFor(pid);
        json s = pickSlots(rid);
        out.push_back({{"id", rid}, {"person_id", pid}, {"name", r["name"].c_str()},
                       {"shift", s["label"]}, {"total", s["total"]}, {"owed", std::atof(r["owed"].c_str())},
                       {"months", VolunteerLedger::months(rid, pol, std::max(2, pol.reviewAfterMonths))}});
    }
    return out;
}

// 📋 His slots on his calendar: assistant coach on the helped section's
// teams, a practices-only schedule of his days AND slots (mig 1461) — he
// sees only the practices starting on his slots.  A coach who already
// coaches there keeps what he had (every practice, or his own days).
void VolunteerShifts::assignCoachSlots(pqxx::work& tx, long long personId, long long requestId) {
    auto req = tx.exec_params("SELECT helps_section_id FROM volunteer_requests WHERE id = $1", requestId);
    if (req.empty() || req[0][0].is_null()) return;
    const long long sectionId = req[0][0].as<long long>();
    auto coach = tx.exec_params(
        "INSERT INTO coaches (person_id) VALUES ($1) ON CONFLICT (person_id) DO UPDATE SET person_id = EXCLUDED.person_id "
        "RETURNING id", personId);
    const long long coachId = coach[0]["id"].as<long long>();
    auto had = tx.exec_params(
        "SELECT EXISTS (SELECT 1 FROM team_coaches tc JOIN teams t ON t.id = tc.team_id "
        "                WHERE tc.coach_id = $1 AND tc.ended_at IS NULL AND t.club_section_id = $2) AS coaching, "
        "       EXISTS (SELECT 1 FROM coach_schedules s WHERE s.coach_id = $1 AND s.club_section_id = $2) AS scheduled",
        coachId, sectionId);
    const bool coaching = had[0]["coaching"].as<bool>(), scheduled = had[0]["scheduled"].as<bool>();
    tx.exec_params(
        "INSERT INTO team_coaches (team_id, coach_id, coach_role_id) "
        "SELECT t.id, $1, (SELECT id FROM coach_roles WHERE name = 'assistant') "
        "  FROM teams t "
        " WHERE t.is_active AND t.club_section_id = $2 "
        "   AND NOT EXISTS (SELECT 1 FROM team_coaches tc WHERE tc.team_id = t.id AND tc.coach_id = $1 AND tc.ended_at IS NULL)",
        coachId, sectionId);
    if (coaching && !scheduled) return;   // every practice already (mig 955)
    auto sched = tx.exec_params(
        "INSERT INTO coach_schedules (coach_id, club_section_id, practices_only) VALUES ($1, $2, true) "
        "ON CONFLICT (coach_id, club_section_id) DO UPDATE SET coach_id = EXCLUDED.coach_id RETURNING id",
        coachId, sectionId);
    const long long schedId = sched[0]["id"].as<long long>();
    tx.exec_params(
        "INSERT INTO coach_schedule_days (coach_schedule_id, isodow) "
        "SELECT DISTINCT $1::int, s.isodow FROM volunteer_request_slots s WHERE s.request_id = $2 ON CONFLICT DO NOTHING",
        schedId, requestId);
    // Slots only on a schedule that is his volunteering alone — a real
    // coach's own days must not shrink to his slots.
    if (!scheduled)
        tx.exec_params(
            "INSERT INTO coach_schedule_slots (coach_schedule_id, isodow, starts_at) "
            "SELECT $1::int, s.isodow, s.starts_at FROM volunteer_request_slots s WHERE s.request_id = $2 ON CONFLICT DO NOTHING",
            schedId, requestId);
}

// 🛑 End: a volunteering-only schedule (it has slot rows) and its team rows go.
void VolunteerShifts::removeCoachSlots(pqxx::work& tx, long long personId, long long requestId) {
    auto req = tx.exec_params("SELECT helps_section_id FROM volunteer_requests WHERE id = $1", requestId);
    if (req.empty() || req[0][0].is_null()) return;
    const long long sectionId = req[0][0].as<long long>();
    auto sched = tx.exec_params(
        "SELECT s.id, s.coach_id FROM coach_schedules s JOIN coaches c ON c.id = s.coach_id "
        " WHERE c.person_id = $1 AND s.club_section_id = $2 "
        "   AND EXISTS (SELECT 1 FROM coach_schedule_slots x WHERE x.coach_schedule_id = s.id)",
        personId, sectionId);
    if (sched.empty()) return;
    const long long coachId = sched[0]["coach_id"].as<long long>();
    tx.exec_params(
        "UPDATE team_coaches tc SET ended_at = now() FROM teams t "
        " WHERE t.id = tc.team_id AND tc.coach_id = $1 AND tc.ended_at IS NULL AND t.club_section_id = $2",
        coachId, sectionId);
    tx.exec_params("DELETE FROM coach_schedules WHERE id = $1", sched[0]["id"].as<long long>());
}

VolunteerShifts::Result VolunteerShifts::decide(long long requestId, const std::string& decision, long long userId) {
    if (requestId <= 0 || (decision != "approve" && decision != "deny" && decision != "end"))
        return fail(400, "decision must be approve, deny or end");
    auto* db = Database::getInstance();
    auto tx = db->beginTransaction();
    if (decision == "end") {
        auto d = tx->exec_params(
            "UPDATE volunteer_requests SET status = 'ended', ended_at = now() "
            " WHERE id = $1 AND status = 'approved' RETURNING person_id", requestId);
        if (d.empty()) { db->rollback(tx); return fail(409, "Not an active volunteer."); }
        removeCoachSlots(*tx, d[0]["person_id"].as<long long>(), requestId);
        db->commit(tx);
        Result r; r.body = {{"status", "ended"}}; return r;
    }
    auto d = tx->exec_params(
        "UPDATE volunteer_requests SET status = $2, decided_by_user_id = NULLIF($3, 0), decided_at = now() "
        " WHERE id = $1 AND status = 'pending' "
        " RETURNING person_id, shift_id",
        requestId, decision == "approve" ? "approved" : "denied", userId);
    if (d.empty()) { db->rollback(tx); return fail(409, "Already decided."); }
    // Approve (mig 1461): coach for his slots.  No club_volunteers row — his
    // back balance stays owed; SQL keeps him eligible while approved.
    if (decision == "approve") assignCoachSlots(*tx, d[0]["person_id"].as<long long>(), requestId);
    db->commit(tx);
    Result r; r.body = {{"status", decision == "approve" ? "approved" : "denied"}}; return r;
}
