#pragma once
#include <memory>
#include <string>
#include "../core/Controller.h"

class FacilityLockup;

// LockupController — #lockups and the one-tap confirm link (mig 421,
// owner 2026-09-24: "if we don't tell fh that lighthouse is secure …
// sends a text and email to me").
//
//   GET  /api/lockups/board          tonight per facility + last 30 nights +
//                                    who is asked / alerted.  Admins, listed
//                                    people, active coaches.
//   POST /api/lockups/:id/confirm    { note? }  "I locked it" from the board.
//   GET  /api/lockups/tap?t=…        public: the link in the prompt / alert.
//                                    Confirms and shows a small page whose
//                                    words are message_templates lockup/page_*.
//   POST /api/lockups/test           { channel: email|sms|call }  admin only:
//                                    sends tonight's alert copy to the caller's
//                                    own contact so the pipe can be checked.
class LockupController : public Controller {
public:
    LockupController();
    ~LockupController() override;
    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    struct Scope { long long userId = 0, personId = 0; bool isAdmin = false; };
    bool resolveScope(const Request& request, Scope* scope, Response* error);

    Response handleBoard(const Request& request);
    Response handleConfirm(const Request& request);
    Response handleTap(const Request& request);
    Response handleTest(const Request& request);

    std::unique_ptr<FacilityLockup> model_;
};
