#include "TacticalLiveController.h"

#include <algorithm>
#include <iostream>

#include "../database/Database.h"
#include "../third_party/json.hpp"

using nlohmann::json;

namespace {

Response jsonOut(HttpStatus s, const json& body) { Response r(s, body.dump()); r.setHeader("Content-Type", "application/json; charset=utf-8"); return r; }
Response jsonError(HttpStatus s, const std::string& message) { return jsonOut(s, {{"success", false}, {"error", message}}); }

long long idAfter(const std::string& path, const std::string& key) {
    auto p = path.find(key); if (p == std::string::npos) return 0;
    p += key.size(); auto e = path.find('/', p);
    try { return std::stoll(path.substr(p, e == std::string::npos ? std::string::npos : e - p)); } catch (...) { return 0; }
}

std::string str(const pqxx::row& r, const char* c) { return r[c].is_null() ? std::string{} : std::string(r[c].c_str()); }

struct Viewer { long long personId = 0; bool isStaff = false; };

// The signed-in account's person, and whether they run boards: a live
// coach of any team, or a club/super admin.  Deliberately NOT per-team —
// a meeting board is one room, whoever coaches anything may drive it.
bool loadViewer(Database* db, long long userId, Viewer* out) {
    auto rows = db->query(R"SQL(
        SELECT u.person_id,
               (EXISTS (SELECT 1 FROM admins a JOIN admin_levels al ON al.id = a.admin_level_id
                         WHERE a.user_id = u.id AND al.name IN ('club','super'))
                OR EXISTS (SELECT 1 FROM team_coaches tc JOIN coaches co ON co.id = tc.coach_id
                            WHERE co.person_id = u.person_id AND tc.ended_at IS NULL)) AS is_staff
          FROM users u WHERE u.id = $1::int)SQL", {std::to_string(userId)});
    if (rows.empty() || rows[0]["person_id"].is_null()) return false;
    out->personId = rows[0]["person_id"].as<long long>();
    out->isStaff  = rows[0]["is_staff"].as<bool>();
    return true;
}

json piecesJson(Database* db, long long boardId) {
    auto rows = db->query(
        "SELECT id, person_id, label, kind, x, y FROM tactical_live_pieces "
        " WHERE board_id = $1::int ORDER BY kind, id", {std::to_string(boardId)});
    json out = json::array();
    for (const auto& r : rows) {
        out.push_back({{"id", r["id"].as<long long>()},
                       {"personId", r["person_id"].is_null() ? json(nullptr) : json(r["person_id"].as<long long>())},
                       {"label", str(r, "label")}, {"kind", str(r, "kind")},
                       {"x", r["x"].as<double>()}, {"y", r["y"].as<double>()}});
    }
    return out;
}

} // namespace

void TacticalLiveController::registerRoutes(Router& router, const std::string& prefix) {
    router.get (prefix + "/board",             [this](const Request& r) { return handleGetBoard(r); });
    router.post(prefix + "/boards",            [this](const Request& r) { return handleCreateBoard(r); });
    router.post(prefix + "/boards/:id/close",  [this](const Request& r) { return handleCloseBoard(r); });
    router.post(prefix + "/pieces/:id/move",   [this](const Request& r) { return handleMove(r); });
    router.post(prefix + "/pieces/:id/label",  [this](const Request& r) { return handleLabel(r); });
}

Response TacticalLiveController::handleGetBoard(const Request& request) {
    const long long userId = bearerUserId(request);
    if (userId <= 0) return jsonError(HttpStatus::UNAUTHORIZED, "sign in");
    try {
        auto* db = Database::getInstance();
        Viewer me;
        if (!loadViewer(db, userId, &me)) return jsonError(HttpStatus::FORBIDDEN, "No person on this account.");

        const std::string wantId = request.getQueryParam("id");
        auto boards = db->query(
            wantId.empty()
              ? "SELECT b.id, b.team_id, b.title, t.name AS team_name, b.closed_at "
                "  FROM tactical_live_boards b JOIN teams t ON t.id = b.team_id "
                " WHERE b.closed_at IS NULL ORDER BY b.created_at DESC LIMIT 1"
              : "SELECT b.id, b.team_id, b.title, t.name AS team_name, b.closed_at "
                "  FROM tactical_live_boards b JOIN teams t ON t.id = b.team_id "
                " WHERE b.id = $1::int",
            wantId.empty() ? std::vector<std::string>{} : std::vector<std::string>{wantId});

        json board = nullptr, pieces = json::array();
        if (!boards.empty()) {
            const auto& b = boards[0];
            board = {{"id", b["id"].as<long long>()}, {"teamId", b["team_id"].as<long long>()},
                     {"teamName", str(b, "team_name")}, {"title", str(b, "title")},
                     {"closedAt", b["closed_at"].is_null() ? json(nullptr) : json(str(b, "closed_at"))}};
            pieces = piecesJson(db, b["id"].as<long long>());
        }

        // Which teams the viewer may start a board for: any active team with
        // players on it (admins), or just the ones they coach.
        json teams = json::array();
        if (me.isStaff) {
            auto ts = db->query(R"SQL(
                SELECT DISTINCT t.id, t.name FROM teams t
                 WHERE t.is_active
                   AND EXISTS (SELECT 1 FROM team_persons tp
                                WHERE tp.team_id = t.id AND tp.removed_at IS NULL)
                   AND (EXISTS (SELECT 1 FROM admins a JOIN admin_levels al ON al.id = a.admin_level_id
                                  JOIN users u ON u.id = a.user_id
                                 WHERE u.person_id = $1::int AND al.name IN ('club','super'))
                     OR EXISTS (SELECT 1 FROM team_coaches tc JOIN coaches co ON co.id = tc.coach_id
                                 WHERE tc.team_id = t.id AND tc.ended_at IS NULL
                                   AND co.person_id = $1::int))
                 ORDER BY t.name)SQL", {std::to_string(me.personId)});
            for (const auto& r : ts) teams.push_back({{"id", r["id"].as<long long>()}, {"name", str(r, "name")}});
        }

        return jsonOut(HttpStatus::OK, {{"success", true}, {"board", board}, {"pieces", pieces},
                                        {"viewer", {{"personId", me.personId}, {"isStaff", me.isStaff}}},
                                        {"teams", teams}});
    } catch (const std::exception& e) {
        std::cerr << "[GET /api/tactical-live/board] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Database error");
    }
}

