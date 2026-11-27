-- 1597 — 💬 Messages = the four LeagueApps program descriptions, nothing
-- else.
--
-- Owner 2026-11-19: "we need to clean out messagges from there. the only
-- ones we need are the 4 la ones for each "club" any other messages have
-- now been automated … messaages is for copy and paste and i only need
-- that for la desc right?" → "so clean that page root and stem".
--
-- The page (frontend/js/screens/messages.js) is rebuilt: pick Boys /
-- Girls / Men's / Women's Club, see that club's LA description, 📋 Copy
-- puts the formatted version (text/html) on the clipboard for the
-- LeagueApps editor.  The 16 lead funnels, initial email / SMS, follow-
-- up / broadcast / close / info snippets and quick links are gone from
-- it — the Leads page builds those itself (LeadsScreen.messageSnippets),
-- unchanged.  The description text is still the program_* rows (mig 370).
-- The page's own words are these rows.

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Messages', v.label, 'messages_page', v.tier, NULL, v.body, v.sort, true, true, false
  FROM (VALUES
    ('#messages — page title',            'title',      '💬 Messages', 10),
    ('#messages — under the title',       'subtitle',   'The LeagueApps program description for each club. Pick a club, tap 📋 Copy, and paste into the program''s Description in LeagueApps (Ctrl+V keeps the bold, headings and bullets).', 11),
    ('#messages — club pill, Boys',       'club_boys',  'Boys Club', 20),
    ('#messages — club pill, Girls',      'club_girls', 'Girls Club', 21),
    ('#messages — club pill, Men',        'club_men',   'Men''s Club', 22),
    ('#messages — club pill, Women',      'club_women', 'Women''s Club', 23),
    ('#messages — card heading',          'card_title', '📋 LA Program Description — {club}', 30),
    ('#messages — copy button',           'copy',       '📋 Copy', 31),
    ('#messages — copy button, done',     'copied',     '✅ Copied', 32),
    ('#messages — copy button, failed',   'copy_failed','⚠ Copy failed', 33),
    ('#messages — nothing to show',       'empty',      'No description for this club yet.', 35)
  ) AS v(label, tier, body, sort)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'messages_page' AND m.tier = v.tier);
