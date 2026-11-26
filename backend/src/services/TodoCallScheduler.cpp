#include "TodoCallScheduler.h"

#include <chrono>
#include <iostream>
#include <thread>

#include "../database/Database.h"
#include "../models/MessageCopy.h"
#include "TwilioService.h"

namespace {
constexpr int kIntervalSeconds = 60;

std::string col(const pqxx::row& r, const char* name) {
    return r[name].is_null() ? std::string() : std::string(r[name].c_str());
}
}  // namespace

TodoCallScheduler& TodoCallScheduler::getInstance() {
    static TodoCallScheduler instance;
    return instance;
}

void TodoCallScheduler::start() {
    if (running_) return;
    running_ = true;
    std::thread(&TodoCallScheduler::loop, this).detach();
    std::cout << "📞 To-do call scheduler started (every " << kIntervalSeconds << "s)" << std::endl;
}

void TodoCallScheduler::loop() {
    std::this_thread::sleep_for(std::chrono::seconds(25));
    while (running_) {
        try {
            tick();
        } catch (const std::exception& e) {
            std::cerr << "[TodoCallScheduler] tick failed: " << e.what() << std::endl;
        }
        for (int i = 0; i < kIntervalSeconds && running_; ++i) std::this_thread::sleep_for(std::chrono::seconds(1));
    }
}

void TodoCallScheduler::tick() {
    auto* db = Database::getInstance();
    for (const auto& due : db->query(
             "SELECT d.person_todo_id, d.person_id, d.body, d.club_day, p.first_name, "
             "       (SELECT ph.phone_number FROM person_phones ph WHERE ph.person_id = d.person_id "
             "         ORDER BY ph.can_receive_calls DESC NULLS LAST, ph.is_primary DESC NULLS LAST, ph.id LIMIT 1) AS phone "
             "  FROM fh_todo_calls_due d JOIN persons p ON p.id = d.person_id")) {
        const std::string todoId = due["person_todo_id"].c_str();
        const std::string day = due["club_day"].c_str();
        const std::string phone = TwilioService::normalizeUs(col(due, "phone"));
        // Claim the day first: a slow Twilio call never rings twice.
        auto claimed = db->query(
            "INSERT INTO person_todo_calls (person_todo_id, club_day, contact) VALUES ($1::bigint, $2::date, NULLIF($3, '')) "
            "ON CONFLICT DO NOTHING RETURNING person_todo_id",
            {todoId, day, phone});
        if (claimed.empty()) continue;
        auto finish = [&](bool ok, const std::string& sid, const std::string& err) {
            db->query("UPDATE person_todo_calls SET ok = $3::boolean, twilio_sid = NULLIF($4, ''), error = NULLIF($5, '') "
                      " WHERE person_todo_id = $1::bigint AND club_day = $2::date",
                      {todoId, day, ok ? "true" : "false", sid, err});
        };
        if (phone.empty()) { finish(false, "", "no phone on file"); continue; }
        const auto say = MessageCopy().render("todo_call", "call", {{"first", col(due, "first_name")}, {"todo", col(due, "body")}});
        if (!say.ok()) { finish(false, "", "message_templates todo_call/call missing (mig 1944)"); continue; }
        auto r = TwilioService::getInstance().call(phone, say.body);
        finish(r.ok, r.sid, r.error);
        std::cout << "[TodoCallScheduler] to-do " << todoId << " (person " << col(due, "person_id") << "): "
                  << (r.ok ? "call placed" : "call failed: " + r.error) << std::endl;
    }
}
