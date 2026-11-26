#include "Study.h"

#include <cmath>
#include <regex>
#include <set>

#include "../database/Database.h"

using json = nlohmann::json;

long long Study::personForUser(long long userId) {
    if (userId <= 0) return 0;
    auto r = Database::getInstance()->query(
        "SELECT person_id FROM users WHERE id = $1::bigint AND person_id IS NOT NULL", {std::to_string(userId)});
    return r.empty() ? 0 : r[0][0].as<long long>();
}

bool Study::hasPlan(long long personId) {
    if (personId <= 0) return false;
    return !Database::getInstance()->query(
        "SELECT 1 FROM study_plans WHERE person_id = $1::int", {std::to_string(personId)}).empty();
}

json Study::board(long long personId) {
    // One query builds the whole board; the outline is nested in order.
    auto r = Database::getInstance()->query(R"SQL(
        WITH pl AS (SELECT * FROM study_plans WHERE person_id = $1::int),
        tries AS (
            SELECT a.plan_id, a.question_id, count(*) AS tries, bool_or(a.is_correct) AS ever_right
              FROM study_answers a JOIN pl ON pl.id = a.plan_id
             GROUP BY a.plan_id, a.question_id)
        SELECT COALESCE(json_agg(json_build_object(
            'id', pl.id,
            'test_date', pl.test_date,
            'exam', (SELECT row_to_json(x) FROM (
                SELECT e.code, e.title, e.provider, e.test_code, e.minutes, e.question_count, e.formats, e.calculator,
                       e.score_min, e.score_max, e.pass_score, e.pass_score_state, e.pass_score_source,
                       e.companion_url, e.register_url, e.note
                  FROM study_exams e WHERE e.id = pl.exam_id) x),
            'areas', (SELECT COALESCE(json_agg(json_build_object(
                    'id', ar.id, 'code', ar.code, 'name', ar.name, 'parent_code', par.code,
                    'approx_questions', ar.approx_questions, 'pct', ar.pct, 'is_overlay', ar.is_overlay,
                    'topics', (SELECT COALESCE(json_agg(json_build_object(
                            'id', t.id, 'num', t.num, 'statement', t.statement,
                            'mark', m.status,
                            'points', (SELECT COALESCE(json_agg(json_build_object('letter', p.letter, 'statement', p.statement)
                                                                ORDER BY p.sort_order), '[]'::json)
                                         FROM study_topic_points p WHERE p.topic_id = t.id),
                            'asked', (SELECT COALESCE(sum(tr.tries), 0) FROM tries tr JOIN study_questions q ON q.id = tr.question_id
                                       WHERE tr.plan_id = pl.id AND q.topic_id = t.id),
                            'right', (SELECT count(*) FROM tries tr JOIN study_questions q ON q.id = tr.question_id
                                       WHERE tr.plan_id = pl.id AND q.topic_id = t.id AND tr.ever_right),
                            'questions', (SELECT count(*) FROM study_questions q WHERE q.topic_id = t.id AND q.is_active)
                        ) ORDER BY t.sort_order), '[]'::json)
                        FROM study_topics t
                        LEFT JOIN study_topic_marks m ON m.plan_id = pl.id AND m.topic_id = t.id
                       WHERE t.area_id = ar.id)
                ) ORDER BY ar.sort_order), '[]'::json)
                FROM study_areas ar LEFT JOIN study_areas par ON par.id = ar.parent_id
               WHERE ar.exam_id = pl.exam_id),
            'questions', (SELECT COALESCE(json_agg(json_build_object(
                    'id', q.id, 'topic_id', q.topic_id, 'kind', q.kind, 'kind_label', k.label,
                    'prompt', q.prompt, 'choices', q.choices,
                    'tries', COALESCE(tr.tries, 0), 'right', COALESCE(tr.ever_right, false)
                ) ORDER BY q.sort_order), '[]'::json)
                FROM study_questions q
                JOIN study_question_kinds k ON k.code = q.kind
                JOIN study_topics t ON t.id = q.topic_id
                JOIN study_areas ar ON ar.id = t.area_id
                LEFT JOIN tries tr ON tr.plan_id = pl.id AND tr.question_id = q.id
               WHERE ar.exam_id = pl.exam_id AND q.is_active),
            'answered', (SELECT count(*) FROM study_answers a WHERE a.plan_id = pl.id),
            'right', (SELECT count(*) FROM study_answers a WHERE a.plan_id = pl.id AND a.is_correct)
        ) ORDER BY pl.id), '[]'::json)::text AS plans
          FROM pl)SQL", {std::to_string(personId)});
    json plans = json::parse(r[0]["plans"].c_str(), nullptr, false);
    return {{"plans", plans.is_array() ? plans : json::array()}};
}

