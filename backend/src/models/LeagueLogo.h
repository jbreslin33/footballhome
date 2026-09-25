#pragma once
#include <string>
#include "../third_party/json.hpp"
#include "LogoImage.h"

class Database;

// ────────────────────────────────────────────────────────────────────────────
// LeagueLogo — league / organization crests (migration 434).  Same model
// as ClubLogo: bytes in organization_logos, organizations.logo_id current,
// organizations.logo_url the nginx path of the cached file under
// frontend/images/league-logos.  League text → organization is
// gcal_league_aliases (mig 258), already read by every crest query.
// ────────────────────────────────────────────────────────────────────────────
class LeagueLogo : public LogoImage {
public:
    LeagueLogo();

    // The leagues: organizations with a league alias, a leagues row, or a
    // low id (the hand-seeded ones), with their current crest + aliases.
    nlohmann::json board();
    bool  exists(long long organizationId);
    Saved save(long long organizationId, const std::string& bytes, const std::string& source,
               const std::string& sourceUrl, const std::string& originalFilename, long long personId);
    void importLegacy();
    void materialize();

    static const char* dir()       { return "/app/images/league-logos"; }
    static const char* urlPrefix() { return "/images/league-logos/"; }

private:
    Database* db_;
};
