-- 1882 (2026-11-25): the 🧠 panel shows only the machines that are AWAKE.
--
-- Owner 11/25, agreeing the design — one machine per concept, asleep ("nothing to do") until
-- its trigger, several awake at once, complementing or fighting, a resolver deciding: "ok yes
-- like it. but for display on screen i think if state is 'off' i would not display it as that
-- is like too many things lol. maybe display the ones that are on?"
--
-- The panel's core is his team's phase, his job state and his action; under them, only the
-- machines awake right now, in priority order (machine_order — the order they win in when they
-- fight; proposed 11/25, the owner's to change). In the timeline a machine gets a row only if it
-- woke up in that example. Until the engine runs them as real machines they are read from what
-- it already sends (job state, the act's concept, the shadow).
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Football', 'Concept clip viewer — awake machines: ' || v.l, 'taxonomy', v.t, NULL, v.b, v.o, true, true
  FROM (VALUES
    ('priority order when machines fight (keys, comma-separated — first wins)', 'machine_order', 'recover,press,chase,double,mark,shadow,cover,pdist', 370),
    ('right-now label: awake', 'brain_lane_awake', 'Awake', 371),
    ('right-now label: action', 'brain_lane_action_short', 'Action', 372),
    ('none awake', 'm_none', '— none: he just holds his place', 373),
    ('none awake in the example', 'm_none_example', 'No machine woke up in this example — he held his place throughout.', 374),
    ('wins tag', 'm_wins', '← wins if they fight', 375),
    ('group heading', 'brain_group_awake', 'Machines that woke up in this example (asleep = not shown)', 376),
    ('machine: recover', 'm_recover', 'Recover', 377),
    ('recover awake', 'm_recover_on', 'line broken — getting back goal-side', 378),
    ('machine: press', 'm_press', 'Press', 379),
    ('press awake ({man})', 'm_press_on', 'closing down {man}', 380),
    ('machine: double-team', 'm_double', 'Double-team', 381),
    ('double-team awake ({man})', 'm_double_on', 'second man on {man}', 382),
    ('machine: loose ball', 'm_chase', 'Loose ball', 383),
    ('loose ball awake', 'm_chase_on', 'first to the loose ball', 384),
    ('machine: marking', 'm_mark', 'Marking (zonal)', 385),
    ('marking awake ({man})', 'm_mark_on', 'goal-side of {man} in his zone', 386),
    ('machine: cover shadow', 'm_shadow', 'Cover shadow', 387),
    ('cover shadow awake ({list})', 'm_shadow_on', '{list} hidden behind him', 388),
    ('cover shadow while pressing ({man}, {list})', 'm_shadow_press', 'pressing along the line to {man} — hidden: {list}', 389),
    ('machine: cover', 'm_cover', 'Cover', 390),
    ('cover awake', 'm_cover_on', 'behind the man who presses', 391),
    ('machine: pressing distance', 'm_pdist', 'Pressing distance', 392),
    ('pressing distance awake ({man})', 'm_pdist_on', 'stepping toward {man} to have him in reach', 393)
  ) AS v(l, t, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'taxonomy' AND m.tier = v.t);

-- The how-to box and the caption, for the new layout.
UPDATE message_templates SET body = '#{num} {player}   ·   TEAM: {phase}   ·   HIM: {state}   ·   AWAKE: {using}'
 WHERE kind = 'taxonomy' AND tier = 'cap_layers';
UPDATE message_templates SET body = 'ACTION — what his body does this instant (pass, shoot, press, hold …), picked fresh by his state every moment. AWAKE — the concept machines that have something to do right now; asleep ones are not shown. Several can be awake at once: they work together (the cover shadow bends the press) or fight, and then the first one listed wins.'
 WHERE kind = 'taxonomy' AND tier = 'brain_howto_using';
