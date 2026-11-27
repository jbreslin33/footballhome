#include "FilmAnalysis.h"

#include <algorithm>
#include <cmath>
#include <map>
#include <string>
#include <vector>

#include "../database/Database.h"

using json = nlohmann::json;

namespace {
std::string str(const pqxx::row& r, const char* c) { return r[c].is_null() ? std::string{} : std::string(r[c].c_str()); }
double num(const pqxx::row& r, const char* c) { return r[c].is_null() ? 0.0 : r[c].as<double>(); }
double round1(double v) { return std::round(v * 10.0) / 10.0; }

struct Spot { std::string kind, kit; int track = -1; double x = 0, y = 0; bool placed = false; };
struct Frame { int frame = 0; double t = 0; std::vector<Spot> people; bool ball = false, ballPlaced = false; double bx = 0, by = 0; };
}  // namespace

json FilmAnalysis::list() {
    auto* db = Database::getInstance();
    json out = json::array();
    for (const auto& r : db->query(R"SQL(
            SELECT c.id, c.title, c.source_url, c.video_start_sec, c.video_end_sec, c.analysis_fps,
                   to_char(c.created_at AT TIME ZONE 'America/New_York', 'Mon FMDD') AS made_on,
                   (SELECT count(*) FROM film_clip_camera k WHERE k.clip_id = c.id) AS frames
              FROM film_clips c ORDER BY c.created_at DESC, c.id DESC)SQL")) {
        out.push_back({{"id", r["id"].as<long long>()}, {"title", str(r, "title")}, {"source_url", str(r, "source_url")},
                       {"start", num(r, "video_start_sec")}, {"end", num(r, "video_end_sec")},
                       {"fps", num(r, "analysis_fps")}, {"made_on", str(r, "made_on")},
                       {"frames", r["frames"].as<long long>()}});
    }
    return out;
}

