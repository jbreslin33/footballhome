#pragma once
#include <string>
#include <vector>
#include "../third_party/json.hpp"

class Database;

// ────────────────────────────────────────────────────────────────────────────
// ClubLogoSearch — the club_logo_searches queue (migration 432): one row
// per opponent text ever looked up online.  Owns every SQL touch on that
// table; ClubLogoSearchScheduler drives it, ClubLogoController shows it.
// ────────────────────────────────────────────────────────────────────────────
class ClubLogoSearch {
public:
    struct Row {
        long long   id = 0;
        std::string opponentText, context, status;
        int         attempts = 0;
    };
    struct Result {
        std::string status;          // found | none | failed
        std::string clubNameFound, imageUrl, pageUrl, reason, judgeNote, error, provider, model;
        long long   clubId = 0, logoId = 0;
        double      confidence = 0;
    };

    ClubLogoSearch();

    // Queue a search for this text unless one already exists.  A prior
    // 'none'/'failed' row is re-queued when `force` (the button on #logos);
    // 'found'/'rejected' rows are left alone.  Returns the row id.
    long long enqueue(const std::string& opponentText, long long personId, bool force);
    bool      alreadyKnown(const std::string& opponentText);
    std::vector<Row> nextQueued(int limit);
    void markRunning(long long id);
    void finish(long long id, const Result& r);
    // Reject a found crest: the row is 'rejected' and the club's current
    // logo is cleared if it is the one this search stored.
    bool reject(long long id, long long personId);
    // What the calendar knows about the text (league, section, team) — the
    // context line the finder prompt gets.
    std::string contextFor(const std::string& opponentText);
    nlohmann::json recent(int limit);

private:
    Database* db_;
};
