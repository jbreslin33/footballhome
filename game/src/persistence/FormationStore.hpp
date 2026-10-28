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
#include "core/ConceptRegistry.hpp"
#include "core/ModelParams.hpp"

#include <map>
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

// G4.57: direct-opponent pairs by position number (game_direct_opponents):
// (number, opponent_number) — our 9's are their 4 and 5, and so on.
std::vector<std::pair<int, int>> loadDirectOpponents(const DbConfig& cfg);

// Fictional demo rosters (migration 628; game/CONCEPTS.md §registry).
struct DemoPlayer {
    std::string name;
    std::int32_t max_speed_cms = 600;
    std::int32_t concept_mask = -1;  // -1 = use the band bundle
    // Mig 656: his overall ability from his teams' records (0-100; -1 = the
    // team's, else the band's) — his default on every concept his band knows.
    std::int16_t quality = -1;
    // Mig 636 (G4.30): per-player attributes (-1 = band), the formation
    // slot label he boots in ('SUB' = bench) and James's description.
    core::PlayerAttributes attrs;
    std::string position;
    std::string description;
    // Mig 639 (G4.31): the player's own ABILITY rows — (concept id, 0-100)
    // over his band's (mig 652: he plays min(demand, ability)).
    std::vector<std::pair<int, std::uint8_t>> concepts;
    // Mig 669 (G4.47): his TENDENCIES — (concept id, 0-100; 50 = neutral):
    // how much he likes a concept, apart from how well he does it.
    std::vector<std::pair<int, std::uint8_t>> tendencies;
    // Mig 793 (G4.83): his sheet's life — age, when he started, years out;
    // -1 = no sheet (the band's flat ability).
    std::int16_t age = -1, start_age = -1, years_off = 0;
};
// G4.58: a phase of play (game_phases): what restart, where the ball is —
// x_pct up the pitch from the team in possession's own goal line (0-100),
// y_pct across it (-100 right … +100 left, from that team's view).
struct Phase {
    std::string code, title, kind;   // kind: keeper | open | kickoff | corner
    int x_pct = 50, y_pct = 0;
    // The defending team's most advanced outfield line, % up from the
    // possessing team's goal line; -1 = its natural shape (mig 696).
    int press_line_pct = -1;
};
std::vector<Phase> loadPhases(const DbConfig& cfg);
// Restart shapes (mig 697): where the team in possession stands for a
// phase, per formation and position number, in metres (depth from its own
// goal line, width + = left from its view).
struct PhasePosition {
    std::string phase, formation, side = "in";   // side: in | out (mig 698)
    int number = 0;
    int depth_cm = 0, width_cm = 0;
};
std::vector<PhasePosition> loadPhasePositions(const DbConfig& cfg);

struct DemoTeam {
    std::string name;  // game_demo_teams.name (the TEAMS frame)
    std::string level_band;
    // Mig 652: the game model this team plays (game_models.name; was the
    // style preset, mig 631) — its DEMAND. Empty = none (core concepts
    // asked in full, style concepts not at all — DB-less boots only; since
    // mig 762 every DB team names one, "Curriculum" when it has no coach).
    std::string game_model;
    std::int16_t quality = -1;   // mig 656: team strength from its record; -1 = the band
    // Mig 636: the club formation code this team plays (overrides
    // GAME_FORMATION_*). Empty = the env's choice.
    std::string formation_code;
    // Mig 639: kit colours 0xRRGGBB, -1 = the client's default.
    std::int32_t kit_shirt = -1, kit_shorts = -1, kit_socks = -1, kit_trim = -1;
    std::vector<DemoPlayer> players;  // shirt order (1 = GK; past 11 = bench)
};
std::optional<DemoTeam> loadDemoTeam(const DbConfig& cfg,
                                     const std::string& team_name);

// Game models (mig 652; were the style presets, mig 630): a school, club,
// federation, formation or team model — its DEMAND per concept id
// (-1 = doesn't say, 0-100 = asks this much). A model inherits every
// demand of its parent it doesn't set itself (a team model = its school
// plus changes); loadGameModels returns them RESOLVED. Empty on failure.
struct GameModel {
    std::string name;
    std::string parent;           // "" = none
    core::PresetOverlay overlay;  // by curriculum id (game_concepts)
    // G4.68 (mig 747): defend-your-man's 3 rules by third, [zone][rung]
    // (zone 0 our third / 1 middle / 2 theirs; rung 0 intercept / 1 no turn /
    // 2 contain); -1 = inherit from the parent, 100 when nobody sets it.
    std::int16_t ladder[3][3] = {{-1, -1, -1}, {-1, -1, -1}, {-1, -1, -1}};
    // G4.76 (mig 762): what the model's OWN rows say (before inheritance —
    // what the HUD saves and clears), and which model each resolved demand
    // came from (index into the models vector; -1 = nobody). Filled by
    // resolveGameModels, so it can run again after a save.
    core::PresetOverlay own;
    std::int16_t own_ladder[3][3] = {{-1, -1, -1}, {-1, -1, -1}, {-1, -1, -1}};
    std::array<std::int16_t, core::kMaxConcepts> origin;
    std::int16_t ladder_origin[3][3] = {{-1, -1, -1}, {-1, -1, -1}, {-1, -1, -1}};
    // G4.76: the model's own concept numbers (game_model_concept_params),
    // milli-units keyed like game_model_params ("concept.<code>.<param>"),
    // resolved through the parent chain the same way; a number nobody in
    // the chain sets is the global game_model_params row.
    std::map<std::string, std::int64_t> own_params, params;
    std::map<std::string, int> param_origin;
    bool resolved = false;
};
std::vector<GameModel> loadGameModels(const DbConfig& cfg);
// Fold each model's parent chain into its overlay (own demand wins; a
// cycle or a missing parent just stops the chain).
void resolveGameModels(std::vector<GameModel>& models);
// G4.76 (mig 762, the HUD's Save): write one model's own demand for one
// concept (demand < 0 = delete the row: inherit from the parent; refused by
// the DB for a top-level model, which must state every concept).
bool saveModelDemand(const DbConfig& cfg, const std::string& model,
                     int concept_id, int demand);
// G4.76: one number into a model — "concept.<code>.<param>" →
// game_model_concept_params, "ladder.<zone>.<rung>" → game_model_ladder
// (milli; nullopt = delete the model's own row: inherit). False on failure
// (a top-level model can't lose a ladder cell).
bool saveModelParam(const DbConfig& cfg, const std::string& model,
                    const std::string& key, std::optional<std::int64_t> milli);
// Every concept number the HUD can tune: its key and unit (game_model_params,
// owner 'concept'), in a stable order.
struct ParamInfo { std::string key, unit; };
std::vector<ParamInfo> loadConceptParamInfo(const DbConfig& cfg);

// G4.33 (mig 642): every number the Skill / Concept classes use, keyed
// "owner.code.param". Empty on any failure — the classes keep their
// seeded defaults, loudly logged.
core::ModelParams loadModelParams(const DbConfig& cfg);

// G4.37 (mig 650): the curriculum — every concept by stable id, with the
// level it is a default from. Empty on any failure (keep builtin()).
std::optional<core::ConceptRegistry> loadConcepts(const DbConfig& cfg);

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
