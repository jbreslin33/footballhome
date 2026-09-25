#include "LeagueLogo.h"

#include <sys/stat.h>
#include <iostream>

#include "../database/Database.h"

using nlohmann::json;

LeagueLogo::LeagueLogo() : db_(Database::getInstance()) {}

bool LeagueLogo::exists(long long id) {
    return !db_->query("SELECT 1 FROM organizations WHERE id = $1::int", {std::to_string(id)}).empty();
}

LeagueLogo::Saved LeagueLogo::save(long long orgId, const std::string& bytes, const std::string& source,
                                   const std::string& sourceUrl, const std::string& originalFilename,
                                   long long personId) {
    Saved out;
    if (bytes.size() < 64)              { out.error = "empty image"; return out; }
    if (bytes.size() > 8 * 1024 * 1024) { out.error = "image over 8 MB"; return out; }
    const Sniffed s = sniff(bytes);
    if (!s.ok) { out.error = "not a PNG, JPEG, WebP, GIF or SVG"; return out; }
    auto org = db_->query("SELECT COALESCE(NULLIF(short_name, ''), name) AS n FROM organizations WHERE id = $1::int",
                          {std::to_string(orgId)});
    if (org.empty()) { out.error = "no such league"; return out; }
    const std::string slug = slugify(org[0]["n"].c_str());
    auto ins = db_->query(R"SQL(
        INSERT INTO organization_logos (organization_id, bytes, mime, byte_size, file_path, source, source_url,
                                        original_filename, uploaded_by)
        VALUES ($1::int, decode($2, 'hex'), $3, $4::int, 'pending-' || $1 || '-' || clock_timestamp()::text,
                $5, NULLIF($6, ''), NULLIF($7, ''), NULLIF($8, '0')::int)
        RETURNING id)SQL",
        {std::to_string(orgId), hex(bytes), s.mime, std::to_string(bytes.size()), source,
         sourceUrl, originalFilename, std::to_string(personId)});
    out.logoId = ins[0]["id"].as<long long>();
    out.filePath = std::string(urlPrefix()) + slug + "-" + std::to_string(out.logoId) + "." + s.ext;
    db_->query("UPDATE organization_logos SET file_path = $2 WHERE id = $1::int", {std::to_string(out.logoId), out.filePath});
    db_->query("UPDATE organizations SET logo_id = $2::int, logo_url = $3 WHERE id = $1::int",
               {std::to_string(orgId), std::to_string(out.logoId), out.filePath});
    if (!writeFile(dir(), urlPrefix(), out.filePath, bytes)) {
        std::cerr << "LeagueLogo::save: cached file write failed for " << out.filePath << std::endl;
    }
    return out;
}

json LeagueLogo::board() {
    json out = json::array();
    auto rows = db_->query(R"SQL(
        SELECT o.id, o.name, COALESCE(o.short_name, '') AS short_name, COALESCE(o.logo_url, '') AS logo_url, o.logo_id,
               l.source, l.original_filename, l.source_url,
               to_char(l.created_at AT TIME ZONE 'America/New_York', 'Mon DD, YYYY') AS uploaded_label,
               COALESCE((SELECT string_agg(ga.alias, ', ' ORDER BY ga.alias) FROM gcal_league_aliases ga
                          WHERE ga.organization_id = o.id), '') AS aliases,
               (SELECT count(*) FROM fh_events fe JOIN gcal_league_aliases ga
                  ON LOWER(BTRIM(ga.alias)) = LOWER(BTRIM(fe.league))
                 WHERE ga.organization_id = o.id) AS event_count
          FROM organizations o
          LEFT JOIN organization_logos l ON l.id = o.logo_id
         WHERE o.id < 100
            OR EXISTS (SELECT 1 FROM gcal_league_aliases ga WHERE ga.organization_id = o.id)
            OR EXISTS (SELECT 1 FROM leagues lg WHERE lg.organization_id = o.id AND lg.is_active)
         ORDER BY (o.logo_id IS NULL), o.name)SQL");
    for (const auto& r : rows) {
        out.push_back({
            {"id",            r["id"].as<long long>()},
            {"name",          r["name"].c_str()},
            {"short_name",    r["short_name"].c_str()},
            {"logo_url",      r["logo_url"].c_str()},
            {"has_logo",      !r["logo_id"].is_null()},
            {"source",        r["source"].is_null() ? "" : r["source"].c_str()},
            {"original_filename", r["original_filename"].is_null() ? "" : r["original_filename"].c_str()},
            {"source_url",    r["source_url"].is_null() ? "" : r["source_url"].c_str()},
            {"uploaded_label", r["uploaded_label"].is_null() ? "" : r["uploaded_label"].c_str()},
            {"aliases",       r["aliases"].c_str()},
            {"event_count",   r["event_count"].as<long long>()},
        });
    }
    return out;
}

void LeagueLogo::importLegacy() {
    auto rows = db_->query(
        "SELECT id, name, logo_url FROM organizations WHERE logo_id IS NULL AND logo_url LIKE '/images/%'");
    for (const auto& r : rows) {
        const std::string url = r["logo_url"].c_str();
        const std::string bytes = readSiteFile(url);
        if (bytes.empty()) { std::cerr << "LeagueLogo::importLegacy: missing " << url << std::endl; continue; }
        Saved s = save(r["id"].as<long long>(), bytes, "legacy", "", url, 0);
        if (!s.ok()) std::cerr << "LeagueLogo::importLegacy(" << r["name"].c_str() << "): " << s.error << std::endl;
        else std::cout << "LeagueLogo: imported " << r["name"].c_str() << " -> " << s.filePath << std::endl;
    }
}

void LeagueLogo::materialize() {
    mkdir(dir(), 0755);
    for (const auto& r : db_->query("SELECT id, file_path FROM organization_logos WHERE file_path LIKE '/images/league-logos/%'")) {
        const std::string path = r["file_path"].c_str();
        if (!fileMissing(dir(), urlPrefix(), path)) continue;
        auto b = db_->query("SELECT encode(bytes, 'hex') AS h FROM organization_logos WHERE id = $1::int",
                            {std::to_string(r["id"].as<long long>())});
        if (!b.empty() && writeFile(dir(), urlPrefix(), path, unhex(b[0]["h"].c_str()))) std::cout << "LeagueLogo: rewrote " << path << std::endl;
    }
}
