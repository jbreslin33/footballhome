#include "FacilityLockup.h"

#include <iostream>
#include <map>
#include <sstream>

#include "../core/Crypto.h"
#include "../database/Database.h"

using nlohmann::json;

namespace {

std::string str(const pqxx::row& r, const char* col) {
    return r[col].is_null() ? std::string() : r[col].as<std::string>();
}

// Every lock-up read goes through this one projection so the board, the
// scheduler and the tap page describe a night the same way.
const char* kSelect = R"(
SELECT l.id, l.facility_id, f.name AS facility, f.short_name, f.timezone,
       l.local_date::text AS local_date,
       to_char(l.local_date, 'Dy Mon FMDD') AS date_label,
       l.last_fh_event_id,
       to_char(l.due_at,        'YYYY-MM-DD"T"HH24:MI:SSOF') AS due_at,
       to_char(l.deadline_at,   'YYYY-MM-DD"T"HH24:MI:SSOF') AS deadline_at,
       to_char(l.prompted_at,   'YYYY-MM-DD"T"HH24:MI:SSOF') AS prompted_at,
       to_char(l.confirmed_at,  'YYYY-MM-DD"T"HH24:MI:SSOF') AS confirmed_at,
       to_char(l.last_alert_at, 'YYYY-MM-DD"T"HH24:MI:SSOF') AS last_alert_at,
       to_char(l.announced_at,  'YYYY-MM-DD"T"HH24:MI:SSOF') AS announced_at,
       to_char(ge.starts_at   AT TIME ZONE f.timezone, 'FMHH12:MI')    AS starts_label,
       to_char(ge.ends_at     AT TIME ZONE f.timezone, 'FMHH12:MI AM') AS ends_label,
       to_char(l.deadline_at  AT TIME ZONE f.timezone, 'FMHH12:MI AM') AS deadline_label,
       to_char(l.confirmed_at AT TIME ZONE f.timezone, 'FMHH12:MI AM') AS confirmed_label,
       COALESCE(k.player_label, initcap(fe.kind)) AS kind_label,
       (SELECT string_agg(t.name, ' / ' ORDER BY t.name)
          FROM fh_event_teams fet JOIN teams t ON t.id = fet.team_id
         WHERE fet.fh_event_id = fe.id) AS teams,
       (SELECT p.first_name || ' ' || p.last_name FROM persons p WHERE p.id = l.confirmed_by_person_id) AS confirmed_by,
       l.confirmed_via, l.note, l.alert_count,
       f.lockup_max_alerts, f.lockup_repeat_minutes,
       (now() >= l.due_at)      AS is_due,
       (now() >= l.deadline_at) AS is_overdue
  FROM facility_lockups l
  JOIN facilities f ON f.id = l.facility_id
  LEFT JOIN fh_events fe ON fe.id = l.last_fh_event_id
  LEFT JOIN gcal_events ge ON ge.id = fe.gcal_event_id
  LEFT JOIN fh_event_kind_labels k ON k.kind = fe.kind
)";

}  // namespace

std::string FacilityLockup::Lockup::status() const {
    if (!hasEvent())  return "none";
    if (confirmed())  return "locked";
    if (isOverdue)    return "overdue";
    if (isDue)        return "due";
    return "pending";
}

FacilityLockup::FacilityLockup() : db_(Database::getInstance()) {}

