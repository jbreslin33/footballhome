#pragma once
#include <string>
#include "../models/FacilityLockup.h"

// ────────────────────────────────────────────────────────────────────────────
// LockupScheduler — the nightly "was the gate locked?" clock (migration
// 421, owner 2026-09-24).  One detached thread, every 60 s:
//
//   1. FacilityLockup::syncToday()  — tonight's last event per facility
//   2. due_at reached, nobody asked  → prompt the closers (tap link)
//   3. deadline passed, unconfirmed  → alert the escalation people
//                                      (email / text / call), repeating on
//                                      the facility's cadence up to its cap
//   4. confirmed after alerts began  → all-clear to the same people
//
// Same lifetime convention as LaSyncScheduler (runs until process exit).
// deliver() is static so LockupController's "test to me" button sends
// exactly what the scheduler would.
// ────────────────────────────────────────────────────────────────────────────
class LockupScheduler {
public:
    static LockupScheduler& getInstance();
    void start();

    struct Outcome {
        bool        ok = false;
        std::string contact;   // where it went (email address / E.164)
        std::string error;     // why not
    };

    // stage: prompt | alert | confirmed | test   channel: email | sms | call
    // Renders message_templates kind='lockup' tier=<stage>_<channel>
    // ('test' uses the alert copy), mints the tap link, sends, logs.
    static Outcome deliver(FacilityLockup& model, const FacilityLockup::Lockup& lockup,
                           const FacilityLockup::Recipient& to, const std::string& stage,
                           const std::string& channel, int alertN);

private:
    LockupScheduler() = default;
    ~LockupScheduler() = default;
    LockupScheduler(const LockupScheduler&) = delete;
    LockupScheduler& operator=(const LockupScheduler&) = delete;

    void loop();
    void tick();
    bool running_ = false;
};
