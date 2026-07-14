#include "PaymentsController.h"

#include <cmath>
#include <cstdlib>
#include <iostream>
#include <sstream>
#include <unordered_map>
#include <utility>
#include <vector>

#include "../models/PersonPayments.h"
#include "../services/LaProgramSync.h"
#include "../third_party/json.hpp"

using nlohmann::json;

namespace {

// Env-int reader used to keep programme IDs overridable at deploy time
// without recompiling (mirrors YouthRoster / LaPool convention).
int envIntOr(const char* name, int fallback) {
    const char* v = std::getenv(name);
    if (!v || !*v) return fallback;
    try { return std::stoi(v); }
    catch (const std::exception&) { return fallback; }
}

std::string jsonEscape(const std::string& s) {
    return json(s).dump();
}

Response badRequest(const std::string& msg) {
    std::ostringstream body;
    body << "{\"error\":" << jsonEscape(msg) << "}";
    return Response(HttpStatus::BAD_REQUEST, body.str());
}

Response internalErr(const std::string& msg) {
    std::ostringstream body;
    body << "{\"error\":" << jsonEscape(msg) << "}";
    return Response(HttpStatus::INTERNAL_SERVER_ERROR, body.str());
}

} // namespace

PaymentsController::PaymentsController()
    : payments_        (std::make_unique<PersonPayments>()),
      mensProgramId_   (envIntOr("LEAGUEAPPS_MENS_PROGRAM_ID",         5039300)),
      womensProgramId_ (envIntOr("LEAGUEAPPS_WOMENS_PROGRAM_ID",       5039340)),
      boysProgramId_   (envIntOr("LEAGUEAPPS_BOYS_CLUB_PROGRAM_ID",    5039252)),
      girlsProgramId_  (envIntOr("LEAGUEAPPS_GIRLS_CLUB_PROGRAM_ID",   5039357)) {}

PaymentsController::~PaymentsController() = default;

void PaymentsController::registerRoutes(Router& router, const std::string& prefix) {
    router.get(prefix + "/mens", [this](const Request& req) {
        if (!requireBearer(req)) return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
        return this->handleGetForProgram("mens", mensProgramId_);
    });
    router.get(prefix + "/womens", [this](const Request& req) {
        if (!requireBearer(req)) return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
        return this->handleGetForProgram("womens", womensProgramId_);
    });
    router.get(prefix + "/boys", [this](const Request& req) {
        if (!requireBearer(req)) return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
        return this->handleGetForProgram("boys", boysProgramId_);
    });
    router.get(prefix + "/girls", [this](const Request& req) {
        if (!requireBearer(req)) return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
        return this->handleGetForProgram("girls", girlsProgramId_);
    });

    // Members view — one row per person on the program, joined with the
    // last-2-calendar-months window of transactions + lifetime aggregates
    // + computed status ("what have you done for me lately").
    router.get(prefix + "/mens/members", [this](const Request& req) {
        if (!requireBearer(req)) return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
        return this->handleGetMembersForProgram("mens", mensProgramId_);
    });
    router.get(prefix + "/womens/members", [this](const Request& req) {
        if (!requireBearer(req)) return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
        return this->handleGetMembersForProgram("womens", womensProgramId_);
    });
    router.get(prefix + "/boys/members", [this](const Request& req) {
        if (!requireBearer(req)) return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
        return this->handleGetMembersForProgram("boys", boysProgramId_);
    });
    router.get(prefix + "/girls/members", [this](const Request& req) {
        if (!requireBearer(req)) return errorResponse(HttpStatus::UNAUTHORIZED, "Unauthorized");
        return this->handleGetMembersForProgram("girls", girlsProgramId_);
    });
}

