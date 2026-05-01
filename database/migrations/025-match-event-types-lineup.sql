-- Add lineup event types for tracking starters and listed substitutes
INSERT INTO match_event_types (name) VALUES ('starter') ON CONFLICT (name) DO NOTHING;
INSERT INTO match_event_types (name) VALUES ('sub_listed') ON CONFLICT (name) DO NOTHING;
