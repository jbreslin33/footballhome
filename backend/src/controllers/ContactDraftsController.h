#pragma once
#include <string>
#include "../core/Controller.h"

// ContactDraftsController — /api/contact-drafts, the 📝 drafts under a
// contact in Game Center's 📇 panel (migration 724, owner 2026-10-26:
// email the APSL commissioner about our home-game times "without others
// being involved", drafts kept until sent or deleted).  Club admins only.
//
//   GET    /api/contact-drafts?contact_id=   { contact, drafts[], sent[] }   (ContactDrafts::forContact)
//   POST   /api/contact-drafts               { id?, contact_id, match_id?, subject, body, recipient_ids? } → { draft }
//                                             recipient_ids (mig 726) replaces who it goes To; contact_id always stays
//   DELETE /api/contact-drafts?id=
//   POST   /api/contact-drafts/sent          { id } → { to: "a,b" }   the page opens Gmail with it filled in
class ContactDraftsController : public Controller {
public:
    void registerRoutes(Router& router, const std::string& prefix) override;
private:
    bool gate(const Request& request, Response* error);
    Response handleList(const Request& request);
    Response handleSave(const Request& request);
    Response handleDelete(const Request& request);
    Response handleSent(const Request& request);
};