json Study::answer(long long personId, long long questionId, const json& given, std::string* error) {
    auto* db = Database::getInstance();
    auto r = db->query(R"SQL(
        SELECT pl.id AS plan_id, q.kind, q.answer::text AS answer, q.tolerance::float8 AS tol, q.solution,
               COALESCE(q.choices::text, 'null') AS choices
          FROM study_questions q
          JOIN study_topics t ON t.id = q.topic_id
          JOIN study_areas ar ON ar.id = t.area_id
          JOIN study_plans pl ON pl.exam_id = ar.exam_id AND pl.person_id = $1::int
         WHERE q.id = $2::int AND q.is_active)SQL",
        {std::to_string(personId), std::to_string(questionId)});
    if (r.empty()) { *error = "That question isn't on your study plan."; return nullptr; }

    const std::string kind = r[0]["kind"].c_str();
    const json right = json::parse(r[0]["answer"].c_str());
    const json choices = json::parse(r[0]["choices"].c_str());
    bool ok = false;
    if (kind == "numeric") {
        if (!given.is_number()) { *error = "Enter a number."; return nullptr; }
        ok = std::fabs(given.get<double>() - right.get<double>()) <= r[0]["tol"].as<double>() + 1e-9;
    } else if (kind == "single") {
        if (!given.is_number_integer()) { *error = "Pick an answer."; return nullptr; }
        ok = given.get<long long>() == right.get<long long>();
    } else {  // multi: the same set of choices
        if (!given.is_array() || given.empty()) { *error = "Pick at least one answer."; return nullptr; }
        std::set<long long> a, b;
        for (const auto& x : given) if (x.is_number_integer()) a.insert(x.get<long long>());
        for (const auto& x : right) b.insert(x.get<long long>());
        ok = a == b;
    }
    db->query("INSERT INTO study_answers (plan_id, question_id, given, is_correct) VALUES ($1::int, $2::int, $3::jsonb, $4::boolean)",
              {r[0]["plan_id"].c_str(), std::to_string(questionId), given.dump(), ok ? "true" : "false"});

    // The right answer as words, for "the answer is …".
    std::string words;
    if (kind == "numeric") {
        words = right.dump();
    } else if (kind == "single") {
        const auto i = right.get<size_t>();
        words = choices.is_array() && i < choices.size() ? choices[i].get<std::string>() : right.dump();
    } else {
        for (const auto& x : right) {
            const auto i = x.get<size_t>();
            if (!words.empty()) words += "; ";
            words += choices.is_array() && i < choices.size() ? choices[i].get<std::string>() : x.dump();
        }
    }
    return {{"is_correct", ok}, {"answer", right}, {"answer_text", words}, {"solution", r[0]["solution"].c_str()}};
}

std::string Study::mark(long long personId, long long topicId, const std::string& status) {
    if (!status.empty() && status != "learning" && status != "confident") return "Unknown status.";
    auto* db = Database::getInstance();
    auto plan = db->query(R"SQL(
        SELECT pl.id FROM study_topics t JOIN study_areas ar ON ar.id = t.area_id
          JOIN study_plans pl ON pl.exam_id = ar.exam_id AND pl.person_id = $1::int
         WHERE t.id = $2::int)SQL", {std::to_string(personId), std::to_string(topicId)});
    if (plan.empty()) return "That topic isn't on your study plan.";
    const std::string planId = plan[0][0].c_str();
    if (status.empty()) {
        db->query("DELETE FROM study_topic_marks WHERE plan_id = $1::int AND topic_id = $2::int", {planId, std::to_string(topicId)});
    } else {
        db->query(R"SQL(
            INSERT INTO study_topic_marks (plan_id, topic_id, status) VALUES ($1::int, $2::int, $3)
            ON CONFLICT (plan_id, topic_id) DO UPDATE SET status = EXCLUDED.status, updated_at = now())SQL",
            {planId, std::to_string(topicId), status});
    }
    return "";
}

std::string Study::setTestDate(long long personId, long long planId, const std::string& date) {
    static const std::regex ymd(R"(^\d{4}-\d{2}-\d{2}$)");
    if (!date.empty() && !std::regex_match(date, ymd)) return "Date must be YYYY-MM-DD.";
    auto r = Database::getInstance()->query(
        "UPDATE study_plans SET test_date = NULLIF($3, '')::date WHERE id = $1::int AND person_id = $2::int RETURNING id",
        {std::to_string(planId), std::to_string(personId), date});
    return r.empty() ? "That isn't your study plan." : "";
}
