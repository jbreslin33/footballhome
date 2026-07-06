#include "MensTeamColumns.h"

#include <utility>

#include "../database/Database.h"

namespace {

MensTeamColumns::Column rowToColumn(const pqxx::row& row) {
    MensTeamColumns::Column c;
    c.teamId       = row["team_id"].is_null()    ? 0 : row["team_id"].as<int>();
    c.label        = row["label"].is_null()      ? std::string{} : row["label"].c_str();
    c.shortLabel   = row["short_label"].is_null() ? c.label : std::string(row["short_label"].c_str());
    if (c.shortLabel.empty()) c.shortLabel = c.label;
    c.sortOrder    = row["sort_order"].is_null() ? 0 : row["sort_order"].as<int>();
    c.color        = row["color"].is_null()      ? std::string{} : row["color"].c_str();
    c.mutexGroup   = row["mutex_group"].is_null() ? std::string{} : row["mutex_group"].c_str();
    c.hasMaxRoster = !row["max_roster"].is_null();
    c.maxRoster    = c.hasMaxRoster ? row["max_roster"].as<int>() : 0;
    return c;
}

} // namespace

MensTeamColumns::MensTeamColumns(std::string domain)
    : db_(Database::getInstance()),
      domain_(std::move(domain)) {}

std::vector<MensTeamColumns::Column> MensTeamColumns::loadAll() {
    std::vector<Column> out;
    // roster_columns (renamed from mens_team_columns in migration 092) is
    // shared across roster domains via the `domain` column; this model
    // filters by domain_ (default 'mens') so each caller sees only its
    // own scoped view.
    const auto rows = db_->query(
        "SELECT c.id, c.team_id, COALESCE(c.label, t.name) AS label, c.short_label, "
        "       c.sort_order, c.color, c.mutex_group, c.max_roster "
        "  FROM roster_columns c "
        "  JOIN teams t ON t.id = c.team_id "
        " WHERE c.domain = $1 "
        "   AND c.archived_at IS NULL "
        " ORDER BY c.sort_order",
        {domain_}
    );
    out.reserve(rows.size());
    for (const auto& row : rows) out.push_back(rowToColumn(row));
    return out;
}

std::optional<MensTeamColumns::Column> MensTeamColumns::findByTeamId(int teamId) {
    const auto rows = db_->query(
        "SELECT c.id, c.team_id, COALESCE(c.label, t.name) AS label, c.short_label, "
        "       c.sort_order, c.color, c.mutex_group, c.max_roster "
        "  FROM roster_columns c "
        "  JOIN teams t ON t.id = c.team_id "
        " WHERE c.domain = $1 "
        "   AND c.team_id = $2 "
        "   AND c.archived_at IS NULL",
        {domain_, std::to_string(teamId)}
    );
    if (rows.empty()) return std::nullopt;
    return rowToColumn(rows[0]);
}
