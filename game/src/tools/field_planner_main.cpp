// game/src/tools/field_planner_main.cpp — fh-field-planner
//
// Lighthouse Field pitch-placement sweep [FH]. The C++ port of the hot loop
// in game/scripts/plan_lighthouse_pitch.py + search_lighthouse_pitch_water.py
// (James, 10/22: the Python sweeps took minutes). Python still exports the
// inputs — export_lighthouse_planner_input.py 11v11|7v7 writes obstacles.txt
// (one rule per line, site metres, x east / z south) and grid.bin (lidar
// ground, pit-filled ground, D8 flow accumulation on 1 m cells) — and this
// tool tries every placement, cheap rules first, and scores the legal ones
// for water exactly like the Python: 3 x pond + 1.5 x runoff + 0.5 x flat.
//
//   fh-field-planner obstacles.txt grid.bin [options]
//     --size L,W          pitch in yards (default 115,74)
//     --rot a,b,step      degrees, [a, b) (default 0,180,5)
//     --step m            centre grid in metres (default 2)
//     --box x0,x1,z0,z1   centre search box (default -110,125,-125,40)
//     --keepout cx,cz,rot,L,W,yd   another pitch (yards) to stay yd clear of;
//                         repeatable
//     --sort water|clear  driest first, or farthest from the keepouts
//     --top N             rows printed (default 15)
//
// Output: one TSV row per placement — cx cz rot clear_yd pond flow flat score
// — then "legal N". Pure geometry + doubles: it is an offline tool, not the
// sim, so the fixed-point rule does not apply.

#include <algorithm>
#include <cmath>
#include <cstdint>
#include <cstdio>
#include <fstream>
#include <sstream>
#include <string>
#include <vector>

