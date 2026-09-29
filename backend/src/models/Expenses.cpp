#include "Expenses.h"

#include <algorithm>
#include <cmath>
#include <ctime>
#include <map>
#include <set>

#include "../database/Database.h"

// Membership counts (kits × members) are read only behind laGet( routes —
// FinancesController /summary syncs the programs, and /expenses follows it
// on the same page load (LA → DB → render).

using nlohmann::json;

namespace {

std::string str(const pqxx::row& r, const char* c) { return r[c].is_null() ? std::string{} : std::string(r[c].c_str()); }
double num(const pqxx::row& r, const char* c) { return r[c].is_null() ? 0.0 : r[c].as<double>(); }
double round2(double v) { return std::round(v * 100.0) / 100.0; }

// YYYY-MM arithmetic.
std::string monthOf(const std::string& ymd) { return ymd.size() >= 7 ? ymd.substr(0, 7) : ymd; }
int monthIndex(const std::string& ym) { return std::stoi(ym.substr(0, 4)) * 12 + std::stoi(ym.substr(5, 2)) - 1; }
std::string monthAt(int idx) { char b[8]; std::snprintf(b, sizeof b, "%04d-%02d", idx / 12, idx % 12 + 1); return b; }

// Every home game a policy pays for — one query, both sources.
const char* kGamesSql = R"SQL(
    WITH pol AS (
        SELECT * FROM ref_fee_policies WHERE club_id = $1::int AND is_active
    ), fx AS (
        SELECT p.id AS policy_id, 'fixture'::text AS source, f.id::bigint AS ref_id, NULL::bigint AS fh_event_id, f.id AS league_fixture_id,
               f.starts_at, f.away_name AS opponent, f.status
          FROM pol p
          JOIN league_fixture_sources s ON s.league_label = p.fixture_league_label AND s.is_active
          JOIN league_fixtures f ON f.source_id = s.id AND f.removed_at IS NULL AND f.status <> 'cancelled'
         WHERE p.fixture_league_label IS NOT NULL
           AND (f.home_club_id = $1::int OR (NOT p.home_only AND f.away_club_id = $1::int))
    ), ev AS (
        SELECT p.id, 'event'::text, e.id::bigint, e.id, NULL::int,
               g.starts_at, COALESCE(NULLIF(e.opponent, ''), g.summary), 'scheduled'::text
          FROM pol p
          JOIN fh_events e ON e.kind = 'match' AND (p.event_category IS NULL OR e.category = p.event_category)
                          AND e.league = ANY (p.event_league_labels)
          JOIN gcal_events g ON g.id = e.gcal_event_id AND g.deleted_at IS NULL
         WHERE p.fixture_league_label IS NULL
           AND (NOT p.home_only OR COALESCE(e.is_home, false))
           AND (p.age_band IS NULL OR g.summary ~* ('\m' || p.age_band || '\M'))
    ), games AS (SELECT * FROM fx UNION ALL SELECT * FROM ev)
    SELECT u.policy_id, p.label AS policy_label, p.club_section_id, p.per_game_usd, u.source, u.ref_id, u.status,
           to_char(u.starts_at AT TIME ZONE 'America/New_York', 'YYYY-MM-DD') AS game_on,
           to_char(u.starts_at AT TIME ZONE 'America/New_York', 'Dy Mon FMDD') AS date_label,
           u.opponent, (u.starts_at < now() AND u.status <> 'postponed') AS played,
           pay.id AS payment_id, pay.invoice_line_id, pay.amount_usd AS paid_amount,
           i.id AS invoice_id, (i.invoice_year || '.' || i.invoice_number) AS invoice_label
      FROM games u
      JOIN ref_fee_policies p ON p.id = u.policy_id
      LEFT JOIN ref_fee_payments pay ON (u.source = 'fixture' AND pay.league_fixture_id = u.league_fixture_id)
                                     OR (u.source = 'event'   AND pay.fh_event_id = u.fh_event_id)
      LEFT JOIN invoice_lines il ON il.id = pay.invoice_line_id
      LEFT JOIN invoices i ON i.id = il.invoice_id
     ORDER BY u.starts_at, p.sort_order, u.ref_id)SQL";

