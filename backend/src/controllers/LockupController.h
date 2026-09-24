#pragma once
#include <memory>
#include <string>
#include "../core/Controller.h"

class FacilityLockup;

// LockupController — #security and the upload link (mig 421/424, owner
// 2026-09-24: "call phone if no upload of picture of locked gate is
// uploaded to footballhome within 45 minutes of end time … a security
// button at top level of admin … and an upload button to accept a pic").
//
//   GET  /api/security/board          tonight per facility + last 30 nights +
//                                     who is asked / alerted.  Admins, listed
//                                     people, active coaches.
//   POST /api/security/photo          { lockup_id, image: "data:image/…;base64,…" }
//                                     the upload button on #security; the photo
//                                     marks the night locked.
//   GET  /api/security/tap?t=…        public: the link in the prompt / alert —
//                                     a page with one camera button, no login.
//   POST /api/security/tap-photo?t=…  { image }  the upload from that page.
//   POST /api/security/test           { channel: email|sms|call }  admin only:
//                                     tonight's alert copy to the caller's own
//                                     contact so the pipe can be checked.
class LockupController : public Controller {
public:
    LockupController();
    ~LockupController() override;
    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    struct Scope { long long userId = 0, personId = 0; bool isAdmin = false; };
    bool resolveScope(const Request& request, Scope* scope, Response* error);

    Response handleBoard(const Request& request);
    Response handlePhoto(const Request& request);
    Response handleTap(const Request& request);
    Response handleTapPhoto(const Request& request);
    Response handleTest(const Request& request);

    // Decodes a data: URL, checks it is a JPEG/PNG/WebP, writes it under
    // /app/images/security and returns the nginx path.  "" + *error on failure.
    std::string savePhoto(long long lockupId, const std::string& dataUrl,
                          std::string* mime, long long* byteSize, std::string* error);

    std::unique_ptr<FacilityLockup> model_;
};
