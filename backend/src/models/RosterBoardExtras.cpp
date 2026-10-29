#include "RosterBoardExtras.h"

#include <functional>
#include <iostream>
#include <unordered_map>

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
            "SELECT s.team_id, s.league_label, s.system, n.full_name, n.person_id, "
            "       n.person_id IS NOT NULL AND NOT fh_in_leagueapps(n.person_id) AS cut, "
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
                                 {"names", nlohmann::json::array()},
                                 // parallel to names: the FH person the
                                 // match trigger found (null = league-only)
                                 {"personIds", nlohmann::json::array()},
                                 // parallel: on the list with no live LA
                                 // membership = cut, still owed a drop (mig 807)
                                 {"cut", nlohmann::json::array()}};
            if (!r["full_name"].is_null()) {
                official[tid]["names"].push_back(r["full_name"].c_str());
                official[tid]["personIds"].push_back(r["person_id"].is_null() ? nlohmann::json(nullptr)
                                                                              : nlohmann::json(r["person_id"].as<long long>()));
                official[tid]["cut"].push_back(!r["cut"].is_null() && r["cut"].as<bool>());
            }
        }
        body["officialRosters"] = std::move(official);
        // League eligibility rules between those lists (mig 820): per team,
        // {requires: [teamId…], excludes: [teamId…]} — the board checks the
        // lists above against each other and flags ⚠ INELIGIBLE.
        nlohmann::json rules = nlohmann::json::object();
        for (const auto& r : db->query("SELECT team_id, other_team_id, rule FROM roster_team_rules ORDER BY 1, 2")) {
            const std::string tid = r["team_id"].c_str();
            if (!rules.contains(tid)) rules[tid] = {{"requires", nlohmann::json::array()}, {"excludes", nlohmann::json::array()}};
            rules[tid][r["rule"].c_str()].push_back(r["other_team_id"].as<long long>());
        }
        body["rosterRules"] = std::move(rules);
    } catch (const std::exception& e) {
        std::cerr << "[" << logTag << "] official names attach failed: " << e.what() << std::endl;
    }
    // 🏦 A bank payment LeagueApps recorded but hasn't applied yet (mig
    // 690) comes off the board's balance too — LA's raw
    // outstandingBalance still counts it as owed until it settles.
    // pendingBankUsd rides along so the card can say why.
    try {
        auto* db = Database::getInstance();
        std::unordered_map<long long, double> pending;
        for (const auto& r : db->query(
            "SELECT m.la_registration_id, SUM(fh_membership_pending_bank_usd(m.id))::float8 AS usd "
            "  FROM person_la_memberships m "
            " WHERE m.ended_at IS NULL AND m.la_registration_id IS NOT NULL "
            "   AND fh_membership_pending_bank_usd(m.id) > 0 "
            " GROUP BY m.la_registration_id"))
            pending[r["la_registration_id"].as<long long>()] = r["usd"].as<double>();
        if (!pending.empty()) {
            std::function<void(nlohmann::json&)> walk = [&](nlohmann::json& j) {
                if (j.is_array()) { for (auto& e : j) walk(e); return; }
                if (!j.is_object()) return;
                const auto reg = j.find("registrationId");
                const auto bal = j.find("outstandingBalance");
                if (reg != j.end() && bal != j.end() && bal->is_number()) {
                    long long id = 0;
                    if (reg->is_number_integer()) id = reg->get<long long>();
                    else if (reg->is_string()) { try { id = std::stoll(reg->get<std::string>()); } catch (...) {} }
                    if (const auto it = pending.find(id); it != pending.end()) {
                        const double raw = bal->get<double>();
                        j["outstandingBalance"] = raw > it->second ? raw - it->second : 0.0;
                        j["pendingBankUsd"] = it->second;
                    }
                    return;
                }
                for (auto& [k, v] : j.items()) walk(v);
            };
            walk(body);
        }
    } catch (const std::exception& e) {
        std::cerr << "[" << logTag << "] pending bank attach failed: " << e.what() << std::endl;
    }
}
