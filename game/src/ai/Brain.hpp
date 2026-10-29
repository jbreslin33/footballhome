// game/src/ai/Brain.hpp
//
// First-generation team brain (G2.4): a deterministic, pure function of
// the World that produces one MoveIntent + Action per AI slot each tick.
// No RNG, no stored state beyond the static team setup — same world in,
// same orders out, on every architecture (DESIGN.md §3, §5).
//
// Behavior set ([FH] utility-lite; support-spot/role ideas trace to
// [Buckland] and [GRF]):
//   loose ball → each team's nearest player chases it; rest hold anchors
//   our ball   → AI carrier dribbles at the goal, shoots inside range;
//                teammates hold (ball-shifted) anchors = natural support
//   their ball → nearest player presses the carrier; rest hold anchors
// The three-layer architecture (team tactic → role → player utilities,
// DESIGN.md §5) grows out of exactly these hooks in later slices.

#pragma once

#include "ai/Concept.hpp"
#include "ai/Formation.hpp"
#include "core/World.hpp"

#include <array>
#include <cstdint>
#include <vector>

namespace fh::game::ai {

struct TeamSetup {
    // team[slot] = 0 (home, attacks +x) or 1 (away, attacks -x).
    std::vector<std::uint8_t> team_of_slot;

    static TeamSetup splitHalves(std::uint8_t slot_count);
};

// WHY a player did what he did (G4.41, the brain overlay — James: "an
// overlay that shows info about players brain … buckland does basically
// this", after [Buckland]'s Simple Soccer debug view). Read-only: the sim
// never looks at it, so it can't move a golden. Names = kWhyNames, sent to
// clients in the BRAIN_LEGEND frame.
enum class Why : std::uint8_t {
    Hold, Shoot, Pass, PassLadder, OverTop, Recycle, KeeperPunt, Dribble, Clear,
    KeeperSweep, KeeperPosition, CoverShadow, CounterPress, Tackle, Recover,
    Press, Chase, Delay, Libero, Mark, GiveAndGo, BlindSideRun, RunInBehind,
    Outlet, Support, Human, WaitForRunner, LapseDeep, LapseStepOut,
    LapseShort, LapseLong, HabitShort, HabitLong, HabitDeep, HabitStepOut,
    MeetPass, KeepRunning, KeeperDive, SideOn, DropStep, Unmark, PlayBack, Shield,
    JumpPass, ShadowHelp, PackMiddle, PressFullBack, LockDoor,
    Intercept, NoTurn, Contain, ShadowLine, PlayOff,
    MarkTight, ProtectMiddle, AttackDrop, RunBackDrop, CallShadow,
    CallManOn, CallTurn, CallTime, CallSqueeze, CallLine,
    HurryKeeper, PressBadTouch, OverHighLine, KeeperShort,
    FalseNineDrop, Overlap, ComeShort, CheckIn,
    WaitPass, StayOnside,
};
inline constexpr const char* kWhyNames[] = {
    "hold shape", "shoot", "pass", "pass ladder", "over the top", "recycle", "keeper punt", "dribble", "clear",
    "keeper sweep", "keeper position", "cover shadow", "counter-press", "tackle", "recover goal-side",
    "press", "chase ball", "delay", "libero", "mark", "give and go", "blind-side run", "run in behind",
    "outlet", "support", "human", "wait for the runner",
    "lapse: sweeping too deep", "lapse: stepped out too high",
    "lapse: short and simple", "lapse: hit it long",
    "likes it short", "likes it long", "likes to sit deep", "likes to step out",
    "meet the pass", "keep running", "keeper dive", "jockey side-on", "turn and run with him",
    "lose your marker", "play it back", "shield and turn",
    "jump the pass", "shadow and help", "pack the middle", "press the full-back", "lock the door",
    "intercept", "no turn", "contain", "shadow the line", "play off for the long ball",
    "mark tight (near the ball)", "protect the middle (far from the ball)",
    "attack the ball in the air", "run back for the ball in the air",
    "call: adjust your shadow",
    "call: man on", "call: turn", "call: time", "call: squeeze", "call: line",
    "hurry the keeper", "press the bad touch",
    "over the high line", "keeper: short and simple",
    "false 9: drop in",
    "overlap", "winger: come short", "check in",
    "lapse: lets it come to him",
    "stay onside",
};
inline constexpr int kWhyCount = static_cast<int>(sizeof(kWhyNames) / sizeof(kWhyNames[0]));

struct Orders {
    core::MoveIntent move;
    core::Action action = core::Action::None;
    // The overlay's read of the decision (never fed back into the sim).
    Why why = Why::Hold;
    math::Vec2 target{};          // where he's going / aiming
    std::int16_t other = -1;      // the pass receiver, marked man, pressed carrier
    std::uint8_t rung = 0;        // pass-ladder rung of a laddered pass (1-6)
    bool read = false;            // the passer read the interceptors for it (safe_pass, G4.86)
    // An aimed LoftedKick's first-bounce distance (G4.48); 0 = the preset
    // chip (clearances, punts).
    std::uint8_t carry_m = 0;
    // A kick played to a mate (G4.81): who (World ball().pass_to — the man
    // who meets it, the rest let it run); 0xFF = nobody. Filled with a
    // ground pass's weight (carry_m = metres to the target) in ordersFor.
    std::uint8_t pass_to = 0xFF;
    std::uint8_t passTo() const { return pass_to; }
    // What he could see (G4.66, overlay only): his picture of the men
    // behind him is this many tenths of a second old (0 = he just looked;
    // 255 = sees everything — the perfect band); `unseen` = how many men
    // he only knows from that look.
    std::uint8_t look_ds = 255;
    std::uint8_t unseen = 0;
    // A call he's making (G4.70-71, overlay + harness): what (a Why name),
    // to whom (-1 none, kBackLine = the back line); `due` = the call the
    // moment asked of him, said or not (Hold = none); `heard` = a call he
    // heard this tick (Hold = none).
    static constexpr std::int16_t kBackLine = 254;
    Why call = Why::Hold;
    std::int16_t call_to = -1;
    Why due = Why::Hold;
    Why heard = Why::Hold;
};

class Brain {
public:
    // Formation specs per team; an invalid/empty spec falls back to the
    // built-in for that team's size (tests and DB-down boots take this
    // path, so goldens never depend on the database).
    Brain(TeamSetup setup, math::Fixed64 pitch_half_x,
          math::Fixed64 pitch_half_y,
          FormationSpec home = {}, FormationSpec away = {});

