#pragma once
#include <string>
#include "../core/Controller.h"

// ScheduleLinksController — the #league-schedules page (migration 566):
// the leagues' own schedule pages (the owner's "schedules" bookmarks) as
// DB rows, listed on a page and edited there (owner 2026-10-12: "please
// save them and display links on a page on fh").
//
//   GET    /api/schedule-links          { links: [{ id, label, url, note, sort_order }] }
//   POST   /api/schedule-links          { id?, label, url, note?, sort_order? }  upsert → { links }
//   DELETE /api/schedule-links?id=…     retire a link (is_active = false) → { links }
class ScheduleLinksController : public Controller {
public:
    ScheduleLinksController();
    void registerRoutes(Router& router, const std::string& prefix) override;
private:
    bool gate(const Request& request, Response* error);
    nlohmann::json links();
    Response handleList(const Request& request);
    Response handleUpsert(const Request& request);
    Response handleRemove(const Request& request);
};