json gameJson(const pqxx::row& r) {
    json g = {{"policy_id", r["policy_id"].as<long long>()}, {"policy_label", str(r, "policy_label")},
              {"section_id", r["club_section_id"].is_null() ? json(nullptr) : json(r["club_section_id"].as<long long>())},
              {"source", str(r, "source")}, {"ref_id", r["ref_id"].as<long long>()}, {"status", str(r, "status")},
              {"game_on", str(r, "game_on")}, {"date_label", str(r, "date_label")}, {"opponent", str(r, "opponent")},
              {"amount", num(r, "per_game_usd")}, {"played", r["played"].as<bool>()}, {"invoiced", nullptr}};
    if (!r["payment_id"].is_null())
        g["invoiced"] = {{"line_id", r["invoice_line_id"].as<long long>()}, {"amount", num(r, "paid_amount")},
                         {"invoice_id", r["invoice_id"].is_null() ? json(nullptr) : json(r["invoice_id"].as<long long>())},
                         {"invoice_label", str(r, "invoice_label")}};
    return g;
}

} // namespace

json Expenses::games(int clubId) {
    json out = json::array();
    for (const auto& r : Database::getInstance()->query(kGamesSql, {std::to_string(clubId)})) out.push_back(gameJson(r));
    return out;
}