    // Skill noise (G4.3): perception delay + decision jitter per team.
    // Defaults (zero) = the perfect-play baseline the goldens lock.
    // G4.33: the class-based concepts read their numbers from the club DB
    // (game_model_params); without it they keep their seeded defaults.
    void setDirectPairs(std::vector<std::pair<int, int>> pairs) { direct_pairs_ = std::move(pairs); direct_.clear(); }
    // A restart shape (G4.58, phases of play): while `team`'s dead ball is
    // waiting, each listed slot holds his mark facing the ball (the taker —
    // the one on the ball — plays as usual); released on the first touch.
    void setRestartShape(std::uint8_t team, std::vector<std::pair<std::uint8_t, math::Vec2>> marks) {
        hold_team_ = team; hold_ = std::move(marks);
    }
    void clearRestartShape() { hold_.clear(); hold_team_ = 0xFF; }
    // Setting up a dead ball (G4.64): a restart takes seconds, so every man
    // who knows his job (rating > 0) gets to it — the consistency roll is for
    // the live game. James 10/26: "talking ukies restart. our 10 should be on
    // their 6!"
    void setDeadBallSetup(bool on) { dead_ball_setup_ = on; }
    void setModelParams(const core::ModelParams& p) {
        books_[0].configure(p);
        books_[1].configure(p);
        initiative_ = p.fixed("skill.tendency.initiative", 1000);
        arrive_decel_ = p.fixed("physics.body.arrive_decel_mps2", 4500);
        arrive_through_ = p.fixed("physics.body.arrive_through_mps", 3000);
        shape_slope_ = p.fixed("physics.shape.ours_slope", 450);
        shape_offset_ = p.fixed("physics.shape.ours_offset_m", 2000);
        shape_depth_ = p.fixed("physics.shape.ours_depth_k", 1400);
    }
    // G4.76: one team's concept numbers — the global rows with its game
    // model's own (game_model_concept_params) and the HUD's live changes.
    void setTeamModelParams(std::uint8_t team, const core::ModelParams& p) {
        if (team < 2) books_[team].configure(p);
    }

