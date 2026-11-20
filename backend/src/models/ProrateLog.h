#pragma once
#include <vector>
#include "../third_party/json.hpp"

class Database;

// ProrateLog — 💵 the band's "Prorate" box (mig 1603, owner 2026-11-20
// "todo at top for new players tuition … find new players who we did not
// prorate yet. like they should have more then $1 billed out right?").
//
// Due = a current ACTIVE-variant LA membership whose LA total billed
// (la_amount_owed_cents) is still ≤ $1 — only the card-capture fee — and
// that is not free (NA_FREE), not a club volunteer, and not ✓ Done
// (prorate_dismissals).  Billing them in LA raises the total past $1 and
// the next LA sync takes them off by itself.  The amount is worked out
// in the browser by BillingBadge.projectedProrate — the same math as the
// Tuition page's Prorate cell.
class ProrateLog {
public:
    ProrateLog();
    // [{person_id, first_name, last_name, section, la_user_id,
    //   registered_at (ISO UTC), billed_usd, paid_usd, programs}] newest first.
    nlohmann::json dueList();
    // ✓ Done without billing: prorate_dismissals rows.
    int dismiss(const std::vector<long long>& playerIds, long long byUserId);
private:
    Database* db_;
};
