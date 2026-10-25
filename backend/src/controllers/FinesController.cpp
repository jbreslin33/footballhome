#include "FinesController.h"

#include <iostream>
#include <algorithm>
#include <map>
#include <vector>

#include "../database/Database.h"
#include "../models/PersonFines.h"
#include "../third_party/json.hpp"

using json = nlohmann::json;

namespace {
std::string str(const pqxx::row& r, const char* c) { return r[c].is_null() ? std::string{} : std::string(r[c].c_str()); }
Response jsonOut(HttpStatus s, const json& body) { Response r(s, body.dump()); r.setHeader("Content-Type", "application/json"); return r; }
Response jsonOk(const json& body) { return jsonOut(HttpStatus::OK, body); }
Response jsonError(HttpStatus s, const std::string& message) { return jsonOut(s, {{"error", message}}); }
}

FinesController::FinesController() {}

bool FinesController::gate(const Request& request, Response* error) {
    if (requireAdminLevel(request, {"club", "super"})) return true;
    *error = jsonError(denialStatus(request), "Fines are for club admins.");
    return false;
}

void FinesController::registerRoutes(Router& router, const std::string& prefix) {
    router.get(prefix, [this](const Request& r) { return handleBoard(r); });
    router.get (prefix + "/disputes",     [this](const Request& r) { return handleDisputes(r); });
    router.post(prefix + "/disputes/:id", [this](const Request& r) { return handleDecide(r); });
}

// GET /api/fines/disputes — pending "I was there" disputes (mig 691).
Response FinesController::handleDisputes(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    try {
        json out = json::array();
        for (const auto& r : Database::getInstance()->query(R"SQL(
            SELECT d.id, d.person_id, COALESCE(p.first_name,'') || ' ' || COALESCE(p.last_name,'') AS name,
                   d.fh_event_id, d.note,
                   to_char(ge.starts_at AT TIME ZONE 'America/New_York', 'Dy Mon FMDD, FMHH12:MI AM') || ' '
                     || CASE fe.kind WHEN 'practice' THEN 'Practice' WHEN 'intrasquad' THEN 'Intra Squad'
                                     ELSE 'Game' || COALESCE(' vs ' || NULLIF(BTRIM(fe.opponent), ''), '') END AS event,
                   (SELECT f.amount_usd FROM fh_person_fines(ARRAY[d.person_id], ge.starts_at - interval '1 day') f
                     WHERE f.fh_event_id = d.fh_event_id LIMIT 1)::text AS amount,
                   to_char(d.created_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"') AS created_at
              FROM fine_disputes d
              JOIN persons p ON p.id = d.person_id
              JOIN fh_events fe ON fe.id = d.fh_event_id
              JOIN gcal_events ge ON ge.id = fe.gcal_event_id
             WHERE d.status = 'pending'
             ORDER BY d.created_at)SQL")) {
            out.push_back({{"id", r["id"].as<long long>()}, {"person_id", r["person_id"].as<long long>()},
                           {"name", r["name"].c_str()}, {"fh_event_id", r["fh_event_id"].as<long long>()},
                           {"event", r["event"].c_str()},
                           {"note", r["note"].is_null() ? json(nullptr) : json(r["note"].c_str())},
                           {"amount", r["amount"].is_null() ? json(nullptr) : json(std::atof(r["amount"].c_str()))},
                           {"created_at", r["created_at"].c_str()}});
        }
        return jsonOk({{"disputes", out}});
    } catch (const std::exception& e) {
        std::cerr << "[FinesController::disputes] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not load disputes");
    }
}

// POST /api/fines/disputes/:id {decision: approve|deny} — approve marks the
// player present for the event (the no-show fine goes away on its own).
Response FinesController::handleDecide(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    const std::string path = request.getPath();
    long long id = 0;
    try { id = std::stoll(path.substr(path.find_last_of('/') + 1)); } catch (...) {}
    json body;
    try { body = request.getBody().empty() ? json::object() : json::parse(request.getBody()); } catch (...) {}
    const std::string decision = body.value("decision", std::string{});
    if (id <= 0 || (decision != "approve" && decision != "deny"))
        return jsonError(HttpStatus::BAD_REQUEST, "decision must be approve or deny");
    const std::string userId = std::to_string(bearerUserId(request));
    try {
        auto* db = Database::getInstance();
        auto tx = db->beginTransaction();
        auto d = tx->exec_params(
            "UPDATE fine_disputes SET status = $2, decided_by_user_id = NULLIF($3, '0')::int, decided_at = now() "
            " WHERE id = $1 AND status = 'pending' RETURNING person_id, fh_event_id",
            id, decision == "approve" ? "approved" : "denied", userId);
        if (d.empty()) { db->rollback(tx); return jsonError(HttpStatus::CONFLICT, "Already decided."); }
        if (decision == "approve") {
            tx->exec_params(
                "UPDATE fh_event_attendance SET status = 'present', marked_by_user_id = NULLIF($3, '0')::int, marked_at = now() "
                " WHERE fh_event_id = $1 AND person_id = $2 AND status = 'absent'",
                d[0]["fh_event_id"].as<long long>(), d[0]["person_id"].as<long long>(), userId);
        }
        db->commit(tx);
        return jsonOk({{"status", decision == "approve" ? "approved" : "denied"}});
    } catch (const std::exception& e) {
        std::cerr << "[FinesController::decide] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Could not save the decision");
    }
}

