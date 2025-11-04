-- External Data Integration System
-- Handles importing data from external league websites and systems

-- External data sources (websites, APIs, feeds)
CREATE TABLE external_data_sources (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,              -- 'APSL Website', 'CASA API', 'TeamPass System'
    display_name VARCHAR(150) NOT NULL,      -- Human readable name
    slug VARCHAR(100) UNIQUE NOT NULL,       -- 'apsl-website', 'casa-api'
    base_url VARCHAR(500) NOT NULL,          -- 'https://www.apslsoccer.com'
    source_type VARCHAR(50) NOT NULL,        -- 'website_scrape', 'rest_api', 'xml_feed', 'csv_import'
    data_format VARCHAR(50),                 -- 'html', 'json', 'xml', 'csv'
    authentication_type VARCHAR(50),         -- 'none', 'api_key', 'oauth', 'basic_auth'
    authentication_config JSONB,             -- Store auth credentials/config
    update_frequency VARCHAR(50),            -- 'real_time', 'hourly', 'daily', 'weekly', 'manual'
    is_active BOOLEAN DEFAULT true,
    last_sync_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Data source endpoints (specific URLs/endpoints for different data types)
CREATE TABLE data_source_endpoints (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    source_id UUID NOT NULL REFERENCES external_data_sources(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,              -- 'standings', 'fixtures', 'results'
    endpoint_path VARCHAR(500) NOT NULL,     -- '/APSL/Tables/', '/api/standings'
    data_type VARCHAR(50) NOT NULL,          -- 'standings', 'fixtures', 'results', 'teams', 'players'
    extraction_config JSONB,                 -- CSS selectors, JSON paths, etc.
    transformation_rules JSONB,              -- Field mappings, data transformations
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Import jobs (track data import operations)
CREATE TABLE import_jobs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    source_id UUID NOT NULL REFERENCES external_data_sources(id) ON DELETE CASCADE,
    endpoint_id UUID REFERENCES data_source_endpoints(id),
    job_type VARCHAR(50) NOT NULL,           -- 'full_sync', 'incremental', 'manual_import'
    status VARCHAR(50) NOT NULL DEFAULT 'pending', -- 'pending', 'running', 'completed', 'failed'
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    records_processed INTEGER DEFAULT 0,
    records_inserted INTEGER DEFAULT 0,
    records_updated INTEGER DEFAULT 0,
    records_failed INTEGER DEFAULT 0,
    error_message TEXT,
    import_metadata JSONB,                   -- Store import-specific data
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Staging tables for external data before it's processed into main tables
CREATE TABLE staging_external_data (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    import_job_id UUID NOT NULL REFERENCES import_jobs(id) ON DELETE CASCADE,
    source_id UUID NOT NULL REFERENCES external_data_sources(id),
    data_type VARCHAR(50) NOT NULL,          -- 'standings', 'fixtures', 'results'
    raw_data JSONB NOT NULL,                 -- Original data from external source
    processed_data JSONB,                    -- Cleaned/transformed data
    mapping_status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'mapped', 'failed'
    target_table VARCHAR(100),               -- Which table this should map to
    target_record_id UUID,                   -- If mapped to existing record
    mapping_confidence DECIMAL(3,2),         -- 0.00-1.00 confidence score
    mapping_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Data mappings (map external entities to internal entities)
CREATE TABLE external_entity_mappings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    source_id UUID NOT NULL REFERENCES external_data_sources(id) ON DELETE CASCADE,
    external_id VARCHAR(200) NOT NULL,       -- External system's ID for the entity
    external_name VARCHAR(200) NOT NULL,     -- Name in external system
    entity_type VARCHAR(50) NOT NULL,        -- 'league', 'conference', 'division', 'team', 'player'
    internal_table VARCHAR(100) NOT NULL,    -- 'leagues', 'teams', etc.
    internal_record_id UUID NOT NULL,        -- ID in our system
    confidence_score DECIMAL(3,2) DEFAULT 1.00, -- Mapping confidence
    mapping_method VARCHAR(50),              -- 'exact_match', 'fuzzy_match', 'manual'
    is_verified BOOLEAN DEFAULT false,       -- Has been human-verified
    verified_by UUID REFERENCES users(id),
    verified_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(source_id, external_id, entity_type)
);

-- Import conflicts (when external data conflicts with internal data)
CREATE TABLE import_conflicts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    import_job_id UUID NOT NULL REFERENCES import_jobs(id) ON DELETE CASCADE,
    staging_data_id UUID NOT NULL REFERENCES staging_external_data(id),
    conflict_type VARCHAR(50) NOT NULL,      -- 'duplicate_team', 'score_mismatch', 'date_conflict'
    existing_record_table VARCHAR(100),      -- Table of conflicting record
    existing_record_id UUID,                 -- ID of conflicting record
    conflict_description TEXT NOT NULL,
    suggested_resolution VARCHAR(50),        -- 'keep_external', 'keep_internal', 'merge', 'manual_review'
    resolution_status VARCHAR(50) DEFAULT 'pending', -- 'pending', 'resolved', 'ignored'
    resolved_by UUID REFERENCES users(id),
    resolved_at TIMESTAMP,
    resolution_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Data sync history (track changes from external sources)
CREATE TABLE data_sync_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    source_id UUID NOT NULL REFERENCES external_data_sources(id) ON DELETE CASCADE,
    table_name VARCHAR(100) NOT NULL,        -- Which table was affected
    record_id UUID NOT NULL,                 -- Which record was affected
    action VARCHAR(50) NOT NULL,             -- 'insert', 'update', 'delete'
    old_values JSONB,                        -- Previous values (for updates)
    new_values JSONB,                        -- New values
    sync_job_id UUID REFERENCES import_jobs(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for performance
CREATE INDEX idx_external_data_sources_type ON external_data_sources(source_type);
CREATE INDEX idx_data_source_endpoints_source ON data_source_endpoints(source_id);
CREATE INDEX idx_data_source_endpoints_type ON data_source_endpoints(data_type);
CREATE INDEX idx_import_jobs_source ON import_jobs(source_id);
CREATE INDEX idx_import_jobs_status ON import_jobs(status);
CREATE INDEX idx_import_jobs_created ON import_jobs(created_at);
CREATE INDEX idx_staging_external_data_job ON staging_external_data(import_job_id);
CREATE INDEX idx_staging_external_data_status ON staging_external_data(mapping_status);
CREATE INDEX idx_external_entity_mappings_source ON external_entity_mappings(source_id);
CREATE INDEX idx_external_entity_mappings_external ON external_entity_mappings(source_id, external_id);
CREATE INDEX idx_external_entity_mappings_internal ON external_entity_mappings(internal_table, internal_record_id);
CREATE INDEX idx_import_conflicts_job ON import_conflicts(import_job_id);
CREATE INDEX idx_import_conflicts_status ON import_conflicts(resolution_status);
CREATE INDEX idx_data_sync_history_source ON data_sync_history(source_id);
CREATE INDEX idx_data_sync_history_table ON data_sync_history(table_name, record_id);
CREATE INDEX idx_data_sync_history_created ON data_sync_history(created_at);