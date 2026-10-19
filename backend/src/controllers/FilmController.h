#pragma once
#include <string>
#include "../core/Controller.h"

// FilmController — the #film page (mig 599): the league's game-film sheet
// mirrored read-only, each link matched FUZZILY to the game (owner: "the
// date may not always match up so you got to sometimes use fuzzy logic
// based on home team and around when it was and schedule").  The sheet's
// home team resolves through film_team_aliases; the nearest APSL fixture
// involving that club within the matchday window ±3 days names the game.
// The feed's home/away flag is not trusted (it disagrees with gcal).
//
//   GET /api/film   { rows: [{ matchday, from, till, home_team, url,
//                              game: {on, day_label, opponent} | null }] }
class FilmController : public Controller {
public:
    FilmController();
    void registerRoutes(Router& router, const std::string& prefix) override;
private:
    Response handleList(const Request& request);
};
