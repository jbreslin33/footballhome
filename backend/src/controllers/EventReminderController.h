#pragma once

#include "../core/Controller.h"

// EventReminderController — coach-triggered "nudge non-responders" flow.
//
// Two endpoints:
//   POST /api/matches/:matchId/remind    (bearer JWT)
//     Body: { channel: 'sms'|'email' = 'sms',
//             person_ids?: [int]  // omit → all non-responders on roster
//           }
//     Response: {
//       match_id, channel, sent, skipped_rate_limited,
//       recipients: [ { person_id, name, contact, url, sms_href?, mailto_href? } ]
//     }
//     Rate limit: at most one reminder per (match_id, person_id) per
//     kRateLimitWindow.  Rate-limited recipients are dropped, NOT errored,
//     so a partial batch still succeeds.
//
//   GET  /api/reminders/verify?token=X    (public)
//     Sets fh_sess cookie for the person referenced by the token,
//     records delivered_at on player_event_reminders, then 302 →
//     /#my so the recipient lands on their weekly RSVP view.
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
    Response handleSendReminders(const Request& request);
    Response handleVerify(const Request& request);

    // GET /api/mens/week-availability?days=7
    //   Bearer JWT required.
    //   Returns every mens event (games + practices + pickups) in the
    //   next `days` (default 7) with every roster-eligible player and
    //   their current RSVP status.  Powers the "Mens Reminders"
    //   left-to-right event-columns board so the coach can nudge any
    //   individual "no response" player one-off.
    //
    //   Response shape — see cpp for the full JSON.
    Response handleGetMensWeek(const Request& request);
};
