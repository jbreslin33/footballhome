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
    // Formations come from the club's own `formations` table (open system:
    // rows added on the club page become playable AI shapes). DB down or
    // code unknown = loud log + built-in shapes; the sandbox always boots.
    // G4.37: the curriculum first — rosters and presets name concepts.
    // A DB that renumbered a wired concept is refused (ids are wire
    // format and every saved rating keys on them).
    if (auto reg = persistence::loadConcepts(db)) {
        const core::ConceptRegistry wired = core::ConceptRegistry::builtin();
        // Only ids the builtin NAMES are checked: its holes (31-152 since
        // G4.53) are the DB's to fill. (Checking them refused every DB from
        // G4.53 to G4.54 — the daemon ran the builtin curriculum.)
        const int bad = reg->firstRenumbered(wired);
        if (bad >= 0)
            std::fprintf(stderr, "fh-game: game_concepts id %d is '%s', wired '%s' — REFUSED, builtin curriculum kept\n",
                         bad, reg->name(bad).c_str(), wired.name(bad).c_str());
        if (bad < 0) {
            say("fh-game: %d concept(s) in the curriculum (club DB)\n", reg->size());
            core::setConcepts(std::move(*reg));
        }
    }
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
    cfg.model_params = persistence::loadModelParams(db);   // G4.33
    cfg.direct_pairs = persistence::loadDirectOpponents(db);   // G4.57
    say("fh-game: %zu game-model param(s) loaded\n", cfg.model_params.size());
    // Fictional demo rosters (mig 628): named players filling the
    // ladder. A roster's band OVERRIDES GAME_LEVEL_* defaults.
    if (auto t = persistence::loadDemoTeam(db, th)) {
        cfg.roster_home = std::move(*t);
        cfg.level_home = core::levelParams(cfg.roster_home.level_band);
        cfg.level_home_id = core::levelId(cfg.roster_home.level_band);
        say("fh-game: home roster %s (%s%s%s)\n", th,
                    cfg.roster_home.level_band.c_str(),
                    cfg.roster_home.game_model.empty() ? ""
                                                       : ", plays ",
                    cfg.roster_home.game_model.c_str());
    }
    if (auto t = persistence::loadDemoTeam(db, ta)) {
        cfg.roster_away = std::move(*t);
        cfg.level_away = core::levelParams(cfg.roster_away.level_band);
        cfg.level_away_id = core::levelId(cfg.roster_away.level_band);
        say("fh-game: away roster %s (%s%s%s)\n", ta,
                    cfg.roster_away.level_band.c_str(),
                    cfg.roster_away.game_model.empty() ? ""
                                                       : ", plays ",
                    cfg.roster_away.game_model.c_str());
    }
    // Mig 636: a roster that names its formation plays it (Ukies 4-2-3-1,
    // Lighthouse APSL 4-3-3), over GAME_FORMATION_*.
    for (auto [roster, spec, side] :
         {std::tuple{&cfg.roster_home, &cfg.formation_home, "home"},
          std::tuple{&cfg.roster_away, &cfg.formation_away, "away"}}) {
        if (roster->formation_code.empty()) continue;
        if (auto f = persistence::loadFormation(db, roster->formation_code)) {
            *spec = std::move(*f);
            say("fh-game: %s formation %s (the team's own)\n", side,
                        roster->formation_code.c_str());
        }
    }
    // Game models (mig 652): schools, federations, formations, teams.
    cfg.models = persistence::loadGameModels(db);
    say("fh-game: %zu admin user(s), %zu game model(s) loaded\n",
                cfg.admin_user_ids.size(), cfg.models.size());
}

}  // namespace fh::game::server
