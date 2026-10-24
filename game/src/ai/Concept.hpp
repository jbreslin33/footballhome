// game/src/ai/Concept.hpp
//
// Concepts as classes (G4.33). James: "each concept is a class? extended
// from concept? … no hard code. all comes from db and oop".
//
// A Concept knows its curriculum name + id (core::concepts(), game_concepts
// mig 650; the wire and game_demo_player_concepts use the name) and its
// numbers, which come
// from game_model_params ("concept.<name>.<param>", mig 642; constructor
// defaults = the seeded rows, used only without a DB). The Brain asks it
// at the phase it belongs to; WHETHER a player uses it this tick is still
// his 0-100 rating rolled by the Brain (graded knowledge, CONCEPTS.md).
//
// The 26 concepts that predate G4.33 still live inline in Brain.cpp and
// move into classes one at a time, each move held to the goldens.
//
// Sources: [Bielsa] man-oriented marking with a free +1 (libero) and the 9
// pressing on a cover shadow; [Sacchi] palla coperta / scoperta — the line
// steps up on a covered ball, drops on an uncovered one (the same rule in
// the FA, KNVB and DFB back-four models); [Bielsa-Leeds] the Leeds 2019/20
// tactical analysis (CONCEPTS.md G4.35) — the pass ladder.

#pragma once

#include "core/ModelParams.hpp"
#include "core/World.hpp"
#include "math/Vec3.hpp"

#include <cstdint>
#include <functional>
#include <optional>
#include <string>

