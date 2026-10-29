-- 822 (2026-10-29) — game: the REFEREE has his own taxonomy — the laws he
-- applies, the judgements inside them (cue → call), what he must SEE to make
-- each one, where he stands to see it — and the officials are bodies on the
-- pitch with their own ratings (game/DESIGN.md §8.86, G4.88).
--
-- James 10/29: "do we have offsides lol" — "we need an ai ref. that has its
-- own taxonomy of what he sees adn understands". Until now the World WAS the
-- referee: exact positions at the instant of every kick, never wrong. Now the
-- assistant referee judges offside from where HE stands and HIS call stands;
-- the World keeps the truth only for the harness.
--
-- First slice: offside by the assistants (wired), ball out of play exact (the
-- World, as before — the row says so), fouls / advantage / penalties as
-- 'teaching' rows only: fouls and cards are still a v1 non-goal (DESIGN §8).
--
-- Sources (verified 10/29): IFAB Laws of the Game (Law 11 text as the FA
-- reproduces it); IFAB Practical Guidelines, positioning (AR in line with the
-- second-last defender or the ball if nearer the goal line; wide diagonal);
-- Oudejans et al. 2000 (Nature 404:33 — AR errors from his viewing angle,
-- usually standing beyond the last defender: 179 of 200 situations); Helsen,
-- Gilis & Weston 2006 (J Sports Sci 24:521-528 — 2002 World Cup, 337
-- offsides, ~26% wrong, 86.6% of errors flags: the flash-lag account).
-- Numbers marked [FH] are estimates.

INSERT INTO game_sources (code, kind, title, url, verified) VALUES
  ('ifab-lotg', 'federation', 'IFAB, Laws of the Game 2025/26', 'https://www.thefa.com/football-rules-governance/lawsandrules/laws/football-11-11/law-11---offside', true),
  ('ifab-guidelines', 'federation', 'IFAB, Practical Guidelines for Match Officials: positioning, movement and teamwork', 'https://www.theifab.com/laws/latest/guidelines/positioning-movement-and-teamwork/', true),
  ('oudejans-2000', 'analysis', 'Oudejans, Verheijen, Bakker, Gerrits, Steinbrückner & Beek (2000), Errors in judging ''offside'' in football, Nature 404:33', 'https://www.nature.com/articles/35003639', true),
  ('helsen-2006', 'analysis', 'Helsen, Gilis & Weston (2006), Errors in judging "offside" in association football: test of the optical error versus the perceptual flash-lag hypothesis, J Sports Sci 24:521-528', 'https://research.tees.ac.uk/en/publications/errors-in-judging-offside-in-association-football-test-of-the-opt/', true)
ON CONFLICT (code) DO NOTHING;

-- ── the referee's taxonomy ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS game_ref_laws (
    id      SMALLINT PRIMARY KEY,
    number  SMALLINT NOT NULL UNIQUE CHECK (number BETWEEN 1 AND 17),
    code    TEXT NOT NULL UNIQUE,
    title   TEXT NOT NULL,
    summary TEXT NOT NULL,
    status  TEXT NOT NULL CHECK (status IN ('wired', 'partial', 'teaching')),
    source_id INTEGER NOT NULL REFERENCES game_sources(id)
);
COMMENT ON TABLE game_ref_laws IS 'The IFAB Laws the AI officials apply (mig 822). wired = played by the engine; partial = some of its judgements; teaching = dictionary only.';

CREATE TABLE IF NOT EXISTS game_ref_judgements (
    id       SMALLINT PRIMARY KEY,
    law_id   SMALLINT NOT NULL REFERENCES game_ref_laws(id),
    code     TEXT NOT NULL UNIQUE,
    title    TEXT NOT NULL,
    cue_call TEXT NOT NULL,          -- cue → call, in referee words
    made_by  TEXT NOT NULL CHECK (made_by IN ('referee', 'assistant', 'world')),
    status   TEXT NOT NULL CHECK (status IN ('wired', 'teaching')),
    sort_order SMALLINT NOT NULL DEFAULT 0
);
COMMENT ON TABLE game_ref_judgements IS 'A decision inside a law (mig 822). made_by world = the engine still decides it exactly (no official perception yet).';

