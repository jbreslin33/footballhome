#pragma once
#include <string>
#include "../core/Controller.h"

// CoachingBooksController — 📚 #books, owner only (mig 1928).
//
//   GET /api/coaching-books                     { books, moments }
//   GET /api/coaching-books/:book/pages/:page   { image (base64), mime, page_count }
//
// The page images are bought copies of copyrighted books: only the people
// menu_page_people lists for 'books' (the owner), never a public URL.
class CoachingBooksController : public Controller {
public:
    CoachingBooksController();
    void registerRoutes(Router& router, const std::string& prefix) override;
private:
    bool gate(const Request& request, Response* error);
    Response handleLibrary(const Request& request);
    Response handlePage(const Request& request);
};
