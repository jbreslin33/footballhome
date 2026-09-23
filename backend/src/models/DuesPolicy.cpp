#include "DuesPolicy.h"

#include <stdexcept>
#include <string>

#include "../database/Database.h"

std::mutex                              DuesPolicy::mutex_;
std::unordered_map<int, DuesPolicy::Cached> DuesPolicy::cache_;

DuesPolicy::Row DuesPolicy::current(int clubId) {
    using clock = std::chrono::steady_clock;
    constexpr auto kTtl = std::chrono::seconds(60);

    {
        std::lock_guard<std::mutex> lock(mutex_);
        auto it = cache_.find(clubId);
        if (it != cache_.end() && clock::now() - it->second.fetchedAt < kTtl) {
            return it->second.row;
        }
    }

    auto rows = Database::getInstance()->query(
        "SELECT fh_monthly_dues_usd($1::int)         AS usd,"
        "       fh_dues_pause_after_months($1::int)  AS months,"
        "       array_to_string(fh_dues_partial_amounts_usd($1::int), ',') AS partials",
        {std::to_string(clubId)});
    if (rows.empty() || rows[0]["usd"].is_null() || rows[0]["months"].is_null()) {
        throw std::runtime_error("dues_policies: no policy in force for club " + std::to_string(clubId));
    }
    Row row;
    row.monthlyDuesUsd   = rows[0]["usd"].as<double>();
    row.pauseAfterMonths = rows[0]["months"].as<int>();
    if (!rows[0]["partials"].is_null()) {
        std::string list = rows[0]["partials"].c_str();
        for (size_t start = 0; start <= list.size();) {
            size_t comma = list.find(',', start);
            if (comma == std::string::npos) comma = list.size();
            try { if (comma > start) row.partialAmountsUsd.push_back(std::stod(list.substr(start, comma - start))); }
            catch (const std::exception&) {}
            start = comma + 1;
        }
    }

    std::lock_guard<std::mutex> lock(mutex_);
    cache_[clubId] = Cached{row, clock::now()};
    return row;
}

void DuesPolicy::invalidate() {
    std::lock_guard<std::mutex> lock(mutex_);
    cache_.clear();
}
