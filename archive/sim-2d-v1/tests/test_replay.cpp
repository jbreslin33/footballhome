// footballhome sim - fh-sim-replay integration test (§16.6 sub-slice 6)
//
// Proves the replay driver produces a byte-identical canonical hash to
// the live match that recorded the input log. Runs two matches side by
// side against the same InMemoryPgClient:
//
//   1. Live: identical setup to test_determinism.cpp's
//      human_sprint_east_400_ticks_seed_42 golden test — one human slot
//      pressing "sprint east" for 400 ticks. Wire InputFrame bytes are
//      inserted into InMemoryPgClient the same way SimServer does it
//      (see SimServer.cpp INPUT handler, §16.6 task 8).
//   2. Replay: tools::replayMatch on the same DB, up_to_tick=400.
//
// Success criterion: replay.canonical_hash == live golden hash. If the
// replay driver drifts by even one bit the ctest exits non-zero.
//
// Also exercises the --verify code path: MatchEnd event → replayMatch
// resolves target_tick automatically.

#include "common/IdTypes.hpp"
#include "common/M0Attributes.hpp"
#include "controller/Intent.hpp"
#include "match/CanonicalHash.hpp"
#include "match/Match.hpp"
#include "match/MatchClock.hpp"
#include "math/Vec3.hpp"
#include "net/InputFrame.hpp"
#include "persistence/EventTypes.hpp"
#include "persistence/IPgClient.hpp"
#include "persistence/InMemoryPgClient.hpp"
#include "physics/BasicPhysics.hpp"
#include "profile/PlayerProfile.hpp"
#include "scenario/EmptyPitchScenario.hpp"
#include "test_harness.hpp"
#include "tools/Replay.hpp"

#include <cstddef>
#include <cstdint>
#include <memory>
#include <vector>

using fh::sim::ClientId;
using fh::sim::MatchId;
using fh::sim::PersonId;
using fh::sim::SlotId;
using fh::sim::TickNum;
using fh::sim::controller::Intent;
using fh::sim::match::canonicalMatchHash;
using fh::sim::match::Match;
using fh::sim::match::MatchConfig;
using fh::sim::match::RealtimeClock;
using fh::sim::math::Fixed64;
using fh::sim::math::Vec3;
using fh::sim::persistence::EventRow;
using fh::sim::persistence::EventType;
using fh::sim::persistence::InMemoryPgClient;
using fh::sim::persistence::InputRow;
using fh::sim::persistence::MatchRow;
using fh::sim::physics::BasicPhysics;
using fh::sim::scenario::EmptyPitchScenario;
using fh::sim::tools::replayMatch;
using fh::sim::tools::ReplayOptions;

namespace {

constexpr MatchId       kMatchId       = 1;
constexpr std::uint64_t kSeed          = 42;
constexpr std::int16_t  kScenarioId    = 0;
constexpr std::uint32_t kTickHz        = 20;
constexpr TickNum       kTargetTick    = 400;
constexpr SlotId        kSlotId        = 1;

std::unique_ptr<Match> makeMatch()
{
    MatchConfig cfg;
    cfg.id             = kMatchId;
    cfg.seed           = kSeed;
    cfg.server_version = "test";
    cfg.physics        = std::make_unique<BasicPhysics>();
    cfg.scenario       = std::make_unique<EmptyPitchScenario>();
    cfg.clock          = std::make_unique<RealtimeClock>(kTickHz);
    return std::make_unique<Match>(std::move(cfg));
}

fh::sim::profile::PlayerProfile makeProfile()
{
    fh::sim::profile::PlayerProfile p;
    p.physical = fh::sim::m0::defaultPhysical();
    p.concepts = fh::sim::m0::defaultConcepts();
    return p;
}

// Record the match_id in InMemoryPgClient so getMatch() during replay
// returns a row with the right scenario_id + seed + tick_hz.
void seedMatchRow(InMemoryPgClient& db)
{
    MatchRow row;
    row.id             = kMatchId;
    row.scenario_id    = kScenarioId;
    row.seed           = kSeed;
    row.tick_hz        = static_cast<std::int16_t>(kTickHz);
    row.server_version = "test";
    row.visibility     = 0;
    db.upsertMatch(row);
}

// Build the same wire INPUT frame the live server would receive for a
// "sprint east" input, and insert it as a recorded InputRow at tick_num=0.
void recordSprintEastInput(InMemoryPgClient& db)
{
    const auto wire = fh::sim::net::encodeInputFrame(
        /*client_tick=*/0,
        /*desired_dir_x=*/1.0F,
        /*desired_dir_y=*/0.0F,
        /*wants_sprint=*/true,
        /*wants_walk=*/false);

    InputRow row;
    row.match_id = kMatchId;
    row.tick_num = 0;
    row.slot_id  = kSlotId;
    row.payload.resize(wire.size());
    for (std::size_t i = 0; i < wire.size(); ++i) {
        row.payload[i] = static_cast<std::byte>(wire[i]);
    }
    db.insertInput(row);
}

} // namespace

