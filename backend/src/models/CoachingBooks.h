#pragma once
#include <string>
#include "../third_party/json.hpp"

// CoachingBooks — 📚 the owner's Soccer Tutor library (mig 1928).
// Books, the team patterns written up from them (our words, cited by page),
// and the captured page images.  Owner only: the controller lets in just the
// people menu_page_people lists for 'books'.
class CoachingBooks {
public:
    // { books: [{id, slug, title, subtitle, author, team, season, page_count,
    //            method_note, patterns: [{id, moment, chapter, title, situation,
    //            trigger, outcome, vs_formation, page_from, page_to,
    //            roles: [{role, job}]}]}],
    //   moments: [{code, title}] }
    static nlohmann::json library();

    // One page image: { book_id, page_no, page_count, mime, image (base64) }
    // or null when the page isn't loaded.
    static nlohmann::json page(int bookId, int pageNo);
};
