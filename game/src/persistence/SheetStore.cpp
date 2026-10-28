// persistence/SheetStore.cpp — see SheetStore.hpp (G4.83, mig 793).
#include "persistence/SheetStore.hpp"

#include <pqxx/pqxx>

#include <algorithm>
#include <cstdio>

namespace fh::game::persistence {

namespace {

std::string connStr(const DbConfig& cfg) {
    return "host=" + cfg.host + " dbname=" + cfg.dbname + " user=" + cfg.user +
           " password=" + cfg.password + " connect_timeout=5";
}

std::uint64_t fnv(const std::string& s) {
    std::uint64_t h = 14695981039346656037ULL;
    for (unsigned char c : s) { h ^= c; h *= 1099511628211ULL; }
    return h;
}

// game_attributes codes in attributeAt order (the sheet's index).
int attributeIndex(const std::string& code) {
    static const char* codes[core::kAttributeCount] = {
        "pace", "passing", "shooting", "first_touch", "tackling", "anticipation", "decisions",
        "goalkeeping", "acceleration", "deceleration", "agility", "dribbling", "communication",
        "concentration"};
    for (int i = 0; i < core::kAttributeCount; ++i)
        if (code == codes[i]) return i;
    return -1;
}

}  // namespace

std::optional<core::SheetRules> loadSheetRules(const DbConfig& cfg) {
    try {
        core::SheetRules r = core::SheetRules::fromParams(loadModelParams(cfg));
        pqxx::connection conn{connStr(cfg)};
        pqxx::work tx{conn};
        for (const auto& row : tx.exec(
                 "SELECT stage, roll_lo, roll_hi, outcome, round(weight * 1000)::int, years, years_hi "
                 "FROM game_sheet_tables ORDER BY stage, roll_lo")) {
            core::SheetTableRow t;
            t.lo = row[1].as<int>();
            t.hi = row[2].as<int>();
            t.outcome = row[3].as<std::string>();
            t.weight = math::Fixed64::fromFraction(row[4].as<int>(), 1000);
            t.years = row[5].as<int>();
            t.years_hi = row[6].as<int>();
            r.tables[row[0].as<std::string>()].push_back(t);
        }
        for (const auto& row : tx.exec(
                 "SELECT position_group, attribute, offset_pts FROM game_sheet_position_profile")) {
            int g = -1;
            for (int k = 0; k < core::kPositionGroups; ++k)
                if (row[0].as<std::string>() == core::kPositionGroupNames[k]) g = k;
            const int a = attributeIndex(row[1].as<std::string>());
            if (g >= 0 && a >= 0) r.profile[g][a] = row[2].as<int>();
        }
        return r;
    } catch (const std::exception& e) {
        std::fprintf(stderr, "fh-game: sheet rules load failed: %s\n", e.what());
        return std::nullopt;
    }
}

std::optional<SheetTeam> loadSheetFacts(const DbConfig& cfg, const std::string& team_name,
                                        const core::ModelParams& params) {
    try {
        pqxx::connection conn{connStr(cfg)};
        pqxx::work tx{conn};
        const auto t = tx.exec_params(
            "SELECT id, COALESCE(quality, 50), club_team_id FROM game_demo_teams WHERE name = $1", team_name);
        if (t.empty()) return std::nullopt;
        SheetTeam out;
        out.team_id = t[0][0].as<int>();
        out.name = team_name;
        const int quality = t[0][1].as<int>();
        const bool club = !t[0][2].is_null();
        const int club_team = club ? t[0][2].as<int>() : 0;
        // The tier thresholds: shares of the club team's lineup matches.
        const math::Fixed64 starter_share = params.fixed("sheet.tier.starter_start_share", 350);
        const math::Fixed64 bench_share = params.fixed("sheet.tier.bench_app_share", 250);
        int matches = 0;
        if (club)
            matches = tx.exec_params(
                "SELECT count(DISTINCT m.id) FROM match_lineups l JOIN matches m ON m.id = l.match_id "
                "WHERE m.home_team_id = $1", club_team)[0][0].as<int>();
        const auto rows = tx.exec_params(
            "SELECT p.shirt, p.name, p.person_id, COALESCE(p.position, ''), p.lineup_slot, "
            "       extract(year FROM age(pe.birth_date))::int, "
            "       (SELECT count(*) FILTER (WHERE l.is_starter) FROM match_lineups l JOIN matches m ON m.id = l.match_id "
            "          JOIN players pl ON pl.id = l.player_id WHERE pl.person_id = p.person_id AND m.home_team_id = $2), "
            "       (SELECT count(*) FROM match_lineups l JOIN matches m ON m.id = l.match_id "
            "          JOIN players pl ON pl.id = l.player_id WHERE pl.person_id = p.person_id AND m.home_team_id = $2) "
            "FROM game_demo_players p LEFT JOIN persons pe ON pe.id = p.person_id "
            "WHERE p.team_id = $1 ORDER BY p.lineup_slot NULLS LAST, p.shirt",
            out.team_id, club_team);
        int non_starters = 0;
        for (const auto& r : rows) {
            SheetPlayer sp;
            sp.shirt = r[0].as<int>();
            sp.name = r[1].as<std::string>();
            core::SheetFacts& f = sp.facts;
            f.seed = r[2].is_null() ? fnv("team:" + std::to_string(out.team_id) + ":shirt:" + std::to_string(sp.shirt))
                                    : fnv("person:" + r[2].as<std::string>());
            f.team_quality = quality;
            if (!r[5].is_null()) f.age = r[5].as<int>();
            if (club && matches > 0) {
                const int starts = r[6].as<int>(), apps = r[7].as<int>();
                const math::Fixed64 m = math::Fixed64::fromInt(matches);
                if (math::Fixed64::fromInt(starts) >= starter_share * m) f.tier = core::LineupTier::Starter;
                else if (math::Fixed64::fromInt(apps) >= bench_share * m) f.tier = core::LineupTier::Bench;
                else f.tier = core::LineupTier::Deep;
                sp.tier_basis = std::to_string(starts) + " starts / " + std::to_string(apps) + " in squad of " +
                                std::to_string(matches);
            } else {
                // No lineups: the boot lineup is the XI, the next seven the bench.
                if (!r[4].is_null()) { f.tier = core::LineupTier::Starter; sp.tier_basis = "in the lineup"; }
                else if (non_starters++ < 7) { f.tier = core::LineupTier::Bench; sp.tier_basis = "next seven"; }
                else { f.tier = core::LineupTier::Deep; sp.tier_basis = "the rest"; }
            }
            // Where he has lined up, on any club team; else his listed spot.
            if (!r[2].is_null())
                for (const auto& pr : tx.exec_params(
                         "SELECT pos.abbreviation, count(*) FROM match_lineups l JOIN players pl ON pl.id = l.player_id "
                         "JOIN positions pos ON pos.id = l.position_id WHERE pl.person_id = $1 GROUP BY 1",
                         r[2].as<int>())) {
                    const int g = core::positionGroupOf(pr[0].as<std::string>());
                    if (g >= 0) f.positions[g] += pr[1].as<int>();
                }
            if (std::all_of(f.positions.begin(), f.positions.end(), [](int n) { return n == 0; })) {
                const int g = core::positionGroupOf(r[3].as<std::string>());
                if (g >= 0) f.positions[g] = 1;
            }
            out.players.push_back(std::move(sp));
        }
        for (const auto& r : tx.exec_params(
                 "SELECT shirt, attribute, rating FROM game_demo_player_attributes "
                 "WHERE team_id = $1 AND source = 'edited'", out.team_id)) {
            const int a = attributeIndex(r[1].as<std::string>());
            if (a < 0) continue;
            for (auto& sp : out.players)
                if (sp.shirt == r[0].as<int>()) sp.facts.edited[a] = static_cast<std::int16_t>(r[2].as<int>());
        }
        return out;
    } catch (const std::exception& e) {
        std::fprintf(stderr, "fh-game: sheet facts for '%s' failed: %s\n", team_name.c_str(), e.what());
        return std::nullopt;
    }
}

bool saveSheets(const DbConfig& cfg, const SheetTeam& team, const std::vector<core::PlayerSheet>& sheets) {
    static const char* codes[core::kAttributeCount] = {
        "pace", "passing", "shooting", "first_touch", "tackling", "anticipation", "decisions",
        "goalkeeping", "acceleration", "deceleration", "agility", "dribbling", "communication",
        "concentration"};
    try {
        pqxx::connection conn{connStr(cfg)};
        pqxx::work tx{conn};
        for (std::size_t k = 0; k < team.players.size() && k < sheets.size(); ++k) {
            const auto& sp = team.players[k];
            const auto& s = sheets[k];
            tx.exec_params(
                "UPDATE game_demo_players SET age = $3, age_source = $4, start_age = $5, years_off = $6, "
                "lineup_tier = $7, quality = $8 WHERE team_id = $1 AND shirt = $2",
                team.team_id, sp.shirt, s.age(), std::string(s.ageRolled() ? "rolled" : "real"), s.startAge(), s.yearsOff(),
                std::string(core::tierName(s.tier())), s.quality());
            tx.exec_params("DELETE FROM game_demo_player_history WHERE team_id = $1 AND shirt = $2", team.team_id, sp.shirt);
            tx.exec_params("DELETE FROM game_demo_player_rolls WHERE team_id = $1 AND shirt = $2", team.team_id, sp.shirt);
            int ord = 0;
            for (const auto& h : s.history()) {
                const std::int64_t milli = (h.weight * math::Fixed64::fromInt(1000) + math::Fixed64::halfConst()).raw >>
                                           math::Fixed64::FRAC_BITS;
                tx.exec_params(
                    "INSERT INTO game_demo_player_history (team_id, shirt, ord, stage, outcome, from_age, to_age, weight, roll) "
                    "VALUES ($1, $2, $3, $4, $5, $6, $7, $8::numeric / 1000, $9)",
                    team.team_id, sp.shirt, ++ord, h.stage, h.outcome, h.from_age, h.to_age, milli, h.roll);
            }
            for (const auto& [what, roll] : s.rolls())
                tx.exec_params(
                    "INSERT INTO game_demo_player_rolls (team_id, shirt, what, roll) VALUES ($1, $2, $3, $4)",
                    team.team_id, sp.shirt, what, roll);
            for (int i = 0; i < core::kAttributeCount; ++i)
                tx.exec_params(
                    "INSERT INTO game_demo_player_attributes (team_id, shirt, attribute, rating, source) "
                    "VALUES ($1, $2, $3, $4, 'derived') ON CONFLICT (team_id, shirt, attribute) "
                    "DO UPDATE SET rating = EXCLUDED.rating WHERE game_demo_player_attributes.source = 'derived'",
                    team.team_id, sp.shirt, std::string(codes[i]), s.attribute(i));
        }
        tx.commit();
        return true;
    } catch (const std::exception& e) {
        std::fprintf(stderr, "fh-game: saving sheets for '%s' failed: %s\n", team.name.c_str(), e.what());
        return false;
    }
}

}  // namespace fh::game::persistence
