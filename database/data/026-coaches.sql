-- Coaches - Foundation Data
-- Create coach entities for persons (team assignments happen in 080-post-load-processing.sql)

-- James Breslin as coach
INSERT INTO coaches (id, person_id, license_level, certifications)
VALUES (
    1,
    1,  -- person_id=1 (James Breslin from persons table)
    'USSF D',
    'USSF D License, SafeSport Certified'
) ON CONFLICT (id) DO UPDATE SET
    person_id = EXCLUDED.person_id,
    license_level = EXCLUDED.license_level,
    certifications = EXCLUDED.certifications;

