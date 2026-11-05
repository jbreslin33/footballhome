#!/usr/bin/env python3
# game/scripts/benchmarks_tracking_channel.py (G5.13, DESIGN §8.110) — usage: <DFL dir>
# Real: with the ball wide 18-35 m off the line the side on it attacks (|y| 14+, in play, 5 Hz),
# who is ahead of it on its side: attackers / defenders in the channel (0-18 m off the line, |y| 14+,
# ball side), attackers ahead of the ball on its side (|y| 10+) and how many of them run at 4 m/s+
# toward the line, by role. DFL tracking (Bassek et al. 2025, CC BY).
# G5.14 (§8.111): WHERE THEY STAND — every outfield man by role, ball side / far side (his y v the
# ball's), attacking / defending: metres ahead of the ball toward the line (+ = nearer their line)
# and metres across toward the ball's touchline (+ = ball side); plus the nearest defender to the ball.
# G5.15 (§8.112): THREE SECONDS BEFORE — how far the ball came toward the line, who had it, and how far each
# attacker came / where he stood v the ball then.
import collections, glob, os, re, sys, multiprocessing
sys.path.insert(0, "/srv/footballhome/game/scripts")
import benchmarks_tracking as bt
ROLE = {"IVL": "CB", "IVR": "CB", "IVZ": "CB", "LV": "FB", "RV": "FB", "DML": "DM/CM", "DMR": "DM/CM", "DMZ": "DM/CM",
        "DLM": "DM/CM", "DRM": "DM/CM", "ZO": "AM", "OLM": "WIDE", "ORM": "WIDE", "LM": "WIDE", "RM": "WIDE", "HL": "WIDE",
        "HR": "WIDE", "LA": "WIDE", "RA": "WIDE", "STL": "ST", "STR": "ST", "STZ": "ST"}