Response PaymentsController::handleGetForProgram(const std::string& programKey,
                                                 long long programId) {
    // Sync new LA transactions first so the payments table reflects
    // reality on every page hit.  Non-fatal — we still return whatever
    // we have persisted if the sync fails.
    try {
        payments_->syncFromLa();
    } catch (const std::exception& e) {
        std::cerr << "[PaymentsController] sync failed: " << e.what() << std::endl;
    }

    std::vector<PersonPayments::PaymentRow> rows;
    try {
        rows = payments_->loadAllByProgram(programId);
    } catch (const std::exception& e) {
        return internalErr(std::string("Failed to load payments: ") + e.what());
    }

    json payments = json::array();
    double totalPositive = 0.0;
    double totalRefunds  = 0.0;
    std::string programName;
    for (const auto& r : rows) {
        if (programName.empty() && !r.programName.empty()) programName = r.programName;
        // Split totals so the UI can show gross + refund at a glance.
        if (r.txnType == "Refund" || r.txnType == "Partial Refund") totalRefunds  += r.amount;
        else                                                        totalPositive += r.amount;

        json j = json::object();
        j["transactionId"]  = r.transactionId;
        j["userId"]         = r.userId;
        j["registrationId"] = r.registrationId ? json(r.registrationId) : json(nullptr);
        j["invoiceId"]      = r.invoiceId      ? json(r.invoiceId)      : json(nullptr);
        j["firstName"]      = r.firstName;
        j["lastName"]       = r.lastName;
        j["programName"]    = r.programName;
        j["amount"]         = r.amount;
        j["netAmount"]      = r.hasNetAmount ? json(r.netAmount) : json(nullptr);
        j["gateway"]        = r.gateway;
        j["txnType"]        = r.txnType;
        j["paidAt"]         = r.paidAt.empty() ? json(nullptr) : json(r.paidAt);
        payments.push_back(std::move(j));
    }

    json out = json::object();
    out["program"]       = programKey;
    out["programId"]     = programId;
    out["programName"]   = programName;
    out["total"]         = payments.size();
    out["totalPositive"] = totalPositive;
    out["totalRefunds"]  = totalRefunds;
    out["payments"]      = std::move(payments);
    return Response(HttpStatus::OK, out.dump());
}

