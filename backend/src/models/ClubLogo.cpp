#include "ClubLogo.h"

#include <sys/stat.h>
#include <algorithm>
#include <cctype>
#include <fstream>
#include <iostream>
#include <iterator>
#include <sstream>
#include <vector>

#include "../database/Database.h"

using nlohmann::json;

ClubLogo::ClubLogo() : db_(Database::getInstance()) {}

// ── clubs ────────────────────────────────────────────────────────────────

// "Desert Hawks FC", "desert-hawks", "Desert Hawks S.C." all mean the same
// club: lower-case, letters and digits only, and the usual club suffixes
// dropped.  Exact name matches still win.
std::string ClubLogo::nameKey(const std::string& name) {
    std::string words, w;
    std::vector<std::string> toks;
    for (unsigned char c : name + " ") {
        if (std::isalnum(c)) w.push_back(static_cast<char>(std::tolower(c)));
        else if (!w.empty()) { toks.push_back(w); w.clear(); }
    }
    static const char* suffixes[] = {"fc", "sc", "ac", "cf", "afc", "club", "soccer", "football", "united"};
    auto isSuffix = [&](const std::string& t) {
        for (const char* x : suffixes) if (t == x) return true;
        return false;
    };
    // Drop trailing suffix words, but never empty the name ("Fishtown AC" → "fishtown", "FC United" stays).
    while (toks.size() > 1 && isSuffix(toks.back())) toks.pop_back();
    for (const auto& t : toks) words += t;
    return words;
}

long long ClubLogo::findClubByName(const std::string& name) {
    auto rows = db_->query(R"SQL(
        SELECT c.id FROM clubs c
         WHERE LOWER(BTRIM(c.name)) = LOWER(BTRIM($1))
         ORDER BY (c.logo_id IS NOT NULL) DESC,
                  EXISTS (SELECT 1 FROM club_aliases a WHERE a.club_id = c.id) DESC,
                  c.id
         LIMIT 1)SQL", {name});
    if (!rows.empty()) return rows[0]["id"].as<long long>();
    // Loose match: same key.  Prefer a club that already carries a crest or
    // alias (the one the admin curated) over a bare scraped row.
    const std::string key = nameKey(name);
    if (key.empty()) return 0;
    auto loose = db_->query(R"SQL(
        SELECT c.id, c.name FROM clubs c
         WHERE c.logo_id IS NOT NULL OR c.organization_id IS NULL
            OR EXISTS (SELECT 1 FROM club_aliases a WHERE a.club_id = c.id)
            OR EXISTS (SELECT 1 FROM teams t WHERE t.club_id = c.id AND t.is_active)
         ORDER BY (c.logo_id IS NOT NULL) DESC, c.id)SQL");
    for (const auto& r : loose) {
        if (nameKey(r["name"].c_str()) == key) return r["id"].as<long long>();
    }
    return 0;
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
    if (!writeFile(dir(), urlPrefix(), out.filePath, bytes)) {
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
        const std::string bytes = readSiteFile(url);
        if (bytes.empty()) { std::cerr << "ClubLogo::importLegacy: missing " << url << std::endl; continue; }
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
        if (!fileMissing(dir(), urlPrefix(), path)) continue;
        auto b = db_->query("SELECT encode(bytes, 'hex') AS h FROM club_logos WHERE id = $1::int",
                            {std::to_string(r["id"].as<long long>())});
        if (b.empty()) continue;
        if (writeFile(dir(), urlPrefix(), path, unhex(b[0]["h"].c_str()))) std::cout << "ClubLogo: rewrote " << path << std::endl;
    }
}
