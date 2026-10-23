#pragma once
#include <string>
#include "../core/Controller.h"

// /api/phone-relay — FH Texter (migration 667): a coach's own Android
// sends the one text the coach clicked Send on in Football Home, from the
// coach's own number.  Owner 2026-10-23: "this solution we want me on web
// desktop and send. no phone interaction by me" — and "i don't want
// anything that could get us rate limited or blocked", so every text is
// one click, one recipient, spaced and capped by phone_relay_policy.
//
// Website (signed-in club admin):
//   GET  /status          paired phones (online?), today's count, cap
//   POST /pair-code       one-time code to type into the app
//   POST /texts           {to, body, for_person_id?, purpose?} — queue one
//   GET  /texts/:id       its status (queued → sending → sent → delivered)
// Phone (X-FH-Device token from /device/pair):
//   POST /device/pair     {code, name, app_version} → {token}
//   POST /device/next     heartbeat; hands over the next due text
//   POST /device/report   {id, status: sent|delivered|failed, error?}
class PhoneRelayController : public Controller {
public:
    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    // Signed-in club admin → their person_id, else *error.
    bool requireSender(const Request& request, long long* personId, Response* error);
    // X-FH-Device token → device id (and its person), else *error.
    bool requireDevice(const Request& request, long long* deviceId, Response* error);

    Response handleStatus(const Request& request);
    Response handlePairCode(const Request& request);
    Response handleQueue(const Request& request);
    Response handleTextStatus(const Request& request);
    Response handleDevicePair(const Request& request);
    Response handleDeviceNext(const Request& request);
    Response handleDeviceReport(const Request& request);
};