    // Per-player level (G4.30): the band bent by the player's attributes.
    void setSlotLevel(core::SlotIndex slot, const core::LevelParams& lv) {
        if (slot_level_.size() <= slot) {
            slot_level_.resize(slot + 1u);
            slot_level_set_.resize(slot + 1u, 0);
        }
        slot_level_[slot] = lv;
        slot_level_set_[slot] = 1;
    }
    const core::LevelParams& levelOf(core::SlotIndex slot) const {
        return slot < slot_level_set_.size() && slot_level_set_[slot]
                   ? slot_level_[slot]
                   : level_[setup_.team_of_slot[slot]];
    }

    void setLevels(const core::LevelParams& home,
                   const core::LevelParams& away,
                   std::uint64_t match_seed) {
        level_[0] = home;
        level_[1] = away;
        match_seed_ = match_seed;
        // Reset every slot's knowledge to its band's default ratings.
        for (std::size_t i = 0; i < ratings_.size(); ++i) {
            ratings_[i] = core::defaultRatings(
                level_[setup_.team_of_slot[i]]);
        }
    }

    // Per-slot graded knowledge (game/CONCEPTS.md; 0-100 per concept).
    void setRatings(core::SlotIndex slot, const core::ConceptRatings& r) {
        if (slot < ratings_.size()) ratings_[slot] = r;
    }
    // What he KNOWS (ability, before the game model's demand): his habits —
    // a lapse picks the neighbour concept he's best at (G4.46).
    void setHabits(core::SlotIndex slot, const core::ConceptRatings& r) {
        if (habits_.size() <= slot) habits_.resize(slot + 1u, core::ConceptRatings{});
        habits_[slot] = r;
    }
    // The coach's weights on defend-your-man's 3 rules by third of the
    // pitch (G4.68, mig 747; 0-100, 100 = always when it's on): [zone][rung],
    // zone 0 = our third, 1 = middle, 2 = theirs.
    enum Rung : std::uint8_t { kIntercept = 0, kNoTurn = 1, kContain = 2 };
    using Ladder = std::array<std::array<std::uint8_t, 3>, 3>;
    void setLadder(std::uint8_t team, const Ladder& w) {
        if (team < 2) ladder_[team] = w;
    }
    // His TENDENCIES (G4.47, mig 669; -1 = none): how much he LIKES a
    // concept, apart from how well he does it — weights his lapses and
    // makes him try a liked neighbour on his own initiative.
    void setTendencies(core::SlotIndex slot, const core::PresetOverlay& t) {
        if (tendencies_.size() <= slot) {
            core::PresetOverlay none;
            none.fill(-1);
            tendencies_.resize(slot + 1u, none);
        }
        tendencies_[slot] = t;
    }
    const core::ConceptRatings& ratings(core::SlotIndex slot) const {
        return ratings_[slot];
    }

    // Orders for ONE slot given the current world. Pure + deterministic.
    Orders ordersFor(core::SlotIndex slot, const core::World& world) const;
    // His formation spot shifted with the ball (harness, G4.80): where his
    // position alone would put him — no duty, no concept.
    // stay-onside (184, G4.91): our ball, off the ball — a target past their
    // offside line comes back onto it, less margin_m (rolled per second).
    void stayOnside(core::SlotIndex slot, const core::World& world, Orders& o) const;
    math::Vec2 shapeAnchor(core::SlotIndex slot, const core::World& world) const;

