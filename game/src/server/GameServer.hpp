// game/src/server/GameServer.hpp
//
// The match daemon's brain: owns the authoritative World, speaks fh-game.v2
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
#include "persistence/FormationStore.hpp"
#include "common/IdTypes.hpp"
#include "core/World.hpp"
#include "net/Codec.hpp"
#include "net/INetworkTransport.hpp"

#include <cstdint>
#include <map>
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
        // The match's noise seed.
        std::uint64_t match_seed = 0;
        // users.id values holding the admin capability (club authz chain
        // users→admins; loaded at boot by main.cpp).
        std::vector<std::int64_t> admin_user_ids;
        // The teams (names, positions, kits, top speeds). Empty = generic slots.
        persistence::DemoTeam roster_home;
        persistence::DemoTeam roster_away;
        // G4.32: the club DB, for an admin RELOAD_ROSTERS (lineups,
        // attributes, roles, kits edited from the page). Unset = no reload
        // (tests, DB-down boots).
        std::optional<persistence::DbConfig> db;
        // The physics and player-state numbers (game_model_params); empty = code defaults.
        core::ModelParams model_params;
        // G4.88 (mig 822): the match officials — empty = a 50-rated crew.
        std::vector<persistence::CrewMember> crew;
    };

    GameServer(Config cfg, net::INetworkTransport& transport);

    // Advance one tick and broadcast one snapshot. The caller owns pacing.
    void tickOnce();
    // G4.61: sim speed, % of real time (0 = paused). The daemon's loop
    // paces ticks by it; the physics per tick never changes. Admins set
    // it live (SPEED 0x31); everyone watching is told.
    std::uint16_t speedPct() const noexcept { return speed_pct_; }
    void setSpeedPct(std::uint16_t pct);
    // Paused: a snapshot of the frozen world without a tick, so clients'
    // stale-socket watchdogs stay quiet.
    void heartbeat();

    const core::World& world() const noexcept { return world_; }
    // Each slot's decision on the last tick (the brain overlay's read;
    // fh-game-match tallies pass outcomes by it).
    const std::vector<ai::Orders>& lastOrders() const noexcept { return last_orders_; }
    const std::vector<core::MatchEvent>& lastEvents() const noexcept { return last_events_; }
    const ai::Brain& brain() const noexcept { return brain_; }

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
    std::uint16_t speed_pct_ = 100;
    std::vector<std::string> slot_names_;   // served via ROSTER frames
    void applyRosters();
    // G4.32: send the TEAMS frame (names + kits) to one client / everyone.
    void sendTeams(ClientId id);
    void broadcastTeams();
    void broadcastRoster();
    // Clients holding the admin capability (granted from the JWT role).
    std::unordered_map<ClientId, bool> admins_;
    // G4.41 brain overlay: each slot's last decision, and who's watching.
    std::vector<ai::Orders> last_orders_;
    std::vector<core::MatchEvent> last_events_;   // the last tick's (tools read them)
    // G4.93: which official's flag is up (OfficialRole index, -1 none), till when.
    static constexpr std::uint64_t kFlagUpTicks = 45;   // 1.5 s
    int flag_official_ = -1;
    std::uint64_t flag_until_tick_ = 0;
    // G5.2: the signal for a ball out — who gave it, what (OfficialSnap bits
    // 1-3), until the ball is played or kSignalTicks. The referee repeats it.
    static constexpr std::uint64_t kSignalTicks = 150;   // 5 s
    static constexpr std::uint64_t kHumanRestartTicks = 300;   // 10 s [FH]
    int signal_official_ = -1;
    std::uint8_t signal_code_ = 0;
    std::uint64_t signal_until_tick_ = 0;
    std::unordered_map<ClientId, bool> brain_watchers_;
    void sendBrain();
    // Connected clients, for snapshot fan-out. Keyed map (not vector) so
    // disconnect is O(1); iteration order doesn't matter — clients receive
    // identical bytes.
    std::unordered_map<ClientId, bool> clients_;
};

}  // namespace fh::game::server
