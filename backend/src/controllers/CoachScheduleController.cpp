#include "CoachScheduleController.h"

#include <iostream>
#include <map>
#include <set>

#include "../database/Database.h"
#include "../third_party/json.hpp"

using nlohmann::json;

namespace {

Response jsonOut(HttpStatus s, const json& body) {
    Response r(s, body.dump());
    r.setHeader("Content-Type", "application/json; charset=utf-8");
    return r;
}
Response jsonError(HttpStatus s, const std::string& message) { return jsonOut(s, {{"error", message}}); }

}  // namespace

void CoachScheduleController::registerRoutes(Router& router, const std::string& prefix) {
    router.get (prefix, [this](const Request& r) { return handleGet(r); });
    router.post(prefix, [this](const Request& r) { return handleSave(r); });
}

bool CoachScheduleController::gate(const Request& request, Response* error) {
    if (!requireBearer(request)) {
        *error = jsonError(HttpStatus::UNAUTHORIZED, "Unauthorized");
        return false;
    }
    if (!Database::getInstance()->query("SELECT 1 FROM admins WHERE user_id = $1::int LIMIT 1",
                                        {std::to_string(bearerUserId(request))}).empty())
        return true;
    // 403, not 401: a signed-in non-admin keeps their session.
    *error = jsonError(HttpStatus::FORBIDDEN, "The coach schedule is for club admins.");
    return false;
}

Response CoachScheduleController::handleGet(const Request& request) {
    Response denied(HttpStatus::FORBIDDEN, "");
    if (!gate(request, &denied)) return denied;
    try {
        auto rows = Database::getInstance()->query(R"SQL(
            SELECT cs.id AS section_id, cs.name AS section_name,
                   c.id AS coach_id,
                   BTRIM(COALESCE(p.first_name, '') || ' ' || COALESCE(p.last_name, '')) AS name,
                   CASE WHEN s.id IS NULL THEN '{1,2,3,4,5,6,7}'
                        ELSE COALESCE((SELECT array_agg(d.isodow ORDER BY d.isodow)
                                         FROM coach_schedule_days d WHERE d.coach_schedule_id = s.id), '{}')
                   END::text AS days
              FROM (SELECT DISTINCT tc.coach_id, t.club_section_id
                      FROM team_coaches tc JOIN teams t ON t.id = tc.team_id
                     WHERE tc.ended_at IS NULL AND t.is_active) x
              JOIN club_sections cs ON cs.id = x.club_section_id
              JOIN coaches c ON c.id = x.coach_id
              JOIN persons p ON p.id = c.person_id
              LEFT JOIN coach_schedules s ON s.coach_id = c.id AND s.club_section_id = cs.id
             ORDER BY cs.id, p.first_name, p.last_name)SQL");
        json sections = json::array();
        for (const auto& r : rows) {
            const int sectionId = r["section_id"].as<int>();
            if (sections.empty() || sections.back()["id"].get<int>() != sectionId)
                sections.push_back({{"id", sectionId}, {"name", r["section_name"].c_str()}, {"coaches", json::array()}});
            std::string text = r["days"].c_str();   // "{1,5}"
            json days = json::array();
            for (char ch : text) if (ch >= '1' && ch <= '7') days.push_back(ch - '0');
            sections.back()["coaches"].push_back({
                {"coach_id", r["coach_id"].as<int>()}, {"name", r["name"].c_str()}, {"days", days}});
        }
        return jsonOut(HttpStatus::OK, {{"sections", sections}});
    } catch (const std::exception& e) {
        std::cerr << "CoachScheduleController::handleGet: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not load the coach schedule");
    }
}

Response CoachScheduleController::handleSave(const Request& request) {
    Response denied(HttpStatus::FORBIDDEN, "");
    if (!gate(request, &denied)) return denied;
    long long coachId = 0, sectionId = 0;
    std::set<int> days;
    try {
        const json body = json::parse(request.getBody());
        coachId   = body.value("coach_id", 0LL);
        sectionId = body.value("club_section_id", 0LL);
        for (const auto& v : body.at("days")) {
            const int d = v.get<int>();
            if (d < 1 || d > 7) return jsonError(HttpStatus::BAD_REQUEST, "days must be 1 to 7");
            days.insert(d);
        }
    } catch (const std::exception&) {
        return jsonError(HttpStatus::BAD_REQUEST, "coach_id, club_section_id and days are required");
    }
    if (coachId <= 0 || sectionId <= 0) return jsonError(HttpStatus::BAD_REQUEST, "coach_id and club_section_id are required");
    try {
        std::string list = "{";
        for (int d : days) list += (list.size() > 1 ? "," : "") + std::to_string(d);
        list += "}";
        auto* db = Database::getInstance();
        // One statement: the schedule row and its days change together.
        auto saved = db->query(R"SQL(
            WITH coach AS (
              SELECT DISTINCT tc.coach_id, t.club_section_id
                FROM team_coaches tc JOIN teams t ON t.id = tc.team_id
               WHERE tc.coach_id = $1::int AND t.club_section_id = $2::int AND tc.ended_at IS NULL
            ), up AS (
              INSERT INTO coach_schedules (coach_id, club_section_id)
              SELECT coach_id, club_section_id FROM coach
              ON CONFLICT (coach_id, club_section_id) DO UPDATE SET coach_id = EXCLUDED.coach_id
              RETURNING id
            ), gone AS (
              DELETE FROM coach_schedule_days d USING up
               WHERE d.coach_schedule_id = up.id AND NOT d.isodow = ANY($3::smallint[])
            ), added AS (
              INSERT INTO coach_schedule_days (coach_schedule_id, isodow)
              SELECT up.id, x FROM up, unnest($3::smallint[]) AS x
              ON CONFLICT DO NOTHING
            )
            SELECT id FROM up)SQL", {std::to_string(coachId), std::to_string(sectionId), list});
        if (saved.empty()) return jsonError(HttpStatus::NOT_FOUND, "That coach is not on a team in that section.");
        json out = json::array();
        for (int d : days) out.push_back(d);
        return jsonOut(HttpStatus::OK, {{"days", out}});
    } catch (const std::exception& e) {
        std::cerr << "CoachScheduleController::handleSave: " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not save the coach schedule");
    }
}
