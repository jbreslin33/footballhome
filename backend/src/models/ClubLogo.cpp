#include "ClubLogo.h"

#include <sys/stat.h>
#include <algorithm>
#include <cctype>
#include <fstream>
#include <iostream>
#include <iterator>
#include <sstream>

#include "../database/Database.h"

using nlohmann::json;

ClubLogo::ClubLogo() : db_(Database::getInstance()) {}

// ── helpers ──────────────────────────────────────────────────────────────

std::string ClubLogo::hex(const std::string& bytes) {
    static const char* d = "0123456789abcdef";
    std::string out;
    out.reserve(bytes.size() * 2);
    for (unsigned char c : bytes) { out.push_back(d[c >> 4]); out.push_back(d[c & 15]); }
    return out;
}

std::string ClubLogo::unhex(const std::string& h) {
    // pqxx hands bytea back as "\x0a1b..." (hex output format).
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

ClubLogo::Sniffed ClubLogo::sniff(const std::string& b) {
    Sniffed s;
    if (b.size() < 12) return s;
    if (b.compare(0, 8, "\x89PNG\r\n\x1a\n") == 0)                          { s = {"png",  "image/png",     true}; }
    else if (b.compare(0, 3, "\xFF\xD8\xFF") == 0)                          { s = {"jpg",  "image/jpeg",    true}; }
    else if (b.compare(0, 4, "RIFF") == 0 && b.compare(8, 4, "WEBP") == 0)  { s = {"webp", "image/webp",    true}; }
    else if (b.compare(0, 6, "GIF87a") == 0 || b.compare(0, 6, "GIF89a") == 0) { s = {"gif", "image/gif",   true}; }
    else {
        // SVG: text, "<svg" somewhere in the first KB (after an optional XML prolog / BOM / comments).
        const std::string head = b.substr(0, std::min<size_t>(b.size(), 1024));
        std::string lower = head;
        std::transform(lower.begin(), lower.end(), lower.begin(), [](unsigned char c) { return std::tolower(c); });
        if (lower.find("<svg") != std::string::npos && lower.find("<script") == std::string::npos) {
            s = {"svg", "image/svg+xml", true};
        }
    }
    return s;
}

std::string ClubLogo::slugify(const std::string& name) {
    std::string out;
    bool dash = false;
    for (unsigned char c : name) {
        if (std::isalnum(c)) { out.push_back(static_cast<char>(std::tolower(c))); dash = false; }
        else if (!dash && !out.empty()) { out.push_back('-'); dash = true; }
    }
    while (!out.empty() && out.back() == '-') out.pop_back();
    return out.empty() ? "club" : out.substr(0, 60);
}

bool ClubLogo::writeFile(const std::string& filePath, const std::string& bytes) {
    // filePath is the nginx path (/images/clubs/x.png); the file lives under dir().
    const std::string prefix = "/images/clubs/";
    if (filePath.rfind(prefix, 0) != 0) return false;
    mkdir(dir(), 0755);
    const std::string full = std::string(dir()) + "/" + filePath.substr(prefix.size());
    std::ofstream f(full, std::ios::binary | std::ios::trunc);
    if (!f.is_open()) { std::cerr << "ClubLogo: cannot write " << full << std::endl; return false; }
    f.write(bytes.data(), static_cast<std::streamsize>(bytes.size()));
    return f.good();
}

// ── clubs ────────────────────────────────────────────────────────────────

long long ClubLogo::findClubByName(const std::string& name) {
    auto rows = db_->query(R"SQL(
        SELECT c.id FROM clubs c
         WHERE LOWER(BTRIM(c.name)) = LOWER(BTRIM($1))
         ORDER BY (c.logo_id IS NOT NULL) DESC,
                  EXISTS (SELECT 1 FROM club_aliases a WHERE a.club_id = c.id) DESC,
                  c.id
         LIMIT 1)SQL", {name});
    return rows.empty() ? 0 : rows[0]["id"].as<long long>();
}

long long ClubLogo::resolveClub(const std::string& text) {
    auto rows = db_->query(
        "SELECT club_id FROM club_aliases WHERE LOWER(BTRIM(alias)) = LOWER(BTRIM($1)) LIMIT 1", {text});
    if (!rows.empty()) return rows[0]["club_id"].as<long long>();
    return findClubByName(text);
}

long long ClubLogo::createClub(const std::string& name) {
    auto rows = db_->query(
        "INSERT INTO clubs (organization_id, name) VALUES (NULL, BTRIM($1)) RETURNING id", {name});
    return rows.empty() ? 0 : rows[0]["id"].as<long long>();
}

bool ClubLogo::clubExists(long long clubId) {
    return !db_->query("SELECT 1 FROM clubs WHERE id = $1::int", {std::to_string(clubId)}).empty();
}

// ── logos ────────────────────────────────────────────────────────────────

ClubLogo::Saved ClubLogo::save(long long clubId, const std::string& bytes, const std::string& source,
                               const std::string& sourceUrl, const std::string& originalFilename,
                               long long personId) {
    Saved out;
    if (bytes.size() < 64)               { out.error = "empty image"; return out; }
    if (bytes.size() > 8 * 1024 * 1024)  { out.error = "image over 8 MB"; return out; }
    const Sniffed s = sniff(bytes);
    if (!s.ok) { out.error = "not a PNG, JPEG, WebP, GIF or SVG"; return out; }

    auto club = db_->query("SELECT name FROM clubs WHERE id = $1::int", {std::to_string(clubId)});
    if (club.empty()) { out.error = "no such club"; return out; }
    const std::string slug = slugify(club[0]["name"].c_str());

    // Two statements, no transaction: the file name carries the row id so
    // insert first with a placeholder path, then fix the path up.
    auto ins = db_->query(R"SQL(
        INSERT INTO club_logos (club_id, bytes, mime, byte_size, file_path, source, source_url,
                                original_filename, uploaded_by)
        VALUES ($1::int, decode($2, 'hex'), $3, $4::int, 'pending-' || $1 || '-' || clock_timestamp()::text,
                $5, NULLIF($6, ''), NULLIF($7, ''), NULLIF($8, '0')::int)
        RETURNING id)SQL",
        {std::to_string(clubId), hex(bytes), s.mime, std::to_string(bytes.size()), source,
         sourceUrl, originalFilename, std::to_string(personId)});
    out.logoId = ins[0]["id"].as<long long>();
    out.filePath = "/images/clubs/" + slug + "-" + std::to_string(out.logoId) + "." + s.ext;
    db_->query("UPDATE club_logos SET file_path = $2 WHERE id = $1::int",
               {std::to_string(out.logoId), out.filePath});
    db_->query("UPDATE clubs SET logo_id = $2::int, logo_url = $3, updated_at = now() WHERE id = $1::int",
               {std::to_string(clubId), std::to_string(out.logoId), out.filePath});
    if (!writeFile(out.filePath, bytes)) {
        // The row is the truth; a failed cache write is loud but not fatal —
        // materialize() retries at next start.
        std::cerr << "ClubLogo::save: cached file write failed for " << out.filePath << std::endl;
    }
    return out;
}

