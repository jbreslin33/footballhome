#include "LaSyncScheduler.h"
#include "LaProgramSync.h"
#include "../database/Database.h"

#include <chrono>
#include <iostream>
#include <thread>

namespace {
// Club's own stated freshness requirement (2026-08-30): LA is source of
// truth for membership, and needs to be reflected within ~5 minutes.
constexpr int kIntervalSeconds = 300;
}

LaSyncScheduler& LaSyncScheduler::getInstance() {
    static LaSyncScheduler instance;
    return instance;
}

void LaSyncScheduler::start() {
    if (running_) return;
    running_ = true;
    std::thread(&LaSyncScheduler::loop, this).detach();
    std::cout << "⏰ LA membership sync scheduler started (every "
              << kIntervalSeconds << "s)" << std::endl;
}

void LaSyncScheduler::loop() {
    // Run once immediately on boot — don't make every program wait a
    // full interval after a deploy/restart before the first refresh.
    while (running_) {
        try {
            syncAllPrograms();
        } catch (const std::exception& e) {
            std::cerr << "[LaSyncScheduler] pass failed: " << e.what() << std::endl;
        }
        for (int i = 0; i < kIntervalSeconds && running_; ++i) {
            std::this_thread::sleep_for(std::chrono::seconds(1));
        }
    }
}

// Same enumeration + per-program try/catch shape as
// AdminLaBackfillController::handleSyncMemberships — one bad program
// (LA hiccup, a deleted program still in our table, etc.) must never
// block the rest from refreshing.
void LaSyncScheduler::syncAllPrograms() {
    auto* db = Database::getInstance();
    auto rows = db->query(
        "SELECT program_id, program_name FROM leagueapps_programs ORDER BY program_id");

    int ok = 0, failed = 0;
    std::size_t totalRecords = 0;
    const auto t0 = std::chrono::steady_clock::now();

    for (const auto& row : rows) {
        const long long programId = row["program_id"].as<long long>();
        try {
            LaProgramSync sync;
            auto res = sync.run(static_cast<int>(programId));
            totalRecords += res.recs.size();
            ++ok;
        } catch (const std::exception& e) {
            ++failed;
            std::cerr << "[LaSyncScheduler] program=" << programId
                      << " failed: " << e.what() << std::endl;
        }
    }

    const auto t1 = std::chrono::steady_clock::now();
    const long long elapsedMs =
        std::chrono::duration_cast<std::chrono::milliseconds>(t1 - t0).count();
    std::cout << "[LaSyncScheduler] pass complete: " << ok << " ok, " << failed
              << " failed, " << totalRecords << " records, " << elapsedMs << "ms"
              << std::endl;
}
