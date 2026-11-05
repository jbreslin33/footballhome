// game/src/server/MatchSetup.cpp — see MatchSetup.hpp.

#include "server/MatchSetup.hpp"

#include <cstdio>
#include <tuple>

namespace fh::game::server {

void loadMatchFromDb(GameServer::Config& cfg, const persistence::DbConfig& db,
                     const MatchNames& names, bool log) {
    auto say = [log](const char* fmt, auto... args) {
        if (log) std::printf(fmt, args...);
    };
    const char* home_code = names.formation_home.c_str();
    const char* away_code = names.formation_away.c_str();
    const char* th = names.team_home.c_str();
    const char* ta = names.team_away.c_str();
    // Formations come from the club's own `formations` table; DB down or code
    // unknown = loud log + built-in shapes; the sandbox always boots.
    if (auto f = persistence::loadFormation(db, home_code)) {
        cfg.formation_home = std::move(*f);
        say("fh-game: home formation %s (club DB)\n", home_code);
    } else {
        say("fh-game: home formation FALLBACK (built-in)\n");
    }
    if (auto f = persistence::loadFormation(db, away_code)) {
        cfg.formation_away = std::move(*f);
        say("fh-game: away formation %s (club DB)\n", away_code);
    } else {
        say("fh-game: away formation FALLBACK (built-in)\n");
    }
    cfg.admin_user_ids = persistence::loadAdminUserIds(db);
    cfg.db = db;   // G4.32: admin RELOAD_ROSTERS re-reads the teams
    cfg.model_params = persistence::loadModelParams(db);
    say("fh-game: %zu physics param(s) loaded\n", cfg.model_params.size());
    if (auto t = persistence::loadDemoTeam(db, th)) {
        cfg.roster_home = std::move(*t);
        say("fh-game: home team %s\n", th);
    }
    if (auto t = persistence::loadDemoTeam(db, ta)) {
        cfg.roster_away = std::move(*t);
        say("fh-game: away team %s\n", ta);
    }
    // Mig 636: a team that names its formation plays it (the PL 15/16 sides
    // their usual shape), over GAME_FORMATION_*.
    for (auto [roster, spec, side] :
         {std::tuple{&cfg.roster_home, &cfg.formation_home, "home"},
          std::tuple{&cfg.roster_away, &cfg.formation_away, "away"}}) {
        if (roster->formation_code.empty()) continue;
        if (auto f = persistence::loadFormation(db, roster->formation_code)) {
            *spec = std::move(*f);
            say("fh-game: %s formation %s (the team's own)\n", side, roster->formation_code.c_str());
        }
    }
    // G4.88: the officials — the pro crew.
    cfg.crew = persistence::loadCrew(db, "pro");
    say("fh-game: %zu official(s), %zu admin user(s)\n", cfg.crew.size(), cfg.admin_user_ids.size());
}

}  // namespace fh::game::server