std::vector<FacilityLockup::Lockup> FacilityLockup::select(const std::string& where,
                                                           const std::vector<std::string>& params,
                                                           const std::string& order) {
    std::vector<Lockup> out;
    auto rows = db_->query(std::string(kSelect) + " WHERE " + where + " " +
                           (order.empty() ? "ORDER BY l.local_date DESC, f.name" : order), params);
    for (const auto& r : rows) {
        Lockup l;
        l.id            = r["id"].as<long long>();
        l.facilityId    = r["facility_id"].as<int>();
        l.facility      = str(r, "facility");
        l.shortName     = str(r, "short_name");
        l.timezone      = str(r, "timezone");
        l.localDate     = str(r, "local_date");
        l.dateLabel     = str(r, "date_label");
        l.lastEventId   = r["last_fh_event_id"].is_null() ? 0 : r["last_fh_event_id"].as<long long>();
        l.dueAtIso      = str(r, "due_at");
        l.deadlineAtIso = str(r, "deadline_at");
        l.promptedAtIso = str(r, "prompted_at");
        l.confirmedAtIso= str(r, "confirmed_at");
        l.lastAlertAtIso= str(r, "last_alert_at");
        l.announcedAtIso= str(r, "announced_at");
        l.startsLabel   = str(r, "starts_label");
        l.endsLabel     = str(r, "ends_label");
        l.deadlineLabel = str(r, "deadline_label");
        l.confirmedLabel= str(r, "confirmed_label");
        l.confirmedBy   = str(r, "confirmed_by");
        l.confirmedVia  = str(r, "confirmed_via");
        l.note          = str(r, "note");
        l.alertCount    = r["alert_count"].as<int>();
        l.maxAlerts     = r["lockup_max_alerts"].as<int>();
        l.repeatMinutes = r["lockup_repeat_minutes"].as<int>();
        l.isDue         = r["is_due"].as<bool>();
        l.isOverdue     = r["is_overdue"].as<bool>();
        if (l.hasEvent()) {
            const std::string teams = str(r, "teams");
            l.lastEvent = str(r, "kind_label") + (teams.empty() ? "" : " · " + teams) +
                          " " + l.startsLabel + "–" + l.endsLabel;
        }
        out.push_back(l);
    }
    return out;
}

void FacilityLockup::syncToday() {
    // Tonight's last event per facility → upsert; frozen once alerts start.
    db_->query(R"(
WITH today AS (
  SELECT f.id AS facility_id, f.timezone, f.lockup_grace_minutes,
         (now() AT TIME ZONE f.timezone)::date AS local_date
    FROM facilities f WHERE f.is_active AND f.lockup_required
), last_ev AS (
  SELECT t.facility_id, t.local_date, t.lockup_grace_minutes,
         (SELECT fe.id FROM fh_events fe JOIN gcal_events ge ON ge.id = fe.gcal_event_id
           WHERE fe.facility_id = t.facility_id
             AND ge.deleted_at IS NULL AND ge.status IS DISTINCT FROM 'cancelled'
             AND NOT ge.all_day
             AND (ge.starts_at AT TIME ZONE t.timezone)::date = t.local_date
           ORDER BY ge.ends_at DESC, fe.id LIMIT 1) AS fh_event_id
    FROM today t
)
INSERT INTO facility_lockups (facility_id, local_date, last_fh_event_id, due_at, deadline_at)
SELECT le.facility_id, le.local_date, le.fh_event_id, ge.ends_at,
       ge.ends_at + make_interval(mins => le.lockup_grace_minutes)
  FROM last_ev le
  JOIN fh_events fe ON fe.id = le.fh_event_id
  JOIN gcal_events ge ON ge.id = fe.gcal_event_id
ON CONFLICT (facility_id, local_date) DO UPDATE
   SET last_fh_event_id = EXCLUDED.last_fh_event_id,
       due_at = EXCLUDED.due_at, deadline_at = EXCLUDED.deadline_at, updated_at = now()
 WHERE facility_lockups.confirmed_at IS NULL AND facility_lockups.alert_count = 0
   AND (facility_lockups.last_fh_event_id IS DISTINCT FROM EXCLUDED.last_fh_event_id
        OR facility_lockups.due_at <> EXCLUDED.due_at
        OR facility_lockups.deadline_at <> EXCLUDED.deadline_at)
)");
    // Every event tonight got cancelled and nobody was told yet → no check-in.
    db_->query(R"(
DELETE FROM facility_lockups l
 USING facilities f
 WHERE f.id = l.facility_id
   AND l.local_date = (now() AT TIME ZONE f.timezone)::date
   AND l.confirmed_at IS NULL AND l.prompted_at IS NULL AND l.alert_count = 0
   AND NOT EXISTS (
     SELECT 1 FROM fh_events fe JOIN gcal_events ge ON ge.id = fe.gcal_event_id
      WHERE fe.facility_id = f.id AND ge.deleted_at IS NULL
        AND ge.status IS DISTINCT FROM 'cancelled' AND NOT ge.all_day
        AND (ge.starts_at AT TIME ZONE f.timezone)::date = l.local_date)
)");
}

