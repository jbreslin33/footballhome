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

    // ── Documents (mig 1538) ────────────────────────────────────────────
    // Store an upload (base64 of a PDF / JPEG / PNG / HEIC / WebP, sniffed
    // by magic bytes) on a step; marks the step sent.  out id > 0 = ok, else
    // *error says why.
    static long long addFile(long long personId, const std::string& code, const std::string& filename,
                             const std::string& base64, long long userId, std::string* error);
    // Remove an upload.  ownerPersonId > 0 = the person themselves (only
    // their own, only before it went to compliance); 0 = a club admin.
    static std::string removeFile(long long fileId, long long ownerPersonId);
    // A file for a club admin: false when gone (purged / deleted).
    static bool fileBytes(long long fileId, std::string* filename, std::string* mime, std::string* bytes);
    // ✉️ Email one stage's files (volunteer = clearances → compliance,
    // paid = finance → HR; onboarding_stages, mig 1545), cc the person and
    // the admin, Reply-To the admin; split into parts under the relay's size
    // cap.  "" = sent; else the error.  *sentFiles = how many.
    static std::string sendStage(long long personId, const std::string& stage, long long adminUserId, int* sentFiles);
    // ✍️ NSOR filled in on FootballHome (mig 1558): store the filled PDF on
    // the step and email it to the state (message_templates nsor_to /
    // nsor_email), cc the person, Reply-To the email on the form.  Once a
    // day at most.  "" = sent; else the error.
    static std::string sendNsor(long long personId, const std::string& fileDataUrl, const std::string& lastName,
                                const std::string& fullName, const std::string& email);
    // Deletes file bytes purge_days after they went to compliance.
    static void purge();
};
