-- 1993 (2026-11-27): 🎥 Film analysis — automatic tracking of game film.
--
-- Owner: "can you analyze game film and track analytics on fh" … "i want
-- this totally automated and not worried about time" … "make the replay
-- and put analysis on the page with it. for however long the clip is in
-- future that analysis is on same page".
--
-- A CLIP is any stretch of a film (10 s test today, a minute, a half, a
-- whole game later).  scripts/film/ processes it off-line (players +
-- referees + keepers from Roboflow's football-player model, kit colour →
-- team, the ball's path, and a pan/tilt/zoom camera fitted to the pitch
-- paint so every foot / ball spot gets a position in metres) and loads:
--
--   film_clips            one row per clip: the film, its window, the fitted
--                         camera + pitch, and the replay video (club_files)
--   film_clip_kits        which kit colour is which side in that clip
--   film_clip_camera      pan / tilt / focal per analysed frame
--   film_clip_detections  every player / keeper / referee / ball spot per
--                         frame, in pixels and pitch metres (centre spot
--                         origin, x along the length, y across, near
--                         touchline negative)
--
-- The page #film-analysis (Football menu, coaches) lists clips and shows
-- the replay, a top-down mini-pitch synced to it, and the clip's numbers —
-- computed by the backend from these rows, so a longer clip just has more
-- rows.  Wording: message_templates kind 'film_analysis'.
BEGIN;

CREATE TABLE IF NOT EXISTS film_clips (
    id               serial PRIMARY KEY,
    title            text NOT NULL,
    source_url       text NOT NULL,               -- the film (YouTube etc.)
    fh_event_id      bigint REFERENCES fh_events(id) ON DELETE SET NULL,
    video_start_sec  numeric(9,3) NOT NULL,       -- window inside the film
    video_end_sec    numeric(9,3) NOT NULL,
    analysis_fps     numeric(5,2) NOT NULL,
    camera_x_m       numeric(7,3),                -- fitted camera, pitch metres
    camera_y_m       numeric(7,3),
    camera_z_m       numeric(7,3),
    lens_k1          numeric(8,5),
    pitch_length_m   numeric(6,2) NOT NULL,
    pitch_width_m    numeric(6,2) NOT NULL,
    replay_file_id   integer REFERENCES club_files(id) ON DELETE SET NULL,
    pipeline_note    text,                         -- models / settings used, for the record
    created_at       timestamptz NOT NULL DEFAULT now(),
    CHECK (video_end_sec > video_start_sec)
);

CREATE TABLE IF NOT EXISTS film_clip_kits (
    clip_id     integer NOT NULL REFERENCES film_clips(id) ON DELETE CASCADE,
    kit         text    NOT NULL,                 -- the colour the pipeline reports
    team_label  text    NOT NULL,
    is_ours     boolean,                          -- NULL = not confirmed yet
    sort_order  integer NOT NULL DEFAULT 0,
    PRIMARY KEY (clip_id, kit)
);

CREATE TABLE IF NOT EXISTS film_clip_camera (
    clip_id   integer NOT NULL REFERENCES film_clips(id) ON DELETE CASCADE,
    frame     integer NOT NULL,                   -- frame number inside the clip
    t_sec     numeric(9,3) NOT NULL,              -- seconds from the clip start
    pan_deg   real NOT NULL,
    tilt_deg  real NOT NULL,
    f_px      real NOT NULL,
    solved    boolean NOT NULL,                   -- false = carried between solved frames
    PRIMARY KEY (clip_id, frame)
);

CREATE TABLE IF NOT EXISTS film_clip_detections (
    id        bigserial PRIMARY KEY,
    clip_id   integer NOT NULL REFERENCES film_clips(id) ON DELETE CASCADE,
    frame     integer NOT NULL,
    t_sec     numeric(9,3) NOT NULL,
    kind      text NOT NULL CHECK (kind IN ('player', 'goalkeeper', 'referee', 'ball')),
    kit       text,                               -- players only; joins film_clip_kits
    track_id  integer,                            -- tracker id inside the clip (not a person yet)
    img_x     real NOT NULL,
    img_y     real NOT NULL,
    pitch_x   real,                               -- NULL when the camera couldn't place it
    pitch_y   real,
    conf      real
);
CREATE INDEX IF NOT EXISTS film_clip_detections_clip_frame_idx ON film_clip_detections (clip_id, frame);

INSERT INTO menu_pages (code, group_code, label, icon, audience, sort_order, screens, new_tab, download, is_active)
VALUES ('film-analysis', 'football', 'Film Analysis', '🎥', 'coach', 9, '{film-analysis}', false, false, true)
ON CONFLICT (code) DO NOTHING;

INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side, is_public)
SELECT 'Film analysis', v.label, 'film_analysis', v.tier, v.body, v.so, true, false
  FROM (VALUES
  ('Film analysis — intro', 'intro', 'Game film tracked automatically: every player, the referee and the ball, placed on the pitch. Pick a clip; the mini-pitch follows the replay.', 1),
  ('Film analysis — no clips yet', 'none', 'No clips analysed yet.', 2),
  ('Film analysis — clip list heading', 'clips', 'Clips', 3),
  ('Film analysis — replay heading', 'replay', 'Replay', 4),
  ('Film analysis — mini-pitch heading', 'pitch', 'On the pitch', 5),
  ('Film analysis — numbers heading', 'numbers', 'Numbers', 6),
  ('Film analysis — watch the film link', 'film_link', 'Watch the film from {start}', 7),
  ('Film analysis — clip length line', 'window', '{start}–{end} of the film · {seconds} s · {frames} frames analysed', 8),
  ('Film analysis — ball found', 'ball_found', 'Ball found', 9),
  ('Film analysis — ball distance', 'ball_distance', 'Ball travelled', 10),
  ('Film analysis — ball in thirds', 'ball_thirds', 'Ball in each third (left → right)', 11),
  ('Film analysis — nearest to the ball', 'nearest', 'Nearest to the ball', 12),
  ('Film analysis — players seen', 'seen', 'Players seen per frame', 13),
  ('Film analysis — average position', 'avg_pos', 'Average position (from halfway, m)', 14),
  ('Film analysis — team width', 'width', 'Width (m)', 15),
  ('Film analysis — team depth', 'depth', 'Depth (m)', 16),
  ('Film analysis — camera fitted', 'camera', 'Camera fitted from the pitch lines (frames between are filled in)', 17),
  ('Film analysis — caveat', 'caveat', 'Test quality: the camera only sees part of the pitch, so team numbers count the players in view. Player names are not matched yet.', 18),
  ('Film analysis — kit not confirmed', 'kit_unconfirmed', '(which side is ours not confirmed)', 19)
  ) AS v(label, tier, body, so)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'film_analysis');

INSERT INTO schema_migrations (filename) VALUES ('1993-film-analysis.sql') ON CONFLICT DO NOTHING;
COMMIT;
