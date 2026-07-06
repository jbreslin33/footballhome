#pragma once
#include <memory>
#include <string>
#include "../core/Controller.h"

class PayReminderLog;

// POST /api/pay-reminder-log
//   body: {leagueAppsUserId, method: 'sms'|'email', club?, tier?,
//          amount?, daysOverdue?}
//
// Bearer-presence auth.  Response: 201 with {ok:true}.
// The frontend fires this via fetch({keepalive:true}) right before
// navigating to the sms:/mailto: URL so it survives the tab switch.
class PayReminderLogController : public Controller {
public:
    PayReminderLogController();
    ~PayReminderLogController() override;

    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    std::unique_ptr<PayReminderLog> model_;

    Response handleCreate(const Request& request);
};
