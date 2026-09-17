#pragma once
#include <string>
#include <utility>
#include <vector>

#include "../third_party/json.hpp"
#include "WelcomeLog.h"

class Database;

// MessageCopy — the one way the backend turns a message_templates row
// into text (migration 366).  No outbound wording lives in C++: a
// controller names a (kind, tier), hands over the facts as tokens, and
// gets subject + body back.
//
// Template syntax:
//   {token}        the token's value; when that is empty, the word from
//                  the kind='fallback' row whose tier is the token name
//                  ("Hi there,") — or nothing if there is no such row.
//   [[ … ]]        optional section: kept only if every {token} inside
//                  has a value.  Fallback words never apply inside one.
//   {form:<code>}  club_forms link for the club (migration 365).
//
// Owner 2026-09-17: "we need all messages in db no hard code not even
// for nudges."
class MessageCopy {
public:
    using Tokens = std::vector<std::pair<std::string, std::string>>;

    struct Rendered {
        std::string subject;
        std::string body;
        bool ok() const { return !body.empty(); }
    };

    explicit MessageCopy(int clubId = WelcomeLog::kLighthouseClubId);

    // First active row for (kind, tier) by sort_order.  !ok() when the
    // row is missing — callers report that instead of sending nothing.
    Rendered render(const std::string& kind, const std::string& tier, const Tokens& tokens);

    // body + the kind='sms_link_hint' sentence (for any SMS with a link).
    std::string withSmsLinkHint(const std::string& smsBody);

    // The mailbox compose links open as (clubs.outreach_email).
    std::string outreachEmail();

    // Adds the hrefs the browser opens for a drafted message:
    //   email → mailto_href + gmail_href      sms → sms_href (hint added)
    void addComposeHrefs(nlohmann::json& out, const std::string& channel, const std::string& contact,
                         const std::string& subject, const std::string& emailBody,
                         const std::string& smsBody);

private:
    std::string fill(std::string text, const Tokens& tokens);
    std::string fallbackFor(const std::string& token);

    Database* db_;
    int       clubId_;
};
