#include "FormationTactics.h"

#include "../database/Database.h"

using nlohmann::json;

namespace {

// The board a formation's situations hang off (migration 1120's unique
// index: one template board per formation).
constexpr const char* kBoardSql =
    "SELECT b.id FROM tactical_boards b "
    "  JOIN tactical_board_types bt ON bt.id = b.board_type_id AND bt.code = 'template' "
    " WHERE b.formation_id = $1::int AND b.is_template";

}  // namespace

json FormationTactics::get(long long formationId) {
    auto* db = Database::getInstance();
    json out = {{"formation_id", formationId}, {"board_id", nullptr}, {"situations", json::array()}};
    auto board = db->query(kBoardSql, {std::to_string(formationId)});
    if (board.empty()) return out;
    const std::string boardId = board[0]["id"].as<std::string>();
    out["board_id"] = board[0]["id"].as<long long>();

    for (const auto& f : db->query(
             "SELECT id, COALESCE(label, '') AS label, COALESCE(notes, '') AS notes "
             "  FROM tactical_frames WHERE board_id = $1::int ORDER BY frame_number, id",
             {boardId})) {
        const std::string fid = f["id"].as<std::string>();
        json sit = {{"id", f["id"].as<long long>()},
                    {"label", f["label"].as<std::string>()},
                    {"notes", f["notes"].as<std::string>()},
                    {"ball", nullptr},
                    {"players", json::array()},
                    {"opponents", json::array()}};
        for (const auto& p : db->query(
                 "SELECT is_opponent, position_id, COALESCE(generic_label, '') AS label, "
                 "       x::float8 AS x, y::float8 AS y "
                 "  FROM tactical_frame_players WHERE frame_id = $1::int ORDER BY slot_number",
                 {fid})) {
            if (p["is_opponent"].as<bool>())
                sit["opponents"].push_back({{"label", p["label"].as<std::string>()},
                                            {"x", p["x"].as<double>()}, {"y", p["y"].as<double>()}});
            else if (!p["position_id"].is_null())
                sit["players"].push_back({{"position_id", p["position_id"].as<int>()},
                                          {"x", p["x"].as<double>()}, {"y", p["y"].as<double>()}});
        }
        auto ball = db->query(
            "SELECT x::float8 AS x, y::float8 AS y FROM tactical_frame_objects "
            " WHERE frame_id = $1::int AND object_type = 'ball' ORDER BY id LIMIT 1", {fid});
        if (!ball.empty()) sit["ball"] = {{"x", ball[0]["x"].as<double>()}, {"y", ball[0]["y"].as<double>()}};
        out["situations"].push_back(std::move(sit));
    }
    return out;
}

bool FormationTactics::putSituation(long long frameId, const json& body, long long byUserId) {
    auto* db = Database::getInstance();
    auto tx = db->beginTransaction();
    try {
        auto own = tx->exec_params(
            "SELECT b.id FROM tactical_frames f "
            "  JOIN tactical_boards b ON b.id = f.board_id AND b.is_template AND b.formation_id IS NOT NULL "
            "  JOIN tactical_board_types bt ON bt.id = b.board_type_id AND bt.code = 'template' "
            " WHERE f.id = $1",
            frameId);
        if (own.empty()) { db->rollback(tx); return false; }
        const long long boardId = own[0]["id"].as<long long>();

        tx->exec_params("DELETE FROM tactical_frame_players WHERE frame_id = $1", frameId);
        tx->exec_params("DELETE FROM tactical_frame_objects WHERE frame_id = $1 AND object_type = 'ball'", frameId);
        for (const auto& p : body.at("players")) {
            const int pos = p.at("position_id").get<int>();
            tx->exec_params(
                "INSERT INTO tactical_frame_players (frame_id, position_id, slot_number, is_starter, is_opponent, x, y) "
                "VALUES ($1, $2, $2, true, false, $3, $4)",
                frameId, pos, p.at("x").get<double>(), p.at("y").get<double>());
        }
        int slot = 101;
        for (const auto& o : body.at("opponents")) {
            tx->exec_params(
                "INSERT INTO tactical_frame_players (frame_id, generic_label, slot_number, is_starter, is_opponent, x, y) "
                "VALUES ($1, NULLIF($2, ''), $3, true, true, $4, $5)",
                frameId, o.value("label", std::string()), slot++, o.at("x").get<double>(), o.at("y").get<double>());
        }
        if (body.contains("ball") && body["ball"].is_object())
            tx->exec_params(
                "INSERT INTO tactical_frame_objects (frame_id, object_type, x, y) VALUES ($1, 'ball', $2, $3)",
                frameId, body["ball"].at("x").get<double>(), body["ball"].at("y").get<double>());
        tx->exec_params(
            "UPDATE tactical_boards SET updated_at = now(), created_by_user_id = COALESCE(created_by_user_id, $2) WHERE id = $1",
            boardId, byUserId);
        db->commit(tx);
        return true;
    } catch (...) {
        db->rollback(tx);
        throw;
    }
}
