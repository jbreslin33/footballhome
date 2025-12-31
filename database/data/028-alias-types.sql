-- Alias-types - Foundation Data
-- This file contains core/foundational data for alias-types that always loads.
-- Defines the types of name variations/aliases that can be associated with teams.

INSERT INTO alias_types (name, description) VALUES
    ('abbreviation', 'Short form or acronym (e.g., "Man U" for Manchester United)'),
    ('nickname', 'Informal or popular name used by fans or media'),
    ('historical', 'Former official name from previous seasons or eras'),
    ('alternate_spelling', 'Different spelling variation or transliteration'),
    ('translation', 'Official name in different language or locale'),
    ('short_name', 'Shortened version of the official name');