json Expenses::projection(int clubId) {
    auto* db = Database::getInstance();
    const std::string club = std::to_string(clubId);
    const std::string today = db->query("SELECT to_char(now() AT TIME ZONE 'America/New_York', 'YYYY-MM-DD') AS d")[0]["d"].c_str();
    const int nowIdx = monthIndex(monthOf(today));

    // by_month accumulators: policy/line id → month → {projected, invoiced}
    struct Cell { double projected = 0, invoiced = 0; };
    using Months = std::map<std::string, Cell>;
    // Forward only (owner: "only worried about future expenses from this
    // date forward"): a projection for a month already gone lands in this
    // month — it is still to be paid.  Invoiced amounts keep their month.
    auto add = [&](Months& m, const std::string& ym, double proj, double inv) {
        const std::string pm = monthIndex(ym) < nowIdx ? monthAt(nowIdx) : ym;
        m[pm].projected += proj; m[ym].invoiced += inv; };
    int minIdx = nowIdx, maxIdx = nowIdx;
    auto widen = [&](const std::string& ym) { int i = monthIndex(ym); maxIdx = std::max(maxIdx, i); };

    json out = {{"today", today}, {"ref_fees", json::array()}, {"budget", json::array()}, {"sections", json::array()}, {"all", json::object()}};
    std::map<long long, Months> bySection; std::map<long long, std::string> sectionName; Months all;
    for (const auto& r : db->query("SELECT id, name FROM club_sections ORDER BY sort_order, id")) sectionName[r["id"].as<long long>()] = str(r, "name");
    auto roll = [&](long long sectionId, const Months& m) { for (const auto& [ym, c] : m) { add(bySection[sectionId], ym, c.projected, c.invoiced); add(all, ym, c.projected, c.invoiced); } };
    auto monthsJson = [&](const Months& m) { json j = json::object(); for (const auto& [ym, c] : m) j[ym] = {{"projected", round2(c.projected)}, {"invoiced", round2(c.invoiced)}}; return j; };
    auto totals = [&](const Months& m) { double p = 0, i = 0; for (const auto& [ym, c] : m) { p += c.projected; i += c.invoiced; } return json{{"projected", round2(p)}, {"invoiced", round2(i)}}; };

    // ── referee fees ──
    std::map<long long, std::vector<json>> gamesByPolicy;
    for (const auto& r : db->query(kGamesSql, {club})) gamesByPolicy[r["policy_id"].as<long long>()].push_back(gameJson(r));
    for (const auto& p : db->query("SELECT id, label, group_label, club_section_id, per_game_usd, home_only, note FROM ref_fee_policies WHERE club_id = $1::int AND is_active ORDER BY sort_order, id", {club})) {
        const long long pid = p["id"].as<long long>(); const double rate = num(p, "per_game_usd");
        const long long sectionId = p["club_section_id"].is_null() ? 0 : p["club_section_id"].as<long long>();
        Months m; json seasons = json::array();
        const auto& games = gamesByPolicy[pid];
        std::set<std::string> counted;   // game keys placed by a season
        for (const auto& s : db->query("SELECT id, label, starts_on::text AS s, ends_on::text AS e, home_games_expected, is_assumed FROM ref_fee_seasons WHERE policy_id = $1::int ORDER BY starts_on", {std::to_string(pid)})) {
            const std::string from = str(s, "s"), to = str(s, "e"); const int expected = s["home_games_expected"].as<int>();
            int known = 0; std::string lastKnownMonth;
            for (const auto& g : games) {
                const std::string on = g["game_on"].get<std::string>();
                if (on < from || on > to) continue;
                known++; counted.insert(g["source"].get<std::string>() + ":" + std::to_string(g["ref_id"].get<long long>()));
                const std::string ym = monthOf(on); widen(ym);
                if (g["invoiced"].is_null()) add(m, ym, rate, 0); else add(m, ym, 0, g["invoiced"]["amount"].get<double>());
                if (ym > lastKnownMonth) lastKnownMonth = ym;
            }
            const int remainder = std::max(0, expected - known);
            const int endIdx = monthIndex(monthOf(to)); widen(monthOf(from)); widen(monthOf(to));
            int startIdx = std::max(nowIdx, lastKnownMonth.empty() ? monthIndex(monthOf(from)) : monthIndex(lastKnownMonth) + 1);
            if (startIdx > endIdx) startIdx = std::max(nowIdx, endIdx);   // season over or nearly: whatever is left lands now / at the end
            const int n = std::max(1, endIdx - startIdx + 1);
            for (int k = 0; k < remainder; k++) add(m, monthAt(startIdx + (k % n)), rate, 0);   // one game at a time round the months
            seasons.push_back({{"id", s["id"].as<long long>()}, {"label", str(s, "label")}, {"starts_on", from}, {"ends_on", to},
                               {"expected", expected}, {"known", known}, {"remainder", remainder}, {"is_assumed", s["is_assumed"].as<bool>()}});
        }
        // Games outside every season window still count where they fall.
        for (const auto& g : games) {
            if (counted.count(g["source"].get<std::string>() + ":" + std::to_string(g["ref_id"].get<long long>()))) continue;
            const std::string ym = monthOf(g["game_on"].get<std::string>()); widen(ym);
            if (g["invoiced"].is_null()) add(m, ym, rate, 0); else add(m, ym, 0, g["invoiced"]["amount"].get<double>());
        }
        roll(sectionId, m);
        out["ref_fees"].push_back({{"policy_id", pid}, {"label", str(p, "label")}, {"group_label", str(p, "group_label")}, {"section_id", sectionId ? json(sectionId) : json(nullptr)},
                                   {"section", sectionName.count(sectionId) ? sectionName[sectionId] : ""}, {"rate", rate}, {"home_only", p["home_only"].as<bool>()},
                                   {"note", str(p, "note")}, {"seasons", seasons}, {"games", games.size()}, {"by_month", monthsJson(m)}, {"totals", totals(m)}});
    }

    // ── budget lines ──
    for (const auto& b : db->query(R"SQL(
        SELECT b.id, b.label, b.group_label, c.label AS category_label, b.category, b.club_section_id, b.amount_usd, b.amount_per, b.paid_before_usd,
               b.period_start::text AS ps, b.period_end::text AS pe, b.spread, b.is_assumed, b.note,
               CASE WHEN b.amount_per = 'member' THEN (
                   SELECT COUNT(DISTINCT m.person_id) FROM person_la_memberships m
                     JOIN leagueapps_programs lp ON lp.program_id = m.la_program_id
                     JOIN club_sections s ON s.id = b.club_section_id
                    WHERE m.ended_at IS NULL AND lp.variant = 'active'
                      AND lp.category = CASE s.code WHEN 'M' THEN 'men' WHEN 'W' THEN 'women' WHEN 'B' THEN 'boys' WHEN 'G' THEN 'girls' END)
                    -- per week (mig 491): the weeks still ahead in the period, forward only
                    WHEN b.amount_per = 'week' THEN GREATEST(0, CEIL((b.period_end - GREATEST(b.period_start, (now() AT TIME ZONE 'America/New_York')::date) + 1) / 7.0))::int
               ELSE 1 END AS units
          FROM budget_lines b JOIN invoice_line_categories c ON c.code = b.category
         WHERE b.club_id = $1::int AND b.is_active
         ORDER BY b.sort_order, b.id)SQL", {club})) {
        const long long bid = b["id"].as<long long>(); const long long units = b["units"].as<long long>();
        const double total = round2(num(b, "amount_usd") * units);
        const long long sectionId = b["club_section_id"].is_null() ? 0 : b["club_section_id"].as<long long>();
        Months m; double invoiced = 0; json lines = json::array();
        for (const auto& l : db->query(R"SQL(
            SELECT l.id, l.amount, l.description, i.id AS invoice_id, (i.invoice_year || '.' || i.invoice_number) AS invoice_label, i.invoice_date::text AS on_date
              FROM invoice_lines l JOIN invoices i ON i.id = l.invoice_id
              LEFT JOIN invoice_installment_plans p ON p.id = l.plan_id
             WHERE COALESCE(l.budget_line_id, p.budget_line_id) = $1::int
             ORDER BY i.invoice_date, l.id)SQL", {std::to_string(bid)})) {
            const double amt = num(l, "amount"); invoiced += amt;
            const std::string ym = monthOf(str(l, "on_date")); widen(ym); add(m, ym, 0, amt);
            lines.push_back({{"line_id", l["id"].as<long long>()}, {"amount", amt}, {"description", str(l, "description")},
                             {"invoice_id", l["invoice_id"].as<long long>()}, {"invoice_label", str(l, "invoice_label")}, {"on", str(l, "on_date")}});
        }
        const double paidBefore = num(b, "paid_before_usd");
        const double remaining = std::max(0.0, round2(total - paidBefore - invoiced));
        const std::string ps = str(b, "ps"), pe = str(b, "pe"); widen(monthOf(pe));
        if (remaining > 0) {
            const int startIdx = std::max(nowIdx, monthIndex(monthOf(ps))), endIdx = std::max(startIdx, monthIndex(monthOf(pe)));
            if (str(b, "spread") == "even") {
                const int n = endIdx - startIdx + 1; const double per = round2(remaining / n);
                for (int i = startIdx; i <= endIdx; i++) add(m, monthAt(i), i == endIdx ? round2(remaining - per * (n - 1)) : per, 0);
            } else add(m, monthAt(startIdx), remaining, 0);
        }
        roll(sectionId, m);
        out["budget"].push_back({{"id", bid}, {"label", str(b, "label")}, {"group_label", str(b, "group_label")}, {"category", str(b, "category")}, {"category_label", str(b, "category_label")},
                                 {"section_id", sectionId ? json(sectionId) : json(nullptr)}, {"section", sectionName.count(sectionId) ? sectionName[sectionId] : ""},
                                 {"amount", num(b, "amount_usd")}, {"amount_per", str(b, "amount_per")}, {"units", units}, {"total", total},
                                 {"paid_before", paidBefore}, {"invoiced", round2(invoiced)}, {"remaining", remaining}, {"period_start", ps}, {"period_end", pe},
                                 {"spread", str(b, "spread")}, {"is_assumed", b["is_assumed"].as<bool>()}, {"note", str(b, "note")},
                                 {"lines", lines}, {"by_month", monthsJson(m)}, {"totals", totals(m)}});
    }

    json months = json::array(); for (int i = minIdx; i <= maxIdx; i++) months.push_back(monthAt(i));
    out["months"] = months;
    for (const auto& [sid, name] : sectionName) {
        const Months& m = bySection[sid];
        out["sections"].push_back({{"section_id", sid}, {"name", name}, {"by_month", monthsJson(m)}, {"totals", totals(m)}});
    }
    if (bySection.count(0)) out["sections"].push_back({{"section_id", nullptr}, {"name", "Club"}, {"by_month", monthsJson(bySection[0])}, {"totals", totals(bySection[0])}});
    out["all"] = {{"by_month", monthsJson(all)}, {"totals", totals(all)}};
    return out;
}