std::vector<FacilityLockup::Lockup> FacilityLockup::pendingPrompts() {
    return select("l.prompted_at IS NULL AND l.confirmed_at IS NULL AND now() >= l.due_at "
                  "AND l.due_at > now() - interval '12 hours'", {});
}

std::vector<FacilityLockup::Lockup> FacilityLockup::pendingAlerts() {
    return select("l.confirmed_at IS NULL AND now() >= l.deadline_at "
                  "AND l.alert_count < f.lockup_max_alerts "
                  "AND (l.last_alert_at IS NULL OR l.last_alert_at + make_interval(mins => f.lockup_repeat_minutes) <= now()) "
                  "AND l.deadline_at > now() - interval '12 hours'", {});
}

std::vector<FacilityLockup::Lockup> FacilityLockup::pendingAnnouncements() {
    return select("l.confirmed_at IS NOT NULL AND l.announced_at IS NULL AND l.alert_count > 0 "
                  "AND l.confirmed_at > now() - interval '12 hours'", {});
}

std::vector<FacilityLockup::Lockup> FacilityLockup::todays() {
    // A facility with no events tonight still gets a card (status 'none').
    std::vector<Lockup> out = select("l.local_date = (now() AT TIME ZONE f.timezone)::date", {}, "ORDER BY f.name");
    auto facs = db_->query(
        "SELECT id, name, short_name, timezone, to_char((now() AT TIME ZONE timezone)::date, 'Dy Mon FMDD') AS date_label, "
        "       (now() AT TIME ZONE timezone)::date::text AS local_date "
        "  FROM facilities WHERE is_active AND lockup_required ORDER BY name");
    for (const auto& r : facs) {
        const int fid = r["id"].as<int>();
        bool have = false;
        for (const auto& l : out) if (l.facilityId == fid) { have = true; break; }
        if (have) continue;
        Lockup l;
        l.facilityId = fid;
        l.facility   = str(r, "name");
        l.shortName  = str(r, "short_name");
        l.timezone   = str(r, "timezone");
        l.dateLabel  = str(r, "date_label");
        l.localDate  = str(r, "local_date");
        out.push_back(l);
    }
    return out;
}

std::vector<FacilityLockup::Lockup> FacilityLockup::history(int days) {
    return select("l.local_date < (now() AT TIME ZONE f.timezone)::date "
                  "AND l.local_date >= (now() AT TIME ZONE f.timezone)::date - $1::int",
                  {std::to_string(days)});
}

bool FacilityLockup::get(long long id, Lockup* out) {
    auto v = select("l.id = $1::bigint", {std::to_string(id)});
    if (v.empty()) return false;
    *out = v.front();
    return true;
}