namespace fh::game::ai {

// What a concept may look at this tick. sign = the player's attack
// direction along x (+1 / -1).
struct ConceptContext {
    const core::World& world;
    core::SlotIndex slot;
    int sign;
    math::Vec2 seen_ball;     // the ball as this player perceives it
    math::Fixed64 half_x;     // pitch half-length
    math::Fixed64 degree;     // this player's rating as 0..1
    // The flight read (G4.49) for a free ball: the team that takes it
    // first (-1 = none / the ball is owned) and where.
    int flight_first = -1;
    math::Vec2 flight_at{};
};

class Concept {
public:
    Concept(std::string name, int bit) : name_(std::move(name)), bit_(bit) {}
    virtual ~Concept() = default;
    const std::string& name() const { return name_; }
    int bit() const { return bit_; }
    virtual void configure(const core::ModelParams&) {}

protected:
    std::string key(const char* param) const { return "concept." + name_ + "." + param; }

private:
    std::string name_;
    int bit_;
};

// The free +1 [Bielsa]: marks nobody and moves into the ball's channel —
// channels 2-4 only (James: "avoids channels 1 and 5 unless absolutely
// needed": the long ball dropping out wide is the absolutely-needed). In the
// defensive phase he is PART OF THE LINE — level with the deepest teammate,
// stepping with it, holding the offside — and drops a few metres behind it
// only when their carrier can play long forward (an uncovered ball, the
// line step's own test); a long ball in the air he meets where it lands.
// James 10/23: "libero should stay with line until ball carrier can play
// long forward. that is standard." (G4.45 — the old always-deep libero
// played everyone onside: Lighthouse measured +0.22 WITHOUT him.)
class Libero : public Concept {
public:
    Libero() : Concept("libero", 26) {}
    void configure(const core::ModelParams& p) override;
    // Where he should be (their ball). Never empty. can_play_long = their
    // carrier is free to play forward (LineStep::covered() is false).
    math::Vec2 target(const ConceptContext& c, bool can_play_long) const;
    // How long one lapse lasts: the ability roll is per window, so a
    // switched-off libero stays switched off a few seconds (mig 668).
    std::int32_t lapseWindowTicks() const { return lapse_window_ticks_; }

private:
    math::Fixed64 depth_min_, depth_span_, follow_, lateral_max_, lead_s_, long_ball_z_, level_;
    std::int32_t lapse_window_ticks_ = 90;
};

// The libero's two LAPSES (G4.46, mig 668). James: "a bad libero will lag
// behind the line too much and also get caught too high up" / "they drift
// into another concept not in the game model … which is a concept that is
// good in other systems". No "bad" concepts: each is right somewhere.
//
// Deep sweeper — catenaccio's libero [Herrera/Rocco]: always a few metres
// BEHIND the line, ball covered or not; right in a deep block against pace,
// wrong behind a stepping line (he plays everyone onside).
class DeepSweeper : public Concept {
public:
    DeepSweeper() : Concept("deep-sweeper", 149) {}
    void configure(const core::ModelParams& p) override;
    math::Vec2 target(const ConceptContext& c) const;

private:
    math::Fixed64 depth_, follow_, lateral_max_, lead_s_, long_ball_z_;
};

// Step out — the front-foot defender [Gasperini/Bielsa man-orientation]:
// leaves the line to engage the man receiving between the lines, in his
// channel; right in an aggressive man-oriented press, wrong as the spare
// man (he's caught high when the ball goes in behind).
class StepOut : public Concept {
public:
    StepOut() : Concept("step-out", 150) {}
    void configure(const core::ModelParams& p) override;
    math::Vec2 target(const ConceptContext& c) const;

private:
    math::Fixed64 reach_, channel_, gap_, step_, follow_, lateral_max_;
};

// The 9's press on their building centre back [Bielsa]: run at him along
// the line to his nearest midfield receiver, the pass in your shadow.
class CoverShadow : public Concept {
public:
    CoverShadow() : Concept("cover-shadow", 27) {}
    void configure(const core::ModelParams& p) override;
    // A target when their CB is carrying out of the back, else nothing
    // (the normal press handles the rest).
    std::optional<math::Vec2> target(const ConceptContext& c) const;

private:
    math::Fixed64 deep_x_, handover_, gap_, lane_width_, ahead_;
};

// Palla coperta / scoperta [Sacchi]: the back line STEPS UP while the ball
// is covered — travelling between their players, or at the feet of a man
// turned toward his own goal or under pressure — and stops when a free
// opponent is receiving facing forward (he can play long). A ball in the
// air is read by its flight (G4.49): ours to win = covered; THEIR ball
// played forward to them (a long ball over the line) = uncovered, drop.
class LineStep : public Concept {
public:
    LineStep() : Concept("line-step", 28) {}
    void configure(const core::ModelParams& p) override;
    // The line (x · sign, own-goal negative) to step up to while the ball
    // is covered; empty when it's uncovered (hold / drop).
    std::optional<math::Fixed64> stepLine(const ConceptContext& c) const;
    bool covered(const ConceptContext& c) const;

private:
    math::Fixed64 step_behind_, receive_radius_, pressure_radius_, moving_speed_, forward_;
};

// The pass ladder [Bielsa-Leeds ch4]: the passer's order of looking
// forward, like a quarterback's progressions —
//   1 behind their back line, central   2 behind it, wide
//   3 in front of it, central           4 in front of it, wide
//   5 past their first line, central    6 past it, wide
// 0 = not past their first line (off the ladder). Lower rung wins, more
// progress breaks the tie; a reachable rung up to fireRung(rating) is
// played at once — no "is it worth it" gain threshold. Lane + interceptor
// safety stay the Brain's existing safe_pass gate.
// Rungs 1-2 are a ball into SPACE (G4.36): a receiver standing beyond
// their line is offside, so a laddered passer skips anyone in an offside
// position and plays an onside runner where he will be (leadPoint).
class PassLadder : public Concept {
public:
    PassLadder() : Concept("pass-ladder", 29) {}
    void configure(const core::ModelParams& p) override;
    // Their lines, as x · sign (toward the goal we attack).
    struct Lines {
        math::Fixed64 back;     // deepest outfield opponent
        math::Fixed64 first;    // most advanced outfield opponent
        math::Fixed64 offside;  // second-last opponent, keeper included
    };
    Lines lines(const core::World& w, core::SlotIndex passer, int sign) const;
    int rung(math::Fixed64 progress, math::Fixed64 y, const Lines& l) const;
    // Rungs 1..fireRung are played without the gain threshold.
    int fireRung(math::Fixed64 degree) const;
    // Offside position by the law (beyond the second-last opponent, the
    // ball and halfway) — the World arms exactly this on the kick.
    static bool offsidePosition(math::Fixed64 progress, math::Fixed64 ball_progress,
                                const Lines& l);
    // Where to play a moving receiver from `from`: as far along his run as
    // he gets while the ball travels (reaction + distance / pass speed).
    math::Vec2 leadPoint(const core::PlayerState& p, const math::Vec3& from) const;
    // Is (rung a, progress a) a better target than (rung b, progress b)?
    static bool better(int ra, math::Fixed64 pa, int rb, math::Fixed64 pb);

private:
    math::Fixed64 pocket_depth_, central_half_width_, fire_span_, lead_s_, pass_speed_;
    int fire_min_ = 2;
};

// The blind-side run [Bielsa-Leeds f7/21/35/46/48/51/65/78/81/82] — the
// Bamford/Harrison run. Up at their line, the runner waits ONSIDE on the
// far-from-ball shoulder of his nearest line defender; he goes when the
// man on the ball has TIME to play (nobody within carrier_free_m — the
// book's cue is the passer turning forward, f82, but our carriers always
// face their dribble, so "free to pass" is the honest equivalent) and
// that defender can't see him (he is behind his facing — ball-watching,
// f81): a diagonal across the defender's back into the space behind. The
// laddered passer leads him (PassLadder::leadPoint). Only the team's
// max_runners most advanced attackers make it (the 9 and a winger / 8).
class BlindSideRun : public Concept {
public:
    BlindSideRun() : Concept("blind-side-run", 30) {}
    void configure(const core::ModelParams& p) override;
    // Where this attacker should be on our ball; empty when he isn't up
    // at their line with a defender to beat (other duties take over).
    std::optional<math::Vec2> target(const ConceptContext& c) const;
    // The cue: the carrier is free to pass and the marker can't see me.
    bool go(const ConceptContext& c, core::SlotIndex marker) const;

private:
    math::Fixed64 line_band_, marker_radius_, shoulder_, onside_margin_,
        run_depth_, channel_pull_, carrier_free_, blind_cos_, end_margin_;
    int max_runners_ = 2;
};

// Release timing [Bielsa-Leeds f54/f67/f71] — the passer's half of the
// blind-side run (G4.44): a teammate is attacking their line — onside,
// moving forward at pace, within approach_m of it — so an unpressed carrier
// HOLDS the ball (keeps carrying) and plays only the ball in behind (ladder
// rungs 1-2) once it is on: his lead point beyond the line, in range, lane
// open. A runner who slows, or runs offside, ends the hold. Curriculum id 60.
class ReleaseTiming : public Concept {
public:
    ReleaseTiming() : Concept("release-timing", 60) {}
    void configure(const core::ModelParams& p) override;
    bool hold(const core::World& w, core::SlotIndex carrier, int sign,
              const PassLadder::Lines& l, const PassLadder& ladder) const;

private:
    math::Fixed64 approach_, runner_speed_;
};

// The class-based concepts a Brain carries.

// The pass ladder's two LAPSES — and two Football Manager-style
// TENDENCIES (G4.47, mig 669). James: "like football manager … tries short
// passes at a certain percent. tries long balls?" Each is right in its own
// system; for a laddered side it's what he does instead of looking up.
//
// Short simple — the possession habit [Guardiola juego de posición]: the
// nearest open man, sideways or back is fine.
class ShortSimple : public Concept {
public:
    ShortSimple() : Concept("short-simple", 151) {}
    void configure(const core::ModelParams& p) override;
    using LaneOpen = std::function<bool(const math::Vec2&, const math::Vec2&)>;
    std::optional<core::SlotIndex> pick(const ConceptContext& c, const LaneOpen& open) const;

private:
    math::Fixed64 min_, max_, back_;
};

// Direct ball — route one [Reep]: lofted to the furthest-forward man in
// range, over whatever is in the lane, dropped where he'll be (G4.48's
// aimed loft; max_m = the passer's range).
class DirectBall : public Concept {
public:
    DirectBall() : Concept("direct-ball", 152) {}
    void configure(const core::ModelParams& p) override;
    std::optional<core::SlotIndex> pick(const ConceptContext& c) const;
    // The passer's lofted range (G4.48): also caps an over-the-top ball.
    math::Fixed64 maxRange() const { return max_; }

private:
    math::Fixed64 min_gain_, min_, max_;
};

// Meet the pass (G4.49) [Buckland's ReceiveBall state, re-expressed
// stateless; Wiel Coerver / every coaching manual: "come to the ball"]: our
// ball is travelling — the man who can take it first goes to the point
// where he can, and the rest keep playing as if we have it, because we
// will. Without it the receiver stood still and the whole team turned back
// to defend its own pass (a free ball read as THEIR ball): Lighthouse's
// intended receiver got 24% of passes, the ball in behind 2%. Curriculum id
// 153; the other side's half of the same read is intercept (20).
class MeetThePass : public Concept {
public:
    MeetThePass() : Concept("meet-the-pass", 153) {}
    void configure(const core::ModelParams& p) override;
    math::Fixed64 reaction() const { return reaction_; }
    int horizonTicks() const { return horizon_ticks_; }
    // A runner ahead of our ball in flight keeps going at least this fast.
    math::Fixed64 keepRunningSpeed() const { return keep_running_; }

private:
    math::Fixed64 reaction_, keep_running_;
    int horizon_ticks_ = 90;
};

struct ConceptBook {
    Libero libero;
    CoverShadow cover_shadow;
    LineStep line_step;
    PassLadder pass_ladder;
    BlindSideRun blind_side_run;
    ReleaseTiming release_timing;
    DeepSweeper deep_sweeper;
    StepOut step_out;
    ShortSimple short_simple;
    DirectBall direct_ball;
    MeetThePass meet_the_pass;
    ConceptBook() { configure(core::ModelParams{}); }
    void configure(const core::ModelParams& p) {
        libero.configure(p);
        cover_shadow.configure(p);
        line_step.configure(p);
        pass_ladder.configure(p);
        blind_side_run.configure(p);
        release_timing.configure(p);
        deep_sweeper.configure(p);
        step_out.configure(p);
        short_simple.configure(p);
        direct_ball.configure(p);
        meet_the_pass.configure(p);
    }
};

}  // namespace fh::game::ai
