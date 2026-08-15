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

std::vector<MensTeamColumns::Column> MensTeamColumns::loadAll(bool includeInactive) {
    std::vector<Column> out;
    // Board columns live directly on teams since migration 250 folded
    // roster_columns in (label/short_label/color/board_sort_order/
    // mutex_group/max_roster/board_archived_at).  The old `domain`
    // filter is now teams.gender_category — one less thing to forget
    // in a migration. Activity gate is teams.is_active (migration
    // 262) — board_archived_at is presentation-only now, not the
    // "does this team operate" signal. includeInactive drops that gate
    // for the Teams screen's Active/Inactive pill.
    const std::string sql =
        "SELECT t.id, t.id AS team_id, COALESCE(t.label, t.name) AS label, "
        "       t.short_label, t.board_sort_order AS sort_order, "
        "       t.color, t.mutex_group, t.max_roster "
        "  FROM teams t "
        " WHERE t.gender_category = $1 "
        "   AND t.board_sort_order IS NOT NULL " +
        std::string(includeInactive ? "" : "   AND t.is_active = true ") +
        " ORDER BY t.board_sort_order";
    const auto rows = db_->query(sql, {domain_});
    out.reserve(rows.size());
    for (const auto& row : rows) out.push_back(rowToColumn(row));
    return out;
}

std::optional<MensTeamColumns::Column> MensTeamColumns::findByTeamId(int teamId) {
    const auto rows = db_->query(
        "SELECT t.id, t.id AS team_id, COALESCE(t.label, t.name) AS label, "
        "       t.short_label, t.board_sort_order AS sort_order, "
        "       t.color, t.mutex_group, t.max_roster "
        "  FROM teams t "
        " WHERE t.gender_category = $1 "
        "   AND t.id = $2 "
        "   AND t.board_sort_order IS NOT NULL "
        "   AND t.is_active = true",
        {domain_, std::to_string(teamId)}
    );
    if (rows.empty()) return std::nullopt;
    return rowToColumn(rows[0]);
}