namespace {

constexpr double kYd = 0.9144;
constexpr double kD2R = M_PI / 180.0;

struct Pt { double x, z; };
using Poly = std::vector<Pt>;

struct Rule {
  std::string kind, name;
  bool closed = false;
  double min = 0, slope = 0;
  Poly pts;
  double bx0 = 1e18, bx1 = -1e18, bz0 = 1e18, bz1 = -1e18;  // bounding box
};

struct Keepout { Poly rect; Pt c; double clear; };

struct Grid {
  int x0 = 0, z0 = 0, nx = 0, nz = 0;
  std::vector<float> g, filled, acc;
  float at(const std::vector<float>& a, int i, int j) const { return a[size_t(j) * nx + i]; }
};

double segDist(Pt p, Pt a, Pt b) {
  double dx = b.x - a.x, dz = b.z - a.z, l2 = dx * dx + dz * dz;
  double t = l2 == 0 ? 0 : std::clamp(((p.x - a.x) * dx + (p.z - a.z) * dz) / l2, 0.0, 1.0);
  return std::hypot(p.x - a.x - t * dx, p.z - a.z - t * dz);
}

bool crosses(Pt a, Pt b, Pt c, Pt d) {
  auto o = [](Pt p, Pt q, Pt r) { return (q.x - p.x) * (r.z - p.z) - (q.z - p.z) * (r.x - p.x); };
  return o(a, b, c) * o(a, b, d) < 0 && o(c, d, a) * o(c, d, b) < 0;
}

bool inRect(Pt p, const Poly& r) {
  int sg = 0;
  for (int i = 0; i < 4; i++) {
    Pt a = r[i], b = r[(i + 1) % 4];
    double cr = (b.x - a.x) * (p.z - a.z) - (b.z - a.z) * (p.x - a.x);
    int s = cr > 0 ? 1 : -1;
    if (!sg) sg = s;
    else if (s != sg) return false;
  }
  return true;
}

bool inPoly(Pt p, const Poly& poly) {
  bool c = false;
  for (size_t i = 0, j = poly.size() - 1; i < poly.size(); j = i++) {
    Pt a = poly[i], b = poly[j];
    if ((a.z > p.z) != (b.z > p.z) && p.x < (b.x - a.x) * (p.z - a.z) / (b.z - a.z) + a.x) c = !c;
  }
  return c;
}

Poly rect(double cx, double cz, double th, double L, double W) {
  double c = std::cos(th), s = std::sin(th);
  Poly r;
  for (auto [u, v] : {std::pair{-L / 2, -W / 2}, {L / 2, -W / 2}, {L / 2, W / 2}, {-L / 2, W / 2}})
    r.push_back({cx + u * c - v * s, cz + u * s + v * c});
  return r;
}

// Rect-to-polyline distance, 0 when they touch or overlap (plan_lighthouse_
// pitch.py's dpoly, plus: a closed polygon swallowing the rect counts).
double rectDist(const Poly& R, Pt rc, const Poly& P, bool closed) {
  Poly pts = P;
  if (closed) pts.push_back(P[0]);
  double d = 1e9;
  for (int i = 0; i < 4; i++) {
    Pt a = R[i], b = R[(i + 1) % 4];
    for (size_t j = 0; j + 1 < pts.size(); j++) {
      Pt c = pts[j], e = pts[j + 1];
      if (crosses(a, b, c, e)) return 0;
      d = std::min({d, segDist(c, a, b), segDist(e, a, b), segDist(a, c, e), segDist(b, c, e)});
    }
  }
  for (Pt p : P) if (inRect(p, R)) return 0;
  if (closed && inPoly(rc, P)) return 0;
  return d;
}

// z of a polyline at x, extended east of its last point at `slope` and flat
// west of its first (plan_lighthouse_pitch.py's vendor_z).
double lineZ(const Poly& P, double slope, double x) {
  if (x >= P.back().x) return P.back().z + slope * (x - P.back().x);
  if (x <= P.front().x) return P.front().z;
  for (size_t i = 0; i + 1 < P.size(); i++)
    if (P[i].x <= x && x <= P[i + 1].x)
      return P[i].z + (P[i + 1].z - P[i].z) * (x - P[i].x) / (P[i + 1].x - P[i].x);
  return P.back().z;
}

// x of a polyline at z: its first x north of it, unbounded south of it
// (plan_lighthouse_pitch.py's rodeo_x).
double lineX(const Poly& P, double z) {
  if (z <= P.front().z) return P.front().x;
  if (z >= P.back().z) return 1e9;
  for (size_t i = 0; i + 1 < P.size(); i++)
    if (P[i].z <= z && z <= P[i + 1].z)
      return P[i].x + (P[i + 1].x - P[i].x) * (z - P[i].z) / (P[i + 1].z - P[i].z);
  return 1e9;
}

// Cheap rules first: the tree test (thousands of crowns) runs last.
int cost(const Rule& r) {
  if (r.kind == "points") return 3;
  if (r.kind == "poly" || r.kind == "inside") return 2;
  return 1;
}

bool legal(const std::vector<Rule>& rules, const Poly& R, Pt c) {
  for (const Rule& r : rules) {
    if (r.kind == "poly") {
      // Boxes farther apart than min on either axis can't be within min.
      double rx0 = 1e18, rx1 = -1e18, rz0 = 1e18, rz1 = -1e18;
      for (Pt p : R) { rx0 = std::min(rx0, p.x); rx1 = std::max(rx1, p.x); rz0 = std::min(rz0, p.z); rz1 = std::max(rz1, p.z); }
      if (rx0 - r.bx1 > r.min || r.bx0 - rx1 > r.min || rz0 - r.bz1 > r.min || r.bz0 - rz1 > r.min) continue;
      if (rectDist(R, c, r.pts, r.closed) < r.min) return false;
    } else if (r.kind == "inside") {
      for (Pt p : R) if (!inPoly(p, r.pts)) return false;
      if (rectDist(R, c, r.pts, false) < r.min) return false;
    } else if (r.kind == "outside") {
      if (inPoly(c, r.pts)) return false;
      for (Pt p : R) if (inPoly(p, r.pts)) return false;
    } else if (r.kind == "below") {
      for (Pt p : R) if (p.z >= lineZ(r.pts, r.slope, p.x)) return false;
    } else if (r.kind == "left") {
      for (Pt p : R) if (p.x >= lineX(r.pts, p.z)) return false;
    } else if (r.kind == "points") {
      double reach = std::hypot(R[0].x - c.x, R[0].z - c.z) + r.min;  // half-diagonal
      for (Pt t : r.pts) {
        if (std::abs(t.x - c.x) > reach || std::abs(t.z - c.z) > reach) continue;
        if (inRect(t, R)) return false;
        for (int i = 0; i < 4; i++) if (segDist(t, R[i], R[(i + 1) % 4]) < r.min) return false;
      }
    }
  }
  return true;
}

struct Water { double pond = 0, flow = 0, flat = 0, score = 0; };

// search_lighthouse_pitch_water.py's water(): sample the pitch every `step`
// m; pond = pit-filled depth > 1 cm, else flow = >= 150 m² upslope crossing,
// else flat = slope < 0.5 % over 6 m.
Water water(const Grid& G, double cx, double cz, double th, double L, double W, double step) {
  double ca = std::cos(th), sa = std::sin(th);
  int pond = 0, flow = 0, flat = 0;
  for (double u = -L / 2 + step / 2; u < L / 2; u += step)
    for (double v = -W / 2 + step / 2; v < W / 2; v += step) {
      double x = cx + u * ca - v * sa, z = cz + u * sa + v * ca;
      int i = int(std::lround(x - G.x0)), j = int(std::lround(z - G.z0));
      if (i < 3 || j < 3 || i >= G.nx - 3 || j >= G.nz - 3) continue;
      double gx = (G.at(G.g, i + 3, j) - G.at(G.g, i - 3, j)) / 6;
      double gz = (G.at(G.g, i, j + 3) - G.at(G.g, i, j - 3)) / 6;
      double sl = std::hypot(gx, gz) * 100;
      if (G.at(G.filled, i, j) - G.at(G.g, i, j) > 0.01) pond++;
      else if (G.at(G.acc, i, j) >= 150) flow++;
      else if (sl < 0.5) flat++;
    }
  double k = step * step;
  Water w{pond * k, flow * k, flat * k, 0};
  w.score = 3 * w.pond + 1.5 * w.flow + 0.5 * w.flat;
  return w;
}

std::vector<double> nums(const std::string& s) {
  std::vector<double> v;
  std::stringstream ss(s);
  std::string t;
  while (std::getline(ss, t, ',')) v.push_back(std::stod(t));
  return v;
}

}  // namespace

