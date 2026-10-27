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
    // max_m overridable (the keeper's short ball reaches a split centre-back).
    std::optional<core::SlotIndex> pick(const ConceptContext& c, const LaneOpen& open,
                                        std::optional<math::Fixed64> max_m = std::nullopt) const;

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

// See ball and man (G4.53, core, from U-10) [coaching: "keep the play in
// front of you", "open body / see ball and man"]: off the ball, adjusting
// a short way (within within_m of where he's going), he faces the ball
// and shuffles or backpedals instead of turning his back. A failed roll =
// he turns and runs, back to the play — the youth habit. Runs in behind,
// chases, presses and recovery sprints face their travel.
class FaceThePlay : public Concept {
public:
    FaceThePlay() : Concept("face-the-play", 154) {}
    void configure(const core::ModelParams& p) override;
    math::Fixed64 within() const { return within_; }

private:
    math::Fixed64 within_;
};

// Side-on, show him one way (G4.54, core, U-14) [FIFA Training Centre
// "Defending in 1v1"; FA Boot Room 1v1 defending; St. Albert Soccer
// jockeying points]: delaying, he stands side-on — body turned stance°
// open toward the side he is showing the carrier — so a run that way is
// his side-on crossover, not a square backpedal. Lapse: square-on.
class SideOnJockey : public Concept {
public:
    SideOnJockey() : Concept("side-on-jockey", 155) {}
    void configure(const core::ModelParams& p) override;
    math::Fixed64 stance() const { return stance_; }   // radians

private:
    math::Fixed64 stance_;
};

// Turn and run with him (G4.54, core, U-14) [drop step / hip turn —
// St. Albert Soccer; FA Boot Room]: the carrier he's jockeying comes at
// him at speed (goalward ≥ carrier_mps, within within_m) → drop-step and
// run with him on the goal-side line, lead_m ahead along his run. No
// backpedal holds a sprinting dribbler. Lapse: keeps backpedalling.
class DropStep : public Concept {
public:
    DropStep() : Concept("drop-step", 156) {}
    void configure(const core::ModelParams& p) override;
    math::Fixed64 carrierSpeed() const { return carrier_; }
    math::Fixed64 within() const { return within_; }
    math::Fixed64 lead() const { return lead_; }

private:
    math::Fixed64 carrier_, within_, lead_;
};

// When to step in (G4.54, core, U-14) [FIFA Training Centre
// "Defending in 1v1"; FA Boot Room 1v1 defending]: with cover behind him a
// defender used to step in on every carrier. The lesson: engage when cover
// has ARRIVED (a teammate within cover_m of the carrier, goal-side), his
// back is to our goal, or he's pinned within touchline_m of the line —
// otherwise contain and delay. (A loose touch is the fourth trigger; the
// engine has no heavy touches yet.) Lapse: dives in anyway.
class EngageOrContain : public Concept {
public:
    EngageOrContain() : Concept("engage-or-contain", 157) {}
    void configure(const core::ModelParams& p) override;
    math::Fixed64 cover() const { return cover_; }
    math::Fixed64 touchline() const { return touchline_; }
    // Deny the shot (FA "delay, deny, dictate"): inside this distance of
    // our goal he closes the carrier down — containing there lets him shoot.
    math::Fixed64 danger() const { return danger_; }

private:
    math::Fixed64 cover_, touchline_, danger_;
};

// Shot selection (25, G4.21 → G4.55): shoot on what the chance is WORTH
// against what else he could do. His read of it is an xG-like estimate
// [FH, fitted to rough public xG anchors: ~0.45 at 6 m, ~0.2 at the spot,
// ~0.09 at the box edge, ~0.03 at 25 m, central and clear — source to pin]:
//   xg = scale · visible-goal angle (halved per body in it) · e^(−d/decay),
// × pressed_factor under pressure. Pressed, he shoots at min_pressed or
// better; free, he needs min_free (else he works it closer); and a mate
// with a safe pass whose chance is pass_better × his passes instead.
class ShotSelection : public Concept {
public:
    ShotSelection() : Concept("shot-selection", 25) {}
    void configure(const core::ModelParams& p) override;
    math::Fixed64 xg(math::Fixed64 angle_rad, math::Fixed64 dist, bool pressed) const;
    math::Fixed64 minPressed() const { return min_pressed_; }
    math::Fixed64 minFree() const { return min_free_; }
    math::Fixed64 passBetter() const { return pass_better_; }

private:
    math::Fixed64 scale_, decay_, pressed_, min_pressed_, min_free_, pass_better_;
};