long long ClubLogo::setAlias(const std::string& aliasIn, long long clubId, std::string* error) {
    std::string alias = aliasIn;
    alias.erase(alias.begin(), std::find_if(alias.begin(), alias.end(), [](unsigned char c) { return !std::isspace(c); }));
    alias.erase(std::find_if(alias.rbegin(), alias.rend(), [](unsigned char c) { return !std::isspace(c); }).base(), alias.end());
    if (alias.empty()) { *error = "alias is empty"; return 0; }
    if (!clubExists(clubId)) { *error = "no such club"; return 0; }
    auto rows = db_->query(R"SQL(
        INSERT INTO club_aliases (club_id, alias, notes) VALUES ($1::int, $2, 'set on #logos')
        ON CONFLICT (LOWER(BTRIM(alias))) DO UPDATE SET club_id = EXCLUDED.club_id
        RETURNING id)SQL", {std::to_string(clubId), alias});
    return rows.empty() ? 0 : rows[0]["id"].as<long long>();
}

bool ClubLogo::removeAlias(long long aliasId) {
    auto rows = db_->query("DELETE FROM club_aliases WHERE id = $1::int RETURNING id", {std::to_string(aliasId)});
    return !rows.empty();
}

// ── board ────────────────────────────────────────────────────────────────

