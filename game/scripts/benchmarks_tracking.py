#!/usr/bin/env python3
"""benchmarks_tracking.py — pro reference numbers from TRACKING data (game/DESIGN.md).

    python3 -I game/scripts/benchmarks_tracking.py dfl <dir>         > dfl.json
    python3 -I game/scripts/benchmarks_tracking.py skillcorner <dir> > sc.json

The StatsBomb scripts see the ball. These see the other 21: the shape of a
team, the room the man on the ball has, how many mates he can actually find,
and how far and fast they run. One match at a time, stdlib only.

Sources (download them yourself into <dir>; nothing here is committed):

  dfl          Bassek, Rein, Weber & Memmert (2025), "An integrated dataset of
               spatiotemporal and event data in elite soccer", figshare,
               doi 10.6084/m9.figshare.28196177, CC BY. Data owner: DFL. 7
               matches of 2022/23 (2 Bundesliga, 5 2. Bundesliga), TRACAB
               optical tracking, 25 Hz, every player, always in shot.
  skillcorner  SkillCorner Open Data (github.com/SkillCorner/opendata), MIT, A-League
               2024/25, broadcast tracking, 10 Hz. Men off camera are
               EXTRAPOLATED, so only shape and room are read from it, and a
               difference between it and dfl may be the camera, not the level.
               Physical numbers come from dfl alone.

Every frame is sampled at 5 Hz. Only ball-in-play frames with a team in
possession count. Definitions, the same in the harness:

  shape        outfielders only, deepest to highest (length) and touchline to
               touchline (width); in / out of possession.
  line height  the defending team's deepest outfielder, metres from their own
               goal line, overall and by where the ball is.
  man on ball  the possession team's player nearest the ball, within 1.5 m,
               ball slower than 8 m/s, held for two samples (0.4 s). A pass
               flying past is therefore not a carrier.
  pressure     metres from him to the nearest opponent.
  reception    a new carrier on the same team within 3 s of the last: the
               nearest opponent at that first sample.
  open mates   outfield mates 5-30 m from the man on the ball, 3 m+ from any
               opponent, no opponent within 2 m of the straight line to him.
               FH original: a mate you could actually find.
  physical     outfielders, per 90 played. Whole match, dead time included,
               as the industry counts it. High speed 19.8-25.2 km/h, sprint
               25.2+ km/h held 1 s (the common bands; vendors differ a little).
"""
import glob
import json
import os
import re
import statistics
import sys
from collections import defaultdict

SAMPLE_HZ = 5
DT = 1.0 / SAMPLE_HZ
CARRIER_M = 1.5
CARRIER_BALL_MS = 8.0
RECEPTION_GAP_S = 3.0
OPEN_NEAR, OPEN_FAR, OPEN_OPP, OPEN_LANE = 5.0, 30.0, 3.0, 2.0
HSR_KMH, SPRINT_KMH = 19.8, 25.2
SPRINT_HOLD_S = 1.0


def bucket(v, edges):
    for i, b in enumerate(edges):
        if v < b:
            return i
    return len(edges)


def lane_gap(px, py, qx, qy, ox, oy):
    """Distance from o to the segment p-q."""
    dx, dy = qx - px, qy - py
    n = dx * dx + dy * dy
    t = 0.0 if n == 0 else max(0.0, min(1.0, ((ox - px) * dx + (oy - py) * dy) / n))
    cx, cy = px + t * dx, py + t * dy
    return ((ox - cx) ** 2 + (oy - cy) ** 2) ** 0.5


