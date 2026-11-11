-- 1256 (2026-11-11) — #apsl-pyramid proposal map: both borders drawn alike.
-- Owner: "i need them same colors i can't see them" / "same colors as each
-- other" / "it will be obvious the one closer is the traffic one right?".
-- The straight-distance border is now drawn exactly like the traffic one
-- (two-tone, the two conferences' colours, solid); the traffic line is the
-- one nearer New York.  The ☰ key says so.
UPDATE message_templates
   SET body = 'Two lines in the same colours: the one nearer New York is halfway between city centres with traffic (New York ×1.25), the other is straight distance. Shaded between: neutral zone.',
       updated_at = now()
 WHERE kind = 'apsl_pyramid' AND tier = 'proposal_lines';
