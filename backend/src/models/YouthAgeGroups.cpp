#include "YouthAgeGroups.h"

#include <chrono>
#include <ctime>

#include "../database/Database.h"

YouthAgeGroups::YouthAgeGroups()
    : db_(Database::getInstance()) {}

std::vector<YouthAgeGroups::Bucket>
YouthAgeGroups::loadFor(int seasonEndYear) {
    std::vector<Bucket> out;
    const std::string sql =
        "SELECT bucket_label, club_filter, "
        "       TO_CHAR(min_birth_date, 'YYYY-MM-DD') AS min_iso, "
        "       TO_CHAR(max_birth_date, 'YYYY-MM-DD') AS max_iso, "
        "       max_roster, sort_order, color "
        "  FROM youth_age_groups "
        " WHERE season_end_year = $1 "
        " ORDER BY sort_order";
    const std::vector<std::string> params = {std::to_string(seasonEndYear)};
    const auto rows = db_->query(sql, params);
    out.reserve(rows.size());
    for (const auto& row : rows) {
        Bucket b;
        b.label        = row["bucket_label"].is_null() ? std::string{} : row["bucket_label"].c_str();
        b.clubFilter   = row["club_filter"].is_null()  ? std::string{} : row["club_filter"].c_str();
        b.minBirthIso  = row["min_iso"].is_null()      ? std::string{} : row["min_iso"].c_str();
        b.maxBirthIso  = row["max_iso"].is_null()      ? std::string{} : row["max_iso"].c_str();
        b.sortOrder    = row["sort_order"].is_null()   ? 0             : row["sort_order"].as<int>();
        b.hasMaxRoster = !row["max_roster"].is_null();
        b.maxRoster    = b.hasMaxRoster ? row["max_roster"].as<int>() : 0;
        b.color        = row["color"].is_null() ? std::string{} : row["color"].c_str();
        out.push_back(std::move(b));
    }
    return out;
}

const YouthAgeGroups::Bucket*
YouthAgeGroups::matchBucket(const std::string& birthDateIso,
                            const std::string& club,
                            const std::vector<Bucket>& buckets) {
    if (birthDateIso.empty()) return nullptr;
    for (const auto& b : buckets) {
        if (!b.clubFilter.empty() && b.clubFilter != club) continue;
        if (birthDateIso >= b.minBirthIso && birthDateIso <= b.maxBirthIso) return &b;
    }
    return nullptr;
}

int YouthAgeGroups::defaultSeasonEndYear() {
    const auto now = std::chrono::system_clock::now();
    const std::time_t t = std::chrono::system_clock::to_time_t(now);
    std::tm tm_local{};
    localtime_r(&t, &tm_local);
    const int y = tm_local.tm_year + 1900;
    // tm_mon is 0-based → tm_mon >= 5 means Jun-Dec.
    return (tm_local.tm_mon >= 5) ? y + 1 : y;
}