std::vector<FacilityLockup::Recipient> FacilityLockup::recipients(long long lockupId, const std::string& role) {
    auto rows = db_->query(R"(
WITH ppl AS (
  SELECT lp.person_id, lp.channels
    FROM facility_lockup_people lp
    JOIN facility_lockups l ON l.facility_id = lp.facility_id
   WHERE l.id = $1::bigint AND lp.role = $2 AND lp.is_active
  UNION ALL
  SELECT c.person_id, ARRAY['email','sms']::text[]
    FROM facility_lockups l
    JOIN facilities f ON f.id = l.facility_id
    JOIN fh_event_teams fet ON fet.fh_event_id = l.last_fh_event_id
    JOIN team_coaches tc ON tc.team_id = fet.team_id AND tc.ended_at IS NULL
    JOIN coaches c ON c.id = tc.coach_id
   WHERE l.id = $1::bigint AND $2 = 'closer' AND f.lockup_prompt_last_event_coaches
)
SELECT p.id AS person_id, p.first_name,
       array_to_string(ppl.channels, ',') AS channels,
       (SELECT e.email FROM person_emails e WHERE e.person_id = p.id
         ORDER BY e.is_primary DESC NULLS LAST, e.id LIMIT 1) AS email,
       (SELECT ph.phone_number FROM person_phones ph WHERE ph.person_id = p.id AND ph.can_receive_sms
         ORDER BY ph.is_primary DESC NULLS LAST, ph.id LIMIT 1) AS phone
  FROM ppl JOIN persons p ON p.id = ppl.person_id
)", {std::to_string(lockupId), role});
    std::map<long long, Recipient> merged;
    for (const auto& r : rows) {
        const long long pid = r["person_id"].as<long long>();
        Recipient& rec = merged[pid];
        rec.personId  = pid;
        rec.firstName = str(r, "first_name");
        rec.email     = str(r, "email");
        rec.phone     = str(r, "phone");
        const std::string ch = "," + str(r, "channels") + ",";
        if (ch.find(",email,") != std::string::npos) rec.wantEmail = true;
        if (ch.find(",sms,")   != std::string::npos) rec.wantSms   = true;
        if (ch.find(",call,")  != std::string::npos) rec.wantCall  = true;
    }
    std::vector<Recipient> out;
    for (auto& kv : merged) out.push_back(kv.second);
    return out;
}

std::string FacilityLockup::issueToken(long long lockupId, long long personId) {
    const std::string raw = fh::crypto::randomTokenB64Url(24);
    db_->query("INSERT INTO facility_lockup_tokens (lockup_id, person_id, token_hash, expires_at) "
               "VALUES ($1::bigint, $2::int, $3, now() + interval '24 hours')",
               {std::to_string(lockupId), std::to_string(personId), fh::crypto::sha256Hex(raw)});
    return raw;
}

FacilityLockup::TokenInfo FacilityLockup::lookupToken(const std::string& raw) {
    TokenInfo t;
    if (raw.empty()) return t;
    auto rows = db_->query(
        "SELECT t.id, t.lockup_id, t.person_id, (t.expires_at > now()) AS live, "
        "       (t.used_at IS NOT NULL) AS used, p.first_name "
        "  FROM facility_lockup_tokens t JOIN persons p ON p.id = t.person_id "
        " WHERE t.token_hash = $1", {fh::crypto::sha256Hex(raw)});
    if (rows.empty()) return t;
    const auto& r = rows[0];
    t.found     = true;
    t.id        = r["id"].as<long long>();
    t.lockupId  = r["lockup_id"].as<long long>();
    t.personId  = r["person_id"].as<long long>();
    t.live      = r["live"].as<bool>();
    t.used      = r["used"].as<bool>();
    t.firstName = str(r, "first_name");
    return t;
}

void FacilityLockup::markTokenUsed(long long tokenId) {
    db_->query("UPDATE facility_lockup_tokens SET used_at = now() WHERE id = $1::bigint", {std::to_string(tokenId)});
}

long long FacilityLockup::addPhoto(long long lockupId, long long personId, const std::string& urlPath,
                                   const std::string& mime, long long byteSize) {
    auto rows = db_->query(
        "INSERT INTO facility_lockup_photos (lockup_id, person_id, file_path, mime, byte_size) "
        "VALUES ($1::bigint, NULLIF($2, '0')::int, $3, $4, $5::int) RETURNING id",
        {std::to_string(lockupId), std::to_string(personId), urlPath, mime, std::to_string(byteSize)});
    confirm(lockupId, personId, "photo", "");
    return rows.empty() ? 0 : rows[0]["id"].as<long long>();
}

