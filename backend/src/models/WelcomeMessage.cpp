#include "WelcomeMessage.h"

#include "../database/Database.h"

namespace {

void replaceAll(std::string& s, const std::string& from, const std::string& to) {
    if (from.empty()) return;
    for (size_t pos = 0; (pos = s.find(from, pos)) != std::string::npos; pos += to.size())
        s.replace(pos, from.size(), to);
}

// A block that rendered as nothing leaves its blank lines behind; fold
// runs of 3+ newlines back to one paragraph break and trim the ends.
std::string tidy(std::string s) {
    for (size_t pos; (pos = s.find("\n\n\n")) != std::string::npos; ) s.erase(pos, 1);
    while (!s.empty() && (s.back() == '\n' || s.back() == ' ')) s.pop_back();
    size_t lead = 0;
    while (lead < s.size() && s[lead] == '\n') ++lead;
    return s.substr(lead);
}

// $1 = player person id, $2 = club id (release policy when on no team).
//
// tm        the player's live teams, each with its released-window end —
//           the same visibility rule #my applies.
// ev        every labelled event for those teams over the next four
//           weeks; `released` = inside the window for at least one team.
// upcoming  the released ones, one player-facing line each (kind label +
//           opponent, never the gcal title).
// slot/pat  the usual week: a (kind, weekday[, time]) that repeats at
//           least twice in those four weeks, days folded per time.
// rel       when the first still-closed week opens for their section.
constexpr const char* kFactsSql = R"SQL(
WITH tm AS (
  SELECT DISTINCT t.id, t.club_id, t.club_section_id,
         fh_schedule_window_end(t.club_id, t.club_section_id, now()) AS window_end
    FROM team_persons tp
    JOIN teams t ON t.id = tp.team_id
   WHERE tp.person_id = $1::int AND tp.removed_at IS NULL AND t.is_active
     AND NOT EXISTS (SELECT 1 FROM rsvp_suspensions s
                      WHERE s.person_id = tp.person_id
                        AND (s.team_id IS NULL OR s.team_id = tp.team_id)
                        AND s.starts_at <= now()
                        AND (s.ends_at IS NULL OR s.ends_at > now()))
), ev AS (
  SELECT fe.id, k.player_label, k.weekly_pattern, fe.opponent, fe.is_home,
         ge.starts_at,
         (ge.starts_at AT TIME ZONE 'America/New_York') AS local_start,
         bool_or(ge.starts_at <= tm.window_end) AS released
    FROM tm
    JOIN fh_event_teams fet ON fet.team_id = tm.id
    JOIN fh_events fe ON fe.id = fet.fh_event_id
    JOIN fh_event_kind_labels k ON k.kind = fe.kind
    JOIN gcal_events ge ON ge.id = fe.gcal_event_id
   WHERE ge.deleted_at IS NULL AND ge.status IS DISTINCT FROM 'cancelled'
     AND ge.ends_at > now() AND ge.starts_at < now() + interval '28 days'
   GROUP BY fe.id, k.player_label, k.weekly_pattern, fe.opponent, fe.is_home, ge.starts_at
), upcoming AS (
  SELECT string_agg('• ' || to_char(local_start, 'Dy Mon FMDD, FMHH12:MI AM') || ' — ' || player_label
                    || COALESCE(CASE WHEN is_home IS FALSE THEN ' @ ' ELSE ' vs ' END
                                || NULLIF(BTRIM(opponent), ''), ''),
                    E'\n' ORDER BY starts_at, id) AS txt
    FROM ev WHERE released
), slot AS (
  SELECT player_label, weekly_pattern,
         extract(isodow FROM local_start)::int AS isodow,
         to_char(local_start, 'Dy') AS dow,
         CASE WHEN weekly_pattern = 'time' THEN to_char(local_start, 'FMHH12:MI AM') END AS at,
         min(local_start::time) AS at_sort
    FROM ev WHERE weekly_pattern <> 'none'
   GROUP BY 1, 2, 3, 4, 5
  HAVING count(*) >= 2
), pat AS (
  SELECT '• ' || player_label || ' — ' || string_agg(dow, ', ' ORDER BY isodow)
             || COALESCE(' ' || at, '') AS line,
         (weekly_pattern = 'day') AS late, min(isodow) AS d, min(at_sort) AS t
    FROM slot GROUP BY player_label, weekly_pattern, at
), rel AS (
  SELECT fh_schedule_week_opens_at(x.club_id, x.club_section_id,
           ((x.window_end + interval '1 millisecond') AT TIME ZONE 'America/New_York')::date) AS opens
    FROM (SELECT club_id, club_section_id, window_end FROM tm
          UNION ALL
          SELECT $2::int, NULL::int, fh_schedule_window_end($2::int, NULL, now())
           WHERE NOT EXISTS (SELECT 1 FROM tm)
          ORDER BY window_end LIMIT 1) x
)
SELECT EXISTS (SELECT 1 FROM tm) AS on_team,
       COALESCE((SELECT txt FROM upcoming), '') AS events,
       COALESCE((SELECT string_agg(line, E'\n' ORDER BY late, d, t) FROM pat), '') AS schedule,
       COALESCE((SELECT to_char(opens AT TIME ZONE 'America/New_York', 'FMDay') FROM rel), '') AS release_day,
       COALESCE((SELECT to_char(opens AT TIME ZONE 'America/New_York', 'FMHH12:MI AM') FROM rel), '') AS release_time
)SQL";

}  // namespace

