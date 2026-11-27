#pragma once
#include <memory>
#include <string>
#include "../core/Controller.h"

class PersonSheet;

// PersonSheetController — the ⋯ player sheet's own read (owner 2026-11-20:
// the card is the same wherever it is opened from).
//
//   GET  /api/person-sheet?person_id=N | ?la_user_id=N
//        PersonSheet::card.  Club admins and coaches; 403 for players.
//
//   GET  /api/person-sheet/attendance?person_id=N[&fh_event_id=M]
//        PersonSheet::attendance — the events the caller may take this
//        person's roll on (none for a player), M's first.
//
//   POST /api/person-sheet/volunteer  { person_id, on }
//        🙋 club_volunteers row on / off — club admins.  Answers the card.
class PersonSheetController : public Controller {
public:
    PersonSheetController();
    ~PersonSheetController() override;
    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    std::unique_ptr<PersonSheet> model_;

    Response handleCard(const Request& request);
    Response handleAttendance(const Request& request);
    Response handleVolunteer(const Request& request);
};
