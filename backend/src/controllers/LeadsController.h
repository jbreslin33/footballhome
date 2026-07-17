#pragma once
#include <optional>
#include <string>
#include "../core/Controller.h"

// ────────────────────────────────────────────────────────────────────────────
// LeadsController — REST surface for the Leads page (admin tool that
// triages Meta lead-form responses into contact attempts and youth /
// adult roster placeholders).
//
// Routes (mounted at prefix "/api/leads"):
//   POST   /api/leads/sync                refresh-from-Meta + return report
//   GET    /api/leads                     DB-only list with per-row contact agg
//   POST   /api/leads/:id/contact         log a text/email/whatsapp/call send
//   GET    /api/leads/:id/contacts        recent touches for one lead (audit)
//   DELETE /api/leads/:id/contacts/:cid   remove an accidental touch (+ siblings)
//   GET    /api/leads/contact-stats       per-lead + windowed aggregates
//   GET    /api/leads/next-pickup         next upcoming Pickup chat_event
//   GET    /api/leads/:id/vcard           vCard download (self/parent/player/
//                                                         youth-pair)
//   POST   /api/leads/:id/mark-converted  manual signed-up flag (set)
//   DELETE /api/leads/:id/mark-converted  clear the flag (undo)
//   POST   /api/leads/:id/mark-dead       closed-lost flag (set)
//   DELETE /api/leads/:id/mark-dead       clear the flag (revive)
//   POST   /api/leads/:id/status-override manual lifecycle color override
//                                          body: {status: 'new'|'responded'|
//                                                 'signedup'|'dead'|null}
//                                          null clears the override.
//   POST   /api/leads/guest-signup        PUBLIC (no auth) — form-post
//                                          landing at /pickup.  Body:
//                                          {name, phone?, email?, ad?,
//                                           age_group?, gender?, experience?,
//                                           position?, notes?}.  Requires
//                                          name AND (phone OR email).
//                                          Inserts a leads row with
//                                          form_id='pickup-funnel',
//                                          leadgen_id='guest-<epoch>-<rand>'.
//
// All routes are bearer-presence gated.  The contact handler additionally
// decodes the JWT payload (no signature verify) to extract `userId` so
// `lead_contacts.contacted_by` matches the Node behavior.
// The guest-signup route is the sole exception — deliberately public so
// Meta ads can send unauthenticated traffic straight to the funnel.
// ────────────────────────────────────────────────────────────────────────────
class LeadsController : public Controller {
public:
    LeadsController() = default;
    ~LeadsController() override = default;

    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    Response handleSync             (const Request& request);
    Response handleList             (const Request& request);
    Response handleLogContact       (const Request& request);
    Response handleListContacts     (const Request& request);
    Response handleDeleteContact    (const Request& request);
    Response handleContactStats     (const Request& request);
    Response handleNextPickup       (const Request& request);
    // NOTE: /unjoined-members is registered via laGet(dynamic) so LA
    // membership is freshly synced (persons + aliases +
    // person_la_memberships + person_emails + person_phones) before this
    // handler ever runs.  The handler therefore reads exclusively from
    // Postgres — no LA fetch inside.  The LaSyncMap param is unused
    // (handler doesn't need per-program metadata); marked (void).
    Response handleUnjoinedMembers  (const Request& request, const LaSyncMap& sync);
    Response handleAnalytics        (const Request& request);
    Response handleVcard            (const Request& request);
    Response handleMarkConverted    (const Request& request);
    Response handleUnmarkConverted  (const Request& request);
    Response handleMarkDead         (const Request& request);
    Response handleUnmarkDead       (const Request& request);
    Response handleSetStatusOverride(const Request& request);
    Response handleGuestSignup      (const Request& request);

    // Auth helpers.
    static std::optional<int>  extractUserIdJwt (const Request& request);

    // /api/leads/:id/{contact,contacts,vcard,mark-converted,mark-dead,status-override}
    static bool extractLeadId   (const std::string& path, int& leadId);
    // /api/leads/:id/contacts/<cid>
    static bool extractContactId(const std::string& path, int& contactId);
};
