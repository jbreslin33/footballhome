#include "Proposals.h"

#include "../database/Database.h"

using json = nlohmann::json;

namespace {
const char* kSelect =
    "SELECT p.id, p.code, p.icon, p.title, p.summary, p.as_of::text AS as_of, "
    "       COALESCE(p.screen, '') AS screen, "
    "       s.code AS status_code, s.label AS status_label, s.icon AS status_icon, "
    "       (SELECT count(*) FROM proposal_sections ps WHERE ps.proposal_id = p.id) AS sections "
    "  FROM proposals p JOIN proposal_statuses s ON s.code = p.status_code "
    " WHERE p.is_active ";

json row(const pqxx::row& r) {
    return {
        {"code", r["code"].c_str()}, {"icon", r["icon"].c_str()},
        {"title", r["title"].c_str()}, {"summary", r["summary"].c_str()},
        {"asOf", r["as_of"].c_str()}, {"screen", r["screen"].c_str()},
        {"status", {{"code", r["status_code"].c_str()}, {"label", r["status_label"].c_str()},
                    {"icon", r["status_icon"].c_str()}}},
        {"sections", r["sections"].as<int>()},
    };
}
}

json Proposals::list() {
    json out = json::array();
    for (const auto& r : Database::getInstance()->query(
            std::string(kSelect) + " ORDER BY p.sort_order, p.as_of DESC, p.code")) {
        out.push_back(row(r));
    }
    return out;
}

json Proposals::one(const std::string& code) {
    auto* db = Database::getInstance();
    auto found = db->query(std::string(kSelect) + " AND p.code = $1", {code});
    if (found.empty()) return nullptr;
    json out = row(found[0]);
    json sections = json::array();
    for (const auto& r : db->query(
            "SELECT heading, body FROM proposal_sections WHERE proposal_id = $1::int ORDER BY sort_order",
            {found[0]["id"].c_str()})) {
        sections.push_back({{"heading", r["heading"].c_str()}, {"body", r["body"].c_str()}});
    }
    out["sections"] = sections;
    return out;
}