json FilmAnalysis::clip(long long id) {
    auto* db = Database::getInstance();
    const std::string sid = std::to_string(id);
    auto c = db->query(R"SQL(
        SELECT id, title, source_url, video_start_sec, video_end_sec, analysis_fps, pitch_length_m, pitch_width_m,
               camera_x_m, camera_y_m, camera_z_m, replay_file_id, pipeline_note
          FROM film_clips WHERE id = $1::int)SQL", {sid});
    if (c.empty()) return nullptr;
    const auto& cr = c[0];
    const double L = num(cr, "pitch_length_m"), W = num(cr, "pitch_width_m");

    json kits = json::array();
    for (const auto& r : db->query(
            "SELECT kit, team_label, is_ours FROM film_clip_kits WHERE clip_id = $1::int ORDER BY sort_order, kit", {sid}))
        kits.push_back({{"kit", str(r, "kit")}, {"label", str(r, "team_label")},
                        {"is_ours", r["is_ours"].is_null() ? json(nullptr) : json(r["is_ours"].as<bool>())}});

    // Frames come from the camera table (every analysed frame has a row);
    // detections hang off them.
    std::map<int, Frame> frames;
    int solved = 0;
    for (const auto& r : db->query(
            "SELECT frame, t_sec, solved FROM film_clip_camera WHERE clip_id = $1::int ORDER BY frame", {sid})) {
        Frame f; f.frame = r["frame"].as<int>(); f.t = num(r, "t_sec");
        if (r["solved"].as<bool>()) ++solved;
        frames[f.frame] = f;
    }
    for (const auto& r : db->query(R"SQL(
            SELECT frame, t_sec, kind, kit, track_id, pitch_x, pitch_y
              FROM film_clip_detections WHERE clip_id = $1::int ORDER BY frame, id)SQL", {sid})) {
        const int fr = r["frame"].as<int>();
        auto& f = frames[fr];
        f.frame = fr; f.t = num(r, "t_sec");
        const bool placed = !r["pitch_x"].is_null() && !r["pitch_y"].is_null();
        if (str(r, "kind") == "ball") {
            f.ball = true; f.ballPlaced = placed;
            if (placed) { f.bx = num(r, "pitch_x"); f.by = num(r, "pitch_y"); }
            continue;
        }
        Spot s; s.kind = str(r, "kind"); s.kit = str(r, "kit");
        s.track = r["track_id"].is_null() ? -1 : r["track_id"].as<int>();
        s.placed = placed;
        if (placed) { s.x = num(r, "pitch_x"); s.y = num(r, "pitch_y"); }
        f.people.push_back(s);
    }

    // ── numbers
    const double n = std::max<size_t>(1, frames.size());
    int ballFrames = 0, ballPlacedN = 0, thirds[3] = {0, 0, 0};
    double ballDist = 0;
    const Frame* prev = nullptr;
    const double step = num(cr, "analysis_fps") > 0 ? 1.0 / num(cr, "analysis_fps") : 0.1;
    struct KitAcc { double seen = 0, sx = 0, sy = 0, cnt = 0, width = 0, depth = 0, shapeFrames = 0, nearest = 0; };
    std::map<std::string, KitAcc> acc;
    double refs = 0, nearestTotal = 0;
    for (const auto& [fr, f] : frames) {
        std::map<std::string, std::vector<const Spot*>> byKit;
        for (const auto& s : f.people) {
            if (s.kind == "referee") { refs += 1; continue; }
            const std::string k = s.kind == "goalkeeper" ? "goalkeeper" : (s.kit.empty() ? "unknown" : s.kit);
            acc[k].seen += 1;
            if (s.placed) { acc[k].sx += s.x; acc[k].sy += s.y; acc[k].cnt += 1; byKit[k].push_back(&s); }
        }
        for (const auto& [k, v] : byKit) {
            if (k == "goalkeeper" || k == "unknown" || v.size() < 3) continue;
            double minx = 1e9, maxx = -1e9, miny = 1e9, maxy = -1e9;
            for (const Spot* s : v) { minx = std::min(minx, s->x); maxx = std::max(maxx, s->x); miny = std::min(miny, s->y); maxy = std::max(maxy, s->y); }
            acc[k].width += maxy - miny; acc[k].depth += maxx - minx; acc[k].shapeFrames += 1;
        }
        if (f.ball) ++ballFrames;
        if (f.ballPlaced) {
            ++ballPlacedN;
            thirds[f.bx < -L / 6 ? 0 : (f.bx > L / 6 ? 2 : 1)]++;
            if (prev && prev->ballPlaced && std::abs((f.t - prev->t) - step) < step * 0.5) {
                const double d = std::hypot(f.bx - prev->bx, f.by - prev->by);
                if (d < 40.0 * step) ballDist += d;            // > 40 m/s = a wrong spot, not a pass
            }
            const Spot* best = nullptr; double bd = 4.0;          // nearest player within 4 m
            for (const auto& s : f.people) {
                if (!s.placed || s.kind == "referee") continue;
                const double d = std::hypot(s.x - f.bx, s.y - f.by);
                if (d < bd) { bd = d; best = &s; }
            }
            if (best) {
                acc[best->kind == "goalkeeper" ? "goalkeeper" : (best->kit.empty() ? "unknown" : best->kit)].nearest += 1;
                nearestTotal += 1;
            }
        }
        prev = &f;
    }

    json teams = json::array();
    for (const auto& [k, a] : acc) {
        teams.push_back({
            {"kit", k},
            {"seen_per_frame", round1(a.seen / n)},
            {"avg_x", a.cnt ? json(round1(a.sx / a.cnt)) : json(nullptr)},
            {"avg_y", a.cnt ? json(round1(a.sy / a.cnt)) : json(nullptr)},
            {"width", a.shapeFrames ? json(round1(a.width / a.shapeFrames)) : json(nullptr)},
            {"depth", a.shapeFrames ? json(round1(a.depth / a.shapeFrames)) : json(nullptr)},
            {"nearest_pct", nearestTotal ? json(std::round(100.0 * a.nearest / nearestTotal)) : json(nullptr)},
        });
    }
    json stats = {
        {"frames", (long long)frames.size()},
        {"camera_solved_pct", std::round(100.0 * solved / n)},
        {"ball_found_pct", std::round(100.0 * ballFrames / n)},
        {"ball_placed_pct", std::round(100.0 * ballPlacedN / n)},
        {"ball_distance_m", round1(ballDist)},
        {"ball_thirds_pct", ballPlacedN ? json::array({std::round(100.0 * thirds[0] / ballPlacedN), std::round(100.0 * thirds[1] / ballPlacedN), std::round(100.0 * thirds[2] / ballPlacedN)}) : json::array()},
        {"referees_per_frame", round1(refs / n)},
        {"teams", teams},
    };

    // ── per-frame pitch spots for the mini-pitch: [kind, kit, track, x, y]
    json fr = json::array();
    for (const auto& [k, f] : frames) {
        json spots = json::array();
        for (const auto& s : f.people)
            if (s.placed) spots.push_back({s.kind, s.kit, s.track, round1(s.x), round1(s.y)});
        fr.push_back({{"f", f.frame}, {"t", f.t}, {"p", spots},
                      {"b", f.ballPlaced ? json::array({round1(f.bx), round1(f.by)}) : json(nullptr)}});
    }

    return {
        {"clip", {{"id", id}, {"title", str(cr, "title")}, {"source_url", str(cr, "source_url")},
                  {"start", num(cr, "video_start_sec")}, {"end", num(cr, "video_end_sec")},
                  {"fps", num(cr, "analysis_fps")}, {"pitch", {L, W}},
                  {"camera", {num(cr, "camera_x_m"), num(cr, "camera_y_m"), num(cr, "camera_z_m")}},
                  {"replay_file_id", cr["replay_file_id"].is_null() ? json(nullptr) : json(cr["replay_file_id"].as<long long>())},
                  {"note", str(cr, "pipeline_note")}}},
        {"kits", kits},
        {"stats", stats},
        {"frames", fr},
    };
}
