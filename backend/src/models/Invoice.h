#pragma once
#include <string>
#include "../third_party/json.hpp"

class Database;

// ────────────────────────────────────────────────────────────────────────────
// Invoice — biweekly invoices to The Lighthouse, Inc. (migration 465, owner
// 2026-09-27: "make it easier to make invoices for lighthouse … a top level
// section … on a specific invoice sheet … for myself, luke breslin, jamie
// Arevelo and Anthony Acevedo … the others will only have hours").
//
// invoice_issuers say who invoices (their From block, payable-to, duty and
// rate); invoices / invoice_lines are the sheets; invoice_installment_plans
// carry an expense over N invoices — creating a new invoice picks up the
// next "k of N" line of every plan the issuer has not finished, which is
// the part that used to be renumbered by hand.  The number is the pay
// period of the year, shared by every issuer.
//
// This class owns every SQL touch; InvoiceController serves /api/invoices.
// ────────────────────────────────────────────────────────────────────────────
class Invoice {
public:
    Invoice();

    // Everything the page needs: issuers, categories, bill-to, invoices
    // (with totals) and each issuer's open plans + the next number.
    nlohmann::json board();

    // One sheet: header, lines in print order, total, file name.  Empty
    // object when missing.
    nlohmann::json get(long long invoiceId);
    // The same sheet by its public slug (mig 480); empty when unknown.
    nlohmann::json getPublic(const std::string& slug);

    // New draft for the issuer: next number (see nextNumber), today's date
    // unless given, the hours line at the issuer's rate, and one line per
    // open instalment plan.  Returns the invoice id, 0 on failure.
    long long create(long long issuerId, const std::string& isoDate, std::string* error);
    // What board() runs first (mig 569): a draft for the previous and the
    // current pay period, for every auto_create issuer whose latest number
    // is behind them — so nobody has to hit New invoice.
    void ensureAutoDrafts();

    bool update(long long invoiceId, const nlohmann::json& fields, std::string* error);
    bool remove(long long invoiceId);

    // Insert (lineId 0) or update a line.  amount defaults to qty × rate.
    long long upsertLine(long long invoiceId, long long lineId, const nlohmann::json& fields, std::string* error);
    bool removeLine(long long lineId);

    // New instalment plan for the issuer; its "1 of N" line lands on the
    // given draft invoice.  Returns the plan id.
    long long createPlan(long long issuerId, long long invoiceId, const nlohmann::json& fields, std::string* error);
    bool removePlan(long long planId);

    // Hours by day (mig 469): a stint on the invoice, { date, start, end,
    // note }.  The labor line's quantity / amount follow the stints.
    long long upsertShift(long long invoiceId, long long shiftId, const nlohmann::json& fields, std::string* error);
    bool removeShift(long long shiftId);

    // Weekly default (mig 470): { issuer_id, weekday 0-6, start, end, note }.
    long long upsertDefaultShift(long long issuerId, long long id, const nlohmann::json& fields, std::string* error);
    bool removeDefaultShift(long long id);
    // Copy the issuer's usual week onto the invoice's period.  Only when the
    // invoice has no days yet, unless force.  Returns days added.
    int applyDefaults(long long invoiceId, bool force, std::string* error);
    // Events on the calendar in the invoice's period (mig 531, practices
    // since mig 569): every match and practice of a team the issuer
    // coaches, or whose coaching policy pays them (coach_issuer_id), with
    // the issuer's own RSVP, the hours the policy gives a match (else the
    // calendar length) and whether it is already a day row.
    nlohmann::json periodGames(long long invoiceId);
    // Add those events as day rows: the fh_event_ids given, or — with none
    // and policyOnly — what a new invoice adds by itself: the policy-paid
    // games, plus every RSVP-yes event when the issuer's days_source is
    // 'events' (mig 569).  Already-added events are skipped.  Returns days
    // added.
    int addGames(long long invoiceId, const std::vector<long long>& fhEventIds, bool policyOnly, std::string* error);

    bool updateIssuer(long long issuerId, const nlohmann::json& fields, std::string* error);

    long long issuerOf(long long invoiceId);

private:
    // Highest number used by anyone this year; +1 when this issuer already
    // holds it (James does all four in one sitting, so Luke's next is
    // James's current).
    int nextNumber(long long issuerId, int year);
    // The shared middle of create() and ensureAutoDrafts(): the draft for
    // one specific (year, number), dated the Friday after the period unless
    // isoDate is given.
    long long createNumbered(long long issuerId, int year, int number, const std::string& isoDate, std::string* error);
    // Labor line quantity = SUM(shift hours), amount = quantity × rate,
    // whenever the invoice has any shifts.
    void syncLabor(long long invoiceId);
    nlohmann::json openPlans(long long issuerId);
    nlohmann::json defaultShifts(long long issuerId);

    Database* db_;
};
