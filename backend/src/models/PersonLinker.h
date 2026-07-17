#pragma once
#include <string>
#include <set>
#include "../third_party/json.hpp"

class Database;

// ────────────────────────────────────────────────────────────────────────────
// PersonLinker — find-or-create the `persons` row for an upstream record.
//
// LA path (linkLa):
//   1. Existing alias for (provider='leagueapps', external_user_id) → fast hit
//   2. Existing persons row for (LOWER(first_name), LOWER(last_name))
//      with DOB tie-break (skip with `dob-mismatch` reason if persons.dob and
//      LA dob both present and differ)
//   3. Otherwise INSERT a new persons row
//   4. UPSERT the LA alias so step 1 hits next time
//
// Skips (Result.skipReason populated) are non-fatal — the caller logs and
// keeps going.  This mirrors meta-leads-webhook person-data.js exactly.
// ────────────────────────────────────────────────────────────────────────────
class PersonLinker {
public:
    struct Result {
        int  personId       = 0;      // 0 if not linked (skip)
        bool created        = false;  // a new persons row was inserted
        bool aliasCreated   = false;
        // Set instead of `created`/`aliasCreated` when `dryRun = true`.
        // Mirrors Node's personLinker.linkLa(rec, {dryRun:true}) result.
        bool wouldCreatePerson = false;
        bool wouldCreateAlias  = false;
        std::string skipReason;       // e.g. "missing-la-userId", "dob-mismatch (...)"
        int  conflictPersonId = 0;    // only set for dob-mismatch
    };

    PersonLinker();

    // Find-or-create persons + alias from a LeagueApps registration record.
    // Always returns; never throws on schema-conformant input.
    // `dryRun` mirrors Node's option: probe what would happen (set the
    // `wouldCreate*` flags) without writing.
    //
    // `deferPrimaryContact` (Phase A batching, 2026-07-17): when true,
    // the primary person's email/phone are NOT upserted inline; the
    // caller is expected to collect (personId, email, phone) tuples
    // for every record and flush them in one bulk INSERT after the
    // loop.  `ensureParentLink` still runs (parent contact + parent
    // FK linkage are per-CHILD and only present on youth programs,
    // which are small).  Adult program syncs (men, men-pickup) see
    // the full ~1.6s win from batching primary contacts.
    Result linkLa(const nlohmann::json& rec,
                  bool dryRun = false,
                  bool deferPrimaryContact = false);

    // Mark `personId` as a current member of LA sub-program `programId`.
    // Idempotent: if the person already has an open row for this program,
    // the row's `la_registration_id` is backfilled if currently NULL but no
    // other writes occur.  If they have an open row for a DIFFERENT program,
    // that row is closed (ended_at = now()) and a new open row inserted —
    // this is how "active → paused" (or vice-versa) transitions are
    // captured with a preserved audit trail.  Callers must have already
    // resolved `personId` via linkLa (or otherwise) and the referenced
    // `programId` must exist in `leagueapps_programs.program_id`.
    //
    // `registrationId` is the LA registration id for this (person, program)
    // pair — the same id that appears on transactions.  It is the correct
    // join key from `person_payments` back to a member for youth (whose
    // payer/`la_user_id` is the parent, not the child).  Pass 0 to skip.
    //
    // `registeredAtIso` is the LA-authoritative moment the person
    // registered for this program (extracted from LA fields like
    // registrationDate / dateRegistered / signupDate — see
    // LaProgramSync::extractRegisteredIso).  Populated on INSERT and
    // back-filled on the update-existing branch when the column is
    // still NULL.  Never overwrites an existing non-NULL value (the
    // BillingController manual backfill has the same rule).  Pass ""
    // when unknown.  The projected-prorate math (billing-badge.js)
    // silently returns $0 without it, so populating this from the
    // primary sync path is what makes mid-cycle signups auto-prorate
    // without an operator hitting /api/billing/la-reg-backfill.
    // Best-effort: logs + swallows on DB errors (does not throw).
    void recordMembership(int personId,
                          long long programId,
                          long long registrationId = 0,
                          const std::string& registeredAtIso = std::string());

    // End-of-sync sweep: for LA sub-program `programId`, close (set
    // ended_at = now()) every OPEN person_la_memberships row whose person
    // is NOT represented in `activeLaUserIds` (the set of LA userIds that
    // LaProgramSync just accepted as "still a member" for this program —
    // i.e. registrationStatus in {SPOT_RESERVED, SPOT_PENDING, WAITING_LIST}).
    // Callers MUST pass the CANONICAL LA userId set — persons whose
    // external_person_aliases row maps to an id in this set are kept open,
    // everyone else for this program is closed.  Best-effort: logs +
    // swallows on DB errors.  User directive 2026-07-12: membership
    // MUST come from LA every time — no more "sync only opens" behavior.
    void closeStaleMemberships(long long programId,
                               const std::set<std::string>& activeLaUserIds);

    // Upsert `email` and/or `phone` onto `personId`.  No-op for empty strings.
    //
    // Exposed public (Phase A batching, 2026-07-17) so LaProgramSync
    // can call it as a fallback when the bulk INSERT path can't be
    // used (e.g. a single re-run after a partial failure).  Also used
    // by the internal fast-path in linkLa when `deferPrimaryContact`
    // is false (the historical inline behaviour).
    void upsertContact(int personId, const std::string& email, const std::string& phone);

private:
    Database* db_;

    // Lowercase + trim + collapse whitespace runs to a single space.
    static std::string normalizeName(const std::string&);

    // Pull "YYYY-MM-DD" out of `rec.birthDate` (LA returns either ISO string
    // or epoch millis).  Returns empty when no birthDate is present.
    static std::string birthDateIso(const nlohmann::json&);

    // Trim leading/trailing whitespace.
    static std::string trim(const std::string&);

    // Contact backfill (2026-07-01): every LA reg carries email/phone for
    // the person we just linked.  Youth regs (userType='CHILD') carry the
    // parent's contact under parent* keys — we upsert a separate parent
    // person row (linked via persons.parent_person_id) so the parent's
    // email/phone lands in person_emails/person_phones for lead-suppression.
    //
    // These are best-effort: on any DB error we log and swallow (never
    // fail the caller — the alias linkage is what matters most).

    // For CHILD records, resolve-or-create the parent person from
    // parentUserId + parentFirstName/parentLastName, upsert parentEmail/
    // parentPhone on the parent, and set persons.parent_person_id on the
    // child.  For non-CHILD records this is a no-op.
    void ensureParentLink(int childPersonId, const nlohmann::json& rec);
};
