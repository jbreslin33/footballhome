// game/src/server/GameServer.hpp
//
// The match daemon's brain: owns the authoritative World, speaks fh-game.v1
// through an INetworkTransport, and enforces the slot-claim rules. One
// GameServer == one match (per-match daemon orchestration arrives later,
// [v1] pattern).
//
// Flow per tick (driven by the caller — main.cpp paces wall clock OUTSIDE
// the sim, so headless/fast-forward runs need no code change, DESIGN.md §4):
//   transport.poll() → intents land via onMessage → tickOnce() advances the
//   World and broadcasts one SNAPSHOT to every connected client.
//
// Claim rules (G0): every authenticated client gets kCapPlayer|kCapSpectator.
// A slot can be claimed by at most one client; a client may claim multiple
// slots ("human control of 1 or more players" — DESIGN.md §1). Intents for
// unclaimed/foreign slots are dropped silently — the server never trusts a
// client's slot field. [QUAKE]

#pragma once

#include "ai/Brain.hpp"
#include "core/ModelParams.hpp"
#include "core/Skill.hpp"
#include "persistence/FormationStore.hpp"
#include "common/IdTypes.hpp"
#include "core/World.hpp"
#include "net/Codec.hpp"
#include "net/INetworkTransport.hpp"

#include <cstdint>
#include <optional>
#include <unordered_map>

namespace fh::game::server {

class GameServer {
public:
    struct Config {
        std::uint64_t match_id   = 1;
        std::uint8_t  slot_count = 22;
        // 6 m/s shared max speed until attributes land (G2).
        std::int32_t  max_speed_mps = 6;
        // Pitch half-extents (m) sent in HELLO. Standard 105x68 pitch.
        std::int32_t  pitch_half_x = 52;  // 52.5 rounds to Fixed in ctor
        std::int32_t  pitch_half_y = 34;
        // 0 = untimed sandbox. The live daemon sets this from
        // GAME_HALF_MINUTES (main.cpp).
        std::uint32_t half_length_ticks = 0;
        // Formation shapes (loaded from the club DB by main.cpp); empty =
        // built-ins. Config, not state: loaded once at boot.
        ai::FormationSpec formation_home;
        ai::FormationSpec formation_away;
        // Skill levels (G4.3) + the match's noise seed.
        core::LevelParams level_home;
        core::LevelParams level_away;
        std::uint8_t level_home_id = 0;  // kLevelNames index (for the wire)
        std::uint8_t level_away_id = 0;
        std::uint64_t match_seed = 0;
        // users.id values holding the admin capability (club authz chain
        // users→admins; loaded at boot by main.cpp).
        std::vector<std::int64_t> admin_user_ids;
        // Fictional demo rosters (mig 628): names + per-slot speed +
        // concept overrides. Empty = generic slots at the band defaults.
        persistence::DemoTeam roster_home;
        persistence::DemoTeam roster_away;
        // Game models (mig 652; were the style presets): resolved demand
        // overlays. Wire id = index (PRESETS frame). Empty = the DB was
        // down; no PRESETS frame.
        std::vector<persistence::GameModel> models;
        // G4.32: the club DB, for an admin RELOAD_ROSTERS (lineups,
        // attributes, roles, kits edited from the page). Unset = no reload
        // (tests, DB-down boots).
        std::optional<persistence::DbConfig> db;
        // G4.33: game-model numbers (game_model_params) for the Skill and
        // Concept classes; empty = their seeded defaults.
        core::ModelParams model_params;
        // G4.57: direct-opponent pairs by position number (DB).
        std::vector<std::pair<int, int>> direct_pairs;
        // G4.58: phases of play (DB) for the admin RUN_PHASE frame.
        std::vector<persistence::Phase> phases;
    };

    GameServer(Config cfg, net::INetworkTransport& transport);

    // Advance one tick and broadcast one snapshot. The caller owns pacing.
    void tickOnce();
    // G4.58: set up phase `id` (cfg.phases) for `team` in possession —
    // all 22 placed in their organized shapes for that ball, then the
    // restart (keeper's ball / corner / kick-off) or the ball at the feet
    // of the team's nearest outfielder (open play). Coaching's phase of play.
    void runPhase(std::uint8_t team, std::size_t id);

    const core::World& world() const noexcept { return world_; }
    // Each slot's decision on the last tick (the brain overlay's read;
    // fh-game-match tallies pass outcomes by it).
    const std::vector<ai::Orders>& lastOrders() const noexcept { return last_orders_; }
    const std::vector<core::MatchEvent>& lastEvents() const noexcept { return last_events_; }

    // Exposed for tests.
    bool slotClaimedBy(std::uint8_t slot, ClientId client) const;

private:
    void onConnect(ClientId id, const auth::JwtClaims& claims);
    void onDisconnect(ClientId id);
    void onMessage(ClientId id, std::span<const std::uint8_t> bytes);

    void handleFrame(ClientId id, const net::DecodedFrame& frame);
    net::Bytes buildSnapshotFrame() const;

    Config cfg_;
    net::INetworkTransport& transport_;
    core::World world_;
    ai::Brain brain_;

    // slot → owning client. Absent key = AI-controlled (idle in G0).
    std::unordered_map<std::uint8_t, ClientId> slot_owner_;
    // Current level ids (mutable via admin MATCH_SETTINGS).
    std::uint8_t level_id_[2] = {0, 0};
    // Per-slot names + live concept RATINGS (served via ROSTER frames):
    // what each player PLAYS = min(his team model's demand, his ability).
    std::vector<std::string> slot_names_;
    std::vector<core::ConceptRatings> concept_ratings_;
    std::vector<core::ConceptRatings> ability_;   // what each player KNOWS
    int team_model_[2] = {-1, -1};                // index into cfg_.models
    void applyRosters();
    // Ability for one slot under a band: the band's defaults, then the
    // legacy mask, then the player's own rows.
    core::ConceptRatings buildAbility(std::uint8_t slot, const core::LevelParams& band) const;
    // Re-derive one team's played ratings from ability + its model.
    void recomputeKnowledge(bool home);
    // G4.30: each rostered player's level = his team band bent by his
    // attributes (core::levelForPlayer), into World + Brain. Re-run after
    // every band change (MATCH_SETTINGS) — attributes are the roster's.
    void applySlotLevels();
    core::SkillSet skills_;   // G4.33: one class per attribute
    // G4.32: send the TEAMS frame (names + kits) to one client / everyone.
    void sendTeams(ClientId id);
    void broadcastTeams();
    void broadcastRoster();
    // Clients holding the admin capability (granted from the JWT role).
    std::unordered_map<ClientId, bool> admins_;
    // G4.41 brain overlay: each slot's last decision, and who's watching.
    std::vector<ai::Orders> last_orders_;
    std::vector<core::MatchEvent> last_events_;   // the last tick's (tools read them)
    std::unordered_map<ClientId, bool> brain_watchers_;
    void sendBrain();
    // Connected clients, for snapshot fan-out. Keyed map (not vector) so
    // disconnect is O(1); iteration order doesn't matter — clients receive
    // identical bytes.
    std::unordered_map<ClientId, bool> clients_;
};

}  // namespace fh::game::server
