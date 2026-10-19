#pragma once
#include <string>
#include "../core/Controller.h"

// CarpoolController — ride requests on a game (mig 601).  Owner 2026-10-19:
// "would be great to have a carpool feature on each game. request ride.
// then they could auto have address for pickup of child on there. then
// someone could click to acccpet carpool to drive?"
//
//   GET  /api/carpool/:fhEventId
//     { success, viewerPersonId,
//       requests: [{ id, personId, name, address1…zip, note, createdAt,
//                    requestedBy: {personId, name, phone},
//                    acceptedBy: {personId, name, phone} | null }],
//       riders:   [{ personId, name, open, address1…zip }] }   // who I may ask for
//   POST /api/carpool/:fhEventId/requests   { person_id, address1…zip, note }
//   POST /api/carpool/requests/:id/accept     — me as driver
//   POST /api/carpool/requests/:id/unaccept   — driver steps back
//   POST /api/carpool/requests/:id/cancel     — requester pulls it
//
// Visible to the game's own people only: rostered players and open
// invitees (fh_event_invites), their parents, the tagged teams' coaches,
// club staff (fh_event_staff) and club/super admins.  A request may be
// posted for yourself or your own child; the pickup address pre-fills
// from person_addresses and is snapshotted on the request row.
class CarpoolController : public Controller {
public:
    void registerRoutes(Router& router, const std::string& prefix) override;
private:
    Response handleList(const Request& request);
    Response handleCreate(const Request& request);
    // GET /requests/:id/options — the three timed pickup plans for the
    // viewer as driver (migs 608/609): ride to the driver's, driver
    // detours to the rider, or a neutral carpool_spots row, each with
    // leave/pickup times computed back from the event's arrival deadline
    // (Nominatim + OSRM via CarpoolRouting; addresses never leave the
    // server for anyone but the requester, accepted driver, and staff).
    Response handleOptions(const Request& request);
    Response handleAction(const Request& request, const std::string& action);
};
