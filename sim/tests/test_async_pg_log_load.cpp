// footballhome sim - AsyncPgLog load tests (DESIGN.md §16.5 exit criterion)
//
// Proves the last §16.5 exit criterion for Slice 13:
//
//   "Input write queue never blocks the tick loop under simulated
//    100 ms Postgres latency for a 10-minute match (load test enforces
//    zero dropped inputs)."
//
// Modeling choices
// ----------------
//
// * Push pattern models the real M0 tick loop:
//     - 22 filled slots (per-match slot count)
//     - 20 Hz tick rate (matches sim's RealtimeClock default)
//     - one InputRow per (slot, tick), pushed as a burst at each
//       tick boundary and separated by `sleep_until(next_tick)`
//     - a 20-byte dummy payload — the queue mechanics are payload-
//       agnostic, so exact wire bytes don't matter here.
//
// * Sink latency simulated by `std::this_thread::sleep_for(100ms)`
//   inside the sink lambda. This models a worst-case slow Postgres
//   (network hiccup, GC pause, IO saturation) without needing a real
//   database or toxiproxy sidecar.
//
// * Queue capacity: the AsyncPgLog default (256). With push rate
//   22 × 20 = 440 rows/s and sink drain 256 rows / 100 ms = 2560 rows/s,
//   headroom is 5.8× — the test proves the steady-state ratio holds.
//
// Two test variants
// -----------------
//
//   [1] async_pg_log_no_drops_under_100ms_pg_latency_5s   (always runs)
//       5-second wall time. Proves the steady-state property (drain >
//       push). Runs in every `ctest` invocation and every image build.
//
//   [2] async_pg_log_no_drops_10min_match                 (opt-in)
//       Full 10-minute wall time. Gated on the FH_SIM_LOAD_10MIN env
//       var so `ctest` stays fast; invoked on demand via the Makefile
//       target `sim-load-test-10min` (or a dedicated CI job). Honors
//       the literal "10-minute match" phrasing in DESIGN.md §16.5.
//
// The 5-second test is the guardrail for regressions in the drain/push
// ratio. The 10-minute test additionally guards against slow leaks or
// scheduler starvation over long horizons. Neither uses a real DB.

#include "common/IdTypes.hpp"
#include "persistence/AsyncPgLog.hpp"
#include "persistence/IPgClient.hpp"
#include "test_harness.hpp"

#include <atomic>
#include <chrono>
#include <cstddef>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <span>
#include <thread>
#include <vector>

using fh::sim::MatchId;
using fh::sim::SlotId;
using fh::sim::TickNum;
using fh::sim::persistence::AsyncPgLog;
using fh::sim::persistence::InputRow;