CREATE TABLE IF NOT EXISTS game_ref_perceptions (
    id     SMALLINT PRIMARY KEY,
    code   TEXT NOT NULL UNIQUE,
    title  TEXT NOT NULL,
    how    TEXT NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('wired', 'teaching'))
);
COMMENT ON TABLE game_ref_perceptions IS 'What an official must SEE to judge (mig 822) — and how his eyes can fool him.';

CREATE TABLE IF NOT EXISTS game_ref_judgement_perceptions (
    judgement_id  SMALLINT NOT NULL REFERENCES game_ref_judgements(id),
    perception_id SMALLINT NOT NULL REFERENCES game_ref_perceptions(id),
    PRIMARY KEY (judgement_id, perception_id)
);

CREATE TABLE IF NOT EXISTS game_ref_positionings (
    id     SMALLINT PRIMARY KEY,
    code   TEXT NOT NULL UNIQUE,
    role   TEXT NOT NULL CHECK (role IN ('referee', 'assistant')),
    title  TEXT NOT NULL,
    how    TEXT NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('wired', 'teaching'))
);
COMMENT ON TABLE game_ref_positionings IS 'Where an official stands to see (mig 822).';

CREATE TABLE IF NOT EXISTS game_ref_law_sources (
    law_id SMALLINT NOT NULL REFERENCES game_ref_laws(id),
    source_id INTEGER NOT NULL REFERENCES game_sources(id),
    citation TEXT NOT NULL, verified BOOLEAN NOT NULL DEFAULT true,
    PRIMARY KEY (law_id, source_id));
CREATE TABLE IF NOT EXISTS game_ref_judgement_sources (
    judgement_id SMALLINT NOT NULL REFERENCES game_ref_judgements(id),
    source_id INTEGER NOT NULL REFERENCES game_sources(id),
    citation TEXT NOT NULL, verified BOOLEAN NOT NULL DEFAULT true,
    PRIMARY KEY (judgement_id, source_id));
CREATE TABLE IF NOT EXISTS game_ref_perception_sources (
    perception_id SMALLINT NOT NULL REFERENCES game_ref_perceptions(id),
    source_id INTEGER NOT NULL REFERENCES game_sources(id),
    citation TEXT NOT NULL, verified BOOLEAN NOT NULL DEFAULT true,
    PRIMARY KEY (perception_id, source_id));
CREATE TABLE IF NOT EXISTS game_ref_positioning_sources (
    positioning_id SMALLINT NOT NULL REFERENCES game_ref_positionings(id),
    source_id INTEGER NOT NULL REFERENCES game_sources(id),
    citation TEXT NOT NULL, verified BOOLEAN NOT NULL DEFAULT true,
    PRIMARY KEY (positioning_id, source_id));

-- ── the officials: crews, men, their own ratings ────────────────────────
CREATE TABLE IF NOT EXISTS game_ref_attributes (
    code        TEXT PRIMARY KEY,
    name        TEXT NOT NULL,
    description TEXT NOT NULL,
    scales      TEXT NOT NULL,
    status      TEXT NOT NULL CHECK (status IN ('wired', 'teaching')),
    sort_order  SMALLINT NOT NULL DEFAULT 0
);
COMMENT ON TABLE game_ref_attributes IS 'An official''s own ratings (mig 822), 0-100 like a player''s.';

CREATE TABLE IF NOT EXISTS game_official_crews (
    id    SERIAL PRIMARY KEY,
    code  TEXT NOT NULL UNIQUE,
    name  TEXT NOT NULL,
    level TEXT NOT NULL CHECK (level IN ('u10', 'u14', 'amateur', 'semipro', 'pro', 'world'))
);
COMMENT ON TABLE game_official_crews IS 'A match''s officials (mig 822); a match is run by the crew of its home team''s level.';

