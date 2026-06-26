#include "Lead.h"

#include <sstream>
#include <stdexcept>

#include "../database/Database.h"

namespace {

using nlohmann::json;

// Parse a JSONB column.  pqxx returns it as text in libpq's repr; nlohmann
// can parse that directly.  An unset/null cell yields nullptr.
json parseJsonb(const pqxx::field& f) {
    if (f.is_null()) return json(nullptr);
    try { return json::parse(f.c_str()); }
    catch (const std::exception&) { return json(nullptr); }
}

std::optional<std::string> optStr(const pqxx::field& f) {
    if (f.is_null()) return std::nullopt;
    return std::string(f.c_str());
}

// Build a Lead from a pqxx::row whose columns are (in order):
//   id, leadgen_id, form_id, page_id, ad_id, name, email, phone,
//   raw_fields, preferred_channel, created_at, email_count, last_email_at
Lead rowToLead(const pqxx::row& row) {
    Lead l;
    l.id               = row["id"].as<int>();
    l.leadgenId        = row["leadgen_id"].c_str();
    l.formId           = row["form_id"].c_str();
    l.pageId           = optStr(row["page_id"]);
    l.adId             = optStr(row["ad_id"]);
    l.name             = optStr(row["name"]);
    l.email            = optStr(row["email"]);
    l.phone            = optStr(row["phone"]);
    l.rawFields        = parseJsonb(row["raw_fields"]);
    l.preferredChannel = optStr(row["preferred_channel"]);
    l.createdAtIso     = row["created_at"].is_null() ? std::string{} : row["created_at"].c_str();
    // email_count / last_email_at are aggregate-only; tolerate their
    // absence when this row came from findById (single-row select).
    // pqxx::row::column_number() throws on unknown name rather than
    // returning -1, so guard via try/catch.
    try {
        const auto& f = row["email_count"];
        l.emailCount = f.is_null() ? 0 : f.as<int>();
    } catch (const std::exception&) { /* not selected */ }
    try {
        l.lastEmailAtIso = optStr(row["last_email_at"]);
    } catch (const std::exception&) { /* not selected */ }
    return l;
}

const char* kSelectListAggregate =
    "SELECT l.id, l.leadgen_id, l.form_id, l.page_id, l.ad_id, "
    "       l.name, l.email, l.phone, l.raw_fields, l.preferred_channel, "
    "       to_char(l.created_at AT TIME ZONE 'UTC', "
    "               'YYYY-MM-DD\"T\"HH24:MI:SS.MS\"Z\"') AS created_at, "
    "       COALESCE(c.email_count, 0)::int AS email_count, "
    "       to_char(c.last_email_at AT TIME ZONE 'UTC', "
    "               'YYYY-MM-DD\"T\"HH24:MI:SS.MS\"Z\"') AS last_email_at "
    "  FROM leads l "
    "  LEFT JOIN ( "
    "    SELECT lead_id, "
    "           COUNT(*) FILTER (WHERE channel='email')    AS email_count, "
    "           MAX(sent_at) FILTER (WHERE channel='email') AS last_email_at "
    "      FROM lead_contacts "
    "     GROUP BY lead_id "
    "  ) c ON c.lead_id = l.id "
    " ORDER BY l.created_at DESC";

const char* kSelectById =
    "SELECT id, leadgen_id, form_id, page_id, ad_id, "
    "       name, email, phone, raw_fields, preferred_channel, "
    "       to_char(created_at AT TIME ZONE 'UTC', "
    "               'YYYY-MM-DD\"T\"HH24:MI:SS.MS\"Z\"') AS created_at "
    "  FROM leads "
    " WHERE id = $1";

} // namespace

std::vector<Lead> Lead::listAll() {
    auto db = Database::getInstance();
    auto rs = db->query(kSelectListAggregate);
    std::vector<Lead> out;
    out.reserve(rs.size());
    for (const auto& row : rs) out.push_back(rowToLead(row));
    return out;
}

std::optional<Lead> Lead::findById(int leadId) {
    auto db = Database::getInstance();
    auto rs = db->query(kSelectById, { std::to_string(leadId) });
    if (rs.empty()) return std::nullopt;
    return rowToLead(rs[0]);
}

std::optional<std::string>
Lead::normalizePreferredChannel(const std::string& raw) {
    if (raw.empty()) return std::nullopt;
    std::string v;
    v.reserve(raw.size());
    for (char c : raw) v.push_back(static_cast<char>(std::tolower(
        static_cast<unsigned char>(c))));
    // Trim trailing/leading whitespace.
    size_t a = 0, b = v.size();
    while (a < b && std::isspace(static_cast<unsigned char>(v[a]))) ++a;
    while (b > a && std::isspace(static_cast<unsigned char>(v[b - 1]))) --b;
    v = v.substr(a, b - a);
    if (v == "text"     || v == "sms"        || v == "phone text") return std::string("text");
    if (v == "email")                                              return std::string("email");
    if (v == "whatsapp" || v == "whats app"  || v == "wa")         return std::string("whatsapp");
    return std::nullopt;
}

