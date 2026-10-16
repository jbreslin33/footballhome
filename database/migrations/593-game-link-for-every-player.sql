-- 593 (2026-10-16) — A personalized game link for EVERY player on a game,
-- squad role or not.
--
-- Owner: "call ups and ALL PLayers need email and text link personalized
-- to invite to game!"
--
-- The GAME LINK buttons (mig 384) rendered only on Starting / Bench /
-- Alternates because the message names the player's role, and the backend
-- refused anyone outside the squad.  Now every card has the buttons: a
-- player with no role yet (unassigned Going / Not Going / No Response,
-- or an invited call-up) gets these pool tiers instead — same personal
-- magic link straight to the game, no role named, an ask to answer.
-- RsvpBoardController picks tier 'pool_adult' / 'pool_parent' when the
-- person holds no squad zone (RsvpBoard::poolRecipient).

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order)
SELECT 'RSVP', 'Squad notice — personal game invite, no role (adult)', 'squad_notice', 'pool_adult',
       'Lighthouse 1893 — game invite',
E'Hi {first} — you''re wanted for this game:\n{event}\n[[Where: {where}\n]][[Arrive by {arrival}\n]]\nSet Going or Not Going so the coaches can build the lineup — no password needed: {link}\n\n— {sender}, Lighthouse 1893', 60
WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'squad_notice' AND tier = 'pool_adult');

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order)
SELECT 'RSVP', 'Squad notice — personal game invite, no role (parent)', 'squad_notice', 'pool_parent',
       'Lighthouse 1893 — game invite',
E'Hi {first} — {child} is wanted for this game:\n{event}\n[[Where: {where}\n]][[Arrive by {arrival}\n]]\nSet {child}''s availability — Going or Not Going — so the coaches can build the lineup, no password needed: {link}\n\n— {sender}, Lighthouse 1893', 61
WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'squad_notice' AND tier = 'pool_parent');
