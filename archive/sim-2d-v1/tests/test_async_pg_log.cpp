// footballhome sim - AsyncPgLog tests
//
// Exercises the semantics documented in AsyncPgLog.hpp:
//   * push() nothrow, in-order sink delivery
//   * capacity overflow drops rows (dropped counter reflects it)
//   * stop() drains any rows pushed just before the shutdown signal
//   * sink exceptions are counted as drops and the drain thread survives
//   * destructor calls stop() (RAII cleanup)
//
// The tests use a small POD row type and a synchronised sink that copies
// each batch into a shared vector under lock. Waits are bounded by a
// generous timeout to avoid flaking CI on a loaded host — a real deadlock
// still surfaces cleanly (the timeout expires and FH_EXPECT trips).

#include "persistence/AsyncPgLog.hpp"
#include "test_harness.hpp"

#include <atomic>
#include <chrono>
#include <cstdint>
#include <mutex>
#include <span>
#include <stdexcept>
#include <thread>
#include <vector>

using fh::sim::persistence::AsyncPgLog;

namespace {

struct Row {
    std::uint32_t seq;
};

// Sink that appends every batch it sees into a shared vector under lock.
// Copies (not moves) so the test can observe the sink handoff without
// invalidating the caller's local buffer.
struct RecordingSink {
    std::mutex             mu;
    std::vector<Row>       rows;

    void operator()(std::span<const Row> batch)
    {
        std::lock_guard<std::mutex> lk(mu);
        for (const auto& r : batch) { rows.push_back(r); }
    }

    std::size_t size()
    {
        std::lock_guard<std::mutex> lk(mu);
        return rows.size();
    }
};

// Spin with backoff up to `timeout_ms` waiting for `pred()` to hold.
// Returns true on success. Test failure sites treat false as a hang.
template <typename Pred>
bool waitFor(Pred pred, int timeout_ms = 2000)
{
    const auto deadline =
        std::chrono::steady_clock::now() +
        std::chrono::milliseconds(timeout_ms);
    while (std::chrono::steady_clock::now() < deadline) {
        if (pred()) { return true; }
        std::this_thread::sleep_for(std::chrono::milliseconds(1));
    }
    return pred();
}

} // namespace

FH_TEST(async_pg_log_delivers_pushed_rows_in_order)
{
    // Sink held on the heap so the AsyncPgLog can outlive the local
    // reference-capture without a dangling-reference footgun.
    auto sink = std::make_shared<RecordingSink>();
    AsyncPgLog<Row> log(
        [sink](std::span<const Row> batch) { (*sink)(batch); });

    constexpr std::uint32_t N = 50;
    for (std::uint32_t i = 0; i < N; ++i) {
        log.push(Row{i});
    }

    // Wait for the drain thread to flush.
    const bool ok = waitFor([&] { return sink->size() == N; });
    FH_EXPECT(ok);
    FH_EXPECT_EQ(log.flushed(), static_cast<std::size_t>(N));
    FH_EXPECT_EQ(log.dropped(), static_cast<std::size_t>(0));

    // Order preserved (push is single-threaded here, so no reordering
    // is expected across batches either).
    std::lock_guard<std::mutex> lk(sink->mu);
    for (std::uint32_t i = 0; i < N; ++i) {
        FH_EXPECT_EQ(sink->rows[i].seq, i);
    }
}

FH_TEST(async_pg_log_drops_when_capacity_exceeded)
{
    // Sink blocks on a gate until the test releases it. Fill the queue
    // past capacity while the drain thread is stuck inside the sink,
    // observe the dropped counter climb, then release.
    std::mutex        gate;
    std::atomic<bool> released{false};

    gate.lock();
    auto sink_fn = [&gate, &released](std::span<const Row>) {
        if (!released.load(std::memory_order_acquire)) {
            std::lock_guard<std::mutex> waiter(gate);
            (void)waiter;
        }
    };

    AsyncPgLog<Row> log(sink_fn, /*capacity=*/8);

    // First push may or may not be picked up by the drain thread before
    // the next arrives; either way, at most (capacity + 1) rows can be
    // in flight before drops start. Push 8*4 rows; expect > 0 drops.
    for (std::uint32_t i = 0; i < 32; ++i) {
        log.push(Row{i});
    }

    // Give the drain thread a beat to consume the first batch and start
    // blocking on the gate.
    std::this_thread::sleep_for(std::chrono::milliseconds(10));

    FH_EXPECT_GT(log.dropped(), static_cast<std::size_t>(0));

    // Release the sink so stop() can drain and the thread can exit.
    released.store(true, std::memory_order_release);
    gate.unlock();

    log.stop();
}

FH_TEST(async_pg_log_stop_drains_final_batch)
{
    auto sink = std::make_shared<RecordingSink>();
    AsyncPgLog<Row> log(
        [sink](std::span<const Row> batch) { (*sink)(batch); });

    // Push a burst and immediately stop. The final-drain path in
    // AsyncPgLog::drainLoop must deliver every row before returning.
    constexpr std::uint32_t N = 100;
    for (std::uint32_t i = 0; i < N; ++i) {
        log.push(Row{i});
    }
    log.stop();

    FH_EXPECT_EQ(sink->size(), static_cast<std::size_t>(N));
    FH_EXPECT_EQ(log.flushed(), static_cast<std::size_t>(N));
    FH_EXPECT_EQ(log.dropped(), static_cast<std::size_t>(0));
}

FH_TEST(async_pg_log_sink_exception_is_counted_and_drain_continues)
{
    std::atomic<int> call_count{0};
    std::atomic<int> good_rows{0};

    AsyncPgLog<Row> log(
        [&call_count, &good_rows](std::span<const Row> batch) {
            const int n = call_count.fetch_add(1, std::memory_order_relaxed);
            if (n == 0) {
                // First batch throws; drain thread must catch, count as
                // drop, keep going.
                throw std::runtime_error("simulated pg outage");
            }
            good_rows.fetch_add(static_cast<int>(batch.size()),
                                std::memory_order_relaxed);
        });

    log.push(Row{1});
    // Wait for the first batch to hit the sink and throw.
    const bool first_call =
        waitFor([&] {
            return call_count.load(std::memory_order_relaxed) >= 1;
        });
    FH_EXPECT(first_call);

    // Now push more; drain should still be alive.
    log.push(Row{2});
    log.push(Row{3});

    const bool later_delivered =
        waitFor([&] {
            return good_rows.load(std::memory_order_relaxed) >= 2;
        });
    FH_EXPECT(later_delivered);
    FH_EXPECT_GE(log.dropped(), static_cast<std::size_t>(1));

    log.stop();
}

FH_TEST(async_pg_log_stop_is_idempotent)
{
    AsyncPgLog<Row> log([](std::span<const Row>) {});
    log.stop();
    log.stop();  // must not deadlock or double-join
}

FH_TEST_MAIN()