// Hold the line (9, core, U-10; G4.4 → G4.56) [Sacchi palla coperta /
// scoperta; KNVB: pressure on the ball → squeeze, none → drop]: the back
// line sets at the ball − hold_m (push-up squeezes it by up to squeeze_m)
// while the ball is covered, and drops a further uncovered_drop_m when a
// free carrier faces forward and can play in behind. An attacker beyond
// the line is offside, not a man to follow. Lapse: drops with the deepest
// attacker — the pre-offside rule every back line used until G4.56,
// which sank lines 16-22 m from their own goal (real ~35-45 m).
class LineHold : public Concept {
public:
    LineHold() : Concept("line-hold", 9) {}
    void configure(const core::ModelParams& p) override;
    math::Fixed64 hold() const { return hold_; }
    math::Fixed64 squeeze() const { return squeeze_; }
    math::Fixed64 uncoveredDrop() const { return drop_; }

private:
    math::Fixed64 hold_, squeeze_, drop_;
};

// Where to stand on your man (G4.57, core, U-12→U-14) [US Soccer / FA
// "ball, man, goal"; Bielsa man-orientation; James: "mark from behind or
// cover shadow in front or tuck inside"]: always goal-side; the nearer his
// man is to the ball (within near_m) the more he steps ball-side into the
// passing line — the cover shadow in front, deny the pass; the further
// (out to far_m) the more he tucks toward the ball, up to tuck share of
// the way — the far-side marker helps inside and the team stays compact.
// Lapse: a flat stand goal-side of the man.
class MarkPosition : public Concept {
public:
    MarkPosition() : Concept("mark-position", 158) {}
    void configure(const core::ModelParams& p) override;
    math::Fixed64 nearM() const { return near_; }
    math::Fixed64 farM() const { return far_; }
    math::Fixed64 tuck() const { return tuck_; }

private:
    math::Fixed64 near_, far_, tuck_;
};

// Mark by distance from the ball (122, core, U-14) [James 10/26: "marking
// should be proximal to ball. so further away from ball the more you
// protect middle … closer to ball the more tight"; the coaching guideline
// "tight near the ball, zone away from it"]: his man within near_m of the
// ball → tight_m off him, goal-side and ball-side; out at far_m → loose_m
// off him, goal-side and toward the middle. Gap and direction blend on a
// straight line between. Our full-back drops inside while their centre-
// backs build. Lapse: mark-position's spot.
class NearTightFarZone : public Concept {
public:
    NearTightFarZone() : Concept("near-tight-far-zone", 122) {}
    void configure(const core::ModelParams& p) override;
    // 0 = his man next to the ball … 1 = far from it.
    math::Fixed64 farShare(math::Fixed64 ball_to_man) const;
    math::Fixed64 gap(math::Fixed64 far_share) const { return tight_ + (loose_ - tight_) * far_share; }

private:
    math::Fixed64 near_, far_, tight_, loose_;
};

// Lose your marker (G4.57, core, U-10) [James: "offense we unmark. in any
// direction"; coaching: check away, create a yard]: our ball, he's off it
// with an opponent within tight_m — step step_m to the spot (8 directions)
// furthest from every opponent, staying within leash_m of his job.
class LoseYourMarker : public Concept {
public:
    LoseYourMarker() : Concept("lose-your-marker", 159) {}
    void configure(const core::ModelParams& p) override;
    math::Fixed64 tight() const { return tight_; }
    math::Fixed64 step() const { return step_; }
    math::Fixed64 leash() const { return leash_; }

private:
    math::Fixed64 tight_, step_, leash_;
};

