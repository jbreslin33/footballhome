#pragma once
#include <vector>
#include "../third_party/json.hpp"

class Database;

// NewMemberOnboarding — 🆕 the band's onboarding report + the 🆕 New members
// pill on #onboarding (mig 1896, owner 2026-11-25 "they are not onboarded
// fully until they rsvp" + "and get charged pro rate" + "i should get an
// onbording status report in the todo at top on every load").
//
// Who: a current PLAYING LA membership (variant 'active'; pickup never
// counts) registered on/after new_member_onboard_policy.counts_from, not
// ✓ Done (new_member_onboard_dismissals).
// Onboarded = answered ≥ 1 RSVP (fh_event_rsvps for them) AND charged the
// prorate (billed past the $1 card fee, NA_FREE, a club volunteer, or ✓ Done
// on the 💵 Prorate box — ProrateLog's rule, mig 1603).
// Tone by hours since registering: green < green_hours ≤ yellow < red_hours ≤ red.
class NewMemberOnboarding {
public:
    NewMemberOnboarding();
    // {policy:{counts_from, green_hours, red_hours},
    //  members:[{person_id, first_name, last_name, section, registered_at (ISO UTC),
    //            age_hours, tone, rsvp_at (ISO|null), rsvp_ok, billed_usd, prorate_ok,
    //            onboarded, teams:[name]}]}  — not-onboarded first, oldest first.
    nlohmann::json report();
    int dismiss(const std::vector<long long>& personIds, long long byUserId);
private:
    Database* db_;
};
