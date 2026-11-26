#pragma once
#include <string>
#include "../core/Controller.h"

// StudyController — 🎓 #study (mig 1937): the signed-in person's own study plans.
//
//   GET  /api/study                               { plans }
//   POST /api/study/answer  {question_id, given}  { is_correct, answer, answer_text, solution, plans }
//   POST /api/study/mark    {topic_id, status}    status learning | confident | ""   → { plans }
//   POST /api/study/date    {plan_id, date}       date YYYY-MM-DD | ""              → { plans }
//
// Open to anyone with a study_plans row; never another person's plan.
class StudyController : public Controller {
public:
    StudyController();
    void registerRoutes(Router& router, const std::string& prefix) override;
};