// The direct opponent (160, G4.57, core, U-10) [James: "we call it a
// direct opponent … a universal concept, it's just that the zonal systems
// move in relation of their zone to mark and unmark"]: every player knows
// his man (Brain::directOpponents — position-number pairs, else the
// shape matchup). Man-markers (18) follow him anywhere; a zonal marker
// picks him up first while he is in his zone (within zone_m of where his
// zone puts him) and passes him on when he leaves. Lapse: nearest man.
class DirectOpponent : public Concept {
public:
    DirectOpponent() : Concept("direct-opponent", 160) {}
    void configure(const core::ModelParams& p) override;
    math::Fixed64 zone() const { return zone_; }

private:
    math::Fixed64 zone_;
};

// Pressed with no pass: keep it (161, G4.60, core, U-10) [James 10/26:
// "shield and turn back, play it back to a CB or the keeper, hoof only in
// your own third"; coaching: shield, if you can't go forward go back]: a
// touch-tight carrier with nothing on plays it back — the open teammate
// goal-side of him within back_pass_max_m, the one with most room — or
// else shields: body between man and ball, carrying shield_step_m away
// from the presser and back toward his goal at shield_speed_share pace.
// Only inside own_third_m of his own goal line may he kick it away.
// Lapse: the hoof upfield from anywhere.
class KeepItUnderPressure : public Concept {
public:
    KeepItUnderPressure() : Concept("keep-it-under-pressure", 161) {}
    void configure(const core::ModelParams& p) override;
    math::Fixed64 ownThird() const { return own_third_; }
    math::Fixed64 backPassMax() const { return back_max_; }
    math::Fixed64 shieldStep() const { return step_; }
    math::Fixed64 shieldSpeed() const { return speed_; }

private:
    math::Fixed64 own_third_, back_max_, step_, speed_;
};

// The one-spot defender (G4.63, James 10/26: "a player could be close
// enough to get to direct opponent during pass traversal, while also cover
// shadowing another opp from current ball carrier who is not their direct
// opp, while also being dense enough to get to 1 or more others' direct
// opponents to help … on the way to being the ultimate defender") — three
// style lessons a man-oriented press [Bielsa] asks for, each a job one body
// can do at once:
//
// Pressing distance (164): close enough to a man to reach him while a pass
// to him travels — reach him where he RECEIVES it: he comes to meet the
// ball (meet_share of his own run), the ball covers the rest at
// pass_speed, and the defender runs that long less his reaction (his
// body's own law, from a standing start). The must: his own man stays in
// it. The help: every other man in it too.
class PressingDistance : public Concept {
public:
    PressingDistance() : Concept("pressing-distance", 164) {}
    void configure(const core::ModelParams& p) override;
    math::Fixed64 passSpeed() const { return pass_speed_; }
    math::Fixed64 reaction() const { return reaction_; }
    math::Fixed64 contact() const { return contact_; }
    math::Fixed64 helpWeight() const { return help_; }
    math::Fixed64 moveCost() const { return cost_; }
    math::Fixed64 meetShare() const { return meet_; }
    math::Fixed64 maxOffMan() const { return max_off_; }

private:
    math::Fixed64 pass_speed_, reaction_, contact_, help_, cost_, meet_, max_off_;
};

// Cover-shadow a second man (163): stand on the line from their carrier to
// a man who is NOT yours — the ground pass to him goes through your body —
// while yours stays in pressing distance. A lane a teammate already stands
// on is taken. Lapse: on his own man only.
class ShadowSecondMan : public Concept {
public:
    ShadowSecondMan() : Concept("shadow-second-man", 163) {}
    void configure(const core::ModelParams& p) override;
    math::Fixed64 fromPasser() const { return from_passer_; }
    math::Fixed64 fromMan() const { return from_man_; }
    math::Fixed64 laneWidth() const { return width_; }
    math::Fixed64 laneWeight() const { return weight_; }

private:
    math::Fixed64 from_passer_, from_man_, width_, weight_;
};

