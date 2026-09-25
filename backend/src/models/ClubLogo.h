#pragma once
#include <string>
#include <vector>
#include "../third_party/json.hpp"

class Database;

// ────────────────────────────────────────────────────────────────────────────
// ClubLogo — club crests (migration 428, owner 2026-09-25: "all logos need
// to be saved in db and normalized with club").
//
// One row per image in club_logos (bytes in the DB are the source of
// truth); clubs.logo_id points at the current one and clubs.logo_url holds
// its nginx path.  The file under /app/images/clubs (= frontend/images/clubs,
// served by nginx at /images/clubs/) is a cache this class writes on save
// and rewrites on demand.  club_aliases maps opponent text to a club.
//
// This class owns every SQL touch; ClubLogoController serves /api/club-logos.
// ────────────────────────────────────────────────────────────────────────────
class ClubLogo {
public:
    struct Sniffed { std::string ext, mime; bool ok = false; };
    struct Saved   { long long logoId = 0; std::string filePath, error; bool ok() const { return error.empty(); } };

    ClubLogo();

    // Board for #logos: clubs that carry a stored logo or an alias, every
    // club name for the picker, and opponent texts on the calendar that no
    // rule resolves to a crest yet.
    nlohmann::json board();

    // Case/whitespace-insensitive clubs.name match; 0 when none.  Prefers a
    // club that already has a stored logo or alias, then the lowest id.
    long long findClubByName(const std::string& name);
    // Also checks club_aliases.
    long long resolveClub(const std::string& text);
    // New unattached club (organization_id NULL).
    long long createClub(const std::string& name);
    bool clubExists(long long clubId);

    // Checks the bytes are a PNG/JPEG/WebP/GIF/SVG, writes the file, inserts
    // the row and makes it the club's current logo.  source: upload | url | legacy.
    Saved save(long long clubId, const std::string& bytes, const std::string& source,
               const std::string& sourceUrl, const std::string& originalFilename, long long personId);

    long long setAlias(const std::string& alias, long long clubId, std::string* error);
    bool removeAlias(long long aliasId);

    // Startup: bring the hand-placed /images/... crests (clubs.logo_url with
    // no logo_id) into club_logos, then rewrite any cached file that is
    // missing on disk.  Both idempotent.
    void importLegacy();
    void materialize();

    static Sniffed sniff(const std::string& bytes);
    static std::string slugify(const std::string& name);
    static const char* dir()      { return "/app/images/clubs"; }
    static const char* siteDir()  { return "/app/images/site"; }   // read-only mount of frontend/images

private:
    bool writeFile(const std::string& filePath, const std::string& bytes);
    static std::string hex(const std::string& bytes);
    static std::string unhex(const std::string& hexText);
    Database* db_;
};
