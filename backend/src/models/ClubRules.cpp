#include "ClubRules.h"

#include <map>
#include <string>

#include "../database/Database.h"

using json = nlohmann::json;

json ClubRules::forPerson(int personId, bool everything) {
    auto* db = Database::getInstance();
    const std::string pid = std::to_string(personId);
    const std::string all = everything ? "true" : "false";

    // Every active rule, grouped into its layer key.
    std::map<std::string, json> rulesByKey;
    for (const auto& r : db->query(
            "SELECT id, scope, club_section_id, team_id, title, body "
            "  FROM club_rules WHERE is_active ORDER BY sort_order, id")) {
        const std::string scope = r["scope"].c_str();
        std::string key = "club";
        if (scope == "section") key = "section-" + std::string(r["club_section_id"].c_str());
        if (scope == "team")    key = "team-" + std::string(r["team_id"].c_str());
        rulesByKey[key].push_back({{"id", r["id"].as<int>()},
                                   {"title", r["title"].c_str()},
                                   {"body", r["body"].c_str()}});
    }
    auto rulesFor = [&](const std::string& key) {
        auto it = rulesByKey.find(key);
        return it == rulesByKey.end() ? json::array() : it->second;
    };

    json out = {{"layers", json::array()}};
    out["layers"].push_back({{"scope", "club"}, {"key", "club"}, {"rules", rulesFor("club")}});

    // The person's teams: played on, coached, or a parent of someone on.
    const std::string myTeams =
        "SELECT tp.team_id FROM team_persons tp WHERE tp.person_id = $1::int AND tp.removed_at IS NULL "
        "UNION SELECT tc.team_id FROM team_coaches tc JOIN coaches c ON c.id = tc.coach_id "
        "       WHERE c.person_id = $1::int AND tc.ended_at IS NULL "
        "UNION SELECT tp.team_id FROM person_guardians g JOIN team_persons tp ON tp.person_id = g.child_person_id "
        "       WHERE g.guardian_person_id = $1::int AND tp.removed_at IS NULL";

    for (const auto& r : db->query(
            "SELECT s.id, s.code, s.invoice_label FROM club_sections s "
            " WHERE $2::boolean OR s.id IN (SELECT t.club_section_id FROM teams t "
            "       WHERE t.is_active AND t.id IN (" + myTeams + ")) "
            " ORDER BY s.sort_order, s.id",
            {pid, all})) {
        const std::string key = "section-" + std::string(r["id"].c_str());
        out["layers"].push_back({{"scope", "section"}, {"key", key},
                                 {"sectionCode", r["code"].c_str()},
                                 {"label", r["invoice_label"].is_null() ? json(nullptr) : json(r["invoice_label"].c_str())},
                                 {"rules", rulesFor(key)}});
    }

    // Teams only when they have rules of their own (no empty pills).
    for (const auto& r : db->query(
            "SELECT t.id, COALESCE(t.label, t.name) AS label FROM teams t "
            " WHERE t.is_active AND EXISTS (SELECT 1 FROM club_rules cr WHERE cr.is_active AND cr.team_id = t.id) "
            "   AND ($2::boolean OR t.id IN (" + myTeams + ")) "
            " ORDER BY t.club_section_id NULLS LAST, t.board_sort_order NULLS LAST, t.name",
            {pid, all})) {
        const std::string key = "team-" + std::string(r["id"].c_str());
        out["layers"].push_back({{"scope", "team"}, {"key", key}, {"teamId", r["id"].as<int>()},
                                 {"label", r["label"].c_str()}, {"rules", rulesFor(key)}});
    }
    return out;
}
