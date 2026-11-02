// game/src/core/Officials.hpp — the match officials (G4.88, mig 822).
//
// James 10/29: "we need an ai ref. that has its own taxonomy of what he
// sees adn understands". Until G4.88 the World WAS the referee: exact
// positions at the instant of every kick, never wrong. Now a crew of three
// — a referee and two assistants — are bodies on the pitch (core::Body, the
// players' own locomotion law), each standing where his positioning row
// puts him (game_ref_positionings), and the offside call is the ASSISTANT'S,
// made from where he stands at the kick (game_ref_judgements
// offside-position, game_ref_perceptions kick-moment-and-line +
// line-from-his-angle). The World keeps the truth beside it, for the harness
// only.
//
// The officials are not in the players' slots: the wire, the clients and the
// brains see 22 players as before. They are World state (hashed), moved
// after the players each tick.
//
// Sources: IFAB Laws of the Game, Law 11; IFAB Practical Guidelines
// (assistant in line with the second-last defender or the ball if nearer the
// goal line; the referee's wide diagonal); Oudejans et al. 2000 [optical
// error: an assistant beyond the line sees a far-side attacker ahead];
// Helsen, Gilis & Weston 2006 [flash-lag: most errors are flags].
#pragma once

#include "core/Locomotion.hpp"
#include "core/ModelParams.hpp"
#include "math/Fixed64.hpp"
#include "math/Vec3.hpp"

#include <array>
#include <cstdint>

namespace fh::game::core {

class World;

// game_officials.role: assistant 1 runs the +y touchline and judges the +x
// half, assistant 2 the -y touchline and the -x half — the diagonal.
enum class OfficialRole : std::uint8_t { Referee = 0, Assistant1 = 1, Assistant2 = 2 };
inline constexpr int kOfficialCount = 3;

struct OfficialState {
    math::Vec3 pos{};
    math::Vec3 vel{};
    math::Vec2 face{math::Fixed64::one(), math::Fixed64::zero()};
};

// An official's own ratings (game_ref_attributes, 0-100); -1 = a 50.
struct OfficialRatings {
    std::int16_t pace = -1;
    std::int16_t acceleration = -1;
    std::int16_t positioning = -1;
    std::int16_t offside_judgement = -1;
};

// What the assistant judged at the last kick (the harness reads it).
struct OffsideCall {
    std::uint32_t called = 0;   // the men he flagged
    std::uint32_t truth = 0;    // the men in an offside position
    int assistant = -1;         // which official judged (OfficialRole)
    math::Fixed64 off_line_m{}; // how far he stood from level with the line (+ = beyond it)
};

// The call on a ball out of play (G5.2, judgement ball-out-last-touch): the
// whole ball over a line is plain to see; WHO touched it last is not, when it
// came off a man. The World keeps the truth beside the call, for the harness.
struct OutCall {
    int official = -1;              // who called it (OfficialRole)
    std::uint8_t truth = 0xFF;      // the team that really touched it last
    std::uint8_t called = 0xFF;     // the team he says touched it last
    bool deflection = false;        // it came off a man just before it went out
    math::Fixed64 dist_m{};         // how far he was from that touch
};

class Officials {
public:
    void configure(const ModelParams& p);
    void setOfficial(OfficialRole role, const OfficialRatings& r, const Body& body,
                     math::Fixed64 max_speed);
    // Kick-off spots: the referee in the centre circle's edge, each
    // assistant on his touchline at halfway.
    void place(math::Fixed64 half_x, math::Fixed64 half_y);
    // Scenario setup (tests): put one official on a spot, standing.
    void placeOfficial(OfficialRole role, const math::Vec3& pos) {
        state_[static_cast<int>(role)].pos = pos;
        state_[static_cast<int>(role)].vel = math::Vec3{};
    }
    // Positioning (game_ref_positionings), one tick of the body law each.
    void tick(const World& w);

