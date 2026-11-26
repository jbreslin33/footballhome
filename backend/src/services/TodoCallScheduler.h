#pragma once

// ────────────────────────────────────────────────────────────────────────────
// TodoCallScheduler — 📞 the daily to-do call (mig 1944; owner 2026-11-26:
// "for luke breslin todo. streting every day. call if he has not uploaded
// photo of him starting streting routine uploaded 1pm every day").
//
// Every minute: each item in fh_todo_calls_due (daily, photo_proof, past its
// call_at club time inside a 2 h window, given before today's call time, no
// photo today, not rung today, todo_call_policy.is_on) gets ONE phone call to
// the person's phone.  The person_todo_calls row is claimed first (one per
// item per club day), then updated with Twilio's answer.  Wording:
// message_templates kind=todo_call tier=call ({first}, {todo}).
// ────────────────────────────────────────────────────────────────────────────
class TodoCallScheduler {
public:
    static TodoCallScheduler& getInstance();
    void start();

private:
    TodoCallScheduler() = default;
    TodoCallScheduler(const TodoCallScheduler&) = delete;
    TodoCallScheduler& operator=(const TodoCallScheduler&) = delete;

    void loop();
    void tick();
    bool running_ = false;
};
