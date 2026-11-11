#pragma once
#include <string>

// ────────────────────────────────────────────────────────────────────────────
// AttendanceCallScheduler — 📞 practice attendance calls (mig 1277; owner
// 2026-11-11: "call all coaches that set going to practice 1/2 way through
// to remind to take attendance … until all players who set going are markd
// off … like it does for lockup in security screen").
//
// Every minute: each practice in fh_attendance_calls_due (past its
// halfway point, someone Going still unmarked, a Going coach to call, no
// round inside repeat_minutes) gets a round — a phone call to every Going
// coach (fh_attendance_call_going is_coach), and with round 1 a text
// listing the unmarked names + a magic link to #event/<id>/players.
// attendance_call_policies.live = false sends it all to test_person_id
// instead.  Rounds in attendance_call_rounds, every try in
// attendance_call_log.  Wording: message_templates kind=attendance_call.
// ────────────────────────────────────────────────────────────────────────────
class AttendanceCallScheduler {
public:
    static AttendanceCallScheduler& getInstance();
    void start();

private:
    AttendanceCallScheduler() = default;
    AttendanceCallScheduler(const AttendanceCallScheduler&) = delete;
    AttendanceCallScheduler& operator=(const AttendanceCallScheduler&) = delete;

    void loop();
    void tick();
    bool running_ = false;
};
