-- Migration 2215: ✅ To do — one category per band box.
-- Owner 11/27: "todo boxes should only have 1 category. so min pitch needs to
-- be sep box from ppr u12". todo_categories = what a to-do is about; the 🚦
-- band draws one "✅ <category> — …" box per category with anything due
-- (items with no category share the plain "✅ To do" box). Tapping a box
-- opens the list on that category only; an item added there joins it.
BEGIN;
CREATE TABLE todo_categories (
    id         serial PRIMARY KEY,
    name       text NOT NULL UNIQUE CHECK (length(btrim(name)) > 0),
    icon       text,
    sort_order integer NOT NULL DEFAULT 0,
    created_at timestamptz NOT NULL DEFAULT now()
);
ALTER TABLE person_todos ADD COLUMN category_id integer REFERENCES todo_categories(id) ON DELETE SET NULL;

INSERT INTO todo_categories (name, icon, sort_order) VALUES
    ('Mini Pitch proposal',  '🏟', 10),
    ('PPR Indoor 2027 U12',  '📝', 20);

UPDATE person_todos SET category_id = (SELECT id FROM todo_categories WHERE name = 'Mini Pitch proposal')
 WHERE person_id = 1 AND body LIKE 'Mini Pitch proposal%';
UPDATE person_todos SET category_id = (SELECT id FROM todo_categories WHERE name = 'PPR Indoor 2027 U12')
 WHERE person_id = 1 AND body LIKE 'PPR Indoor 2027 U12%';

INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side)
SELECT 'Event Center', v.label, 'event_center', v.tier, v.body, v.sort_order, true
  FROM (VALUES
    ('Band: to-do box for one category ({cat} = icon + name, {list} = its items)', 'seg_todo_cat', '✅ {cat} — {list}', 1004),
    ('To-do popup: show every category',                                          'todo_all_cats', '← All to-dos',     1005)
  ) AS v(label, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'event_center' AND t.tier = v.tier AND t.is_active);
-- The box already names the category: the items say only what to do.
UPDATE person_todos SET body = 'Finish it and send it'
 WHERE person_id = 1 AND body = 'Mini Pitch proposal — finish it and send it';
UPDATE person_todos SET body = 'On #league-registration: club commitment form, U12 team commitment form, U12 official roster, check to the City of Philadelphia, then email it to the league'
 WHERE person_id = 1 AND body LIKE 'PPR Indoor 2027 U12 — finish the registration%';
COMMIT;
