#pragma once
#include "../third_party/json.hpp"

// ────────────────────────────────────────────────────────────────────────────
// DuesLedger — every soccer payment LeagueApps took, by section and month,
// since the books start (cash_flow_policies' budget year, Aug 1).
//
// Owner 2026-11-16: "tuition for nov looks off. if so are others off too?" →
// #tuition summed each listed member's payments, so money from anyone not on
// a tab today (moved to pickup, left) vanished, and its average divided by
// the months since the first payment ever → "we should be counting money
// gotten from pickup guys … we are couning their money lol". So the money
// is the payments, not the members: the same rule as #finances (CashFlow) —
// counted programs (la_soccer_programs.counts_in, pickup included), a
// dispute posted twice lands once, cards count at once, bank payments once
// LeagueApps deposited them (mig 1386; until then pending). Section = the
// LeagueApps program's category the money was paid into.
//
// byMonth(): { start, now_ym, sections: { men|women|boys|girls: { ym:
//   { amount, pending } } } } — amount net of refunds.
class DuesLedger {
public:
    static nlohmann::json byMonth(int clubId);
};
