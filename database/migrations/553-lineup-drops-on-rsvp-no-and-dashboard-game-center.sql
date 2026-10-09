-- 553 (2026-10-09) — a player who answers anything but yes leaves the
-- lineup, and the #dashboard Game Center cell.
--
-- Owner: "if a player changes his availability after we put him in lineup
-- like tolu did we need to remove him from bench or starters if starter
-- then its blank spot of course".  A trigger on fh_event_rsvps: when a
-- game's RSVP lands as anything but 'yes', that person's match_lineups
-- rows for the match go — a starter's slot is simply empty again, a bench
-- row is gone.  Every RSVP path (buttons, standing answers, roll call,
-- magic link) writes fh_event_rsvps, so none can miss it.  The one row
-- already wrong today (a starter who answered no on 2026-10-08) is
-- cleaned up the same way below.
--
-- Owner: "we need game center dash item. like showing number of possible
-- starters and subs … and if starters have been filled out. i know we
-- auto fill the kids".  GET /api/dashboard lists the week's games with
-- going / can start / on track (the same starter rule Game Center's
-- Practice Criteria pill uses: fh_starter_window + fh_starter_policy, a
-- late game RSVP costs the start where the policy says so) and whether
-- the lineup is set; the words live here.
CREATE OR REPLACE FUNCTION fh_lineup_drop_on_rsvp() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE v_match_id integer;
BEGIN
    IF NEW.response = 'yes' THEN RETURN NEW; END IF;
    SELECT fe.match_id INTO v_match_id FROM fh_events fe WHERE fe.id = NEW.fh_event_id;
    IF v_match_id IS NULL THEN RETURN NEW; END IF;
    DELETE FROM match_lineups ml
     WHERE ml.match_id = v_match_id
       AND ml.player_id IN (SELECT pl.id FROM players pl WHERE pl.person_id = NEW.person_id);
    RETURN NEW;
END $$;
COMMENT ON FUNCTION fh_lineup_drop_on_rsvp() IS 'mig 553: a game RSVP of anything but yes removes that person from the match lineup (starter slot left empty, bench row gone).';
DROP TRIGGER IF EXISTS fh_event_rsvps_lineup_drop ON fh_event_rsvps;
CREATE TRIGGER fh_event_rsvps_lineup_drop
AFTER INSERT OR UPDATE OF response ON fh_event_rsvps
FOR EACH ROW EXECUTE FUNCTION fh_lineup_drop_on_rsvp();

-- Today's mismatch: anyone in a coming game's lineup whose answer is no.
DELETE FROM match_lineups ml
 USING players pl, fh_events fe, gcal_events ge, fh_event_rsvps rv
 WHERE pl.id = ml.player_id AND fe.match_id = ml.match_id AND ge.id = fe.gcal_event_id
   AND rv.fh_event_id = fe.id AND rv.person_id = pl.person_id
   AND ge.starts_at > now() AND rv.response = 'no';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Dashboard', l, 'dashboard', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('gc_title',       'Game Center cell — title',                             '🏟️ Game Center', 853),
    ('gc_sub',         'Game Center cell — line under the title',              'This week''s games — who is going, who can start, is the lineup set', 854),
    ('gc_count',       'Game Center cell — under the big number ({days})',     'games in {days} days', 855),
    ('gc_none',        'Game Center cell — no games ({days})',                 'No games in the next {days} days', 856),
    ('gc_going',       'Game Center cell — going ({n} {of})',                  '{n} going of {of}', 857),
    ('gc_can_start',   'Game Center cell — can start now ({n})',               '{n} can start', 858),
    ('gc_on_track',    'Game Center cell — on track with upcoming practices ({n})', '{n} on track', 859),
    ('gc_need',        'Game Center cell — starters a game needs ({n})',       'need {n}', 860),
    ('gc_lineup_set',  'Game Center cell — lineup set ({starters} {bench})',   'lineup {starters} + {bench} bench', 861),
    ('gc_lineup_none', 'Game Center cell — lineup not set',                    'no lineup yet', 862),
    ('gc_lineup_part', 'Game Center cell — starters short ({starters} {need})','lineup {starters} of {need}', 863),
    ('gc_everyone',    'Game Center cell — kids: everyone plays',              'everyone plays', 864),
    ('gc_not_going',   'Game Center cell — in the lineup but not going ({n})', '{n} in lineup not going', 865)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'dashboard' AND m.tier = v.t);