bool FacilityLockup::confirm(long long lockupId, long long personId, const std::string& via, const std::string& note) {
    auto rows = db_->query(
        "UPDATE facility_lockups SET confirmed_at = now(), confirmed_by_person_id = $2::int, "
        "       confirmed_via = $3, note = NULLIF($4, ''), updated_at = now() "
        " WHERE id = $1::bigint AND confirmed_at IS NULL RETURNING id",
        {std::to_string(lockupId), std::to_string(personId), via, note});
    return !rows.empty();
}

void FacilityLockup::markPrompted(long long id) {
    db_->query("UPDATE facility_lockups SET prompted_at = now(), updated_at = now() WHERE id = $1::bigint",
               {std::to_string(id)});
}

void FacilityLockup::bumpAlert(long long id) {
    db_->query("UPDATE facility_lockups SET alert_count = alert_count + 1, last_alert_at = now(), updated_at = now() "
               "WHERE id = $1::bigint", {std::to_string(id)});
}

void FacilityLockup::markAnnounced(long long id) {
    db_->query("UPDATE facility_lockups SET announced_at = now(), updated_at = now() WHERE id = $1::bigint",
               {std::to_string(id)});
}

void FacilityLockup::logAlert(long long lockupId, const std::string& stage, const std::string& channel,
                              long long personId, const std::string& contact, bool ok,
                              const std::string& providerSid, const std::string& error) {
    db_->query("INSERT INTO facility_lockup_alerts (lockup_id, stage, channel, person_id, contact, ok, provider_sid, error) "
               "VALUES ($1::bigint, $2, $3, NULLIF($4, '0')::int, $5, $6::boolean, NULLIF($7, ''), NULLIF($8, ''))",
               {std::to_string(lockupId), stage, channel, std::to_string(personId), contact,
                ok ? "true" : "false", providerSid, error});
}

bool FacilityLockup::isAdminUser(long long userId) {
    return !db_->query("SELECT 1 FROM admins WHERE user_id = $1::int LIMIT 1", {std::to_string(userId)}).empty();
}

long long FacilityLockup::personForUser(long long userId) {
    auto rows = db_->query("SELECT person_id FROM users WHERE id = $1::int", {std::to_string(userId)});
    if (rows.empty() || rows[0]["person_id"].is_null()) return 0;
    return rows[0]["person_id"].as<long long>();
}

bool FacilityLockup::canView(long long personId, bool isAdmin) {
    if (isAdmin) return true;
    if (personId <= 0) return false;
    auto rows = db_->query(
        "SELECT 1 FROM facility_lockup_people WHERE person_id = $1::int AND is_active "
        "UNION ALL "
        "SELECT 1 FROM coaches c JOIN team_coaches tc ON tc.coach_id = c.id AND tc.ended_at IS NULL "
        " WHERE c.person_id = $1::int LIMIT 1", {std::to_string(personId)});
    return !rows.empty();
}

json FacilityLockup::toJson(const Lockup& l) {
    json j = {
        {"id", l.id}, {"facility_id", l.facilityId}, {"facility", l.facility}, {"short_name", l.shortName},
        {"local_date", l.localDate}, {"date_label", l.dateLabel}, {"status", l.status()},
        {"last_event", l.lastEvent}, {"ends_label", l.endsLabel}, {"deadline_label", l.deadlineLabel},
        {"due_at", l.dueAtIso}, {"deadline_at", l.deadlineAtIso}, {"prompted_at", l.promptedAtIso},
        {"confirmed_at", l.confirmedAtIso}, {"confirmed_label", l.confirmedLabel},
        {"confirmed_by", l.confirmedBy}, {"confirmed_via", l.confirmedVia}, {"note", l.note},
        {"alert_count", l.alertCount}, {"max_alerts", l.maxAlerts}, {"repeat_minutes", l.repeatMinutes},
        {"last_alert_at", l.lastAlertAtIso},
    };
    j["alerts"] = l.id > 0 ? alertsJson(l.id) : json::array();
    j["photos"] = l.id > 0 ? photosJson(l.id) : json::array();
    return j;
}