    // Law 11.1 offside position at the moment `kicker` plays the ball,
    // judged by the assistant covering the half the attack goes into, from
    // where he stands (judgement offside-position). Returns the call; its
    // `called` mask is what the whistle uses.
    OffsideCall judgeOffsidePosition(const World& w, std::uint8_t kicker) const;
    // The law exactly — the truth the World keeps for the harness.
    static std::uint32_t offsidePositionTruth(const World& w, std::uint8_t kicker);

    // Law 9, Law 6 (G5.2): whose line it is — each assistant calls his own
    // touchline in his half and his goal line; the far half of a touchline
    // is the referee's, the diagonal's other end.
    static int officialFor(const math::Vec2& crossed, bool end_line);
    // His call on who touched it last, from where he stands now. `other` =
    // the team that touched it before; a clean ball out is never wrong.
    OutCall judgeOutOfPlay(const World& w, const math::Vec2& crossed, bool end_line, bool deflected,
                           const math::Vec2& touch_at, std::uint8_t last, std::uint8_t other) const;
    // The dead ball's clock (G5.2, owner 'official', row 'restart'), ticks.
    std::uint32_t callTicks() const { return call_ticks_; }
    std::uint32_t retrieveTicks() const { return retrieve_ticks_; }
    std::uint32_t readyTicksThrow() const { return ready_ticks_[0]; }
    std::uint32_t readyTicksGoalKick() const { return ready_ticks_[1]; }
    std::uint32_t readyTicksCorner() const { return ready_ticks_[2]; }
    std::uint32_t deflectionTicks() const { return deflection_ticks_; }
    math::Fixed64 throwMaxM() const { return throw_max_m_; }

    const OfficialState& official(int i) const { return state_[i]; }
    const Body& body(int i) const { return body_[i]; }
    math::Fixed64 maxSpeed(int i) const { return top_[i]; }

private:
    // Where official i should stand; line_vel = the line's velocity there
    // (assistants), for shadowing it.
    math::Vec2 spotFor(int i, const World& w, math::Vec2* line_vel = nullptr) const;
    static math::Fixed64 byRating(std::int16_t r, math::Fixed64 at0, math::Fixed64 at50, math::Fixed64 at100);

    std::array<OfficialState, kOfficialCount> state_{};
    std::array<Body, kOfficialCount> body_{};
    std::array<math::Fixed64, kOfficialCount> top_{};
    std::array<OfficialRatings, kOfficialCount> ratings_{};
    // game_model_params owner 'official' (mig 822).
    math::Fixed64 flash_lag_s_ = math::Fixed64::fromFraction(8, 100);
    math::Fixed64 noise_[3] = {math::Fixed64::one(), math::Fixed64::fromFraction(1, 2),
                               math::Fixed64::fromFraction(1, 5)};
    // How stale his read of the line is (s), by positioning (G4.90).
    // An assistant closes his gap to the line over this long (s), G4.90.
    math::Fixed64 track_s_ = math::Fixed64::fromFraction(1, 2);
    math::Fixed64 lag_[3] = {math::Fixed64::fromFraction(6, 10), math::Fixed64::fromFraction(3, 10),
                             math::Fixed64::fromFraction(1, 10)};
    math::Fixed64 touchline_off_ = math::Fixed64::one();
    math::Fixed64 diagonal_share_ = math::Fixed64::fromFraction(6, 10);
    math::Fixed64 ball_pull_ = math::Fixed64::fromFraction(1, 2);
    math::Fixed64 behind_ = math::Fixed64::fromInt(8);
    // G5.2 (mig 922). Restart times = StatsBomb PL 2015/16 lower quartile of
    // the dead time (the taker's own seconds come on top); call + fetch FH.
    std::uint32_t call_ticks_ = 12, retrieve_ticks_ = 45;
    std::uint32_t ready_ticks_[3] = {252, 654, 636};   // throw, goal kick, corner
    std::uint32_t deflection_ticks_ = 30;
    math::Fixed64 wrong_pct_per_10m_ = math::Fixed64::fromInt(5);
    math::Fixed64 wrong_pct_max_ = math::Fixed64::fromInt(30);
    math::Fixed64 throw_max_m_ = math::Fixed64::fromInt(28);
};

}  // namespace fh::game::core
