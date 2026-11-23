#pragma once
#include <string>
#include "../core/Controller.h"

// LeagueEntryController — 📝 #league-registration (mig 1746), club admins.
//
//   GET  /api/league-entries                  { entries }
//   POST /api/league-entries/team   {id, fields}          a team's form answers
//   POST /api/league-entries/entry  {id, fields}          who it goes to, note
//   POST /api/league-entries/item   {id, done}            tick the checklist
//   POST /api/league-entries/send   {id, files:[{filename, file}]}   ✉️ the filled forms
class LeagueEntryController : public Controller {
public:
    LeagueEntryController();
    void registerRoutes(Router& router, const std::string& prefix) override;
private:
    bool gate(const Request& request, Response* error);
};
