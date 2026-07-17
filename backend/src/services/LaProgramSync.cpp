#include "LaProgramSync.h"

#include <cctype>
#include <chrono>
#include <cmath>
#include <cstdio>
#include <ctime>
#include <iostream>

#include "../database/Database.h"
#include "../models/PersonLinker.h"
#include "LeagueAppsService.h"

namespace {

// Uppercase ASCII copy used to match LA registrationStatus.
std::string upperAscii(const std::string& s) {
    std::string out;
    out.reserve(s.size());
    for (char c : s) out.push_back(static_cast<char>(std::toupper(static_cast<unsigned char>(c))));
    return out;
}

// LA records use either `userId` (number/string) or, on older feeds,
// `memberId`.  Always normalise to a string so it can key external_person_
// aliases.external_user_id (TEXT).  Returns empty string when neither
// field is present.
std::string extractUserId(const nlohmann::json& rec) {
    auto take = [&](const char* key) -> std::string {
        auto it = rec.find(key);
        if (it == rec.end() || it->is_null()) return {};
        if (it->is_string())               return it->get<std::string>();
        if (it->is_number_integer())       return std::to_string(it->get<long long>());
        if (it->is_number_unsigned())      return std::to_string(it->get<unsigned long long>());
        if (it->is_number_float())         return std::to_string(static_cast<long long>(it->get<double>()));
        return {};
    };
    std::string uid = take("userId");
    if (uid.empty()) uid = take("memberId");
    return uid;
}

// Extract the LA `registrationId` from a registration record as an int64.
// Returns 0 when absent (which recordMembership() treats as "don't know").
long long extractRegistrationId(const nlohmann::json& rec) {
    auto it = rec.find("registrationId");
    if (it == rec.end() || it->is_null()) return 0;
    if (it->is_number_integer())  return it->get<long long>();
    if (it->is_number_unsigned()) return static_cast<long long>(it->get<unsigned long long>());
    if (it->is_number_float())    return static_cast<long long>(it->get<double>());
    if (it->is_string()) {
        try { return std::stoll(it->get<std::string>()); }
        catch (...) { return 0; }
    }
    return 0;
}

// Extract a plausible "registered at" ISO timestamp (UTC) from a raw LA
// registration record.  LA payloads have carried the field under several
// names depending on program vintage / API version; try the common
// suspects in a defined priority order and normalise to ISO.
//
// KEEP IN SYNC with BillingController::extractRegisteredIso — that
// endpoint (POST /api/billing/la-reg-backfill) does the same job for
// pre-existing NULL rows; the two extractors must agree so the manual
// backfill and this primary-path write always resolve to the same
// value.  Returns "" when nothing matches (recordMembership then
// leaves la_registered_at NULL, and projected-prorate silently shows
// $0 as before).
std::string extractRegisteredIso(const nlohmann::json& rec) {
    static const char* kCandidates[] = {
        "registrationDate",
        "registrationCreatedAt",
        "dateRegistered",
        "signupDate",
        "createdOn",
        "dateCreated",
        "created",
        "lastUpdated",
    };

    for (const char* key : kCandidates) {
        auto it = rec.find(key);
        if (it == rec.end() || it->is_null()) continue;

        if (it->is_number()) {
            const double v = it->get<double>();
            if (v < 1'000'000'000'000.0) continue;   // implausibly small for millis
            const long long millis = static_cast<long long>(v);
            const std::time_t secs = static_cast<std::time_t>(millis / 1000);
            struct tm buf;
            gmtime_r(&secs, &buf);
            char out[32];
            std::snprintf(out, sizeof(out),
                          "%04d-%02d-%02dT%02d:%02d:%02dZ",
                          buf.tm_year + 1900, buf.tm_mon + 1, buf.tm_mday,
                          buf.tm_hour, buf.tm_min, buf.tm_sec);
            return out;
        }
        if (it->is_string()) {
            const std::string s = it->get<std::string>();
            if (s.size() < 10) continue;
            return s;   // Postgres TIMESTAMPTZ is forgiving with ISO strings.
        }
    }
    return {};
}

} // namespace

