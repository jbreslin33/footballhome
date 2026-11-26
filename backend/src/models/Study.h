#pragma once
#include <string>

#include "../third_party/json.hpp"

// Study — 🎓 #study (mig 1937): a person's study plan for a test.  First one:
// the owner's Praxis Mathematics (5165) for the PA Mathematics 7-12 certificate
// (owner 2026-11-26: "this is an example of how fh can help players/coaches
// beyond football").  A plan belongs to a person; any player or coach can be
// given one.
//
//   study_exams → study_areas → study_topics → study_topic_points   the test
//   study_questions                                                 practice
//   study_plans (person + exam + test date)
//   study_topic_marks (learning / confident), study_answers         progress
//
// Every call works on the signed-in person's own plans only.
class Study {
public:
    // users.id → persons.id (0 = none).
    static long long personForUser(long long userId);
    static bool hasPlan(long long personId);

    // { plans: [{ id, test_date, exam:{…}, areas:[{…, topics:[{…, points, mark, asked, right}]}],
    //             questions:[{id, topic_id, kind, prompt, choices, tries, right}], answered, right }] }
    // Answers and solutions are NOT in the board — they come back from answer().
    static nlohmann::json board(long long personId);

    // Check one practice answer and log it.  given: index (single), [indexes] (multi), number (numeric).
    // → { is_correct, answer, solution }; *error set when the question isn't on one of the person's plans.
    static nlohmann::json answer(long long personId, long long questionId, const nlohmann::json& given, std::string* error);

    // status: "learning" | "confident" | "" (back to not started).  "" = ok, else why not.
    static std::string mark(long long personId, long long topicId, const std::string& status);

    // date: "YYYY-MM-DD" or "" (no date yet).
    static std::string setTestDate(long long personId, long long planId, const std::string& date);
};
