#include "PersonTodos.h"

#include "../database/Database.h"

using json = nlohmann::json;

json PersonTodos::list(long long personId) {
    json out = {{"todos", json::array()}, {"due", 0}};
    if (personId <= 0) return out;
    auto* db = Database::getInstance();
    auto rows = db->query(R"SQL(
        SELECT id, body,
               to_char(remind_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"') AS remind_at,
               to_char(done_at   AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"') AS done_at,
               (done_at IS NULL AND (remind_at IS NULL OR remind_at <= now())) AS due
          FROM person_todos
         WHERE person_id = $1::int
           AND (done_at IS NULL OR done_at > now() - INTERVAL '7 days')
         ORDER BY done_at IS NOT NULL, done_at DESC, remind_at NULLS FIRST, id
    )SQL", {std::to_string(personId)});
    int due = 0;
    for (const auto& r : rows) {
        const bool isDue = r["due"].as<bool>();
        if (isDue) ++due;
        out["todos"].push_back({
            {"id",        r["id"].as<long long>()},
            {"body",      r["body"].c_str()},
            {"remind_at", r["remind_at"].is_null() ? json(nullptr) : json(r["remind_at"].c_str())},
            {"done_at",   r["done_at"].is_null()   ? json(nullptr) : json(r["done_at"].c_str())},
            {"due",       isDue},
        });
    }
    out["due"] = due;
    return out;
}

std::string PersonTodos::add(long long personId, const std::string& body, const std::string& remindAtIso) {
    if (personId <= 0) return "Sign in first";
    const auto b = body.find_first_not_of(" \t\r\n");
    if (b == std::string::npos) return "Type what to do";
    if (body.size() > 500) return "Keep it under 500 characters";
    auto* db = Database::getInstance();
    try {
        db->query(
            "INSERT INTO person_todos (person_id, body, remind_at) "
            "VALUES ($1::int, btrim($2), NULLIF($3, '')::timestamptz)",
            {std::to_string(personId), body, remindAtIso});
    } catch (const std::exception&) {
        return "That time didn't read — pick it again";
    }
    return "";
}

bool PersonTodos::setDone(long long personId, long long id, bool done) {
    auto* db = Database::getInstance();
    auto r = db->query(
        std::string("UPDATE person_todos SET done_at = ") + (done ? "now()" : "NULL") +
        " WHERE id = $1::bigint AND person_id = $2::int RETURNING id",
        {std::to_string(id), std::to_string(personId)});
    return !r.empty();
}

bool PersonTodos::remove(long long personId, long long id) {
    auto* db = Database::getInstance();
    auto r = db->query(
        "DELETE FROM person_todos WHERE id = $1::bigint AND person_id = $2::int RETURNING id",
        {std::to_string(id), std::to_string(personId)});
    return !r.empty();
}