// Jump the pass (162): their pass is travelling to a man — HIS defender
// goes as the ball goes, to arrive goal-side (arrive_gap_m) as it does, so
// the receiver can't turn. His defender is the one whose direct opponent
// he is; out of reach (jump_max_m), the teammate in pressing distance of
// him jumps instead — the chain. Lapse: holds his mark until the ball lands.
class JumpThePass : public Concept {
public:
    JumpThePass() : Concept("jump-the-pass", 162) {}
    void configure(const core::ModelParams& p) override;
    math::Fixed64 arriveGap() const { return gap_; }
    math::Fixed64 jumpMax() const { return max_; }

private:
    math::Fixed64 gap_, max_;
};

// Lighthouse's out-of-possession plan (G4.64, mig 730). James 10/26: "we
// essentially pack the middle then wait for the inevitable pass to full
// then we press." Three style lessons keyed to formation numbers (params,
// not code): the false 9 and both wingers.
//
// Pack the middle (165) [FH; the narrow front three: Klopp]: while they
// build in their half, the false 9 drops in front of their midfield —
// screen_gap_m off the man of theirs nearest the ball that our 6/8/10 mark,
// on the line from the ball — and both wingers tuck in to screen the others
// (no wider than tuck_width_m): with the 6/8/10 man-marking that is 6 v 3, and their full-backs are left
// open on purpose. On the trigger the far winger tucks on to
// weak_tuck_width_m (an extra midfielder). Lapse: Bielsa's shape.
class PackTheMiddle : public Concept {
public:
    PackTheMiddle() : Concept("pack-the-middle", 165) {}
    void configure(const core::ModelParams& p) override;
    int falseNine() const { return nine_; }
    bool isWinger(int number) const { return number != 0 && (number == right_ || number == left_); }
    // Our midfield (the man markers the pack helps): their men are the ones
    // to screen.
    bool isMidfield(int number) const { return number != 0 && (number == mid_[0] || number == mid_[1] || number == mid_[2]); }
    math::Fixed64 tuckWidth() const { return tuck_; }
    math::Fixed64 weakTuckWidth() const { return weak_tuck_; }
    math::Fixed64 centralWidth() const { return central_; }
    math::Fixed64 screenGap() const { return screen_; }
    // The false 9 floats higher (nine_screen_gap_m): between their centre-
    // backs and midfield, in reach to lock the door.
    math::Fixed64 nineScreenGap() const { return nine_screen_; }
    math::Fixed64 fromHalfway() const { return from_halfway_; }
    math::Fixed64 handover() const { return handover_; }
    // G4.72 (James 10/27): the wingers are book-ends to our 8 and 10 —
    // level with the one on their side, bookend_gap_m wider; the 9 stands in
    // the box between their centre-backs and two deepest midfielders; on
    // their restart our full-backs stand fb_off_m goal-side and fb_inside_m
    // inside their winger.
    bool isFullBack(int number) const { return number != 0 && (number == rb_ || number == lb_); }
    bool isBookendMid(int number) const { return number != 0 && (number == mid_[1] || number == mid_[2]); }
    math::Fixed64 bookendGap() const { return bookend_; }
    math::Fixed64 fbOff() const { return fb_off_; }
    math::Fixed64 fbInside() const { return fb_inside_; }

private:
    int nine_ = 9, right_ = 7, left_ = 11, mid_[3] = {6, 8, 10}, rb_ = 2, lb_ = 3;
    math::Fixed64 tuck_, weak_tuck_, central_, screen_, nine_screen_, from_halfway_, handover_;
    math::Fixed64 bookend_, fb_off_, fb_inside_;
};

