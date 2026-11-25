-- 1912 (2026-11-25): the concept viewer shows THE concept on the pitch — first, stay in pressing distance.
-- Owner 11/25: "i still don't see what we are getting out of the viewer in regards to 'stay in pressing distance'
-- just seems like its lost in shuffle lol and not highliged". The followed man's reach circle (green: his man inside
-- it; red: outside), a line to his man with the metres, a banner IN / OUT on top, and the scrub bar coloured with
-- every moment he was in reach (green) or out (red). The banner's words:
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Football', 'Concept viewer — ' || v.l, 'taxonomy', v.t, NULL, v.b, v.o, true, true
  FROM (VALUES
    ('pressing distance: in ({num},{man},{gap},{reach})', 'focus_pd_in', '✓ IN PRESSING DISTANCE — #{num} on #{man}: {gap} m away, he can reach {reach} m', 480),
    ('pressing distance: out ({num},{man},{gap},{reach},{short})', 'focus_pd_out', '✗ OUT OF PRESSING DISTANCE — #{num} on #{man}: {gap} m away, he can reach {reach} m ({short} m too far)', 481),
    ('pressing distance: stepping', 'focus_pd_stepping', '— stepping in', 482),
    ('pressing distance: off, our ball ({num})', 'focus_pd_off_ours', '#{num}: not in it now — he reads that we have the ball', 483),
    ('pressing distance: off, pressing ({num})', 'focus_pd_off_press', '#{num}: not in it now — he is the man pressing the ball', 484),
    ('pressing distance: off, loose ball ({num})', 'focus_pd_off_chase', '#{num}: not in it now — he is going for the loose ball', 485),
    ('pressing distance: off, keeper ({num})', 'focus_pd_off_keeper', '#{num}: not in it — he is the keeper', 486),
    ('pressing distance: off, no man ({num})', 'focus_pd_off_none', '#{num}: not in it now — no man to mind', 487),
    ('pressing distance: tally ({num},{pin},{pout})', 'focus_pd_tally', 'This recording, #{num} while in it: in reach {pin}% · out of reach {pout}% (the bar below: green in, red out)', 488)
  ) AS v(l, t, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'taxonomy' AND m.tier = v.t);

-- The scrub bar's spells (owner 11/25: "highlight with color at what from and till timestamps the 'stay in press..' is
-- ON. dont show others … or allow them to be toggled" · "button to 'play only main concept' not leading up or after").
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Football', 'Concept viewer — ' || v.l, 'taxonomy', v.t, NULL, v.b, v.o, true, true
  FROM (VALUES
    ('lanes: this concept (tap for all)', 'strip_main', 'This concept', 490),
    ('lanes: all concepts (tap for this one)', 'strip_all', 'All concepts', 491),
    ('play only the concept', 'strip_only', '▶ Only this concept', 492),
    ('playing only the concept', 'strip_only_on', '■ Only this concept', 493)
  ) AS v(l, t, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'taxonomy' AND m.tier = v.t);
