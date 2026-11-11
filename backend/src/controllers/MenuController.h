#ifndef MENU_CONTROLLER_H
#define MENU_CONTROLLER_H

#include "../core/Controller.h"
#include "../core/Response.h"
#include "../core/Request.h"
#include "../database/Database.h"

// GET /api/menu — the main menu's groups and their pages (mig 1244).
// #role-selection draws one button per group; every page of a group wears
// the group's pill row (frontend/js/lib/main-menu.js).  Who sees a page is
// its `audience` (the old tile's rule); each page still gates itself on the
// server, so the list is not a security boundary.
class MenuController : public Controller {
public:
    MenuController();
    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    Database* db_;
    Response handleMenu(const Request& request);
};

#endif