Response TacticalLiveController::handleCreateBoard(const Request& request) {
    const long long userId = bearerUserId(request);
    if (userId <= 0) return jsonError(HttpStatus::UNAUTHORIZED, "sign in");
    json body;
    try { body = request.getBody().empty() ? json::object() : json::parse(request.getBody()); }
    catch (...) { return jsonError(HttpStatus::BAD_REQUEST, "bad json"); }
    const long long teamId = body.value("team_id", 0LL);
    if (teamId <= 0) return jsonError(HttpStatus::BAD_REQUEST, "team_id");
    std::string title = body.value("title", std::string(""));
    if (title.size() > 80) title.resize(80);
    try {
        auto* db = Database::getInstance();
        Viewer me;
        if (!loadViewer(db, userId, &me)) return jsonError(HttpStatus::FORBIDDEN, "No person on this account.");
        if (!me.isStaff) return jsonError(HttpStatus::FORBIDDEN, "Starting a board is for coaches.");
        const std::string tid = std::to_string(teamId);

        // One open board at a time: starting a new one ends the rest.  The
        // meeting room has one screen; stale boards would split the squad.
        db->query("UPDATE tactical_live_boards SET closed_at = now() WHERE closed_at IS NULL");

        auto ins = db->query(
            "INSERT INTO tactical_live_boards (team_id, title, created_by_user_id) "
            "VALUES ($1::int, $2, $3::int) RETURNING id",
            {tid, title, std::to_string(userId)});
        const long long boardId = ins[0]["id"].as<long long>();
        const std::string bid = std::to_string(boardId);

        // Seed one piece per active rostered player, labelled LAST NAME
        // (owner: "name on piece coudl defulat to their last name unless
        // they over ride"), laid out in rows on our half; then a ball on
        // the spot and a 4-4-2 of unowned opponent X's on theirs.
        db->query(R"SQL(
            INSERT INTO tactical_live_pieces (board_id, person_id, label, kind, x, y)
            SELECT $1::int, p.id,
                   COALESCE(NULLIF(BTRIM(p.last_name), ''), NULLIF(BTRIM(p.first_name), ''), 'Player'),
                   'player',
                   0.12 + 0.76 * ((row_number() OVER w - 1) % 5) / 4.0,
                   0.58 + 0.34 * floor((row_number() OVER w - 1) / 5.0)
                         / GREATEST(ceil((COUNT(*) OVER ()) / 5.0) - 1, 1)
              FROM team_persons tp
              JOIN persons p ON p.id = tp.person_id
             WHERE tp.team_id = $2::int AND tp.removed_at IS NULL
            WINDOW w AS (ORDER BY p.last_name, p.first_name, p.id))SQL",
            {bid, tid});
        db->query(
            "INSERT INTO tactical_live_pieces (board_id, label, kind, x, y) "
            "VALUES ($1::int, '', 'ball', 0.5, 0.5)", {bid});
        db->query(R"SQL(
            INSERT INTO tactical_live_pieces (board_id, label, kind, x, y)
            SELECT $1::int, 'X', 'opponent',
                   v.x, v.y
              FROM (VALUES (0.50,0.06),
                           (0.20,0.16),(0.40,0.16),(0.60,0.16),(0.80,0.16),
                           (0.20,0.30),(0.40,0.30),(0.60,0.30),(0.80,0.30),
                           (0.40,0.42),(0.60,0.42)) AS v(x, y))SQL", {bid});

        return jsonOut(HttpStatus::OK, {{"success", true}, {"boardId", boardId}});
    } catch (const std::exception& e) {
        std::cerr << "[POST /api/tactical-live/boards] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Database error");
    }
}

