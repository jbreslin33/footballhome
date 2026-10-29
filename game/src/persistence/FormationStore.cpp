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
            "SELECT (p->>'x')::int, (p->>'y')::int, p->>'label', coalesce(r.number, 0) "
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
        }
        return spec;
    } catch (const std::exception& e) {
        std::fprintf(stderr, "fh-game: formation load '%s' failed: %s\n",
                     code.c_str(), e.what());
        return std::nullopt;
    }
}

std::vector<Phase> loadPhases(const DbConfig& cfg) {
    std::vector<Phase> out;
    try {
        pqxx::connection conn{"host=" + cfg.host + " dbname=" + cfg.dbname + " user=" + cfg.user +
                              " password=" + cfg.password + " connect_timeout=5"};
        pqxx::work tx{conn};
        for (const auto& r : tx.exec("SELECT code, title, kind, ball_x_pct, ball_y_pct, coalesce(press_line_pct, -1) "
                                     "FROM game_phases ORDER BY sort_order, code"))
            out.push_back(Phase{r[0].as<std::string>(), r[1].as<std::string>(), r[2].as<std::string>(),
                                r[3].as<int>(), r[4].as<int>(), r[5].as<int>()});
    } catch (const std::exception& e) {
        std::fprintf(stderr, "fh-game: phases load failed: %s\n", e.what());
    }
    return out;
}

std::vector<PhasePosition> loadPhasePositions(const DbConfig& cfg) {
    std::vector<PhasePosition> out;
    try {
        pqxx::connection conn{"host=" + cfg.host + " dbname=" + cfg.dbname + " user=" + cfg.user +
                              " password=" + cfg.password + " connect_timeout=5"};
        pqxx::work tx{conn};
        for (const auto& r : tx.exec("SELECT phase_code, formation_code, side, number, round(depth_m * 100)::int, "
                                     "round(width_m * 100)::int FROM game_phase_positions"))
            out.push_back(PhasePosition{r[0].as<std::string>(), r[1].as<std::string>(), r[2].as<std::string>(),
                                        r[3].as<int>(), r[4].as<int>(), r[5].as<int>()});
    } catch (const std::exception& e) {
        std::fprintf(stderr, "fh-game: phase positions load failed: %s\n", e.what());
    }
    return out;
}

std::vector<std::pair<int, int>> loadDirectOpponents(const DbConfig& cfg) {
    std::vector<std::pair<int, int>> out;
    try {
        pqxx::connection conn{"host=" + cfg.host + " dbname=" + cfg.dbname + " user=" + cfg.user +
                              " password=" + cfg.password + " connect_timeout=5"};
        pqxx::work tx{conn};
        for (const auto& r : tx.exec("SELECT number, opponent_number FROM game_direct_opponents ORDER BY 1, 2"))
            out.emplace_back(r[0].as<int>(), r[1].as<int>());
    } catch (const std::exception& e) {
        std::fprintf(stderr, "fh-game: direct opponents load failed: %s\n", e.what());
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
            "SELECT id, level_band, game_model, formation_code, "
            "       kit_shirt, kit_shorts, kit_socks, kit_trim, quality "
            "FROM game_demo_teams WHERE name = $1",
            team_name);
        if (team.empty()) return std::nullopt;
        DemoTeam out;
        out.name = team_name;
        out.level_band = team[0][1].as<std::string>();
        if (!team[0][2].is_null())
            out.game_model = team[0][2].as<std::string>();
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
        if (!team[0][8].is_null()) out.quality = team[0][8].as<std::int16_t>();
        const int team_id = team[0][0].as<int>();
        const auto rows = tx.exec_params(
            "SELECT shirt, name, max_speed_cms, concept_mask, "
            "       COALESCE(position, ''), COALESCE(description, ''), quality, "
            "       age, start_age, COALESCE(years_off, 0) "   // mig 793 sheet
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
            if (!r[6].is_null()) p.quality = r[6].as<std::int16_t>();
            if (!r[7].is_null()) p.age = r[7].as<std::int16_t>();
            if (!r[8].is_null()) p.start_age = r[8].as<std::int16_t>();
            p.years_off = r[9].as<std::int16_t>();
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
                else if (code == "acceleration") a.acceleration = v;
                else if (code == "deceleration") a.deceleration = v;
                else if (code == "agility") a.agility = v;
                else if (code == "dribbling") a.dribbling = v;
                else if (code == "communication") a.communication = v;
                else if (code == "concentration") a.concentration = v;
                else if (code == "reaction") a.reaction = v;
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
            const int idx = core::concepts().find(name);
            if (idx < 0) continue;   // not in the curriculum (game_concepts)
            const int v = r[2].as<int>();
            for (std::size_t i = 0; i < shirts.size(); ++i)
                if (shirts[i] == shirt)
                    out.players[i].concepts.emplace_back(
                        idx, static_cast<std::uint8_t>(v < 0 ? 0 : (v > 100 ? 100 : v)));
        }
        // Mig 669 tendencies, by concept NAME.
        for (const auto& r : tx.exec_params(
                 "SELECT shirt, concept, tendency FROM game_demo_player_tendencies "
                 "WHERE team_id = $1",
                 team_id)) {
            const int idx = core::concepts().find(r[1].as<std::string>());
            if (idx < 0) continue;
            const int v = r[2].as<int>();
            for (std::size_t i = 0; i < shirts.size(); ++i)
                if (shirts[i] == r[0].as<int>())
                    out.players[i].tendencies.emplace_back(
                        idx, static_cast<std::uint8_t>(v < 0 ? 0 : (v > 100 ? 100 : v)));
        }
        return out;
    } catch (const std::exception& e) {
        std::fprintf(stderr, "fh-game: demo team '%s' load failed: %s\n",
                     team_name.c_str(), e.what());
        return std::nullopt;
    }
}

