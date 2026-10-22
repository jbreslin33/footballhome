#include "Club.h"
#include "../database/Database.h"

Club::Club(Database* db, int organizationId, std::string slug, std::string name, int clubId)
    : Organization(db, organizationId, std::move(slug), std::move(name)), clubId_(clubId) {}

// Sections list the club's operating teams (is_active + board_sort_order,
// the rosters boards' rule).  A section with schedule_section_id plays on
// that section's teams — Girls on the Boys teams.  The club's founding
// year is its earliest section's.
nlohmann::json Club::publicPage() const {
    nlohmann::json page = Organization::publicPage();
    pqxx::result rows = db_->query(R"(
        WITH sections AS (
            SELECT cs.id, cs.name, cs.sort_order, cs.founded_year,
                   json_agg(json_build_object('name', t.name, 'label', t.label, 'division', d.name)
                            ORDER BY t.board_sort_order) AS teams
              FROM club_sections cs
              JOIN teams t ON t.club_section_id = COALESCE(cs.schedule_section_id, cs.id)
              LEFT JOIN divisions d ON d.id = t.division_id
             WHERE t.club_id = $1::int AND t.is_active AND t.board_sort_order IS NOT NULL
             GROUP BY cs.id)
        SELECT COALESCE(c.logo_url, '')       AS logo_url,
               COALESCE(c.outreach_email, '') AS email,
               (SELECT min(founded_year) FROM sections) AS founded_year,
               COALESCE((SELECT json_agg(json_build_object('name', name, 'founded_year', founded_year,
                                                           'teams', teams) ORDER BY sort_order)
                           FROM sections), '[]'::json)::text AS sections
          FROM clubs c
         WHERE c.id = $1::int
    )", {std::to_string(clubId_)});
    if (rows.empty()) return page;
    const auto& row = rows[0];
    page["logo_url"]      = row["logo_url"].c_str();
    page["contact_email"] = row["email"].c_str();
    page["founded_year"]  = row["founded_year"].is_null() ? nlohmann::json(nullptr)
                                                          : nlohmann::json(row["founded_year"].as<int>());
    page["sections"]      = nlohmann::json::parse(row["sections"].c_str());
    return page;
}
