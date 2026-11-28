#!/usr/bin/env python3
"""🏋️ Sync sources → the exercise catalog (mig 2191).

Owner 11/27: "any new book that comes in must fire off a trigger to do that
book or source too. or we need a sync all sources to exercises?"

A book with no rows in `exercises` is "not read yet" (#exercises → 📚 Sources).
Reading is done by Claude agents (page images → our own words), so the sync
is three steps:

  1. python3 -I scripts/exercises/sync.py queue  WORKDIR
       every coaching book with no exercises → page pairs in WORKDIR/pairs/b<id>/
       + one brief per ~60 pages (Kindle: ~36 spreads) WORKDIR/brief-b<id>-<rng>.txt,
       queue listed in WORKDIR/queue.txt
  2. one general-purpose agent per brief: "Follow the brief in <file> exactly"
       → WORKDIR/out/out-b<id>-<rng>.json
  3. python3 -I scripts/exercises/sync.py load   WORKDIR
       every book whose briefs all have output → one re-runnable migration
       NNNN-exercises-book-<slug>.sql (next free number), applied by hand
       through psql + schema_migrations, like every migration.

Book text never lands in git — only these tools and our paraphrase.
Loading a new book (scripts/books/load_book.py) puts it on the queue.
"""
import glob, json, math, os, re, subprocess, sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HERE))
MIGS = os.path.join(REPO, "database", "migrations")
BOOKS = os.path.expanduser("~/football-data/books")
PSQL = ["sudo", "podman", "exec", "-i", "footballhome_db", "psql", "-q", "-v", "ON_ERROR_STOP=1",
        "-U", "footballhome_user", "-d", "footballhome"]
CROP = (0, 250, 1040, 1800)           # Coach Viewer page incl. footer (load_book.py stops at 1612 and clips progressions)
KINDLE_CROP = (48, 59)                # Kindle spread: title bar / footer
CATS = {"warm_up", "passing_unopposed", "passing_opposed", "rondo", "possession", "positional_game", "small_sided_game",
        "phase_of_play", "combination", "finishing", "one_v_one", "technical", "transition", "defending",
        "conditioned_game", "set_piece", "goalkeeping", "conditioning"}
OPP = {"unopposed", "passive", "opposed", "overload"}
MOM = {"in_possession", "out_of_possession", "to_defend", "to_attack", "set_piece"}


def sql_rows(query):
    out = subprocess.run(PSQL + ["-At", "-F", "\x1f", "-c", query], capture_output=True, text=True,
                         stdin=subprocess.DEVNULL, check=True).stdout
    return [line.split("\x1f") for line in out.splitlines() if line]


def unread_books():
    return sql_rows("SELECT b.id, b.slug, COALESCE(b.page_count, 0), b.title FROM coaching_books b "
                    "WHERE NOT EXISTS (SELECT 1 FROM exercises e WHERE e.book_id = b.id) ORDER BY b.id")


