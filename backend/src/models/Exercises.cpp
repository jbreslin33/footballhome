#include "Exercises.h"

#include "../database/Database.h"

using json = nlohmann::json;

namespace {
json txt(const pqxx::field& f) { return f.is_null() ? json(nullptr) : json(f.c_str()); }
json num(const pqxx::field& f) { return f.is_null() ? json(nullptr) : json(f.as<double>()); }
json in(const pqxx::field& f)  { return f.is_null() ? json(nullptr) : json(f.as<int>()); }
json bl(const pqxx::field& f)  { return f.is_null() ? json(nullptr) : json(f.as<bool>()); }
}

json Exercises::catalog() {
    auto* db = Database::getInstance();
    json out = {{"categories", json::array()}, {"oppositions", json::array()},
                {"sources", json::array()}, {"exercises", json::array()}};
    for (const auto& r : db->query("SELECT id, code, label, icon, description FROM exercise_categories ORDER BY sort_order, id"))
        out["categories"].push_back({{"id", r["id"].as<int>()}, {"code", r["code"].c_str()}, {"label", r["label"].c_str()},
                                     {"icon", txt(r["icon"])}, {"description", r["description"].c_str()}});
    for (const auto& r : db->query("SELECT code, label FROM exercise_oppositions ORDER BY sort_order"))
        out["oppositions"].push_back({{"code", r["code"].c_str()}, {"label", r["label"].c_str()}});
    // Every book (read for exercises or not) plus any other source that has
    // exercises; a book shows by its own title.  count = active exercises.
    for (const auto& r : db->query(
            "SELECT s.id, COALESCE(b.title, s.title) AS title, b.id AS book_id, b.author, b.page_count, "
            "       (SELECT count(*) FROM exercises e WHERE e.source_id = s.id AND e.is_active) AS n "
            "  FROM game_sources s LEFT JOIN coaching_books b ON b.source_id = s.id "
            " WHERE b.id IS NOT NULL OR EXISTS (SELECT 1 FROM exercises e WHERE e.source_id = s.id AND e.is_active) "
            " ORDER BY 2"))
        out["sources"].push_back({{"id", r["id"].as<int>()}, {"title", r["title"].c_str()}, {"book_id", in(r["book_id"])},
                                  {"author", txt(r["author"])}, {"pages", in(r["page_count"])}, {"count", r["n"].as<int>()}});
    for (const auto& r : db->query(
            "SELECT id, title, category_id, opposition, moment, source_id, book_id, page_from, page_to, source_ref, coach, "
            "       objective, players_text, min_players, max_players, area_text, has_goals, has_keepers, directional "
            "  FROM exercises WHERE is_active ORDER BY source_id, sort_order, id"))
        out["exercises"].push_back({
            {"id", r["id"].as<int>()}, {"title", r["title"].c_str()}, {"category_id", r["category_id"].as<int>()},
            {"opposition", txt(r["opposition"])}, {"moment", txt(r["moment"])}, {"source_id", r["source_id"].as<int>()},
            {"book_id", in(r["book_id"])}, {"page_from", in(r["page_from"])}, {"page_to", in(r["page_to"])},
            {"source_ref", txt(r["source_ref"])}, {"coach", txt(r["coach"])}, {"objective", r["objective"].c_str()},
            {"players", txt(r["players_text"])}, {"min", in(r["min_players"])}, {"max", in(r["max_players"])},
            {"area", txt(r["area_text"])}, {"goals", bl(r["has_goals"])}, {"keepers", bl(r["has_keepers"])},
            {"directional", bl(r["directional"])}});
    return out;
}

json Exercises::one(int id) {
    auto r = Database::getInstance()->query(
        "SELECT e.*, c.label AS category_label, c.icon AS category_icon, COALESCE(b.title, s.title) AS source_title, "
        "       b.author AS book_author "
        "  FROM exercises e JOIN exercise_categories c ON c.id = e.category_id "
        "  JOIN game_sources s ON s.id = e.source_id LEFT JOIN coaching_books b ON b.id = e.book_id "
        " WHERE e.id = $1::int", {std::to_string(id)});
    if (r.empty()) return nullptr;
    const auto& x = r[0];
    return {
        {"id", x["id"].as<int>()}, {"title", x["title"].c_str()},
        {"category_id", x["category_id"].as<int>()}, {"category", x["category_label"].c_str()}, {"category_icon", txt(x["category_icon"])},
        {"opposition", txt(x["opposition"])}, {"moment", txt(x["moment"])},
        {"source_id", x["source_id"].as<int>()}, {"source", x["source_title"].c_str()}, {"author", txt(x["book_author"])},
        {"book_id", in(x["book_id"])}, {"page_from", in(x["page_from"])}, {"page_to", in(x["page_to"])},
        {"source_ref", txt(x["source_ref"])}, {"coach", txt(x["coach"])},
        {"objective", x["objective"].c_str()}, {"setup", txt(x["setup"])}, {"procedure", txt(x["procedure"])},
        {"rules", txt(x["rules"])}, {"progressions", txt(x["progressions"])}, {"coaching_points", txt(x["coaching_points"])},
        {"players", txt(x["players_text"])}, {"min", in(x["min_players"])}, {"max", in(x["max_players"])},
        {"area", txt(x["area_text"])}, {"length_m", num(x["area_length_m"])}, {"width_m", num(x["area_width_m"])},
        {"duration_min", num(x["duration_min"])}, {"goals", bl(x["has_goals"])}, {"keepers", bl(x["has_keepers"])},
        {"directional", bl(x["directional"])}, {"age", txt(x["age_text"])}};
}