    // The flight read (G4.49): for a free live ball, where and when each
    // player can first take it — the ball's own path walked tick by tick
    // (gravity, bounces, skid, roll), a touch only where it's low and slow
    // enough to control. A pure function of the world; cached per tick
    // because all 22 brains ask the same question.
    struct FlightRead {
        bool live = false;                 // a free ball in play
        std::vector<std::int16_t> tick;    // ticks until slot can take it; -1 = can't (horizon)
        std::vector<math::Vec2> at;        // where
        int first[2] = {-1, -1};           // each team's first man to it
    };
    const FlightRead& flightRead(const core::World& world) const;
    // The race itself (G4.86) — ONE model of "who gets to this ball first",
    // for the ball in the air (flightRead) and for the ball a passer is about
    // to strike (passSafe): the path from pos/vel; each man after his own
    // reaction + perception, less `since` (ticks the flight has already
    // flown); `ours` (the passing team) only where the ball has come down to
    // his control speed; opponents `opp_margin` m more reach (a passer's
    // caution). first_only: stop at the first tick anyone can take it.
    struct RaceBall {
        math::Vec3 pos, vel;
        std::int64_t since = 0;            // ticks since the flight began
        core::SlotIndex kicker = 0xFF;
        int lockout = 0;                   // the kicker's own lockout ticks left
        std::uint8_t ours = 0xFF;          // the team whose ball it is
        bool offside = true;               // honour the live offside flags
        math::Fixed64 opp_margin{};
        bool first_only = false;
    };
    void race(const core::World& world, const RaceBall& rb, FlightRead& f) const;
    // A passer's read [Buckland] (G4.19, G4.86): the race on the pass he's
    // about to strike — safe when one of ours is first, ties to them.
    bool passSafe(const core::World& world, core::SlotIndex passer, core::SlotIndex receiver,
                  const math::Vec2& from, const math::Vec2& to, math::Fixed64 speed,
                  math::Fixed64 reach) const;
    // ...the loft he's about to hit, carry_m to `at` (G4.86b).
    bool loftSafe(const core::World& world, core::SlotIndex passer, const math::Vec2& from,
                  const math::Vec2& at, std::uint8_t carry_m, math::Fixed64 reach) const;
    bool raceSafe(const core::World& world, core::SlotIndex passer, const math::Vec3& pos,
                  const math::Vec3& vel, math::Fixed64 reach) const;

    // A slot's traditional position number (2 RB … 9 striker; 0 = unknown).
    int numberOf(core::SlotIndex slot) const {
        return spec_[setup_.team_of_slot[slot]].positions[index_in_team_[slot]].number;
    }

