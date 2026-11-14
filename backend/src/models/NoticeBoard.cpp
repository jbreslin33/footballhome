#include "NoticeBoard.h"
#include "VolunteerShifts.h"
#include "WelcomeLog.h"
#include "../database/Database.h"

#include <iostream>

using json = nlohmann::json;

json DuesStanding::toJson() const {
    return {
        {"is_self",     isSelf},
        {"first_name",  firstName},
        {"balance",     balance},
        {"line",        line},
        {"eligible",    eligible},
        {"min_payment", minPayment},
        {"blocks",      blocks},
        {"over_line",   overLine},
        {"alternate",   alternate},
        {"pay_url",     payUrl},
    };
}

std::vector<DuesStanding> DuesStanding::forPersonAndKids(Database* db, long long personId) {
    std::vector<DuesStanding> out;
    if (personId <= 0) return out;
    pqxx::result dr = db->query(R"SQL(
        SELECT p.id, COALESCE(p.first_name, '') AS first_name,
               fh_dues_balance_usd(p.id)               AS balance,
               fh_dues_line_usd($2::int)               AS line,
               fh_dues_eligible(p.id, $2::int)         AS eligible,
               fh_dues_min_payment_usd(p.id, $2::int)  AS min_payment,
               fh_dues_blocks_eligibility(p.id, $2::int) AS blocks,
               fh_dues_over_line(p.id, $2::int)         AS over_line,
               fh_dues_alternate(p.id, $2::int)          AS alternate,
               fh_fill_form_links('{form:la_dashboard}', $2::int) AS pay_url
          FROM persons p
         WHERE p.id = $1::int OR fh_is_guardian($1::int, p.id)
         ORDER BY (p.id = $1::int) DESC, p.first_name
    )SQL", {std::to_string(personId), std::to_string(WelcomeLog::kLighthouseClubId)});
    for (const auto& r : dr) {
        DuesStanding s;
        s.personId   = r["id"].as<long long>();
        s.isSelf     = s.personId == personId;
        s.firstName  = r["first_name"].c_str();
        s.balance    = r["balance"].is_null()     ? 0.0 : r["balance"].as<double>();
        s.line       = r["line"].is_null()        ? json(nullptr) : json(r["line"].as<double>());
        s.eligible   = r["eligible"].is_null()    ? true : r["eligible"].as<bool>();
        s.minPayment = r["min_payment"].is_null() ? 0.0 : r["min_payment"].as<double>();
        s.blocks     = !r["blocks"].is_null()    && r["blocks"].as<bool>();
        s.overLine   = !r["over_line"].is_null() && r["over_line"].as<bool>();
        s.alternate  = !r["alternate"].is_null() && r["alternate"].as<bool>();
        s.payUrl     = r["pay_url"].is_null()     ? "" : r["pay_url"].c_str();
        out.push_back(std::move(s));
    }
    return out;
}

json DuesNotice::toJson() const {
    json j = s_.toJson();
    j["kind"] = kind();
    j["person_id"] = s_.personId;
    // Which banner: ⛔ blocked, 💰 alternate, ⚠️ over the line (my_dues tiers).
    j["tier"] = !s_.eligible ? "banner" : s_.alternate ? "alternate_banner" : "warning";
    return j;
}

json VolunteerShiftNotice::toJson() const {
    json j = mine_;
    j["kind"] = kind();
    return j;
}

std::vector<std::unique_ptr<Notice>> NoticeBoard::collect(Database* db, long long personId) {
    std::vector<std::unique_ptr<Notice>> out;
    if (personId <= 0) return out;
    // One kind failing never costs the viewer the others.
    try {
        for (auto& s : DuesStanding::forPersonAndKids(db, personId))
            if (s.needsNotice()) out.push_back(std::make_unique<DuesNotice>(std::move(s)));
    } catch (const std::exception& e) {
        std::cerr << "[NoticeBoard] dues: " << e.what() << std::endl;
    }
    try {
        json mine = VolunteerShifts::mine(personId);
        const bool offer = mine.value("offer", false);
        if (offer || !mine["pick"].is_null())
            out.push_back(std::make_unique<VolunteerShiftNotice>(std::move(mine)));
    } catch (const std::exception& e) {
        std::cerr << "[NoticeBoard] volunteer: " << e.what() << std::endl;
    }
    return out;
}

json NoticeBoard::toJson(const std::vector<std::unique_ptr<Notice>>& notices) {
    json arr = json::array();
    for (const auto& n : notices) arr.push_back(n->toJson());
    return arr;
}