class ShapeTally:
    """The ball-in-play measures of one match. Frames are given per period as
    (ball_x, ball_y, team_in_possession, {team: [(x, y), ...outfield]},
     {team: [(x, y), ...keepers]}); teams are 0 and 1."""

    def __init__(self, length):
        self.half = length / 2.0
        self.len = [[], []]         # [in, out]
        self.wid = [[], []]
        self.line = []
        self.line_zone = [[], [], []]   # ball in the defenders' own / middle / far third
        self.press = []
        self.recv = []
        self.open = []
        self.frames = 0

    def period(self, frames):
        side = {}   # team -> +1 when it attacks +x this period
        for t in (0, 1):
            ks = [p[0] for f in frames for p in f[4][t]]
            if not ks:
                ks = [p[0] for f in frames for p in f[3][t]]
            side[t] = -1 if sum(ks) > 0 else 1
        cand, held, carrier, last = None, 0, None, None
        prev = None
        for i, (bx, by, pos, of, gk) in enumerate(frames):
            if prev is None or prev[0] != i - 1:
                bspeed = None
            else:
                bspeed = ((bx - prev[1]) ** 2 + (by - prev[2]) ** 2) ** 0.5 / DT
            prev = (i, bx, by)
            if len(of[0]) < 9 or len(of[1]) < 9:
                cand, held, carrier = None, 0, None
                continue
            self.frames += 1
            d = 1 - pos
            for k, t in ((0, pos), (1, d)):
                xs = [p[0] for p in of[t]]
                ys = [p[1] for p in of[t]]
                self.len[k].append(max(xs) - min(xs))
                self.wid[k].append(max(ys) - min(ys))
            s = side[d]
            h = min(s * p[0] for p in of[d]) + self.half
            self.line.append(h)
            ball_from_own = s * bx + self.half
            self.line_zone[bucket(ball_from_own, (2 * self.half / 3, 4 * self.half / 3))].append(h)
            # The man on the ball.
            mine = of[pos] + gk[pos]
            best, bi = 1e9, -1
            for j, p in enumerate(mine):
                g = ((p[0] - bx) ** 2 + (p[1] - by) ** 2) ** 0.5
                if g < best:
                    best, bi = g, j
            near = best <= CARRIER_M and (bspeed is None or bspeed <= CARRIER_BALL_MS)
            key = (pos, bi if bi < len(of[pos]) else 100 + bi)
            if not near:
                cand, held = None, 0
                continue
            if key == cand:
                held += 1
            else:
                cand, held = key, 1
            if held < 2:
                continue
            c = mine[bi]
            foes = of[d] + gk[d]
            g = min(((p[0] - c[0]) ** 2 + (p[1] - c[1]) ** 2) ** 0.5 for p in foes)
            self.press.append(g)
            if carrier != key:
                if carrier is not None and carrier[0] == pos and last is not None and (i - last) * DT <= RECEPTION_GAP_S:
                    self.recv.append(g)
                carrier = key
            last = i
            n = 0
            for j, m in enumerate(of[pos]):
                if j == bi:
                    continue
                dm = ((m[0] - c[0]) ** 2 + (m[1] - c[1]) ** 2) ** 0.5
                if not OPEN_NEAR <= dm <= OPEN_FAR:
                    continue
                if min(((p[0] - m[0]) ** 2 + (p[1] - m[1]) ** 2) ** 0.5 for p in foes) < OPEN_OPP:
                    continue
                if any(lane_gap(c[0], c[1], m[0], m[1], p[0], p[1]) < OPEN_LANE for p in foes):
                    continue
                n += 1
            self.open.append(n)

    def result(self):
        out = {}
        m = statistics.mean
        out["team_length_in_possession_m"] = m(self.len[0])
        out["team_length_out_of_possession_m"] = m(self.len[1])
        out["team_width_in_possession_m"] = m(self.wid[0])
        out["team_width_out_of_possession_m"] = m(self.wid[1])
        out["line_height_m"] = m(self.line)
        for k, name in enumerate(("own_third", "middle_third", "far_third")):
            out[f"line_height_ball_{name}_m"] = m(self.line_zone[k]) if self.line_zone[k] else None
        out["carrier_nearest_opponent_m"] = statistics.median(self.press)
        n = len(self.press)
        for k, name in enumerate(("lt2m", "2_5m", "5_10m", "10m_plus")):
            out[f"carrier_nearest_opponent_{name}_pct"] = 100.0 * sum(bucket(v, (2, 5, 10)) == k for v in self.press) / n
        out["reception_nearest_opponent_m"] = statistics.median(self.recv)
        r = len(self.recv)
        for k, name in enumerate(("lt2m", "2_5m", "5m_plus")):
            out[f"reception_nearest_opponent_{name}_pct"] = 100.0 * sum(bucket(v, (2, 5)) == k for v in self.recv) / r
        out["open_mates_per_carrier"] = m(self.open)
        out["_receptions"] = r
        out["_in_play_minutes"] = self.frames * DT / 60.0
        return out