json FacilityLockup::alertsJson(long long lockupId) {
    json out = json::array();
    auto rows = db_->query(
        "SELECT a.stage, a.channel, a.contact, a.ok, a.error, "
        "       to_char(a.sent_at, 'YYYY-MM-DD\"T\"HH24:MI:SSOF') AS sent_at, "
        "       COALESCE(p.first_name || ' ' || p.last_name, '') AS person "
        "  FROM facility_lockup_alerts a LEFT JOIN persons p ON p.id = a.person_id "
        " WHERE a.lockup_id = $1::bigint ORDER BY a.sent_at DESC, a.id DESC LIMIT 60",
        {std::to_string(lockupId)});
    for (const auto& r : rows) {
        out.push_back({{"stage", str(r, "stage")}, {"channel", str(r, "channel")}, {"contact", str(r, "contact")},
                       {"ok", r["ok"].as<bool>()}, {"error", str(r, "error")}, {"sent_at", str(r, "sent_at")},
                       {"person", str(r, "person")}});
    }
    return out;
}

json FacilityLockup::photosJson(long long lockupId) {
    json out = json::array();
    auto rows = db_->query(
        "SELECT ph.id, ph.file_path, to_char(ph.created_at, 'YYYY-MM-DD\"T\"HH24:MI:SSOF') AS created_at, "
        "       COALESCE(p.first_name || ' ' || p.last_name, '') AS person "
        "  FROM facility_lockup_photos ph LEFT JOIN persons p ON p.id = ph.person_id "
        " WHERE ph.lockup_id = $1::bigint ORDER BY ph.created_at DESC, ph.id DESC",
        {std::to_string(lockupId)});
    for (const auto& r : rows) {
        out.push_back({{"id", r["id"].as<long long>()}, {"url", str(r, "file_path")},
                       {"created_at", str(r, "created_at")}, {"person", str(r, "person")}});
    }
    return out;
}

json FacilityLockup::peopleJson() {
    json out = json::array();
    auto rows = db_->query(
        "SELECT f.short_name AS facility, lp.role, array_to_string(lp.channels, ', ') AS channels, "
        "       p.first_name || ' ' || p.last_name AS name, f.lockup_prompt_last_event_coaches AS coaches_too, "
        "       f.lockup_grace_minutes, f.lockup_repeat_minutes, f.lockup_max_alerts "
        "  FROM facility_lockup_people lp JOIN facilities f ON f.id = lp.facility_id "
        "  JOIN persons p ON p.id = lp.person_id "
        " WHERE lp.is_active AND f.is_active ORDER BY f.name, lp.role, name");
    for (const auto& r : rows) {
        out.push_back({{"facility", str(r, "facility")}, {"role", str(r, "role")}, {"channels", str(r, "channels")},
                       {"name", str(r, "name")}, {"coaches_too", r["coaches_too"].as<bool>()},
                       {"grace_minutes", r["lockup_grace_minutes"].as<int>()},
                       {"repeat_minutes", r["lockup_repeat_minutes"].as<int>()},
                       {"max_alerts", r["lockup_max_alerts"].as<int>()}});
    }
    return out;
}

FacilityLockup::Tokens FacilityLockup::tokens(const Lockup& l, const std::string& name,
                                              const std::string& link, int alertN) {
    return {
        {"name", name}, {"facility", l.facility}, {"date", l.dateLabel},
        {"last_event", l.lastEvent}, {"ends_at", l.endsLabel}, {"deadline", l.deadlineLabel},
        {"link", link}, {"alert_n", alertN > 0 ? std::to_string(alertN) : std::string()},
        {"confirmed_by", l.confirmedBy}, {"confirmed_at", l.confirmedLabel},
        {"repeat_minutes", std::to_string(l.repeatMinutes)},
    };
}
