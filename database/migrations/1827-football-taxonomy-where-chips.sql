-- 1827 (2026-11-24): 🧬 Taxonomy of Football — where each concept lives, on its card.
--
-- Owner 11/24: "i need on each concept card wherther icons for if used in game, db, engine" ·
-- "clicking each one takes you to pertiientn info. c++ icon for code right? should take me to
-- code with links to parent and childs" · "db icon should show me talbe and relationships and
-- normalzation".  Three chips, lit or dim: 🗄 DB → the database sheet (table, key, foreign
-- keys, this row, the rows it points to, every table that points at it — read from the
-- Postgres catalogue by GET /api/tactic-plans/taxonomy/db), 🎮 Game → the behaviour the
-- engine plays, ⚙️ C++ → the class sheet (parents, children, source).  Words only.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Football', 'Taxonomy of Football — ' || v.l, 'taxonomy', v.t, NULL, v.b, v.o, true, true
  FROM (VALUES
    ('chip: in the database', 'where_db', '🗄 DB', 140),
    ('chip tip: in the database', 'where_db_tip', 'In the database. Tap for its table, its row and the tables linked to it.', 141),
    ('chip: used in the game', 'where_game', '🎮 Game', 142),
    ('chip tip: used in the game', 'where_game_tip', 'The engine plays this in a match. Tap for what it does.', 143),
    ('chip tip: not used in the game', 'where_game_no', 'Not played in the game yet.', 144),
    ('chip: C++', 'where_code', '⚙️ C++', 145),
    ('chip tip: C++', 'where_code_tip', 'There is C++ for this. Tap for the class, its parents and children, and the source.', 146),
    ('chip tip: no C++', 'where_code_no', 'No C++ for this yet.', 147),
    ('legend line for the chips', 'where_legend', 'On each card: 🗄 in the database · 🎮 played in the game · ⚙️ C++ in the engine. Lit = yes — tap one to go there.', 148),
    ('sheet section: C++ classes', 's_classes', '🧱 C++ classes', 149),
    ('database sheet: title ({title})', 'db_title', '🗄 {title} — in the database', 150),
    ('database sheet: link back to the concept', 'db_to_concept', 'the concept', 151),
    ('database sheet: normalisation ({cols} {out} {tables} {used})', 'db_norm',
     'Normalised: the game_concepts row holds only what is true of the concept itself — {cols} columns, one row per concept, found by its key. Anything that can repeat, or that belongs to something else, lives in its own table and points here by key instead of being copied: {tables} tables point at a concept, {used} of them have rows for this one. The row itself points out to {out} other tables.', 152),
    ('database sheet: key legend', 'db_key_legend', '🔑 primary key · 🔗 foreign key (points to another table) · ◇ unique · ? may be empty', 153),
    ('database sheet section: the table and this row', 'db_s_table', 'The table and this row', 154),
    ('database sheet section: what it points to', 'db_s_out', 'What this row points to', 155),
    ('database sheet section: what points at it', 'db_s_in', 'Tables that point at this row', 156),
    ('database sheet section: related tables with no rows', 'db_s_empty', 'Linked tables with nothing for this concept yet', 157),
    ('database sheet: column heading', 'db_col', 'Column', 158),
    ('database sheet: type heading', 'db_type', 'Type', 159),
    ('database sheet: value heading', 'db_value', 'Value', 160),
    ('database sheet: points-to heading', 'db_ref', 'Points to', 161),
    ('database sheet: row count ({n})', 'db_rows', '{n} rows', 162),
    ('database sheet: more rows ({n})', 'db_more', '+{n} more rows not shown', 163)
  ) AS v(l, t, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'taxonomy' AND m.tier = v.t);
