// game/src/teach/TeachingServer.hpp
//
// The teaching room (docs/teaching-room.md; owner 11/24: "i want a teaching room/sandbox
// that does not touch game … the sandbox uses the game engine … maybe it extends the
// classes"). A GameServer child: the same World, the same Brain, the same room controls
// (pause, slow, step pass by pass) — and ONE override. While their side has the ball,
// each outfielder of ours goes where his JOB in a club tactic plan puts him, solved by
// shared/tactics/TacticGeometry.hpp from where their men really stand this tick, instead
// of where the engine's measured block would. Their side — and ours the moment we win
// it — is the engine as it is.
//
// The live match and a Premier League practice room are plain GameServers: nothing here
// can reach them. This file uses floating point (the shared solver's); a teaching room
// is a lesson, not a golden — src/teach is outside the determinism lint on purpose.

#pragma once

#include "server/GameServer.hpp"
#include "teach/TeachingPlan.hpp"

namespace fh::game::teach {

class TeachingServer final : public server::GameServer {
public:
    // `us` = the side that runs the plan (0 home, 1 away); the other takes the goal kick.
    TeachingServer(Config cfg, net::INetworkTransport& transport, Plan plan, std::uint8_t us);

    // Probes (tests): the step the room is on, and whether a man is on his plan job now.
    int stateId() const { return cur_ ? cur_->id : 0; }
    bool onJob(std::uint8_t slot) const { return slot < 32 && on_job_[slot]; }

protected:
    ai::Orders decide(std::uint8_t slot) override;
    std::uint8_t conceptOf(std::uint8_t slot, const ai::Orders& o) const override;

private:
    std::uint8_t teamOf(std::uint8_t slot) const { return slot < cfg_.slot_count / 2 ? 0 : 1; }
    void solve();   // once a tick, on the first of ours asked

    Plan plan_;
    std::uint8_t us_, them_;
    const PlanState* cur_ = nullptr;
    std::uint64_t solved_tick_ = ~0ull;
    bool active_ = false;          // their ball: the plan places us
    int last_owner_ = -1;          // their last man on it
    int receiver_ = -1;            // the man their pass in flight is for
    bool has_[32]{};               // a plan spot this tick
    math::Vec2 spot_[32]{};
    std::int16_t other_[32]{};     // the man his job names first (slot), -1 none
    std::uint8_t concept_[32]{};   // his job's game concept (255 none)
    bool on_job_[32]{};            // he took his plan spot on the last decide
};

}  // namespace fh::game::teach
