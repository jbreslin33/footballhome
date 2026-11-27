-- 1928 📚 Coaching books — the owner's own Soccer Tutor library, read for the
-- game engine (James 11/26 "i would like to incorporate into footballhome for
-- my personal use" · "yes add the owner-only page").
--
-- Books are bought copies read in the Coach Viewer app; the pages are
-- captured from his phone over adb into ~/football-data/books/ (never git).
-- What lands here:
--   coaching_books           one row per book (author, team, season)
--   coaching_book_pages      the page images (JPEG bytes) — OWNER ONLY, served
--                            as base64 JSON behind the super gate, never a URL
--   coaching_book_patterns   each team pattern the author saw 10+ times,
--                            written up in OUR words: moment, trigger,
--                            outcome, book pages (the citation)
--   coaching_book_pattern_roles  who does what in that pattern
-- Page #books: menu_pages audience 'named' = only the people listed in
-- menu_page_people for that page (here person 1, the owner).  Four people
-- hold the super admin level, so super alone is not "owner only".

CREATE TABLE coaching_books (
    id            serial PRIMARY KEY,
    slug          text NOT NULL UNIQUE,          -- = folder under ~/football-data/books/
    title         text NOT NULL,
    subtitle      text,
    author        text NOT NULL,
    team          text,
    season        text,                          -- '2011-12'
    publisher     text NOT NULL DEFAULT 'SoccerTutor.com',
    page_count    integer,                       -- screens captured (app page numbers)
    method_note   text,                          -- how the author built it, our words
    sort_order    integer NOT NULL DEFAULT 0,
    created_at    timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE coaching_book_pages (
    book_id       integer NOT NULL REFERENCES coaching_books(id) ON DELETE CASCADE,
    page_no       integer NOT NULL,              -- app page number (1 = cover)
    printed_page  integer,                       -- number printed on the page, if any
    mime          text NOT NULL DEFAULT 'image/jpeg',
    bytes         bytea NOT NULL,
    PRIMARY KEY (book_id, page_no)
);

CREATE TABLE coaching_book_patterns (
    id              serial PRIMARY KEY,
    book_id         integer NOT NULL REFERENCES coaching_books(id) ON DELETE CASCADE,
    moment          text NOT NULL REFERENCES game_moments(code),
    chapter         text,
    title           text NOT NULL,               -- our short name for it
    situation       text NOT NULL,               -- where / when it happens
    trigger_text    text,                        -- the cue that starts it
    outcome         text,                        -- what it is meant to achieve
    vs_formation    text,                        -- opponent shape, when the book splits by it
    page_from       integer NOT NULL,            -- app page numbers (citation)
    page_to         integer NOT NULL,
    concept_id      smallint REFERENCES game_concepts(id),  -- engine concept it feeds, once mapped
    sort_order      integer NOT NULL DEFAULT 0,
    created_at      timestamptz NOT NULL DEFAULT now(),
    CHECK (page_to >= page_from)
);
CREATE INDEX coaching_book_patterns_book ON coaching_book_patterns(book_id, sort_order);

CREATE TABLE coaching_book_pattern_roles (
    pattern_id   integer NOT NULL REFERENCES coaching_book_patterns(id) ON DELETE CASCADE,
    sort_order   integer NOT NULL,
    role         text NOT NULL,                  -- 'Ball-side full back', 'No.6', 'Back four'
    job          text NOT NULL,
    PRIMARY KEY (pattern_id, sort_order)
);

ALTER TABLE menu_pages DROP CONSTRAINT menu_pages_audience_check;
ALTER TABLE menu_pages ADD CONSTRAINT menu_pages_audience_check
    CHECK (audience = ANY (ARRAY['everyone', 'coach', 'admin', 'marketing', 'named']));

INSERT INTO menu_pages (code, group_code, label, icon, audience, sort_order, screens, new_tab, download, is_active)
VALUES ('books', 'football', 'Books', '📚', 'named', 10, '{books}', false, false, true);

-- Who may open a 'named' page.  /api/menu leaves the page out for everyone
-- else, and the page's own API checks the same rows.
CREATE TABLE menu_page_people (
    page_code  text    NOT NULL REFERENCES menu_pages(code) ON DELETE CASCADE,
    person_id  integer NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    PRIMARY KEY (page_code, person_id)
);
INSERT INTO menu_page_people (page_code, person_id) VALUES ('books', 1);

INSERT INTO message_templates (category, label, kind, tier, body, sort_order, client_side, is_public)
SELECT 'Coaching books', v.label, 'books', v.tier, v.body, v.so, true, false
FROM (VALUES
  ('Books — page title', 'title', 'Coaching books', 1),
  ('Books — under the title', 'intro', 'Your Soccer Tutor library, read for the game engine. Patterns are written in our words; tap a page number to see the page.', 2),
  ('Books — no books yet', 'none', 'No books loaded yet.', 3),
  ('Books — all moments pill', 'all', 'All', 4),
  ('Books — no patterns yet for this book', 'no_patterns', 'Pages captured — patterns not written up yet.', 5),
  ('Books — trigger label', 'trigger', 'Trigger', 6),
  ('Books — outcome label', 'outcome', 'Aim', 7),
  ('Books — versus label', 'vs', 'v', 8),
  ('Books — pages label', 'pages', 'pp.', 9),
  ('Books — page viewer, previous', 'prev', '‹ Prev', 10),
  ('Books — page viewer, next', 'next', 'Next ›', 11),
  ('Books — page viewer, close', 'close', 'Close', 12),
  ('Books — browse all pages', 'browse', 'Browse pages', 13),
  ('Books — counts line', 'counts', '{pages} pages · {patterns} patterns', 14)
) AS v(label, tier, body, so);