const std::vector<std::string>& Lead::excludedLeadgenIds() {
    // 5 California leads from the APSL ad that ran against San Francisco
    // instead of Philadelphia (city-key bug, fixed 2026-06-08).  Same set
    // the Node webhook used to keep them out of /api/leads forever.
    static const std::vector<std::string> kExcluded = {
        "1216620387131716", // Ann (707 CA)
        "2389328841559768", // Alberto Castillon (209 CA)
        "1018387347196312", // Yovg Tribal (510 CA)
        "2211610912932327", // Brayan Guerra (510 CA)
        "987234783709164",  // فياض زقزوق (510 CA)
    };
    return kExcluded;
}

bool Lead::upsertFromMeta(const json& metaLead) {
    const std::string leadgenId = metaLead.value("id", std::string{});
    if (leadgenId.empty()) return false;

    for (const auto& bad : excludedLeadgenIds()) {
        if (leadgenId == bad) return false;
    }

    // Flatten field_data into a name→value map for the column extraction.
    // Meta sends an array of {name, values:[string,...]}; we keep the
    // first value, matching the Node `extractLeadFields` helper.
    const json& fd = metaLead.contains("field_data") ? metaLead["field_data"]
                                                     : json::array();

    std::string fullName, email, phone, preferredRaw;
    for (const auto& f : fd) {
        if (!f.is_object()) continue;
        const std::string name = f.value("name", std::string{});
        if (name.empty()) continue;
        std::string value;
        if (f.contains("values") && f["values"].is_array() && !f["values"].empty()) {
            const auto& v0 = f["values"][0];
            if (v0.is_string())          value = v0.get<std::string>();
            else if (!v0.is_null())      value = v0.dump();
        }
        if (name == "full_name" || (fullName.empty() && name == "name"))
            fullName = value;
        else if (name == "email" || (email.empty() && name == "email_address"))
            email = value;
        else if (name == "phone_number" || (phone.empty() && name == "phone"))
            phone = value;
        else if (name == "preferred_channel")
            preferredRaw = value;
    }

    const auto preferred = normalizePreferredChannel(preferredRaw);

    // Build raw_fields jsonb param: exactly the JSON.stringify(field_data)
    // Node writes — the full array of {name,values}.  json::dump() with
    // default settings gives a compact (no whitespace) representation
    // matching Node's behavior.
    const std::string rawFieldsJson = fd.dump();

    auto null_or = [](const std::string& s) -> std::string { return s; };

    // pqxx wants every $N to be a string for the prepared param adapter
    // we use elsewhere — but NULLs need a sentinel.  Database::query() in
    // this codebase already supports the std::vector<std::string> form, so
    // we keep the call site uniform.  Empty strings stay as empty strings
    // (they become NULL via NULLIF inside the SQL).
    auto db = Database::getInstance();
    db->query(
        "INSERT INTO leads (leadgen_id, form_id, page_id, ad_id, "
        "                   name, email, phone, raw_fields, "
        "                   preferred_channel, created_at) "
        "VALUES ($1, NULLIF($2, ''), NULLIF($3, ''), NULLIF($4, ''), "
        "        NULLIF($5, ''), NULLIF($6, ''), NULLIF($7, ''), "
        "        $8::jsonb, NULLIF($9, ''), "
        "        COALESCE(NULLIF($10, '')::timestamptz, now())) "
        "ON CONFLICT (leadgen_id) DO UPDATE "
        "   SET form_id = EXCLUDED.form_id, "
        "       page_id = EXCLUDED.page_id, "
        "       ad_id   = EXCLUDED.ad_id, "
        "       name    = EXCLUDED.name, "
        "       email   = EXCLUDED.email, "
        "       phone   = EXCLUDED.phone, "
        "       raw_fields = EXCLUDED.raw_fields, "
        "       preferred_channel = COALESCE(EXCLUDED.preferred_channel, "
        "                                    leads.preferred_channel), "
        "       created_at = COALESCE(leads.created_at, EXCLUDED.created_at)",
        {
            leadgenId,
            null_or(metaLead.value("form_id", std::string{})),
            null_or(metaLead.value("page_id", std::string{})),
            null_or(metaLead.value("ad_id",   std::string{})),
            null_or(fullName),
            null_or(email),
            null_or(phone),
            rawFieldsJson,
            preferred.value_or(std::string{}),
            null_or(metaLead.value("created_time", std::string{})),
        });
    return true;
}
