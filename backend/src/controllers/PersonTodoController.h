#pragma once
#include <string>
#include "../core/Controller.h"

// PersonTodoController — the player sheet's ✅ To do tab (mig 1903).
// Owner 2026-11-25: "we need indivdual todo lists for all players" —
// financial aid / college applications for the high-school kids, "stretch
// every day" for others.  The player sees and ticks them in the 🚦 band
// (GET/POST /api/my/todos, PersonTodos::list); staff give and take back here.
//
//   GET  /api/person-todos?person_id=N          PersonTodos::sheet
//        Club admins and the player's coaches; 403 for anyone else.
//   POST /api/person-todos
//        {action:"give", person_id, body, repeat?:"daily", due_on?:"YYYY-MM-DD",
//         team_id?}   team_id = everyone on that team (viewer must manage it)
//        {action:"take", person_id, id, all?}   all = the item's whole batch
//        → the sheet again, plus {given: n} on a give.
class PersonTodoController : public Controller {
public:
    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    Response handleSheet(const Request& request);
    Response handlePost(const Request& request);
};
