#pragma once
#include <string>
#include "../core/Controller.h"

// FinesController — the #fines page (migration 534): the Men's fines on a
// page of their own (owner 2026-10-06: "we need a fines section … i think
// its own").  Nothing stored: PersonFines derives every fine from RSVP and
// attendance rows against fine_policies (mig 460); this rolls them up by
// month and by player with where each month's LeagueApps posting stands.
//
//   GET /api/fines?months=6   { months: [...], people: [...], rules: [...] }
class FinesController : public Controller {
public:
    FinesController();
    void registerRoutes(Router& router, const std::string& prefix) override;
private:
    bool gate(const Request& request, Response* error);
    Response handleBoard(const Request& request);
};
