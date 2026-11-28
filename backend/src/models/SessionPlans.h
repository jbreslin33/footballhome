#pragma once
#include <string>
#include "../third_party/json.hpp"

// SessionPlans — 🗓 exercises from the catalog (mig 2191) tied to practices
// and games (mig 5020).
//
// Each team has session templates, one per slot:
//   youth (boys / girls)  → weekday slots (ISO 1 Mon … 7 Sun)
//   men / women           → match-day slots: MD+1, MD-3, MD-2, MD-1 and the
//                           no-game week
//   every team            → MD 0 = the game warm-up
// A practice on the calendar resolves to its slot (youth: its weekday; men /
// women: days to the team's next game, or days since the last one for MD+1,
// else the no-game plan); a game resolves to MD 0.  A coach may edit one
// event: fh_event_sessions holds that copy and it wins over the template.
class SessionPlans {
public:
    // Teams this person may plan for: club admins → every active club team;
    // otherwise the teams they coach (team_coaches).  [{id, label, anchor}]
    static nlohmann::json teamsFor(long long personId, bool clubAdmin);
    static bool canPlanTeam(long long personId, bool clubAdmin, int teamId);

    // { team:{id,label,anchor}, slots:[{anchor, weekday, md_offset, theme,
    //   template_id, exercises:[item]}] }
    static nlohmann::json teamPlan(int teamId);

    // Template edits.  slot = {anchor, weekday?, md_offset?}.
    static int addToTemplate(int teamId, const nlohmann::json& slot, int exerciseId, int minutes);
    static void setTheme(int teamId, const nlohmann::json& slot, const std::string& theme);
    // Item edits on a template row or an event row (kind "template" | "event").
    // Returns the owning team id (template) or fh_event_id (event), 0 if none.
    static long long itemOwner(const std::string& kind, int itemId);
    static void updateItem(const std::string& kind, int itemId, const nlohmann::json& body);
    static void deleteItem(const std::string& kind, int itemId);

    // The session for one calendar event:
    // { fh_event_id, kind ('practice'|'match'), team:{id,label,anchor}|null,
    //   slot:{anchor,weekday,md_offset}|null, source:'event'|'template'|'none',
    //   exercises:[item] }
    static nlohmann::json eventSession(long long fhEventId);
    // Copy the resolved template onto the event (start editing this one).
    static void startEventEdit(long long fhEventId, long long personId);
    static void resetEvent(long long fhEventId);
    static int addToEvent(long long fhEventId, int exerciseId, int minutes, long long personId);
};
