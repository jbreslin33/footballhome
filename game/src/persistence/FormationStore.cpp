// game/src/persistence/FormationStore.cpp

#include "persistence/FormationStore.hpp"

#include <pqxx/pqxx>

#include <cstdio>

namespace fh::game::persistence {

using math::Fixed64;
using math::Vec2;

ai::FormationSpec::Pos mapClubPosition(int club_x, int club_y,
                                       bool is_keeper) {
    // See the header for the mapping derivation. fromFraction keeps the
    // conversion exact (integers over 100 / 50).
    ai::FormationSpec::Pos p;
    p.base = Vec2{Fixed64::fromFraction(club_y - 100, 100),
                  Fixed64::fromFraction(club_x - 50, 50)};
    p.keeper = is_keeper;
    return p;
}

std::optional<ai::FormationSpec> loadFormation(const DbConfig& cfg,
                                               const std::string& code) {
    try {
        const std::string conn_str =
            "host=" + cfg.host + " dbname=" + cfg.dbname +
            " user=" + cfg.user + " password=" + cfg.password +
            " connect_timeout=5";
        pqxx::connection conn{conn_str};
        pqxx::work tx{conn};

        // Postgres expands positions_json so the daemon never parses JSON.
        const auto rows = tx.exec_params(
            "SELECT (p->>'x')::int, (p->>'y')::int, p->>'label' "
            "FROM formations f, jsonb_array_elements(f.positions_json) p "
            "WHERE f.code = $1 "
            "ORDER BY (p->>'slot')::int",
            code);
        if (rows.empty()) return std::nullopt;

        ai::FormationSpec spec;
        spec.positions.reserve(rows.size());
        for (const auto& row : rows) {
            spec.positions.push_back(
                mapClubPosition(row[0].as<int>(), row[1].as<int>(),
                                row[2].as<std::string>() == "GK"));
        }
        return spec;
    } catch (const std::exception& e) {
        std::fprintf(stderr, "fh-game: formation load '%s' failed: %s\n",
                     code.c_str(), e.what());
        return std::nullopt;
    }
}

std::vector<std::int64_t> loadAdminUserIds(const DbConfig& cfg) {
    try {
        const std::string conn_str =
            "host=" + cfg.host + " dbname=" + cfg.dbname +
            " user=" + cfg.user + " password=" + cfg.password +
            " connect_timeout=5";
        pqxx::connection conn{conn_str};
        pqxx::work tx{conn};
        const auto rows = tx.exec(
            "SELECT u.id FROM users u JOIN admins a ON a.user_id = u.id");
        std::vector<std::int64_t> out;
        out.reserve(rows.size());
        for (const auto& row : rows) out.push_back(row[0].as<std::int64_t>());
        return out;
    } catch (const std::exception& e) {
        std::fprintf(stderr, "fh-game: admin-id load failed: %s\n", e.what());
        return {};
    }
}

std::optional<DemoTeam> loadDemoTeam(const DbConfig& cfg,
                                     const std::string& team_name) {
    try {
        const std::string conn_str =
            "host=" + cfg.host + " dbname=" + cfg.dbname +
            " user=" + cfg.user + " password=" + cfg.password +
            " connect_timeout=5";
        pqxx::connection conn{conn_str};
        pqxx::work tx{conn};
        const auto team = tx.exec_params(
            "SELECT id, level_band, style_preset FROM game_demo_teams "
            "WHERE name = $1",
            team_name);
        if (team.empty()) return std::nullopt;
        DemoTeam out;
        out.level_band = team[0][1].as<std::string>();
        if (!team[0][2].is_null())
            out.style_preset = team[0][2].as<std::string>();
        const auto rows = tx.exec_params(
            "SELECT name, max_speed_cms, concept_mask FROM game_demo_players "
            "WHERE team_id = $1 ORDER BY shirt",
            team[0][0].as<int>());
        for (const auto& r : rows) {
            DemoPlayer p;
            p.name = r[0].as<std::string>();
            p.max_speed_cms = r[1].as<std::int32_t>();
            p.concept_mask = r[2].is_null() ? -1 : r[2].as<std::int32_t>();
            out.players.push_back(std::move(p));
        }
        return out;
    } catch (const std::exception& e) {
        std::fprintf(stderr, "fh-game: demo team '%s' load failed: %s\n",
                     team_name.c_str(), e.what());
        return std::nullopt;
    }
}

std::vector<StylePreset> loadStylePresets(const DbConfig& cfg) {
    std::vector<StylePreset> out;
    try {
        const std::string conn_str =
            "host=" + cfg.host + " dbname=" + cfg.dbname +
            " user=" + cfg.user + " password=" + cfg.password +
            " connect_timeout=5";
        pqxx::connection conn{conn_str};
        pqxx::work tx{conn};
        const auto rows = tx.exec(
            "SELECT p.name, r.concept, r.rating "
            "FROM game_style_presets p "
            "JOIN game_style_preset_ratings r ON r.preset_id = p.id "
            "ORDER BY p.sort_order, p.id");
        for (const auto& row : rows) {
            const std::string name = row[0].as<std::string>();
            if (out.empty() || out.back().name != name) {
                StylePreset p;
                p.name = name;
                p.overlay.fill(-1);
                out.push_back(std::move(p));
            }
            // "concept" is a C++20 keyword — hence dial_name.
            const std::string dial_name = row[1].as<std::string>();
            int idx = -1;
            for (int i = 0; i < core::kConceptCount; ++i) {
                if (dial_name == core::kConceptNames[i]) { idx = i; break; }
            }
            if (idx < 0) {  // a queued concept's row landed early: skip
                std::fprintf(stderr,
                             "fh-game: preset '%s' names unknown concept "
                             "'%s' — skipped\n",
                             name.c_str(), dial_name.c_str());
                continue;
            }
            int rating = row[2].as<int>();
            if (rating < 0) rating = 0;
            if (rating > 100) rating = 100;
            out.back().overlay[idx] = static_cast<std::int16_t>(rating);
        }
        return out;
    } catch (const std::exception& e) {
        std::fprintf(stderr, "fh-game: style presets load failed: %s\n",
                     e.what());
        return {};
    }
}

}  // namespace fh::game::persistence
