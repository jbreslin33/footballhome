-- Migration 036: Add count_when_canceled to chat_events
-- Allows individual canceled sessions to grant attendance credit
-- Default false: canceled sessions are NOT counted unless explicitly opted in

ALTER TABLE chat_events
  ADD COLUMN IF NOT EXISTS count_when_canceled boolean NOT NULL DEFAULT false;

COMMENT ON COLUMN chat_events.count_when_canceled IS
  'When true, this canceled session still counts toward attendance eligibility. Only meaningful when is_active = false.';