std::vector<GameModel> loadGameModels(const DbConfig& cfg) {
    std::vector<GameModel> out;
    try {
        const std::string conn_str =
            "host=" + cfg.host + " dbname=" + cfg.dbname +
            " user=" + cfg.user + " password=" + cfg.password +
            " connect_timeout=5";
        pqxx::connection conn{conn_str};
        pqxx::work tx{conn};
        for (const auto& row : tx.exec(
                 "SELECT m.name, COALESCE(p.name, '') FROM game_models m "
                 "LEFT JOIN game_models p ON p.id = m.parent_id "
                 "ORDER BY m.sort_order, m.id")) {
            GameModel g;
            g.name = row[0].as<std::string>();
            g.parent = row[1].as<std::string>();
            g.overlay.fill(-1);
            out.push_back(std::move(g));
        }
        for (const auto& row : tx.exec(
                 "SELECT m.name, mc.concept_id, mc.demand FROM game_model_concepts mc "
                 "JOIN game_models m ON m.id = mc.model_id")) {
            const std::string name = row[0].as<std::string>();
            const int id = row[1].as<int>();
            if (id < 0 || id >= core::kMaxConcepts) continue;
            int d = row[2].as<int>();
            d = d < 0 ? 0 : (d > 100 ? 100 : d);
            for (auto& g : out)
                if (g.name == name) g.overlay[id] = static_cast<std::int16_t>(d);
        }
        for (const auto& row : tx.exec(
                 "SELECT m.name, l.zone, l.rung, l.weight FROM game_model_ladder l "
                 "JOIN game_models m ON m.id = l.model_id")) {
            const std::string name = row[0].as<std::string>();
            const auto zs = row[1].as<std::string>(), rs = row[2].as<std::string>();
            const int z = zs == "own" ? 0 : zs == "middle" ? 1 : zs == "their" ? 2 : -1;
            const int r = rs == "intercept" ? 0 : rs == "no_turn" ? 1 : rs == "contain" ? 2 : -1;
            if (z < 0 || r < 0) continue;
            int w = row[3].as<int>();
            w = w < 0 ? 0 : (w > 100 ? 100 : w);
            for (auto& g : out)
                if (g.name == name) g.ladder[z][r] = static_cast<std::int16_t>(w);
        }
        for (const auto& row : tx.exec(
                 "SELECT m.name, 'concept.' || c.name || '.' || p.param, round(p.value * 1000)::bigint "
                 "FROM game_model_concept_params p JOIN game_models m ON m.id = p.model_id "
                 "JOIN game_concepts c ON c.id = p.concept_id")) {
            const std::string name = row[0].as<std::string>();
            for (auto& g : out)
                if (g.name == name) g.own_params[row[1].as<std::string>()] = row[2].as<std::int64_t>();
        }
        resolveGameModels(out);
        return out;
    } catch (const std::exception& e) {
        std::fprintf(stderr, "fh-game: game models load failed: %s\n", e.what());
        return {};
    }
}

