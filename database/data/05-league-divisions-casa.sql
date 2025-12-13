-- ========================================
-- CASA DIVISIONS
-- ========================================
-- Generated: 2025-12-13T19:55:59.068Z
-- Source: CASA Website
-- ========================================

INSERT INTO league_divisions (id, conference_id, name, display_name, slug, tier, is_active)
VALUES ('ad505cc1-202e-47be-8bb1-27f0f42857cf', '782605fe-f106-4307-8e6b-34bdb5c6df87', 'Liga 1', 'Liga 1', 'liga-1', 1, true)
ON CONFLICT (id) DO NOTHING;
INSERT INTO league_divisions (id, conference_id, name, display_name, slug, tier, is_active)
VALUES ('2ec1c004-1dc2-4384-8679-4de64e9add18', '782605fe-f106-4307-8e6b-34bdb5c6df87', 'Liga 2', 'Liga 2', 'liga-2', 2, true)
ON CONFLICT (id) DO NOTHING;
