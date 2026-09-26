#include "ClubFile.h"

#include <algorithm>
#include <cctype>
#include <iostream>

#include "../database/Database.h"

using nlohmann::json;

namespace {

std::string hexOf(const std::string& bytes) {
    static const char* d = "0123456789abcdef";
    std::string out;
    out.reserve(bytes.size() * 2);
    for (unsigned char c : bytes) { out.push_back(d[c >> 4]); out.push_back(d[c & 15]); }
    return out;
}

std::string unhex(const std::string& h) {
    std::string out;
    size_t i = (h.size() >= 2 && h[0] == '\\' && h[1] == 'x') ? 2 : 0;
    out.reserve((h.size() - i) / 2);
    auto v = [](char c) -> int {
        if (c >= '0' && c <= '9') return c - '0';
        if (c >= 'a' && c <= 'f') return c - 'a' + 10;
        if (c >= 'A' && c <= 'F') return c - 'A' + 10;
        return 0;
    };
    for (; i + 1 < h.size(); i += 2) out.push_back(static_cast<char>((v(h[i]) << 4) | v(h[i + 1])));
    return out;
}

std::string extOf(const std::string& filename) {
    const auto dot = filename.rfind('.');
    if (dot == std::string::npos || dot + 1 >= filename.size()) return "";
    std::string ext = filename.substr(dot + 1);
    for (char& c : ext) c = static_cast<char>(std::tolower(static_cast<unsigned char>(c)));
    return ext;
}

bool startsWith(const std::string& s, const char* p) { return s.rfind(p, 0) == 0; }

// Text we are happy to show inline: UTF-8 with no NUL and not markup
// (HTML/SVG/XML could carry script — those go out as attachments).
bool looksLikeText(const std::string& b) {
    const size_t n = std::min<size_t>(b.size(), 8192);
    for (size_t i = 0; i < n; ++i) {
        const unsigned char c = static_cast<unsigned char>(b[i]);
        if (c == 0) return false;
        if (c < 32 && c != '\t' && c != '\n' && c != '\r' && c != '\f') return false;
    }
    size_t i = 0;
    while (i < n && std::isspace(static_cast<unsigned char>(b[i]))) ++i;
    if (i < n && b[i] == '<') return false;
    return true;
}

json rowToJson(const pqxx::row& r) {
    return {
        {"id",          r["id"].as<long long>()},
        {"title",       r["title"].c_str()},
        {"note",        r["note"].is_null() ? "" : r["note"].c_str()},
        {"filename",    r["original_filename"].c_str()},
        {"mime",        r["mime"].c_str()},
        {"byte_size",   r["byte_size"].as<long long>()},
        {"visibility",  r["visibility"].c_str()},
        {"uploaded_by", r["uploaded_by"].is_null() ? 0 : r["uploaded_by"].as<long long>()},
        {"uploader",    r["uploader"].is_null() ? "" : r["uploader"].c_str()},
        {"created_at",  r["created_at"].c_str()},
        {"inline_ok",   r["inline_ok"].as<bool>()},
    };
}

}  // namespace

ClubFile::ClubFile() : db_(Database::getInstance()) {}

ClubFile::Meta ClubFile::sniff(const std::string& b, const std::string& filename) {
    Meta m;
    m.filename = filename;
    const std::string ext = extOf(filename);
    auto set = [&](const char* mime, bool inl) { m.mime = mime; m.inlineOk = inl; };
    if (startsWith(b, "%PDF-"))                                            set("application/pdf", true);
    else if (startsWith(b, "\x89PNG\r\n\x1a\n"))                            set("image/png", true);
    else if (b.size() > 3 && startsWith(b, "\xFF\xD8\xFF"))                 set("image/jpeg", true);
    else if (startsWith(b, "GIF87a") || startsWith(b, "GIF89a"))            set("image/gif", true);
    else if (b.size() > 12 && startsWith(b, "RIFF") && b.compare(8, 4, "WEBP") == 0) set("image/webp", true);
    else if (startsWith(b, "PK\x03\x04")) {
        if      (ext == "xlsx") set("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", false);
        else if (ext == "docx") set("application/vnd.openxmlformats-officedocument.wordprocessingml.document", false);
        else if (ext == "pptx") set("application/vnd.openxmlformats-officedocument.presentationml.presentation", false);
        else                    set("application/zip", false);
    }
    else if (startsWith(b, "\xD0\xCF\x11\xE0"))                             set("application/msword", false);   // legacy Office
    else if (looksLikeText(b)) {
        if      (ext == "csv")               set("text/csv; charset=utf-8", true);
        else if (ext == "md")                set("text/markdown; charset=utf-8", true);
        else if (ext == "json")              set("application/json; charset=utf-8", true);
        else                                 set("text/plain; charset=utf-8", true);
    }
    else                                                                    set("application/octet-stream", false);
    return m;
}

json ClubFile::visibilities() {
    json out = json::array();
    for (const auto& r : db_->query("SELECT code, label, description FROM file_visibilities ORDER BY sort_order, code")) {
        out.push_back({{"code", r["code"].c_str()}, {"label", r["label"].c_str()}, {"description", r["description"].c_str()}});
    }
    return out;
}

bool ClubFile::visibilityExists(const std::string& code) {
    return !db_->query("SELECT 1 FROM file_visibilities WHERE code = $1", {code}).empty();
}

