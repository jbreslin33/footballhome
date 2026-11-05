// game/src/ai/TeamPhase.cpp — the phases of play (G5.21, DESIGN §8.119).
#include "ai/TeamPhase.hpp"

namespace fh::game::ai {

BallSide readBallSide(const core::World& world, const std::vector<std::uint8_t>& team_of_slot) {
    BallSide b;
    const auto& ball = world.ball();
    if (world.restartTeam() != 0xFF) { b.side = world.restartTeam(); b.dead = true; return b; }
    if (world.outStage() != 0) { b.dead = true; return b; }   // over the line, the call to come: side unknown
    if (ball.owner && *ball.owner < team_of_slot.size()) { b.side = team_of_slot[*ball.owner]; return b; }
    if (world.lastTouchTeam() < 2) b.side = world.lastTouchTeam();
    return b;
}

namespace {

// Each phase state is one of these: which phase, and nothing else — the
// transitions are the same rule for all of them, in the global state.
class PhaseState final : public TeamState {
public:
    constexpr explicit PhaseState(Phase p) : p_(p) {}
    std::uint8_t id() const override { return static_cast<std::uint8_t>(p_); }
    const char* name() const override { return kPhaseNames[static_cast<int>(p_)]; }
    void execute(TeamAgent&, const TeamCtx&) const override {}
    Phase phase() const { return p_; }
private:
    Phase p_;
};

const PhaseState kStates[kPhaseCount] = {
    PhaseState{Phase::InPossession}, PhaseState{Phase::AttackingTransition}, PhaseState{Phase::DefendingBlock},
    PhaseState{Phase::DefensiveTransition}, PhaseState{Phase::OurSetPiece}, PhaseState{Phase::TheirSetPiece},
};
const TeamState* st(Phase p) { return &kStates[static_cast<int>(p)]; }

// The global state reads the ball every tick and moves the team between
// phases: a dead ball is a set piece for one side or the other; a change of
// side that has held min_dwell starts a transition; a transition that has
// run transition_ticks settles.
class Reader final : public TeamState {
public:
    std::uint8_t id() const override { return 0xFE; }
    const char* name() const override { return "read the ball"; }
    void execute(TeamAgent& a, const TeamCtx& c) const override {
        const BallSide b = readBallSide(c.world, c.team_of_slot);
        if (b.dead) {
            a.dead = true;
            if (b.side != 0xFF) { a.side = b.side; a.pending = 0xFF; }
            if (a.side != 0xFF) a.machine.change(a, c, st(a.side == a.team ? Phase::OurSetPiece : Phase::TheirSetPiece), c.tick);
            return;
        }
        const bool was_dead = a.dead;
        a.dead = false;
        if (b.side == 0xFF) return;
        bool turned = false;
        if (a.side == 0xFF) { a.side = b.side; turned = true; }
        else if (b.side != a.side) {
            if (a.pending != b.side) { a.pending = b.side; a.pending_since = c.tick; }
            if (c.tick - a.pending_since >= c.params.min_dwell_ticks) { a.side = b.side; a.pending = 0xFF; turned = true; }
        } else a.pending = 0xFF;
        if (turned) {
            a.machine.change(a, c, st(a.side == a.team ? Phase::AttackingTransition : Phase::DefensiveTransition), c.tick);
            return;
        }
        // Back in play from a set piece: the settled phase of whoever has it.
        if (was_dead) {
            a.machine.change(a, c, st(a.side == a.team ? Phase::InPossession : Phase::DefendingBlock), c.tick);
            return;
        }
        const auto* cur = a.machine.current();
        if ((cur == st(Phase::AttackingTransition) || cur == st(Phase::DefensiveTransition)) &&
            a.machine.ticksIn(c.tick) >= c.params.transition_ticks)
            a.machine.change(a, c, st(a.side == a.team ? Phase::InPossession : Phase::DefendingBlock), c.tick);
    }
};
const Reader kReader;

}  // namespace

Phase TeamAgent::phase() const {
    const auto* s = machine.current();
    return s ? static_cast<Phase>(s->id()) : Phase::DefendingBlock;
}

const TeamState* teamStartState() { return st(Phase::OurSetPiece); }
const TeamState* teamGlobalState() { return &kReader; }

}  // namespace fh::game::ai