// Press the full-back (166) [FH; the pass wide as the trigger: Rangnick,
// Klopp]: their pass goes to a full-back — the winger whose direct
// opponent he is steps STRAIGHT at him (James: "doesn't curve run") and
// stands step_gap_m off him on the line to their nearest central man
// (the 6/8/10, level with or ahead of the full-back by shadow_ahead_m), so
// the ball back inside goes through his body. Inside handover_m of a
// carrying full-back the normal press takes over. Lapse: the ordinary brain
// (he marks or holds shape).
class PressTheFullBack : public Concept {
public:
    PressTheFullBack() : Concept("press-the-full-back", 166) {}
    void configure(const core::ModelParams& p) override;
    math::Fixed64 stepGap() const { return gap_; }
    math::Fixed64 shadowAhead() const { return ahead_; }
    math::Fixed64 handover() const { return handover_; }

private:
    math::Fixed64 gap_, ahead_, handover_;
};

// Lock the door (167) [FH — Lighthouse's own]: on the same trigger the
// false 9 goes up to the centre-back nearest the ball, lock_gap_m off him
// on the line to the full-back — no return pass — and shades shade_m
// toward the far centre-back to put off the long switch. Their centre-
// backs are the men the 9's number is paired with (game_direct_opponents).
// Lapse: stays dropped.
class LockTheDoor : public Concept {
public:
    LockTheDoor() : Concept("lock-the-door", 167) {}
    void configure(const core::ModelParams& p) override;
    math::Fixed64 lockGap() const { return gap_; }
    math::Fixed64 shade() const { return shade_; }
    // Before the trigger the 9 floats no further than this from the ball-
    // side centre-back (James: "close enough to ball side cb to lock door
    // on cb to fb transmission").
    math::Fixed64 reach() const { return reach_; }

private:
    math::Fixed64 gap_, shade_, reach_;
};

// Defend your man (168) [James 10/26: "3 rules. #1 priority interception,
// #2 no turn, #3 contain"; the coaching standard]: a marker's ladder on his
// direct opponent. #1 the pass to him — get to it first if you can (the
// flight read's race). #2 else arrive tight and goal-side as the ball does
// (jump the pass), and while he has it with his back to our goal stay
// no_turn_gap_m goal-side within no_turn_within_m — don't dive in, don't
// let him turn. #3 he's turned, or the pass to him lands before I can get
// tight: contain (delay / side-on; contain_gap_m off). The HUD names
// the rung. Lapse: the old pieces, unnamed (he may dive on a back-to-goal).
class DefendYourMan : public Concept {
public:
    DefendYourMan() : Concept("defend-your-man", 168) {}
    void configure(const core::ModelParams& p) override;
    math::Fixed64 noTurnGap() const { return gap_; }
    math::Fixed64 noTurnWithin() const { return within_; }
    math::Fixed64 containGap() const { return contain_; }

private:
    math::Fixed64 gap_, within_, contain_;
};

// Shadow the line (169) [James 10/26 — Lighthouse's second tactic]: the
// ball-side winger protects the midfield while the CB→FB pass travels
// (pack), then goes to the closest point of the FUTURE pass line from the
// full-back to their winger and traverses up it to from_fb_m off the full-
// back, the line re-read every tick as their winger moves (he looks behind;
// G4.65+ will make that a scan, and the full-back's call). Within on_line_m
// of the line he is on it. Inside handover_m of a full-back on the ball the
// normal press takes over. Lapse: press the full-back straight.
class ShadowTheLine : public Concept {
public:
    ShadowTheLine() : Concept("shadow-the-line", 169) {}
    void configure(const core::ModelParams& p) override;
    math::Fixed64 fromFullBack() const { return from_fb_; }
    math::Fixed64 onLine() const { return on_line_; }
    math::Fixed64 handover() const { return handover_; }

private:
    math::Fixed64 from_fb_, on_line_, handover_;
};

