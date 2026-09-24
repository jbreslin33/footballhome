#include "LockupScheduler.h"

#include <chrono>
#include <iostream>
#include <thread>

#include "../core/Mail.h"
#include "../models/MessageCopy.h"
#include "MagicLinkService.h"
#include "TwilioService.h"

namespace {
constexpr int kIntervalSeconds = 60;

std::string tapLink(FacilityLockup& model, const FacilityLockup::Lockup& l, long long personId) {
    return MagicLinkService::publicBaseUrl() + "/api/security/tap?t=" + model.issueToken(l.id, personId);
}
}  // namespace

LockupScheduler& LockupScheduler::getInstance() {
    static LockupScheduler instance;
    return instance;
}

void LockupScheduler::start() {
    if (running_) return;
    running_ = true;
    std::thread(&LockupScheduler::loop, this).detach();
    std::cout << "⏰ Facility lock-up scheduler started (every " << kIntervalSeconds << "s)" << std::endl;
}

void LockupScheduler::loop() {
    // Let the DB pool settle before the first pass.
    std::this_thread::sleep_for(std::chrono::seconds(15));
    while (running_) {
        try {
            tick();
        } catch (const std::exception& e) {
            std::cerr << "[LockupScheduler] tick failed: " << e.what() << std::endl;
        }
        for (int i = 0; i < kIntervalSeconds && running_; ++i) {
            std::this_thread::sleep_for(std::chrono::seconds(1));
        }
    }
}

void LockupScheduler::tick() {
    FacilityLockup model;
    model.syncToday();

    for (const auto& l : model.pendingPrompts()) {
        int sent = 0;
        for (const auto& to : model.recipients(l.id, "closer")) {
            if (to.wantEmail) sent += deliver(model, l, to, "prompt", "email", 0).ok;
            if (to.wantSms)   sent += deliver(model, l, to, "prompt", "sms", 0).ok;
        }
        model.markPrompted(l.id);
        std::cout << "[LockupScheduler] prompted closers for " << l.facility << " " << l.localDate
                  << " (" << sent << " sent)" << std::endl;
    }

    for (const auto& l : model.pendingAlerts()) {
        const int n = l.alertCount + 1;
        // Bump first so a slow Twilio call can never double-fire on the next tick.
        model.bumpAlert(l.id);
        // Email and text carry the upload link — with the first alert only;
        // the phone rings on every alert until a photo is up (owner
        // 2026-09-24: "keep calling my phone every 5 minutes").
        int sent = 0;
        for (const auto& to : model.recipients(l.id, "escalation")) {
            if (to.wantEmail && n == 1) sent += deliver(model, l, to, "alert", "email", n).ok;
            if (to.wantSms   && n == 1) sent += deliver(model, l, to, "alert", "sms", n).ok;
            if (to.wantCall)            sent += deliver(model, l, to, "alert", "call", n).ok;
        }
        std::cout << "[LockupScheduler] alert " << n << " for " << l.facility << " " << l.localDate
                  << " (" << sent << " sent)" << std::endl;
    }

    for (const auto& l : model.pendingAnnouncements()) {
        model.markAnnounced(l.id);
        for (const auto& to : model.recipients(l.id, "escalation")) {
            if (to.wantEmail) deliver(model, l, to, "confirmed", "email", 0);
            if (to.wantSms)   deliver(model, l, to, "confirmed", "sms", 0);
        }
        std::cout << "[LockupScheduler] all-clear for " << l.facility << " " << l.localDate << std::endl;
    }
}

LockupScheduler::Outcome LockupScheduler::deliver(FacilityLockup& model, const FacilityLockup::Lockup& l,
                                                  const FacilityLockup::Recipient& to,
                                                  const std::string& stage, const std::string& channel,
                                                  int alertN) {
    Outcome out;
    const std::string tier = (stage == "test" ? "alert" : stage) + "_" + channel;
    if (channel == "email") out.contact = to.email;
    else out.contact = TwilioService::normalizeUs(to.phone);
    if (out.contact.empty()) {
        out.error = channel == "email" ? "no email on file" : "no mobile number on file";
        model.logAlert(l.id, stage, channel, to.personId, channel == "email" ? "" : to.phone, false, "", out.error);
        return out;
    }

    // The all-clear carries no link; everything else lets the recipient
    // confirm with one tap.
    const std::string link = (stage == "confirmed" || channel == "call") ? "" : tapLink(model, l, to.personId);
    const auto copy = MessageCopy().render("lockup", tier, model.tokens(l, to.firstName, link, alertN));
    if (!copy.ok()) {
        out.error = "message_templates lockup/" + tier + " missing (migration 421)";
        std::cerr << "[LockupScheduler] " << out.error << std::endl;
        model.logAlert(l.id, stage, channel, to.personId, out.contact, false, "", out.error);
        return out;
    }

    std::string sid;
    if (channel == "email") {
        if (!fh::mail::isConfigured()) out.error = "email not configured";
        else if (!fh::mail::send(out.contact, copy.subject, copy.body)) out.error = "smtp send failed";
        else out.ok = true;
    } else if (channel == "sms") {
        auto r = TwilioService::getInstance().sendSms(out.contact, copy.body);
        out.ok = r.ok; sid = r.sid; out.error = r.error;
    } else if (channel == "call") {
        auto r = TwilioService::getInstance().call(out.contact, copy.body);
        out.ok = r.ok; sid = r.sid; out.error = r.error;
    } else {
        out.error = "unknown channel";
    }
    model.logAlert(l.id, stage, channel, to.personId, out.contact, out.ok, sid, out.error);
    return out;
}
