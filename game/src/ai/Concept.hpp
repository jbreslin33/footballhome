// game/src/ai/Concept.hpp
//
// Concepts as classes (G4.33). James: "each concept is a class? extended
// from concept? … no hard code. all comes from db and oop".
//
// A Concept knows its registry name + bit (core::kConceptNames — the wire
// and game_demo_player_concepts use the name) and its numbers, which come
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
// the FA, KNVB and DFB back-four models).

#pragma once

#include "core/ModelParams.hpp"
#include "core/World.hpp"
#include "math/Vec3.hpp"

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

// The free +1 [Bielsa]: marks nobody; shadows the ball across, a few metres
// BEHIND the deepest teammate, and meets a long ball where it drops.
class Libero : public Concept {
public:
    Libero() : Concept("libero", 26) {}
    void configure(const core::ModelParams& p) override;
    // Where he should be (their ball). Never empty.
    math::Vec2 target(const ConceptContext& c) const;

private:
    math::Fixed64 depth_min_, depth_span_, follow_, lateral_max_, lead_s_, long_ball_z_;
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
// opponent is receiving facing forward (he can play long).
class LineStep : public Concept {
public:
    LineStep() : Concept("line-step", 28) {}
    void configure(const core::ModelParams& p) override;
    // The line (x · sign, own-goal negative) to step up to while the ball
    // is covered; empty when it's uncovered (hold / drop).
    std::optional<math::Fixed64> stepLine(const ConceptContext& c) const;
    bool covered(const ConceptContext& c) const;

private:
    math::Fixed64 step_behind_, receive_radius_, pressure_radius_, moving_speed_;
};

// The class-based concepts a Brain carries.
struct ConceptBook {
    Libero libero;
    CoverShadow cover_shadow;
    LineStep line_step;
    ConceptBook() { configure(core::ModelParams{}); }
    void configure(const core::ModelParams& p) {
        libero.configure(p);
        cover_shadow.configure(p);
        line_step.configure(p);
    }
};

}  // namespace fh::game::ai
