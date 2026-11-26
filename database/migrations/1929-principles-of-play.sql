-- 1929 (2026-11-26): the PRINCIPLES OF PLAY — the universal layer above every game model.
-- Owner 11/26: "lets think like a coach … do we start with the principles of play which sit above all game models and
-- style?" · "yes start with principles of play".
-- Layers, top down: principles of play (universal, this table) → moments (game_moments) → game model principles
-- (game_principles, the 19 rows: how WE play each moment) → formation + style → concepts (game_concepts) → actions.
-- The classic ten (Allen Wade, FA, 1967; taught the same by the FA and US Soccer since): five attacking, five
-- defending. Definitions are FH wording — what it is / when / what it is NOT — for the owner to correct.
-- Each game-model principle points UP to the one it mainly serves (play_principle_id). Set pieces use all ten: no parent.
-- Source row unverified until the research session checks it against the text.

CREATE TABLE IF NOT EXISTS game_play_principles (
    id          serial PRIMARY KEY,
    code        text NOT NULL UNIQUE,
    side        text NOT NULL CHECK (side IN ('attack', 'defend')),
    title       text NOT NULL,
    aka         text NOT NULL DEFAULT '',
    definition  text NOT NULL,
    is_not      text NOT NULL DEFAULT '',
    sort_order  smallint NOT NULL
);

CREATE TABLE IF NOT EXISTS game_play_principle_sources (
    principle_id integer NOT NULL REFERENCES game_play_principles(id) ON DELETE CASCADE,
    source_id    integer NOT NULL REFERENCES game_sources(id),
    note         text NOT NULL DEFAULT '',
    PRIMARY KEY (principle_id, source_id)
);

ALTER TABLE game_principles ADD COLUMN IF NOT EXISTS play_principle_id integer REFERENCES game_play_principles(id);

INSERT INTO game_play_principles (code, side, title, aka, definition, is_not, sort_order) VALUES
  ('penetration', 'attack', 'Penetration', 'going forward',
   'Get the ball, or a man, past defenders toward their goal: a pass, a run or a carry that takes one or more of them out of the game. The first question for the man on the ball whenever we have it.',
   'Not just going forward: a pass forward that lets them all stay goal side has penetrated nobody.', 1),
  ('support', 'attack', 'Support', 'depth in attack',
   'Team-mates near the ball at angles and distances that give the man on it a safe option — beside, behind or ahead of him — so he is never alone and the ball can be kept.',
   'Not standing next to him: a man in his passing lane or behind a defender is no support.', 2),
  ('width', 'attack', 'Width', '',
   'Use the whole width of the pitch, so their defenders have to spread out and gaps open between them.',
   'Not only wingers on the touchline: width is the team''s, and can come from full-backs or a switch.', 3),
  ('mobility', 'attack', 'Mobility', 'movement',
   'Men without the ball move — away, into gaps, behind, swapping places — to pull defenders out of shape and make space for the ball or for each other.',
   'Not running for its own sake: a move that takes nobody with it and opens nothing is not mobility.', 4),
  ('improvisation', 'attack', 'Improvisation', 'creativity',
   'The man on the ball does the unexpected — a feint, a dribble, a pass they did not read — to unbalance an organised defence, usually in the last third.',
   'Not carelessness: risk where losing it costs little and the reward is a chance.', 5),
  ('pressure', 'defend', 'Pressure', 'delay; the first defender',
   'The nearest man to the ball goes to it, goal side, to stop it going forward: slow him down, show him away from goal, win it when he can. Buys time for the rest to get back and set.',
   'Not diving in: a first defender who is beaten has delayed nothing.', 6),
  ('cover', 'defend', 'Cover', 'depth in defence; the second defender',
   'A second man behind and to the side of the first, close enough to take the ball carrier if the first is beaten, and to tell him which way to show.',
   'Not level with the first defender: two men in a line are beaten by one touch.', 7),
  ('balance', 'defend', 'Balance', 'the third defenders',
   'The men away from the ball cover the space and the runners on the far side — goal side, tucked in — so a switch or a run behind finds a defender.',
   'Not marking every man tight: balance gives up the far man to protect the space that matters.', 8),
  ('compactness', 'defend', 'Compactness', 'concentration',
   'The team narrows and shortens around the ball and toward our goal, so the space between and behind the lines is small and every pass through is contested.',
   'Not dropping into our box: compact means short and narrow, at whatever height the game model sets.', 9),
  ('control-restraint', 'defend', 'Control and restraint', 'patience',
   'Stay on your feet and stay organised: wait for the right moment to win it — a bad touch, a back pass, a trap — rather than commit early and open the team up.',
   'Not passive: restraint is waiting to win it, not waiting for them to miss.', 10)
ON CONFLICT (code) DO NOTHING;

INSERT INTO game_sources (code, kind, title, url, verified)
SELECT 'wade-fa-guide-1967', 'book', 'Allen Wade, The F.A. Guide to Training and Coaching (1967) — the principles of play', NULL, false
 WHERE NOT EXISTS (SELECT 1 FROM game_sources WHERE code = 'wade-fa-guide-1967');

INSERT INTO game_play_principle_sources (principle_id, source_id, note)
SELECT p.id, s.id, 'the classic ten; FH wording'
  FROM game_play_principles p, game_sources s
 WHERE s.code = 'wade-fa-guide-1967'
ON CONFLICT DO NOTHING;
INSERT INTO game_play_principle_sources (principle_id, source_id, note)
SELECT p.id, s.id, 'England DNA principles of play'
  FROM game_play_principles p, game_sources s
 WHERE s.code = 'fa-england'
ON CONFLICT DO NOTHING;

-- Each game-model principle up to the one it mainly serves.
UPDATE game_principles g SET play_principle_id = p.id
  FROM game_play_principles p, (VALUES
    ('ip-build-up', 'support'),          -- get it out in control: options round the ball
    ('ip-shape', 'width'),               -- height, width, depth: stretch them
    ('ip-secure', 'support'),
    ('ip-progress', 'penetration'),
    ('ip-create', 'improvisation'),
    ('ip-finish', 'penetration'),
    ('op-pressure', 'pressure'),
    ('op-press-team', 'pressure'),
    ('op-compact', 'compactness'),
    ('op-mark', 'balance'),
    ('op-protect-goal', 'compactness'),
    ('op-keeper', 'cover'),
    ('td-regain', 'pressure'),
    ('td-recover', 'cover'),             -- delay and get back goal side: depth before the ball
    ('ta-forward', 'penetration'),
    ('ta-secure', 'support'),
    ('ta-spread', 'width')
  ) AS m(g, p)
 WHERE g.code = m.g AND p.code = m.p;
