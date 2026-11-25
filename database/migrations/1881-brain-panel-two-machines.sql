-- 1881 (2026-11-25): the 🧠 panel says plainly there are TWO state machines.
--
-- Owner: "the state names are cut off. and the names of the state machines are cut off. is
-- it 5 state machines? because there are 5 rows." No: two state machines (the team's phase,
-- his own state); the third row is what he uses inside his state; the last rows are reads.
-- The rows are now grouped under those headings, each name on its own line, and each row's
-- states written out in full under its bar.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Football', 'Concept clip viewer — brain panel: ' || v.l, 'taxonomy', v.t, NULL, v.b, v.o, true, true
  FROM (VALUES
    ('group: the machines', 'brain_group_machines', '2 state machines — each is in exactly ONE state at any moment', 360),
    ('machine 1 ({n})', 'brain_machine_team', 'Machine 1 · TEAM — {n} states (the whole team shares it)', 361),
    ('machine 2 ({n})', 'brain_machine_him', 'Machine 2 · HIM — {n} states (his own job)', 362),
    ('group: inside his state', 'brain_group_using', 'Not a machine — what he uses inside his state', 363),
    ('row: using', 'brain_lane_using_full', 'USING — a concept, or nothing', 364),
    ('group: reads', 'brain_group_reads', 'Not machines — reads, always running (they decide nothing)', 365),
    ('empty row', 'brain_lane_empty', '— nothing in this example', 366)
  ) AS v(l, t, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'taxonomy' AND m.tier = v.t);
UPDATE message_templates SET body = 'TEAM — machine 1: what the whole team is doing. One phase at a time, the same for all eleven (we have it / they have it / just lost it …).'
 WHERE kind = 'taxonomy' AND tier = 'brain_howto_team';
UPDATE message_templates SET body = 'HIM — machine 2: his own job. One state at a time — he can never be in two states of the same machine. Two machines, so he is always in one team phase AND one state of his own.'
 WHERE kind = 'taxonomy' AND tier = 'brain_howto_him';
UPDATE message_templates SET body = 'USING — not a machine: inside his state, the concept he is applying. It changes HOW he does the state (e.g. while holding his place, he steps toward his man to stay in pressing distance). Often nothing.'
 WHERE kind = 'taxonomy' AND tier = 'brain_howto_using';
UPDATE message_templates SET body = 'KNOWS — not machines: what he reads all the time — who his man is, can he reach him, who is hidden behind him. Reading something does not make him do it.'
 WHERE kind = 'taxonomy' AND tier = 'brain_howto_knows';

-- Owner 11/25: "how are we getting the proper behaviour with 1 player state machine lol. i would
-- think we need one just for player actions". The action he does this instant is a third layer
-- in the engine already, but it is picked fresh every tick by his state — no memory — so the
-- panel shows it as its own row, labelled as not (yet) a machine.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Football', 'Concept clip viewer — brain panel: ' || v.l, 'taxonomy', v.t, NULL, v.b, v.o, true, true
  FROM (VALUES
    ('group: the action', 'brain_group_action', 'Not a machine yet — his action this instant, picked fresh by his state every moment (no memory)', 367),
    ('row: action ({n})', 'brain_lane_action', 'ACTION — {n} actions (pass, shoot, dribble, press, hold …)', 368)
  ) AS v(l, t, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'taxonomy' AND m.tier = v.t);
