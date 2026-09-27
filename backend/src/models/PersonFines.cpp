#include "PersonFines.h"

#include <cmath>
#include <cstdlib>
#include <sstream>

#include "../database/Database.h"

using nlohmann::json;

PersonFines::PersonFines()
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

json strOrNull(const pqxx::row& r, const char* col) {
    return r[col].is_null() ? json(nullptr) : json(std::string(r[col].c_str()));
}

} // namespace

PersonFines::Map PersonFines::monthsFor(const std::vector<int>& personIds, int monthsBack) {
    Map out;
    const std::string ids = idList(personIds);
    if (ids.empty()) return out;
    if (monthsBack <= 0) monthsBack = 3;
    const std::string back = std::to_string(monthsBack - 1);

    // Who is fineable, and since when: on an active team in a section with
    // a fine policy in force today.  `since` is the earliest such policy,
    // so the month boxes never reach back before fines existed.
    std::ostringstream who;
    who << "SELECT tp.person_id, min(fp.effective_from)::text AS since, min(t.club_id) AS club_id"
        << "  FROM team_persons tp"
        << "  JOIN teams t ON t.id = tp.team_id AND t.is_active AND t.club_section_id IS NOT NULL"
        << "  JOIN fine_policies fp ON fp.club_id = t.club_id"
        << "   AND (fp.club_section_id IS NULL OR fp.club_section_id = t.club_section_id)"
        << "   AND fp.effective_from <= CURRENT_DATE"
        << " WHERE tp.removed_at IS NULL AND tp.person_id IN (" << ids << ")"
        << " GROUP BY tp.person_id";
    auto whoRows = db_->query(who.str());
    if (whoRows.empty()) return out;

    // The month boxes: this month and the (monthsBack − 1) before it, club
    // time, oldest first.
    std::ostringstream months;
    months << "SELECT to_char(d, 'YYYY-MM') AS ym, to_char(d, 'Mon') AS label,"
           << "       to_char(d, 'YYYY-MM-DD') AS first_day,"
           << "       to_char(first_friday_of_month(d::timestamptz), 'YYYY-MM-DD') AS first_friday,"
           << "       to_char(d + interval '1 month', 'YYYY-MM') AS post_ym,"
           << "       to_char(d + interval '1 month', 'Mon') AS post_label,"
           << "       to_char(first_friday_of_month((d + interval '1 month')::timestamptz), 'YYYY-MM-DD') AS post_first_friday,"
           << "       to_char(now() AT TIME ZONE 'America/New_York', 'YYYY-MM-DD') AS today"
           << "  FROM generate_series("
           << "         date_trunc('month', (now() AT TIME ZONE 'America/New_York')::date)::date - interval '" << back << " months',"
           << "         date_trunc('month', (now() AT TIME ZONE 'America/New_York')::date)::date,"
           << "         interval '1 month') d ORDER BY d";
    auto monthRows = db_->query(months.str());

    // Every fine since the first shown month, oldest first, with its label.
    std::ostringstream fines;
    fines << "SELECT f.person_id, f.fh_event_id, f.event_kind, f.opponent, f.fine_kind, k.label,"
          << "       f.amount_usd::text AS amount, f.response, f.attendance,"
          << "       to_char(f.starts_at AT TIME ZONE 'America/New_York', 'YYYY-MM') AS ym,"
          << "       to_char(f.starts_at AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS\"Z\"') AS start_iso"
          << "  FROM fh_person_fines(ARRAY[" << ids << "]::int[],"
          << "         ((date_trunc('month', (now() AT TIME ZONE 'America/New_York')::date)::date"
          << "            - interval '" << back << " months')::timestamp AT TIME ZONE 'America/New_York')) f"
          << "  JOIN fine_kinds k ON k.code = f.fine_kind"
          << " ORDER BY f.person_id, f.starts_at";
    auto fineRows = db_->query(fines.str());

    // Every LeagueApps charge since the first shown month (person_payments
    // txn_type 'Charge' — each charge the owner adds in LA is its own row,
    // amount and day, no description).  Owner 2026-09-27: "you should be
    // able to detect what a charge is for by amount and timing ... when i
    // add 35 due to a player around the 1st friday you know its dues.
    // when i add a 2nd amount around that time it should match the fines."
    std::ostringstream charges;
    charges << "SELECT p.id AS person_id, pp.amount::text AS amount,"
            << "       to_char(pp.paid_at AT TIME ZONE 'America/New_York', 'YYYY-MM') AS ym,"
            << "       to_char(pp.paid_at AT TIME ZONE 'America/New_York', 'YYYY-MM-DD') AS day"
            << "  FROM person_payments pp"
            << "  JOIN persons p ON p.la_user_id::bigint = pp.la_user_id::bigint"
            << " WHERE pp.txn_type = 'Charge' AND p.id IN (" << ids << ")"
            << "   AND pp.paid_at >= ((date_trunc('month', (now() AT TIME ZONE 'America/New_York')::date)::date"
            << "         - interval '" << back << " months')::timestamp AT TIME ZONE 'America/New_York')"
            << " ORDER BY p.id, pp.paid_at";
    auto chargeRows = db_->query(charges.str());
    struct Charge { double amount; std::string day; bool used = false; };
    std::unordered_map<int, std::unordered_map<std::string, std::vector<Charge>>> chargesBy;   // person → ym → charges
    for (const auto& r : chargeRows) {
        chargesBy[r["person_id"].as<int>()][r["ym"].c_str()].push_back(
            Charge{std::atof(r["amount"].c_str()), r["day"].c_str()});
    }

    // Monthly dues rate per club (dues_policies) — the charge that means "dues".
    std::unordered_map<int, double> rateByClub;
    for (const auto& w : whoRows) {
        const int club = w["club_id"].as<int>();
        if (rateByClub.count(club)) continue;
        auto rr = db_->query("SELECT fh_monthly_dues_usd(" + std::to_string(club) + ")::text AS r");
        rateByClub[club] = (rr.empty() || rr[0]["r"].is_null()) ? 0.0 : std::atof(rr[0]["r"].c_str());
    }
    auto same = [](double a, double b) { return std::fabs(a - b) < 0.005; };

    // person → ym → items
    std::unordered_map<int, std::unordered_map<std::string, json>> byPerson;
    std::unordered_map<int, std::unordered_map<std::string, double>> totals;
    for (const auto& r : fineRows) {
        const int pid = r["person_id"].as<int>();
        const std::string ym = r["ym"].c_str();
        const double amount = std::atof(r["amount"].c_str());
        auto& items = byPerson[pid][ym];
        if (!items.is_array()) items = json::array();
        items.push_back({
            {"fhEventId",  r["fh_event_id"].as<long long>()},
            {"startAt",    r["start_iso"].c_str()},
            {"eventKind",  r["event_kind"].c_str()},
            {"opponent",   strOrNull(r, "opponent")},
            {"kind",       r["fine_kind"].c_str()},
            {"label",      r["label"].c_str()},
            {"amount",     amount},
            {"response",   strOrNull(r, "response")},
            {"attendance", strOrNull(r, "attendance")},
        });
        totals[pid][ym] += amount;
    }

    const std::string currentYm = monthRows.empty() ? std::string{} : std::string(monthRows.back()["ym"].c_str());
    const std::string today     = monthRows.empty() ? std::string{} : std::string(monthRows.back()["today"].c_str());
    for (const auto& w : whoRows) {
        const int pid = w["person_id"].as<int>();
        const std::string since = w["since"].c_str();          // YYYY-MM-DD
        const std::string sinceYm = since.substr(0, 7);
        const double rate = rateByClub[w["club_id"].as<int>()];
        auto& myCharges = chargesBy[pid];

        // The dues charge of a month: the first charge equal to the rate.
        // Claimed first so a $35 fine total can never be mistaken for it.
        auto duesChargeIn = [&](const std::string& ym) -> Charge* {
            auto it = myCharges.find(ym);
            if (it == myCharges.end()) return nullptr;
            for (auto& c : it->second) if (!c.used && same(c.amount, rate)) { c.used = true; return &c; }
            return nullptr;
        };
        std::unordered_map<std::string, Charge*> duesByYm;
        auto duesFor = [&](const std::string& ym) -> Charge* {
            auto f = duesByYm.find(ym);
            if (f != duesByYm.end()) return f->second;
            Charge* c = duesChargeIn(ym);
            duesByYm[ym] = c;
            return c;
        };
        for (const auto& m : monthRows) { duesFor(m["ym"].c_str()); duesFor(m["post_ym"].c_str()); }

        json monthsJson = json::array();
        double total = 0;
        for (const auto& m : monthRows) {
            const std::string ym = m["ym"].c_str();
            if (ym < sinceYm) continue;                           // before fines existed
            const double t = totals[pid].count(ym) ? totals[pid][ym] : 0.0;
            json items = byPerson[pid].count(ym) ? byPerson[pid][ym] : json::array();

            // Posting: the month's fines go on LA with the NEXT month's dues
            // (first Friday).  posted = a charge that month equal to the
            // fine total (or to dues + fines in one); drift = a charge is
            // there but the total has since moved; not_posted = the first
            // Friday has passed with nothing; due = not yet time; nothing =
            // no fines to post.
            const std::string postYm = m["post_ym"].c_str();
            const std::string postFri = m["post_first_friday"].c_str();
            json posting = {{"month", postYm}, {"label", m["post_label"].c_str()}, {"firstFriday", postFri},
                            {"status", "nothing"}, {"postedAmount", nullptr}, {"postedOn", nullptr}};
            if (t > 0.005) {
                Charge* hit = nullptr;
                Charge* near = nullptr;
                auto it = myCharges.find(postYm);
                if (it != myCharges.end()) {
                    for (auto& c : it->second) {
                        if (c.used) continue;
                        if (same(c.amount, t) || same(c.amount, rate + t)) { hit = &c; break; }
                        if (!near || std::fabs(c.amount - t) < std::fabs(near->amount - t)) near = &c;
                    }
                }
                if (hit) {
                    hit->used = true;
                    posting["status"] = "posted";
                    posting["postedAmount"] = same(hit->amount, t) ? t : hit->amount - rate;
                    posting["postedOn"] = hit->day;
                } else if (near && today >= postFri) {
                    near->used = true;
                    posting["status"] = "drift";
                    posting["postedAmount"] = near->amount;
                    posting["postedOn"] = near->day;
                } else if (today >= postFri) {
                    posting["status"] = "not_posted";
                } else {
                    posting["status"] = "due";
                }
            }

            monthsJson.push_back({
                {"month",   ym},
                {"label",   m["label"].c_str()},
                {"current", ym == currentYm},
                {"total",   t},
                {"items",   std::move(items)},
                {"posting", std::move(posting)},
            });
            total += t;
        }

        // This month's dues: posted when a charge equal to the rate exists
        // this month; not_posted once its first Friday has passed; due before.
        json dues = nullptr;
        if (!monthRows.empty() && rate > 0) {
            const auto& cur = monthRows.back();
            const std::string curFri = cur["first_friday"].c_str();
            Charge* d = duesFor(currentYm);
            dues = {{"month", currentYm}, {"label", cur["label"].c_str()}, {"rate", rate}, {"firstFriday", curFri},
                    {"status", d ? "posted" : (today >= curFri ? "not_posted" : "due")},
                    {"postedOn", d ? json(d->day) : json(nullptr)}};
        }

        out[pid] = json{{"since", since}, {"total", total}, {"months", std::move(monthsJson)}, {"dues", std::move(dues)}};
    }
    return out;
}

json PersonFines::rulesFor(int personId) {
    json rules = json::array();
    if (personId <= 0) return rules;
    auto rows = db_->query(
        "SELECT DISTINCT ON (k.sort_order) k.code, k.label, r.amount::text AS amount"
        "  FROM fine_kinds k"
        "  JOIN LATERAL ("
        "    SELECT fh_fine_amount_usd(t.club_id, t.club_section_id, k.code, CURRENT_DATE) AS amount"
        "      FROM team_persons tp JOIN teams t ON t.id = tp.team_id AND t.is_active"
        "     WHERE tp.person_id = $1::int AND tp.removed_at IS NULL AND t.club_section_id IS NOT NULL"
        "     ORDER BY amount DESC NULLS LAST LIMIT 1) r ON true"
        " WHERE r.amount IS NOT NULL AND r.amount > 0"
        " ORDER BY k.sort_order",
        {std::to_string(personId)});
    for (const auto& r : rows) {
        rules.push_back({{"kind", r["code"].c_str()}, {"label", r["label"].c_str()},
                         {"amount", std::atof(r["amount"].c_str())}});
    }
    return rules;
}
