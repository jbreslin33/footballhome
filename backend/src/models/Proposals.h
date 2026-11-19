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
    // {code,label,icon}, asOf, screen, sections (count).
    static nlohmann::json list();

    // One proposal with its sections [{heading, body}] in order; null when
    // there is no active proposal with that code.
    static nlohmann::json one(const std::string& code);
};
