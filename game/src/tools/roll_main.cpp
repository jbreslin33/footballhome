// fh-game-roll — roll every player's character sheet for game teams
// (G4.83, mig 793; game/DESIGN.md §8.81).
//
//   POSTGRES_PASSWORD=... fh-game-roll [--write] "Lighthouse APSL" "Ukrainian Nationals"
//
// Without --write it prints the sheets and changes nothing. With it, each
// team's sheets go to the DB in one transaction (attributes marked 'edited'
// are never touched). Deterministic: the same club facts roll the same men.
// Names are printed to the terminal only — they live in the club DB, never
// in git.
#include "core/ConceptRegistry.hpp"
#include "core/PlayerSheet.hpp"
#include "persistence/SheetStore.hpp"

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <string>
#include <vector>

using namespace fh::game;

namespace {
const char* envOr(const char* k, const char* d) {
    const char* v = std::getenv(k);
    return v && *v ? v : d;
}
}  // namespace

int main(int argc, char** argv) {
    bool write = false;
    std::vector<std::string> teams;
    for (int i = 1; i < argc; ++i) {
        if (std::strcmp(argv[i], "--write") == 0) write = true;
        else teams.emplace_back(argv[i]);
    }
    if (teams.empty()) {
        std::fprintf(stderr, "usage: fh-game-roll [--write] <game team name> ...\n");
        return 2;
    }
    persistence::DbConfig db;
    db.host = envOr("POSTGRES_HOST", "localhost");
    db.dbname = envOr("POSTGRES_DB", "footballhome");
    db.user = envOr("POSTGRES_USER", "footballhome_user");
    db.password = envOr("POSTGRES_PASSWORD", "");
    const auto params = persistence::loadModelParams(db);
    const auto rules = persistence::loadSheetRules(db);
    if (!rules || params.size() == 0) {
        std::fprintf(stderr, "fh-game-roll: no rules from the DB — nothing rolled\n");
        return 1;
    }
    const core::PlayerGenerator gen{*rules};
    int failed = 0;
    for (const auto& name : teams) {
        const auto team = persistence::loadSheetFacts(db, name, params);
        if (!team) { ++failed; continue; }
        std::vector<core::SheetFacts> facts;
        for (const auto& p : team->players) facts.push_back(p.facts);
        const auto sheets = gen.generateTeam(facts);
        std::printf("\n%s — %zu players (team quality %d)\n", name.c_str(), sheets.size(),
                    team->players.empty() ? 0 : team->players[0].facts.team_quality);
        int tiers[3] = {0, 0, 0};
        long sum[3][core::kAttributeCount] = {};
        for (std::size_t k = 0; k < sheets.size(); ++k) {
            const auto& s = sheets[k];
            const auto& p = team->players[k];
            ++tiers[static_cast<int>(s.tier())];
            for (int i = 0; i < core::kAttributeCount; ++i) sum[static_cast<int>(s.tier())][i] += s.attribute(i);
            std::printf("  #%-3d %-24.24s %-7s age %2d%s start %d off %d | q %d |", p.shirt, p.name.c_str(),
                        core::tierName(s.tier()), s.age(), s.ageRolled() ? "*" : " ", s.startAge(), s.yearsOff(),
                        s.quality());
            for (const auto& h : s.history()) std::printf(" %s(%d-%d)", h.outcome.c_str(), h.from_age, h.to_age);
            std::printf("\n        pace %d pass %d shoot %d touch %d tackle %d antic %d decis %d gk %d acc %d dec %d agil %d drib %d comm %d conc %d  [%s]\n",
                        s.attribute(0), s.attribute(1), s.attribute(2), s.attribute(3), s.attribute(4), s.attribute(5),
                        s.attribute(6), s.attribute(7), s.attribute(8), s.attribute(9), s.attribute(10),
                        s.attribute(11), s.attribute(12), s.attribute(13), p.tier_basis.c_str());
        }
        std::printf("  tiers: %d starters, %d bench, %d deep bench; mean passing by tier %.0f / %.0f / %.0f, pace %.0f / %.0f / %.0f (* = rolled age)\n",
                    tiers[0], tiers[1], tiers[2],
                    tiers[0] ? double(sum[0][1]) / tiers[0] : 0.0, tiers[1] ? double(sum[1][1]) / tiers[1] : 0.0,
                    tiers[2] ? double(sum[2][1]) / tiers[2] : 0.0,
                    tiers[0] ? double(sum[0][0]) / tiers[0] : 0.0, tiers[1] ? double(sum[1][0]) / tiers[1] : 0.0,
                    tiers[2] ? double(sum[2][0]) / tiers[2] : 0.0);
        if (write) {
            if (persistence::saveSheets(db, *team, sheets)) std::printf("  written.\n");
            else ++failed;
        }
    }
    return failed ? 1 : 0;
}
