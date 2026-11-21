#pragma once
#include <string>
#include "../core/Controller.h"

// CoachScheduleController — /api/coach-schedule, behind #coach-schedule.
// Mig 955 began it as weekdays per section; mig 1634 makes it the standing
// week of practice SESSIONS (weekday + local start, fh_practice_sessions()),
// weekend duty (= the coach's teams' games), and cover asks.
// fh_coach_off_schedule() decides what each coach sees and RSVPs to.
//
//   GET  /api/coach-schedule?week=YYYY-MM-DD  (or ?cover=<id>: that ask's week)
//        { me, sessions, coaches, week: { start, events } }
//   GET  /api/coach-schedule/event/<id>        { covers, past, me, me_on, coaches } — the event page's 🆘 strip + 🙋 ask (migs 1640/1643)
//   POST /api/coach-schedule/session          { coach_id, isodow, starts_at, on }   admin
//   POST /api/coach-schedule/plan             { coach_id, mode: every | call_in }   admin
//   POST /api/coach-schedule/cover            { fh_event_id, coach_id, ask: [coach_id], note }
//   POST /api/coach-schedule/cover/<id>/take      the caller covers it (admin: { coach_id })
//   POST /api/coach-schedule/cover/<id>/withdraw  the asker or an admin
//   POST /api/coach-schedule/cover/<id>/text      { coach_id } → { sms_href }: their own sign-in link (mig 1640)
//
// #coach-schedule is the owner's screen (menu: admin); coaches use the
// event / cover endpoints from their calendar.  Only admins change sessions.  A coach asks cover for themself; an admin for anyone.
class CoachScheduleController : public Controller {
public:
    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    struct Caller { long long userId = 0; long long coachId = 0; bool admin = false; };
    bool gate(const Request& request, Caller* caller, Response* error);

    Response handleGet(const Request& request);
    Response handleEventCovers(const Request& request);
    Response handleSession(const Request& request);
    Response handlePlan(const Request& request);
    Response handleCoverCreate(const Request& request);
    Response handleCoverAction(const Request& request);
};