// Play off for the long ball (170) [James 10/26]: with our winger
// shadowing the ground ball to their winger, our full-back doesn't play
// tight — he stands off_m goal-side of his winger and guards the ball over
// the top. Still his direct opponent; only how he marks changes. When his
// winger drops short he doesn't follow him up the field: never further up
// than our highest centre-back plus ahead_of_line_m (James 10/27). Their
// ball in the air for his man: he reads it on the kick and attacks the drop,
// face_up_m past it on its path so he takes it facing their goal (G4.69).
class PlayOffLongBall : public Concept {
public:
    PlayOffLongBall() : Concept("play-off-long-ball", 170) {}
    void configure(const core::ModelParams& p) override;
    math::Fixed64 off() const { return off_; }
    math::Fixed64 aheadOfLine() const { return ahead_; }
    math::Fixed64 faceUp() const { return face_up_; }

private:
    math::Fixed64 off_, ahead_, face_up_;
};

// Call: adjust your shadow (172, G4.70) [James 10/26: "the full back
// would communicate to the winger the cover shadow adjustment"]: our
// full-back playing off sees their winger; our winger shadowing the line
// has him behind him. The full-back KNOWS the call (this rating), SAYS it
// (his communication: LevelParams::speak_pct), and the winger HEARS it —
// his picture of that man is then only hear_s (+ his own perception delay)
// old. Rolled per second, per call.
//
// G4.71 (James 10/27: "we need whether he listens to communicaiton. really
// for all players. same with the other calls"): every call is a Call — a
// concept to KNOW it, the talker's communication to SAY it, the listener's
// concentration (LevelParams::listen_pct) to HEAR it — and hear_s, how old
// the listener's picture is once he has. `reach()` is the call's own
// distance (man on: how close the man is; turn/time: how free he is; line:
// how far off the line), 0 where it has none.
class Call : public Concept {
public:
    Call(const char* name, int id, const char* reach_param = nullptr, std::int64_t reach_milli = 0)
        : Concept(name, id), reach_param_(reach_param), reach_milli_(reach_milli) {}
    void configure(const core::ModelParams& p) override;
    math::Fixed64 hear() const { return hear_; }
    math::Fixed64 reach() const { return reach_; }

private:
    const char* reach_param_;
    std::int64_t reach_milli_;
    math::Fixed64 hear_, reach_;
};
class CallAdjustShadow : public Call {
public:
    CallAdjustShadow() : Call("call-adjust-shadow", 172) {}
};
// Man on (173, core, U-10) [FA / US Soccer: the first call a kid learns]:
// a man is closing on our man on the ball (or about to receive), within
// near_m, and he can't see him; a teammate who can see both tells him.
// Heard: he knows where that man is — he shields, plays it back, or plays
// first time instead of turning into him.
class CallManOn : public Call {
public:
    CallManOn() : Call("call-man-on", 173, "near_m", 5000) {}
};
// Turn (174, core, U-10): our man on the ball (or receiving) with his back
// to their goal, nobody within free_m, and he hasn't looked — "turn!".
// Heard: his picture behind him is fresh — he sees he's free and turns.
class CallTurn : public Call {
public:
    CallTurn() : Call("call-turn", 174, "free_m", 7000) {}
};
// Time (175, core, U-12): the same, facing their goal — "time!": you're
// free, take a touch, look up. Heard: his picture behind is fresh.
class CallTime : public Call {
public:
    CallTime() : Call("call-time", 175, "free_m", 7000) {}
};
// Squeeze (176, core, U-14) [Sacchi: the back line steps up together on a
// covered ball]: the keeper (the man who sees the whole line) calls the
// step when the ball is covered. Heard: a back-line man who knows line-step
// steps up even when his own read missed it.
class CallSqueeze : public Call {
public:
    CallSqueeze() : Call("call-squeeze", 176) {}
};
// Line (177, core, U-14): a back-line man has dropped gap_m or more off the
// line, playing their men onside — the keeper calls "line!". Heard: one who
// knows line-hold holds the line even when his own read lapsed.
class CallLine : public Call {
public:
    CallLine() : Call("call-line", 177, "gap_m", 2000) {}
};

