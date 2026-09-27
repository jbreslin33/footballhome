#pragma once
#include <string>
#include <unordered_map>
#include <vector>

#include "../third_party/json.hpp"

class Database;

// ────────────────────────────────────────────────────────────────────────────
// PersonFines — read-only roll-up of the fines a person has earned, by
// calendar month, for the #payments cards (migration 460).
//
// Owner 2026-09-27: "we need a fines part to financial. similar to pro
// rate. it should show next to pro rate ... always show last 3 months of
// fines with the individual months each in a box ... i need the individual
// month to know what to add to oct 4 from sept".
//
// Nothing is stored: fh_person_fines() derives every fine from the RSVP
// and attendance rows against the rate in force on the event day
// (fine_policies), so the numbers here move when a mark is corrected.
// One bulk query per screen load, same shape as PersonActivity.
//
// monthsFor() returns, per person who is on a team whose section has a
// fine policy in force (Mens today — parents and the women are not
// fined):
//   { "since": "2026-09-27",            the policy's first day
//     "total": 4.00,                    across the shown months
//     "months": [ { "month": "2026-09", "label": "Sep", "current": true,
//                   "total": 4.00,
//                   "items": [ { "fhEventId", "startAt", "eventKind",
//                                "opponent", "kind", "label", "amount",
//                                "response", "attendance" } ],
//                   "posting": { "month": "2026-10", "label": "Oct",
//                                "firstFriday": "2026-10-02",
//                                "status": posted|drift|not_posted|due|nothing,
//                                "postedAmount", "postedOn" } } ],
//     "dues": { "month": "2026-09", "label": "Sep", "rate": 35,
//               "firstFriday": "2026-09-04",
//               "status": posted|not_posted|due, "postedOn" } }
// A month's fines are posted to LA with the next month's dues on its
// first Friday; posting/dues read the LA charges FH already mirrors
// (person_payments, txn_type Charge) and match them by amount and month
// — the dues charge is the one equal to the rate, the fines charge the
// one equal to the month's total (or dues + fines in one).  Nothing is
// marked by hand.
// The months are the last three calendar months (club time), clipped to
// the policy's first month, oldest first.  People on no such team are
// absent from the map — the card then shows nothing.
// ────────────────────────────────────────────────────────────────────────────
class PersonFines {
public:
    using Map = std::unordered_map<int, nlohmann::json>;   // person_id → fines object

    PersonFines();

    // Ids ≤ 0 are ignored; an empty list is a no-op.
    Map monthsFor(const std::vector<int>& personIds, int monthsBack = 3);

private:
    Database* db_;
};
