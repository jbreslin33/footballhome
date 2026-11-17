#pragma once
#include <string>
#include "../core/Controller.h"

// PersonSeesController — 👁 SEES + 📋 ROSTERS on the #teams cards
// (migration 1435, owner 2026-11-17).
//
//   GET /api/person-sees?ids=1,2,3
//       { people: { "<id>": { sees: [...], suspended, injured, rosters: [...] } } }
//       sees    = fh_person_sees: per board team, what its events ask him
//                 about by default (games / practices, and why not).
//       rosters = fh_person_rosters: the official league lists he is on.
//       Club admins and coaches (it carries injuries and suspensions).
class PersonSeesController : public Controller {
public:
    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    Response handleGet(const Request& request);
};
