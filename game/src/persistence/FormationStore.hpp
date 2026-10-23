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
#include "core/Levels.hpp"

#include <optional>
#include <string>

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

// Fictional demo rosters (migration 628; game/CONCEPTS.md §registry).
struct DemoPlayer {
    std::string name;
    std::int32_t max_speed_cms = 600;
    std::int32_t concept_mask = -1;  // -1 = use the band bundle
    // Mig 636 (G4.30): per-player attributes (-1 = band), the formation
    // slot label he boots in ('SUB' = bench) and James's description.
    core::PlayerAttributes attrs;
    std::string position;
    std::string description;
    // Mig 639 (G4.31): knowledge overrides — (concept index, 0-100),
    // applied after the team's style preset (a role beats the identity).
    std::vector<std::pair<int, std::uint8_t>> concepts;
};
struct DemoTeam {
    std::string name;  // game_demo_teams.name (the TEAMS frame)
    std::string level_band;
    // Mig 631: the style preset this team WEARS — overlaid onto its
    // ratings at boot and after band changes. Empty = none.
    std::string style_preset;
    // Mig 636: the club formation code this team plays (overrides
    // GAME_FORMATION_*). Empty = the env's choice.
    std::string formation_code;
    // Mig 639: kit colours 0xRRGGBB, -1 = the client's default.
    std::int32_t kit_shirt = -1, kit_shorts = -1, kit_socks = -1, kit_trim = -1;
    std::vector<DemoPlayer> players;  // shirt order (1 = GK; past 11 = bench)
};
std::optional<DemoTeam> loadDemoTeam(const DbConfig& cfg,
                                     const std::string& team_name);

// Style presets (migration 630; game/CONCEPTS.md "Schools & auteurs").
// overlay: -1 = dial untouched, 0-100 = set it. Rows carry concept NAMES;
// unknown names (queued concepts) are skipped with a log. Empty vector on
// any failure — the sandbox boots preset-less, loudly.
struct StylePreset {
    std::string name;
    core::PresetOverlay overlay;  // kConceptNames order
};
std::vector<StylePreset> loadStylePresets(const DbConfig& cfg);

}  // namespace fh::game::persistence
