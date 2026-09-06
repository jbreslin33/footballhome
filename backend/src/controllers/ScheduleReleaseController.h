#pragma once
#include <string>
#include "../core/Controller.h"

// Schedule release window — when next week's schedule posts to players
// and parents (migration 334).  The standing rule lives in
// schedule_release_policies, an early open is a row in
// schedule_week_releases, and the window itself is derived by
// fh_schedule_window_end() — this controller only reads/writes the two
// tables and reports what the functions say.
//
//   GET  /api/schedule/window?week_start=YYYY-MM-DD[&club_id=][&section_id=]
//        public.  {club_id, week_start, policy{weekday,time,time_zone,label},
//                  policy_opens_at, release{...}|null, opens_at, open_now}
//   GET  /api/schedule/releases[?club_id=]          admin (club/super)
//   POST /api/schedule/releases                      admin
//        body {week_start, club_id?, section_id?, note?}  → opens the week now
//   POST /api/schedule/releases/:id/revoke            admin
//   PUT  /api/schedule/policy                         admin
//        body {cutover_weekday, cutover_time, club_id?, section_id?}
//        → new policy row effective today (same-day edit updates it)
//
// club_id defaults to the club that owns the most active teams (the one
// club this deployment serves); section_id defaults to club-wide.
class ScheduleReleaseController : public Controller {
public:
    ScheduleReleaseController();
    ~ScheduleReleaseController() override;

    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    Response handleWindow(const Request& request);
    Response handleListReleases(const Request& request);
    Response handleCreateRelease(const Request& request);
    Response handleRevokeRelease(const Request& request);
    Response handlePutPolicy(const Request& request);
};
