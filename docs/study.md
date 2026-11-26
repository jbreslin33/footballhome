# 🎓 Study (`#study`, mig 1937)

Owner 2026-11-26: "i need a project on fh lol to prepare for the math 7-12
praxis for pa so i can teach it" · "this is an example of how fh can help
players/coaches beyond football".

A **study plan belongs to a person**: a test, the topics on it, practice with
worked answers, and the person's own progress. The first plan is the owner's
Praxis Mathematics (5165) for the Pennsylvania Mathematics 7-12 certificate.
Giving a player or coach a plan is one `study_plans` row; a trigger adds them to
`menu_page_people` so the 🎓 Learn menu shows them the page.

## The test (5165)

From the ETS Study Companion
(<https://praxis.ets.org/on/demandware.static/-/Library-Sites-ets-praxisLibrary/default/pdfs/5165.pdf>):
180 minutes, 66 questions (select one or more, numeric entry, other types), an
on-screen graphing calculator, about 25% of questions set in a teaching
scenario.

| Area | ≈ questions | % |
|---|---|---|
| I. Number & Quantity and Algebra (IA 7, IB 13) | 20 | 30 |
| II. Functions and Calculus (IIA 13, IIB 7) | 20 | 30 |
| III. Geometry | 13 | 20 |
| IV. Statistics & Probability | 13 | 20 |
| Tasks of Teaching Mathematics (across the content) | ≈17 | ≈25 |

The outline is loaded as written: 13 areas, 66 numbered topics (45 content + 21
teaching tasks), 176 lettered points.
Passing score in PA: **159** (scale 100–200), from the Mercyhurst 2025 and Wilkes
testing guides. Re-check it on praxis.ets.org before registering.

## Tables

- `study_exams`: the test (time, questions, calculator, passing score + source, links)
- `study_areas`: content categories, `parent_id` for IA/IB…, `is_overlay` for the teaching tasks
- `study_topics`, `study_topic_points`: the outline
- `study_questions` (+ `study_question_kinds` single / multi / numeric): practice.
  `answer` is an index, an array of indexes, or a number (with `tolerance`).
  These are Football Home originals, not ETS's sample questions (those stay in the Study Companion).
- `study_plans`: person + exam + `test_date`
- `study_topic_marks`: learning / confident per topic
- `study_answers`: every answer, right or wrong

## Code

- `backend/src/models/Study.cpp` and `controllers/StudyController.cpp`, under
  `/api/study` (GET board; POST `/answer`, `/mark`, `/date`). They only ever
  touch the signed-in person's own plans, and the board never carries answers.
- `frontend/js/screens/study.js` (`StudyScreen`) shows:
  - the test card with the 📅 test date
  - 🗓 This week: the topics not yet confident, spread evenly over the weeks left, 🟡 first
  - ✏️ Practice: this week's topics and never-right questions come first; ✏️ Practise narrows it to one topic
  - 📚 What's on the test: ⚪/🟡/🟢 per topic
- Page wording is in `message_templates` kind `study`.

## Adding

- More questions: write a migration that inserts into `study_questions` and finds the topic by exam code + area code + topic number.
- Another test: add a `study_exams` row with its areas, topics and points, then give a person a `study_plans` row.