def make_pairs(slug, out):
    from PIL import Image
    os.makedirs(out, exist_ok=True)
    if slug.startswith("kindle-"):
        files = sorted(glob.glob(f"{BOOKS}/{slug}/raw/s[0-9][0-9][0-9].jpg"))
        for f in files:
            dst = f"{out}/{os.path.basename(f)}"
            if os.path.exists(dst): continue
            im = Image.open(f).convert("RGB")
            im.crop((0, KINDLE_CROP[0], im.width, im.height - KINDLE_CROP[1])).save(dst, quality=85)
        return len(files)
    files = sorted(glob.glob(f"{BOOKS}/{slug}/raw/p[0-9][0-9][0-9].png"))
    for i in range(0, len(files), 2):
        a, b = i + 1, min(i + 2, len(files))
        dst = f"{out}/p{a:03d}-{b:03d}.png" if b > a else f"{out}/p{a:03d}.png"
        if os.path.exists(dst): continue
        ims = [Image.open(f).convert("RGB").crop(CROP) for f in files[i:i + 2]]
        w = sum(im.width for im in ims); h = max(im.height for im in ims)
        c = Image.new("RGB", (w, h), "white"); x = 0
        for im in ims: c.paste(im, (x, 0)); x += im.width
        c.resize((w * 2 // 3, h * 2 // 3)).save(dst)
    return len(files)


def cmd_queue(work):
    T = open(f"{HERE}/brief-template.txt").read(); K = open(f"{HERE}/brief-kindle.txt").read()
    os.makedirs(f"{work}/out", exist_ok=True)
    lines = []
    for bid, slug, n, title in unread_books():
        kin = slug.startswith("kindle-")
        n = make_pairs(slug, f"{work}/pairs/b{bid}") or int(n)
        if not n: print(f"skip b{bid} {slug}: no pages captured"); continue
        per = 36 if kin else 60
        k = max(1, math.ceil(n / per)); size = math.ceil(n / k / 2) * 2
        for a in range(1, n + 1, size):
            z = min(a + size - 1, n); rng = f"{a:03d}-{z:03d}"
            open(f"{work}/brief-b{bid}-{rng}.txt", "w").write(
                (K if kin else T).format(TITLE=title, KEY=f"b{bid}", A=a, Z=z, RNG=rng, N=n, W=work))
            lines.append(f"b{bid} {rng} {slug}")
    open(f"{work}/queue.txt", "w").write("\n".join(lines) + "\n")
    print(f"{len(lines)} briefs for {len({l.split()[0] for l in lines})} books → {work}/queue.txt")


def q(v):
    if v is None or v == "": return "NULL"
    if isinstance(v, bool): return "true" if v else "false"
    if isinstance(v, (int, float)): return repr(v)
    return "'" + str(v).replace("'", "''") + "'"


def num(v, cast=float):
    try: return q(cast(v)) if v not in (None, "") else "NULL"
    except (TypeError, ValueError): return "NULL"


def next_mig():
    used = {int(m.group(1)) for f in os.listdir(MIGS) if (m := re.match(r"^(\d+)-", f))}
    used |= {int(r[0]) for r in sql_rows("SELECT substring(filename from '^[0-9]+') FROM schema_migrations "
                                         "WHERE filename ~ '^[0-9]+-'")}
    return max(used) + 1


def book_sql(num_, name, slug, rows):
    rows.sort(key=lambda e: (e["p"][0], e["p"][-1]))
    seen, keep = set(), []
    for e in rows:
        k = (e["t"].strip().lower(), e["p"][0])
        if k in seen: continue
        seen.add(k)
        if e.get("cat") not in CATS: e["cat"] = "passing_unopposed" if e.get("opp") == "unopposed" else "passing_opposed"
        if e.get("opp") not in OPP: e["opp"] = None
        if e.get("m") not in MOM: e["m"] = None
        keep.append(e)
    B = f"(SELECT id FROM coaching_books WHERE slug = {q(slug)})"
    L = [f"-- {num_} 🏋️ Exercises from the book \"{slug}\" into the exercise catalog (mig 2191).",
         "-- Every practice the book sets out, in OUR OWN WORDS, with app page numbers",
         "-- (the diagram is the book page).  Written by scripts/exercises/sync.py load.",
         "-- Re-runnable: clears this book's exercises first.",
         "BEGIN;", f"DELETE FROM exercises WHERE book_id = {B};"]
    if keep:
        vals = []
        for i, e in enumerate(keep):
            pf, pt = int(e["p"][0]), int(e["p"][-1]); pt = max(pt, pf)
            vals.append("  (" + ", ".join([q(e["t"]), q(e["cat"]), q(e["opp"]), q(e["m"]), str(pf), str(pt),
                q(e.get("ref")), q(e.get("coach")), q(e.get("obj") or e["t"]), q(e.get("setup")), q(e.get("proc")),
                q(e.get("rules")), q(e.get("prog")), q(e.get("cp")), q(e.get("players")), num(e.get("min"), int),
                num(e.get("max"), int), q(e.get("area")), num(e.get("len_m")), num(e.get("wid_m")), num(e.get("dur")),
                q(bool(e.get("goals"))), q(bool(e.get("gk"))), q(bool(e.get("dir"))), q(e.get("age")), str((i + 1) * 10)]) + ")")
        L += ["INSERT INTO exercises (title, category_id, opposition, moment, source_id, book_id, page_from, page_to, source_ref, coach,",
              "  objective, setup, procedure, rules, progressions, coaching_points, players_text, min_players, max_players,",
              "  area_text, area_length_m, area_width_m, duration_min, has_goals, has_keepers, directional, age_text, sort_order)",
              "SELECT v.t, c.id, v.opp, v.m, b.source_id, b.id, v.pf::int, v.pt::int, v.ref, v.coach, v.obj, v.setup, v.proc, v.rules, v.prog, v.cp,",
              "  v.players, v.mn::int, v.mx::int, v.area, v.len::real, v.wid::real, v.dur::real, v.goals::boolean, v.gk::boolean, v.dir::boolean, v.age, v.so",
              "FROM (VALUES", ",\n".join(vals),
              ") AS v(t, cat, opp, m, pf, pt, ref, coach, obj, setup, proc, rules, prog, cp, players, mn, mx, area, len, wid, dur, goals, gk, dir, age, so)",
              "JOIN exercise_categories c ON c.code = v.cat",
              f"CROSS JOIN (SELECT id, source_id FROM coaching_books WHERE slug = {q(slug)}) b;"]
    L += [f"INSERT INTO schema_migrations (filename) VALUES ('{num_}-{name}.sql') ON CONFLICT DO NOTHING;", "COMMIT;", ""]
    return "\n".join(L), len(keep)


def cmd_load(work, apply=True):
    queue = [l.split() for l in open(f"{work}/queue.txt") if l.strip()]
    books = {}
    for key, rng, slug in queue: books.setdefault((key, slug), []).append(rng)
    for (key, slug), rngs in books.items():
        outs = [f"{work}/out/out-{key}-{r}.json" for r in rngs]
        if not all(os.path.exists(o) for o in outs): continue
        bid = key[1:]
        if sql_rows(f"SELECT 1 FROM exercises WHERE book_id = {int(bid)} LIMIT 1"): continue   # already loaded
        name = "exercises-book-" + re.sub(r"[^a-z0-9]+", "-", slug.lower()).strip("-")[:60]
        if glob.glob(f"{MIGS}/*-{name}.sql"): continue                                        # written before (maybe 0 exercises)
        rows = []
        for o in outs: rows += json.load(open(o)).get("exercises", [])
        n = next_mig()
        sql, count = book_sql(n, name, slug, rows)
        path = f"{MIGS}/{n}-{name}.sql"
        open(path, "w").write(sql)
        if apply:
            subprocess.run(PSQL, input=sql.encode(), check=True)
        print(f"{key} {slug}: {count} exercises → {os.path.basename(path)}{' (applied)' if apply else ''}")


if __name__ == "__main__":
    if len(sys.argv) < 3 or sys.argv[1] not in ("queue", "load"): sys.exit(__doc__)
    work = os.path.abspath(sys.argv[2])
    cmd_queue(work) if sys.argv[1] == "queue" else cmd_load(work, apply="--no-apply" not in sys.argv)
