-- Organization-admins - Foundation Data
-- Renamed from club_admins (admins belong to organizations)
-- This file contains core/foundational data that always loads.

-- Assign James Breslin to Lighthouse 1893 organization
INSERT INTO organization_admins (organization_id, admin_id, admin_role, is_primary, is_active)
VALUES (1, 1, 'Owner', true, true)
ON CONFLICT DO NOTHING;