CREATE TABLE IF NOT EXISTS game_officials (
    id      SERIAL PRIMARY KEY,
    crew_id INTEGER NOT NULL REFERENCES game_official_crews(id) ON DELETE CASCADE,
    role    TEXT NOT NULL CHECK (role IN ('referee', 'assistant_1', 'assistant_2')),
    name    TEXT NOT NULL,
    UNIQUE (crew_id, role)
);
COMMENT ON COLUMN game_officials.role IS 'assistant_1 runs the +y touchline and the +x half, assistant_2 the -y touchline and the -x half (the diagonal).';

CREATE TABLE IF NOT EXISTS game_official_ratings (
    official_id INTEGER NOT NULL REFERENCES game_officials(id) ON DELETE CASCADE,
    attribute   TEXT NOT NULL REFERENCES game_ref_attributes(code),
    rating      SMALLINT NOT NULL CHECK (rating BETWEEN 0 AND 100),
    PRIMARY KEY (official_id, attribute)
);

-- ── rows ────────────────────────────────────────────────────────────────
INSERT INTO game_ref_laws (id, number, code, title, summary, status, source_id)
SELECT x.id, x.number, x.code, x.title, x.summary, x.status, s.id
FROM (VALUES
  (5,  5,  'law-5-referee',            'The Referee', 'Full authority; his decisions on facts are final; advantage; positions to judge.', 'partial'),
  (6,  6,  'law-6-other-officials',    'The Other Match Officials', 'Assistant referees indicate offside, ball out of play and offences out of the referee''s view.', 'partial'),
  (9,  9,  'law-9-ball-in-out',        'The Ball In and Out of Play', 'Out when it has wholly passed over the goal line or touchline, or play is stopped.', 'wired'),
  (11, 11, 'law-11-offside',           'Offside', 'Offside position: head, body or feet in the opponents'' half nearer their goal line than both the ball and the second-last opponent (level is onside); an offence only on becoming involved in active play.', 'wired'),
  (12, 12, 'law-12-fouls-misconduct',  'Fouls and Misconduct', 'Direct and indirect free-kick offences; careless, reckless, excessive force; handball; cautions and sending-offs.', 'teaching'),
  (13, 13, 'law-13-free-kicks',        'Free Kicks', 'Direct and indirect; the offside offence restarts with an indirect free kick where it happened.', 'partial'),
  (14, 14, 'law-14-penalty-kick',      'The Penalty Kick', 'A direct free-kick offence by a defender inside his own penalty area.', 'teaching')
) AS x(id, number, code, title, summary, status)
JOIN game_sources s ON s.code = 'ifab-lotg'
ON CONFLICT (id) DO NOTHING;

