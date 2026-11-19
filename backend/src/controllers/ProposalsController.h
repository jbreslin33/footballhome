#pragma once
#include <string>
#include "../core/Controller.h"

// ProposalsController — 📑 #proposals (mig 1572), club admins only.
//
//   GET /api/proposals          { proposals: [...] }
//   GET /api/proposals/:code    { proposal: {..., sections: [{heading, body}]} }
class ProposalsController : public Controller {
public:
    ProposalsController();
    void registerRoutes(Router& router, const std::string& prefix) override;
private:
    bool gate(const Request& request, Response* error);
    Response handleList(const Request& request);
    Response handleOne(const Request& request);
};