// GET /api/fines?months=6
//   months: [{ month, label, current, total, fines, players_fined,
//              by_kind: { <kind>: { count, total } },
//              posting: { posted, not_posted, due, drift } (players) }]   oldest first
//   people: [{ person_id, name, la_user_id, section, teams, total, fines,
//              months: [{ month, label, current, total, items, posting }] }]  highest total first
//   rules:  [{ section, kind, label, amount, since }]
Response FinesController::handleBoard(const Request& request) {
    Response denied; if (!gate(request, &denied)) return denied;
    int months = 6;
    if (request.hasQueryParam("months")) {
        try { months = std::stoi(request.getQueryParam("months")); } catch (...) { months = 6; }
        if (months < 1) months = 1;
        if (months > 24) months = 24;
    }
    try {
        auto* db = Database::getInstance();
        // Everyone fineable: on an active team in a section with a rate in
        // force (the same scope PersonFines uses), with the labels the page
        // shows.
        auto who = db->query(R"SQL(
            SELECT p.id AS person_id, COALESCE(p.first_name,'') AS first_name, COALESCE(p.last_name,'') AS last_name,
                   p.la_user_id::text AS la_user_id,
                   min(cs.name) AS section,
                   string_agg(DISTINCT COALESCE(t.label, t.name), ' · ') AS teams
              FROM team_persons tp
              JOIN teams t ON t.id = tp.team_id AND t.is_active AND t.club_section_id IS NOT NULL
              JOIN club_sections cs ON cs.id = t.club_section_id
              JOIN persons p ON p.id = tp.person_id
             WHERE tp.removed_at IS NULL
               AND EXISTS (SELECT 1 FROM fine_policies fp
                            WHERE fp.club_id = t.club_id
                              AND (fp.club_section_id IS NULL OR fp.club_section_id = t.club_section_id)
                              AND fp.effective_from <= CURRENT_DATE)
             GROUP BY p.id
             ORDER BY p.last_name, p.first_name)SQL");
        std::vector<int> pids;
        for (const auto& r : who) pids.push_back(r["person_id"].as<int>());

        PersonFines fines;
        const PersonFines::Map byPerson = fines.monthsFor(pids, months);

        // Roll up by month across everyone.
        std::map<std::string, json> monthAgg;   // ym → aggregate (ordered oldest first)
        json people = json::array();
        for (const auto& r : who) {
            const int pid = r["person_id"].as<int>();
            auto it = byPerson.find(pid);
            if (it == byPerson.end()) continue;
            const json& f = it->second;
            double total = 0; int count = 0;
            for (const auto& m : f["months"]) {
                const std::string ym = m["month"].get<std::string>();
                json& agg = monthAgg[ym];
                if (agg.is_null()) agg = {{"month", ym}, {"label", m["label"]}, {"current", m["current"]}, {"total", 0.0}, {"fines", 0},
                                          {"players_fined", 0}, {"by_kind", json::object()},
                                          {"posting", {{"posted", 0}, {"not_posted", 0}, {"due", 0}, {"drift", 0}}}};
                const double t = m["total"].get<double>();
                const int n = static_cast<int>(m["items"].size());
                agg["total"] = agg["total"].get<double>() + t;
                agg["fines"] = agg["fines"].get<int>() + n;
                if (n > 0) agg["players_fined"] = agg["players_fined"].get<int>() + 1;
                for (const auto& item : m["items"]) {
                    const std::string k = item["kind"].get<std::string>();
                    json& bk = agg["by_kind"][k];
                    if (bk.is_null()) bk = {{"label", item["label"]}, {"count", 0}, {"total", 0.0}};
                    bk["count"] = bk["count"].get<int>() + 1;
                    bk["total"] = bk["total"].get<double>() + item["amount"].get<double>();
                }
                if (t > 0 && !m["current"].get<bool>() && m.contains("posting") && !m["posting"].is_null()) {
                    const std::string st = m["posting"].value("status", "");
                    if (agg["posting"].contains(st)) agg["posting"][st] = agg["posting"][st].get<int>() + 1;
                }
                total += t; count += n;
            }
            people.push_back({{"person_id", pid}, {"name", str(r, "first_name") + " " + str(r, "last_name")},
                              {"la_user_id", r["la_user_id"].is_null() ? json(nullptr) : json(str(r, "la_user_id"))},
                              {"section", str(r, "section")}, {"teams", str(r, "teams")},
                              {"total", total}, {"fines", count}, {"months", f["months"]}, {"since", f.value("since", "")}});
        }
        json monthsOut = json::array();
        for (auto& [ym, agg] : monthAgg) monthsOut.push_back(agg);

        // The rules in force today, per section that has any.
        json rules = json::array();
        for (const auto& r : db->query(R"SQL(
            SELECT DISTINCT ON (fp.club_section_id, fp.fine_kind)
                   COALESCE(cs.name, 'Club') AS section, fp.fine_kind AS kind, fk.label, fp.amount_usd AS amount,
                   fp.effective_from::text AS since, fk.sort_order
              FROM fine_policies fp
              JOIN fine_kinds fk ON fk.code = fp.fine_kind
              LEFT JOIN club_sections cs ON cs.id = fp.club_section_id
             WHERE fp.effective_from <= CURRENT_DATE
             ORDER BY fp.club_section_id, fp.fine_kind, fp.effective_from DESC)SQL")) {
            rules.push_back({{"section", str(r, "section")}, {"kind", str(r, "kind")}, {"label", str(r, "label")},
                             {"amount", r["amount"].as<double>()}, {"since", str(r, "since")}, {"sort_order", r["sort_order"].as<int>()}});
        }
        std::sort(rules.begin(), rules.end(), [](const json& a, const json& b) {
            return a["section"].get<std::string>() != b["section"].get<std::string>() ? a["section"] < b["section"] : a["sort_order"] < b["sort_order"]; });

        return jsonOk({{"months", monthsOut}, {"people", people}, {"rules", rules}, {"months_back", months}});
    } catch (const std::exception& e) {
        std::cerr << "[fines] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, e.what());
    }
}
