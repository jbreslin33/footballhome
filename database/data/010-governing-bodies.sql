-- Governing Bodies - Minimal (US-focused for APSL/CASA)
-- Start with core bodies needed for Football Home functionality
-- Can expand to worldwide coverage later

-- Global
INSERT INTO governing_bodies (id, scope_id, name, short_name, website_url, country_id, state_id, description, is_active) VALUES
(1, 1, 'FIFA', 'FIFA', 'https://www.fifa.com', NULL, NULL, 'International governing body of association football', true) ON CONFLICT (id) DO NOTHING;

-- Confederations
INSERT INTO governing_bodies (id, scope_id, name, short_name, website_url, country_id, state_id, description, is_active) VALUES
(10, 2, 'CONCACAF', 'CONCACAF', 'https://www.concacaf.com', NULL, NULL, 'North/Central America and Caribbean confederation', true) ON CONFLICT (id) DO NOTHING;

-- National (US)
INSERT INTO governing_bodies (id, scope_id, name, short_name, website_url, country_id, state_id, description, is_active) VALUES
(100, 3, 'United States Soccer Federation', 'USSF', 'https://www.ussoccer.com', NULL, NULL, 'National governing body for soccer in the United States', true) ON CONFLICT (id) DO NOTHING;

-- Regional (US)
INSERT INTO governing_bodies (id, scope_id, name, short_name, website_url, country_id, state_id, description, is_active) VALUES
(200, 4, 'United States Adult Soccer Association', 'USASA', 'https://www.usadultsoccer.com', NULL, NULL, 'Primary adult soccer governing body in the US', true),
(300, 4, 'Eastern Pennsylvania Soccer Association', 'EPSA', 'https://www.epsa-soccer.org', NULL, NULL, 'Adult soccer in Eastern Pennsylvania (CASA region)', true) ON CONFLICT (id) DO NOTHING;
