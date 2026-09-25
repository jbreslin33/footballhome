#pragma once
#include <memory>
#include <string>
#include "../core/Controller.h"

class ClubLogo;

// ClubLogoController — /api/club-logos, behind the #logos page (mig 428,
// owner 2026-09-25: upload a folder of opponent logos named after the club,
// or capture one from a URL; every logo stored in the DB against a club).
//
//   GET    /api/club-logos/board        clubs with a stored logo/alias, every
//                                       club name (picker), opponent texts on
//                                       the calendar with no crest yet.
//   POST   /api/club-logos/upload       { club_id | club_name, image: "data:image/…;base64,…", filename }
//                                       → stores the image as the club's crest
//                                       (a new unattached club when club_name
//                                       matches nothing).
//   POST   /api/club-logos/from-url     { club_id | club_name, url }
//                                       → fetches the image server-side and
//                                       stores it the same way.
//   POST   /api/club-logos/alias        { alias, club_id | club_name }
//                                       → opponent text -> club.
//   DELETE /api/club-logos/alias?id=…
//   POST   /api/club-logos/search       { opponent }  queue a web search for
//                                       the crest (mig 432); re-runs a miss.
//   POST   /api/club-logos/league/upload   { organization_id, image, filename }  (mig 434)
//   POST   /api/club-logos/league/from-url { organization_id, url }
//   POST   /api/club-logos/search/reject { id }  throw out a crest the search
//                                       stored; the club falls back to its
//                                       previous one.
//
// Club/super admins only (403 for a signed-in non-admin, per Controller::denialStatus).
class ClubLogoController : public Controller {
public:
    ClubLogoController();
    ~ClubLogoController() override;
    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    bool gate(const Request& request, Response* error);
    long long callerPersonId(const Request& request);
    // club_id, else club_name (existing match or a new club). 0 + *error when neither.
    long long clubFromBody(const nlohmann::json& body, bool* created, Response* error);

    Response handleBoard(const Request& request);
    Response handleUpload(const Request& request);
    Response handleFromUrl(const Request& request);
    Response handleSetAlias(const Request& request);
    Response handleRemoveAlias(const Request& request);
    Response handleSearch(const Request& request);
    Response handleRejectSearch(const Request& request);
    Response handleLeagueUpload(const Request& request);
    Response handleLeagueFromUrl(const Request& request);
    // Shared by from-url handlers: fetches `url` (http/https, public host only)
    // and returns the bytes; fills *error on refusal / failure.
    bool fetchImage(const std::string& url, std::string* bytes, Response* error);

    std::unique_ptr<ClubLogo> model_;
};