json Expenses::openBudgetLines(int clubId) {
    json out = json::array();
    for (const auto& b : Database::getInstance()->query(R"SQL(
        SELECT b.id, b.label, b.category, s.name AS section, b.period_start::text AS ps, b.period_end::text AS pe, b.amount_per, b.amount_usd, b.paid_before_usd,
               CASE WHEN b.amount_per = 'member' THEN (
                   SELECT COUNT(DISTINCT m.person_id) FROM person_la_memberships m
                     JOIN leagueapps_programs lp ON lp.program_id = m.la_program_id
                    WHERE m.ended_at IS NULL AND lp.variant = 'active'
                      AND lp.category = CASE s.code WHEN 'M' THEN 'men' WHEN 'W' THEN 'women' WHEN 'B' THEN 'boys' WHEN 'G' THEN 'girls' END)
                    WHEN b.amount_per = 'week' THEN GREATEST(0, CEIL((b.period_end - GREATEST(b.period_start, (now() AT TIME ZONE 'America/New_York')::date) + 1) / 7.0))::int
               ELSE 1 END AS units,
               COALESCE((SELECT SUM(l.amount) FROM invoice_lines l LEFT JOIN invoice_installment_plans p ON p.id = l.plan_id
                          WHERE COALESCE(l.budget_line_id, p.budget_line_id) = b.id), 0) AS invoiced
          FROM budget_lines b LEFT JOIN club_sections s ON s.id = b.club_section_id
         WHERE b.club_id = $1::int AND b.is_active
         ORDER BY b.period_end < CURRENT_DATE, b.sort_order, b.id)SQL", {std::to_string(clubId)})) {
        const double total = round2(num(b, "amount_usd") * b["units"].as<long long>());
        out.push_back({{"id", b["id"].as<long long>()}, {"label", str(b, "label")}, {"category", str(b, "category")}, {"section", str(b, "section")},
                       {"period_start", str(b, "ps")}, {"period_end", str(b, "pe")}, {"total", total}, {"paid_before", num(b, "paid_before_usd")},
                       {"invoiced", round2(num(b, "invoiced"))},
                       {"remaining", std::max(0.0, round2(total - num(b, "paid_before_usd") - num(b, "invoiced")))}});
    }
    return out;
}

