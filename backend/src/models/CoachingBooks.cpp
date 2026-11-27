#include "CoachingBooks.h"

#include <algorithm>
#include <map>

#include "../database/Database.h"

using json = nlohmann::json;

json CoachingBooks::library() {
    auto* db = Database::getInstance();
    json out = {{"books", json::array()}, {"moments", json::array()}};

    for (const auto& r : db->query("SELECT code, title FROM game_moments ORDER BY sort_order"))
        out["moments"].push_back({{"code", r["code"].c_str()}, {"title", r["title"].c_str()}});

    // Patterns with their roles, folded per book in C++.
    std::map<int, json> roles;   // pattern id → [{role, job}]
    for (const auto& r : db->query(
            "SELECT pattern_id, role, job FROM coaching_book_pattern_roles ORDER BY pattern_id, sort_order"))
        roles[r["pattern_id"].as<int>()].push_back({{"role", r["role"].c_str()}, {"job", r["job"].c_str()}});

    std::map<int, json> patterns;   // book id → [pattern]
    auto txt = [](const pqxx::field& f) { return f.is_null() ? json(nullptr) : json(f.c_str()); };
    for (const auto& r : db->query(
            "SELECT id, book_id, moment, chapter, title, situation, trigger_text, outcome, vs_formation, "
            "       page_from, page_to FROM coaching_book_patterns ORDER BY book_id, sort_order, id")) {
        const int id = r["id"].as<int>();
        patterns[r["book_id"].as<int>()].push_back({
            {"id", id}, {"moment", r["moment"].c_str()}, {"chapter", txt(r["chapter"])},
            {"title", r["title"].c_str()}, {"situation", r["situation"].c_str()},
            {"trigger", txt(r["trigger_text"])}, {"outcome", txt(r["outcome"])},
            {"vs_formation", txt(r["vs_formation"])},
            {"page_from", r["page_from"].as<int>()}, {"page_to", r["page_to"].as<int>()},
            {"roles", roles.count(id) ? roles[id] : json::array()}});
    }

    for (const auto& r : db->query(
            "SELECT b.id, b.slug, b.title, b.subtitle, b.author, b.team, b.season, b.method_note, "
            "       COALESCE(b.page_count, (SELECT max(page_no) FROM coaching_book_pages p WHERE p.book_id = b.id), 0) AS page_count "
            "  FROM coaching_books b ORDER BY b.sort_order, b.title")) {
        const int id = r["id"].as<int>();
        out["books"].push_back({
            {"id", id}, {"slug", r["slug"].c_str()}, {"title", r["title"].c_str()},
            {"subtitle", txt(r["subtitle"])}, {"author", r["author"].c_str()},
            {"team", txt(r["team"])}, {"season", txt(r["season"])},
            {"method_note", txt(r["method_note"])}, {"page_count", r["page_count"].as<int>()},
            {"patterns", patterns.count(id) ? patterns[id] : json::array()}});
    }
    return out;
}

json CoachingBooks::page(int bookId, int pageNo) {
    auto r = Database::getInstance()->query(
        "SELECT p.mime, encode(p.bytes, 'base64') AS b64, "
        "       COALESCE(b.page_count, (SELECT max(page_no) FROM coaching_book_pages x WHERE x.book_id = b.id)) AS page_count "
        "  FROM coaching_book_pages p JOIN coaching_books b ON b.id = p.book_id "
        " WHERE p.book_id = $1::int AND p.page_no = $2::int",
        {std::to_string(bookId), std::to_string(pageNo)});
    if (r.empty()) return nullptr;
    std::string b64 = r[0]["b64"].c_str();
    b64.erase(std::remove(b64.begin(), b64.end(), '\n'), b64.end());   // encode() wraps at 76
    return {{"book_id", bookId}, {"page_no", pageNo}, {"page_count", r[0]["page_count"].as<int>()},
            {"mime", r[0]["mime"].c_str()}, {"image", b64}};
}
