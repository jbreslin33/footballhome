#pragma once
#include "../third_party/json.hpp"

// FilmAnalysis — 🎥 #film-analysis (mig 1993).  Reads the rows that
// scripts/film/ loads for a clip and works out the clip's numbers.  Any
// clip length: the numbers are per-frame averages / sums over whatever
// frames the clip has.
//
//   list()      every clip, newest first: id, title, film window, frames
//   clip(id)    the clip + kits + replay file id + numbers + the per-frame
//               pitch positions the mini-pitch draws (null when no clip)
class FilmAnalysis {
public:
    static nlohmann::json list();
    static nlohmann::json clip(long long id);
};
