-- 722 (2026-10-26) — a red (turned-off) ref fee remembers its GAME, not just
-- the fixture id.  TeamPass re-issued the uids of two APSL away games at
-- 16:48; the feed sync made new league_fixtures rows, the id-only declines
-- of 16:42 no longer matched, and auto-add put both fees back on James's
-- 2026.21 (owner: "why did apsl refs come back lol. is it not saving?").
-- InvoiceController's RefDeclines now matches date + opponent too; rows
-- written before this learn their game the next time their id matches.
ALTER TABLE invoice_ref_declines ADD COLUMN IF NOT EXISTS game_on date;
ALTER TABLE invoice_ref_declines ADD COLUMN IF NOT EXISTS opponent text;

-- The two orphaned declines (their fixtures were re-issued and are removed).
DELETE FROM invoice_ref_declines d USING league_fixtures f
 WHERE d.source = 'fixture' AND f.id = d.ref_id AND f.removed_at IS NOT NULL;

-- Fixture declines learn their game now (same date/opponent Expenses::games
-- builds), so they hold even before the invoice is next opened.
UPDATE invoice_ref_declines d
   SET game_on = (f.starts_at AT TIME ZONE 'America/New_York')::date,
       opponent = CASE WHEN f.home_club_id = 134 THEN f.away_name ELSE f.home_name END
  FROM league_fixtures f
 WHERE d.source = 'fixture' AND f.id = d.ref_id AND d.game_on IS NULL;
