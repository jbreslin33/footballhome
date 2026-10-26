#include "ContactDrafts.h"

#include "../database/Database.h"

using nlohmann::json;

namespace {

std::string str(const pqxx::row& r, const char* c) { return r[c].is_null() ? std::string{} : std::string(r[c].c_str()); }

constexpr const char* kDraftCols =
    "d.id, d.contact_id, d.match_id, d.subject, d.body, "
    // Everyone it goes To (mig 726), the draft's own contact first.
    "(SELECT COALESCE(json_agg(json_build_object('id', c.id, 'name', c.name, 'email', c.email) "
    "         ORDER BY (c.id = d.contact_id) DESC, c.name), '[]') "
    "   FROM contact_email_draft_recipients r JOIN club_contacts c ON c.id = r.contact_id WHERE r.draft_id = d.id) AS recipients, "
    "to_char(d.updated_at AT TIME ZONE 'America/New_York', 'Mon DD, HH12:MI AM') AS updated_label, "
    "to_char(d.sent_at AT TIME ZONE 'America/New_York', 'Mon DD, HH12:MI AM') AS sent_label";

json draftJson(const pqxx::row& r) {
    return {{"id", r["id"].as<long long>()}, {"contact_id", r["contact_id"].as<long long>()},
            {"match_id", r["match_id"].is_null() ? json(nullptr) : json(r["match_id"].as<long long>())},
            {"subject", str(r, "subject")}, {"body", str(r, "body")},
            {"recipients", json::parse(str(r, "recipients"))},
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
                                   " WHERE d.sent_at IS NULL AND (d.contact_id = $1::int OR EXISTS (SELECT 1 FROM contact_email_draft_recipients r "
                                   "        WHERE r.draft_id = d.id AND r.contact_id = $1::int)) ORDER BY d.updated_at DESC", {cid}))
        out["drafts"].push_back(draftJson(r));
    for (const auto& r : db->query(std::string("SELECT ") + kDraftCols + " FROM contact_email_drafts d "
                                   " WHERE d.sent_at IS NOT NULL AND (d.contact_id = $1::int OR EXISTS (SELECT 1 FROM contact_email_draft_recipients r "
                                   "        WHERE r.draft_id = d.id AND r.contact_id = $1::int)) ORDER BY d.sent_at DESC LIMIT 5", {cid}))
        out["sent"].push_back(draftJson(r));
    return out;
}

json ContactDrafts::save(long long id, long long contactId, long long matchId,
                         const std::string& subject, const std::string& body, long long userId,
                         const std::vector<long long>* recipientIds) {
    auto* db = Database::getInstance();
    long long draftId = id;
    if (id > 0) {
        auto r = db->query("UPDATE contact_email_drafts SET subject = $2, body = $3, updated_at = now() "
                           " WHERE id = $1::bigint AND sent_at IS NULL RETURNING id",
                           {std::to_string(id), subject, body});
        if (r.empty()) return nullptr;
    } else {
        auto r = db->query("INSERT INTO contact_email_drafts (contact_id, match_id, subject, body, created_by_user_id) "
                           "SELECT c.id, NULLIF($2,'0')::int, $3, $4, NULLIF($5,'0')::int FROM club_contacts c WHERE c.id = $1::int RETURNING id",
                           {std::to_string(contactId), std::to_string(matchId), subject, body, std::to_string(userId)});
        if (r.empty()) return nullptr;
        draftId = r[0]["id"].as<long long>();
    }
    // Recipients (mig 726): the list given replaces the old one; the
    // draft's own contact is always on it.
    const std::string did = std::to_string(draftId);
    if (recipientIds) {
        std::string ids = "{";
        for (size_t i = 0; i < recipientIds->size(); ++i) { if (i) ids += ','; ids += std::to_string((*recipientIds)[i]); }
        ids += "}";
        db->query("DELETE FROM contact_email_draft_recipients r USING contact_email_drafts d "
                  " WHERE r.draft_id = d.id AND d.id = $1::bigint AND r.contact_id <> d.contact_id AND NOT (r.contact_id = ANY($2::int[]))", {did, ids});
        db->query("INSERT INTO contact_email_draft_recipients (draft_id, contact_id) "
                  "SELECT $1::bigint, c.id FROM club_contacts c WHERE c.id = ANY($2::int[]) ON CONFLICT DO NOTHING", {did, ids});
    }
    db->query("INSERT INTO contact_email_draft_recipients (draft_id, contact_id) "
              "SELECT d.id, d.contact_id FROM contact_email_drafts d WHERE d.id = $1::bigint ON CONFLICT DO NOTHING", {did});
    return draftById(draftId);
}

bool ContactDrafts::remove(long long id) {
    return !Database::getInstance()->query("DELETE FROM contact_email_drafts WHERE id = $1::bigint RETURNING id",
                                           {std::to_string(id)}).empty();
}

json ContactDrafts::markSent(long long id, long long userId) {
    auto* db = Database::getInstance();
    const std::string did = std::to_string(id);
    auto to = db->query("SELECT c.id, c.club_id, c.email FROM contact_email_draft_recipients r JOIN club_contacts c ON c.id = r.contact_id "
                        " WHERE r.draft_id = $1::bigint AND COALESCE(c.email, '') <> '' ORDER BY c.id", {did});
    if (to.empty()) return nullptr;
    auto r = db->query("UPDATE contact_email_drafts SET sent_at = now(), updated_at = now() WHERE id = $1::bigint RETURNING match_id", {did});
    if (r.empty()) return nullptr;
    const std::string matchId = r[0]["match_id"].is_null() ? std::string() : str(r[0], "match_id");
    std::string joined;
    for (const auto& c : to) {
        if (!joined.empty()) joined += ',';
        joined += str(c, "email");
        db->query("INSERT INTO club_contact_messages (club_id, contact_id, match_id, channel, contact, tier, sent_by_user_id) "
                  "VALUES ($1::int, $2::int, NULLIF($3,'')::int, 'email', $4, 'draft', NULLIF($5,'0')::int)",
                  {str(c, "club_id"), str(c, "id"), matchId, str(c, "email"), std::to_string(userId)});
    }
    return {{"to", joined}};
}
