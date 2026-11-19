#pragma once
#include <string>

#include "../third_party/json.hpp"

// ────────────────────────────────────────────────────────────────────────────
// Onboarding — 🎓 the volunteer → paid path (mig 1526).
//
// Owner 2026-11-19: the club's new-coach email (PA criminal history, child
// abuse, FBI fingerprints, NSOR, photo ID, W-9, direct deposit) as a
// checklist "on their calendar as outstanding items like missing rsvps …
// but has actionable links", a staff page with volunteers and paid, "this way
// they feel like they have path to get paid and thus are motivated to
// volunteer".
//
//   onboarding_steps         the checklist (stage volunteer = step 1,
//                            paid = step 2 — shown to a volunteer as next)
//   person_onboarding        who is on the path, track volunteer | paid
//   person_onboarding_steps  sent_at (the person) / verified_at (the club)
//
// A step's state: todo · sent (club checking) · done (verified, not expired)
// · renew (verified, inside 60 days of verified_at + renew_months).
// required = stage volunteer, or the person is on the paid track.
// left = required steps in todo / renew — the 🚦 band's count.
// ────────────────────────────────────────────────────────────────────────────
class Onboarding {
public:
    // The person's own path: {track, steps:[…], left, total}; null when the
    // person is not on it.
    static nlohmann::json mine(long long personId);

    // Club admins: {steps:[defs], people:[{person_id, name, track, note,
    // steps:[…], left, done, total}], candidates:[{person_id, name, why}]}.
    static nlohmann::json board();

    // The person: "I sent it" (sent=true) or undo.  Never on a verified step.
    // "" = ok, else the error.
    static std::string markSent(long long personId, const std::string& code, bool sent);

    // A club admin on a step: verified · redo (sent cleared, note kept) ·
    // sent · clear.  "" = ok, else the error.
    static std::string review(long long personId, const std::string& code, const std::string& action,
                              const std::string& note, long long userId);

    // A club admin: start / move a person (track volunteer | paid), or take
    // them off the path (track "").  "" = ok, else the error.
    static std::string setTrack(long long personId, const std::string& track, long long userId);
};
