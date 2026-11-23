#pragma once
#include <string>
#include "../core/Controller.h"

// ProposalsController — 📑 #proposals (mig 1572), club admins only, except
// the public read of a proposal flagged is_public (mig 1713).
//
//   GET /api/proposals               { proposals: [...] }
//   GET /api/proposals/:code         { proposal: {..., sections: [{heading, body}]}, recipients }
//   POST /api/proposals/recipients/:id  { email } → { recipients }
//   GET /api/proposals/public/:code  no login: { proposal, copy } for an
//                                    is_public proposal, else 404
class ProposalsController : public Controller {
public:
    ProposalsController();
    void registerRoutes(Router& router, const std::string& prefix) override;
private:
    bool gate(const Request& request, Response* error);
    Response handleList(const Request& request);
    Response handleOne(const Request& request);
    Response handlePublic(const Request& request);
    Response handleRecipientEmail(const Request& request);
};
