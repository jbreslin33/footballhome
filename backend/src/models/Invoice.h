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

    // New draft for the issuer: next number (see nextNumber), today's date
    // unless given, the hours line at the issuer's rate, and one line per
    // open instalment plan.  Returns the invoice id, 0 on failure.
    long long create(long long issuerId, const std::string& isoDate, std::string* error);

    bool update(long long invoiceId, const nlohmann::json& fields, std::string* error);
    bool remove(long long invoiceId);

    // Insert (lineId 0) or update a line.  amount defaults to qty × rate.
    long long upsertLine(long long invoiceId, long long lineId, const nlohmann::json& fields, std::string* error);
    bool removeLine(long long lineId);

    // New instalment plan for the issuer; its "1 of N" line lands on the
    // given draft invoice.  Returns the plan id.
    long long createPlan(long long issuerId, long long invoiceId, const nlohmann::json& fields, std::string* error);
    bool removePlan(long long planId);

    bool updateIssuer(long long issuerId, const nlohmann::json& fields, std::string* error);

    long long issuerOf(long long invoiceId);

private:
    // Highest number used by anyone this year; +1 when this issuer already
    // holds it (James does all four in one sitting, so Luke's next is
    // James's current).
    int nextNumber(long long issuerId, int year);
    nlohmann::json openPlans(long long issuerId);

    Database* db_;
};
