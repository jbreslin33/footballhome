-- 372: Bib colours become rows, not a CHECK list.
--
-- Why: the Event Center's Teams pill (pickup sides) / Groups pill (practice
-- groups) puts players on a colour via match_lineups.squad_color (migration
-- 316). The allowed colours lived in a CHECK constraint, so the screen would
-- have had to repeat the list — with labels and swatches — in JS. A lookup
-- table is the one place for it: the constraint becomes a foreign key, and
-- the screen reads label + hex from the API. Add a colour by migration.

BEGIN;

CREATE TABLE IF NOT EXISTS squad_colors (
    code       varchar(10) PRIMARY KEY,
    label      varchar(30) NOT NULL,
    hex        varchar(7)  NOT NULL CHECK (hex ~ '^#[0-9a-fA-F]{6}$'),
    sort_order integer     NOT NULL DEFAULT 0,
    is_active  boolean     NOT NULL DEFAULT true
);

COMMENT ON TABLE squad_colors IS
    'Bib colours a pickup side / practice group can be named by. FK target of match_lineups.squad_color.';

INSERT INTO squad_colors (code, label, hex, sort_order) VALUES
    ('blue',   'Blue',   '#2563eb', 10),
    ('white',  'White',  '#f8fafc', 20),
    ('green',  'Green',  '#16a34a', 30),
    ('orange', 'Orange', '#ea580c', 40),
    ('red',    'Red',    '#dc2626', 50),
    ('yellow', 'Yellow', '#eab308', 60),
    ('black',  'Black',  '#111827', 70),
    ('pink',   'Pink',   '#ec4899', 80)
ON CONFLICT (code) DO NOTHING;

ALTER TABLE match_lineups
    DROP CONSTRAINT IF EXISTS match_lineups_squad_color_check;
ALTER TABLE match_lineups
    DROP CONSTRAINT IF EXISTS match_lineups_squad_color_fkey;
ALTER TABLE match_lineups
    ADD CONSTRAINT match_lineups_squad_color_fkey
    FOREIGN KEY (squad_color) REFERENCES squad_colors(code) ON UPDATE CASCADE;

COMMIT;
