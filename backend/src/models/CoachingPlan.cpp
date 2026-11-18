#include "CoachingPlan.h"

#include <cmath>
#include <map>
#include <stdexcept>

#include "../database/Database.h"

using nlohmann::json;

namespace {
double round2(double v) { return std::round(v * 100.0) / 100.0; }

// $1 = budget year id, $2 = club id.  One row per item (see CoachingPlan.h).
const char* kItemsSql = R"SQL(
WITH y AS (SELECT id, starts_on, ends_on FROM budget_years WHERE id = $1),
days AS (SELECT d::date AS day, extract(isodow FROM d)::int AS dow, extract(month FROM d)::int AS mo FROM y, generate_series(y.starts_on, y.ends_on, interval '1 day') d),
occ AS (SELECT bs.id AS season_id, bs.code, bs.sort_order, days.dow, count(*)::int AS n
          FROM days JOIN budget_seasons bs ON bs.club_id = $2
           AND CASE WHEN bs.from_month <= bs.to_month THEN days.mo BETWEEN bs.from_month AND bs.to_month ELSE days.mo >= bs.from_month OR days.mo <= bs.to_month END
         GROUP BY 1, 2, 3, 4),
slot AS (SELECT s.*, ARRAY(SELECT sp.program_id FROM practice_slot_programs sp WHERE sp.slot_id = s.id ORDER BY 1) AS programs
           FROM practice_slots s WHERE s.budget_year_id = $1 AND s.is_active),
brk AS (SELECT s.id AS slot_id, o.season_id,
               COALESCE((SELECT max(b.weeks_off) FROM practice_season_breaks b JOIN finance_programs fp ON fp.kind = b.program_kind
                          WHERE b.budget_year_id = $1 AND b.season_id = o.season_id AND fp.id = ANY (s.programs)), 0) AS weeks_off
          FROM slot s JOIN occ o ON o.dow = s.weekday),
first AS (SELECT DISTINCT ON (c.issuer_id, s.weekday) c.issuer_id, s.weekday, s.id AS slot_id
            FROM slot s JOIN practice_slot_coaches c ON c.slot_id = s.id ORDER BY c.issuer_id, s.weekday, s.start_time)
SELECT 'practice' AS kind, c.issuer_id, o.code AS season, o.sort_order, s.label, GREATEST(0, o.n - b.weeks_off) AS times, s.minutes / 60.0 AS each_h,
       ii.hourly_rate AS rate, s.programs
  FROM slot s JOIN practice_slot_coaches c ON c.slot_id = s.id JOIN invoice_issuers ii ON ii.id = c.issuer_id
  JOIN occ o ON o.dow = s.weekday JOIN brk b ON b.slot_id = s.id AND b.season_id = o.season_id
UNION ALL
SELECT 'arrival', f.issuer_id, o.code, o.sort_order, s.label, GREATEST(0, o.n - b.weeks_off), r.minutes / 60.0, ii.hourly_rate, s.programs
  FROM first f JOIN slot s ON s.id = f.slot_id JOIN invoice_issuers ii ON ii.id = f.issuer_id
  JOIN occ o ON o.dow = f.weekday JOIN brk b ON b.slot_id = s.id AND b.season_id = o.season_id
  JOIN coach_arrival_rules r ON r.issuer_id = f.issuer_id AND r.budget_year_id = $1 AND r.season_id = o.season_id AND r.minutes > 0
UNION ALL
SELECT 'game', p.coach_issuer_id, bs.code, bs.sort_order, p.label, rs.home_games_expected, p.hours_per_game, COALESCE(p.rate_per_hour, ii.hourly_rate),
       ARRAY(SELECT DISTINCT fpt.program_id FROM finance_program_teams fpt WHERE fpt.team_id = p.team_id ORDER BY 1)
  FROM ref_fee_policies p JOIN invoice_issuers ii ON ii.id = p.coach_issuer_id
  JOIN ref_fee_seasons rs ON rs.policy_id = p.id AND rs.home_games_expected > 0
  JOIN y ON rs.starts_on BETWEEN y.starts_on AND y.ends_on
  JOIN budget_seasons bs ON bs.club_id = $2
   AND CASE WHEN bs.from_month <= bs.to_month THEN extract(month FROM rs.starts_on) BETWEEN bs.from_month AND bs.to_month
            ELSE extract(month FROM rs.starts_on) >= bs.from_month OR extract(month FROM rs.starts_on) <= bs.to_month END
 WHERE p.kind = 'coaching' AND p.is_active ORDER BY 2, 4, 1, 5)SQL";
}  // namespace

