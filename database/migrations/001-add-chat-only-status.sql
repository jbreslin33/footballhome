-- Add 'chat_only' status to roster_statuses
INSERT INTO roster_statuses (code, display_name, description, show_in_rsvp, show_in_official_roster, sort_order)
VALUES ('chat_only', 'Chat Only', 'In team chat but not on official roster', true, false, 7)
ON CONFLICT (code) DO NOTHING;