json Expenses::refLineFor(int clubId, const json& picks) {
    json items = json::array(); double amount = 0; std::string desc;
    std::set<std::string> wanted;
    if (picks.is_array()) for (const auto& p : picks) if (p.is_object() && p.contains("source") && p.contains("ref_id") && p["ref_id"].is_number())
        wanted.insert(p["source"].get<std::string>() + ":" + std::to_string(p["ref_id"].get<long long>()));
    for (const auto& r : Database::getInstance()->query(kGamesSql, {std::to_string(clubId)})) {
        const std::string key = str(r, "source") + ":" + std::string(r["ref_id"].c_str());
        if (!wanted.count(key) || !r["payment_id"].is_null()) continue;
        json g = gameJson(r);
        items.push_back({{"policy_id", g["policy_id"]}, {"source", g["source"]}, {"ref_id", g["ref_id"]}, {"game_on", g["game_on"]}, {"opponent", g["opponent"]}, {"amount", g["amount"]}});
        amount += g["amount"].get<double>();
        // "APSL 9/13 Feelsgood FC, Liga 1 9/27 Desert Hawks FC, U8 10/11 Fishtown"
        const std::string on = g["game_on"].get<std::string>();
        std::string label = g["policy_label"].get<std::string>(); auto sp = label.rfind(' '); if (label.rfind("Parks & Rec ", 0) == 0) label = label.substr(12);
        desc += (desc.empty() ? "" : ", ") + label + " " + std::to_string(std::stoi(on.substr(5, 2))) + "/" + std::to_string(std::stoi(on.substr(8, 2))) + " " + g["opponent"].get<std::string>();
    }
    return {{"description", desc}, {"quantity", (long long)items.size()}, {"amount", round2(amount)}, {"items", items}};
}

void Expenses::recordRefPayments(long long invoiceLineId, const json& items) {
    auto* db = Database::getInstance();
    for (const auto& it : items) {
        const bool fixture = it["source"].get<std::string>() == "fixture";
        db->query("INSERT INTO ref_fee_payments (policy_id, invoice_line_id, fh_event_id, league_fixture_id, game_on, opponent, amount_usd) "
                  "VALUES ($1::int, $2::int, NULLIF($3,'')::bigint, NULLIF($4,'')::int, $5::date, $6, $7::numeric) ON CONFLICT DO NOTHING",
                  {std::to_string(it["policy_id"].get<long long>()), std::to_string(invoiceLineId),
                   fixture ? std::string() : std::to_string(it["ref_id"].get<long long>()), fixture ? std::to_string(it["ref_id"].get<long long>()) : std::string(),
                   it["game_on"].get<std::string>(), it["opponent"].get<std::string>(), std::to_string(it["amount"].get<double>())});
    }
}