    // What he can see (G4.66): ticks since his last look behind him, 0 =
    // fresh (he just looked, or perfect play sees everything); at most
    // physics.vision.max_age_s.
    std::int32_t lookAge(core::SlotIndex slot, const core::World& world) const;
    // Is `other` in front of slot (his field of view) or close enough to feel?
    bool inView(core::SlotIndex slot, const core::World& world, core::SlotIndex other) const;

private:
    // ordersFor() on the world as slot sees it.
    Orders ordersSeen(core::SlotIndex slot, const core::World& world) const;
    // The decision itself; ordersFor() adds where his body faces (G4.53).
    Orders decide(core::SlotIndex slot, const core::World& world) const;
    // ordersFor() before the laws of the restart are applied.
    Orders ordersFaced(core::SlotIndex slot, const core::World& world) const;
    // G4.80: brake to arrive — his run toward his own target is capped at
    // the speed he can still stop (or, on the ball, slow to a touch) from.
    void brakeToArrive(core::SlotIndex slot, const core::World& world, Orders& o) const;
    void unmark(core::SlotIndex slot, const core::World& world, Orders& o) const;
    bool keepIt(core::SlotIndex slot, const core::World& world, int sign, Orders& out) const;
    // G4.63 the one-spot defender: jump the pass to your man (162); one
    // spot that keeps your man in pressing distance, shadows another man's
    // lane (163) and has more men in pressing distance to help (164).
    bool jumpThePass(core::SlotIndex slot, const core::World& world, int sign, Orders& out) const;
    // Play off (170, G4.69): their ball in the AIR for my man — read it on
    // the kick and attack the drop, receiving it facing their goal.
    bool attackTheDrop(core::SlotIndex slot, const core::World& world, int sign, Orders& out) const;
    // Hurry the keeper (178) / press the bad touch (179), G4.73.
    bool hurryOrPounce(core::SlotIndex slot, const core::World& world, int sign, Orders& out) const;
    // Communication (G4.70-71): the calls one team's moment asks for this
    // tick, read from the true world — who, to whom (Orders::kBackLine = the
    // back line), about which man (-1 = everyone behind him), and whether
    // he says it (knows the call × his communication). Cached per tick.
    struct CallOut { Why why = Why::Hold; int talker = -1, to = -1, man = -1; bool made = false; };
    const std::vector<CallOut>& calls(std::uint8_t team, const core::World& world) const;
    bool says(core::SlotIndex slot, const ai::Call& c, std::uint64_t sec) const;
    bool hears(core::SlotIndex slot, const CallOut& c, const core::World& world) const;
    const ai::Call& callConcept(Why w, std::uint8_t team) const;
    bool backLine(core::SlotIndex slot) const { const int n = numberOf(slot); return n >= 2 && n <= 5; }
    // G4.64 Lighthouse's plan (165-167): pack the middle, then on their pass
    // to a full-back press him and lock the door on the return pass.
    bool packAndTrap(core::SlotIndex slot, const core::World& world, int sign,
                     const math::Vec2& ball, const math::Vec2& anchor, Orders& out) const;
    struct Trap {
        int carrier = -1;                    // their man on the ball / first to their pass
        int winger = -1;                     // our winger who goes (carrier is a full-back)
        std::vector<core::SlotIndex> cbs;    // their centre-backs
    };
    Trap trapRead(const core::World& world, std::uint8_t my_team, const math::Vec2& ball) const;
    int theirWinger(const core::World& world, std::uint8_t my_team, int sign, int full_back,
                    const std::vector<core::SlotIndex>& cbs) const;
    math::Vec2 oneSpot(core::SlotIndex slot, const core::World& world, core::SlotIndex man,
                       const math::Vec2& spot, const math::Vec2& passer, core::SlotIndex carrier,
                       bool shadow, bool help) const;
    // Pressing distance (164): where `man` receives a pass from `passer`
    // (he comes to meet it) and how far slot runs before it arrives.
    struct Reach { math::Vec2 at; math::Fixed64 run; };
    Reach pressReach(core::SlotIndex slot, const core::World& world, const math::Vec2& passer, core::SlotIndex man) const;

    int attackSign(core::SlotIndex slot) const {
        return setup_.team_of_slot[slot] == 0 ? +1 : -1;
    }
    // Is `slot` its team's closest player to `target` (ties → lower slot)?
    bool isTeamClosest(core::SlotIndex slot, const core::World& world,
                       const math::Vec3& target) const;
    // How many teammates are strictly closer to `target` (0 = I am
    // closest, 1 = I am the cover man, ...).
    int teamCloserCount(core::SlotIndex slot, const core::World& world,
                        const math::Vec3& target) const;

