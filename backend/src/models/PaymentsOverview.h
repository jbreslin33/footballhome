#pragma once
#include "../third_party/json.hpp"

// ────────────────────────────────────────────────────────────────────────────
// PaymentsOverview — the Summary and Projections at the top of #payments
// (migration 489).
//
// Owner 2026-09-29: "show me projections on financial page. like for each
// group and overall. based on current members ... current members who are
// current in dues, then another with just current members ... per month
// and per year. for all and each boys, men etc" — "put all at top".
//
// Nothing is stored.  For each club section (club_sections, matched to the
// LeagueApps program category men/women/boys/girls):
//   members  open rows on the section's active membership program
//   free     of those, la_payment_status NA_FREE (the women's program is
//            free; a few men too) — they project $0
//   paying   members − free
//   paid_up  paying members who owe $0                (current in dues)
//   behind   owe something but under the dues line
//   blocked  at or over the line (fh_dues_line_usd; cannot RSVP)
//   owed     sum of balances (fh_dues_balance_usd)
//   rate     fh_monthly_dues_usd for the section
//   projections.all_members  = paying × rate  (monthly), × 12 (yearly)
//   projections.current_dues = paid_up × rate,           × 12
// plus an "all" roll-up across the sections.
class PaymentsOverview {
public:
    static nlohmann::json build(int clubId);
};