def one(pos_path):
    d = os.path.dirname(pos_path); mid = pos_path.rsplit("_", 1)[1]
    info_p = glob.glob(os.path.join(d, f"DFL_02_01_matchinformation_*_{mid}"))[0]
    comp, season, home, guest, length, keepers = bt.dfl_info(info_p)
    pos_of = dict(re.findall(r'<Player PersonId="([^"]+)"[^>]*PlayingPosition="([^"]+)"', open(info_p, encoding="utf8").read()))
    half = length / 2; team_of = {home: 0, guest: 1}
    ball = {}; pl = collections.defaultdict(dict); who = {}
    set_re = re.compile(r'GameSection="([^"]+)".*TeamId="([^"]+)".*PersonId="([^"]+)"')
    sec = None; isb = False; skip = True; cur = None
    for line in open(pos_path, encoding="utf8", buffering=1 << 22):
        s = line.lstrip()
        if s.startswith("<Frame "):
            if skip: continue
            a = s.split('"'); n = int(a[1])
            if n % 5: continue
            if isb:
                st = re.search(r'BallStatus="(\d)"', s); po = re.search(r'BallPossession="(\d)"', s)
                if st and st.group(1) == "1" and po and po.group(1) in "12": ball[(sec, n)] = (float(a[5]), float(a[7]), int(po.group(1)) - 1)
            else: pl[(sec, n)][cur] = (float(a[5]), float(a[7]))
        elif s.startswith("<FrameSet "):
            sec, tid, pid = set_re.search(s).groups()
            isb = tid.upper() == "BALL"; skip = not isb and tid not in team_of
            if not skip and not isb: cur = pid; who[pid] = team_of[tid]
    c = collections.Counter()
    own = {}
    for sc in {k[0] for k in ball}:
        xs = {0: [], 1: []}
        for (s2, n), ps in pl.items():
            if s2 != sc or n % 250: continue
            for pid, p in ps.items():
                if pid in keepers: xs[who[pid]].append(p[0])
        for tm in (0, 1): own[(sc, tm)] = -1 if (sum(xs[tm]) / max(1, len(xs[tm]))) < 0 else 1
    # G5.19 (§8.117): ENTRIES — the ball, the attacking side's in play, first inside 30 m of goal
    # (re-armed once it's back past 40 m); how fast it came (ball speed at the entry: under 7 m/s
    # carried, 7-12, 12+ passed); goal-side defenders and their deepest outfielder at the entry and
    # 3 s before; where the ball was then.
    armed = {}; prev = {}
    for (sc, n) in sorted(ball):
        bx, by, att = ball[(sc, n)]
        g = -own[(sc, att)]; btl = half - bx * g
        key = (sc, att)
        if btl >= 40: armed[key] = True
        p0 = prev.get(key); prev[key] = (n, btl)
        if not (armed.get(key) and p0 and p0[0] == n - 5 and p0[1] >= 30 > btl): continue
        armed[key] = False
        b1 = ball.get((sc, n - 5))
        spd = ((bx - b1[0]) ** 2 + (by - b1[1]) ** 2) ** 0.5 / 0.2 if b1 else 0
        sb = 0 if spd < 7 else 1 if spd < 12 else 2
        def defs(m):
            fr = pl.get((sc, m), {})
            tls = [half - x * g for pid, (x, y) in fr.items() if pid not in keepers and who[pid] != att]
            return tls
        now = defs(n); then = defs(n - 15 * 5); bthen = ball.get((sc, n - 75))
        if len(now) < 9: continue
        c["en"] += 1; c[("ens", sb)] += 1
        c["en_gs"] += sum(1 for v in now if v < btl); c["en_deep"] += min(now)
        if len(then) >= 9 and bthen:
            btl0 = half - bthen[0] * g
            c["en3"] += 1; c["en3_gs"] += sum(1 for v in then if v < btl0); c["en3_deep"] += min(then); c["en3_b"] += btl0
            c["en3_line"] += sorted(then)[1]   # second-deepest: the offside line
            c[("en3_bs", sb)] += 1; c[("en3_gsb", sb)] += sum(1 for v in then if v < btl0)
    # G5.20 (§8.118): THE CARRY THROUGH THE BLOCK — carrier = the attacker nearest the ball within 2 m
    # (5 Hz; the same man, up to 2 frames without him within 2 m while it stays within 4 m); a carry that
    # starts 35 m+ out and gets inside 30 m: how long it took, how fast he went, the defenders goal-side at
    # its start and how many of them he left behind by the entry, the nearest defender (start / closest),
    # the share of frames a defender was within 2 m, the first man to get within 2 m (role, goal-side at
    # the start or not) and how many defenders were within 5 m.
    def carrier_of(sc, n):
        b = ball.get((sc, n))
        if not b: return None
        best = None
        for pid, (x, y) in pl.get((sc, n), {}).items():
            if who.get(pid) != b[2]: continue
            dd = ((x - b[0]) ** 2 + (y - b[1]) ** 2) ** 0.5
            if dd < 2.0 and (best is None or dd < best[1]): best = (pid, dd)
        return best[0] if best else None
    run = None; since = None; pa = None
    for (sc, n) in sorted(ball):
        bx, by, att = ball[(sc, n)]
        g = -own[(sc, att)]; btl = half - bx * g
        if (sc, att) != pa: pa = (sc, att); since = n
        cr = carrier_of(sc, n)
        if run and (run["sc"] != sc or run["att"] != att or n - run["last"] > 15 or (cr is not None and cr != run["pid"])): run = None
        if run and cr is None:
            q = pl.get((sc, n), {}).get(run["pid"])
            if not q or ((q[0] - bx) ** 2 + (q[1] - by) ** 2) ** 0.5 > 4 or run["miss"] >= 2: run = None
            else: run["miss"] += 1; run["last"] = n
            continue
        if cr is None: continue
        defs = [(pid, x, y) for pid, (x, y) in pl.get((sc, n), {}).items() if pid not in keepers and who.get(pid) is not None and who[pid] != att]
        if len(defs) < 9: run = None; continue
        dist = sorted((((x - bx) ** 2 + (y - by) ** 2) ** 0.5, pid) for pid, x, y in defs)
        if run is None:
            if btl < 35: continue
            run = dict(pid=cr, att=att, sc=sc, n0=n, btl0=btl, last=n, miss=0, fr=0, gs={pid for pid, x, y in defs if half - x * g < btl},
                       near0=dist[0][0], close=dist[0][0], eng=0, fe=None, w5=0, done=False,
                       rd={pid: btl - (half - x * g) for pid, x, y in defs}, ab=0 if n - since < 75 else 1 if n - since < 250 else 2)
            continue
        run["miss"] = 0; run["last"] = n
        if run["done"]: continue
        run["fr"] += 1; run["close"] = min(run["close"], dist[0][0]); run["w5"] += sum(1 for v, _ in dist if v < 5)
        if dist[0][0] < 2:
            run["eng"] += 1
            if run["fe"] is None: run["fe"] = dist[0][1]
        if btl < 30:
            run["done"] = True
            gs_now = {pid for pid, x, y in defs if half - x * g < btl}
            c["cy"] += 1; c["cy_du"] += (n - run["n0"]) / 25.0; c["cy_m"] += run["btl0"] - btl
            for pid, d0 in run["rd"].items():
                r = ROLE.get(pos_of.get(pid, ""), "?"); c[("cy_ar", run["ab"], r)] += 1; c[("cy_ag", run["ab"], r)] += pid in run["gs"]; c[("cy_ad", run["ab"], r)] += d0
                r = ROLE.get(pos_of.get(pid, ""), "?"); c[("cy_rn", r)] += 1; c[("cy_rgs", r)] += pid in run["gs"]; c[("cy_rd", r)] += d0
            c[("cy_an", run["ab"])] += 1
            c["cy_gs0"] += len(run["gs"]); c["cy_pass"] += len(run["gs"] - gs_now); c["cy_gs1"] += len(gs_now)
            c["cy_near0"] += run["near0"]; c["cy_close"] += run["close"]
            c["cy_eng"] += run["eng"] / max(1, run["fr"]); c["cy_w5"] += run["w5"] / max(1, run["fr"])
            fe = run["fe"]
            c[("cy_fe", "none" if fe is None else ROLE.get(pos_of.get(fe, ""), "?") + ("/gs" if fe in run["gs"] else "/not"))] += 1
    for (sc, n), (bx, by, att) in ball.items():
        g = -own[(sc, att)]                      # the goal it attacks is at g*half
        btl = half - bx * g
        if not (18 <= btl < 35 and abs(by) >= 14): continue
        c["n"] += 1
        prev = pl.get((sc, n - 5), {})
        sb = 1 if by > 0 else -1; nd = 1e9
        dl = sorted((half - x * g for pid, (x, y) in pl.get((sc, n), {}).items() if who[pid] != att))[:2]
        if len(dl) == 2: c["line"] += btl - max(0.0, min(btl, dl[1])); c["linen"] += 1
        for pid, (x, y) in pl.get((sc, n), {}).items():
            if pid in keepers: continue
            r = ROLE.get(pos_of.get(pid, ""), "?")
            tl = half - x * g
            side = "att" if who[pid] == att else "def"
            same = (y > 0) == (by > 0)
            k = (side, r, "ball" if same else "far")
            c[("wn",) + k] += 1; c[("wa",) + k] += btl - tl; c[("wy",) + k] += y * sb
            if side == "def": nd = min(nd, ((x - bx) ** 2 + (y - by) ** 2) ** 0.5)
            if tl < 18 and abs(y) >= 14 and same: c[(side, "chan")] += 1
            if tl < 16.5 and abs(y) < 20.16: c[(side, "box")] += 1
            if side == "att" and tl < btl and same and abs(y) >= 10:
                c[("ahead", r)] += 1
                if pid in prev:
                    vt = (x - prev[pid][0]) * g / 0.2   # toward the line it attacks
                    if vt >= 4: c[("run", r)] += 1
        then = ball.get((sc, n - 75))           # G5.15 (§8.112): three seconds before, in play
        if then:
            bad = (bx - then[0]) * g
            c["h3n"] += 1; c["h3b"] += bad; c["h3b15"] += bad >= 15
            c[("h3age", 0 if then[2] != att else 1 if bad < 5 else 2 if bad < 15 else 3)] += 1
            pthen = pl.get((sc, n - 75), {})
            for pid, (x, y) in pl.get((sc, n), {}).items():
                if pid in keepers or who[pid] != att or pid not in pthen: continue
                k = (ROLE.get(pos_of.get(pid, ""), "?"), "ball" if (y > 0) == (by > 0) else "far")
                c[("h3",) + k] += 1; c[("h3adv",) + k] += (x - pthen[pid][0]) * g; c[("h3was",) + k] += (pthen[pid][0] - then[0]) * g
        for lim in (1, 2, 3, 5, 8):
            if nd < lim: c[("nd", lim)] += 1
        c["ndsum"] += min(nd, 30)
    return c