int main(int argc, char** argv) {
  if (argc < 3) {
    std::fprintf(stderr, "usage: fh-field-planner obstacles.txt grid.bin [options] (see header)\n");
    return 2;
  }
  double L = 115 * kYd, W = 74 * kYd, r0 = 0, r1 = 180, rs = 5, step = 2;
  double x0 = -110, x1 = 125, z0 = -125, z1 = 40;
  std::string sortBy = "water";
  size_t top = 15;
  std::vector<Keepout> keep;
  for (int a = 3; a + 1 < argc; a += 2) {
    std::string k = argv[a];
    if (k == "--sort") { sortBy = argv[a + 1]; continue; }
    std::vector<double> v = nums(argv[a + 1]);
    if (k == "--size") { L = v[0] * kYd; W = v[1] * kYd; }
    else if (k == "--rot") { r0 = v[0]; r1 = v[1]; rs = v[2]; }
    else if (k == "--step") step = v[0];
    else if (k == "--box") { x0 = v[0]; x1 = v[1]; z0 = v[2]; z1 = v[3]; }
    else if (k == "--keepout")
      keep.push_back({rect(v[0], v[1], v[2] * kD2R, v[3] * kYd, v[4] * kYd), {v[0], v[1]}, v[5] * kYd});
    else if (k == "--top") top = size_t(v[0]);
  }

  std::vector<Rule> rules;
  std::ifstream in(argv[1]);
  for (std::string ln; std::getline(in, ln);) {
    std::istringstream ss(ln);
    Rule r;
    if (!(ss >> r.kind >> r.name)) continue;
    if (r.kind == "poly") { int c; ss >> c >> r.min; r.closed = c; }
    else if (r.kind == "inside" || r.kind == "points") ss >> r.min;
    else if (r.kind == "below") ss >> r.slope;
    for (double x, z; ss >> x >> z;) {
      r.pts.push_back({x, z});
      r.bx0 = std::min(r.bx0, x); r.bx1 = std::max(r.bx1, x);
      r.bz0 = std::min(r.bz0, z); r.bz1 = std::max(r.bz1, z);
    }
    rules.push_back(std::move(r));
  }
  std::stable_sort(rules.begin(), rules.end(),
                   [](const Rule& a, const Rule& b) { return cost(a) < cost(b); });

  Grid G;
  std::ifstream gb(argv[2], std::ios::binary);
  int32_t hdr[4];
  gb.read(reinterpret_cast<char*>(hdr), sizeof hdr);
  G.x0 = hdr[0]; G.z0 = hdr[1]; G.nx = hdr[2]; G.nz = hdr[3];
  for (auto* a : {&G.g, &G.filled, &G.acc}) {
    a->resize(size_t(G.nx) * G.nz);
    gb.read(reinterpret_cast<char*>(a->data()), std::streamsize(a->size() * sizeof(float)));
  }
  if (!gb) { std::fprintf(stderr, "short grid file %s\n", argv[2]); return 1; }

  struct Row { double cx, cz, rot, clear; Water w; };
  std::vector<Row> rows;
  for (double rot = r0; rot < r1 - 1e-9; rot += rs) {
    double th = rot * kD2R;
    for (double cz = z0; cz <= z1 + 1e-9; cz += step)
      for (double cx = x0; cx <= x1 + 1e-9; cx += step) {
        Poly R = rect(cx, cz, th, L, W);
        Pt c{cx, cz};
        double clear = 1e9;
        bool ok = true;
        for (const Keepout& k : keep) {
          double d = inRect(c, k.rect) ? 0 : rectDist(R, c, k.rect, true);
          if (d < k.clear) { ok = false; break; }
          clear = std::min(clear, d);
        }
        if (!ok || !legal(rules, R, c)) continue;
        rows.push_back({cx, cz, rot, clear / kYd, water(G, cx, cz, th, L, W, 1.0)});
      }
  }
  if (sortBy == "clear")
    std::sort(rows.begin(), rows.end(), [](const Row& a, const Row& b) { return a.clear > b.clear; });
  else
    std::sort(rows.begin(), rows.end(), [](const Row& a, const Row& b) { return a.w.score < b.w.score; });
  std::printf("cx\tcz\trot\tclear_yd\tpond\tflow\tflat\tscore\n");
  for (size_t i = 0; i < rows.size() && i < top; i++) {
    const Row& r = rows[i];
    std::printf("%.2f\t%.2f\t%.1f\t%.1f\t%.0f\t%.0f\t%.0f\t%.1f\n", r.cx, r.cz, r.rot,
                keep.empty() ? 0.0 : r.clear, r.w.pond, r.w.flow, r.w.flat, r.w.score);
  }
  std::printf("legal %zu\n", rows.size());
  return 0;
}