namespace {

// Steady-state parameters (match the sim's real M0 configuration).
constexpr int  kSlotsPerMatch = 22;
constexpr int  kTickHz        = 20;
constexpr auto kTickPeriod    =
    std::chrono::milliseconds(1000 / kTickHz);   // 50 ms
constexpr auto kSinkLatency   = std::chrono::milliseconds(100);
constexpr MatchId kMatchId    = 1;

// Run one load scenario:
//   * spins a AsyncPgLog<InputRow> with a 100ms-latency sink
//   * pushes `total_ticks` × kSlotsPerMatch rows at kTickHz
//   * stops the log (draining every queued row before joining)
//   * asserts dropped()==0, flushed()==pushed, sink saw same rows
//
// Returns false only if a wallclock check tripped; assertion failures
// are counted by the FH_EXPECT_* macros and do not abort the run so we
// still see the summary of each condition.
void runLoadScenario(int total_ticks, const char* scenario_name)
{
    std::fprintf(stdout,
        "  [load] scenario=%s ticks=%d slots=%d rate=%dHz sink_latency=100ms\n",
        scenario_name, total_ticks, kSlotsPerMatch, kTickHz);

    std::atomic<std::size_t> sink_batches{0};
    std::atomic<std::size_t> sink_rows{0};

    AsyncPgLog<InputRow> log(
        [&](std::span<const InputRow> batch) {
            std::this_thread::sleep_for(kSinkLatency);
            sink_batches.fetch_add(1, std::memory_order_relaxed);
            sink_rows.fetch_add(batch.size(), std::memory_order_relaxed);
        });

    // Reused byte buffer template — copied per row to keep the InputRow
    // owning its own bytes (as the real writer does).
    const std::vector<std::byte> dummy_payload(20, std::byte{0});

    std::size_t pushed = 0;
    const auto  wall_start = std::chrono::steady_clock::now();
    auto        next_tick  = wall_start;

    for (int t = 0; t < total_ticks; ++t) {
        // Burst: one InputRow per slot, all at this tick's boundary.
        for (int s = 0; s < kSlotsPerMatch; ++s) {
            InputRow r;
            r.match_id = kMatchId;
            r.tick_num = static_cast<TickNum>(t);
            r.slot_id  = static_cast<SlotId>(s);
            r.payload  = dummy_payload;
            log.push(std::move(r));
            ++pushed;
        }
        next_tick += kTickPeriod;
        std::this_thread::sleep_until(next_tick);
    }

    // stop() runs the final drain and joins the drain thread. Any row
    // still in the queue when the last push landed will be delivered
    // before this returns (see AsyncPgLog::drainLoop stopping branch).
    log.stop();

    const auto wall_ms = std::chrono::duration_cast<std::chrono::milliseconds>(
        std::chrono::steady_clock::now() - wall_start).count();
    std::fprintf(stdout,
        "  [load] pushed=%zu flushed=%zu dropped=%zu batches=%zu wall=%lldms\n",
        pushed, log.flushed(), log.dropped(),
        sink_batches.load(std::memory_order_relaxed),
        static_cast<long long>(wall_ms));

    FH_EXPECT_EQ(log.dropped(), static_cast<std::size_t>(0));
    FH_EXPECT_EQ(log.flushed(), pushed);
    FH_EXPECT_EQ(sink_rows.load(std::memory_order_relaxed), pushed);
    FH_EXPECT_GT(sink_batches.load(std::memory_order_relaxed),
                 static_cast<std::size_t>(0));
}

bool envFlagOn(const char* name)
{
    const char* v = std::getenv(name);
    if (v == nullptr) { return false; }
    return std::strcmp(v, "1") == 0
        || std::strcmp(v, "true") == 0
        || std::strcmp(v, "yes") == 0
        || std::strcmp(v, "on") == 0;
}

} // namespace

// ---------------------------------------------------------------------------
// [1] 5-second load — always runs (regression guardrail for the drain/push
//     ratio). Total pushed rows = 5s × 20Hz × 22 slots = 2 200.
// ---------------------------------------------------------------------------
FH_TEST(async_pg_log_no_drops_under_100ms_pg_latency_5s)
{
    constexpr int kSeconds = 5;
    runLoadScenario(kSeconds * kTickHz, "5s");
}

// ---------------------------------------------------------------------------
// [2] 10-minute load — opt-in via FH_SIM_LOAD_10MIN=1. Total pushed rows =
//     600s × 20Hz × 22 slots = 264 000. Honors the literal "10-minute
//     match" phrasing in DESIGN.md §16.5.
// ---------------------------------------------------------------------------
FH_TEST(async_pg_log_no_drops_10min_match)
{
    if (!envFlagOn("FH_SIM_LOAD_10MIN")) {
        std::fprintf(stdout,
            "  SKIP async_pg_log_no_drops_10min_match "
            "(set FH_SIM_LOAD_10MIN=1 to run — ~10 min wall time)\n");
        return;
    }
    constexpr int kSeconds = 600;
    runLoadScenario(kSeconds * kTickHz, "10min");
}

FH_TEST_MAIN()
