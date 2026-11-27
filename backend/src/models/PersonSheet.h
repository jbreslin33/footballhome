#pragma once
#include <string>

#include "../third_party/json.hpp"

// PersonSheet — what the ⋯ player sheet needs to draw itself, whatever
// screen opened it (owner 2026-11-20: "make player card the same wherever
// its clicked from and the functionality to move them teams open la put
// them as volunteers etc contact them for various reasons need to all be
// there").  Before this the opening screen handed over the LA id, the
// contacts and the team pickers, so a card opened from #members had no
// 📇 CONTACT and one opened from #rsvps no 🔗 Open in LA.
//
// One read per opening; the writes stay where they were (team moves
// /api/person-teams, team status /api/mens-roster/invite-only, health
// /api/person-health) plus 🙋 volunteer here.
class PersonSheet {
public:
    // personId <= 0 → looked up by LA user id (alias-aware, mig 602).
    // null when there is no such person.  Shape:
    //   { personId, laUserId, firstName, lastName, dob, section,
    //     canSee      viewer is a club admin or coaches a team
    //     canVolunteer  viewer may flip 🙋 (club admins)
    //     volunteer:  { on, since }            club_volunteers (mig 704)
    //     recipients: [{ personId, name, phone, email, isGuardian }]
    //                 fh_message_recipients — each parent of a kid
    //     teams:      [{ teamId, label, short, section, status, canManage }]
    //                 status = squad_statuses.code, else inactive / plays }
    nlohmann::json card(long long personId, const std::string& laUserId, long long viewerUserId);

    // ✅ The sheet's mini attendance (owner 2026-11-21: "it should have a
    // mini attendance also in the popup for that day and all days really
    // but that event should default to"): the person's events the viewer
    // may take the roll on (fh_event_viewer_tier coach / admin; the person
    // on the event's roster, staff or invites — the attendance POST's own
    // rule), the last 90 days through today, newest first, plus fhEventId
    // (the event the sheet was opened from) whatever its day.  Marks are
    // written by POST|DELETE /api/calendar/events/:id/attendance.
    //   { events: [{ fhEventId, kind, category, opponent, startsAt, status,
    //                open }] }      open = its day has come (club time)
    nlohmann::json attendance(long long personId, long long viewerUserId, long long fhEventId);

    // 🙋 on = a club_volunteers row ($0 dues, no notices); off removes it.
    void setVolunteer(long long personId, bool on);
};
