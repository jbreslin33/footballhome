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
#include "common/IdTypes.hpp"
#include "core/World.hpp"
#include "net/Codec.hpp"
#include "net/INetworkTransport.hpp"

#include <cstdint>
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
    };

    GameServer(Config cfg, net::INetworkTransport& transport);

    // Advance one tick and broadcast one snapshot. The caller owns pacing.
    void tickOnce();

    const core::World& world() const noexcept { return world_; }

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
    // Clients holding the admin capability (granted from the JWT role).
    std::unordered_map<ClientId, bool> admins_;
    // Connected clients, for snapshot fan-out. Keyed map (not vector) so
    // disconnect is O(1); iteration order doesn't matter — clients receive
    // identical bytes.
    std::unordered_map<ClientId, bool> clients_;
};

}  // namespace fh::game::server
