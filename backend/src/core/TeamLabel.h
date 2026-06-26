#pragma once
#include <string>

// ────────────────────────────────────────────────────────────────────────────
// TeamLabel — pure-function utility for compressing a full team name into a
// 6-character chip label (e.g. "Lighthouse 1893 SC Liga 1" → "Liga 1").
//
// Mirrors meta-leads-webhook/index.js `shortTeamLabel()` one-to-one so the
// la-pool / youth-roster / mens-roster shipping payloads keep the same
// shortLabel values across the Node→C++ cutover.
//
// Static-method-only class (no state) — placed in core/ because every roster-
// shaped controller in the porting plan needs it.
// ────────────────────────────────────────────────────────────────────────────
class TeamLabel {
public:
    static std::string shortLabel(const std::string& name);
};
