-- Welcome outreach (owner 2026-09-06).
--
-- "We need a welcome to Lighthouse email after they sign up ... a button
-- for it ... show on #teams IF it has not been sent yet ... only from
-- this date forward for new players."  Consistent across all four clubs.
--
-- Two pieces, and "due" is never stored — it is derived per card:
--   1. welcome_outreach_policies — the standing rule: memberships whose
--      LeagueApps registration date is on/after registered_on_or_after
--      owe a welcome.  Latest row per club wins; history is kept, so
--      moving the cutoff is an INSERT, never a JS edit or an UPDATE.
--   2. person_welcomes — one row per welcome actually sent.  Keyed on the
--      person who RECEIVES it (the parent for youth, the player for
--      adults), so welcoming a family through one child covers the
--      siblings.  player_person_id records which child the email named.
--
-- A card is "due" when its target person has no person_welcomes row AND
-- the membership's la_registered_at::date >= the policy cutoff.  The
-- button itself stays available forever (owner: "allow ... to send
-- invite always even if already sent but show last send and method").

CREATE TABLE IF NOT EXISTS welcome_outreach_policies (
  id                      serial PRIMARY KEY,
  club_id                 int  NOT NULL REFERENCES clubs(id),
  registered_on_or_after  date NOT NULL,
  created_by_user_id      int  REFERENCES users(id),
  created_at              timestamptz NOT NULL DEFAULT now()
);
COMMENT ON TABLE welcome_outreach_policies IS
  'Standing rule for which memberships owe a welcome message: LA registration date on/after registered_on_or_after. Latest created_at per club wins. Owner 2026-09-06.';

INSERT INTO welcome_outreach_policies (club_id, registered_on_or_after)
SELECT 134, DATE '2026-09-06'
 WHERE NOT EXISTS (SELECT 1 FROM welcome_outreach_policies WHERE club_id = 134);

CREATE TABLE IF NOT EXISTS person_welcomes (
  id                serial PRIMARY KEY,
  person_id         int  NOT NULL REFERENCES persons(id) ON DELETE CASCADE,  -- recipient (parent for youth)
  player_person_id  int  REFERENCES persons(id) ON DELETE SET NULL,          -- the child named, youth only
  channel           text NOT NULL CHECK (channel IN ('sms', 'email')),
  contact           text NOT NULL,                                           -- number / address it went to
  sent_by_user_id   int  REFERENCES users(id) ON DELETE SET NULL,
  sent_at           timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS person_welcomes_person_sent_idx
  ON person_welcomes (person_id, sent_at DESC);
COMMENT ON TABLE person_welcomes IS
  'One row per welcome message a coach sent from a roster card (magic sign-in link inside). Recipient-keyed: the parent for youth, the player for adults.';
