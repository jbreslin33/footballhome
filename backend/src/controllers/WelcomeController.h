#pragma once
#include <memory>
#include <string>
#include "../core/Controller.h"

class WelcomeLog;

// POST /api/welcomes
//   body: {person_id, channel: 'sms'|'email', contact, player_person_id?}
//
// The roster-card WELCOME button (owner 2026-09-06).  person_id is who
// RECEIVES the message — the parent for youth boards, the player for
// adults; player_person_id names the child in the youth copy.  Mints a
// 72h magic sign-in link for person_id (MagicLinkService — the same path
// the LINK buttons use), records a person_welcomes row, and returns the
// pre-filled Gmail / mailto / sms hrefs the browser opens.
//
// Response: 201 {url, expires_at, gmail_href?, mailto_href?, sms_href?,
//                welcome: {due:false, lastSentAt, lastChannel, lastContact}}
class WelcomeController : public Controller {
public:
    WelcomeController();
    ~WelcomeController() override;
    void registerRoutes(Router& router, const std::string& prefix) override;
private:
    std::unique_ptr<WelcomeLog> model_;
    Response handleCreate(const Request& request);
};