void resolveGameModels(std::vector<GameModel>& models) {
    for (auto& g : models) {
        if (!g.resolved) {
            g.own = g.overlay;
            for (int z = 0; z < 3; ++z)
                for (int r = 0; r < 3; ++r) g.own_ladder[z][r] = g.ladder[z][r];
            g.resolved = true;
        }
        g.overlay = g.own;
        for (int z = 0; z < 3; ++z)
            for (int r = 0; r < 3; ++r) g.ladder[z][r] = g.own_ladder[z][r];
        g.params = g.own_params;
        g.param_origin.clear();
    }
    auto find = [&](const std::string& n) -> int {
        for (std::size_t k = 0; k < models.size(); ++k)
            if (models[k].name == n) return static_cast<int>(k);
        return -1;
    };
    for (std::size_t k = 0; k < models.size(); ++k) {
        GameModel& g = models[k];
        for (int i = 0; i < core::kMaxConcepts; ++i)
            g.origin[i] = g.own[i] >= 0 ? static_cast<std::int16_t>(k) : std::int16_t{-1};
        for (int z = 0; z < 3; ++z)
            for (int r = 0; r < 3; ++r)
                g.ladder_origin[z][r] = g.own_ladder[z][r] >= 0 ? static_cast<std::int16_t>(k) : std::int16_t{-1};
        for (const auto& [key, v] : g.own_params) g.param_origin[key] = static_cast<int>(k);
        std::string parent = g.parent;
        for (int depth = 0; depth < 16 && !parent.empty(); ++depth) {
            const int pi = find(parent);
            if (pi < 0 || models[pi].name == g.name) break;
            const GameModel& p = models[pi];
            for (int i = 0; i < core::kMaxConcepts; ++i)
                if (g.overlay[i] < 0 && p.own[i] >= 0) {
                    g.overlay[i] = p.own[i];
                    g.origin[i] = static_cast<std::int16_t>(pi);
                }
            for (int z = 0; z < 3; ++z)
                for (int r = 0; r < 3; ++r)
                    if (g.ladder[z][r] < 0 && p.own_ladder[z][r] >= 0) {
                        g.ladder[z][r] = p.own_ladder[z][r];
                        g.ladder_origin[z][r] = static_cast<std::int16_t>(pi);
                    }
            for (const auto& [key, v] : p.own_params)
                if (g.params.emplace(key, v).second) g.param_origin[key] = pi;
            parent = p.parent;
        }
    }
}

bool saveModelDemand(const DbConfig& cfg, const std::string& model,
                     int concept_id, int demand) {
    try {
        const std::string conn_str =
            "host=" + cfg.host + " dbname=" + cfg.dbname +
            " user=" + cfg.user + " password=" + cfg.password +
            " connect_timeout=5";
        pqxx::connection conn{conn_str};
        pqxx::work tx{conn};
        if (demand < 0) {
            tx.exec_params(
                "DELETE FROM game_model_concepts WHERE concept_id = $2 "
                "AND model_id = (SELECT id FROM game_models WHERE name = $1)",
                model, concept_id);
        } else {
            tx.exec_params(
                "INSERT INTO game_model_concepts (model_id, concept_id, demand, citation) "
                "SELECT id, $2, $3, 'Set in the game HUD, ' || to_char(now(), 'YYYY-MM-DD') "
                "FROM game_models WHERE name = $1 "
                "ON CONFLICT (model_id, concept_id) DO UPDATE "
                "SET demand = EXCLUDED.demand, citation = EXCLUDED.citation",
                model, concept_id, demand > 100 ? 100 : demand);
        }
        tx.commit();
        return true;
    } catch (const std::exception& e) {
        std::fprintf(stderr, "fh-game: save demand %s/%d failed: %s\n",
                     model.c_str(), concept_id, e.what());
        return false;
    }
}

