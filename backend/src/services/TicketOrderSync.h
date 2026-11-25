#pragma once
#include "../third_party/json.hpp"

// TicketOrderSync — 🎟 LeagueApps ticket orders → FH tickets (mig 1886).
//
// Source: LeagueApps eCommerce product orders bought from the storefront or
// a product link (GET /v2/sites/{site}/export/product-orders?program-id=0).
// Every paid order (status OPEN_PAID) of a product named in
// ticket_products.la_product_id becomes one tickets row (source leagueapps,
// admits = the order's quantity, amount = its total), keyed by
// la_product_order_id so a rerun never doubles it.  The buyer becomes a
// ticket_holders row keyed by LA userId; the order carries no email or
// phone, so those come from GET /v2/sites/{site}/members/{userId}, and the
// holder is matched to persons by persons.la_user_id / person_la_user_ids.
//
// refreshIfStale() runs on every #tickets load and every public ticket
// page open (at most once every two minutes, one LA call when nothing is
// new) and from a background loop every five minutes (main.cpp).
class TicketOrderSync {
public:
    // → {ran, newTickets, error}
    static nlohmann::json refreshIfStale(bool force = false);
    static void startLoop();
};
