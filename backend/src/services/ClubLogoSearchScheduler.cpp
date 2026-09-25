#include "ClubLogoSearchScheduler.h"

#include <chrono>
#include <iostream>
#include <thread>

#include "../core/HttpClient.h"
#include "../database/Database.h"
#include "../models/ClubLogo.h"
#include "ClubLogoFinder.h"

ClubLogoSearchScheduler& ClubLogoSearchScheduler::getInstance() {
    static ClubLogoSearchScheduler instance;
    return instance;
}

void ClubLogoSearchScheduler::start() {
    if (running_) return;
    running_ = true;
    std::thread(&ClubLogoSearchScheduler::loop, this).detach();
}

void ClubLogoSearchScheduler::loop() {
    std::this_thread::sleep_for(std::chrono::seconds(20));
    while (running_) {
        try { tick(); }
        catch (const std::exception& e) { std::cerr << "ClubLogoSearchScheduler: " << e.what() << std::endl; }
        std::this_thread::sleep_for(std::chrono::seconds(60));
    }
}

void ClubLogoSearchScheduler::tick() {
    ClubLogoSearch queue;
    for (const auto& row : queue.nextQueued(2)) {
        queue.markRunning(row.id);
        ClubLogoSearch::Result r = runOne(row);
        queue.finish(row.id, r);
        std::cout << "ClubLogoSearch: " << row.opponentText << " -> " << r.status
                  << (r.clubNameFound.empty() ? "" : " (" + r.clubNameFound + ")")
                  << (r.error.empty() ? "" : " " + r.error) << std::endl;
    }
}

ClubLogoSearch::Result ClubLogoSearchScheduler::runOne(const ClubLogoSearch::Row& row) {
    ClubLogoSearch::Result r;
    r.provider = "anthropic";
    auto& finder = ClubLogoFinder::getInstance();
    r.model = finder.model();
    try {
        ClubLogoFinder::Candidate c = finder.search(row.opponentText, row.context);
        r.clubNameFound = c.clubName;
        r.imageUrl = c.imageUrl;
        r.pageUrl = c.pageUrl;
        r.reason = c.reason;
        r.confidence = c.confidence;
        if (!c.found()) { r.status = "none"; return r; }

        HttpClient http;
        auto img = http.get(c.imageUrl, {{"Accept", "image/*,*/*;q=0.8"}});
        if (!img.ok()) {
            r.status = "none";
            r.judgeNote = "could not download the image (" + (img.error.empty() ? "HTTP " + std::to_string(img.status) : img.error) + ")";
            return r;
        }
        const auto sniffed = ClubLogo::sniff(img.body);
        if (!sniffed.ok) { r.status = "none"; r.judgeNote = "the URL was not an image file"; return r; }
        if (img.body.size() > 8 * 1024 * 1024) { r.status = "none"; r.judgeNote = "image over 8 MB"; return r; }

        // SVG cannot be shown to the model as an image; trust the finder for
        // it, since an SVG on a club's own page is rarely a photo.
        if (sniffed.ext != "svg") {
            ClubLogoFinder::Verdict v = finder.judge(img.body, sniffed.mime, c.clubName);
            r.judgeNote = v.note;
            if (!v.isCrest) { r.status = "none"; return r; }
        } else {
            r.judgeNote = "SVG — not checked by eye";
        }

        ClubLogo logos;
        const std::string name = c.clubName.empty() ? row.opponentText : c.clubName;
        long long clubId = logos.resolveClub(name);
        if (clubId <= 0) clubId = logos.createClub(name);
        if (clubId <= 0) { r.status = "failed"; r.error = "could not create the club"; return r; }
        ClubLogo::Saved saved = logos.save(clubId, img.body, "search", c.imageUrl, c.pageUrl, 0);
        if (!saved.ok()) { r.status = "failed"; r.error = saved.error; return r; }
        std::string aliasErr;
        Database::getInstance()->query(
            "INSERT INTO club_aliases (club_id, alias, notes) VALUES ($1::int, BTRIM($2), 'found online (search)') "
            "ON CONFLICT (LOWER(BTRIM(alias))) DO UPDATE SET club_id = EXCLUDED.club_id",
            {std::to_string(clubId), row.opponentText});
        r.clubId = clubId;
        r.logoId = saved.logoId;
        r.status = "found";
    } catch (const std::exception& e) {
        r.status = "failed";
        r.error = e.what();
    }
    return r;
}
