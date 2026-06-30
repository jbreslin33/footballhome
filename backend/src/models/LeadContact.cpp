#include "LeadContact.h"

#include "../database/Database.h"

namespace {

std::optional<std::string> optStr(const pqxx::field& f) {
    if (f.is_null()) return std::nullopt;
    return std::string(f.c_str());
}

} // namespace

LeadContact::Row LeadContact::insert(int leadId,
                                      const std::string& channel,
                                      std::optional<int>         contactedBy,
                                      std::optional<std::string> messageBody,
                                      std::optional<std::string> status,
                                      std::optional<std::string> templateId) {
    auto db = Database::getInstance();

    // sent_at is `timestamp without time zone` defaulted to CURRENT_TIMESTAMP
    // — emit the same ISO-with-Z shape Node's pg driver produces when
    // JSON.stringify-ing the returned Date.  Containers run UTC so casting
    // through `AT TIME ZONE 'UTC'` is a no-op semantically; we just need
    // the format.
    auto rs = db->query(
        "INSERT INTO lead_contacts (lead_id, channel, contacted_by, "
        "                           message_body, status, template) "
        "VALUES ($1::int, $2, NULLIF($3, '')::int, NULLIF($4, ''), "
        "        COALESCE(NULLIF($5, ''), 'sent'), NULLIF($6, '')) "
        "RETURNING id, lead_id, channel, "
        "          to_char(sent_at AT TIME ZONE 'UTC', "
        "                  'YYYY-MM-DD\"T\"HH24:MI:SS.MS\"Z\"') AS sent_at, "
        "          status",
        {
            std::to_string(leadId),
            channel,
            contactedBy.has_value() ? std::to_string(*contactedBy) : std::string{},
            messageBody.value_or(std::string{}),
            status.value_or(std::string{}),
            templateId.value_or(std::string{}),
        });

    Row r;
    if (!rs.empty()) {
        const auto& row = rs[0];
        r.id        = row["id"].as<int>();
        r.leadId    = row["lead_id"].as<int>();
        r.channel   = row["channel"].c_str();
        r.sentAtIso = row["sent_at"].is_null() ? std::string{} : row["sent_at"].c_str();
        r.status    = optStr(row["status"]);
    }
    return r;
}

// ────────────────────────────────────────────────────────────────────────────
// List recent touches for a lead.  Drives the Edit-modal "Recent touches"
// section so the operator can spot + delete accidental sends.
// ────────────────────────────────────────────────────────────────────────────
std::vector<LeadContact::LogRow> LeadContact::listForLead(int leadId, int limit) {
    auto db = Database::getInstance();
    std::vector<LogRow> out;
    if (limit <= 0) limit = 20;

    auto rs = db->query(
        "SELECT id, lead_id, channel, "
        "       to_char(sent_at AT TIME ZONE 'UTC', "
        "               'YYYY-MM-DD\"T\"HH24:MI:SS.MS\"Z\"') AS sent_at, "
        "       status, template "
        "  FROM lead_contacts "
        " WHERE lead_id = $1::int "
        " ORDER BY sent_at DESC "
        " LIMIT $2::int",
        { std::to_string(leadId), std::to_string(limit) });

    out.reserve(rs.size());
    for (const auto& row : rs) {
        LogRow r;
        r.id          = row["id"].as<int>();
        r.leadId      = row["lead_id"].as<int>();
        r.channel     = row["channel"].c_str();
        r.sentAtIso   = row["sent_at"].is_null() ? std::string{} : row["sent_at"].c_str();
        r.status      = optStr(row["status"]);
        r.templateId  = optStr(row["template"]);
        out.push_back(std::move(r));
    }
    return out;
}

