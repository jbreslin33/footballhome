-- 616 (2026-10-20) — Call-downs: APSL → CASA, capped at 2 per game.
--
-- Owner: "the rule for apsl/casa is that you can send 2 players down from
-- apsl to casa games. so we need an invite from apsl to casa right? just
-- like call ups we need a call down?"
--
-- The invite machinery already offers the call-down: on a Liga 1 (CASA)
-- game, fh_event_invite_candidates' adult branch lists every player on
-- another active men's team who is not on a tagged team — an APSL-only
-- player (Sheldon Rhoden, Armando Pena) is a 🎟 candidate there today.
-- What was missing is the LEAGUE RULE: at most 2 sent down per game.
-- That cap is a DB row here, enforced by the invite endpoint; invites,
-- Going-folds-into-lineup, magic links and reminders all ride the
-- existing fh_event_invites flow unchanged.

CREATE TABLE IF NOT EXISTS team_invite_caps (
    id            serial PRIMARY KEY,
    to_team_id    int NOT NULL REFERENCES teams(id),
    from_team_id  int NOT NULL REFERENCES teams(id),
    max_per_event int NOT NULL CHECK (max_per_event >= 0),
    note          text,
    created_at    timestamptz NOT NULL DEFAULT now(),
    UNIQUE (to_team_id, from_team_id)
);
COMMENT ON TABLE team_invite_caps IS
  'mig 616: league limits on invites by roster of origin — at most max_per_event open invites on a to_team game for people rostered on from_team (APSL/CASA: 2 down per game).';

-- Liga 1 (120) games may carry at most 2 invitees rostered on APSL (35).
INSERT INTO team_invite_caps (to_team_id, from_team_id, max_per_event, note)
VALUES (120, 35, 2, 'APSL/CASA league rule: at most 2 players sent down from APSL to a CASA game')
ON CONFLICT (to_team_id, from_team_id) DO NOTHING;
