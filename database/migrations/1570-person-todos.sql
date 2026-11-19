-- 1570 (2026-11-19) — ✅ To do on every screen.
-- Owner: "i need a todo all my screens lol. so its like a reminer every time
-- i oepn app lol".  First item: tomorrow morning's #leads BCC touch 1.
--
-- One personal list per person.  An item with remind_at shows from then on
-- (NULL = now); while any item is due, the 🚦 band carries a red
-- "✅ To do — …  Open ›" box naming them.  The popup lists every open item
-- (✓ done, ✕ remove) plus the add form; ☰ "✅ To do" opens it for staff
-- even when nothing is due.  Done items stay 7 days for ↩ undo.
CREATE TABLE IF NOT EXISTS person_todos (
    id          BIGSERIAL PRIMARY KEY,
    person_id   INTEGER NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    body        TEXT NOT NULL CHECK (length(btrim(body)) > 0),
    remind_at   TIMESTAMPTZ,
    done_at     TIMESTAMPTZ,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS person_todos_open ON person_todos (person_id) WHERE done_at IS NULL;

-- The band box: an action (red), after onboarding.
INSERT INTO status_items (code, severity, window_hours, sort_order, is_active)
SELECT 'todo', 'action', NULL, 7, true
 WHERE NOT EXISTS (SELECT 1 FROM status_items WHERE code = 'todo');

INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side)
SELECT 'Event Center', v.label, 'event_center', v.tier, v.body, 1000 + v.n, true
  FROM (VALUES
    (1,  'Band: to-do box ({n} due, {list} = their words)',       'seg_todo',          '✅ To do — {list}'),
    (2,  'Band: to-do box button',                                 'act_todo',          'Open ›'),
    (3,  'To-do popup title',                                      'sheet_todo',        '✅ To do'),
    (4,  '☰ menu: open the to-do list',                            'qlink_todo',        '✅ To do'),
    (5,  'To-do: add box placeholder',                             'todo_placeholder',  'Remind me to…'),
    (6,  'To-do: "when" picker — now',                             'todo_when_now',     'Now'),
    (7,  'To-do: "when" picker — tomorrow morning',                'todo_when_morning', 'Tomorrow 9 AM'),
    (8,  'To-do: "when" picker — pick a date/time',                'todo_when_pick',    'Pick a time…'),
    (9,  'To-do: add button',                                      'todo_add',          '➕ Add'),
    (10, 'To-do: heading over due items',                          'todo_due',          'Due now'),
    (11, 'To-do: heading over later items',                        'todo_later',        'Later'),
    (12, 'To-do: later item shows from ({when})',                  'todo_from',         'shows {when}'),
    (13, 'To-do: heading over done items (last 7 days)',           'todo_done',         'Done'),
    (14, 'To-do: mark done button',                                'todo_check',        '✓ Done'),
    (15, 'To-do: undo done button',                                'todo_undo',         '↩ Undo'),
    (16, 'To-do: empty list',                                      'todo_empty',        'Nothing to do. Add a reminder above — it shows on every screen until you tick it.')
  ) AS v(n, label, tier, body)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = v.tier);

-- The owner's first one: tomorrow 9 AM Eastern.
INSERT INTO person_todos (person_id, body, remind_at)
SELECT 1, 'Email leads: ✉️ BCC touch 1 — Men''s, Women''s, Youth (Marketing → Leads)', '2026-11-20 09:00:00 America/New_York'
 WHERE NOT EXISTS (SELECT 1 FROM person_todos WHERE person_id = 1 AND body LIKE 'Email leads: ✉️ BCC touch 1%');