WelcomeMessage::WelcomeMessage()
    : db_(Database::getInstance()) {}

WelcomeMessage::Facts WelcomeMessage::factsFor(long long playerPersonId, int clubId) {
    Facts f;
    auto rows = db_->query(kFactsSql, {std::to_string(playerPersonId), std::to_string(clubId)});
    if (rows.empty()) return f;
    f.onTeam      = rows[0]["on_team"].as<bool>();
    f.events      = rows[0]["events"].c_str();
    f.schedule    = rows[0]["schedule"].c_str();
    f.releaseDay  = rows[0]["release_day"].c_str();
    f.releaseTime = rows[0]["release_time"].c_str();
    return f;
}

WelcomeMessage::TemplateMap WelcomeMessage::loadTemplates(const std::string& tier) {
    TemplateMap out;
    auto rows = db_->query(
        "SELECT kind, COALESCE(subject,'') AS subject, body FROM message_templates "
        " WHERE kind LIKE 'welcome%' AND tier = $1 AND is_active "
        " ORDER BY sort_order, id",
        {tier});
    for (const auto& row : rows) {
        // First active row per kind wins (sort_order, id).
        out.emplace(row["kind"].c_str(), Template{row["subject"].c_str(), row["body"].c_str()});
    }
    return out;
}

std::string WelcomeMessage::fillFormLinks(const std::string& text, int clubId) {
    if (text.find("{form:") == std::string::npos) return text;
    auto rows = db_->query("SELECT fh_fill_form_links($1::text, $2::int) AS txt",
                           {text, std::to_string(clubId)});
    return rows.empty() || rows[0]["txt"].is_null() ? text : std::string(rows[0]["txt"].c_str());
}

WelcomeMessage::Rendered WelcomeMessage::render(const std::string& channel, bool youth, int clubId,
                                                const Facts& facts, const Tokens& tokens) {
    const auto tpls = loadTemplates(youth ? "parent" : "adult");
    auto bodyOf = [&](const std::string& kind) {
        auto it = tpls.find(kind);
        return it == tpls.end() ? std::string{} : it->second.body;
    };

    const auto skeleton = tpls.find(channel == "email" ? "welcome" : "welcome_sms");
    if (skeleton == tpls.end()) return {};

    const std::string eventsBlock = !facts.onTeam         ? bodyOf("welcome_no_team")
                                  : !facts.events.empty() ? bodyOf("welcome_events")
                                                          : bodyOf("welcome_no_events");
    const std::string scheduleBlock = !facts.onTeam            ? std::string{}
                                    : !facts.schedule.empty()  ? bodyOf("welcome_schedule")
                                                               : bodyOf("welcome_no_schedule");
    // An unresolved {form:…} means the form row is gone — skip the ask.
    std::string docsBlock = tokens.docsAsk ? fillFormLinks(bodyOf("welcome_docs"), clubId) : std::string{};
    if (docsBlock.find("{form:") != std::string::npos) docsBlock.clear();

    auto fill = [&](std::string text) {
        // Blocks first — they carry tokens of their own.
        replaceAll(text, "{events_block}",   eventsBlock);
        replaceAll(text, "{schedule_block}", scheduleBlock);
        replaceAll(text, "{docs_block}",     docsBlock);
        replaceAll(text, "{events}",         facts.events);
        replaceAll(text, "{schedule}",       facts.schedule);
        replaceAll(text, "{release_day}",    facts.releaseDay);
        replaceAll(text, "{release_time}",   facts.releaseTime);
        replaceAll(text, "{first}",          tokens.first);
        replaceAll(text, "{child}",          tokens.child);
        replaceAll(text, "{sender}",         tokens.sender);
        replaceAll(text, "{link}",           tokens.link);
        return tidy(fillFormLinks(text, clubId));
    };

    return {fill(skeleton->second.subject), fill(skeleton->second.body)};
}
