#include "ContactDrafts.h"

#include "../database/Database.h"

using nlohmann::json;

namespace {

std::string str(const pqxx::row& r, const char* c) { return r[c].is_null() ? std::string{} : std::string(r[c].c_str()); }

constexpr const char* kDraftCols =
    "d.id, d.contact_id, d.match_id, d.subject, d.body, "
    "to_char(d.updated_at AT TIME ZONE 'America/New_York', 'Mon DD, HH12:MI AM') AS updated_label, "
    "to_char(d.sent_at AT TIME ZONE 'America/New_York', 'Mon DD, HH12:MI AM') AS sent_label";

json draftJson(const pqxx::row& r) {
    return {{"id", r["id"].as<long long>()}, {"contact_id", r["contact_id"].as<long long>()},
            {"match_id", r["match_id"].is_null() ? json(nullptr) : json(r["match_id"].as<long long>())},
            {"subject", str(r, "subject")}, {"body", str(r, "body")},
            {"updated_label", str(r, "updated_label")},
            {"sent_label", r["sent_label"].is_null() ? json(nullptr) : json(str(r, "sent_label"))}};
}

json draftById(long long id) {
    auto rows = Database::getInstance()->query(std::string("SELECT ") + kDraftCols + " FROM contact_email_drafts d WHERE d.id = $1::bigint",
                                               {std::to_string(id)});
    return rows.empty() ? json(nullptr) : draftJson(rows[0]);
}

}  // namespace

json ContactDrafts::forContact(long long contactId) {
    auto* db = Database::getInstance();
    const std::string cid = std::to_string(contactId);
    auto c = db->query("SELECT id, name, email FROM club_contacts WHERE id = $1::int", {cid});
    if (c.empty()) return nullptr;
    json out = {{"contact", {{"id", contactId}, {"name", str(c[0], "name")}, {"email", str(c[0], "email")}}},
                {"drafts", json::array()}, {"sent", json::array()}};
    for (const auto& r : db->query(std::string("SELECT ") + kDraftCols + " FROM contact_email_drafts d "
                                   " WHERE d.contact_id = $1::int AND d.sent_at IS NULL ORDER BY d.updated_at DESC", {cid}))
        out["drafts"].push_back(draftJson(r));
    for (const auto& r : db->query(std::string("SELECT ") + kDraftCols + " FROM contact_email_drafts d "
                                   " WHERE d.contact_id = $1::int AND d.sent_at IS NOT NULL ORDER BY d.sent_at DESC LIMIT 5", {cid}))
        out["sent"].push_back(draftJson(r));
    return out;
}

json ContactDrafts::save(long long id, long long contactId, long long matchId,
                         const std::string& subject, const std::string& body, long long userId) {
    auto* db = Database::getInstance();
    if (id > 0) {
        auto r = db->query("UPDATE contact_email_drafts SET subject = $2, body = $3, updated_at = now() "
                           " WHERE id = $1::bigint AND sent_at IS NULL RETURNING id",
                           {std::to_string(id), subject, body});
        return r.empty() ? json(nullptr) : draftById(id);
    }
    auto r = db->query("INSERT INTO contact_email_drafts (contact_id, match_id, subject, body, created_by_user_id) "
                       "SELECT c.id, NULLIF($2,'0')::int, $3, $4, NULLIF($5,'0')::int FROM club_contacts c WHERE c.id = $1::int RETURNING id",
                       {std::to_string(contactId), std::to_string(matchId), subject, body, std::to_string(userId)});
    return r.empty() ? json(nullptr) : draftById(r[0]["id"].as<long long>());
}

bool ContactDrafts::remove(long long id) {
    return !Database::getInstance()->query("DELETE FROM contact_email_drafts WHERE id = $1::bigint RETURNING id",
                                           {std::to_string(id)}).empty();
}

json ContactDrafts::markSent(long long id, long long userId) {
    auto* db = Database::getInstance();
    auto r = db->query("UPDATE contact_email_drafts d SET sent_at = now(), updated_at = now() FROM club_contacts c "
                       " WHERE d.id = $1::bigint AND c.id = d.contact_id AND COALESCE(c.email, '') <> '' "
                       "RETURNING c.id AS contact_id, c.club_id, c.email, d.match_id",
                       {std::to_string(id)});
    if (r.empty()) return nullptr;
    db->query("INSERT INTO club_contact_messages (club_id, contact_id, match_id, channel, contact, tier, sent_by_user_id) "
              "VALUES ($1::int, $2::int, NULLIF($3,'')::int, 'email', $4, 'draft', NULLIF($5,'0')::int)",
              {str(r[0], "club_id"), str(r[0], "contact_id"), r[0]["match_id"].is_null() ? std::string() : str(r[0], "match_id"),
               str(r[0], "email"), std::to_string(userId)});
    return {{"to", str(r[0], "email")}};
}
