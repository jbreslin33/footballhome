// game/src/ai/Players.cpp — the player layer's shared pieces (G5.22, DESIGN §8.120).
#include "ai/Players.hpp"

#include "ai/DefendingBlock.hpp"
#include "ai/Possession.hpp"

namespace fh::game::ai {

using math::Fixed64;

Role roleOfNumber(int n) {
    if (n == 4 || n == 5) return Role::CB;
    if (n == 2 || n == 3) return Role::FB;
    if (n == 10) return Role::AM;
    if (n == 7 || n == 11) return Role::Wide;
    if (n == 9) return Role::ST;
    return Role::DM;
}

Role roleOfSlot(const std::string& role, int number) {
    if (role == "centre-back") return Role::CB;
    if (role == "full-back" || role == "wing-back") return Role::FB;
    if (role == "single-pivot" || role == "double-pivot" || role == "eight") return Role::DM;
    if (role == "ten") return Role::AM;
    if (role == "wide-forward") return Role::Wide;
    if (role == "nine") return Role::ST;
    return roleOfNumber(number);
}

Fixed64 bandLookup(const Fixed64 (&row)[kBandCount], Fixed64 off) {
    const Fixed64 u = (off - Fixed64::fromInt(5)) / Fixed64::fromInt(10);
    if (u <= Fixed64::zero()) return row[0];
    if (u >= Fixed64::fromInt(kBandCount - 1)) return row[kBandCount - 1];
    const int i = static_cast<int>(u.raw >> Fixed64::FRAC_BITS);
    const Fixed64 f = u - Fixed64::fromInt(i);
    return row[i] + (row[i + 1] - row[i]) * f;
}

namespace {

bool defendingPhase(Phase p) {
    return p == Phase::DefendingBlock || p == Phase::DefensiveTransition || p == Phase::TheirSetPiece;
}

// Each tick, his state from the ball, his team's assignments and phase.
class Pick final : public PlayerState {
public:
    std::uint8_t id() const override { return 0xFE; }
    const char* name() const override { return "pick"; }
    void execute(PlayerAgent& a, const PlayerCtx& c) const override {
        const auto& ball = c.world.ball();
        const std::uint8_t team = c.team.team;
        const PlayerState* next;
        if (ball.owner && *ball.owner == a.slot) next = Possession::onBall();
        // His team's man for the loose ball — a keeper too: the pass back to him,
        // the ball he's first to (else a pass to the keeper rolled into the net).
        else if (c.block.chaser(team) == a.slot)
            next = (ball.pass_to == a.slot && c.world.lastTouchTeam() == team) ? Possession::receive() : DefendingBlock::chaseBall();
        // A ball in behind played for him (G5.27): he keeps his run while it is
        // loose, first on the race read or not — the defender has to win it.
        else if (!ball.owner && ball.pass_to == a.slot && c.world.lastTouchTeam() == team &&
                 c.poss.led(ball.last_kicker).to == a.slot && c.world.outStage() == 0 && c.world.restartTeam() == 0xFF)
            next = Possession::receive();
        else if (c.world.isKeeper(a.slot)) next = Possession::keeper();
        else if (defendingPhase(c.team.phase()))
            next = c.block.presser(team) == a.slot ? DefendingBlock::pressBall() : DefendingBlock::holdBlockSpot();
        else next = c.poss.runner(a.slot) ? Possession::attackBox() : c.poss.running(a.slot) ? Possession::runLine() : Possession::support();
        a.machine.change(a, c, next, c.tick);
    }
};
const Pick kPick;

}  // namespace

const PlayerState* playerGlobalState() { return &kPick; }
const PlayerState* playerStartState() { return Possession::support(); }

}  // namespace fh::game::ai
