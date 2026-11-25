-- 1872 (2026-11-24): the clip viewer's 🧠 panel shows the brain's LAYERS.
--
-- Owner 11/24: "confused so the state machine is confusing. is he in 'stay in pressing distance'
-- the whole time … there may be times its not right? we need a way to display the state
-- machines and how many there are. i assume the hold position is a sub state machine or is it
-- at same level? can you be in 2 states of same machine. we need this explained on the
-- graphic" · "it needs to be crystal clear what is going on in the 'brain'" · "and what we are
-- seeing".
--
-- The answer the panel now draws (frontend/js/teach/concept.js paintBrain), one lane each:
--   TEAM    the team's phase — one of 6, one at a time, shared by all eleven (frame PHASE)
--   HIM     his state — one of 10, one at a time; never two states of the same machine
--   USING   inside that state, none or one concept: it changes HOW he does the state, it is
--           not a state ("Stay in pressing distance" lives inside "Hold his place")
--   KNOWS   reads, always running: his man, can he reach him, who is in his shadow
-- plus RIGHT NOW in words and one line: is THIS concept active, and if not, why not.
-- The old "Right now: Hold his position" line (the engine's order of the tick, a third name for
-- nearly the same thing) is gone from the panel.

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Football', 'Concept clip viewer — brain panel: ' || v.l, 'taxonomy', v.t, NULL, v.b, v.o, true, true
  FROM (VALUES
    ('tab', 'brain_tab', '🧠 The brain', 320),
    ('how to read: title', 'brain_howto_title', 'How to read the brain', 321),
    ('how to read: team', 'brain_howto_team', 'TEAM — what the whole team is doing: one phase at a time, the same for all eleven (we have it / they have it / just lost it …).', 322),
    ('how to read: him', 'brain_howto_him', 'HIM — his own job: one state at a time. He can never be in two states at once.', 323),
    ('how to read: using', 'brain_howto_using', 'USING — inside that state, the concept he is applying. It is not a state: it changes HOW he does the state (e.g. while holding his place, he steps toward his man to stay in pressing distance). Often nothing.', 324),
    ('how to read: knows', 'brain_howto_knows', 'KNOWS — what he reads all the time: who his man is, can he reach him, who is hidden behind him. Reading something does not make him do it.', 325),
    ('lane: team', 'brain_lane_team', 'Team', 326),
    ('lane: him', 'brain_lane_him', 'Him', 327),
    ('lane: using', 'brain_lane_using', 'Using', 328),
    ('lane: knows', 'brain_lane_knows', 'Knows', 329),
    ('lane: his man', 'brain_lane_man', 'Knows: his man', 330),
    ('lane: in reach', 'brain_lane_reach', 'Knows: man in reach?', 331),
    ('lane: shadow', 'brain_lane_shadow', 'Knows: hidden behind him', 332),
    ('count ({n})', 'brain_count', '{n} states, 1 at a time', 333),
    ('count for using', 'brain_count_using', '0 or 1 at a time', 334),
    ('lanes heading', 'brain_lanes', 'Through this example (the white line is now)', 335),
    ('lanes note', 'brain_lanes_note', 'Each row is one layer. A row only ever has one thing in it at a time; different rows run at the same time. ⚔ = his man changed because of the battle near the ball.', 336),
    ('all states ({phases}, {states})', 'brain_all', 'Every state there is: team {phases} · him {states}', 337),
    ('nothing', 'brain_nothing', '— nothing extra', 338),
    ('in', 'brain_in', 'IN reach', 339),
    ('out', 'brain_out', 'OUT of reach', 340),
    ('knows his man ({man}, {player}, {how})', 'brain_knows_man', 'his man #{man} {player} ({how})', 341),
    ('knows no man', 'brain_knows_noman', 'no man of his own (the spare man)', 342),
    ('knows reach ({gap}, {reach}, {verdict})', 'brain_knows_reach', '{gap} m from him, can cover {reach} m → {verdict}', 343),
    ('knows shadow ({list})', 'brain_knows_shadow', 'hidden behind him: {list}', 344),
    ('knows no shadow', 'brain_knows_noshadow', 'nobody hidden behind him', 345),
    ('status: on ({concept})', 'brain_status_on', '✅ "{concept}" is ACTIVE now — he is doing it', 346),
    ('status: their ball ({concept})', 'brain_status_ourball', '⏸ "{concept}" is not active — his team has the ball', 347),
    ('status: other state ({concept}, {state}, {host})', 'brain_status_otherstate', '⏸ "{concept}" is not active — he is in "{state}"; it is only used inside "{host}"', 348),
    ('status: in reach ({concept})', 'brain_status_inreach', '⏸ "{concept}" is not needed — his man is already in reach, nothing to correct', 349),
    ('status: nothing to do ({concept})', 'brain_status_nothing', '⏸ "{concept}" is not active right now', 350),
    ('status: a read ({concept})', 'brain_status_read', '👁 "{concept}" is a READ — it runs all the time and moves nobody', 351),
    ('caption line 1 ({num}, {player}, {phase}, {state}, {using})', 'cap_layers', '#{num} {player}   ·   TEAM: {phase}   ·   HIM: {state}   ·   USING: {using}', 352),
    -- Which state a switched-on concept lives in (the engine applies it only there).
    ('the state pressing distance lives in (a game_engine_terms code)', 'dial_state_pressing-distance', 'hold_block', 353),
    ('the state the cover shadow lives in (a game_engine_terms code)', 'dial_state_cover-shadow', 'press_ball', 354)
  ) AS v(l, t, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'taxonomy' AND m.tier = v.t);