// Hurry the keeper (178, core, U-14) [James 10/27: "the norm is go after
// if you think you can hurry a pass. if not drop"]: their keeper on the
// ball (or their back pass to him): our nearest outfielder goes only if he
// can get within hurry_m of him before he's ready to play — settle_s after
// he has it (a back pass: its flight + settle_s). Else he drops: nobody
// goes, nobody marks the keeper.
class HurryTheKeeper : public Concept {
public:
    HurryTheKeeper() : Concept("hurry-the-keeper", 178) {}
    void configure(const core::ModelParams& p) override;
    math::Fixed64 hurry() const { return hurry_; }
    math::Fixed64 settle() const { return settle_; }

private:
    math::Fixed64 hurry_, settle_;
};

// Press the bad touch (179, core, U-10) [James 10/27: "if bad touch that
// is almost universal to press"]: one of theirs miscontrols it (a bobble)
// — our nearest man goes for the loose ball, for window_s after it.
class PressTheBadTouch : public Concept {
public:
    PressTheBadTouch() : Concept("press-the-bad-touch", 179) {}
    void configure(const core::ModelParams& p) override;
    std::int32_t windowTicks() const { return window_; }

private:
    std::int32_t window_ = 30;
};

// Beat the high line (180, core, semipro) [James 10/27: "high line go over
// top number 1 is a concept but players should be rated on understanding
// it, percieving it, ability to carry it out"]: their last defender stands
// high_m or more off their goal line — go over it, into the space behind_m
// past him, toward our most advanced man. UNDERSTANDING = this rating
// (taught from semipro: amateurs and kids don't read it; a semipro does at
// his quality); PERCEIVING = his picture (scanning + anticipation decide
// where he thinks their line is); CARRYING IT OUT = the lofted kick (his
// passing error and range). First wired for the keeper's distribution:
// without the read he plays the short, simple ball to an open man.
class BeatTheHighLine : public Concept {
public:
    BeatTheHighLine() : Concept("beat-the-high-line", 180) {}
    void configure(const core::ModelParams& p) override;
    math::Fixed64 high() const { return high_; }
    math::Fixed64 behind() const { return behind_; }
    math::Fixed64 keeperShort() const { return keeper_short_; }
    // G4.78, outfield passers: the ball must travel at least pass_min_m,
    // to a runner no more than runner_from_line_m short of their line.
    math::Fixed64 passMin() const { return pass_min_; }
    math::Fixed64 runnerFromLine() const { return runner_from_line_; }
    // …already running forward at runner_speed_mps, and race_m nearer the
    // drop than any of theirs.
    math::Fixed64 runnerSpeed() const { return runner_speed_; }
    math::Fixed64 race() const { return race_; }

private:
    math::Fixed64 high_, behind_, keeper_short_, pass_min_, runner_from_line_,
                  runner_speed_, race_;
};

// The false 9 who drops in and sends it long (181, G4.78) [James 10/27:
// "everyone including false 9 dropping in and taking care of it to send
// long ball like harry kane … that is how our 9 should play when Luke
// Breslin is in"; Kane at Spurs/Bayern: drops off the line into the space
// in front of their back four, takes it, turns and hits the runner in
// behind]. A role skill: nobody knows it by default (the player's own
// row), a game model asks for it. Off the ball, our ball short of their
// half: the 9 drops to drop_m in front of their back line, central. On
// it: he looks for the runner in behind even when their line isn't
// "high" — space_m of grass behind their last man is enough (the centre-
// back who followed him left it).
class FalseNine : public Concept {
public:
    FalseNine() : Concept("false-nine-drop", 181) {}
    void configure(const core::ModelParams& p) override;
    math::Fixed64 drop() const { return drop_; }
    math::Fixed64 space() const { return space_; }
    math::Fixed64 fromLine() const { return from_line_; }

private:
    math::Fixed64 drop_, space_, from_line_;
};

