#pragma once
#include <memory>
#include <string>
#include "../core/Controller.h"

class Contacts;

// /api/contacts — #contacts (migration 541): the club's people into the
// operator's phone as one vCard file.  Club admins only.
//   GET  /summary                       counts per group (new / changed / all) + last export
//   POST /export { groups, scope, dry_run }   text/vcard (logged), or a JSON preview
class ContactsController : public Controller {
public:
    ContactsController();
    ~ContactsController() override;
    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    std::unique_ptr<Contacts> model_;
    bool gate(const Request& request, Response* error);
    Response handleSummary(const Request& request);
    Response handleExport(const Request& request);
};