CoachingPlan::CoachingPlan(int clubId, const std::string& budgetYear) : clubId_(clubId) {
    auto* db = Database::getInstance();
    const auto y = budgetYear.empty()
        ? db->query("SELECT id, label FROM budget_years WHERE CURRENT_DATE BETWEEN starts_on AND ends_on ORDER BY starts_on LIMIT 1")
        : db->query("SELECT id, label FROM budget_years WHERE label = $1", {budgetYear});
    if (y.empty()) throw std::invalid_argument("No such budget year.");
    yearId_ = y[0]["id"].as<int>();
    year_ = y[0]["label"].c_str();

    for (const auto& s : db->query("SELECT code, label FROM budget_seasons WHERE club_id = $1::int ORDER BY sort_order", {std::to_string(clubId_)}))
        seasons_.emplace_back(s["code"].c_str(), s["label"].c_str());

    std::map<long long, std::string> names;
    for (const auto& n : db->query("SELECT ii.id, COALESCE(NULLIF(BTRIM(p.first_name || ' ' || p.last_name), ''), ii.payable_to) AS name "
                                   "  FROM invoice_issuers ii LEFT JOIN persons p ON p.id = ii.person_id"))
        names[n["id"].as<long long>()] = n["name"].c_str();

    for (const auto& r : db->query(kItemsSql, {std::to_string(yearId_), std::to_string(clubId_)})) {
        Item it;
        it.issuerId = r["issuer_id"].as<long long>();
        it.coach = names[it.issuerId];
        it.kind = r["kind"].c_str();
        it.season = r["season"].c_str();
        it.label = r["label"].c_str();
        it.times = r["times"].as<int>();
        it.hoursEach = r["each_h"].as<double>();
        it.rate = r["rate"].is_null() ? 0.0 : r["rate"].as<double>();
        const std::string arr = r["programs"].c_str();   // {1,2,3}
        std::string cur;
        for (char ch : arr) {
            if (ch >= '0' && ch <= '9') cur += ch;
            else if (!cur.empty()) { it.programs.push_back(std::stoi(cur)); cur.clear(); }
        }
        if (it.times > 0) items_.push_back(std::move(it));
    }
}

json CoachingPlan::toJson() const {
    json out = {{"year", year_}, {"seasons", json::array()}, {"coaches", json::array()}, {"items", json::array()}};
    for (const auto& [code, label] : seasons_) out["seasons"].push_back({{"code", code}, {"label", label}});

    std::vector<long long> order;
    std::map<long long, json> coaches;
    for (const auto& it : items_) {
        if (!coaches.count(it.issuerId)) {
            order.push_back(it.issuerId);
            json bs = json::object();
            for (const auto& s : seasons_) bs[s.first] = {{"practice", 0.0}, {"arrival", 0.0}, {"game", 0.0}, {"hours", 0.0}, {"amount", 0.0}};
            coaches[it.issuerId] = {{"issuer_id", it.issuerId}, {"name", it.coach}, {"rate", it.rate}, {"by_season", bs}, {"hours", 0.0}, {"amount", 0.0}};
        }
        json& c = coaches[it.issuerId];
        json& s = c["by_season"][it.season];
        s[it.kind] = round2(s[it.kind].get<double>() + it.hours());
        s["hours"] = round2(s["hours"].get<double>() + it.hours());
        s["amount"] = round2(s["amount"].get<double>() + it.amount());
        c["hours"] = round2(c["hours"].get<double>() + it.hours());
        c["amount"] = round2(c["amount"].get<double>() + it.amount());
        out["items"].push_back({{"issuer_id", it.issuerId}, {"coach", it.coach}, {"kind", it.kind}, {"season", it.season}, {"label", it.label},
                                {"times", it.times}, {"hours_each", round2(it.hoursEach)}, {"hours", round2(it.hours())},
                                {"rate", it.rate}, {"amount", round2(it.amount())}, {"programs", it.programs}});
    }
    for (long long id : order) out["coaches"].push_back(coaches[id]);
    return out;
}
