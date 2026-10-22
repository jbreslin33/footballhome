#include "Organization.h"
#include "Club.h"
#include "../database/Database.h"

Organization::Organization(Database* db, int id, std::string slug, std::string name)
    : db_(db), id_(id), slug_(std::move(slug)), name_(std::move(name)) {}

nlohmann::json Organization::publicPage() const {
    return {
        {"slug",  slug_},
        {"name",  name_},
        {"kind",  kind()},
        {"copy",  pageCopy()},
        {"links", pageLinks()},
    };
}

// {tier: body} for kind='org_page'; tokens are filled by the page
// (MessageCopy.fill) because the values ride in the same response.
nlohmann::json Organization::pageCopy() const {
    pqxx::result rows = db_->query(
        "SELECT tier, body FROM message_templates "
        " WHERE kind = 'org_page' AND is_active AND is_public "
        " ORDER BY sort_order, id");
    nlohmann::json copy = nlohmann::json::object();
    for (const auto& row : rows) {
        const std::string tier = row["tier"].c_str();
        if (!copy.contains(tier)) copy[tier] = row["body"].c_str();   // first row wins
    }
    return copy;
}

// {"join": [{label, url}], "more": [...]} from organization_page_links.
nlohmann::json Organization::pageLinks() const {
    pqxx::result rows = db_->query(
        "SELECT group_code, label, url FROM organization_page_links "
        " WHERE organization_id = $1::int ORDER BY group_code, sort_order, id",
        {std::to_string(id_)});
    nlohmann::json links = {{"join", nlohmann::json::array()}, {"more", nlohmann::json::array()}};
    for (const auto& row : rows) {
        links[row["group_code"].c_str()].push_back({{"label", row["label"].c_str()},
                                                    {"url",   row["url"].c_str()}});
    }
    return links;
}

std::unique_ptr<Organization> OrganizationRegistry::fromSlug(const std::string& slug) {
    Database* db = Database::getInstance();
    pqxx::result rows = db->query(R"(
        SELECT o.id, o.slug, o.name, c.id AS club_id
          FROM organizations o
          LEFT JOIN LATERAL (SELECT id FROM clubs
                              WHERE organization_id = o.id AND is_active
                              ORDER BY id LIMIT 1) c ON true
         WHERE o.slug = $1 AND o.is_active
    )", {slug});
    if (rows.empty()) return nullptr;
    const auto& row = rows[0];
    if (row["club_id"].is_null()) return nullptr;
    return std::make_unique<Club>(db, row["id"].as<int>(), row["slug"].c_str(),
                                  row["name"].c_str(), row["club_id"].as<int>());
}
