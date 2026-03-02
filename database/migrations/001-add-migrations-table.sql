-- Migration 001: Add schema_migrations table
-- This is a no-op on fresh databases (table already exists from 00-schema.sql).
-- On existing databases, it creates the tracking table.

CREATE TABLE IF NOT EXISTS schema_migrations (
    id SERIAL PRIMARY KEY,
    filename VARCHAR(255) NOT NULL UNIQUE,
    applied_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
