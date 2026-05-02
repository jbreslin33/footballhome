-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Venues - CASA (from SportsEngine schedule API)
-- Total: 6
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

INSERT INTO venues (name, address) VALUES ('Phoenix Sport Club', '301 West Bristol Road, Trevose, PA 19053-7301') ON CONFLICT (name) DO UPDATE SET address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) VALUES ('Lighthouse Sport Complex Field', '101-199 East Erie Avenue, Philadelphia, PA 19140, US') ON CONFLICT (name) DO UPDATE SET address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) VALUES ('Northeast High School', '1601 Cottman Avenue, Philadelphia, PA 19111-3430') ON CONFLICT (name) DO UPDATE SET address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) VALUES ('Germantown Supersite', '1199 East Sedgwick Street, Philadelphia, PA 19150, US') ON CONFLICT (name) DO UPDATE SET address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) VALUES ('South Philadelphia Super Site', '2926-2968 South 10th Street, Philadelphia, PA 19148') ON CONFLICT (name) DO UPDATE SET address = COALESCE(EXCLUDED.address, venues.address);
INSERT INTO venues (name, address) VALUES ('Lighthouse Sport Complex', '101-199 East Erie Avenue, Philadelphia, PA 19140, US') ON CONFLICT (name) DO UPDATE SET address = COALESCE(EXCLUDED.address, venues.address);
