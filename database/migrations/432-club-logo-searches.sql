-- ─────────────────────────────────────────────────────────────────────
-- 432-club-logo-searches.sql (2026-09-25)
--
-- Owner: "we should do that by default upon encountering club with no
-- logo in db … normalized in db and oop for part that checks … i am
-- fine with publish we can always fix … its only for new clubs".
--
-- When an Opponent: text on the calendar matches nothing (no club alias,
-- no club name, no team alias, no cached crest), the backend queues ONE
-- web search for it.  ClubLogoSearchScheduler works the queue:
-- ClubLogoFinder asks Claude (web search + fetch) for the club's crest
-- URL, downloads it, has Claude look at the image to confirm it is a real
-- emblem, then stores it as the club's current logo (club_logos, source
-- = 'search') and aliases the opponent text to the club.  Published at
-- once; #logos shows where it came from with a Reject button.
--
--   club_logo_searches   one row per opponent text ever searched — the
--                        queue, the outcome, and what was found.
--   message_templates    kind = 'logo_search': the prompts (find / judge).
-- ─────────────────────────────────────────────────────────────────────

ALTER TABLE club_logos DROP CONSTRAINT IF EXISTS club_logos_source_check;
ALTER TABLE club_logos ADD CONSTRAINT club_logos_source_check
    CHECK (source IN ('upload', 'url', 'legacy', 'search'));

CREATE TABLE IF NOT EXISTS club_logo_searches (
    id              SERIAL PRIMARY KEY,
    opponent_text   TEXT NOT NULL,
    context         TEXT,                        -- "league PPR · boys U8" — what the calendar knows
    status          TEXT NOT NULL DEFAULT 'queued'
                    CHECK (status IN ('queued', 'running', 'found', 'none', 'failed', 'rejected')),
    attempts        INT  NOT NULL DEFAULT 0,
    requested_by    INT REFERENCES persons(id) ON DELETE SET NULL,   -- NULL = automatic
    requested_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    started_at      TIMESTAMPTZ,
    finished_at     TIMESTAMPTZ,
    provider        TEXT,                        -- 'anthropic'
    model           TEXT,
    club_name_found TEXT,
    club_id         INT REFERENCES clubs(id) ON DELETE SET NULL,
    logo_id         INT REFERENCES club_logos(id) ON DELETE SET NULL,
    image_url       TEXT,                        -- the crest URL the search returned
    page_url        TEXT,                        -- the page it was found on
    confidence      REAL,                        -- 0–1, the finder's own estimate
    judge_note      TEXT,                        -- what the image check said
    reason          TEXT,                        -- the finder's reasoning, in a sentence
    error           TEXT,
    rejected_by     INT REFERENCES persons(id) ON DELETE SET NULL,
    rejected_at     TIMESTAMPTZ
);
CREATE UNIQUE INDEX IF NOT EXISTS club_logo_searches_text_idx ON club_logo_searches (LOWER(BTRIM(opponent_text)));
CREATE INDEX IF NOT EXISTS club_logo_searches_queue_idx ON club_logo_searches (status, requested_at) WHERE status = 'queued';
COMMENT ON TABLE club_logo_searches IS 'One web search per unmatched opponent text for its club crest (mig 432). queued → running → found | none | failed; rejected = an admin threw the found crest out.';

-- The prompts.  {opponent} {context} on the find prompt; {club_name} on the judge prompt.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'System', l, 'logo_search', t, s, b, o, true, false, false
  FROM (VALUES
    ('find_system', 'Club logo search — instructions to the model', NULL,
     E'You find the official crest (badge / logo image) of amateur, youth and semi-pro soccer clubs in and around Philadelphia, PA, for a club called Lighthouse 1893 SC that plays them. Use web search and web fetch. Prefer the club''s own website or official social page. A crest is an emblem or wordmark that belongs to that club — never a photo, a stock image, a league logo, a map pin, a generic shield, a platform placeholder, or another club''s badge. The image URL must point straight at the image file (png, jpg, webp, gif or svg), not at a web page. Reply with only a JSON object and nothing else.', 700),
    ('find_user', 'Club logo search — the question', NULL,
     E'The opponent is written on our calendar as: "{opponent}"[[ ({context})]].\n\nWork out which club that is and find a direct URL to its crest image.\n\nReply with only this JSON:\n{"club_name": "the club''s proper full name", "image_url": "direct image URL or null", "page_url": "the page the crest came from or null", "confidence": 0.0-1.0, "reason": "one sentence"}', 701),
    ('judge', 'Club logo search — checking the downloaded image', NULL,
     E'Is this image the crest, badge or logo of the soccer club "{club_name}"? Answer no for a photo, a stock image, a map pin, a generic shield, a platform placeholder, a league logo, or a blank image.\n\nReply with only this JSON:\n{"is_crest": true or false, "confidence": 0.0-1.0, "note": "one sentence"}', 702)
  ) AS v(t, l, s, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'logo_search' AND m.tier = v.t);
