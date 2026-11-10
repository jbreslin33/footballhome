#pragma once
#include <string>
#include "../core/Controller.h"

// VolunteerController — the #payments side of 🙋 volunteer shifts (mig
// 1222): the owner approves or declines a player's pick.  The player side
// (pick / cancel) is /api/my/volunteer on MyController.
//
//   GET  /api/volunteer/requests        { requests: [...] }  pending, oldest first
//   POST /api/volunteer/requests/:id    {decision: approve|deny}
class VolunteerController : public Controller {
public:
    VolunteerController();
    void registerRoutes(Router& router, const std::string& prefix) override;
private:
    bool gate(const Request& request, Response* error);
    Response handleRequests(const Request& request);
    Response handleDecide(const Request& request);
};
