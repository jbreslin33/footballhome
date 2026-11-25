#pragma once
#include <string>
#include "../core/Controller.h"

// TicketsController — 🎟 tickets (mig 1886).
//
// No login (the fan's pages):
//   GET  /api/tickets/public/on-sale        { products }        the /tickets/ page
//   GET  /api/tickets/public/ticket?k=<tok> { ticket } | 404    the /t/ ticket page
// Gate (club admins and ticket_gate_staff):
//   GET  /api/tickets/gate/games            { games, sources, products }
//   GET  /api/tickets/gate/summary?e=<id>   { summary }
//   POST /api/tickets/gate/scan  {e, code, n?}                 → { scan, summary }
//   POST /api/tickets/gate/sell  {e, source, people, amount?, name?, phone?} → { sale, summary }
//   POST /api/tickets/gate/count {e, n: 1|-1}                  → { summary }
// Club admins:
//   GET  /api/tickets/list                  { tickets, sync }   every ticket
class TicketsController : public Controller {
public:
    TicketsController();
    void registerRoutes(Router& router, const std::string& prefix) override;
private:
    int callerPersonId(const Request& request);
    bool gateAllowed(const Request& request, Response* error);
    bool adminAllowed(const Request& request, Response* error);
    Response handleOnSale(const Request& request);
    Response handleTicket(const Request& request);
    Response handleGames(const Request& request);
    Response handleSummary(const Request& request);
    Response handleScan(const Request& request);
    Response handleSell(const Request& request);
    Response handleCount(const Request& request);
    Response handleList(const Request& request);
};
