#pragma once

#include "../core/Controller.h"

// EventReminderController — coach-triggered "nudge non-responders" flow.
//
// Three endpoints:
//   POST /api/events/:fhEventId/remind    (bearer JWT)
//     Body: { channel: 'sms'|'email' = 'sms',
//             person_ids?: [int]  // omit → all non-responders on roster
//           }
//     Response: {
//       fh_event_id, channel, sent, skipped_rate_limited,
//       recipients: [ { person_id, name, contact, url, sms_href?, mailto_href? } ]
//     }
//     Rate limit: at most one reminder per (fh_event_id, person_id) per
//     kRateLimitWindow.  Rate-limited recipients are dropped, NOT errored,
//     so a partial batch still succeeds.
//
//   GET  /api/reminders/verify?token=X    (public)
//     Sets fh_sess cookie for the person referenced by the token,
//     records delivered_at on player_event_reminders, then 302 →
//     /#calendar so the recipient lands on the CalendarScreen where
//     they RSVP.
//
//   GET  /api/mens/week-availability?days=7    (bearer JWT)
//     Returns every mens fh_event (games + practices + pickups) in
//     the next `days` (default 7) with every roster-eligible player
//     and their current RSVP status.  Powers the "Mens Reminders"
//     board.
//
// Tokens live in player_event_reminders.magic_token as SHA-256 hex.
// The raw token is only ever in the URL; a DB breach can't be used
// to impersonate.  Reminders are valid for kReminderTtl from sent_at.
class EventReminderController : public Controller {
public:
    EventReminderController();
    ~EventReminderController() override;

    void registerRoutes(Router& router, const std::string& prefix) override;

private:
    Response handleSendReminders(const Request& request, const LaSyncMap& sync);
    Response handleVerify(const Request& request);
    Response handleGetMensWeek(const Request& request, const LaSyncMap& sync);
};
