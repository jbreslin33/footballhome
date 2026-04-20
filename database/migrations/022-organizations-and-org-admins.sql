-- Migration 022: Create organizations and organization_admins tables
-- These tables exist in the schema definition but were missing from the running DB.
-- Uses UUID primary keys to match the existing DB schema style.

CREATE TABLE IF NOT EXISTS organizations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL UNIQUE,
    short_name VARCHAR(50),
    website_url TEXT,
    logo_url TEXT,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE organizations IS 'Universal top-level entities (governing bodies, league operators, club owners)';

CREATE TABLE IF NOT EXISTS organization_admins (
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    admin_id UUID NOT NULL REFERENCES admins(id) ON DELETE CASCADE,
    started_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ended_at TIMESTAMP,
    admin_role VARCHAR(50),
    is_primary BOOLEAN DEFAULT false,
    CHECK (ended_at IS NULL OR ended_at > started_at),
    PRIMARY KEY (organization_id, admin_id, started_at)
);

CREATE INDEX IF NOT EXISTS idx_organization_admins_organization ON organization_admins(organization_id);
CREATE INDEX IF NOT EXISTS idx_organization_admins_admin ON organization_admins(admin_id);
CREATE INDEX IF NOT EXISTS idx_organization_admins_current ON organization_admins(organization_id, admin_id) WHERE ended_at IS NULL;

COMMENT ON TABLE organization_admins IS 'Admins assigned to organizations (Lighthouse 1893, etc.)';
