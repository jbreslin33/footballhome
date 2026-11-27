"""Load an analysed clip into the DB (mig 1993 tables) — prints SQL for psql.

  python load_clip.py OUTDIR CALIB.json --title "…" --source-url URL
         --video-start 7.0 --fps 10 [--event FH_EVENT_ID]
         [--kit white="White kit"] [--kit dark="Navy kit"] [--ours white]
         | psql -v ON_ERROR_STOP=1 …

OUTDIR is analyze_clip.py's output (detections.csv, camera.csv, replay.mp4).
The replay goes into club_files (visibility 'members') and film_clips points
at it.  One transaction: a failed load leaves nothing behind.
"""
import argparse, base64, csv, json, os, sys

ap = argparse.ArgumentParser()
ap.add_argument("outdir"); ap.add_argument("calib")
ap.add_argument("--title", required=True); ap.add_argument("--source-url", required=True)
ap.add_argument("--video-start", type=float, required=True); ap.add_argument("--fps", type=float, required=True)
ap.add_argument("--event", type=int); ap.add_argument("--kit", action="append", default=[])
ap.add_argument("--ours"); ap.add_argument("--note", default="")
a = ap.parse_args()

def q(v):
    if v is None or v == "": return "NULL"
    return "'" + str(v).replace("'", "''") + "'"

cal = json.load(open(a.calib))
cam_rows = list(csv.DictReader(open(os.path.join(a.outdir, "camera.csv"))))
det_rows = list(csv.DictReader(open(os.path.join(a.outdir, "detections.csv"))))
last_t = max([float(r["t"]) for r in cam_rows] + [float(r["t"]) for r in det_rows] + [0.0])
video_end = a.video_start + last_t + 1.0 / a.fps
replay = open(os.path.join(a.outdir, "replay.mp4"), "rb").read()

out = sys.stdout
out.write("BEGIN;\n")
out.write("CREATE TEMP TABLE _clip (id int, file_id int) ON COMMIT DROP;\n")
out.write("WITH f AS (INSERT INTO club_files (title, note, original_filename, mime, byte_size, bytes, visibility) VALUES ("
          f"{q('Film analysis replay — ' + a.title)}, {q('scripts/film replay (mig 1993)')}, 'replay.mp4', 'video/mp4', {len(replay)}, "
          f"decode('{base64.b64encode(replay).decode()}', 'base64'), 'members') RETURNING id),\n")
cx, cy, cz = cal["camera"]; L, W = cal["pitch"]
out.write("c AS (INSERT INTO film_clips (title, source_url, fh_event_id, video_start_sec, video_end_sec, analysis_fps, "
          "camera_x_m, camera_y_m, camera_z_m, lens_k1, pitch_length_m, pitch_width_m, replay_file_id, pipeline_note) "
          f"SELECT {q(a.title)}, {q(a.source_url)}, {a.event if a.event else 'NULL'}, {a.video_start}, {round(video_end, 3)}, {a.fps}, "
          f"{cx}, {cy}, {cz}, {cal.get('k1', 0)}, {L}, {W}, f.id, {q(a.note)} FROM f RETURNING id, replay_file_id)\n"
          "INSERT INTO _clip SELECT id, replay_file_id FROM c;\n")
for i, kv in enumerate(a.kit):
    kit, label = kv.split("=", 1)
    ours = "NULL" if not a.ours else ("true" if a.ours == kit else "false")
    out.write(f"INSERT INTO film_clip_kits (clip_id, kit, team_label, is_ours, sort_order) SELECT id, {q(kit)}, {q(label)}, {ours}, {i} FROM _clip;\n")
out.write("CREATE TEMP TABLE _cam (frame int, t_sec numeric, pan_deg real, tilt_deg real, f_px real, solved boolean) ON COMMIT DROP;\n")
out.write("COPY _cam FROM STDIN WITH (FORMAT csv);\n")
w = csv.writer(out, lineterminator="\n")
for r in cam_rows: w.writerow([r["frame"], r["t"], r["pan_deg"], r["tilt_deg"], r["f_px"], "t" if r["solved"] == "True" else "f"])
out.write("\\.\n")
out.write("INSERT INTO film_clip_camera SELECT (SELECT id FROM _clip), * FROM _cam;\n")
out.write("CREATE TEMP TABLE _det (frame int, t_sec numeric, kind text, kit text, track_id int, img_x real, img_y real, pitch_x real, pitch_y real, conf real) ON COMMIT DROP;\n")
out.write("COPY _det FROM STDIN WITH (FORMAT csv);\n")
for r in det_rows:
    w.writerow([r["frame"], r["t"], r["kind"], r["team"], r["track_id"], r["img_x"], r["img_y"], r["pitch_x"], r["pitch_y"], r["conf"]])
out.write("\\.\n")
out.write("INSERT INTO film_clip_detections (clip_id, frame, t_sec, kind, kit, track_id, img_x, img_y, pitch_x, pitch_y, conf) "
          "SELECT (SELECT id FROM _clip), frame, t_sec, kind, NULLIF(kit, ''), track_id, img_x, img_y, pitch_x, pitch_y, conf FROM _det;\n")
out.write("SELECT 'loaded clip ' || id || ' (replay file ' || file_id || ')' FROM _clip;\n")
out.write("COMMIT;\n")