// ────────────────────────────────────────────────────────────────────────────
// Delete a contact row, plus any sibling rows that the same fan-out batch
// inserted across duplicate-email/phone leads.
//
// Fan-out batches share: same channel, same lead-set (sibling leads by
// email for channel='email' / phone for channel='text'), and a sent_at
// within a few seconds of each other (each INSERT runs in its own
// statement so timestamps differ by microseconds, but ±5s is generous
// enough to catch them and tight enough to never sweep an unrelated
// touch).
//
// Returns the list of lead_ids whose rows were removed so the frontend
// can patch the cached per-lead counts in lock-step.  Empty vector ⇒
// nothing matched (already gone, or the row didn't belong to the
// supplied lead — which we treat as a 404).
// ────────────────────────────────────────────────────────────────────────────
std::vector<int> LeadContact::removeWithFanout(int contactId, int leadId) {
    auto db = Database::getInstance();

    // 1) Look up the target row.  Must match (id, lead_id) so the URL
    //    can't reach into another lead's contacts.
    auto rs = db->query(
        "SELECT id, lead_id, channel, sent_at "
        "  FROM lead_contacts "
        " WHERE id = $1::int AND lead_id = $2::int",
        { std::to_string(contactId), std::to_string(leadId) });
    if (rs.empty()) return {};

    const auto& tgt = rs[0];
    const std::string channel = tgt["channel"].c_str();
    const std::string sentAt  = tgt["sent_at"].c_str();

    // 2) Resolve sibling lead_ids by the fan-out key.  Same rules as
    //    handleLogContact in LeadsController so deletes mirror inserts.
    std::vector<int> siblingIds;
    {
        std::string match;
        if (channel == "email") {
            match =
                "SELECT id FROM leads "
                "WHERE id = $1::int "
                "   OR (email IS NOT NULL AND email <> '' "
                "       AND LOWER(email) = LOWER( (SELECT email FROM leads WHERE id = $1::int) ) )";
        } else if (channel == "text") {
            match =
                "SELECT id FROM leads "
                "WHERE id = $1::int "
                "   OR (phone IS NOT NULL AND phone <> '' "
                "       AND phone = (SELECT phone FROM leads WHERE id = $1::int) )";
        } else {
            match = "SELECT id FROM leads WHERE id = $1::int";
        }
        auto sibs = db->query(match, { std::to_string(leadId) });
        for (const auto& r : sibs) siblingIds.push_back(r[0].as<int>());
    }
    if (siblingIds.empty()) siblingIds.push_back(leadId);

    // 3) Build "(id1,id2,...)" literal for the IN list.  Values came
    //    straight from an integer column so no quoting concerns.
    std::string inList = "(";
    for (size_t i = 0; i < siblingIds.size(); ++i) {
        if (i) inList += ",";
        inList += std::to_string(siblingIds[i]);
    }
    inList += ")";

    // 4) Delete the matching rows in one shot.  RETURNING lead_id so we
    //    can echo the truly-affected ids back (in case the fan-out only
    //    hit a subset — e.g. a sibling whose touch was already deleted).
    auto del = db->query(
        "DELETE FROM lead_contacts "
        " WHERE channel = $1 "
        "   AND lead_id IN " + inList + " "
        "   AND sent_at BETWEEN ($2::timestamp - INTERVAL '5 seconds') "
        "                   AND ($2::timestamp + INTERVAL '5 seconds') "
        " RETURNING lead_id",
        { channel, sentAt });

    std::vector<int> out;
    out.reserve(del.size());
    for (const auto& r : del) out.push_back(r["lead_id"].as<int>());
    return out;
}

LeadContact::Stats LeadContact::fetchStats() {
    auto db = Database::getInstance();
    Stats out;

    // Per-lead.
    {
        auto rs = db->query(
            "SELECT lead_id, "
            "       COUNT(*) FILTER (WHERE channel='text')   AS text_count, "
            "       COUNT(*) FILTER (WHERE channel='email')  AS email_count, "
            "       to_char(MAX(sent_at) FILTER (WHERE channel='text') "
            "                 AT TIME ZONE 'UTC', "
            "               'YYYY-MM-DD\"T\"HH24:MI:SS.MS\"Z\"') AS last_text_at, "
            "       to_char(MAX(sent_at) FILTER (WHERE channel='email') "
            "                 AT TIME ZONE 'UTC', "
            "               'YYYY-MM-DD\"T\"HH24:MI:SS.MS\"Z\"') AS last_email_at "
            "  FROM lead_contacts "
            " GROUP BY lead_id");
        for (const auto& row : rs) {
            PerLead p;
            p.textCount       = row["text_count"].as<int>();
            p.emailCount      = row["email_count"].as<int>();
            p.lastTextAtIso   = optStr(row["last_text_at"]);
            p.lastEmailAtIso  = optStr(row["last_email_at"]);
            out.perLead.emplace(row["lead_id"].as<int>(), std::move(p));
        }
    }

    // Aggregate windows.
    {
        auto rs = db->query(
            "SELECT "
            "  COUNT(*) FILTER (WHERE channel='text'  AND sent_at >= NOW() - INTERVAL '5 minutes')  AS texts_5min, "
            "  COUNT(*) FILTER (WHERE channel='text'  AND sent_at >= NOW() - INTERVAL '1 hour')     AS texts_hour, "
            "  COUNT(*) FILTER (WHERE channel='text'  AND sent_at >= NOW() - INTERVAL '24 hours')   AS texts_day, "
            "  COUNT(*) FILTER (WHERE channel='text'  AND sent_at >= NOW() - INTERVAL '7 days')     AS texts_week, "
            "  COUNT(*) FILTER (WHERE channel='email' AND sent_at >= NOW() - INTERVAL '24 hours')   AS emails_day, "
            "  COUNT(*) FILTER (WHERE channel='email' AND sent_at >= NOW() - INTERVAL '7 days')     AS emails_week "
            "  FROM lead_contacts");
        if (!rs.empty()) {
            const auto& row = rs[0];
            out.aggregates.texts5min  = row["texts_5min"].as<int>();
            out.aggregates.textsHour  = row["texts_hour"].as<int>();
            out.aggregates.textsDay   = row["texts_day"].as<int>();
            out.aggregates.textsWeek  = row["texts_week"].as<int>();
            out.aggregates.emailsDay  = row["emails_day"].as<int>();
            out.aggregates.emailsWeek = row["emails_week"].as<int>();
        }
    }

    return out;
}