def dfl_info(path):
    txt = open(path, encoding="utf8").read()
    g = re.search(r'<General [^>]*CompetitionName="([^"]+)"[^>]*Season="([^"]+)"[^>]*HomeTeamId="([^"]+)"[^>]*GuestTeamId="([^"]+)"', txt)
    size = re.search(r'PitchX="([\d.]+)"', txt)
    keepers = set(re.findall(r'<Player PersonId="([^"]+)"[^>]*PlayingPosition="TW"', txt))
    return g.group(1), g.group(2), g.group(3), g.group(4), float(size.group(1)), keepers


def dfl_match(pos_path, info_path):
    comp, season, home, guest, length, keepers = dfl_info(info_path)
    team_of = {home: 0, guest: 1}
    frames = defaultdict(dict)   # (section, N) -> {person: (x, y)}
    ball = {}                    # (section, N) -> (x, y, possession 0/1) in play
    who = {}                     # person -> team
    run = defaultdict(lambda: [0.0, 0.0, 0.0, 0, 0, 0.0])  # dist m, hsr m, sprint m, frames, sprints, run s
    cur, section, is_ball, skip = None, None, False, True
    set_re = re.compile(r'GameSection="([^"]+)".*TeamId="([^"]+)".*PersonId="([^"]+)"')
    hz = 25.0
    with open(pos_path, encoding="utf8", buffering=1 << 22) as f:
        for line in f:
            s = line.lstrip()
            if s.startswith("<Frame "):
                if skip:
                    continue
                a = s.split('"')
                if is_ball:
                    n = int(a[1])
                    if n % 5:
                        continue
                    st = re.search(r'BallStatus="(\d)"', s)
                    po = re.search(r'BallPossession="(\d)"', s)
                    if st and st.group(1) == "1" and po and po.group(1) in "12":
                        ball[(section, n)] = (float(a[5]), float(a[7]), int(po.group(1)) - 1)
                    continue
                n, kmh = int(a[1]), float(a[11])
                r = run[cur]
                m = kmh / 3.6 / hz
                r[0] += m
                r[3] += 1
                if kmh >= SPRINT_KMH:
                    r[2] += m
                    r[5] += 1 / hz
                else:
                    if r[5] >= SPRINT_HOLD_S:
                        r[4] += 1
                    r[5] = 0.0
                    if kmh >= HSR_KMH:
                        r[1] += m
                if n % 5 == 0:
                    frames[(section, n)][cur] = (float(a[5]), float(a[7]))
            elif s.startswith("<FrameSet "):
                section, tid, pid = set_re.search(s).groups()
                is_ball = tid.upper() == "BALL" or "BALL" in pid.upper()
                skip = not is_ball and tid not in team_of
                if not skip and not is_ball:
                    cur = pid
                    who[pid] = team_of[tid]
                    run[cur][5] = 0.0
    tally = ShapeTally(length)
    for sec in sorted({k[0] for k in ball}):
        fr = []
        for k in sorted(k for k in ball if k[0] == sec):
            bx, by, pos = ball[k]
            of, gk = ([], []), ([], [])
            for pid in sorted(frames[k]):
                (gk if pid in keepers else of)[who[pid]].append(frames[k][pid])
            fr.append((bx, by, pos, of, gk))
        tally.period(fr)
    res = tally.result()
    out = [(p, r) for p, r in run.items() if p not in keepers and p in who]
    mins = sum(r[3] for _, r in out) / hz / 60.0
    per90 = 90.0 / mins
    res["distance_km_per_90"] = sum(r[0] for _, r in out) * per90 / 1000
    res["high_speed_m_per_90"] = sum(r[1] for _, r in out) * per90
    res["sprint_m_per_90"] = sum(r[2] for _, r in out) * per90
    res["sprints_per_90"] = sum(r[4] for _, r in out) * per90
    return comp, season, res


