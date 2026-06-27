-- ============================================================================
-- Migration 071: Scrub residual GroupMe defaults and column comments
-- ============================================================================
-- Migrations 057 (FH-native RSVPs/sessions), 059 (GM cutover) and 066
-- (drop GroupMe) flipped the source of truth from GroupMe to footballhome,
-- but two cosmetic / semantic drips were missed:
--
--   1. training_attendance.source still defaulted to 'groupme'. Live table
--      is currently empty (0 rows), so changing the default is safe.
--      New inserts should default to 'footballhome' to match chat_events.
--   2. The COMMENT on external_person_aliases.provider listed 'groupme'
--      as an example provider.
--   3. The COMMENT on matches.manual_override talked about GroupMe as the
--      upstream sync to block.
--
-- Migration 070 already dropped the four unused chat_providers seed rows
-- (discord/slack/teamsnap/whatsapp); the table itself is preserved for
-- future integrations.
-- ============================================================================

BEGIN;

-- 1. training_attendance.source default
ALTER TABLE training_attendance
    ALTER COLUMN source SET DEFAULT 'footballhome';

-- 2. external_person_aliases.provider comment
COMMENT ON COLUMN external_person_aliases.provider IS
    'External source key (e.g. leagueapps, casa, apsl).';

-- 3. matches.manual_override comment
COMMENT ON COLUMN matches.manual_override IS
    'When TRUE, any upstream sync is forbidden from overwriting title/match_date/match_time. Set this when a coach edits the match manually and we should preserve their values.';

COMMIT;
