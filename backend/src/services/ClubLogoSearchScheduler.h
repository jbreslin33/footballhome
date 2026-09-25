#pragma once
#include <string>
#include "../models/ClubLogoSearch.h"

// ────────────────────────────────────────────────────────────────────────────
// ClubLogoSearchScheduler — works the club_logo_searches queue (mig 432).
// One detached thread, every 60 s, at most two searches per tick:
//
//   1. ClubLogoFinder::search()  — which club, and a crest URL
//   2. download the image, ClubLogo::sniff() — is it an image at all
//   3. ClubLogoFinder::judge()   — is it a real crest
//   4. ClubLogo::save() as the club's current logo (source 'search'),
//      club_aliases opponent text → club, row = 'found'
//
// Anything short of that = 'none' (nothing usable) or 'failed' (an error;
// retried up to three times).  Same lifetime convention as LockupScheduler.
// runOne() is public so a test or the controller can drive a row inline.
// ────────────────────────────────────────────────────────────────────────────
class ClubLogoSearchScheduler {
public:
    static ClubLogoSearchScheduler& getInstance();
    void start();
    ClubLogoSearch::Result runOne(const ClubLogoSearch::Row& row);

private:
    ClubLogoSearchScheduler() = default;
    ClubLogoSearchScheduler(const ClubLogoSearchScheduler&) = delete;
    ClubLogoSearchScheduler& operator=(const ClubLogoSearchScheduler&) = delete;
    void loop();
    void tick();
    bool running_ = false;
};
