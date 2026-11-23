#pragma once
#include <string>
#include <vector>

#include "../third_party/json.hpp"

// LeagueEntry — 📝 #league-registration (mig 1746): a registration with a
// league as a checklist, its forms pre-filled.
//
//   league_entries       who signs, who it goes to, the fees
//   league_entry_teams   each team entered = the team commitment form's answers
//   league_entry_items   the checklist; a form row names the league's own
//                        Word file (club_files), filled in the browser
//
// The official roster is the team's live players (team_persons), first
// max_roster by name, each with a parent's phone.
class LeagueEntry {
public:
    // { entries: [{…, director, teams:[{…, coach, assistant, coaches, roster}], items, fees}] }
    static nlohmann::json board();
    // Change a team's answers; fields = {column: value}.  "" = ok, else why not.
    static std::string saveTeam(long long entryTeamId, const nlohmann::json& fields);
    // Who it goes to / the note: {send_to_name, send_to_email, note}.
    static std::string saveEntry(long long entryId, const nlohmann::json& fields);
    static std::string tick(long long itemId, bool done, long long userId);
    struct File { std::string filename, base64; };
    // ✉️ Email the filled forms (built in the browser) to the league.
    static std::string send(long long entryId, const std::vector<File>& files, long long userId, int* sent);
};