def run_dfl(d):
    rows = []
    for p in sorted(glob.glob(os.path.join(d, "DFL_04_03_positions_raw_observed_*.xml"))):
        mid = p.rsplit("_", 1)[1]
        info = glob.glob(os.path.join(d, f"DFL_02_01_matchinformation_*_{mid}"))[0]
        comp, season, res = dfl_match(p, info)
        print(comp, mid[:-4], {k: round(v, 1) for k, v in res.items() if k in ("team_length_in_possession_m", "line_height_m", "distance_km_per_90", "_in_play_minutes") and v}, file=sys.stderr, flush=True)
        rows.append({"competition": comp, "season": season, "match": mid[:-4], "metrics": res})
    return rows


def skillcorner_match(path, meta_path):
    meta = json.load(open(meta_path, encoding="utf8"))
    home, away = meta["home_team"]["id"], meta["away_team"]["id"]
    team_of, keeper = {}, set()
    for p in meta["players"]:
        team_of[p["id"]] = 0 if p["team_id"] == home else 1
        if p.get("player_role", {}).get("acronym") == "GK":
            keeper.add(p["id"])
    tally = ShapeTally(float(meta["pitch_length"]))
    periods = defaultdict(list)
    seen = detected = 0
    with open(path, encoding="utf8", buffering=1 << 22) as f:
        for line in f:
            fr = json.loads(line)
            if fr["frame"] % 2 or fr.get("period") is None or not fr.get("player_data"):
                continue
            b = fr.get("ball_data") or {}
            grp = (fr.get("possession") or {}).get("group")
            if b.get("x") is None or grp not in ("home team", "away team"):
                continue
            of, gk = ([], []), ([], [])
            for p in sorted(fr["player_data"], key=lambda q: q["player_id"]):
                t = team_of.get(p["player_id"])
                if t is None:
                    continue
                (gk if p["player_id"] in keeper else of)[t].append((p["x"], p["y"]))
                seen += 1
                detected += bool(p.get("is_detected"))
            periods[fr["period"]].append((b["x"], b["y"], 0 if grp == "home team" else 1, of, gk))
    for k in sorted(periods):
        tally.period(periods[k])
    res = tally.result()
    res["_detected_pct"] = 100.0 * detected / max(1, seen)
    return res


def run_skillcorner(d):
    rows = []
    for p in sorted(glob.glob(os.path.join(d, "*_tracking_extrapolated.jsonl"))):
        mid = os.path.basename(p).split("_")[0]
        meta = os.path.join(d, f"{mid}_match.json")
        if not os.path.exists(meta):
            continue
        res = skillcorner_match(p, meta)
        print(mid, {k: round(v, 1) for k, v in res.items() if k in ("team_length_in_possession_m", "line_height_m", "_detected_pct", "_in_play_minutes") and v}, file=sys.stderr, flush=True)
        rows.append({"competition": "A-League", "season": "2024/2025", "match": mid, "metrics": res})
    return rows


def main():
    kind, d = sys.argv[1], sys.argv[2]
    rows = run_dfl(d) if kind == "dfl" else run_skillcorner(d)
    by = defaultdict(list)
    for r in rows:
        by[(r["competition"], r["season"])].append(r)
    out = []
    for (comp, season), rs in sorted(by.items()):
        vals, spread = {}, {}
        for k in rs[0]["metrics"]:
            xs = [r["metrics"][k] for r in rs if r["metrics"].get(k) is not None]
            if xs:
                vals[k] = round(statistics.mean(xs), 2)
                spread[k] = [round(min(xs), 2), round(max(xs), 2)]
        out.append({"competition": comp, "season": season, "matches": len(rs), "metrics": vals, "range": spread})
    json.dump(out, sys.stdout, indent=1)
    print()


if __name__ == "__main__":
    main()