// Scanning (G4.66) [Jordet et al. 2013, visual exploratory activity in
// Premier League midfielders: the best scan ~0.6-0.8 times a second; FA /
// US Soccer "check your shoulder"]: what a player knows of the men BEHIND
// him is only as fresh as his last look. A rating sets how often he looks:
// looks per second on a straight line from every_s_at1 (20 s — a 1 barely
// looks) to every_s_at100 (1.25 s); each look is rolled like any concept,
// so a weak one skips some. 0 = never looks: he knows what's in front of
// him and nothing else.
class Scanning : public Concept {
public:
    using Concept::Concept;
    void configure(const core::ModelParams& p) override;
    // Ticks between looks at this rating (1-100).
    std::int32_t everyTicks(std::uint8_t rating) const;

private:
    math::Fixed64 at1_, at100_;
};
// Scan before you receive (33, core, U-10) — in possession: the look over
// the shoulder, and a fresh one while the pass is on its way to him.
class ScanBeforeReceive : public Scanning {
public:
    ScanBeforeReceive() : Scanning("scan-before-receive", 33) {}
};
// Scan when defending (171, core, U-14) — out of possession: checking the
// runner and his man behind him, not only watching the ball.
class ScanDefending : public Scanning {
public:
    ScanDefending() : Scanning("scan-defending", 171) {}
};

// What a body can see (G4.66; physics.vision.*): men within view_half_deg
// of where he faces are seen as they are; so is anyone within feel_m (heard,
// felt). The rest are where they were at his last look, placed back along
// their run by at most max_age_s (the look itself can be older). A human's useful field of view is roughly 180-200 degrees. On the
// ball he never plays a mate he can't see unless his look is younger than
// blind_pass_s.
struct Vision {
    math::Fixed64 cos_half;   // cos(view_half_deg)
    math::Fixed64 feel;       // m
    std::int32_t max_age_ticks = 90;
    // On the ball he passes to a man he can't see only if he looked within this.
    std::int32_t blind_pass_ticks = 15;
    // A call carries this far (G4.71); further, nobody hears it.
    math::Fixed64 voice;
    void configure(const core::ModelParams& p);
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
    FaceThePlay face_the_play;
    SideOnJockey side_on_jockey;
    DropStep drop_step;
    EngageOrContain engage_or_contain;
    ShotSelection shot_selection;
    LineHold line_hold;
    MarkPosition mark_position;
    NearTightFarZone near_tight;
    LoseYourMarker lose_your_marker;
    DirectOpponent direct_opponent;
    KeepItUnderPressure keep_it;
    JumpThePass jump_pass;
    ShadowSecondMan shadow_second;
    PressingDistance press_distance;
    PackTheMiddle pack_middle;
    PressTheFullBack press_full_back;
    LockTheDoor lock_door;
    DefendYourMan defend_man;
    ShadowTheLine shadow_line;
    PlayOffLongBall play_off;
    CallAdjustShadow call_shadow;
    CallManOn call_man_on;
    CallTurn call_turn;
    CallTime call_time;
    CallSqueeze call_squeeze;
    CallLine call_line;
    HurryTheKeeper hurry_keeper;
    PressTheBadTouch bad_touch;
    BeatTheHighLine high_line;
    FalseNine false_nine;
    ScanBeforeReceive scan_receive;
    ScanDefending scan_defend;
    Vision vision;
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
        face_the_play.configure(p);
        side_on_jockey.configure(p);
        drop_step.configure(p);
        engage_or_contain.configure(p);
        shot_selection.configure(p);
        line_hold.configure(p);
        mark_position.configure(p);
        near_tight.configure(p);
        lose_your_marker.configure(p);
        direct_opponent.configure(p);
        keep_it.configure(p);
        jump_pass.configure(p);
        shadow_second.configure(p);
        press_distance.configure(p);
        pack_middle.configure(p);
        press_full_back.configure(p);
        lock_door.configure(p);
        defend_man.configure(p);
        shadow_line.configure(p);
        play_off.configure(p);
        call_shadow.configure(p);
        call_man_on.configure(p);
        call_turn.configure(p);
        call_time.configure(p);
        call_squeeze.configure(p);
        call_line.configure(p);
        hurry_keeper.configure(p);
        bad_touch.configure(p);
        high_line.configure(p);
        false_nine.configure(p);
        scan_receive.configure(p);
        scan_defend.configure(p);
        vision.configure(p);
    }
};

}  // namespace fh::game::ai
