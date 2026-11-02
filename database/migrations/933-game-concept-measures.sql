-- Mig 933 (G5.4, game/DESIGN.md §8.102): every concept tied to the data that
-- can test it. James 11/2: "we can take existing concepts and find out where
-- they are related to the data". First pass from each concept's cue: it says
-- where to look, not what was found. tier: events = StatsBomb 2015/16 events,
-- tracking = DFL / SkillCorner positions, none = no free data can see it.
CREATE TABLE IF NOT EXISTS game_measures (
    code  TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    tier  TEXT NOT NULL CHECK (tier IN ('events', 'tracking', 'none'))
);
CREATE TABLE IF NOT EXISTS game_concept_measures (
    concept TEXT PRIMARY KEY REFERENCES game_concepts(name) ON UPDATE CASCADE ON DELETE CASCADE,
    measure TEXT NOT NULL REFERENCES game_measures(code)
);
INSERT INTO game_measures (code, title, tier) VALUES
 ('shot_choice',  'Shoot or not by spot and pressure; where shots go', 'events'),
 ('pass_choice',  'Pass length, direction and risk by spot and pressure', 'events'),
 ('combination',  'Pass chains: return passes, third man, cut-backs', 'events'),
 ('carry',        'Carries and dribbles by spot; shielding', 'events'),
 ('receive',      'What follows a receipt: touch, turn, first time', 'events'),
 ('tempo',        'Time on the ball and ball speed', 'events'),
 ('build_up',     'Goal kicks and first passes from the back', 'events'),
 ('restart',      'Corners, throw-ins and free kicks', 'events'),
 ('cross',        'Crosses, where they land, who deals with them', 'events'),
 ('transition',   'The seconds after the ball changes hands', 'events'),
 ('press',        'Pressure events by spot, target and sequence', 'events'),
 ('duel',         'Tackles, interceptions, blocks, clearances', 'events'),
 ('keeper',       'Keeper actions and his spot in shot freeze frames', 'events'),
 ('offside',      'Offside calls and where the line was beaten', 'events'),
 ('team_shape',   'Line height, length, width and distances', 'tracking'),
 ('off_ball',     'Runs and marking away from the ball', 'tracking'),
 ('unseen',       'Talk, scanning and body shape', 'none')
ON CONFLICT (code) DO UPDATE SET title = EXCLUDED.title, tier = EXCLUDED.tier;
INSERT INTO game_concept_measures (concept, measure)
SELECT c, m FROM (VALUES
 ('shot_choice', ARRAY['shot-selection','placement','inside-forward']),
 ('pass_choice', ARRAY['pass-ladder','short-simple','safe-pass','verticality','risk-by-third','direct-ball','beat-the-high-line','over-top','switch-play','overload-to-isolate','target-and-runner']),
 ('combination', ARRAY['give-and-go','wall-pass','third-man','lay-off','cut-back','overlap','underlap','false-nine-drop','nine-drops-to-link','ten-arrives']),
 ('carry',       ARRAY['beat-man-1v1','drive-into-space','fix-and-release','cb-step-in','change-of-pace','shield-ball','keep-it-under-pressure']),
 ('receive',     ARRAY['first-touch-direction','half-turn-receive','open-closed-ball','meet-the-pass']),
 ('tempo',       ARRAY['ball-speed','tempo-control','settle-in-possession','pausa','release-timing']),
 ('build_up',    ARRAY['play-out-back','keeper-extra-player','bait-the-press','pivot-drop','cb-split']),
 ('restart',     ARRAY['quick-restart','throw-in-retain','long-throw','corner-blockers','keeper-screen','corner-ring','second-phase-corner','press-their-throw']),
 ('cross',       ARRAY['cross-zone-runs','box-occupancy','defend-the-cross','deny-the-cross','command-box','penalty-spot-guard']),
 ('transition',  ARRAY['counter-attack','counter-or-keep','regain-strike','regain-spread','escape-and-advance','counter-into-fullback-space','second-ball','distribute-quickly','react-to-rebound','counter-press','drop-on-loss','delay','recover','tactical-foul','loose-pass-trap','press-the-bad-touch','anticipate-regain','nearest-decides','zero-pause-switch','find-your-man','screen-transition','chain-recover','defend-outnumbered']),
 ('press',       ARRAY['press-as-unit','engage-line','block-height','touchline-trap','press-the-full-back','lateral-pass-trigger','nine-starts-press','hurry-the-keeper','press-through','press-backward','central-trap','close-the-centre','double-team','lock-the-side','press-minus-one','backpass-step-up','back-to-goal-trap','far-winger-jump','winger-press-angle','open-lane-bait','press-the-rebalance']),
 ('duel',        ARRAY['tackle-timing','engage-or-contain','win-duel','restraint','intercept','jump-the-pass','block-shot-line','clear-the-danger','step-out']),
 ('keeper',      ARRAY['sweep','narrow-angle']),
 ('offside',     ARRAY['offside-trap','stay-onside','blind-side-run','runs']),
 ('unseen',      ARRAY['call-man-on','call-time','call-turn','call-adjust-shadow','call-line','call-squeeze','scan-before-receive','scan-defending','face-the-play','drop-step','side-on-jockey','jockey-angle','body-feint-pass','blind-side-press','play-off-long-ball'])
) AS t(m, cs), unnest(cs) AS c
ON CONFLICT (concept) DO UPDATE SET measure = EXCLUDED.measure;
-- The rest are off the ball or team shape.
INSERT INTO game_concept_measures (concept, measure)
SELECT name, CASE WHEN family = 'team' THEN 'team_shape' ELSE 'off_ball' END FROM game_concepts
ON CONFLICT (concept) DO NOTHING;