files = sorted(glob.glob(os.path.join(sys.argv[1], "DFL_04_03_positions_raw_observed_*.xml")))
c = collections.Counter()
with multiprocessing.Pool(3) as pool:
    for r in pool.imap_unordered(one, files): c.update(r)
n = c["n"]
print(f"{n} frames ({n/5/len(files)/2:.0f} s a team-match), ball wide 18-35 m off their line")
print(f"  in the channel (0-18, |y| 14+, ball side): attackers {c[('att','chan')]/n:.2f}, defenders {c[('def','chan')]/n:.2f}; in the box: attackers {c[('att','box')]/n:.2f}, defenders {c[('def','box')]/n:.2f}")
roles = sorted({k[1] for k in c if isinstance(k, tuple) and k[0] == "ahead"})
print("  attackers ahead of the ball on its side (|y| 10+), a frame / running 4 m/s+ at the line:", "; ".join(f"{r} {c[('ahead',r)]/n:.2f}/{c[('run',r)]/n:.2f}" for r in roles),
      f"; all {sum(c[('ahead',r)] for r in roles)/n:.2f}/{sum(c[('run',r)] for r in roles)/n:.2f}")
print("  WHERE THEY STAND (a frame; metres ahead of the ball toward their line, metres across toward its touchline):")
for side in ("att", "def"):
    out = []
    for r in ("CB", "FB", "DM/CM", "AM", "WIDE", "ST"):
        for f in ("ball", "far"):
            k = (side, r, f); m = c[("wn",) + k]
            if m: out.append(f"{r}-{f} {m/n:.2f} @ {c[('wa',)+k]/m:+.1f}/{c[('wy',)+k]/m:+.1f}")
    print(f"    {'attacking' if side == 'att' else 'defending'}: " + "; ".join(out))