Response TacticalLiveController::handleCloseBoard(const Request& request) {
    const long long boardId = idAfter(request.getPath(), "/boards/");
    if (boardId <= 0) return jsonError(HttpStatus::BAD_REQUEST, "board id");
    const long long userId = bearerUserId(request);
    if (userId <= 0) return jsonError(HttpStatus::UNAUTHORIZED, "sign in");
    try {
        auto* db = Database::getInstance();
        Viewer me;
        if (!loadViewer(db, userId, &me)) return jsonError(HttpStatus::FORBIDDEN, "No person on this account.");
        if (!me.isStaff) return jsonError(HttpStatus::FORBIDDEN, "Ending a board is for coaches.");
        db->query("UPDATE tactical_live_boards SET closed_at = now() WHERE id = $1::int AND closed_at IS NULL",
                  {std::to_string(boardId)});
        return jsonOut(HttpStatus::OK, {{"success", true}});
    } catch (const std::exception& e) {
        std::cerr << "[POST /api/tactical-live/boards/close] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Database error");
    }
}

Response TacticalLiveController::handleMove(const Request& request) {
    const long long pieceId = idAfter(request.getPath(), "/pieces/");
    if (pieceId <= 0) return jsonError(HttpStatus::BAD_REQUEST, "piece id");
    const long long userId = bearerUserId(request);
    if (userId <= 0) return jsonError(HttpStatus::UNAUTHORIZED, "sign in");
    json body;
    try { body = request.getBody().empty() ? json::object() : json::parse(request.getBody()); }
    catch (...) { return jsonError(HttpStatus::BAD_REQUEST, "bad json"); }
    if (!body.contains("x") || !body.contains("y") || !body["x"].is_number() || !body["y"].is_number())
        return jsonError(HttpStatus::BAD_REQUEST, "x and y");
    const double x = std::clamp(body["x"].get<double>(), 0.0, 1.0);
    const double y = std::clamp(body["y"].get<double>(), 0.0, 1.0);
    try {
        auto* db = Database::getInstance();
        Viewer me;
        if (!loadViewer(db, userId, &me)) return jsonError(HttpStatus::FORBIDDEN, "No person on this account.");

        // Own piece, the ball, or staff — and only while the board is open.
        // One UPDATE carries the whole check; 0 rows = not allowed/closed.
        auto upd = db->query(R"SQL(
            UPDATE tactical_live_pieces pc
               SET x = $2::numeric, y = $3::numeric,
                   moved_by_person_id = $4::int, updated_at = now()
              FROM tactical_live_boards b
             WHERE pc.id = $1::int AND b.id = pc.board_id AND b.closed_at IS NULL
               AND (pc.person_id = $4::int OR pc.kind = 'ball' OR $5::bool)
            RETURNING pc.id)SQL",
            {std::to_string(pieceId), std::to_string(x), std::to_string(y),
             std::to_string(me.personId), me.isStaff ? "true" : "false"});
        if (upd.empty()) return jsonError(HttpStatus::FORBIDDEN, "Not your piece (or the board is closed).");
        return jsonOut(HttpStatus::OK, {{"success", true}});
    } catch (const std::exception& e) {
        std::cerr << "[POST /api/tactical-live/move] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Database error");
    }
}

Response TacticalLiveController::handleLabel(const Request& request) {
    const long long pieceId = idAfter(request.getPath(), "/pieces/");
    if (pieceId <= 0) return jsonError(HttpStatus::BAD_REQUEST, "piece id");
    const long long userId = bearerUserId(request);
    if (userId <= 0) return jsonError(HttpStatus::UNAUTHORIZED, "sign in");
    json body;
    try { body = request.getBody().empty() ? json::object() : json::parse(request.getBody()); }
    catch (...) { return jsonError(HttpStatus::BAD_REQUEST, "bad json"); }
    std::string label = body.value("label", std::string(""));
    while (!label.empty() && std::isspace(static_cast<unsigned char>(label.front()))) label.erase(label.begin());
    while (!label.empty() && std::isspace(static_cast<unsigned char>(label.back())))  label.pop_back();
    if (label.empty())    return jsonError(HttpStatus::BAD_REQUEST, "label required");
    if (label.size() > 20) label.resize(20);
    try {
        auto* db = Database::getInstance();
        Viewer me;
        if (!loadViewer(db, userId, &me)) return jsonError(HttpStatus::FORBIDDEN, "No person on this account.");
        auto upd = db->query(R"SQL(
            UPDATE tactical_live_pieces pc
               SET label = $2, moved_by_person_id = $3::int, updated_at = now()
              FROM tactical_live_boards b
             WHERE pc.id = $1::int AND b.id = pc.board_id AND b.closed_at IS NULL
               AND (pc.person_id = $3::int OR $4::bool)
            RETURNING pc.id)SQL",
            {std::to_string(pieceId), label, std::to_string(me.personId),
             me.isStaff ? "true" : "false"});
        if (upd.empty()) return jsonError(HttpStatus::FORBIDDEN, "Not your piece (or the board is closed).");
        return jsonOut(HttpStatus::OK, {{"success", true}});
    } catch (const std::exception& e) {
        std::cerr << "[POST /api/tactical-live/label] " << e.what() << std::endl;
        return jsonError(HttpStatus::INTERNAL_SERVER_ERROR, "Database error");
    }
}