INSERT INTO game_ref_judgements (id, law_id, code, title, cue_call, made_by, status, sort_order) VALUES
  (1,  11, 'offside-position', 'Offside position at the kick',
   'A teammate plays or touches the ball → at THAT moment, is the attacker in the opponents'' half and nearer their goal line than the ball and the second-last opponent? Level is onside. Judged by the assistant from where he stands.', 'assistant', 'wired', 1),
  (2,  11, 'offside-involved-playing', 'Involved: playing the ball',
   'A man flagged at the kick plays or touches the ball → offside offence, indirect free kick where he touched it.', 'assistant', 'wired', 2),
  (3,  11, 'offside-involved-interfering', 'Involved: interfering with an opponent / gaining an advantage',
   'A man in an offside position blocks a defender''s line of sight, challenges him, or plays a rebound → offence.', 'assistant', 'teaching', 3),
  (4,  9,  'ball-out-of-play', 'Ball out of play',
   'The whole ball over the whole goal line or touchline → out; restart to the team that didn''t touch it last. The World decides it exactly for now.', 'world', 'wired', 4),
  (5,  12, 'foul-careless-reckless-excessive', 'Careless, reckless, excessive force',
   'A challenge on an opponent → careless: free kick; reckless: caution; excessive force: sending-off.', 'referee', 'teaching', 5),
  (6,  12, 'handball', 'Handball',
   'Ball touches a hand or arm → deliberate, or the arm making the body unnaturally bigger: offence.', 'referee', 'teaching', 6),
  (7,  5,  'advantage', 'Play on: advantage',
   'An offence, but the team offended against keeps a real attacking chance → play on; penalise if it doesn''t come within a few seconds.', 'referee', 'teaching', 7),
  (8,  14, 'penalty-offence', 'Penalty-area offence',
   'A direct free-kick offence by a defender inside his own penalty area → penalty kick.', 'referee', 'teaching', 8),
  (9,  12, 'caution-sending-off', 'Caution or sending-off',
   'Reckless challenge, persistent offences, dissent, stopping a promising attack → yellow; serious foul play, denying an obvious goal-scoring opportunity → red.', 'referee', 'teaching', 9)
ON CONFLICT (id) DO NOTHING;

INSERT INTO game_ref_perceptions (id, code, title, how, status) VALUES
  (1, 'kick-moment-and-line', 'The kick and the line at once',
   'He must register the moment the ball is played AND where the attacker and the second-last defender are at that moment. A moving attacker is seen ahead of where he is at the flash of the kick (flash-lag) — most errors are flags.', 'wired'),
  (2, 'line-from-his-angle', 'Level, from his angle',
   'He judges "level" along his own line of sight. Standing level with the line he sees it true; standing beyond it, an attacker farther across the pitch than the defender projects ahead of him (wrong flag), nearer him behind (missed offside).', 'wired'),
  (3, 'contact-point', 'The contact',
   'Who touched whom first, where, and with what force.', 'teaching'),
  (4, 'whole-ball-over-line', 'Whole ball over the whole line',
   'Looking along the line, not across it.', 'teaching')
ON CONFLICT (id) DO NOTHING;

INSERT INTO game_ref_judgement_perceptions (judgement_id, perception_id) VALUES
  (1, 1), (1, 2), (2, 1), (3, 2), (4, 4), (5, 3), (6, 3), (8, 3)
ON CONFLICT DO NOTHING;

INSERT INTO game_ref_positionings (id, code, role, title, how, status) VALUES
  (1, 'ar-second-last-defender', 'assistant', 'In line with the second-last defender',
   'On his touchline, facing the field, level with the second-last defender of the team defending his half — or with the ball if it is nearer the goal line; at halfway when the line is in the other half.', 'wired'),
  (2, 'ar-side-steps', 'assistant', 'Side-steps along the line',
   'Short adjustments sideways, facing the field: the better line of vision for offside.', 'teaching'),
  (3, 'referee-wide-diagonal', 'referee', 'The wide diagonal',
   'On the diagonal away from the assistant in that half, close enough to the play, keeping the lead assistant in his field of vision.', 'wired'),
  (4, 'referee-angle-to-play', 'referee', 'Angle to the play',
   'Where he can see between the players at the challenge, not through them.', 'teaching')
ON CONFLICT (id) DO NOTHING;

INSERT INTO game_ref_law_sources (law_id, source_id, citation)
SELECT l.id, s.id, 'IFAB Laws of the Game 2025/26, Law ' || l.number FROM game_ref_laws l, game_sources s WHERE s.code = 'ifab-lotg'
ON CONFLICT DO NOTHING;

