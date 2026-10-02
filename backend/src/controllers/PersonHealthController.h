#pragma once
#include <memory>
#include <string>
#include "../core/Controller.h"

class PersonHealth;

// PersonHealthController — the health dropdown on the #teams roster cards
// (migration 510, owner 2026-10-02).
//
//   GET /api/person-health
//       The dropdown (health_statuses), its copy (message_templates kind
//       'health') and everyone injured right now, keyed by person id.
//       Club admins and coaches.
//
//   PUT /api/person-health   { person_id, status, since?, until? }
//       status = a health_statuses code; since / until = YYYY-MM-DD.
//       Healthy ends the current injury; an injury status starts one or
//       edits the current one.  Admins, or a coach of a team the person
//       is on.  Answers { person_id, health } — health null = healthy.
class PersonHealthController : public Controller {
public:
    PersonHealthController();
    ~PersonHealthController() override;
    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    std::unique_ptr<PersonHealth> model_;

    Response handleBoard(const Request& request);
    Response handleSet(const Request& request);
};
