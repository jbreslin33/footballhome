-- ========================================
-- CASA LIGHTHOUSE ROSTERS
-- ========================================
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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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
    v_external_id VARCHAR := 'casa-lighthouse-boys-club-3-hassane';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '3', 'Hassane', true)
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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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
        '3 Hassane',
        v_user_id, -- Linked to the user we just created/found
        '3',
        'Hassane',
        v_team_id,
        '{"jersey_number":"Abdellaoui","position":null,"team_name":"Lighthouse Boys Club"}'
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
    v_external_id VARCHAR := 'casa-lighthouse-boys-club-4-victor';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '4', 'Victor', true)
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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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
        '4 Victor',
        v_user_id, -- Linked to the user we just created/found
        '4',
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
    v_external_id VARCHAR := 'casa-lighthouse-boys-club-5-oumar';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '5', 'Oumar', true)
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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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
        '5 Oumar',
        v_user_id, -- Linked to the user we just created/found
        '5',
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
    v_external_id VARCHAR := 'casa-lighthouse-boys-club-6-aboubacar';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '6', 'Aboubacar', true)
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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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
        '6 Aboubacar',
        v_user_id, -- Linked to the user we just created/found
        '6',
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
    v_external_id VARCHAR := 'casa-lighthouse-boys-club-7-luke';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '7', 'Luke', true)
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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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
        '7 Luke',
        v_user_id, -- Linked to the user we just created/found
        '7',
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
    v_external_id VARCHAR := 'casa-lighthouse-boys-club-8-luis';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '8', 'Luis', true)
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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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
        '8 Luis',
        v_user_id, -- Linked to the user we just created/found
        '8',
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
    v_external_id VARCHAR := 'casa-lighthouse-boys-club-9-abdoul';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '9', 'Abdoul', true)
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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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
        '9 Abdoul',
        v_user_id, -- Linked to the user we just created/found
        '9',
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
    v_external_id VARCHAR := 'casa-lighthouse-boys-club-10-abouya';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '10', 'Abouya', true)
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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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
        '10 Abouya',
        v_user_id, -- Linked to the user we just created/found
        '10',
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
    v_external_id VARCHAR := 'casa-lighthouse-boys-club-11-edwin';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '11', 'Edwin', true)
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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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
        '11 Edwin',
        v_user_id, -- Linked to the user we just created/found
        '11',
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
    v_external_id VARCHAR := 'casa-lighthouse-boys-club-12-miles';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '12', 'Miles', true)
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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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
        '12 Miles',
        v_user_id, -- Linked to the user we just created/found
        '12',
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
    v_external_id VARCHAR := 'casa-lighthouse-boys-club-13-andy';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '13', 'Andy', true)
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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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
        '13 Andy',
        v_user_id, -- Linked to the user we just created/found
        '13',
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
    v_external_id VARCHAR := 'casa-lighthouse-boys-club-14-arif';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '14', 'Arif', true)
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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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
        '14 Arif',
        v_user_id, -- Linked to the user we just created/found
        '14',
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
    v_external_id VARCHAR := 'casa-lighthouse-boys-club-15-zuhab';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '15', 'Zuhab', true)
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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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
        '15 Zuhab',
        v_user_id, -- Linked to the user we just created/found
        '15',
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
    v_external_id VARCHAR := 'casa-lighthouse-boys-club-16-esnayder';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '16', 'Esnayder', true)
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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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
        '16 Esnayder',
        v_user_id, -- Linked to the user we just created/found
        '16',
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
    v_external_id VARCHAR := 'casa-lighthouse-boys-club-17-majid';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '17', 'Majid', true)
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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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
        '17 Majid',
        v_user_id, -- Linked to the user we just created/found
        '17',
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
    v_external_id VARCHAR := 'casa-lighthouse-boys-club-18-alexander';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '18', 'Alexander', true)
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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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
        '18 Alexander',
        v_user_id, -- Linked to the user we just created/found
        '18',
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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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
    v_team_id UUID := '04b164cd-4e35-4302-84b0-60e2a5e71500';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-boys-club-30-daniel';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '30', 'Daniel', true)
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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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
        '30 Daniel',
        v_user_id, -- Linked to the user we just created/found
        '30',
        'Daniel',
        v_team_id,
        '{"jersey_number":"Salmanca","position":null,"team_name":"Lighthouse Boys Club"}'
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
    v_external_id VARCHAR := 'casa-lighthouse-old-timers-1-logan';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '1', 'Logan', true)
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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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
        '1 Logan',
        v_user_id, -- Linked to the user we just created/found
        '1',
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
    v_external_id VARCHAR := 'casa-lighthouse-old-timers-6-birru';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '6', 'Birru', true)
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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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
        '6 Birru',
        v_user_id, -- Linked to the user we just created/found
        '6',
        'Birru',
        v_team_id,
        '{"jersey_number":"Golden","position":null,"team_name":"Lighthouse Old Timers"}'
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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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
    VALUES (v_user_id, '11', '"Joaquin', true)
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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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
        '11 "Joaquin',
        v_user_id, -- Linked to the user we just created/found
        '11',
        '"Joaquin',
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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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
    v_external_id VARCHAR := 'casa-lighthouse-old-timers-18-musa';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '18', 'Musa', true)
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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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
        '18 Musa',
        v_user_id, -- Linked to the user we just created/found
        '18',
        'Musa',
        v_team_id,
        '{"jersey_number":"Osman","position":null,"team_name":"Lighthouse Old Timers"}'
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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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
    v_external_id VARCHAR := 'casa-lighthouse-old-timers-23-anthony';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '23', 'Anthony', true)
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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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
        '23 Anthony',
        v_user_id, -- Linked to the user we just created/found
        '23',
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
    v_external_id VARCHAR := 'casa-lighthouse-old-timers-24-leo';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '24', 'Leo', true)
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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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
        '24 Leo',
        v_user_id, -- Linked to the user we just created/found
        '24',
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

