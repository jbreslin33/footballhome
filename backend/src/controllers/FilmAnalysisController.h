#pragma once
#include <string>
#include "../core/Controller.h"

// FilmAnalysisController — 🎥 #film-analysis (mig 1993).  Signed-in
// members (the page sits under Football for coaches; same reach as #film).
//
//   GET /api/film-analysis        { clips: [{id, title, source_url, start, end, fps, frames, made_on}] }
//   GET /api/film-analysis/:id    { clip, kits, stats, frames }   — see models/FilmAnalysis
//
// The replay video is a club_files row (visibility 'members'), fetched by
// the page through /api/files/dl/:id.
class FilmAnalysisController : public Controller {
public:
    FilmAnalysisController();
    void registerRoutes(Router& router, const std::string& prefix) override;
private:
    Response handleList(const Request& request);
    Response handleClip(const Request& request);
};