json ClubLogo::board() {
    json clubs = json::array();
    auto rows = db_->query(R"SQL(
        SELECT c.id, c.name, COALESCE(c.logo_url, '') AS logo_url, c.logo_id,
               l.source, l.source_url, l.original_filename, l.mime, l.byte_size,
               to_char(l.created_at AT TIME ZONE 'America/New_York', 'Mon DD, YYYY') AS uploaded_label,
               (SELECT count(*) FROM teams t WHERE t.club_id = c.id) AS team_count,
               COALESCE((SELECT json_agg(json_build_object('id', a.id, 'alias', a.alias) ORDER BY a.alias)
                           FROM club_aliases a WHERE a.club_id = c.id), '[]'::json) AS aliases
          FROM clubs c
          LEFT JOIN club_logos l ON l.id = c.logo_id
         WHERE c.logo_id IS NOT NULL
            OR EXISTS (SELECT 1 FROM club_aliases a WHERE a.club_id = c.id)
            OR c.id = 134
         ORDER BY (c.id = 134) DESC, c.name)SQL");
    for (const auto& r : rows) {
        clubs.push_back({
            {"id",            r["id"].as<long long>()},
            {"name",          r["name"].c_str()},
            {"logo_url",      r["logo_url"].c_str()},
            {"has_logo",      !r["logo_id"].is_null()},
            {"source",        r["source"].is_null() ? "" : r["source"].c_str()},
            {"source_url",    r["source_url"].is_null() ? "" : r["source_url"].c_str()},
            {"original_filename", r["original_filename"].is_null() ? "" : r["original_filename"].c_str()},
            {"mime",          r["mime"].is_null() ? "" : r["mime"].c_str()},
            {"byte_size",     r["byte_size"].is_null() ? 0 : r["byte_size"].as<long long>()},
            {"uploaded_label", r["uploaded_label"].is_null() ? "" : r["uploaded_label"].c_str()},
            {"team_count",    r["team_count"].as<long long>()},
            {"aliases",       json::parse(r["aliases"].c_str())},
        });
    }

    // Every club name, for the picker — the scraped list is a few hundred rows.
    json all = json::array();
    for (const auto& r : db_->query("SELECT id, name, (logo_id IS NOT NULL) AS has_logo FROM clubs ORDER BY name, id")) {
        all.push_back({{"id", r["id"].as<long long>()}, {"name", r["name"].c_str()}, {"has_logo", r["has_logo"].as<bool>()}});
    }

    // Opponent texts on the calendar that no rule turns into a crest.
    json unresolved = json::array();
    auto un = db_->query(R"SQL(
        SELECT fe.opponent, count(*) AS games,
               to_char(max(ge.starts_at) AT TIME ZONE 'America/New_York', 'Mon DD') AS last_label
          FROM fh_events fe
          JOIN gcal_events ge ON ge.id = fe.gcal_event_id
         WHERE COALESCE(fe.opponent, '') <> ''
           AND NOT EXISTS (SELECT 1 FROM club_aliases a JOIN clubs c ON c.id = a.club_id
                            WHERE LOWER(BTRIM(a.alias)) = LOWER(BTRIM(fe.opponent)) AND COALESCE(c.logo_url,'') <> '')
           AND NOT EXISTS (SELECT 1 FROM clubs c
                            WHERE LOWER(BTRIM(c.name)) = LOWER(BTRIM(fe.opponent)) AND COALESCE(c.logo_url,'') <> '')
           AND NOT EXISTS (SELECT 1 FROM gcal_opponent_aliases goa JOIN teams t ON t.id = goa.team_id
                            WHERE LOWER(BTRIM(goa.alias)) = LOWER(BTRIM(fe.opponent)) AND COALESCE(t.logo_url,'') <> '')
           AND NOT EXISTS (SELECT 1 FROM teams t
                            WHERE LOWER(BTRIM(t.name)) = LOWER(BTRIM(fe.opponent)) AND COALESCE(t.logo_url,'') <> '')
           AND NOT EXISTS (SELECT 1 FROM opponent_logo_cache olc
                            WHERE LOWER(BTRIM(olc.opponent_text)) = LOWER(BTRIM(fe.opponent)) AND olc.logo_url <> '')
         GROUP BY fe.opponent
         ORDER BY max(ge.starts_at) DESC)SQL");
    for (const auto& r : un) {
        unresolved.push_back({
            {"opponent",   r["opponent"].c_str()},
            {"games",      r["games"].as<long long>()},
            {"last_label", r["last_label"].is_null() ? "" : r["last_label"].c_str()},
        });
    }
    return {{"clubs", clubs}, {"all_clubs", all}, {"unresolved", unresolved}};
}

// ── startup ──────────────────────────────────────────────────────────────

void ClubLogo::importLegacy() {
    auto rows = db_->query(
        "SELECT id, name, logo_url FROM clubs WHERE logo_id IS NULL AND logo_url LIKE '/images/%'");
    for (const auto& r : rows) {
        const std::string url = r["logo_url"].c_str();
        const std::string full = std::string(siteDir()) + url.substr(std::string("/images").size());
        std::ifstream f(full, std::ios::binary);
        if (!f.is_open()) { std::cerr << "ClubLogo::importLegacy: missing " << full << std::endl; continue; }
        std::string bytes((std::istreambuf_iterator<char>(f)), std::istreambuf_iterator<char>());
        Saved s = save(r["id"].as<long long>(), bytes, "legacy", "", url, 0);
        if (!s.ok()) std::cerr << "ClubLogo::importLegacy(" << r["name"].c_str() << "): " << s.error << std::endl;
        else std::cout << "ClubLogo: imported " << r["name"].c_str() << " -> " << s.filePath << std::endl;
    }
}

void ClubLogo::materialize() {
    mkdir(dir(), 0755);
    auto rows = db_->query("SELECT id, file_path FROM club_logos WHERE file_path LIKE '/images/clubs/%'");
    for (const auto& r : rows) {
        const std::string path = r["file_path"].c_str();
        const std::string full = std::string(dir()) + "/" + path.substr(std::string("/images/clubs/").size());
        struct stat st{};
        if (stat(full.c_str(), &st) == 0 && st.st_size > 0) continue;
        auto b = db_->query("SELECT encode(bytes, 'hex') AS h FROM club_logos WHERE id = $1::int",
                            {std::to_string(r["id"].as<long long>())});
        if (b.empty()) continue;
        if (writeFile(path, unhex(b[0]["h"].c_str()))) std::cout << "ClubLogo: rewrote " << path << std::endl;
    }
}
