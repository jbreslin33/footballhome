-- 1107 (2026-11-05) — Set-piece jobs go to POSITIONS, not just people.
--
-- Owner: "make the takers the positions for specials. like 2 or 3 or 7
-- or weak side winger. strong side winger" … "need all the numbers and
-- in addition ball side winger, ball side fullback, weak side winger,
-- weak side fb".
--
-- A pick now names either a person (as before) or a position ref:
--   * the shirt numbers 1–11 (mig 296: positions.id = shirt number) —
--     whoever starts there in this game's lineup does it;
--   * ball-side / weak-side winger and fullback — relative to the side
--     the ball is on.  A role that carries ball_side ('right'/'left',
--     the corner takers) resolves it outright; any other role shows both
--     (right / left).
--
--   set_piece_position_refs   the choices: shirt number, or the two
--                             numbers a side-relative ref means when the
--                             ball is on the right / the left.
--   set_piece_roles.ball_side 'right' | 'left' | NULL.
--   event_set_piece_picks     person_id OR position_ref_id (exactly one).

CREATE TABLE IF NOT EXISTS set_piece_position_refs (
    id                  SERIAL PRIMARY KEY,
    slug                TEXT NOT NULL UNIQUE,
    title               TEXT NOT NULL,
    position_id         INT REFERENCES positions(id),   -- a plain shirt number
    right_position_id   INT REFERENCES positions(id),   -- ball on the right
    left_position_id    INT REFERENCES positions(id),   -- ball on the left
    sort_order          INT NOT NULL DEFAULT 0,
    CHECK ((position_id IS NOT NULL) <> (right_position_id IS NOT NULL AND left_position_id IS NOT NULL))
);

INSERT INTO set_piece_position_refs (slug, title, position_id, sort_order)
SELECT 'no-' || n, n::text, n, n FROM generate_series(1, 11) AS n
ON CONFLICT (slug) DO NOTHING;

INSERT INTO set_piece_position_refs (slug, title, right_position_id, left_position_id, sort_order) VALUES
    ('ball-side-winger',   'Ball-side winger',   7, 11, 21),
    ('ball-side-fullback', 'Ball-side fullback', 2,  3, 22),
    ('weak-side-winger',   'Weak-side winger',  11,  7, 23),
    ('weak-side-fullback', 'Weak-side fullback', 3,  2, 24)
ON CONFLICT (slug) DO NOTHING;

ALTER TABLE set_piece_roles ADD COLUMN IF NOT EXISTS ball_side TEXT CHECK (ball_side IN ('right', 'left'));
UPDATE set_piece_roles r SET ball_side = v.side
  FROM (VALUES ('taker-right', 'right'), ('taker-left', 'left')) AS v(slug, side), set_piece_groups g
 WHERE g.id = r.group_id AND g.slug = 'corners-for' AND r.slug = v.slug AND r.ball_side IS NULL;

ALTER TABLE event_set_piece_picks ALTER COLUMN person_id DROP NOT NULL;
ALTER TABLE event_set_piece_picks ADD COLUMN IF NOT EXISTS position_ref_id INT REFERENCES set_piece_position_refs(id);
DO $$ BEGIN
  ALTER TABLE event_set_piece_picks ADD CONSTRAINT event_set_piece_picks_who
    CHECK ((person_id IS NOT NULL) <> (position_ref_id IS NOT NULL));
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Match plan', l, 'match_plan', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('positions_group', 'Dropdown group: positions',                      'Positions', 989),
    ('pos_open',        'Position pick with nobody starting there ({pos})', '{pos} (nobody there yet)', 990),
    ('pos_sides',       'Side-relative pick on a role with no ball side ({right} {left})', 'ball right: {right} · ball left: {left}', 991)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'match_plan' AND m.tier = v.t);