Response PaymentsController::handleGetMembersForProgram(const std::string& programKey,
                                                        long long programId) {
    // 1. Refresh membership state — pulls the latest LA registrations for
    //    this program and upserts person_la_memberships (ended_at gets set
    //    for anyone LA has dropped, new rows inserted for fresh regs).
    //    Non-fatal: fall through if LA is unreachable and use whatever we
    //    have in the DB.
    //
    //    We ALSO capture LA's authoritative per-registration `amountPaid`
    //    + `paymentStatus` from the same fetch so step 5 can reconcile
    //    our locally computed status against LA on every load.  If LA is
    //    unreachable, `laPayments` stays empty and step 5 no-ops (leaves
    //    every member with `discrepancy=null`) — we still serve stale
    //    state rather than 5xx-ing, but we never *silently* misclassify.
    std::unordered_map<long long, LaProgramSync::LaPayment> laPayments;
    bool laReachable = false;
    try {
        LaProgramSync sync;
        auto syncResult = sync.run(static_cast<int>(programId));
        laPayments = std::move(syncResult.paymentByRegistration);
        laReachable = true;
    } catch (const std::exception& e) {
        std::cerr << "[PaymentsController::members] LaProgramSync failed for program "
                  << programId << ": " << e.what() << std::endl;
    }

    // 2. Refresh payment cursor — cheap after the first pass on this
    //    process (0 rows once caught up).
    try {
        payments_->syncFromLa();
    } catch (const std::exception& e) {
        std::cerr << "[PaymentsController::members] payments sync failed: " << e.what() << std::endl;
    }

    // 3. Load the joined + windowed report.
    std::vector<PersonPayments::MemberRow> rows;
    try {
        rows = payments_->loadMembersForProgram(programId);
    } catch (const std::exception& e) {
        return internalErr(std::string("Failed to load members: ") + e.what());
    }

    // 4. Serialise.  Counts per status let the tile badge / summary strip
    //    render "N need attention" without a second query.
    //
    // 5. Reconcile against LA (inline with serialisation).  For every
    //    member we compare:
    //      • net local paid  = totalPaid − totalRefunded
    //      • LA authoritative amountPaid
    //      • our derived status vs LA `paymentStatus` (PAID/PARTIAL/UNPAID)
    //    Rules:
    //      • net local paid differs from LA by > $0.01           → mismatch
    //      • LA says PAID/PARTIAL and our status = 'never'       → mismatch
    //      • LA says UNPAID and our status = 'current'/'behind'  → mismatch
    //    Each mismatch is:
    //      • logged to stderr (so ops sees drift without polling the API)
    //      • attached to the member row under `discrepancy`
    //      • counted into a top-level `reconciliation` block with a
    //        compact `mismatches` list the frontend can render as a
    //        red-badge warning strip.
    json members = json::array();
    json mismatches = json::array();
    int cCurrent = 0, cBehind = 0, cOverdue = 0, cNever = 0;
    for (const auto& m : rows) {
        if      (m.status == "current") ++cCurrent;
        else if (m.status == "behind")  ++cBehind;
        else if (m.status == "overdue") ++cOverdue;
        else if (m.status == "never")   ++cNever;

        json row = json::object();
        row["personId"]         = m.personId;
        row["laUserId"]         = m.laUserId;
        row["laRegistrationId"] = m.laRegistrationId ? json(m.laRegistrationId) : json(nullptr);
        row["firstName"]     = m.firstName;
        row["lastName"]      = m.lastName;
        row["dob"]           = m.dob.empty()   ? json(nullptr) : json(m.dob);
        row["email"]         = m.email.empty() ? json(nullptr) : json(m.email);
        row["phone"]         = m.phone.empty() ? json(nullptr) : json(m.phone);
        row["phoneSms"]      = m.phoneSms;
        row["phoneCall"]     = m.phoneCall;
        row["laRegisteredAt"] = m.laRegisteredAt.empty() ? json(nullptr) : json(m.laRegisteredAt);
        row["status"]        = m.status;
        row["totalPaid"]     = m.totalPaid;
        row["totalRefunded"] = m.totalRefunded;
        row["txnCount"]      = m.txnCount;
        row["firstPaidAt"]   = m.firstPaidAt.empty() ? json(nullptr) : json(m.firstPaidAt);
        row["lastPaidAt"]    = m.lastPaidAt.empty()  ? json(nullptr) : json(m.lastPaidAt);
        row["lastAmount"]    = m.lastAmount;

        // Reconciliation.  Skip entirely if LA was unreachable OR if we
        // never resolved a registrationId for this membership row (e.g.
        // an ancient row from before migration 081 that hasn't been
        // touched by a re-sync yet).
        json discrepancy = json(nullptr);
        if (laReachable && m.laRegistrationId != 0) {
            auto it = laPayments.find(m.laRegistrationId);
            if (it != laPayments.end()) {
                const auto& la = it->second;
                row["laAmountPaid"]         = la.amountPaid;
                row["laOutstandingBalance"] = la.outstanding;
                row["laPaymentStatus"]      = la.paymentStatus.empty()
                                              ? json(nullptr)
                                              : json(la.paymentStatus);

                const double netLocal = m.totalPaid - m.totalRefunded;
                const double delta    = netLocal - la.amountPaid;
                std::vector<std::string> reasons;
                if (std::fabs(delta) > 0.01) {
                    reasons.push_back("amount_mismatch");
                }
                if ((la.paymentStatus == "PAID" || la.paymentStatus == "PARTIAL")
                     && la.amountPaid >= 1.0
                     && m.status == "never") {
                    reasons.push_back("la_paid_ours_never");
                }
                if (la.paymentStatus == "UNPAID" && la.amountPaid < 0.01
                    && (m.status == "current" || m.status == "behind")) {
                    reasons.push_back("la_unpaid_ours_current");
                }
                if (!reasons.empty()) {
                    json d = json::object();
                    d["reasons"]         = reasons;
                    d["laAmountPaid"]    = la.amountPaid;
                    d["localNetPaid"]    = netLocal;
                    d["delta"]           = delta;
                    d["laPaymentStatus"] = la.paymentStatus.empty()
                                           ? json(nullptr) : json(la.paymentStatus);
                    d["ourStatus"]       = m.status;
                    discrepancy = d;

                    // Compact summary for the top-level `reconciliation`.
                    json mm = json::object();
                    mm["personId"]         = m.personId;
                    mm["laRegistrationId"] = m.laRegistrationId;
                    mm["firstName"]        = m.firstName;
                    mm["lastName"]         = m.lastName;
                    mm["reasons"]          = reasons;
                    mm["laAmountPaid"]     = la.amountPaid;
                    mm["localNetPaid"]     = netLocal;
                    mm["laPaymentStatus"]  = la.paymentStatus.empty()
                                             ? json(nullptr) : json(la.paymentStatus);
                    mm["ourStatus"]        = m.status;
                    mismatches.push_back(std::move(mm));

                    std::cerr << "[reconcile] program=" << programKey
                              << " reg=" << m.laRegistrationId
                              << " person=" << m.personId
                              << " (" << m.firstName << " " << m.lastName << ")"
                              << " laPaid=" << la.amountPaid
                              << " ourPaid=" << netLocal
                              << " laStatus=" << (la.paymentStatus.empty()
                                                  ? std::string("null")
                                                  : la.paymentStatus)
                              << " ourStatus=" << m.status
                              << " reasons=";
                    for (size_t i = 0; i < reasons.size(); ++i) {
                        std::cerr << (i ? "," : "") << reasons[i];
                    }
                    std::cerr << std::endl;
                }
            } else {
                // Our membership row references a registrationId LA no
                // longer returns for this program (deleted / superseded
                // registration).  Not a payment discrepancy per se, but
                // worth flagging so the operator knows the local row
                // needs pruning.
                json d = json::object();
                d["reasons"] = json::array({ "la_registration_missing" });
                d["ourStatus"] = m.status;
                discrepancy = d;

                json mm = json::object();
                mm["personId"]         = m.personId;
                mm["laRegistrationId"] = m.laRegistrationId;
                mm["firstName"]        = m.firstName;
                mm["lastName"]         = m.lastName;
                mm["reasons"]          = json::array({ "la_registration_missing" });
                mm["ourStatus"]        = m.status;
                mismatches.push_back(std::move(mm));
            }
        }
        row["discrepancy"] = discrepancy;

        json txns = json::array();
        for (const auto& t : m.recentTxns) {
            json j = json::object();
            j["transactionId"] = t.transactionId;
            j["amount"]        = t.amount;
            j["txnType"]       = t.txnType;
            j["paidAt"]        = t.paidAt.empty() ? json(nullptr) : json(t.paidAt);
            j["gateway"]       = t.gateway;
            txns.push_back(std::move(j));
        }
        row["recentTransactions"] = std::move(txns);
        members.push_back(std::move(row));
    }

    json out = json::object();
    out["program"]     = programKey;
    out["programId"]   = programId;
    out["total"]       = members.size();
    out["counts"]      = {
        {"current", cCurrent},
        {"behind",  cBehind},
        {"overdue", cOverdue},
        {"never",   cNever},
    };
    out["needsAttention"] = cNever + cOverdue;  // headline number for the badge
    out["reconciliation"] = {
        {"laReachable", laReachable},
        {"checked",     laReachable ? static_cast<int>(rows.size()) : 0},
        {"mismatches",  std::move(mismatches)},
    };
    out["members"]     = std::move(members);
    return Response(HttpStatus::OK, out.dump());
}