INSERT INTO game_ref_judgement_sources (judgement_id, source_id, citation, verified)
SELECT j.id, s.id, x.citation, x.verified
FROM (VALUES
  ('offside-position',          'ifab-lotg',   'Law 11.1 offside position; level is onside', true),
  ('offside-position',          'helsen-2006', '2002 World Cup: 337 offside decisions, ~26% wrong', true),
  ('offside-involved-playing',  'ifab-lotg',   'Law 11.2: penalised only on becoming involved in active play', true),
  ('offside-involved-interfering', 'ifab-lotg', 'Law 11.2 interfering with play / an opponent, gaining an advantage', true),
  ('ball-out-of-play',          'ifab-lotg',   'Law 9.1', true),
  ('foul-careless-reckless-excessive', 'ifab-lotg', 'Law 12.1', true),
  ('handball',                  'ifab-lotg',   'Law 12.1 handling the ball', true),
  ('advantage',                 'ifab-lotg',   'Law 5.3 advantage', true),
  ('penalty-offence',           'ifab-lotg',   'Law 14', true),
  ('caution-sending-off',       'ifab-lotg',   'Law 12.3', true)
) AS x(code, source, citation, verified)
JOIN game_ref_judgements j ON j.code = x.code JOIN game_sources s ON s.code = x.source
ON CONFLICT DO NOTHING;

INSERT INTO game_ref_perception_sources (perception_id, source_id, citation, verified)
SELECT p.id, s.id, x.citation, x.verified
FROM (VALUES
  ('kick-moment-and-line', 'helsen-2006',   'Errors mostly flags (86.6%), concentrated early in matches: the perceptual flash-lag account', true),
  ('line-from-his-angle',  'oudejans-2000', 'Errors from the viewing angle: ARs frequently positioned beyond the last defender (179 of 200 situations, 40 errors)', true)
) AS x(code, source, citation, verified)
JOIN game_ref_perceptions p ON p.code = x.code JOIN game_sources s ON s.code = x.source
ON CONFLICT DO NOTHING;

INSERT INTO game_ref_positioning_sources (positioning_id, source_id, citation, verified)
SELECT p.id, s.id, x.citation, x.verified
FROM (VALUES
  ('ar-second-last-defender', 'ifab-guidelines', 'In line with the second-last defender or the ball if nearer the goal line; always facing the field', true),
  ('ar-second-last-defender', 'oudejans-2000',   'ARs frequently positioned beyond the last defender', true),
  ('ar-side-steps',           'ifab-guidelines', 'Side-to-side movement for short distances: a better line of vision for offside', true),
  ('referee-wide-diagonal',   'ifab-guidelines', 'The lead AR should be in the referee''s field of vision: usually a wide diagonal', true)
) AS x(code, source, citation, verified)
JOIN game_ref_positionings p ON p.code = x.code JOIN game_sources s ON s.code = x.source
ON CONFLICT DO NOTHING;

INSERT INTO game_ref_attributes (code, name, description, scales, status, sort_order) VALUES
  ('pace',              'Pace',              'Top running speed (the player pace scale).', 'top speed, as a player''s pace', 'wired', 1),
  ('acceleration',      'Acceleration',      'Getting up to speed (the player scale).', 'sprint τ, as a player''s acceleration', 'wired', 2),
  ('positioning',       'Positioning',       'How close to level with the line he settles (an assistant), how well he holds the diagonal.', 'assistant slack beyond the line: 2.5 m at 0 … 1.2 at 50 … 0.3 at 100 [FH]', 'wired', 3),
  ('offside_judgement', 'Offside judgement', 'How sharply he reads level at the kick.', 'perception noise on the gap: ±1.0 m at 0 … ±0.5 at 50 … ±0.2 at 100 [FH]', 'wired', 4),
  ('foul_recognition',  'Foul recognition',  'Seeing the contact for what it is.', '0-100; not yet played', 'teaching', 5),
  ('game_management',   'Game management',   'Advantage, temperature, the players.', '0-100; not yet played', 'teaching', 6)
ON CONFLICT (code) DO NOTHING;

INSERT INTO game_official_crews (code, name, level) VALUES
  ('semipro-crew', 'Semi-pro crew', 'semipro'),
  ('pro-crew',     'Pro crew',      'pro')
