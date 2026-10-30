#pragma once
#include "../third_party/json.hpp"

// CashFlow — the #cash-flow page (migration 882): soccer money that came in
// through LeagueApps against the club's invoices going out.
//
// Money in reads person_payments, LeagueApps' own transactions, limited to
// the programs named in la_soccer_programs.  Net is after LeagueApps' fees,
// less refunds.  Money out reads every invoice line by invoice date, drafts
// included.  What lies ahead comes from the two existing sources, so there
// is one projection in the app: PaymentsOverview for dues, Expenses for
// money out.
class CashFlow {
public:
    static nlohmann::json build(int clubId);
};