FH_TEST(replay_matches_live_human_sprint_east_400) {
    InMemoryPgClient db;
    seedMatchRow(db);

    // --- Live phase: identical to test_determinism.cpp golden ----------
    auto live = makeMatch();
    live->claimSlot(kSlotId, ClientId{7}, PersonId{7}, makeProfile());
    Intent in;
    in.desired_direction = Vec3{Fixed64::one(), Fixed64::zero(), Fixed64::zero()};
    in.wants_sprint = true;
    live->applyInput(ClientId{7}, in);
    recordSprintEastInput(db);
    for (TickNum t = 0; t < kTargetTick; ++t) {
        live->tick();
    }
    const std::uint64_t live_hash = canonicalMatchHash(*live);

    // --- Replay phase: reconstruct from the log ------------------------
    ReplayOptions opts;
    opts.up_to_tick = kTargetTick;
    const auto r = replayMatch(db, kMatchId, opts);

    FH_EXPECT_EQ(r.canonical_hash, live_hash);
    FH_EXPECT_EQ(r.final_tick, kTargetTick);
    FH_EXPECT_EQ(r.inputs_applied, static_cast<std::size_t>(1));
    FH_EXPECT_EQ(r.slots_synthesized, static_cast<std::size_t>(1));
}

FH_TEST(replay_default_target_reads_match_end_tick) {
    InMemoryPgClient db;
    seedMatchRow(db);

    // Live: run 200 ticks (no inputs at all — pure scenario wander).
    auto live = makeMatch();
    for (TickNum t = 0; t < 200; ++t) {
        live->tick();
    }
    const std::uint64_t live_hash = canonicalMatchHash(*live);

    // Record a MatchEnd event so replayMatch can auto-resolve target_tick.
    EventRow end;
    end.match_id   = kMatchId;
    end.tick_num   = 200;
    end.event_type = EventType::MatchEnd;
    // Payload not needed for this test's assertion (we only check that
    // target_tick was resolved from the row).
    end.payload    = std::vector<std::byte>(8, std::byte{0});
    db.insertEvent(end);

    // opts.up_to_tick left as nullopt — must resolve via MatchEnd.
    const auto r = replayMatch(db, kMatchId, {});

    FH_EXPECT_EQ(r.canonical_hash, live_hash);
    FH_EXPECT_EQ(r.final_tick, static_cast<TickNum>(200));
    FH_EXPECT_EQ(r.inputs_applied, static_cast<std::size_t>(0));
    FH_EXPECT_EQ(r.slots_synthesized, static_cast<std::size_t>(0));
}

FH_TEST(replay_missing_match_throws) {
    InMemoryPgClient db;
    // No seedMatchRow — getMatch returns nullopt.
    bool threw = false;
    try {
        (void)replayMatch(db, kMatchId, {});
    } catch (const std::runtime_error&) {
        threw = true;
    }
    FH_EXPECT(threw);
}

FH_TEST_MAIN()