    TeamSetup setup_;
    math::Fixed64 half_x_, half_y_;
    FormationSpec spec_[2];
    core::LevelParams level_[2];
    // G4.33 class-based concepts; G4.76 one book per team, so each team's
    // game model can set its own numbers (game_model_concept_params).
    ConceptBook books_[2];
    const ConceptBook& bookOf(core::SlotIndex s) const {
        return books_[s < setup_.team_of_slot.size() && setup_.team_of_slot[s] == 1 ? 1 : 0];
    }
    // G4.30 per-player levels (perception, decisions, keeper reaction);
    // empty / unset = the team band.
    std::vector<core::LevelParams>  slot_level_;
    std::vector<std::uint8_t>       slot_level_set_;
    std::uint64_t match_seed_ = 0;
    // Does slot play this rung of the ladder at x (his team's third of it)?
    // Rolled per second, after the concept's own roll.
    bool rung(core::SlotIndex slot, Rung r, math::Fixed64 x, std::uint64_t sec) const;
    Ladder ladder_[2] = {{{{100, 100, 100}, {100, 100, 100}, {100, 100, 100}}},
                         {{{100, 100, 100}, {100, 100, 100}, {100, 100, 100}}}};
    std::vector<core::ConceptRatings> ratings_;
    std::vector<core::ConceptRatings> habits_;
    std::vector<core::PresetOverlay> tendencies_;
    // Direct opponents (G4.56-57; James: "we call it a direct opponent and
    // it's an important concept that goes beyond LH and Bielsa"): every
    // marker's man from the two formations' bases — theirs mirrored into
    // ours (their most advanced meet our deepest), paired nearest-first;
    // a man who marks nobody (marking 0, the free +1) gets none. Man-
    // markers follow him anywhere; zonal markers pick him up first in
    // their zone. Per-second cache.
    const std::vector<std::uint8_t>& directOpponents(const core::World& world, std::uint64_t sec) const;
    mutable std::vector<std::uint8_t> direct_;
    std::vector<std::pair<int, int>> direct_pairs_;
    std::vector<std::pair<std::uint8_t, math::Vec2>> hold_;
    std::uint8_t hold_team_ = 0xFF;
    bool dead_ball_setup_ = false;
    mutable std::uint64_t direct_sec_ = ~std::uint64_t{0};
    // G4.66: mates the carrier being decided can't see (and hasn't just
    // looked at) — no pass to them. Set and cleared inside ordersFor().
    mutable std::uint64_t blind_ = 0;
    // The calls cache (one entry per team) and what a back-line man was
    // told this tick (consumed by ordersSeen's line code).
    mutable std::uint64_t calls_tick_[2] = {~0ull, ~0ull};
    mutable std::int64_t calls_key_[2] = {0, 0};
    mutable std::vector<CallOut> calls_[2];
    mutable bool told_squeeze_ = false, told_line_ = false;
    bool blind(core::SlotIndex i) const { return i < 64 && ((blind_ >> i) & 1u); }
    mutable FlightRead flight_;
    mutable FlightRead pass_race_;   // passSafe's scratch (G4.86)
    mutable std::uint64_t flight_tick_ = ~std::uint64_t{0};
    mutable std::int64_t flight_key_[3] = {0, 0, 0};
    math::Fixed64 initiative_ = math::Fixed64::one();
    // G4.80: the deceleration a player plans his arrival on (m/s²), and the
    // speed he still has on reaching a ball he's running onto (m/s).
    math::Fixed64 arrive_decel_ = math::Fixed64::fromFraction(9, 2);
    math::Fixed64 arrive_through_ = math::Fixed64::fromInt(3);
    // G4.80: in possession the shape's middle stands at slope × the ball's
    // x + offset (m, attack direction), its lines' spacing × depth.
    math::Fixed64 shape_slope_ = math::Fixed64::fromFraction(45, 100);
    math::Fixed64 shape_offset_ = math::Fixed64::fromInt(2);
    math::Fixed64 shape_depth_ = math::Fixed64::fromFraction(14, 10);
    math::Fixed64 possessionX(core::SlotIndex slot, math::Fixed64 ball_x) const;
    // Graded application: does slot APPLY concept (bit index) this tick?
    // Consistency roll — deterministic noise vs the rating.
    bool applies(core::SlotIndex slot, int concept_idx,
                 std::uint64_t tick) const {
        const std::uint8_t r = ratings_[slot][concept_idx];
        if (r == 0) return false;
        if (r >= 100 || dead_ball_setup_) return true;
        const auto n = core::detNoise(match_seed_, tick, slot,
                                      static_cast<std::uint8_t>(32 + concept_idx));
        return (n + math::Fixed64::one()) <
               math::Fixed64::fromFraction(r, 50);
    }
    int tendency(core::SlotIndex slot, int c) const {
        return slot < tendencies_.size() ? tendencies_[slot][c] : -1;
    }
    // The concept slot lapses into when his roll on concept_idx fails
    // (G4.46): one of its 'lapses-to' neighbours, weighted by his tendency
    // on each when he has one, else his ability (habit); -1 = none.
    int lapse(core::SlotIndex slot, int concept_idx, std::uint64_t window) const {
        if (slot >= habits_.size()) return -1;
        auto weight = [&](int to) {
            const int t = tendency(slot, to);
            return t >= 0 ? t : static_cast<int>(habits_[slot][to]);
        };
        int total = 0;
        for (int to : core::concepts().lapses(concept_idx)) total += weight(to);
        if (total <= 0) return -1;
        const auto n = core::detNoise(match_seed_, window, slot, static_cast<std::uint8_t>(240));
        // n in [-1, 1) → a pick in [0, total).
        int pick = static_cast<int>((((n + math::Fixed64::one()) * total) / 2).raw >>
                                    math::Fixed64::FRAC_BITS);
        for (int to : core::concepts().lapses(concept_idx)) {
            pick -= weight(to);
            if (pick < 0) return to;
        }
        return -1;
    }
    // What slot actually plays for concept_idx this window (G4.47):
    //   1. a neighbour he LIKES (tendency t > 50) on his own initiative,
    //      (t − 50)% of windows × tendency.initiative — "tries long balls";
    //   2. else the concept itself, when his model asks and his ability
    //      roll succeeds;
    //   3. else, when asked, a lapse into a neighbour;
    //   -1 = none of it (the generic brain).
    int choose(core::SlotIndex slot, int concept_idx, std::uint64_t window) const {
        int k = 0;
        for (int to : core::concepts().lapses(concept_idx)) {
            const int t = tendency(slot, to);
            ++k;
            if (t <= 50) continue;
            const auto n = core::detNoise(match_seed_, window, slot, static_cast<std::uint8_t>(240 + k));
            if ((n + math::Fixed64::one()) * 50 < math::Fixed64::fromInt(t - 50) * initiative_)
                return to;
        }
        if (ratings_[slot][concept_idx] == 0) return -1;
        if (applies(slot, concept_idx, window)) return concept_idx;
        return lapse(slot, concept_idx, window);
    }
    // counter_attack (bit 23, G4.18): is slot's team inside its fast-break
    // window — ball won from the opponent IN OUR OWN HALF, within
    // 2 s + rating ticks? A rebound recovered in their box is a
    // scramble, not a transition (measured: those wins sit 0.6 s
    // before the goal and doubled world scoring when they counted).
    bool inCounterWindow(core::SlotIndex slot,
                         const core::World& world) const {
        const std::uint8_t r = ratings_[slot][23];
        const std::uint8_t team = setup_.team_of_slot[slot];
        if (r == 0 || world.lastLosingTeam() == 0xFF ||
            world.lastLosingTeam() == team)
            return false;
        if (world.tickCount() - world.turnoverTick() >=
            60 + static_cast<std::uint64_t>(r))
            return false;
        const math::Fixed64 x = world.turnoverBallX();
        return team == 0 ? x.raw < 0 : x.raw > 0;
    }
    // Magnitude helper: rating as a 0..1 Fixed64.
    math::Fixed64 degree(core::SlotIndex slot, int concept_idx) const {
        return math::Fixed64::fromFraction(ratings_[slot][concept_idx], 100);
    }
    // Per-slot index within its own team (formation base lookup).
    std::vector<std::uint8_t> index_in_team_;
    std::vector<std::uint8_t> team_size_;
};

}  // namespace fh::game::ai
