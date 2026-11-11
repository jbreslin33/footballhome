#include "AttendanceCallScheduler.h"

#include <chrono>
#include <iostream>
#include <thread>

#include "../database/Database.h"
#include "../models/MessageCopy.h"
#include "MagicLinkService.h"
#include "TwilioService.h"

namespace {
constexpr int kIntervalSeconds = 60;

std::string col(const pqxx::row& r, const char* name) {
    return r[name].is_null() ? std::string() : std::string(r[name].c_str());
}

// "U10 / U12 5:30 PM" — the practice's teams (emoji dropped) + start time.
const char* kPracticeLabelSql = R"SQL(
  SELECT COALESCE((SELECT string_agg(DISTINCT regexp_replace(COALESCE(NULLIF(t.label, ''), t.name), '^[^[:alnum:]]+', ''), ' / ')
                     FROM fh_event_teams et JOIN teams t ON t.id = et.team_id WHERE et.fh_event_id = e.id),
                  initcap(e.category))
         || ' ' || replace(to_char(g.starts_at AT TIME ZONE 'America/New_York', 'FMHH12:MI AM'), ':00', '') AS label
    FROM fh_events e JOIN gcal_events g ON g.id = e.gcal_event_id
   WHERE e.id = $1::bigint)SQL";
}  // namespace

AttendanceCallScheduler& AttendanceCallScheduler::getInstance() {
    static AttendanceCallScheduler instance;
    return instance;
}

void AttendanceCallScheduler::start() {
    if (running_) return;
    running_ = true;
    std::thread(&AttendanceCallScheduler::loop, this).detach();
    std::cout << "📞 Practice attendance-call scheduler started (every " << kIntervalSeconds << "s)" << std::endl;
}

void AttendanceCallScheduler::loop() {
    std::this_thread::sleep_for(std::chrono::seconds(20));
    while (running_) {
        try {
            tick();
        } catch (const std::exception& e) {
            std::cerr << "[AttendanceCallScheduler] tick failed: " << e.what() << std::endl;
        }
        for (int i = 0; i < kIntervalSeconds && running_; ++i) std::this_thread::sleep_for(std::chrono::seconds(1));
    }
}

void AttendanceCallScheduler::tick() {
    auto* db = Database::getInstance();
    for (const auto& due : db->query("SELECT id, live, test_person_id, send_text, unmarked, rounds FROM fh_attendance_calls_due")) {
        const std::string eventId = due["id"].c_str();
        const bool live = due["live"].as<bool>();
        const bool sendText = due["send_text"].as<bool>();
        const int unmarked = due["unmarked"].as<int>();
        const int round = due["rounds"].as<int>() + 1;
        // Claim the round first: a slow Twilio call can never double-fire
        // on the next tick, and a second backend can't take it too.
        auto claimed = db->query(
            "INSERT INTO attendance_call_rounds (fh_event_id, round, unmarked, live) "
            "VALUES ($1::bigint, $2::int, $3::int, $4::boolean) ON CONFLICT DO NOTHING RETURNING round",
            {eventId, std::to_string(round), std::to_string(unmarked), live ? "true" : "false"});
        if (claimed.empty()) continue;

        auto lbl = db->query(kPracticeLabelSql, {eventId});
        const std::string practice = lbl.empty() ? std::string("practice") : col(lbl[0], "label");
        auto namesRow = db->query(
            "SELECT string_agg(BTRIM(COALESCE(p.first_name, '') || ' ' || COALESCE(p.last_name, '')), ', ' "
            "                  ORDER BY p.last_name, p.first_name) AS names "
            "  FROM fh_attendance_call_going($1::bigint) x JOIN persons p ON p.id = x.person_id "
            " WHERE x.is_player AND NOT x.marked", {eventId});
        const std::string names = namesRow.empty() ? std::string() : col(namesRow[0], "names");

        // Who rings: the Going coaches, or (test mode) the test person.
        const std::string who = live
            ? "SELECT x.person_id FROM fh_attendance_call_going($1::bigint) x WHERE x.is_coach"
            : "SELECT $1::int AS person_id";
        const std::string testId = due["test_person_id"].is_null() ? std::string() : std::string(due["test_person_id"].c_str());
        if (!live && testId.empty()) continue;
        auto people = db->query(
            "WITH ppl AS (" + who + ") "
            "SELECT p.id AS person_id, p.first_name, "
            "       (SELECT ph.phone_number FROM person_phones ph WHERE ph.person_id = p.id "
            "         ORDER BY ph.is_primary DESC NULLS LAST, ph.can_receive_sms DESC NULLS LAST, ph.id LIMIT 1) AS phone "
            "  FROM ppl JOIN persons p ON p.id = ppl.person_id",
            {live ? eventId : testId});

        int sent = 0;
        for (const auto& to : people) {
            const std::string personId = to["person_id"].c_str();
            const std::string first = col(to, "first_name");
            const std::string phone = TwilioService::normalizeUs(col(to, "phone"));
            auto log = [&](const char* channel, bool ok, const std::string& sid, const std::string& err) {
                db->query("INSERT INTO attendance_call_log (fh_event_id, round, person_id, channel, contact, ok, twilio_sid, error) "
                          "VALUES ($1::bigint, $2::int, $3::int, $4, NULLIF($5, ''), $6::boolean, NULLIF($7, ''), NULLIF($8, ''))",
                          {eventId, std::to_string(round), personId, channel, phone, ok ? "true" : "false", sid, err});
            };
            if (phone.empty()) { log("call", false, "", "no phone on file"); continue; }

            MessageCopy::Tokens tokens = {{"first", first}, {"practice", practice}, {"n", std::to_string(unmarked)},
                                          {"names", names}, {"round", std::to_string(round)}};
            const auto say = MessageCopy().render("attendance_call", "call", tokens);
            if (!say.ok()) { log("call", false, "", "message_templates attendance_call/call missing (mig 1277)"); continue; }
            auto r = TwilioService::getInstance().call(phone, say.body);
            log("call", r.ok, r.sid, r.error);
            sent += r.ok;

            if (round == 1 && sendText) {
                std::string link;
                try {
                    link = MagicLinkService::mint(std::stoll(personId), "sms", phone, 0, 0, 0,
                                                  "event/" + eventId + "/players").url;
                } catch (const std::exception& e) {
                    std::cerr << "[AttendanceCallScheduler] magic link failed: " << e.what() << std::endl;
                    link = MagicLinkService::publicBaseUrl() + "/#event/" + eventId + "/players";
                }
                tokens.push_back({"link", link});
                const auto txt = MessageCopy().render("attendance_call", "sms", tokens);
                if (txt.ok()) {
                    auto s = TwilioService::getInstance().sendSms(phone, txt.body, "attendance_call");
                    log("sms", s.ok, s.sid, s.error);
                } else {
                    log("sms", false, "", "message_templates attendance_call/sms missing (mig 1277)");
                }
            }
        }
        std::cout << "[AttendanceCallScheduler] " << practice << " (event " << eventId << ") round " << round
                  << (live ? "" : " TEST") << ": " << unmarked << " unmarked, " << sent << " call(s) placed" << std::endl;
    }
}
