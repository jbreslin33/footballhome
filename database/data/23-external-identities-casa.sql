-- ========================================
-- CASA LIGHTHOUSE ROSTERS
-- ========================================
-- Generated: 2025-12-14T00:23:54.739Z
-- Source: Google Sheets
-- ========================================

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '04b164cd-4e35-4302-84b0-60e2a5e71500';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-boys-club-1-omar';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '1', 'Omar', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            NULL,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        '1 Omar',
        v_user_id, -- Linked to the user we just created/found
        '1',
        'Omar',
        v_team_id,
        '{"jersey_number":"Alzubair","position":null,"team_name":"Lighthouse Boys Club"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '04b164cd-4e35-4302-84b0-60e2a5e71500';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-boys-club-2-erwa';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '2', 'Erwa', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            NULL,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        '2 Erwa',
        v_user_id, -- Linked to the user we just created/found
        '2',
        'Erwa',
        v_team_id,
        '{"jersey_number":"Babiker","position":null,"team_name":"Lighthouse Boys Club"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '04b164cd-4e35-4302-84b0-60e2a5e71500';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-boys-club-3-victor';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '3', 'Victor', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            NULL,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        '3 Victor',
        v_user_id, -- Linked to the user we just created/found
        '3',
        'Victor',
        v_team_id,
        '{"jersey_number":"Baidel","position":null,"team_name":"Lighthouse Boys Club"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '04b164cd-4e35-4302-84b0-60e2a5e71500';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-boys-club-4-oumar';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '4', 'Oumar', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            NULL,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        '4 Oumar',
        v_user_id, -- Linked to the user we just created/found
        '4',
        'Oumar',
        v_team_id,
        '{"jersey_number":"Barry","position":null,"team_name":"Lighthouse Boys Club"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '04b164cd-4e35-4302-84b0-60e2a5e71500';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-boys-club-5-aboubacar';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '5', 'Aboubacar', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            NULL,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        '5 Aboubacar',
        v_user_id, -- Linked to the user we just created/found
        '5',
        'Aboubacar',
        v_team_id,
        '{"jersey_number":"Bayo","position":null,"team_name":"Lighthouse Boys Club"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '04b164cd-4e35-4302-84b0-60e2a5e71500';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-boys-club-6-luke';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '6', 'Luke', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            NULL,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        '6 Luke',
        v_user_id, -- Linked to the user we just created/found
        '6',
        'Luke',
        v_team_id,
        '{"jersey_number":"Breslin","position":null,"team_name":"Lighthouse Boys Club"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '04b164cd-4e35-4302-84b0-60e2a5e71500';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-boys-club-7-luis';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '7', 'Luis', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            NULL,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        '7 Luis',
        v_user_id, -- Linked to the user we just created/found
        '7',
        'Luis',
        v_team_id,
        '{"jersey_number":"De Jesus","position":null,"team_name":"Lighthouse Boys Club"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '04b164cd-4e35-4302-84b0-60e2a5e71500';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-boys-club-8-abdoul';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '8', 'Abdoul', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            NULL,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        '8 Abdoul',
        v_user_id, -- Linked to the user we just created/found
        '8',
        'Abdoul',
        v_team_id,
        '{"jersey_number":"Diallo","position":null,"team_name":"Lighthouse Boys Club"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '04b164cd-4e35-4302-84b0-60e2a5e71500';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-boys-club-9-abouya';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '9', 'Abouya', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            NULL,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        '9 Abouya',
        v_user_id, -- Linked to the user we just created/found
        '9',
        'Abouya',
        v_team_id,
        '{"jersey_number":"Gangue","position":null,"team_name":"Lighthouse Boys Club"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '04b164cd-4e35-4302-84b0-60e2a5e71500';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-boys-club-10-edwin';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '10', 'Edwin', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            NULL,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        '10 Edwin',
        v_user_id, -- Linked to the user we just created/found
        '10',
        'Edwin',
        v_team_id,
        '{"jersey_number":"Garcia","position":null,"team_name":"Lighthouse Boys Club"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '04b164cd-4e35-4302-84b0-60e2a5e71500';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-boys-club-11-miles';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '11', 'Miles', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            NULL,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        '11 Miles',
        v_user_id, -- Linked to the user we just created/found
        '11',
        'Miles',
        v_team_id,
        '{"jersey_number":"Henry","position":null,"team_name":"Lighthouse Boys Club"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '04b164cd-4e35-4302-84b0-60e2a5e71500';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-boys-club-12-andy';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '12', 'Andy', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            NULL,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        '12 Andy',
        v_user_id, -- Linked to the user we just created/found
        '12',
        'Andy',
        v_team_id,
        '{"jersey_number":"Hizdri","position":null,"team_name":"Lighthouse Boys Club"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '04b164cd-4e35-4302-84b0-60e2a5e71500';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-boys-club-13-arif';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '13', 'Arif', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            NULL,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        '13 Arif',
        v_user_id, -- Linked to the user we just created/found
        '13',
        'Arif',
        v_team_id,
        '{"jersey_number":"Hossain","position":null,"team_name":"Lighthouse Boys Club"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '04b164cd-4e35-4302-84b0-60e2a5e71500';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-boys-club-14-zuhab';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '14', 'Zuhab', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            NULL,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        '14 Zuhab',
        v_user_id, -- Linked to the user we just created/found
        '14',
        'Zuhab',
        v_team_id,
        '{"jersey_number":"Imran","position":null,"team_name":"Lighthouse Boys Club"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '04b164cd-4e35-4302-84b0-60e2a5e71500';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-boys-club-15-esnayder';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '15', 'Esnayder', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            NULL,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        '15 Esnayder',
        v_user_id, -- Linked to the user we just created/found
        '15',
        'Esnayder',
        v_team_id,
        '{"jersey_number":"Josue","position":null,"team_name":"Lighthouse Boys Club"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '04b164cd-4e35-4302-84b0-60e2a5e71500';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-boys-club-16-majid';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '16', 'Majid', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            NULL,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        '16 Majid',
        v_user_id, -- Linked to the user we just created/found
        '16',
        'Majid',
        v_team_id,
        '{"jersey_number":"Kawa","position":null,"team_name":"Lighthouse Boys Club"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '04b164cd-4e35-4302-84b0-60e2a5e71500';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-boys-club-17-alexander';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '17', 'Alexander', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            NULL,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        '17 Alexander',
        v_user_id, -- Linked to the user we just created/found
        '17',
        'Alexander',
        v_team_id,
        '{"jersey_number":"Lara","position":null,"team_name":"Lighthouse Boys Club"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '04b164cd-4e35-4302-84b0-60e2a5e71500';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-boys-club-18-matt';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '18', 'Matt', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            NULL,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        '18 Matt',
        v_user_id, -- Linked to the user we just created/found
        '18',
        'Matt',
        v_team_id,
        '{"jersey_number":"Leder","position":null,"team_name":"Lighthouse Boys Club"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '04b164cd-4e35-4302-84b0-60e2a5e71500';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-boys-club-19-valentino';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '19', 'Valentino', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            NULL,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        '19 Valentino',
        v_user_id, -- Linked to the user we just created/found
        '19',
        'Valentino',
        v_team_id,
        '{"jersey_number":"Martinez","position":null,"team_name":"Lighthouse Boys Club"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '04b164cd-4e35-4302-84b0-60e2a5e71500';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-boys-club-20-david';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '20', 'David', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            NULL,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        '20 David',
        v_user_id, -- Linked to the user we just created/found
        '20',
        'David',
        v_team_id,
        '{"jersey_number":"Masi","position":null,"team_name":"Lighthouse Boys Club"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '04b164cd-4e35-4302-84b0-60e2a5e71500';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-boys-club-21-elmer';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '21', 'Elmer', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            NULL,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        '21 Elmer',
        v_user_id, -- Linked to the user we just created/found
        '21',
        'Elmer',
        v_team_id,
        '{"jersey_number":"Mendoza","position":null,"team_name":"Lighthouse Boys Club"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '04b164cd-4e35-4302-84b0-60e2a5e71500';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-boys-club-22-dylan';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '22', 'Dylan', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            NULL,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        '22 Dylan',
        v_user_id, -- Linked to the user we just created/found
        '22',
        'Dylan',
        v_team_id,
        '{"jersey_number":"Moreno","position":null,"team_name":"Lighthouse Boys Club"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '04b164cd-4e35-4302-84b0-60e2a5e71500';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-boys-club-23-babacar';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '23', 'Babacar', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            NULL,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        '23 Babacar',
        v_user_id, -- Linked to the user we just created/found
        '23',
        'Babacar',
        v_team_id,
        '{"jersey_number":"Ndiaye","position":null,"team_name":"Lighthouse Boys Club"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '04b164cd-4e35-4302-84b0-60e2a5e71500';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-boys-club-24-zion';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '24', 'Zion', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            NULL,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        '24 Zion',
        v_user_id, -- Linked to the user we just created/found
        '24',
        'Zion',
        v_team_id,
        '{"jersey_number":"Nwalipenja","position":null,"team_name":"Lighthouse Boys Club"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '04b164cd-4e35-4302-84b0-60e2a5e71500';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-boys-club-25-john';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '25', 'John', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            NULL,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        '25 John',
        v_user_id, -- Linked to the user we just created/found
        '25',
        'John',
        v_team_id,
        '{"jersey_number":"Oladele","position":null,"team_name":"Lighthouse Boys Club"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '04b164cd-4e35-4302-84b0-60e2a5e71500';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-boys-club-26-jemirkel';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '26', 'Jemirkel', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            NULL,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        '26 Jemirkel',
        v_user_id, -- Linked to the user we just created/found
        '26',
        'Jemirkel',
        v_team_id,
        '{"jersey_number":"Ornaque","position":null,"team_name":"Lighthouse Boys Club"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '04b164cd-4e35-4302-84b0-60e2a5e71500';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-boys-club-27-joe';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '27', 'Joe', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            NULL,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        '27 Joe',
        v_user_id, -- Linked to the user we just created/found
        '27',
        'Joe',
        v_team_id,
        '{"jersey_number":"Riccitelli","position":null,"team_name":"Lighthouse Boys Club"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '04b164cd-4e35-4302-84b0-60e2a5e71500';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-boys-club-28-caleb';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '28', 'Caleb', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            NULL,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        '28 Caleb',
        v_user_id, -- Linked to the user we just created/found
        '28',
        'Caleb',
        v_team_id,
        '{"jersey_number":"Rojas","position":null,"team_name":"Lighthouse Boys Club"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '04b164cd-4e35-4302-84b0-60e2a5e71500';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-boys-club-29-ali';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '29', 'Ali', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            NULL,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        '29 Ali',
        v_user_id, -- Linked to the user we just created/found
        '29',
        'Ali',
        v_team_id,
        '{"jersey_number":"Salah","position":null,"team_name":"Lighthouse Boys Club"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '449ef257-2d8f-43c0-8ae1-6374894d17f1';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-old-timers-1-hassane';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '1', 'Hassane', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            NULL,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        '1 Hassane',
        v_user_id, -- Linked to the user we just created/found
        '1',
        'Hassane',
        v_team_id,
        '{"jersey_number":"Abdellaoui","position":null,"team_name":"Lighthouse Old Timers"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '449ef257-2d8f-43c0-8ae1-6374894d17f1';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-old-timers-2-logan';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '2', 'Logan', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            NULL,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        '2 Logan',
        v_user_id, -- Linked to the user we just created/found
        '2',
        'Logan',
        v_team_id,
        '{"jersey_number":"Bersani","position":null,"team_name":"Lighthouse Old Timers"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '449ef257-2d8f-43c0-8ae1-6374894d17f1';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-old-timers-7-john';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '7', 'John', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            NULL,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        '7 John',
        v_user_id, -- Linked to the user we just created/found
        '7',
        'John',
        v_team_id,
        '{"jersey_number":"Gonzalez","position":null,"team_name":"Lighthouse Old Timers"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '449ef257-2d8f-43c0-8ae1-6374894d17f1';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-old-timers-8-john';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '8', 'John', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            NULL,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        '8 John',
        v_user_id, -- Linked to the user we just created/found
        '8',
        'John',
        v_team_id,
        '{"jersey_number":"Heiler","position":null,"team_name":"Lighthouse Old Timers"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '449ef257-2d8f-43c0-8ae1-6374894d17f1';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-old-timers-9-justin';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '9', 'Justin', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            NULL,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        '9 Justin',
        v_user_id, -- Linked to the user we just created/found
        '9',
        'Justin',
        v_team_id,
        '{"jersey_number":"Katz","position":null,"team_name":"Lighthouse Old Timers"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '449ef257-2d8f-43c0-8ae1-6374894d17f1';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-old-timers-10-brian';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '10', 'Brian', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            NULL,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        '10 Brian',
        v_user_id, -- Linked to the user we just created/found
        '10',
        'Brian',
        v_team_id,
        '{"jersey_number":"Kenny","position":null,"team_name":"Lighthouse Old Timers"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '449ef257-2d8f-43c0-8ae1-6374894d17f1';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-old-timers-11-joaquin';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, 'Joaquin', 'Ladeuix', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            NULL,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        'Joaquin Ladeuix',
        v_user_id, -- Linked to the user we just created/found
        'Joaquin',
        'Ladeuix',
        v_team_id,
        '{"position":null,"team_name":"Lighthouse Old Timers"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '449ef257-2d8f-43c0-8ae1-6374894d17f1';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-old-timers--ladeuix';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '"', 'Ladeuix', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            7,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        '" Ladeuix',
        v_user_id, -- Linked to the user we just created/found
        '"',
        'Ladeuix',
        v_team_id,
        '{"jersey_number":"07/28/1993","position":null,"team_name":"Lighthouse Old Timers"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '449ef257-2d8f-43c0-8ae1-6374894d17f1';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-old-timers-12-sam';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '12', 'Sam', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            NULL,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        '12 Sam',
        v_user_id, -- Linked to the user we just created/found
        '12',
        'Sam',
        v_team_id,
        '{"jersey_number":"Lipsey","position":null,"team_name":"Lighthouse Old Timers"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '449ef257-2d8f-43c0-8ae1-6374894d17f1';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-old-timers-13-juan-cruz';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '13', 'Juan Cruz', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            NULL,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        '13 Juan Cruz',
        v_user_id, -- Linked to the user we just created/found
        '13',
        'Juan Cruz',
        v_team_id,
        '{"jersey_number":"Llambias","position":null,"team_name":"Lighthouse Old Timers"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '449ef257-2d8f-43c0-8ae1-6374894d17f1';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-old-timers-14-sean';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '14', 'Sean', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            NULL,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        '14 Sean',
        v_user_id, -- Linked to the user we just created/found
        '14',
        'Sean',
        v_team_id,
        '{"jersey_number":"McConnel","position":null,"team_name":"Lighthouse Old Timers"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '449ef257-2d8f-43c0-8ae1-6374894d17f1';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-old-timers-15-antonio';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '15', 'Antonio', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            NULL,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        '15 Antonio',
        v_user_id, -- Linked to the user we just created/found
        '15',
        'Antonio',
        v_team_id,
        '{"jersey_number":"Moral","position":null,"team_name":"Lighthouse Old Timers"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '449ef257-2d8f-43c0-8ae1-6374894d17f1';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-old-timers-16-manuel';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '16', 'Manuel', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            NULL,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        '16 Manuel',
        v_user_id, -- Linked to the user we just created/found
        '16',
        'Manuel',
        v_team_id,
        '{"jersey_number":"Morales","position":null,"team_name":"Lighthouse Old Timers"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '449ef257-2d8f-43c0-8ae1-6374894d17f1';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-old-timers-17-kevin';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '17', 'Kevin', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            NULL,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        '17 Kevin',
        v_user_id, -- Linked to the user we just created/found
        '17',
        'Kevin',
        v_team_id,
        '{"jersey_number":"Nguyen","position":null,"team_name":"Lighthouse Old Timers"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '449ef257-2d8f-43c0-8ae1-6374894d17f1';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-old-timers-19-marcelo';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '19', 'Marcelo', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            NULL,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        '19 Marcelo',
        v_user_id, -- Linked to the user we just created/found
        '19',
        'Marcelo',
        v_team_id,
        '{"jersey_number":"Osorio-Soto","position":null,"team_name":"Lighthouse Old Timers"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '449ef257-2d8f-43c0-8ae1-6374894d17f1';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-old-timers-20-fabian';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '20', 'Fabian', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            NULL,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        '20 Fabian',
        v_user_id, -- Linked to the user we just created/found
        '20',
        'Fabian',
        v_team_id,
        '{"jersey_number":"Padilla","position":null,"team_name":"Lighthouse Old Timers"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '449ef257-2d8f-43c0-8ae1-6374894d17f1';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-old-timers-21-ruben';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '21', 'Ruben', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            NULL,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        '21 Ruben',
        v_user_id, -- Linked to the user we just created/found
        '21',
        'Ruben',
        v_team_id,
        '{"jersey_number":"Piazzesi","position":null,"team_name":"Lighthouse Old Timers"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '449ef257-2d8f-43c0-8ae1-6374894d17f1';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-old-timers-22-joshua';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '22', 'Joshua', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            NULL,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        '22 Joshua',
        v_user_id, -- Linked to the user we just created/found
        '22',
        'Joshua',
        v_team_id,
        '{"jersey_number":"Rosato","position":null,"team_name":"Lighthouse Old Timers"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '449ef257-2d8f-43c0-8ae1-6374894d17f1';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-old-timers-23-anuar';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '23', 'Anuar', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            NULL,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        '23 Anuar',
        v_user_id, -- Linked to the user we just created/found
        '23',
        'Anuar',
        v_team_id,
        '{"jersey_number":"Santos","position":null,"team_name":"Lighthouse Old Timers"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '449ef257-2d8f-43c0-8ae1-6374894d17f1';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-old-timers-24-anthony';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '24', 'Anthony', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            NULL,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        '24 Anthony',
        v_user_id, -- Linked to the user we just created/found
        '24',
        'Anthony',
        v_team_id,
        '{"jersey_number":"Sagustume","position":null,"team_name":"Lighthouse Old Timers"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '449ef257-2d8f-43c0-8ae1-6374894d17f1';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-old-timers-25-yakup';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '25', 'Yakup', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            NULL,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        '25 Yakup',
        v_user_id, -- Linked to the user we just created/found
        '25',
        'Yakup',
        v_team_id,
        '{"jersey_number":"Serce","position":null,"team_name":"Lighthouse Old Timers"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '449ef257-2d8f-43c0-8ae1-6374894d17f1';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-old-timers-26-christopher';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '26', 'Christopher', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            NULL,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        '26 Christopher',
        v_user_id, -- Linked to the user we just created/found
        '26',
        'Christopher',
        v_team_id,
        '{"jersey_number":"Solis","position":null,"team_name":"Lighthouse Old Timers"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '449ef257-2d8f-43c0-8ae1-6374894d17f1';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-old-timers-27-juan';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '27', 'Juan', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            NULL,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        '27 Juan',
        v_user_id, -- Linked to the user we just created/found
        '27',
        'Juan',
        v_team_id,
        '{"jersey_number":"Vizcaino","position":null,"team_name":"Lighthouse Old Timers"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '449ef257-2d8f-43c0-8ae1-6374894d17f1';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-old-timers-28-tom';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '28', 'Tom', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            NULL,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        '28 Tom',
        v_user_id, -- Linked to the user we just created/found
        '28',
        'Tom',
        v_team_id,
        '{"jersey_number":"Diguilio","position":null,"team_name":"Lighthouse Old Timers"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '449ef257-2d8f-43c0-8ae1-6374894d17f1';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-old-timers-29-leo';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '29', 'Leo', true)
    ON CONFLICT (id) DO NOTHING;

    -- 3. Create Player Profile
    INSERT INTO players (id)
    VALUES (v_user_id)
    ON CONFLICT (id) DO NOTHING;

    -- 4. Create Team Player (Roster Entry) if team exists
    IF v_team_id IS NOT NULL THEN
        INSERT INTO team_players (id, team_id, player_id, roster_status_id, jersey_number, is_active)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'tp-' || v_team_id || '-' || v_user_id),
            v_team_id,
            v_user_id,
            1, -- Active
            NULL,
            true
        )
        ON CONFLICT (team_id, player_id) DO UPDATE SET
            jersey_number = EXCLUDED.jersey_number,
            is_active = true;
    END IF;

    -- 4b. Division roster integration removed - division_players table no longer exists
    -- Players are now inferred from team_players

    -- 5. Create External Identity (Linked to User)
    INSERT INTO user_external_identities (
        id, 
        provider, 
        external_id, 
        external_username, 
        user_id,
        first_name, 
        last_name, 
        team_id, 
        external_data
    ) VALUES (
        uuid_generate_v5(uuid_ns_url(), v_external_id),
        'casa',
        v_external_id,
        '29 Leo',
        v_user_id, -- Linked to the user we just created/found
        '29',
        'Leo',
        v_team_id,
        '{"jersey_number":"Santa","position":null,"team_name":"Lighthouse Old Timers"}'
    )
    ON CONFLICT (provider, external_id) DO UPDATE SET
        user_id = EXCLUDED.user_id,
        external_username = EXCLUDED.external_username,
        first_name = EXCLUDED.first_name,
        last_name = EXCLUDED.last_name,
        team_id = EXCLUDED.team_id,
        external_data = EXCLUDED.external_data,
        updated_at = CURRENT_TIMESTAMP;
END $$;

