-- 042-leagueapps-person-aliases.sql
-- Manual alias mapping for external provider names (starting with LeagueApps)
-- to a canonical person_id in Footballhome.
CREATE TABLE IF NOT EXISTS external_person_aliases (
    id SERIAL PRIMARY KEY,
    provider TEXT NOT NULL,
    alias_first_name TEXT NOT NULL,
    alias_last_name TEXT NOT NULL,
    person_id INTEGER NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_external_person_aliases_provider_name
        UNIQUE (provider, alias_first_name, alias_last_name)
);

CREATE INDEX IF NOT EXISTS idx_external_person_aliases_provider_name_lookup
    ON external_person_aliases (provider, lower(btrim(alias_first_name)), lower(btrim(alias_last_name)));

CREATE INDEX IF NOT EXISTS idx_external_person_aliases_person
    ON external_person_aliases (person_id);

COMMENT ON TABLE external_person_aliases IS
'Manual alias map from external provider name strings to canonical persons.id';

COMMENT ON COLUMN external_person_aliases.provider IS
'External source key (e.g. leagueapps, groupme)';