DO $$
DECLARE
    v_user_id UUID;
    v_team_id UUID := '449ef257-2d8f-43c0-8ae1-6374894d17f1';
    v_division_id UUID;
    v_external_id VARCHAR := 'casa-lighthouse-old-timers-25-anuar';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '25', 'Anuar', true)
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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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
        '25 Anuar',
        v_user_id, -- Linked to the user we just created/found
        '25',
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
    v_external_id VARCHAR := 'casa-lighthouse-old-timers-26-yakup';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '26', 'Yakup', true)
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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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
        '26 Yakup',
        v_user_id, -- Linked to the user we just created/found
        '26',
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
    v_external_id VARCHAR := 'casa-lighthouse-old-timers-27-christopher';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '27', 'Christopher', true)
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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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
        '27 Christopher',
        v_user_id, -- Linked to the user we just created/found
        '27',
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
    v_external_id VARCHAR := 'casa-lighthouse-old-timers-28-juan';
BEGIN
    -- Get division_id from team if team exists
    IF v_team_id IS NOT NULL THEN
        SELECT division_id INTO v_division_id FROM teams WHERE id = v_team_id;
    END IF;
    -- 1. Generate deterministic User ID
    v_user_id := uuid_generate_v5(uuid_ns_url(), 'user-' || v_external_id);

    -- 2. Create User (Stub)
    INSERT INTO users (id, first_name, last_name, is_active)
    VALUES (v_user_id, '28', 'Juan', true)
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

    -- 4b. Also add to Division Roster (for division-level rostering)
    IF v_division_id IS NOT NULL THEN
        INSERT INTO division_players (id, division_id, player_id, status)
        VALUES (
            uuid_generate_v5(uuid_ns_url(), 'dp-' || v_division_id || '-' || v_user_id),
            v_division_id,
            v_user_id,
            'active'
        )
        ON CONFLICT (division_id, player_id) DO UPDATE SET
            status = 'active';
    END IF;

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
        '28 Juan',
        v_user_id, -- Linked to the user we just created/found
        '28',
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

