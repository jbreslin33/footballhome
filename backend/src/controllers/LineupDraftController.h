#pragma once
#include <string>
#include "../core/Controller.h"
#include "../third_party/json.hpp"

// LineupDraftController — proposed lineups next to the official one
// (migration 495).  Owner 2026-09-29: "give lineup draft permission to some
// members. So the official one remains official … a draft tab for me,
// Christopher Fletcher and Gian Maldonado … a pill that shows diff between
// them … everyone sees every draft … make official from a draft".
//
//   GET /api/lineup-drafts/:matchId        { canDraft, viewerPersonId, drafters: [{personId, name}],
//                                            drafts: [{id, authorPersonId, authorName, mine,
//                                            formationCode, updatedAt, rows: [{playerId, zone,
//                                            positionId, slotNumber}]}] }
//                                          For anyone on the roster of one of the game's
//                                          teams (mig 496), its coaches, and club admins.
//   PUT /api/lineup-drafts/:matchId/mine   body { starters: [{playerId, positionId?, slotNumber?}],
//                                            bench: [{playerId, slotNumber?}], alternates: [{playerId}],
//                                            formationId } → the caller's draft, replaced whole.
//
// "Make official" needs no endpoint: the page loads the draft into the
// editor and saves it through the coach-gated official PUT.
class LineupDraftController : public Controller {
public:
    void registerRoutes(Router& router, const std::string& prefix) override;
private:
    struct Access { long long userId = 0; long long personId = 0; bool coach = false; bool drafter = false; std::string teamIds; };
    Access access(const Request& request, long long matchId);
    Response handleGet(const Request& request);
    Response handlePutMine(const Request& request);
};
