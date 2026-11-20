-- 1602 (2026-11-20) — 👋 Welcome box: ✓ Done (one) / ✓ Done all, no message.
-- Owner: "i need to be able to tell the welcome reminder warning at top
-- "done all" or done each one indivicually".
--
-- A welcome_dismissals row = the admin handled this player's welcome some
-- other way; WelcomeLog::dueList skips them like a sent person_welcomes
-- row.  Only the band's list reads it — the roster cards' WELCOME button
-- stays as it was (still re-sendable).  Undo = delete the row.
CREATE TABLE IF NOT EXISTS welcome_dismissals (
    person_id          INTEGER PRIMARY KEY REFERENCES persons(id) ON DELETE CASCADE,
    dismissed_by_user  INTEGER REFERENCES users(id) ON DELETE SET NULL,
    dismissed_at       TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side)
SELECT 'Event Center', v.label, 'event_center', v.tier, v.body, 1110 + v.n, true
  FROM (VALUES
    (1, 'New registrations popup: mark one done without sending', 'welcome_done',     '✓ Done'),
    (2, 'New registrations popup: mark everyone done',            'welcome_done_all', '✓ Done all ({n})'),
    (3, 'New registrations popup: intro adds the Done buttons',   'welcome_intro',    'Tap a name — their contact opens with the welcome ready. ✓ Done takes someone off without sending.')
  ) AS v(n, label, tier, body)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = v.tier);

UPDATE message_templates
   SET body = 'Tap a name — their contact opens with the welcome ready. ✓ Done takes someone off without sending.'
 WHERE kind = 'event_center' AND tier = 'welcome_intro';
