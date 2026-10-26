#pragma once
#include <string>
#include "../third_party/json.hpp"

// ────────────────────────────────────────────────────────────────────────────
// ContactDrafts — one-to-one email drafts to a club/league contact
// (contact_email_drafts, migration 724).
//
// Owner 2026-10-26: "if i want to email aaron about something like
// reschedule or time change i should be able to without others being
// involved ... draft emails from here ... and then delete them if we want
// if they were one offs".  Send itself is the owner's Gmail (the page
// builds the compose link); markSent() records it and logs the send in
// club_contact_messages like the other contact buttons.
// ────────────────────────────────────────────────────────────────────────────
class ContactDrafts {
public:
    // { contact: {id, name, email}, drafts: [unsent, newest first],
    //   sent: [last 5 sent] } — null when the contact doesn't exist.
    static nlohmann::json forContact(long long contactId);
    // Insert (id 0) or update an unsent draft → the saved draft, or null
    // when the id is unknown / already sent.
    static nlohmann::json save(long long id, long long contactId, long long matchId,
                               const std::string& subject, const std::string& body, long long userId);
    static bool remove(long long id);
    // Stamp sent_at and log the email → { to } for the compose link, or
    // null when the draft is gone or its contact has no email.
    static nlohmann::json markSent(long long id, long long userId);
};