LaProgramSync::Result LaProgramSync::run(int programId) {
    Result out;

    const auto t0 = std::chrono::steady_clock::now();
    auto recs = LeagueAppsService::getInstance().fetchProgramRegistrations(programId);
    const auto tFetch = std::chrono::steady_clock::now();

    PersonLinker linker;

    // Phase A batching (2026-07-17): the per-record payment snapshot
    // UPDATE below used to fire one round-trip per active member (~80
    // for men-pickup) — ~800ms of DB latency for what is arithmetically
    // one statement.  We now accumulate the snapshot tuples in this
    // vector and flush them as a single UPDATE ... FROM (VALUES ...)
    // after the linkLa loop completes.  The row-existence side-effect
    // is preserved because linker.recordMembership() runs synchronously
    // inside the loop and always INSERTs the (person, program) row
    // before its regId appears in pendingSnaps.
    struct PendingSnap {
        long long   regId       = 0;
        long long   ownedCents  = 0;
        long long   paidCents   = 0;
        std::string paymentStatus;
    };
    std::vector<PendingSnap> pendingSnaps;
    pendingSnaps.reserve(recs.size());

    // Phase A batching (2026-07-17): defer PRIMARY person email/phone
    // upserts to a bulk INSERT after the loop.  Parent contact +
    // parent FK linkage stay per-CHILD inside ensureParentLink because
    // they involve resolve-or-create semantics that don't cleanly
    // batch (and youth programs are small, so the overhead is
    // negligible).  For adult programs (men, men-pickup) this
    // collapses ~160 round-trips into 2.
    std::vector<std::pair<int, std::string>> pendingEmails;   // (personId, email)
    std::vector<std::pair<int, std::string>> pendingPhones;   // (personId, phone)
    pendingEmails.reserve(recs.size());
    pendingPhones.reserve(recs.size());

    // Mirror the primary-contact field extraction inside
    // PersonLinker::linkLa exactly, so batch semantics == inline semantics.
    auto extractEmailPhone = [](const nlohmann::json& rec,
                                std::string& emailOut,
                                std::string& phoneOut) {
        emailOut.clear();
        phoneOut.clear();
        auto sfield = [&](const char* k) -> std::string {
            auto it = rec.find(k);
            if (it == rec.end() || !it->is_string()) return {};
            return it->get<std::string>();
        };
        emailOut = sfield("email");
        phoneOut = sfield("phoneNumber");
        if (phoneOut.empty()) phoneOut = sfield("phone");
    };

    for (auto& rec : recs) {
        std::string statusRaw;
        if (auto it = rec.find("registrationStatus"); it != rec.end() && it->is_string()) {
            statusRaw = it->get<std::string>();
        }
        const std::string status = upperAscii(statusRaw);

        const std::string uid = extractUserId(rec);
        if (uid.empty()) {
            out.recs.push_back(std::move(rec));
            continue;
        }

        out.statusByUser[uid] = status;

        // Capture LA's authoritative per-registration payment state so
        // the payments screen can reconcile against it on every load.
        const long long regId = extractRegistrationId(rec);
        if (regId > 0) {
            auto readNum = [&](const char* key) -> double {
                auto it = rec.find(key);
                if (it == rec.end() || it->is_null()) return 0.0;
                if (it->is_number()) return it->get<double>();
                if (it->is_string()) {
                    try { return std::stod(it->get<std::string>()); }
                    catch (...) { return 0.0; }
                }
                return 0.0;
            };
            LaPayment lp;
            lp.amountPaid  = readNum("amountPaid");
            lp.totalDue    = readNum("totalAmountDue");
            lp.outstanding = readNum("outstandingBalance");
            if (auto it = rec.find("paymentStatus"); it != rec.end() && it->is_string()) {
                lp.paymentStatus = upperAscii(it->get<std::string>());
            }
            out.paymentByRegistration[regId] = lp;
        }

        // Membership gate (user directive 2026-07-12): a person is a
        // member of this LA program ONLY if their registrationStatus is
        // one of the three statuses the LA console displays by default —
        //   SPOT_RESERVED, SPOT_PENDING, WAITING_LIST.
        // Every other status (DROPPED, CANCELED, DECLINED, REFUNDED, …)
        // is treated as "not currently a member of this program".  The
        // person is still linked via linkLa (so their alias/contact info
        // stays fresh), but no membership row is opened, and the
        // end-of-loop closeStaleMemberships sweep will END any pre-existing
        // open row for this program.  This replaces the earlier "presence
        // == member" heuristic which caused dropped-out folks to keep
        // showing up under the Members board (see 2026-07-03 comment
        // below — superseded).
        const bool isMember =
               status == "SPOT_RESERVED"
            || status == "SPOT_PENDING"
            || status == "WAITING_LIST";

        if (isMember) {
            out.activeUserIds.insert(uid);
        }

        // Link EVERY reg (member or not) so aliases + contact info stay
        // current for people who later re-join.  Only WRITE the
        // membership row when isMember == true.
        try {
            auto r = linker.linkLa(rec, /*dryRun=*/false, /*deferPrimaryContact=*/true);
            if (!r.skipReason.empty()) {
                std::cerr << "[la-sync program=" << programId
                          << "] linkLa skipped userId=" << uid
                          << ": " << r.skipReason << std::endl;
            } else if (r.personId > 0) {
                // Phase A batching (2026-07-17): queue primary
                // person's email + phone regardless of isMember.
                // linkLa historically upserted contacts for every
                // reg (member or not) so downstream lead-matching
                // + churn analytics can find them; we preserve that.
                std::string email;
                std::string phone;
                extractEmailPhone(rec, email, phone);
                if (!email.empty()) pendingEmails.emplace_back(r.personId, std::move(email));
                if (!phone.empty()) pendingPhones.emplace_back(r.personId, std::move(phone));
            }
            if (r.personId > 0 && isMember) {
                // Pull LA's authoritative registration timestamp so
                // recordMembership can populate person_la_memberships
                // .la_registered_at on INSERT (and backfill if NULL on
                // update).  Without this, mid-cycle signups land with a
                // NULL reg-date and billing-badge.projectedProrate
                // returns $0 (tooltip: "no LA registration date on
                // record") until an operator manually hits
                // /api/billing/la-reg-backfill.  See PersonLinker.h
                // recordMembership doc + billing-badge.js.
                const std::string regIso = extractRegisteredIso(rec);
                linker.recordMembership(r.personId, programId, regId, regIso);

                // Snapshot LA-authoritative billing state onto the
                // membership row (migration 117) — payments card reads
                // these directly rather than re-fetching LA per render.
                //
                // Also SEED `next_due_at` on rows that don't have one
                // yet: 1st Friday of the month AFTER their la_registered_at.
                // Operator overrides (`next_due_source='operator_override'`)
                // and payment-advance moves are never touched here — the
                // CASE clauses in the bulk UPDATE below only rewrite
                // when the value is NULL.
                //
                // Deferred to a single bulk UPDATE after the loop —
                // see Phase A batching comment above.  recordMembership
                // ran a moment ago so the row is guaranteed to exist
                // (or to have failed loudly, in which case the snapshot
                // is skipped anyway because we're inside its else-branch).
                if (regId > 0) {
                    const LaPayment& lpSnap = out.paymentByRegistration[regId];
                    PendingSnap snap;
                    snap.regId         = regId;
                    snap.ownedCents    = static_cast<long long>(std::llround(lpSnap.totalDue   * 100.0));
                    snap.paidCents     = static_cast<long long>(std::llround(lpSnap.amountPaid * 100.0));
                    snap.paymentStatus = lpSnap.paymentStatus;
                    pendingSnaps.push_back(std::move(snap));
                }
            }
        } catch (const std::exception& e) {
            std::cerr << "[la-sync program=" << programId
                      << "] linkLa failed userId=" << uid
                      << ": " << e.what() << std::endl;
        }

        out.recs.push_back(std::move(rec));
    }

    // Phase A batching flush (2026-07-17): all pending payment /
    // next-due-seed snapshots are pushed in ONE UPDATE ... FROM (VALUES
    // (...), (...), ...).  For an ~80-record men-pickup sync this
    // collapses ~80 round-trips (~800 ms of DB latency) into one.
    // Semantics are byte-identical to the original per-record UPDATE:
    // CASE clauses reference plm.* so operator overrides and
    // payment-advance moves are still never touched, and the
    // (la_registration_id, ended_at IS NULL) predicate matches the
    // same single row per snapshot.
    if (!pendingSnaps.empty()) {
        try {
            auto* db = Database::getInstance();
            std::vector<std::string> params;
            params.reserve(pendingSnaps.size() * 4);
            std::ostringstream valuesSql;
            for (std::size_t i = 0; i < pendingSnaps.size(); ++i) {
                const auto& s = pendingSnaps[i];
                if (i) valuesSql << ",";
                const std::size_t base = i * 4;
                valuesSql << "($" << (base + 1) << "::bigint,"
                             "$"  << (base + 2) << "::int,"
                             "$"  << (base + 3) << "::int,"
                             "$"  << (base + 4) << "::text)";
                params.push_back(std::to_string(s.regId));
                params.push_back(std::to_string(s.ownedCents));
                params.push_back(std::to_string(s.paidCents));
                params.push_back(s.paymentStatus);
            }
            const std::string sql =
                "UPDATE person_la_memberships plm "
                "   SET la_amount_owed_cents = v.owed_cents,"
                "       la_amount_paid_cents = v.paid_cents,"
                "       la_payment_status    = NULLIF(v.pay_status, ''),"
                "       la_snapshot_at       = now(),"
                "       next_due_at = CASE"
                "         WHEN plm.next_due_at      IS NOT NULL THEN plm.next_due_at"
                "         WHEN plm.la_registered_at IS NULL     THEN NULL"
                "         ELSE (first_friday_of_month("
                "                 plm.la_registered_at + interval '1 month'"
                "               ))::timestamptz"
                "       END,"
                "       next_due_source = CASE"
                "         WHEN plm.next_due_source  IS NOT NULL THEN plm.next_due_source"
                "         WHEN plm.la_registered_at IS NULL     THEN NULL"
                "         ELSE 'la_seed'"
                "       END,"
                "       next_due_updated_at = CASE"
                "         WHEN plm.next_due_at      IS NOT NULL THEN plm.next_due_updated_at"
                "         WHEN plm.la_registered_at IS NULL     THEN plm.next_due_updated_at"
                "         ELSE now()"
                "       END "
                "  FROM (VALUES " + valuesSql.str() + ") AS v(reg_id, owed_cents, paid_cents, pay_status) "
                " WHERE plm.la_registration_id = v.reg_id "
                "   AND plm.ended_at IS NULL";
            db->query(sql, params);
        } catch (const std::exception& e) {
            std::cerr << "[la-sync program=" << programId
                      << "] bulk snapshot/seed failed for "
                      << pendingSnaps.size() << " row(s): "
                      << e.what() << std::endl;
        }
    }

    // Phase A batching flush — primary contacts.  Each of these is one
    // multi-VALUES INSERT ... ON CONFLICT DO NOTHING, collapsing what
    // was up to ~160 round-trips for a men-pickup sync into 2.  The
    // ON CONFLICT targets the GLOBAL unique constraints on email /
    // phone_number so we never steal a contact from another person
    // (matching the historical inline behaviour of upsertContact).
    //
    // NOTE: we deliberately do NOT dedupe (personId, email) pairs
    // client-side — Postgres handles that via ON CONFLICT and the
    // duplicate rows are trivially cheap in the same round-trip.
    auto bulkInsertContacts = [&](const char* table,
                                  const char* col,
                                  const std::vector<std::pair<int, std::string>>& tuples) {
        if (tuples.empty()) return;
        try {
            auto* db = Database::getInstance();
            std::vector<std::string> params;
            params.reserve(tuples.size() * 2);
            std::ostringstream valuesSql;
            for (std::size_t i = 0; i < tuples.size(); ++i) {
                const auto& t = tuples[i];
                if (t.first <= 0 || t.second.empty()) continue;
                if (!params.empty()) valuesSql << ",";
                const std::size_t base = params.size();
                valuesSql << "($" << (base + 1) << "::int,"
                             "$"  << (base + 2) << ")";
                params.push_back(std::to_string(t.first));
                // Trim ASCII whitespace to match upsertContact's cleanEmail/cleanPhone.
                std::string val = t.second;
                std::size_t a = 0, b = val.size();
                while (a < b && std::isspace(static_cast<unsigned char>(val[a])))   ++a;
                while (b > a && std::isspace(static_cast<unsigned char>(val[b - 1]))) --b;
                params.push_back(val.substr(a, b - a));
            }
            if (params.empty()) return;
            const std::string sql = std::string(
                "INSERT INTO ") + table + " (person_id, " + col + ") "
                "VALUES " + valuesSql.str() + " "
                "ON CONFLICT (" + col + ") DO NOTHING";
            db->query(sql, params);
        } catch (const std::exception& e) {
            std::cerr << "[la-sync program=" << programId
                      << "] bulk " << table << " upsert failed for "
                      << tuples.size() << " row(s): "
                      << e.what() << std::endl;
        }
    };
    bulkInsertContacts("person_emails", "email",        pendingEmails);
    bulkInsertContacts("person_phones", "phone_number", pendingPhones);

    // End-of-sync sweep: close any OPEN membership rows for this program
    // whose person is no longer in the "still a member" set.  This is
    // what makes the sync AUTHORITATIVE — the DB after sync reflects
    // exactly the LA console for this program at this moment.
    linker.closeStaleMemberships(static_cast<long long>(programId), out.activeUserIds);

    const auto tDone = std::chrono::steady_clock::now();
    const auto fetchMs = std::chrono::duration_cast<std::chrono::milliseconds>(tFetch - t0).count();
    const auto dbMs    = std::chrono::duration_cast<std::chrono::milliseconds>(tDone  - tFetch).count();
    const auto totalMs = std::chrono::duration_cast<std::chrono::milliseconds>(tDone  - t0).count();
    std::cerr << "[la-sync program=" << programId
              << "] recs=" << out.recs.size()
              << " active=" << out.activeUserIds.size()
              << " fetch=" << fetchMs << "ms"
              << " db=" << dbMs << "ms"
              << " total=" << totalMs << "ms"
              << std::endl;

    return out;
}
