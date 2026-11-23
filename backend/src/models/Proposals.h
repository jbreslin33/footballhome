#pragma once
#include <string>

#include "../third_party/json.hpp"

// ────────────────────────────────────────────────────────────────────────────
// Proposals — 📑 #proposals (mig 1572): every club proposal on one page.
//
// proposals = one row per proposal; status from proposal_statuses.  A
// proposal with its own hand-built page names it in `screen` (In-House,
// mig 900); the rest are drawn from proposal_sections at #proposals/<code>.
// ────────────────────────────────────────────────────────────────────────────
class Proposals {
public:
    // Active proposals in sort order: code, icon, title, summary, status
    // {code,label,icon}, asOf, screen, isPublic, sections (count).
    static nlohmann::json list();

    // One proposal with its sections [{heading, body}] in order; null when
    // there is no active proposal with that code.
    static nlohmann::json one(const std::string& code);

    // The same, but only for a proposal flagged proposals.is_public (mig
    // 1713): the one the standalone page /proposals/#<code> may show to
    // anyone.  Null otherwise.
    static nlohmann::json onePublic(const std::string& code);

    // The page wording, message_templates kind 'proposals': {tier: body}.
    static nlohmann::json copy();

    // Who a proposal is emailed to (proposal_recipients, mig 1713): [{id,
    // name, role, email}], email '' until someone types it on the page.
    // Addresses live only in the database, never in a migration file.
    static nlohmann::json recipients();
    static bool setRecipientEmail(int id, const std::string& email);
};
