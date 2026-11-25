-- 1918 (2026-11-25): the concept viewer says WHICH build ("exe") is playing.
-- Owner 11/25: "ok needs to be more clear of what exe we are watching". A line at the top: the concept, the engine
-- build, when it was built, from how many matches, how many clips — or LIVE when it is not a build. Tap it: what the
-- build is and its clips, each one tap to watch.

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Football', 'Concept viewer — ' || v.l, 'taxonomy', v.t, NULL, v.b, v.o, true, true
  FROM (VALUES
    ('build line ({concept}, {engine}, {when}, {matches}, {n}, {good}, {bad})', 'build_line',
     '🎬 BUILT CLIPS · {concept} · build {engine} · {when} · from {matches} matches · {n} clips ({good} ✓ {bad} ✗)', 501),
    ('build line, live', 'build_live', '🔴 LIVE MATCH — not a build', 502),
    ('build popup title', 'build_popup_title', 'What you are watching', 503),
    ('build popup ({concept}, {matches}, {fixtures}, {engine}, {when}, {secs}, {pool})', 'build_popup_body',
     'Clips of {concept}, built ahead of time from {matches} whole matches ({fixtures}) by engine build {engine}, on {when} in {secs} s. Of {pool} kept, these are the ones a player is shown. Tap one to watch it.', 504),
    ('build popup, live', 'build_live_def', 'This is a match being played right now, not a build: the clock''s end grows as it plays. The built clips play when the concept has a build.', 505),
    ('build clip row ({num}, {name}, {label}, {min}, {outcome})', 'build_clip_row', '#{num} {name} ({label}), {min}'' — {outcome}', 506)
  ) AS v(l, t, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'taxonomy' AND m.tier = v.t);