json ClubFile::list(const Viewer& v) {
    // private: uploader or super.  admins: club/super.  members: signed in.
    // public: everyone (this endpoint is signed-in only; the link is open).
    auto rows = db_->query(R"SQL(
        SELECT f.id, f.title, f.note, f.original_filename, f.mime, f.byte_size, f.visibility,
               f.uploaded_by, f.created_at::text AS created_at,
               BTRIM(COALESCE(p.first_name, '') || ' ' || COALESCE(p.last_name, '')) AS uploader,
               (f.mime LIKE 'application/pdf%' OR f.mime LIKE 'image/%' OR f.mime LIKE 'text/%'
                OR f.mime LIKE 'application/json%') AS inline_ok
          FROM club_files f
          LEFT JOIN persons p ON p.id = f.uploaded_by
         WHERE f.visibility = 'public'
            OR (f.visibility = 'members' AND $1::bool)
            OR (f.visibility = 'admins'  AND $2::bool)
            OR (f.visibility = 'private' AND ($3::bool OR (f.uploaded_by IS NOT NULL AND f.uploaded_by = $4::int)))
         ORDER BY f.created_at DESC, f.id DESC)SQL",
        {v.signedIn ? "true" : "false", v.admin ? "true" : "false", v.super_ ? "true" : "false",
         std::to_string(v.personId)});
    json out = json::array();
    for (const auto& r : rows) out.push_back(rowToJson(r));
    return out;
}

ClubFile::Saved ClubFile::save(const std::string& bytes, const std::string& originalFilename, const std::string& titleIn,
                               const std::string& note, const std::string& visibility, long long personId) {
    Saved out;
    if (bytes.empty())              { out.error = "empty file"; return out; }
    if (bytes.size() > MAX_BYTES)   { out.error = "file over " + std::to_string(MAX_BYTES / (1024 * 1024)) + " MB"; return out; }
    if (!visibilityExists(visibility)) { out.error = "unknown visibility"; return out; }
    std::string filename = originalFilename.empty() ? "upload" : originalFilename;
    if (filename.size() > 200) filename = filename.substr(filename.size() - 200);
    const std::string title = titleIn.empty() ? filename : titleIn;
    const Meta m = sniff(bytes, filename);
    auto ins = db_->query(R"SQL(
        INSERT INTO club_files (title, note, original_filename, mime, byte_size, bytes, visibility, uploaded_by)
        VALUES ($1, NULLIF($2, ''), $3, $4, $5::int, decode($6, 'hex'), $7, NULLIF($8, '0')::int)
        RETURNING id)SQL",
        {title, note, filename, m.mime, std::to_string(bytes.size()), hexOf(bytes), visibility,
         std::to_string(personId)});
    out.id = ins[0]["id"].as<long long>();
    return out;
}

bool ClubFile::update(long long id, const std::string& title, const std::string& note, const std::string& visibility) {
    if (!visibilityExists(visibility)) return false;
    auto rows = db_->query(R"SQL(
        UPDATE club_files SET title = COALESCE(NULLIF($2, ''), title), note = NULLIF($3, ''),
               visibility = $4, updated_at = now()
         WHERE id = $1::int RETURNING id)SQL",
        {std::to_string(id), title, note, visibility});
    return !rows.empty();
}

bool ClubFile::remove(long long id) {
    return !db_->query("DELETE FROM club_files WHERE id = $1::int RETURNING id", {std::to_string(id)}).empty();
}

ClubFile::Meta ClubFile::meta(long long id) {
    Meta m;
    auto rows = db_->query(
        "SELECT id, title, COALESCE(note,'') AS note, original_filename, mime, byte_size, visibility FROM club_files WHERE id = $1::int",
        {std::to_string(id)});
    if (rows.empty()) return m;
    const auto& r = rows[0];
    m.id = r["id"].as<long long>();
    m.title = r["title"].c_str();
    m.note = r["note"].c_str();
    m.filename = r["original_filename"].c_str();
    m.mime = r["mime"].c_str();
    m.byteSize = r["byte_size"].as<long long>();
    m.visibility = r["visibility"].c_str();
    m.inlineOk = startsWith(m.mime, "application/pdf") || startsWith(m.mime, "image/") ||
                 startsWith(m.mime, "text/") || startsWith(m.mime, "application/json");
    return m;
}

long long ClubFile::uploadedBy(long long id) {
    auto rows = db_->query("SELECT uploaded_by FROM club_files WHERE id = $1::int", {std::to_string(id)});
    if (rows.empty() || rows[0]["uploaded_by"].is_null()) return 0;
    return rows[0]["uploaded_by"].as<long long>();
}

bool ClubFile::canSee(const Meta& m, const Viewer& v, long long uploadedBy) {
    if (m.visibility == "public")  return true;
    if (m.visibility == "members") return v.signedIn;
    if (m.visibility == "admins")  return v.admin;
    if (m.visibility == "private") return v.super_ || (uploadedBy > 0 && uploadedBy == v.personId);
    return false;
}

std::string ClubFile::bytes(long long id) {
    auto rows = db_->query("SELECT encode(bytes, 'hex') AS h FROM club_files WHERE id = $1::int", {std::to_string(id)});
    if (rows.empty()) return "";
    return unhex(rows[0]["h"].c_str());
}