ON CONFLICT (code) DO NOTHING;

INSERT INTO game_officials (crew_id, role, name)
SELECT c.id, r.role, c.name || ' ' || r.label
FROM game_official_crews c,
     (VALUES ('referee', 'referee'), ('assistant_1', 'assistant 1'), ('assistant_2', 'assistant 2')) AS r(role, label)
ON CONFLICT (crew_id, role) DO NOTHING;

-- [FH] estimates: a semi-pro crew rated ~50 (the band's middle), a pro crew
-- ~75; referees a step fitter than their assistants.
INSERT INTO game_official_ratings (official_id, attribute, rating)
SELECT o.id, a.attribute,
       CASE WHEN c.level = 'pro' THEN a.pro ELSE a.semi END
         + CASE WHEN o.role = 'referee' AND a.attribute IN ('pace', 'acceleration') THEN 5 ELSE 0 END
FROM game_officials o JOIN game_official_crews c ON c.id = o.crew_id,
     (VALUES ('pace', 45, 60), ('acceleration', 45, 60), ('positioning', 50, 75), ('offside_judgement', 50, 75))
       AS a(attribute, semi, pro)
ON CONFLICT DO NOTHING;

-- The numbers (owner 'official').
ALTER TABLE game_model_params DROP CONSTRAINT IF EXISTS game_model_params_owner_check;
ALTER TABLE game_model_params ADD CONSTRAINT game_model_params_owner_check
    CHECK (owner = ANY (ARRAY['skill', 'concept', 'technique', 'physics', 'sheet', 'official']));

INSERT INTO game_model_params (owner, code, param, value, unit, note) VALUES
  ('official', 'assistant', 'flash_lag_s',     0.08, 's', 'A moving player is seen this far ahead along his run at the flash of the kick. [FH] estimate of the magnitude; the direction (more wrong flags) is Helsen et al. 2006.'),
  ('official', 'assistant', 'noise_m_at0',     1.0,  'm', 'Perception noise on the attacker-to-line gap at offside_judgement 0 (uniform ±). [FH] estimate.'),
  ('official', 'assistant', 'noise_m_at50',    0.5,  'm', 'At 50.'),
  ('official', 'assistant', 'noise_m_at100',   0.2,  'm', 'At 100.'),
  ('official', 'assistant', 'slack_m_at0',     2.5,  'm', 'How far beyond the line (toward the goal line) he settles at positioning 0 — ARs mostly stand beyond the last defender (Oudejans et al. 2000). [FH] estimate.'),
  ('official', 'assistant', 'slack_m_at50',    1.2,  'm', 'At 50.'),
  ('official', 'assistant', 'slack_m_at100',   0.3,  'm', 'At 100.'),
  ('official', 'assistant', 'touchline_off_m', 1.0,  'm', 'He runs this far outside his touchline.'),
  ('official', 'referee',   'diagonal_y_share', 0.6, '',  'On the wide diagonal: his y = −share × half-width × (ball x / half-length), from the corner away from each half''s assistant. [FH]'),
  ('official', 'referee',   'ball_pull',       0.5,  '',  'Then pulled this share of the way toward the ball''s y. [FH]'),
  ('official', 'referee',   'behind_m',        8.0,  'm', 'He stands this far behind the ball, toward the goal the attack comes from. [FH]')
ON CONFLICT DO NOTHING;

-- The pro reference gets offsides (game/scripts/benchmarks_statsbomb.py
-- counts Offside events + passes whose outcome is Pass Offside); the value
-- lands when the script is rerun on the PL 2015/16 events.
INSERT INTO game_benchmark_metrics (code, label, unit, definition) VALUES
  ('offsides_per_team_match', 'Offsides called a team a match', 'offsides',
   'StatsBomb: Offside events + passes with outcome Pass Offside. The game: offside whistles (the assistant''s call, G4.88).')
ON CONFLICT (code) DO NOTHING;
