-- 1903 (2026-11-25) — ✅ To do lists for every player, given by staff.
-- Owner: "we need indivdual todo lists for all players. for example it might
-- be for our hight school kids did you apply for financial aid. college
-- applications. for some it might reminders to stretch every day."
--
-- Same person_todos list as mig 1570 (the 🚦 band's red "✅ To do" box on
-- every screen), now also written by club admins and the player's coaches
-- from the player sheet's new ✅ To do tab:
--   assigned_by_person_id  who gave it (NULL = the person's own reminder).
--                          The player ticks it; only staff remove it.
--   repeat 'daily'         comes back every day: done = ticked today (club
--                          time); never ages off the list.
--   due_on                 optional deadline, shown on the item.
--   batch_id               one "give to the whole team" add = one batch, so
--                          staff can take it back from everyone at once.
ALTER TABLE person_todos
    ADD COLUMN IF NOT EXISTS assigned_by_person_id INTEGER REFERENCES persons(id) ON DELETE SET NULL,
    ADD COLUMN IF NOT EXISTS repeat  TEXT CHECK (repeat IN ('daily')),
    ADD COLUMN IF NOT EXISTS due_on  DATE,
    ADD COLUMN IF NOT EXISTS batch_id BIGINT;
CREATE INDEX IF NOT EXISTS person_todos_person ON person_todos (person_id);
CREATE INDEX IF NOT EXISTS person_todos_batch ON person_todos (batch_id) WHERE batch_id IS NOT NULL;

-- Sheet tab + staff form words (player_sheet), item notes on the player's
-- own list (event_center, next to mig 1570's todo_* rows).
INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side)
SELECT 'Player sheet', v.label, 'player_sheet', v.tier, v.body, 120 + v.n, true
  FROM (VALUES
    (1,  'Tab: to-do list',                                          'tab_todo',            '✅ To do'),
    (2,  'To-do tab: add box placeholder',                           'todo_placeholder',    'e.g. Apply for financial aid'),
    (3,  'To-do tab: repeat picker — once',                          'todo_once',           'Once'),
    (4,  'To-do tab: repeat picker — every day',                     'todo_daily',          'Every day'),
    (5,  'To-do tab: deadline field label',                          'todo_due_label',      'By (optional)'),
    (6,  'To-do tab: who gets it — this player ({name})',            'todo_to_one',         'Just {name}'),
    (7,  'To-do tab: who gets it — everyone on a team ({team}, {n})', 'todo_to_team',       'Everyone on {team} ({n})'),
    (8,  'To-do tab: add button',                                    'todo_add',            '➕ Give'),
    (9,  'To-do tab: remove button',                                 'todo_remove',         '✕ Remove'),
    (10, 'To-do tab: remove from the whole batch ({n} players)',     'todo_remove_all',     '✕ Remove from all {n}'),
    (11, 'To-do tab: item status — open',                            'todo_state_open',     'Not done'),
    (12, 'To-do tab: item status — done ({when})',                   'todo_state_done',     '✓ Done {when}'),
    (13, 'To-do tab: daily item — ticked today',                     'todo_state_today',    '✓ Done today'),
    (14, 'To-do tab: daily item — last ticked ({when})',             'todo_state_last',     'Last done {when}'),
    (15, 'To-do tab: daily item — never ticked',                     'todo_state_never',    'Not ticked yet'),
    (16, 'To-do tab: given by ({name})',                             'todo_from',           'from {name}'),
    (17, 'To-do tab: the player''s own reminders heading',           'todo_own',            'Their own reminders'),
    (18, 'To-do tab: empty list',                                    'empty_todo',          'Nothing on their list. Give them something above — it shows at the top of every screen until they tick it.'),
    (19, 'To-do tab: saved toast ({n} players)',                     'todo_saved',          'Given to {n}.'),
    (20, 'To-do tab: not staff for this player',                     'todo_no_access',      'Only club admins and this player''s coaches can give them to-dos.'),
    (21, 'To-do tab: item deadline ({when})',                        'todo_by',             'by {when}'),
    (22, 'To-do tab: "Just …" when the player has no first name',    'todo_this_player',    'this player')
  ) AS v(n, label, tier, body)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'player_sheet' AND m.tier = v.tier);

INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side)
SELECT 'Event Center', v.label, 'event_center', v.tier, v.body, 1020 + v.n, true
  FROM (VALUES
    (1, 'To-do: item given by staff ({name})',  'todo_given_by', 'from {name}'),
    (2, 'To-do: repeats every day',             'todo_every_day', '🔁 every day'),
    (3, 'To-do: deadline ({when})',             'todo_by',        'by {when}')
  ) AS v(n, label, tier, body)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = v.tier);