print("  nearest defender to the ball: mean " + f"{c['ndsum']/n:.1f} m; " + "; ".join(f"<{l} m {100*c[('nd',l)]/n:.0f}%" for l in (1, 2, 3, 5, 8)))
print(f"  offside line {c['line']/max(1,c['linen']):.1f} m ahead of the ball")
h = c["h3n"]
if h:
    print(f"  THREE SECONDS BEFORE: the ball came {c['h3b']/h:.1f} m toward their line (15 m+ {100*c['h3b15']/h:.0f}%); other side had it {100*c[('h3age',0)]/h:.0f}%, came <5 m {100*c[('h3age',1)]/h:.0f}%, 5-15 {100*c[('h3age',2)]/h:.0f}%, 15+ {100*c[('h3age',3)]/h:.0f}%")
    out = []
    for r in ("CB", "FB", "DM/CM", "AM", "WIDE", "ST"):
        for f in ("ball", "far"):
            m = c[("h3", r, f)]
            if m: out.append(f"{r}-{f} {c[('h3adv',r,f)]/m:+.1f} / {c[('h3was',r,f)]/m:+.1f}")
    print("    attacking, came / stood ahead of the ball then: " + "; ".join(out))
e = c["en"]
if e:
    print(f"  ENTRIES inside 30 m: {e/len(files)/2:.1f} a team-match; ball speed at the entry under 7 m/s {100*c[('ens',0)]/e:.0f}%, 7-12 {100*c[('ens',1)]/e:.0f}%, 12+ {100*c[('ens',2)]/e:.0f}%")
    print(f"    at the entry: goal-side {c['en_gs']/e:.2f}, their deepest outfielder {c['en_deep']/e:.1f} m off his line")
    e3 = c["en3"]
    print(f"    3 s before: ball {c['en3_b']/e3:.1f} m out, goal-side {c['en3_gs']/e3:.2f}, deepest {c['en3_deep']/e3:.1f} m, second-deepest (the line) {c['en3_line']/e3:.1f} m; goal-side 3 s before by entry speed: " + ", ".join(f"{('<7','7-12','12+')[s]} {c[('en3_gsb',s)]/max(1,c[('en3_bs',s)]):.2f}" for s in range(3)))
cy = c["cy"]
if cy:
    print(f"  CARRY THROUGH THE BLOCK (35 m+ out to inside 30, one carrier): {cy/len(files)/2:.1f} a team-match ({100*cy/max(1,e):.0f}% of entries); {c['cy_du']/cy:.1f} s, {c['cy_m']/cy:.1f} m toward goal ({c['cy_m']/max(1e-9,c['cy_du']):.1f} m/s)")
    print(f"    goal-side at its start {c['cy_gs0']/cy:.2f}, left behind by the entry {c['cy_pass']/cy:.2f}, goal-side at the entry {c['cy_gs1']/cy:.2f}; nearest defender at the start {c['cy_near0']/cy:.1f} m, closest along it {c['cy_close']/cy:.1f} m")
    print(f"    a defender within 2 m {100*c['cy_eng']/cy:.0f}% of its frames; defenders within 5 m {c['cy_w5']/cy:.2f}; first man within 2 m: " + ", ".join(f"{k[1]} {100*v/cy:.0f}%" for k, v in sorted(((k, v) for k, v in c.items() if isinstance(k, tuple) and k[0] == "cy_fe"), key=lambda kv: -kv[1])))
    print("    at its start by role, goal-side share / metres goal-side of the ball: " + "; ".join(f"{r} {100*c[('cy_rgs',r)]/c[('cy_rn',r)]:.0f}% {c[('cy_rd',r)]/c[('cy_rn',r)]:+.1f}" for r in ("CB","FB","DM/CM","AM","WIDE","ST","?") if c[("cy_rn",r)]))
    for ab, nm in enumerate(("<3 s", "3-10 s", "10+ s")):
        print(f"    side on the ball {nm}: {100*c[('cy_an',ab)]/cy:.0f}% of carries; " + "; ".join(f"{r} {100*c[('cy_ag',ab,r)]/c[('cy_ar',ab,r)]:.0f}% {c[('cy_ad',ab,r)]/c[('cy_ar',ab,r)]:+.1f}" for r in ("CB","FB","DM/CM","AM","WIDE","ST") if c[("cy_ar",ab,r)]))
