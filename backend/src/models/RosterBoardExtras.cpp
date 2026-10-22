#include "RosterBoardExtras.h"

#include <iostream>

#include "../database/Database.h"

void RosterBoardExtras::attach(nlohmann::json& body, const char* logTag) {
    // ⭐ Standing invites per team (team_auto_invites, migs 617/619) —
    // the board shows who rides a team's games WITHOUT holding a list
    // spot (owner 2026-10-20: "sheldon if he is perpetual call up
    // should show in that category … don't want to lose track of all
    // this"), keyed by team id for the column pills.
    try {
        auto* db = Database::getInstance();
        nlohmann::json autoInv = nlohmann::json::object();
        for (const auto& r : db->query(
            "SELECT a.team_id, a.person_id, "
            "       NULLIF(TRIM(CONCAT_WS(' ', p.first_name, p.last_name)), '') AS name, "
            "       ft.name AS from_team "
            "  FROM team_auto_invites a "
            "  JOIN persons p ON p.id = a.person_id "
            "  LEFT JOIN teams ft ON ft.id = a.from_team_id "
            " WHERE a.active ORDER BY p.last_name, p.first_name")) {
            const std::string tid = r["team_id"].c_str();
            if (!autoInv.contains(tid)) autoInv[tid] = nlohmann::json::array();
            autoInv[tid].push_back({
                {"personId", r["person_id"].as<long long>()},
                {"name", r["name"].is_null() ? "" : r["name"].c_str()},
                {"fromTeam", r["from_team"].is_null() ? "" : r["from_team"].c_str()}});
        }
        body["autoInvites"] = std::move(autoInv);
        // Call-up-gated teams (mig 605): roster rows grant no games
        // there, so the 👀 Sees games pill counts only the ⭐
        // standing invites for these columns.
        nlohmann::json gated = nlohmann::json::array();
        for (const auto& r : db->query(
            "SELECT t.id FROM teams t WHERE t.is_active AND fh_team_callup_only(t.id)"))
            gated.push_back(r["id"].as<long long>());
        body["callupOnlyTeams"] = std::move(gated);
        // Teams whose official roster is pulled ONLINE: On Roster is
        // granted by the pull there, never typed (2026-10-21).
        nlohmann::json online = nlohmann::json::array();
        for (const auto& r : db->query(
            "SELECT DISTINCT team_id FROM official_roster_sources "
            " WHERE is_active AND system IN ('teampass', 'google_sheet')"))
            online.push_back(r["team_id"].as<long long>());
        body["onlineRosterTeams"] = std::move(online);
    } catch (const std::exception& e) {
        std::cerr << "[" << logTag << "] auto-invites attach failed: " << e.what() << std::endl;
    }
    // 🌐 The league's OWN roster per team (official_roster_names, mig
    // 620) — the board's Roster pill mirrors the actual league list.
    try {
        auto* db = Database::getInstance();
        nlohmann::json official = nlohmann::json::object();
        for (const auto& r : db->query(
            // LEFT JOIN: a source with no pull yet (mig 622 seeded the
            // Reserves row empty) still gets its pill — Roster (0) —
            // so the board's auto-pull can give it its first names.
            "SELECT s.team_id, s.league_label, s.system, n.full_name, "
            "       to_char(max(n.pulled_at) OVER (PARTITION BY s.id) AT TIME ZONE 'America/New_York', 'Mon FMDD, FMHH12:MI am') AS pulled_label "
            "  FROM official_roster_sources s "
            "  LEFT JOIN official_roster_names n ON n.source_id = s.id "
            " WHERE s.is_active ORDER BY s.team_id, n.sort_order")) {
            const std::string tid = r["team_id"].c_str();
            if (!official.contains(tid))
                official[tid] = {{"league", r["league_label"].is_null() ? "" : r["league_label"].c_str()},
                                 {"pulledAt", r["pulled_label"].is_null() ? "" : r["pulled_label"].c_str()},
                                 // Which kind of source: teampass / google_sheet
                                 // re-pull online on every board load; club_file
                                 // is an upload with nothing to fetch.
                                 {"system", r["system"].is_null() ? "" : r["system"].c_str()},
                                 {"names", nlohmann::json::array()}};
            if (!r["full_name"].is_null()) official[tid]["names"].push_back(r["full_name"].c_str());
        }
        body["officialRosters"] = std::move(official);
    } catch (const std::exception& e) {
        std::cerr << "[" << logTag << "] official names attach failed: " << e.what() << std::endl;
    }
}
