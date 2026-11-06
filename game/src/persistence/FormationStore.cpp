// game/src/persistence/FormationStore.cpp — boot-time loads from the club DB.
// G5.23 (DESIGN §8.121): only what the clean game reads — formations, the
// teams (names, positions, kits), the officials, admin ids, the physics
// params, the real benchmarks. Models, demands, concepts, phases and phase
// shapes, direct opponents and made-up player numbers are gone.

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
            "SELECT (p->>'x')::int, (p->>'y')::int, p->>'label', coalesce(r.number, 0), coalesce(r.role, '') "
            "FROM formations f CROSS JOIN LATERAL jsonb_array_elements(f.positions_json) p "
            "LEFT JOIN formation_slot_roles r ON r.formation_code = f.code AND r.slot = (p->>'slot')::int "
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
            spec.positions.back().number = static_cast<std::int16_t>(row[3].as<int>());
            spec.positions.back().role = row[4].as<std::string>();
        }
        return spec;
    } catch (const std::exception& e) {
        std::fprintf(stderr, "fh-game: formation load '%s' failed: %s\n",
                     code.c_str(), e.what());
        return std::nullopt;
    }
}

std::vector<CrewMember> loadCrew(const DbConfig& cfg, const std::string& level) {
    std::vector<CrewMember> out;
    try {
        pqxx::connection conn{"host=" + cfg.host + " dbname=" + cfg.dbname + " user=" + cfg.user +
                              " password=" + cfg.password + " connect_timeout=5"};
        pqxx::work tx{conn};
        const auto rows = tx.exec_params(
            "SELECT o.id, o.role, o.name FROM game_officials o JOIN game_official_crews c ON c.id = o.crew_id "
            "WHERE c.level = COALESCE((SELECT level FROM game_official_crews WHERE level = $1 LIMIT 1), 'semipro') "
            "ORDER BY c.id, o.role LIMIT 3",
            level);
        for (const auto& r : rows) {
            CrewMember m;
            const std::string role = r[1].as<std::string>();
            m.role = role == "referee" ? 0 : role == "assistant_1" ? 1 : 2;
            m.name = r[2].as<std::string>();
            for (const auto& a : tx.exec_params(
                     "SELECT attribute, rating FROM game_official_ratings WHERE official_id = $1", r[0].as<int>()))
                m.ratings[a[0].as<std::string>()] = a[1].as<int>();
            out.push_back(std::move(m));
        }
    } catch (const std::exception& e) {
        std::fprintf(stderr, "fh-game: officials load failed (a 50-rated crew): %s\n", e.what());
    }
    return out;
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

std::map<std::string, std::int64_t> loadRestartLawsMilli(const DbConfig& cfg) {
    std::map<std::string, std::int64_t> out;
    try {
        pqxx::connection conn{"host=" + cfg.host + " dbname=" + cfg.dbname + " user=" + cfg.user +
                              " password=" + cfg.password + " connect_timeout=5"};
        pqxx::work tx{conn};
        if (tx.exec("SELECT to_regclass('tactic_restarts') IS NOT NULL")[0][0].as<bool>())
            for (const auto& r : tx.exec("SELECT code, round(law_m * 1000)::bigint FROM tactic_restarts WHERE law_m IS NOT NULL"))
                out[r[0].as<std::string>()] = r[1].as<std::int64_t>();
    } catch (const std::exception& e) {
        std::fprintf(stderr, "fh-game: tactic_restarts load failed (defaults): %s\n", e.what());
    }
    return out;
}

std::vector<std::string> loadDemoTeamNames(const DbConfig& cfg) {
    std::vector<std::string> out;
    try {
        pqxx::connection conn{"host=" + cfg.host + " dbname=" + cfg.dbname + " user=" + cfg.user +
                              " password=" + cfg.password + " connect_timeout=5"};
        pqxx::work tx{conn};
        for (const auto& r : tx.exec("SELECT name FROM game_demo_teams ORDER BY name"))
            out.push_back(r[0].as<std::string>());
    } catch (const std::exception& e) {
        std::fprintf(stderr, "fh-game: game_demo_teams names load failed: %s\n", e.what());
    }
    return out;
}

std::optional<DemoTeam> loadDemoTeam(const DbConfig& cfg, const std::string& team_name) {
    try {
        pqxx::connection conn{"host=" + cfg.host + " dbname=" + cfg.dbname + " user=" + cfg.user +
                              " password=" + cfg.password + " connect_timeout=5"};
        pqxx::work tx{conn};
        const auto team = tx.exec_params(
            "SELECT id, formation_code, kit_shirt, kit_shorts, kit_socks, kit_trim "
            "FROM game_demo_teams WHERE name = $1",
            team_name);
        if (team.empty()) return std::nullopt;
        DemoTeam out;
        out.name = team_name;
        if (!team[0][1].is_null()) out.formation_code = team[0][1].as<std::string>();
        // '#rrggbb' → 0xRRGGBB (mig 639).
        std::int32_t* kit[4] = {&out.kit_shirt, &out.kit_shorts, &out.kit_socks, &out.kit_trim};
        for (int c = 0; c < 4; ++c) {
            if (team[0][2 + c].is_null()) continue;
            const std::string hex = team[0][2 + c].as<std::string>();
            if (hex.size() == 7 && hex[0] == '#') *kit[c] = static_cast<std::int32_t>(std::stol(hex.substr(1), nullptr, 16));
        }
        // Mig 641: the lineup, not the shirts, decides who starts — index =
        // formation slot (1-11), then the bench by shirt.
        for (const auto& r : tx.exec_params(
                 "SELECT name, COALESCE(position, ''), COALESCE(max_speed_cms, 0) FROM game_demo_players WHERE team_id = $1 "
                 "ORDER BY lineup_slot NULLS LAST, shirt",
                 team[0][0].as<int>())) {
            DemoPlayer p;
            p.name = r[0].as<std::string>();
            p.position = r[1].as<std::string>();
            p.max_speed_cms = r[2].as<std::int32_t>();
            out.players.push_back(std::move(p));
        }
        return out;
    } catch (const std::exception& e) {
        std::fprintf(stderr, "fh-game: demo team '%s' load failed: %s\n", team_name.c_str(), e.what());
        return std::nullopt;
    }
}

core::ModelParams loadModelParams(const DbConfig& cfg) {
    core::ModelParams out;
    try {
        const std::string conn_str =
            "host=" + cfg.host + " dbname=" + cfg.dbname +
            " user=" + cfg.user + " password=" + cfg.password +
            " connect_timeout=5";
        pqxx::connection conn{conn_str};
        pqxx::work tx{conn};
        for (const auto& r : tx.exec(
                 "SELECT owner || '.' || code || '.' || param, round(value * 1000)::bigint "
                 "FROM game_model_params"))
            out.setMilli(r[0].as<std::string>(), r[1].as<std::int64_t>());
    } catch (const std::exception& e) {
        std::fprintf(stderr, "fh-game: game_model_params load failed (class defaults): %s\n", e.what());
    }
    return out;
}

std::vector<Benchmark> loadBenchmarks(const DbConfig& cfg, const std::string& level) {
    try {
        const std::string conn_str =
            "host=" + cfg.host + " dbname=" + cfg.dbname +
            " user=" + cfg.user + " password=" + cfg.password +
            " connect_timeout=5";
        pqxx::connection conn{conn_str};
        pqxx::work tx{conn};
        std::vector<Benchmark> out;
        for (const auto& r : tx.exec_params(
                 "SELECT b.metric, m.label, m.unit, b.competition, b.season, s.title, b.matches, b.value::float8 "
                 "FROM game_benchmarks b JOIN game_benchmark_metrics m ON m.code = b.metric "
                 "JOIN game_sources s ON s.id = b.source_id WHERE b.level = $1 ORDER BY b.id", level)) {
            Benchmark b;
            b.metric = r[0].as<std::string>(); b.label = r[1].as<std::string>(); b.unit = r[2].as<std::string>();
            b.competition = r[3].as<std::string>(); b.season = r[4].as<std::string>(); b.source = r[5].as<std::string>();
            b.matches = r[6].as<int>(); b.value = r[7].as<double>();
            out.push_back(std::move(b));
        }
        return out;
    } catch (const std::exception& e) {
        std::fprintf(stderr, "fh-game: benchmark load failed: %s\n", e.what());
        return {};
    }
}

}  // namespace fh::game::persistence
