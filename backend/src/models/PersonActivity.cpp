#include "PersonActivity.h"

#include <sstream>

#include "../database/Database.h"

PersonActivity::PersonActivity()
    : db_(Database::getInstance()) {}

namespace {

std::string idList(const std::vector<int>& ids) {
    std::ostringstream s;
    bool first = true;
    for (int id : ids) {
        if (id <= 0) continue;
        if (!first) s << ',';
        s << id;
        first = false;
    }
    return s.str();
}

std::string str(const pqxx::row& r, const char* col) {
    return r[col].is_null() ? std::string{} : std::string(r[col].c_str());
}

PersonActivity::EventRef refFrom(const pqxx::row& r, const char* prefix) {
    const std::string p(prefix);
    PersonActivity::EventRef e;
    e.status        = str(r, (p + "_status").c_str());
    e.atIso         = str(r, (p + "_at").c_str());
    e.eventKind     = str(r, (p + "_kind").c_str());
    e.eventStartIso = str(r, (p + "_start").c_str());
    e.opponent      = str(r, (p + "_opponent").c_str());
    return e;
}

} // namespace

PersonActivity::Map PersonActivity::latestFor(const std::vector<int>& personIds, int windowDays) {
    Map out;
    const std::string ids = idList(personIds);
    if (ids.empty()) return out;
    if (windowDays <= 0) windowDays = 30;

    // fh_events carries no start of its own (start_at is NULL on every
    // row; the time lives on the linked gcal_events.starts_at), so every
    // pass joins the calendar row.
    // Three DISTINCT ON passes (newest RSVP by responded_at, newest
    // present/late by event start, newest any-mark by event start) plus
    // the windowed tallies, stitched per person. Attendance only counts
    // events that have started — a coach can't have marked the future.
    std::ostringstream sql;
    sql << "WITH ppl AS (SELECT unnest(ARRAY[" << ids << "]::int[]) AS person_id), "
        << "iso AS (SELECT 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"'::text AS f), "
        << "last_rsvp AS ("
        << "  SELECT DISTINCT ON (r.person_id) r.person_id, r.response, r.responded_at, e.kind, ge.starts_at, e.opponent"
        << "    FROM fh_event_rsvps r JOIN fh_events e ON e.id = r.fh_event_id JOIN gcal_events ge ON ge.id = e.gcal_event_id"
        << "   WHERE r.person_id IN (SELECT person_id FROM ppl)"
        << "   ORDER BY r.person_id, r.responded_at DESC, r.id DESC), "
        << "last_att AS ("
        << "  SELECT DISTINCT ON (a.person_id) a.person_id, a.status, a.marked_at, e.kind, ge.starts_at, e.opponent"
        << "    FROM fh_event_attendance a JOIN fh_events e ON e.id = a.fh_event_id JOIN gcal_events ge ON ge.id = e.gcal_event_id"
        << "   WHERE a.person_id IN (SELECT person_id FROM ppl) AND a.status IN ('present','late') AND ge.starts_at <= now()"
        << "   ORDER BY a.person_id, ge.starts_at DESC, a.id DESC), "
        << "last_mark AS ("
        << "  SELECT DISTINCT ON (a.person_id) a.person_id, a.status, a.marked_at, e.kind, ge.starts_at, e.opponent"
        << "    FROM fh_event_attendance a JOIN fh_events e ON e.id = a.fh_event_id JOIN gcal_events ge ON ge.id = e.gcal_event_id"
        << "   WHERE a.person_id IN (SELECT person_id FROM ppl) AND ge.starts_at <= now()"
        << "   ORDER BY a.person_id, ge.starts_at DESC, a.id DESC), "
        << "rsvp_tally AS ("
        << "  SELECT r.person_id,"
        << "         COUNT(*) FILTER (WHERE r.response = 'yes' AND r.responded_at >= now() - make_interval(days => " << windowDays << ")) AS yes30,"
        << "         COUNT(*) FILTER (WHERE r.response = 'no'  AND r.responded_at >= now() - make_interval(days => " << windowDays << ")) AS no30,"
        << "         COUNT(*) AS total"
        << "    FROM fh_event_rsvps r WHERE r.person_id IN (SELECT person_id FROM ppl) GROUP BY r.person_id), "
        << "att_tally AS ("
        << "  SELECT a.person_id,"
        << "         COUNT(*) FILTER (WHERE a.status IN ('present','late') AND ge.starts_at >= now() - make_interval(days => " << windowDays << ")) AS att30,"
        << "         COUNT(*) FILTER (WHERE a.status = 'absent'             AND ge.starts_at >= now() - make_interval(days => " << windowDays << ")) AS abs30,"
        << "         COUNT(*) FILTER (WHERE a.status IN ('present','late')) AS total"
        << "    FROM fh_event_attendance a JOIN fh_events e ON e.id = a.fh_event_id JOIN gcal_events ge ON ge.id = e.gcal_event_id"
        << "   WHERE a.person_id IN (SELECT person_id FROM ppl) AND ge.starts_at <= now() GROUP BY a.person_id) "
        << "SELECT p.person_id,"
        << "  lr.response AS rsvp_status, TO_CHAR(lr.responded_at AT TIME ZONE 'UTC', (SELECT f FROM iso)) AS rsvp_at,"
        << "  lr.kind AS rsvp_kind, TO_CHAR(lr.starts_at AT TIME ZONE 'UTC', (SELECT f FROM iso)) AS rsvp_start, lr.opponent AS rsvp_opponent,"
        << "  la.status AS att_status, TO_CHAR(la.marked_at AT TIME ZONE 'UTC', (SELECT f FROM iso)) AS att_at,"
        << "  la.kind AS att_kind, TO_CHAR(la.starts_at AT TIME ZONE 'UTC', (SELECT f FROM iso)) AS att_start, la.opponent AS att_opponent,"
        << "  lm.status AS mark_status, TO_CHAR(lm.marked_at AT TIME ZONE 'UTC', (SELECT f FROM iso)) AS mark_at,"
        << "  lm.kind AS mark_kind, TO_CHAR(lm.starts_at AT TIME ZONE 'UTC', (SELECT f FROM iso)) AS mark_start, lm.opponent AS mark_opponent,"
        << "  COALESCE(rt.yes30,0) AS yes30, COALESCE(rt.no30,0) AS no30, COALESCE(rt.total,0) AS rsvp_total,"
        << "  COALESCE(at.att30,0) AS att30, COALESCE(at.abs30,0) AS abs30, COALESCE(at.total,0) AS att_total"
        << " FROM ppl p"
        << " LEFT JOIN last_rsvp  lr ON lr.person_id = p.person_id"
        << " LEFT JOIN last_att   la ON la.person_id = p.person_id"
        << " LEFT JOIN last_mark  lm ON lm.person_id = p.person_id"
        << " LEFT JOIN rsvp_tally rt ON rt.person_id = p.person_id"
        << " LEFT JOIN att_tally  at ON at.person_id = p.person_id"
        << " WHERE lr.person_id IS NOT NULL OR lm.person_id IS NOT NULL";

    const auto rows = db_->query(sql.str());
    for (const auto& r : rows) {
        if (r["person_id"].is_null()) continue;
        Summary& s = out[r["person_id"].as<int>()];
        s.lastRsvp      = refFrom(r, "rsvp");
        s.lastAttended  = refFrom(r, "att");
        s.lastMarked    = refFrom(r, "mark");
        s.rsvpYes30     = r["yes30"].as<int>();
        s.rsvpNo30      = r["no30"].as<int>();
        s.rsvpTotal     = r["rsvp_total"].as<int>();
        s.attended30    = r["att30"].as<int>();
        s.absent30      = r["abs30"].as<int>();
        s.attendedTotal = r["att_total"].as<int>();
    }
    return out;
}
