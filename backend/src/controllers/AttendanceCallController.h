#pragma once
#include <string>
#include "../core/Controller.h"

// AttendanceCallController — /api/attendance-calls, the 📞 strip on a
// practice's Players pill (mig 1277; AttendanceCallScheduler places the
// calls).
//
//   GET /api/attendance-calls/event?id=<fh_event_id>
//     → { on, live, test_name, repeat_minutes, calls_from, calls_until,
//         started, over, coaches: [{name, phone}], unmarked: [names],
//         going_players, rounds: [{round, at, unmarked, live, ok, tried}] }
//
// Admins and active coaches only.
class AttendanceCallController : public Controller {
public:
    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    Response handleEvent(const Request& request);
};
