#pragma once
#include <string>
#include "../third_party/json.hpp"

// ────────────────────────────────────────────────────────────────────────────
// Expenses — what the club expects to pay out, month by month, and what has
// already gone onto an invoice (migration 490).
//
// Owner 2026-09-29: "how can we do projections for expenses too? … going
// forward we will be putting expenses into my invoice … figure out what
// projection was invoiced already as we go and take it out of projection"
// / "lets start with ref fees … they are easy to check off right as they
// are invoiced right?"
//
// Two shapes:
//   Referee fees  ref_fee_policies × home games.  Games already on a league
//                 schedule (league_fixtures when the league has a feed,
//                 else the club calendar) sit in their own month; each
//                 ref_fee_seasons row says how many home games the season
//                 should hold, and the shortfall is spread over the season's
//                 months still ahead.  A game ticked on an invoice
//                 (ref_fee_payments) is invoiced, not projected.
//   Coaching      (mig 494) usual hours: each active issuer's default week ×
//                 rate, day by day from today; game hours: ref_fee_policies
//                 of kind 'coaching' (hours_per_game × rate_per_hour, every
//                 game, home and away), same seasons mechanism as referees.
//   Budget lines  budget_lines: a fixed amount, an amount × the section's
//                 current members (kits), or an amount × the weeks still
//                 ahead in the period (paint, mig 491).  Invoice lines / instalment plans
//                 that count toward the line reduce what is still to come;
//                 the remainder lands in the line's start month (never
//                 earlier than the current month) or is spread evenly.
//
// Everything is per club section (Mens / Womens / Boys / Girls) so #finances
// can roll up per section and overall like the revenue side.
class Expenses {
public:
    // Every home game the club pays referees for, known from the schedules:
    // { policy_id, policy_label, section_id, source: fixture|event, ref_id,
    //   game_on, date_label, opponent, amount, played, invoiced: {line_id,
    //   invoice_id, invoice_label} | null }.  Ordered by date.
    static nlohmann::json games(int clubId);

    // The projection: { months: [YYYY-MM…], today, ref_fees: [policy…],
    //   budget: [line…], sections: [{section_id, name, by_month}], all }.
    // Each by_month entry is { projected, invoiced } — projected is what is
    // still expected to go out that month, invoiced what already did.
    static nlohmann::json projection(int clubId);

    // Budget lines an invoice line can count toward: { id, label, category,
    // section, total, invoiced, remaining }.
    static nlohmann::json openBudgetLines(int clubId);

    // The Referees line for a set of games ({source, ref_id} each):
    // { description, quantity, amount, items: [{policy_id, source, ref_id,
    //   game_on, opponent, amount}] }.  Empty items = nothing valid.
    static nlohmann::json refLineFor(int clubId, const nlohmann::json& picks);
    // Tick those games as paid by that invoice line.
    static void recordRefPayments(long long invoiceLineId, const nlohmann::json& items);
};
