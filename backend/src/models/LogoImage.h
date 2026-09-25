#pragma once
#include <string>

// ────────────────────────────────────────────────────────────────────────────
// LogoImage — what every stored crest has in common (mig 428/434): the
// image bytes live in a *_logos table, the served file under
// frontend/images/<dir> is a cache.  ClubLogo (clubs) and LeagueLogo
// (organizations) derive from this and own their own SQL.
// ────────────────────────────────────────────────────────────────────────────
class LogoImage {
public:
    struct Sniffed { std::string ext, mime; bool ok = false; };
    struct Saved   { long long logoId = 0; std::string filePath, error; bool ok() const { return error.empty(); } };

    static Sniffed     sniff(const std::string& bytes);       // PNG / JPEG / WebP / GIF / SVG by content
    static std::string slugify(const std::string& name);
    static const char* siteDir() { return "/app/images/site"; }   // read-only mount of frontend/images

protected:
    // Writes the cached file for an nginx path that starts with `urlPrefix`
    // ("/images/clubs/") into `dir` ("/app/images/clubs").
    static bool        writeFile(const char* dir, const char* urlPrefix, const std::string& filePath, const std::string& bytes);
    static bool        fileMissing(const char* dir, const char* urlPrefix, const std::string& filePath);
    static std::string hex(const std::string& bytes);
    static std::string unhex(const std::string& hexText);
    static std::string readSiteFile(const std::string& imagesUrl);   // "/images/x.png" → bytes, "" when missing
};
