#pragma once
#include <string>

#include "../third_party/json.hpp"

// ────────────────────────────────────────────────────────────────────────────
// Tickets — 🎟 season and single-game tickets for Lighthouse home games
// (mig 1886).  Sold in LeagueApps (eCommerce products, pulled by
// TicketOrderSync) or at the gate (cash / Venmo / Cash App / Zelle / free);
// every ticket carries a secret token that is its QR code and its private
// link /t/?k=<token>.  A ticket admits `admits` people per game: a season
// ticket at every home match of its product's league inside the product's
// window, a single-game ticket at its one game.
// ────────────────────────────────────────────────────────────────────────────
class Tickets {
public:
    // Home matches from yesterday to two weeks out, soonest first:
    // [{id, title, league, opponent, kickoffAt (ISO), today}].
    static nlohmann::json gateGames();

    // One game's gate: who is in (with a ticket / without), gate money by
    // seller and method, the last scans.
    static nlohmann::json gateSummary(long long eventId);

    // Check a scanned code (a token, or the /t/?k= link holding it) against
    // a game and, when it is good, let `want` people in (0 = everyone left
    // on it).  → {result: ok|used|invalid|wrong_game|voided, admitted,
    // remaining, admits, holder, product}.
    static nlohmann::json scan(long long eventId, const std::string& code, int want, int scannedByPersonId);

    // A gate sale: a single-game ticket for the game, paid by `source`
    // (an is_gate ticket_sources code), let in on the spot.  → {token,
    // admitted} or {error}.
    static nlohmann::json sell(long long eventId, const std::string& source, int people,
                               const std::string& amount, const std::string& name,
                               const std::string& phone, int soldByPersonId);

    // +1 / −1 on the without-a-ticket counter.  → the game's summary.
    static nlohmann::json count(long long eventId, int n, int personId);

    // Every ticket, newest first, for the staff list: holder, product,
    // source, admits, amount, token, scans.
    static nlohmann::json list();

    // The public ticket page /t/?k=<token>: the product, holder's first
    // name, admits, and the home games it is good for with how many have
    // used it at each.  Null when the token is unknown.
    static nlohmann::json publicTicket(const std::string& token);

    // The public /tickets/ page: products on sale [{label, kind, price, buyUrl}].
    static nlohmann::json onSale();

    // May this person work the gate?  Club admins always may (checked by the
    // controller); this answers for ticket_gate_staff.
    static bool isGateStaff(int personId);
};
