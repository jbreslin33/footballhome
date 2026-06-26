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
                                      std::optional<std::string> status) {
    auto db = Database::getInstance();

    // sent_at is `timestamp without time zone` defaulted to CURRENT_TIMESTAMP
    // — emit the same ISO-with-Z shape Node's pg driver produces when
    // JSON.stringify-ing the returned Date.  Containers run UTC so casting
    // through `AT TIME ZONE 'UTC'` is a no-op semantically; we just need
    // the format.
    auto rs = db->query(
        "INSERT INTO lead_contacts (lead_id, channel, contacted_by, "
        "                           message_body, status) "
        "VALUES ($1::int, $2, NULLIF($3, '')::int, NULLIF($4, ''), "
        "        COALESCE(NULLIF($5, ''), 'sent')) "
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
