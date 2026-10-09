#pragma once
#include <string>
#include "../core/Controller.h"

// CupRosterController — #cup-rosters (migration 556): the USASA Region I
// Player Pool sheet (the EPSA / USASA cup roster form) filled from the
// men's rosters.  Owner 2026-10-09: "reproduce this like we did for
// invoices. have a blank one and then allow me to check off players to
// fill it from apsl and liga 1 and reserves".
//
//   GET  /api/cup-rosters/board            { rosters: [...], pool: [...], teams: [...], max }
//   POST /api/cup-rosters/new              {} → { id }  (header copied from the last sheet)
//   GET  /api/cup-rosters/:id              the sheet with its players
//   POST /api/cup-rosters/:id/update       { field: value, … }  header fields
//   POST /api/cup-rosters/:id/players      { person_ids: [...] }  replaces the set
//   DELETE /api/cup-rosters?id=            removes the sheet
//   GET  /api/cup-rosters/public/:slug     the sheet, no sign-in (the /cup-roster?k= page)
class CupRosterController : public Controller {
public:
    CupRosterController();
    void registerRoutes(Router& router, const std::string& prefix) override;
private:
    bool gate(const Request& request, Response* error);
    Response handleBoard(const Request& request);
    Response handleNew(const Request& request);
    Response handleGet(const Request& request);
    Response handleUpdate(const Request& request);
    Response handlePlayers(const Request& request);
    Response handleDelete(const Request& request);
    Response handlePublic(const Request& request);
};