bool saveModelParam(const DbConfig& cfg, const std::string& model,
                    const std::string& key, std::optional<std::int64_t> milli) {
    const auto a = key.find('.'), b = key.find('.', a + 1);
    if (a == std::string::npos || b == std::string::npos) return false;
    const std::string owner = key.substr(0, a), code = key.substr(a + 1, b - a - 1),
                      param = key.substr(b + 1);
    try {
        const std::string conn_str =
            "host=" + cfg.host + " dbname=" + cfg.dbname +
            " user=" + cfg.user + " password=" + cfg.password +
            " connect_timeout=5";
        pqxx::connection conn{conn_str};
        pqxx::work tx{conn};
        const std::string value = milli ? std::to_string(*milli) : "0";
        if (owner == "ladder") {
            if (!milli)
                tx.exec_params("DELETE FROM game_model_ladder WHERE zone = $2 AND rung = $3 "
                               "AND model_id = (SELECT id FROM game_models WHERE name = $1)",
                               model, code, param);
            else
                tx.exec_params(
                    "INSERT INTO game_model_ladder (model_id, zone, rung, weight, note) "
                    "SELECT id, $2, $3, LEAST(100, GREATEST(0, round($4::numeric / 1000)))::int, "
                    "'Set in the game HUD, ' || to_char(now(), 'YYYY-MM-DD') "
                    "FROM game_models WHERE name = $1 "
                    "ON CONFLICT (model_id, zone, rung) DO UPDATE "
                    "SET weight = EXCLUDED.weight, note = EXCLUDED.note",
                    model, code, param, value);
        } else if (owner == "concept") {
            if (!milli)
                tx.exec_params("DELETE FROM game_model_concept_params WHERE param = $3 "
                               "AND model_id = (SELECT id FROM game_models WHERE name = $1) "
                               "AND concept_id = (SELECT id FROM game_concepts WHERE name = $2)",
                               model, code, param);
            else
                tx.exec_params(
                    "INSERT INTO game_model_concept_params (model_id, concept_id, param, value, unit, citation) "
                    "SELECT m.id, c.id, $3, $4::numeric / 1000, g.unit, "
                    "'Set in the game HUD, ' || to_char(now(), 'YYYY-MM-DD') "
                    "FROM game_models m, game_concepts c, game_model_params g "
                    "WHERE m.name = $1 AND c.name = $2 AND g.owner = 'concept' AND g.code = $2 AND g.param = $3 "
                    "ON CONFLICT (model_id, concept_id, param) DO UPDATE "
                    "SET value = EXCLUDED.value, citation = EXCLUDED.citation",
                    model, code, param, value);
        } else {
            return false;
        }
        tx.commit();
        return true;
    } catch (const std::exception& e) {
        std::fprintf(stderr, "fh-game: save param %s/%s failed: %s\n",
                     model.c_str(), key.c_str(), e.what());
        return false;
    }
}

std::vector<ParamInfo> loadConceptParamInfo(const DbConfig& cfg) {
    std::vector<ParamInfo> out;
    try {
        const std::string conn_str =
            "host=" + cfg.host + " dbname=" + cfg.dbname +
            " user=" + cfg.user + " password=" + cfg.password +
            " connect_timeout=5";
        pqxx::connection conn{conn_str};
        pqxx::work tx{conn};
        for (const auto& r : tx.exec(
                 "SELECT 'concept.' || g.code || '.' || g.param, g.unit FROM game_model_params g "
                 "JOIN game_concepts c ON c.name = g.code "   // a model row needs a concept id
                 "WHERE g.owner = 'concept' ORDER BY g.code, g.param"))
            out.push_back({r[0].as<std::string>(), r[1].as<std::string>()});
    } catch (const std::exception& e) {
        std::fprintf(stderr, "fh-game: concept param list failed: %s\n", e.what());
    }
    return out;
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

std::optional<core::ConceptRegistry> loadConcepts(const DbConfig& cfg) {
    try {
        const std::string conn_str =
            "host=" + cfg.host + " dbname=" + cfg.dbname +
            " user=" + cfg.user + " password=" + cfg.password +
            " connect_timeout=5";
        pqxx::connection conn{conn_str};
        pqxx::work tx{conn};
        core::ConceptRegistry reg;
        for (const auto& r : tx.exec(
                 "SELECT id, name, COALESCE(taught_from, '') "
                 "FROM game_concepts ORDER BY id"))
            // Mig 762: no core/style in the dictionary — every DB model
            // states its demand, so the registry's default never applies.
            reg.add(r[0].as<int>(), r[1].as<std::string>(),
                    core::levelRank(r[2].as<std::string>()));
        if (reg.size() == 0) return std::nullopt;
        for (const auto& r : tx.exec(
                 "SELECT concept_id, other_id FROM game_concept_links "
                 "WHERE kind = 'lapses-to' ORDER BY concept_id, other_id"))
            reg.addLapse(r[0].as<int>(), r[1].as<int>());
        return reg;
    } catch (const std::exception& e) {
        std::fprintf(stderr, "fh-game: game_concepts load failed (builtin curriculum): %s\n", e.what());
        return std::nullopt;
    }
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
