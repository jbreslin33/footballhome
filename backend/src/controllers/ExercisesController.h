#pragma once
#include <string>
#include "../core/Controller.h"

// ExercisesController — 🏋️ #exercises (mig 2191), the exercise catalog.
// Signed-in members (the page sits under Football for coaches).
//
//   GET /api/exercises       { categories, oppositions, sources, exercises: [light rows], book_pages }
//   GET /api/exercises/:id   { exercise: full write-up }
//
// book_pages = whether this viewer may open the book page images
// (/api/coaching-books/:book/pages/:n — owner only, menu_page_people 'books').
class ExercisesController : public Controller {
public:
    ExercisesController();
    void registerRoutes(Router& router, const std::string& prefix) override;
private:
    Response handleList(const Request& request);
    Response handleOne(const Request& request);
};
