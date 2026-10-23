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
            "SELECT id, level_band, style_preset, formation_code, "
            "       kit_shirt, kit_shorts, kit_socks, kit_trim "
            "FROM game_demo_teams WHERE name = $1",
            team_name);
        if (team.empty()) return std::nullopt;
        DemoTeam out;
        out.name = team_name;
        out.level_band = team[0][1].as<std::string>();
        if (!team[0][2].is_null())
            out.style_preset = team[0][2].as<std::string>();
        if (!team[0][3].is_null())
            out.formation_code = team[0][3].as<std::string>();
        // '#rrggbb' → 0xRRGGBB (mig 639).
        std::int32_t* kit[4] = {&out.kit_shirt, &out.kit_shorts, &out.kit_socks, &out.kit_trim};
        for (int c = 0; c < 4; ++c) {
            if (team[0][4 + c].is_null()) continue;
            const std::string hex = team[0][4 + c].as<std::string>();
            if (hex.size() == 7 && hex[0] == '#')
                *kit[c] = static_cast<std::int32_t>(std::stol(hex.substr(1), nullptr, 16));
        }
        const int team_id = team[0][0].as<int>();
        const auto rows = tx.exec_params(
            "SELECT shirt, name, max_speed_cms, concept_mask, "
            "       COALESCE(position, ''), COALESCE(description, '') "
            "FROM game_demo_players WHERE team_id = $1 "
            // Mig 641: the lineup, not the shirts, decides who starts —
            // index = formation slot (1-11), then the bench by shirt.
            "ORDER BY lineup_slot NULLS LAST, shirt",
            team_id);
        std::vector<int> shirts;
        for (const auto& r : rows) {
            DemoPlayer p;
            shirts.push_back(r[0].as<int>());
            p.name = r[1].as<std::string>();
            p.max_speed_cms = r[2].as<std::int32_t>();
            p.concept_mask = r[3].is_null() ? -1 : r[3].as<std::int32_t>();
            p.position = r[4].as<std::string>();
            p.description = r[5].as<std::string>();
            out.players.push_back(std::move(p));
        }
        // Mig 636 attributes, by registry code (unknown codes = rows for
        // attributes this build doesn't wire yet: skipped).
        const auto attrs = tx.exec_params(
            "SELECT shirt, attribute, rating FROM game_demo_player_attributes "
            "WHERE team_id = $1",
            team_id);
        for (const auto& r : attrs) {
            const int shirt = r[0].as<int>();
            const std::string code = r[1].as<std::string>();
            const auto v = static_cast<std::int16_t>(r[2].as<int>());
            for (std::size_t i = 0; i < shirts.size(); ++i) {
                if (shirts[i] != shirt) continue;
                core::PlayerAttributes& a = out.players[i].attrs;
                if (code == "pace") a.pace = v;
                else if (code == "passing") a.passing = v;
                else if (code == "shooting") a.shooting = v;
                else if (code == "first_touch") a.first_touch = v;
                else if (code == "tackling") a.tackling = v;
                else if (code == "anticipation") a.anticipation = v;
                else if (code == "decisions") a.decisions = v;
                else if (code == "goalkeeping") a.goalkeeping = v;
            }
        }
        // Mig 639 knowledge overrides, by concept NAME.
        const auto cons = tx.exec_params(
            "SELECT shirt, concept, rating FROM game_demo_player_concepts "
            "WHERE team_id = $1",
            team_id);
        for (const auto& r : cons) {
            const int shirt = r[0].as<int>();
            const std::string name = r[1].as<std::string>();
            int idx = -1;
            for (int c = 0; c < core::kConceptCount; ++c)
                if (name == core::kConceptNames[c]) idx = c;
            if (idx < 0) continue;   // a concept this build doesn't know yet
            const int v = r[2].as<int>();
            for (std::size_t i = 0; i < shirts.size(); ++i)
                if (shirts[i] == shirt)
                    out.players[i].concepts.emplace_back(
                        idx, static_cast<std::uint8_t>(v < 0 ? 0 : (v > 100 ? 100 : v)));
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
