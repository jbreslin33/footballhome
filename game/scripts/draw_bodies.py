#!/usr/bin/env python3
"""game/scripts/draw_bodies.py — every player's own body (G4.52).

James: "all players should have different rates of acceleration and speed"
/ "its easy to do individual even if they are all random at first off a
norm" / "use a bell curve". Until someone rates them, each player's
acceleration, deceleration, agility and dribbling are drawn from a bell
curve, N(50, 12) on the 0-100 scale (game_model_params rows say what a
rating means; this says who has what):

  * Correlated the way bodies are [FH estimates, to source]: acceleration
    leans on his pace (rho 0.6 with his z-score inside his own team),
    deceleration and agility on his acceleration (0.5 / 0.4), dribbling on
    his first touch (0.5). Independent draws would make sprinters who can't
    get going and clumsy dribblers with silk touch as often as the rest.
  * Shaped by position where the row has one (wide men quicker and nimbler,
    centre backs slower to turn, attacking players better on the ball).
  * Age is NOT used yet: game_demo_players carries no age (load_squads.py
    reads it from the feeds and only folds it into pace).
  * Deterministic: the draw is seeded per (team, shirt, attribute), so a
    re-run gives the same body; source = 'derived', and a rating marked
    'edited' (the in-game editor) is never overwritten.

Usage: game/scripts/draw_bodies.py [team_id ...]   (default: every team)
"""
import math, random, subprocess, sys

PSQL = ["sudo", "-n", "podman", "exec", "-i", "footballhome_db", "psql", "-v", "ON_ERROR_STOP=1",
        "-U", "footballhome_user", "-d", "footballhome"]
MEAN, SD = 50.0, 12.0
BODY = ["acceleration", "deceleration", "agility", "dribbling"]
# (attribute, what it leans on, rho)
LEANS = {"acceleration": ("pace", 0.6), "deceleration": ("acceleration", 0.5),
         "agility": ("acceleration", 0.4), "dribbling": ("first_touch", 0.5)}
# Position shape, rating points.
POSITION = {
    "GK":  {"acceleration": -4, "agility": -2, "dribbling": -8},
    "CB":  {"acceleration": -4, "agility": -5, "deceleration": 2, "dribbling": -5},
    "LB":  {"acceleration": 4, "agility": 3}, "RB": {"acceleration": 4, "agility": 3},
    "CDM": {"dribbling": -2}, "CM": {}, "CAM": {"agility": 3, "dribbling": 5},
    "LW":  {"acceleration": 5, "agility": 5, "dribbling": 5},
    "RW":  {"acceleration": 5, "agility": 5, "dribbling": 5},
    "ST":  {"acceleration": 3, "agility": 2, "dribbling": 2},
}


def sql(query):
    r = subprocess.run(PSQL + ["-tA", "-F", "\t", "-c", query], capture_output=True, text=True,
                       check=True, stdin=subprocess.DEVNULL)
    return [l.split("\t") for l in r.stdout.splitlines() if l]


def zscores(values):
    vals = [v for v in values.values() if v is not None]
    if len(vals) < 2:
        return {k: 0.0 for k in values}
    mu = sum(vals) / len(vals)
    sd = math.sqrt(sum((v - mu) ** 2 for v in vals) / (len(vals) - 1)) or 1.0
    return {k: (0.0 if v is None else (v - mu) / sd) for k, v in values.items()}


def main():
    teams = [int(t) for t in sys.argv[1:]] or [int(r[0]) for r in sql("SELECT id FROM game_demo_teams ORDER BY id")]
    out = []
    for team in teams:
        players = {int(s): pos.strip().upper() for s, pos in
                   sql(f"SELECT shirt, coalesce(position, '') FROM game_demo_players WHERE team_id = {team}")}
        rated = {}
        for s, a, r, src in sql(f"SELECT shirt, attribute, rating, source FROM game_demo_player_attributes "
                                f"WHERE team_id = {team}"):
            rated[(int(s), a)] = (int(r), src)
        z = {}  # (shirt, attribute) -> z-score inside his team
        for base in ("pace", "first_touch"):
            for shirt, v in zscores({s: rated.get((s, base), (None,))[0] for s in players}).items():
                z[(shirt, base)] = v
        for attr in BODY:  # in order: acceleration before what leans on it
            lean, rho = LEANS[attr]
            for shirt, pos in sorted(players.items()):
                cur = rated.get((shirt, attr))
                if cur and cur[1] == "edited":
                    # His real rating: his z comes from it, nothing is drawn.
                    z[(shirt, attr)] = (cur[0] - MEAN) / SD
                    continue
                rng = random.Random(f"{team}:{shirt}:{attr}:body-v1")
                zz = rho * z.get((shirt, lean), 0.0) + math.sqrt(1 - rho * rho) * rng.gauss(0.0, 1.0)
                z[(shirt, attr)] = zz
                rating = round(MEAN + SD * zz + POSITION.get(pos, {}).get(attr, 0))
                rating = max(1, min(99, rating))
                out.append(f"INSERT INTO game_demo_player_attributes (team_id, shirt, attribute, rating, source) "
                           f"VALUES ({team}, {shirt}, '{attr}', {rating}, 'derived') "
                           f"ON CONFLICT (team_id, shirt, attribute) DO UPDATE SET rating = EXCLUDED.rating "
                           f"WHERE game_demo_player_attributes.source = 'derived';")
    subprocess.run(PSQL + ["--single-transaction", "-q"], input="\n".join(out) + "\n", text=True, check=True)
    print(f"draw_bodies: {len(out)} rating(s) drawn for team(s) {', '.join(map(str, teams))}")


if __name__ == "__main__":
    main()
