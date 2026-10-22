#pragma once

#include "../third_party/json.hpp"

// RosterBoardExtras — the per-column pill data every roster board shares
// (owner 2026-10-22: the ✅/📄/🩹/⭐ pills were MEN'S-board-only; Boys/
// Girls/Womens columns were plain).  Lifted out of MensRosterController
// so Boys and Womens attach the identical payload:
//
//   autoInvites      ⭐ standing invites per team (team_auto_invites)
//   callupOnlyTeams  teams where roster rows grant no games (mig 605)
//   onlineRosterTeams  teams whose On Roster is granted by the 🌐 pull
//   officialRosters  the league's OWN roster names per team (mig 620)
//
// The queries are club-wide (not section-scoped): each board only reads
// the keys matching its own columns' team ids, so one shape serves all.
// Failures never fail the board — the block logs and the body ships
// without the extras, exactly as the mens board always behaved.
class RosterBoardExtras {
public:
    static void attach(nlohmann::json& body, const char* logTag);
};
