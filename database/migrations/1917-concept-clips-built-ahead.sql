-- 1917 (2026-11-25): a concept's clips BUILT ahead of time, played in the concept viewer (?clips=1).
-- Owner 11/25: "would it be better to run the sim and grab the examples ahead of time for each concept since it does
-- not take long. think of it like compiling a c++ program. we can have multiple 'executables' for them to view? we
-- focus now on the 'stay in pressing distance'" · "one concept at a time" · "yes go ahead and we can focus on the
-- 'presentation' of the concept once we have multiple 'exe'".
-- The build: game/src/tools/concept_clips_main.cpp (fh-concept-clips) → frontend/game-clips/<concept>/ (a build
-- output, git-ignored). The words the clip bar uses (its ◀ ▶ titles are the existing clip_prev / clip_next rows):

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Football', 'Concept viewer — ' || v.l, 'taxonomy', v.t, NULL, v.b, v.o, true, true
  FROM (VALUES
    ('clips: none built', 'clip_none', 'No clips are built for this concept yet.', 490),
    ('clips: which ({n}, {total})', 'clip_of', 'Clip {n} of {total}', 491),
    ('clips: done right', 'clip_good', '✓ Done right', 492),
    ('clips: done wrong', 'clip_bad', '✗ Done wrong', 493),
    ('clips: who ({num}, {name}, {label}, {min})', 'clip_who', '#{num} {name} ({label}), {min}''', 494),
    ('clips: outcome won', 'clip_out_won', 'His side won the ball', 495),
    ('clips: outcome held ({gap})', 'clip_out_held', '{gap} m off his man as the pass arrived — he got nowhere', 496),
    ('clips: outcome forward ({gap}, {m})', 'clip_out_forward', '{gap} m off his man as the pass arrived — they went {m} m forward', 497),
    ('clips: outcome goal', 'clip_out_goal', 'They scored', 498)
  ) AS v(l, t, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'taxonomy' AND m.tier = v.t);
