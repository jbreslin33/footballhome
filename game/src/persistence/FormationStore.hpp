// game/src/persistence/FormationStore.hpp
//
// Loads AI formation shapes from the CLUB's own `formations` table — the
// same rows the lineup picker and tactical boards use (open system,
// DESIGN.md §2: adding a formation on the club page makes it a playable
// AI shape, no engine change). Postgres parses positions_json server-side
// (jsonb_array_elements), so no JSON code enters the daemon.
//
// Coordinate mapping (club → game):
//   club y: 0 = own goal line … 100 = attacking goal line
//     → base.x normalized [-1, 0] kickoff shape: base_x = (y - 100) / 100
//   club x: 0 … 100 across the width (50 = centre)
//     → base.y normalized [-1, +1]: base_y = (x - 50) / 50
//   keeper = label "GK".
//
// DB access happens ONCE at boot (config load, not gameplay); the sim loop
// never touches the database. On any failure the caller falls back to the
// built-in specs with a loud log — the sandbox must boot even if the DB is
// down.

#pragma once

#include "ai/Formation.hpp"
#include "core/ModelParams.hpp"

#include <map>
#include <optional>
#include <cstdint>
#include <string>
#include <vector>

namespace fh::game::persistence {

struct DbConfig {
    std::string host = "footballhome_db";
    std::string dbname = "footballhome";
    std::string user = "footballhome_user";
    std::string password;  // from POSTGRES_PASSWORD
};

// Pure mapping from one club-formation position row to a normalized base
// (unit-tested without a database).
ai::FormationSpec::Pos mapClubPosition(int club_x, int club_y,
                                       bool is_keeper);

// Load a formation by its club `code` (e.g. "4-4-2"). nullopt on any
// failure (connection, unknown code, malformed rows) — caller falls back.
std::optional<ai::FormationSpec> loadFormation(const DbConfig& cfg,
                                               const std::string& code);

// Admin users.id set (the club's real authz chain: users → admins →
// admin_levels; the JWT's role claim is minted EMPTY, so identity is the
// gate). Boot-time load; empty set on failure = nobody gets the admin
// capability, loudly logged.
std::vector<std::int64_t> loadAdminUserIds(const DbConfig& cfg);

// G4.57: direct-opponent pairs by position number (game_direct_opponents):
// (number, opponent_number) — our 9's are their 4 and 5, and so on.
struct DemoPlayer {
    std::string name;
    std::string position;          // game_demo_players.position (the roster's label)
    std::int32_t max_speed_cms = 0;   // his top speed (physics); 0 = the match default
};

struct DemoTeam {
    std::string name;            // game_demo_teams.name (the TEAMS frame)
    std::string formation_code;  // mig 636: the club formation this team plays; empty = the env's
    // Mig 639: kit colours 0xRRGGBB, -1 = the client's default.
    std::int32_t kit_shirt = -1, kit_shorts = -1, kit_socks = -1, kit_trim = -1;
    std::vector<DemoPlayer> players;  // lineup order (1-11 the formation slots), then the bench
};
std::optional<DemoTeam> loadDemoTeam(const DbConfig& cfg, const std::string& team_name);

// The match officials (G4.88, mig 822): the crew of `level` (the home
// team's band; falls back to semipro), each man's role and own ratings
// (game_official_ratings). Empty = the World's 50-rated crew.
struct CrewMember {
    int role = 0;                       // core::OfficialRole
    std::string name;
    std::map<std::string, int> ratings; // game_ref_attributes code → 0-100
};
std::vector<CrewMember> loadCrew(const DbConfig& cfg, const std::string& level);

// Every number the game's physics and player states read (game_model_params),
// keyed "owner.code.param". Empty on any failure — code defaults, loudly logged.
core::ModelParams loadModelParams(const DbConfig& cfg);

// G4.81b (mig 782): real-football reference values at a level band
// (game_benchmarks × game_benchmark_metrics), for the harness to print
// beside its own numbers. Empty on any failure.
struct Benchmark {
    std::string metric, label, unit, competition, season, source;
    int matches = 0;
    double value = 0;
};
std::vector<Benchmark> loadBenchmarks(const DbConfig& cfg, const std::string& level);

}  // namespace fh::game::persistence
