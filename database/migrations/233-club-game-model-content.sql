-- 233-club-game-model-content.sql (2026-07-20)
-- Store club-specific game model content for the admin club screen.

BEGIN;

CREATE TABLE IF NOT EXISTS club_game_model_content (
    id bigserial PRIMARY KEY,
    club_id integer NOT NULL REFERENCES clubs(id) ON DELETE CASCADE,
    content_html text NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (club_id)
);

CREATE INDEX IF NOT EXISTS idx_club_game_model_content_club_id
    ON club_game_model_content (club_id, updated_at DESC);

INSERT INTO club_game_model_content (club_id, content_html)
SELECT c.id, '<article style="background: var(--bg-primary); border: 1px solid var(--border-color); border-radius: var(--radius-md); padding: var(--space-3);"><h4 style="margin: 0 0 var(--space-2) 0;">Weekly session plan</h4><div style="display: grid; gap: 0.75rem;"><div style="opacity: 0.8;">The club game model is now stored in the database and can be updated without rebuilding the frontend.</div><div style="background: rgba(59,130,246,0.08); border: 1px solid rgba(59,130,246,0.25); border-radius: var(--radius-md); padding: 0.7rem;"><strong>Tuesday — Base build</strong><div style="opacity: 0.8; margin-top: 0.25rem;">7:15–7:25 arrival + movement prep, 7:25–7:45 build from the back, 7:50–8:10 midfield overloads, 8:15–8:40 final-third finish.</div></div></div></article>'
FROM clubs c
ON CONFLICT (club_id) DO NOTHING;

COMMIT;
