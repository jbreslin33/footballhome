// game/src/ai/concepts/DirectOpponent.hpp
//
// DIRECT OPPONENT — who is my man right now?  (game_concepts direct-opponent, match-up.)
//
// Owner 2026-10-24 (mig 694): "the 9's direct opponents are the 4 and 5 and vice versa.
// that gives the -1, +1. 10:6, 7:2, 3:11, 8:8". And 2026-11-24, on the first build (which
// paired each man with whoever was nearest his place): "direct opponent would never be that
// far away lol. a direct opponent is normally 9 vs 4,5  10 v 6 2 v 7 11v3 8v8 but of course
// in the heat of battle you have to adjust to the ball area and find a direct opponent for
// that part of pitch or battle scene".
//
// So two layers, for the side WITHOUT the ball:
//
//   the matchup     by position number (game_direct_opponents): our 9 on their 4 or 5, our
//                   4 and 5 on their 9, 10 on 6, 6 on 10, 8 on 8, full-backs on wingers.
//                   Wide men pair along their own touchline whatever the numbering (a
//                   full-back takes the winger on HIS side). Where two of ours share one of
//                   theirs (the 4 and 5 on their 9) the nearer takes him and the other is
//                   the spare man — the +1; where one of ours has two (our 9 on their 4 and
//                   5) he takes the nearer and the other is left free — the -1.
//   the battle      near the ball (battle_m) the men in that scene pair with who is actually
//                   there — nearest first, nobody twice. A pair is kept until another is
//                   clearly better (keep_m), so two men do not swap back and forth.
//   no matchup      one of ours whose numbers find nobody in their shape (a back three, a
//                   missing 10) takes the nearest man left — within nearest_max_m of his
//                   place; nobody that near and he is a spare man. Never a man across the pitch.
//
// A RECOGNITION, not an order: it moves nobody. It is what the other concepts read. Fixed
// point, no noise, no memory beyond the last pairing.

#pragma once

#include "common/IdTypes.hpp"
#include "core/ModelParams.hpp"
#include "core/World.hpp"
#include "math/Fixed64.hpp"
#include "math/Vec3.hpp"

#include <array>
#include <cstdint>
#include <vector>

namespace fh::game::ai::concepts {

struct DirectOpponentParams {
    math::Fixed64 keep_m = math::Fixed64::fromInt(4);      // a new man must be this much nearer to take over a pair
    math::Fixed64 battle_m = math::Fixed64::fromInt(18);   // the ball's scene: men this near the ball pair with who is there
    math::Fixed64 wide_y = math::Fixed64::fromFraction(1, 2);   // a formation base this far across (of 1) is a wide man
    math::Fixed64 nearest_max_m = math::Fixed64::fromInt(20);  // no matchup in their shape: the nearest man left, but only this near
};

// How a pair was made, for the viewer.
enum class PairHow : std::uint8_t { None, Matchup, Battle, Nearest };

class DirectOpponents {
public:
    DirectOpponents();

    // The number pairs (game_direct_opponents) arrive as model params "concept.direct.pair_<n>_<m>"
    // (MatchSetup); none at all = the owner's pairs of 10/24, built in.
    void configure(const core::ModelParams& p);

    // One tick for `team`, the side without the ball. Per slot: `place` = his place in the
    // defensive shape (ours), `number` = his position number (0 unknown), `base_y` = his
    // formation base across the pitch in world y (-1 … 1). `goal_x` = the x of the goal line
    // `team` defends.
    void assign(std::uint8_t team, const core::World& w, const std::vector<std::uint8_t>& team_of_slot,
                const std::vector<math::Vec2>& place, math::Fixed64 goal_x,
                const std::vector<std::int16_t>& number, const std::vector<math::Fixed64>& base_y);

    // His man (a slot), or -1: he is the spare man, a keeper, or his side has the ball.
    int of(core::SlotIndex slot) const { return slot < 32 ? opp_[slot] : -1; }
    PairHow how(core::SlotIndex slot) const { return slot < 32 ? how_[slot] : PairHow::None; }
    // The one of ours watching this opponent, or -1 (he is free).
    int watcherOf(core::SlotIndex their) const { return their < 32 ? watcher_[their] : -1; }
    int spare(std::uint8_t team) const { return spare_[team & 1]; }       // ours with nobody, nearest our goal
    int freeMan(std::uint8_t team) const { return free_[team & 1]; }      // theirs left alone, furthest from our goal
    bool partners(int our_number, int their_number) const;               // the matchup table
    void clear(std::uint8_t team, const std::vector<std::uint8_t>& team_of_slot);
    void reset();

    const DirectOpponentParams& params() const { return p_; }

private:
    DirectOpponentParams p_{};
    std::array<std::uint16_t, 12> pair_{};   // pair_[n] bit m: our n takes their m (numbers 1 … 11)
    std::array<int, 32> opp_ = filled();
    std::array<int, 32> watcher_ = filled();
    std::array<PairHow, 32> how_{};
    int spare_[2] = {-1, -1};
    int free_[2] = {-1, -1};
    static std::array<int, 32> filled() { std::array<int, 32> a{}; a.fill(-1); return a; }
};

}  // namespace fh::game::ai::concepts
