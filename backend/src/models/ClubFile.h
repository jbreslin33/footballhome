#pragma once
#include <string>
#include <vector>
#include "../third_party/json.hpp"

class Database;

// ────────────────────────────────────────────────────────────────────────────
// ClubFile — uploaded files (migration 455, owner 2026-09-26: "a file upload
// on footballhome where i can upload a file for you to look at? but also
// maybe to publish for others").
//
// One row per file in club_files; the bytes in the DB are the only copy —
// nothing is written under the web root, so a private file has no URL.
// file_visibilities (private / admins / members / public) says who may see
// a row; the controller decides what the caller is and this class filters.
//
// This class owns every SQL touch; ClubFileController serves /api/files.
// ────────────────────────────────────────────────────────────────────────────
class ClubFile {
public:
    // What the controller worked out about the caller.
    struct Viewer {
        long long personId = 0;
        bool signedIn = false;
        bool admin = false;     // club or super
        bool super_ = false;
    };
    struct Meta {
        long long id = 0;
        std::string title, note, filename, mime, visibility;
        long long byteSize = 0;
        bool inlineOk = false;   // safe to show in the browser (PDF, image, text)
    };
    struct Saved { long long id = 0; std::string error; bool ok() const { return error.empty(); } };

    ClubFile();

    static constexpr std::size_t MAX_BYTES = 30 * 1024 * 1024;

    nlohmann::json visibilities();
    bool visibilityExists(const std::string& code);

    // Rows the viewer may see, newest first, with the uploader's name.
    nlohmann::json list(const Viewer& v);

    // Sniffs the bytes (mime is never taken from the browser) and inserts.
    Saved save(const std::string& bytes, const std::string& originalFilename, const std::string& title,
               const std::string& note, const std::string& visibility, long long personId);
    bool update(long long id, const std::string& title, const std::string& note, const std::string& visibility);
    bool remove(long long id);

    // Meta without bytes; id 0 when missing.
    Meta meta(long long id);
    bool canSee(const Meta& m, const Viewer& v, long long uploadedBy);
    long long uploadedBy(long long id);
    std::string bytes(long long id);

    // Content type decided from the bytes + the original extension.  Only
    // PDF, raster images and plain text may render inline; everything else
    // (office docs, zips, SVG, HTML, unknown) is served as an attachment.
    static Meta sniff(const std::string& bytes, const std::string& filename);

private:
    Database* db_;
};
