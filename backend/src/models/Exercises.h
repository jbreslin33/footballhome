#pragma once
#include "../third_party/json.hpp"

// Exercises — 🏋️ the exercise catalog (mig 2191): every exercise from every
// source (books first), one primary category each, in our own words.
class Exercises {
public:
    // { categories: [{id, code, label, icon, description}],
    //   oppositions: [{code, label}],
    //   sources: [{id, title, book_id}],
    //   exercises: [{id, title, category_id, opposition, moment, source_id, book_id,
    //                page_from, page_to, source_ref, coach, objective, players,
    //                min, max, area, goals, keepers, directional}] }
    static nlohmann::json catalog();

    // Full row incl. setup / procedure / rules / progressions / coaching points,
    // the category and source titles; null when not found.
    static nlohmann::json one(int id);
};
