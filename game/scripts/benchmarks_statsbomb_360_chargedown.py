#!/usr/bin/env python3
"""benchmarks_statsbomb_360_chargedown.py — how often a pressed pass is charged down (G5.165, game/DESIGN.md §8.271).

    python3 -I game/scripts/benchmarks_statsbomb_360_chargedown.py <open360 dir> <PL 15/16 events dir>

Real blocked passes are the presser's: the blocker 2.2 / 3.0 / 4.4 m from the passer, the ball at him 0.1-0.3 s
after the kick (StatsBomb PL 2015/16, 11.97 a team-match = 2.8% of open-play passes). From the 360 freeze frames
(every visible player at the event; StatsBomb Open Data's men's competitions with 360), each open-play pass's
passer (the actor) and his nearest visible opponent outfielder, metres (120 x 80 scaled to 105 x 68); by that
distance (0-1 / 1-2 / 2-3 / 3-5 / 5+ m) and by the pass's height (Ground / Low / High), the share CHARGED DOWN: a
Block linked to the pass, or the next touch the opponents' (Interception, Ball Recovery, Clearance, Miscontrol,
Duel, Block) within 8 m of the passer and 0.6 s of the kick — fh-game-match's PASSES CHARGED DOWN cut (their touch
in the first 0.4 s / 8 m; StatsBomb timestamps are logged to the event, so 0.6 s). Then PL 15/16's charged-down
share of all open-play passes on the same rule (no freeze frames there). Data: StatsBomb Open Data, free with
attribution to StatsBomb. FH original.
"""
import collections, glob, json, math, os, sys

SX, SY = 105 / 120, 68 / 80
SET = ("Corner", "Free Kick", "Goal Kick", "Kick Off", "Throw-in")
SKIP = ("Ball Receipt*", "Pressure", "Foul Won", "Foul Committed")
THEIRS = ("Interception", "Ball Recovery", "Clearance", "Miscontrol", "Duel", "Block")
BINS = [(0, 1), (1, 2), (2, 3), (3, 5), (5, 1e9)]


def secs(e):
    h, m, s = e["timestamp"].split(":")
    return e["period"] * 10000 + int(h) * 3600 + int(m) * 60 + float(s)


def charged(ev, i, e, blocked):
    """True if the pass at ev[i] was charged down by the opponents near the passer."""
    if e["id"] in blocked: return True
    t0 = secs(e); sx, sy = e["location"]
    for g in ev[i + 1:i + 8]:
        if secs(g) - t0 > 0.6: return False
        if g["type"]["name"] in SKIP: continue
        if g["team"]["id"] == e["team"]["id"] or g["type"]["name"] not in THEIRS or "location" not in g: return False
        gx, gy = 120 - g["location"][0], 80 - g["location"][1]   # their frame → the passer's
        return math.hypot((gx - sx) * SX, (gy - sy) * SY) < 8
    return False


def blocked_ids(ev):
    byid = {e["id"]: e for e in ev}
    out = set()
    for e in ev:
        if e["type"]["name"] == "Block":
            for r in e.get("related_events", []):
                if r in byid and byid[r]["type"]["name"] == "Pass": out.add(r)
    return out


def open_pass(e):
    return e["type"]["name"] == "Pass" and e["pass"].get("type", {}).get("name") not in SET and "location" in e


def main():
    N = collections.Counter(); C = collections.Counter()
    for d in sorted(glob.glob(os.path.join(sys.argv[1], "*_*"))):
        if not os.path.isdir(d): continue
        for f in glob.glob(os.path.join(d, "360_*.json")):
            mid = os.path.basename(f)[4:]
            ev = json.load(open(os.path.join(d, "events_" + mid), encoding="utf8"))
            idx = {e["id"]: i for i, e in enumerate(ev)}
            blk = blocked_ids(ev)
            for fr in json.load(open(f, encoding="utf8")):
                i = idx.get(fr["event_uuid"])
                if i is None or not open_pass(ev[i]): continue
                e = ev[i]
                act = [p for p in fr["freeze_frame"] if p.get("actor")]
                if not act: continue
                ax, ay = act[0]["location"]
                opp = [math.hypot((p["location"][0] - ax) * SX, (p["location"][1] - ay) * SY)
                       for p in fr["freeze_frame"] if not p["teammate"] and not p.get("keeper")]
                dmin = min(opp) if opp else 99.0
                b = next(k for k, (lo, hi) in enumerate(BINS) if lo <= dmin < hi)
                h = e["pass"].get("height", {}).get("name", "?").split()[0]
                c = charged(ev, i, e, blk)
                for key in ((b, h), (b, "all"), ("all", h), ("all", "all")):
                    N[key] += 1; C[key] += c
    print("StatsBomb 360 open-play passes: charged down (a linked Block, or the opponents' next touch within 8 m of the passer, 0.6 s) by the passer's nearest visible opponent")
    print(f"  {'nearest':8s} " + "  ".join(f"{h:>18s}" for h in ("Ground", "Low", "High", "all")))
    for b in list(range(len(BINS))) + ["all"]:
        lab = "all" if b == "all" else (f"{BINS[b][0]:g}-{BINS[b][1]:g} m" if BINS[b][1] < 1e8 else f"{BINS[b][0]:g}+ m")
        print(f"  {lab:8s} " + "  ".join(f"{N[(b, h)]:7d} {100 * C[(b, h)] / max(1, N[(b, h)]):5.1f}%     " for h in ("Ground", "Low", "High", "all")))
    under3 = sum(N[(b, "all")] for b in range(3)); c3 = sum(C[(b, "all")] for b in range(3))
    print(f"  pressed (under 3 m) {100 * under3 / max(1, N[('all', 'all')]):.1f}% of passes, charged down {100 * c3 / max(1, under3):.1f}%;"
          f" unpressed {100 * (C[('all', 'all')] - c3) / max(1, N[('all', 'all')] - under3):.1f}%")
    n = c = tm = 0
    for f in glob.glob(os.path.join(sys.argv[2], "*.json")):
        if not os.path.basename(f)[0].isdigit(): continue
        ev = json.load(open(f, encoding="utf8")); blk = blocked_ids(ev); tm += 2
        for i, e in enumerate(ev):
            if open_pass(e): n += 1; c += charged(ev, i, e, blk)
    print(f"StatsBomb PL 2015/16: {c / tm:.2f} open-play passes charged down a team-match of {n / tm:.1f} ({100 * c / max(1, n):.1f}%)")


if __name__ == "__main__":
    main()
