-- 077-lead-contacts-template-backfill.sql
--
-- Backfill lead_contacts.template for rows logged BEFORE the frontend
-- started stamping data-template on every button (which arrives with
-- the "Close / More Info / Call / Text" button expansion — see leads.js
-- renderLead + onContactClick).
--
-- Column was added in migration 072-lead-contacts-template.sql but was
-- never populated: the C++ writer accepted a `template` field in the
-- POST body from day one, but the frontend never sent one until this
-- change.  As of writing there are ~729 email rows and ~89 text rows
-- with template=NULL — that breaks the new "Last: 📨 close · 1h ago"
-- badge on the leads screen since we can't tell WHICH template drove
-- the most-recent touch.
--
-- Classification is best-effort — we match message_body substrings
-- that uniquely identify each template.  Ambiguous rows stay NULL
-- (renders as "—" in the badge, which is honest).  Idempotent: only
-- updates rows where template IS NULL, so re-running is a no-op.

BEGIN;

-- First-touch emails (touch-1 outreach).  Two template variants seen
-- in the wild:
--   "Coach James here with Lighthouse 1893 SC …"      (earlier)
--   "James Breslin here, Soccer Director at Lighthouse 1893 SC …"  (later)
-- Both open with a "thanks for filling out our interest form" hook and
-- close with the qualifying question "Are you looking to join …?".
UPDATE lead_contacts SET template = 'first-touch'
 WHERE template IS NULL
   AND channel   = 'email'
   AND (message_body LIKE '%Coach James here with Lighthouse%'
     OR message_body LIKE '%James Breslin here, Soccer Director at Lighthouse%'
     OR message_body LIKE '%Are you looking to join our%');

-- More-info emails (touch-2 info-dump).  Signature: enumerated details
-- list ("Here are the details:") followed by field address, cost, and
-- the register CTA.  The `Lighthouse Sports Complex` fingerprint is
-- unique to this snippet on the email channel (broadcasts use it too
-- but they don't hit lead_contacts).
UPDATE lead_contacts SET template = 'more-info'
 WHERE template IS NULL
   AND channel   = 'email'
   AND (message_body LIKE '%Here are the details:%'
     OR message_body LIKE '%That''s great that you%'
     OR message_body LIKE '%Lighthouse Sports Complex%');

-- First-touch texts (touch-1 SMS).  Three body variants observed:
--   "Are you looking to join our program this season?"     (original)
--   "Perfect — what level have you played at most recently?" (qualifier)
--   "Hi X, this is Coach James w/ Lighthouse 1893 — thanks for
--    your interest in our …"                                (main variant)
--   "Hi X, Coach James w/ Lighthouse 1893 — want to play for our …"
UPDATE lead_contacts SET template = 'first-touch'
 WHERE template IS NULL
   AND channel   = 'text'
   AND (message_body LIKE '%Are you looking to join%'
     OR message_body LIKE 'Perfect —%'
     OR message_body LIKE 'Perfect%what level%'
     OR message_body LIKE '%Coach James w/ Lighthouse 1893%'
     OR message_body LIKE '%thanks for your interest%');

-- Close texts (response to YES on touch-1 qualifier).  Coach's habitual
-- opener when a lead says "yes I want to play" over SMS starts with
-- "Great." followed by a register link or membership CTA.
UPDATE lead_contacts SET template = 'close'
 WHERE template IS NULL
   AND channel   = 'text'
   AND (message_body LIKE 'Great. To register%'
     OR message_body LIKE 'Great. To become a member%'
     OR message_body LIKE '%To register your son%'
     OR message_body LIKE '%To register your daughter%'
     OR message_body LIKE '%$1 registration%');

COMMIT;

-- Diagnostic — how many rows still lack a template.  Cast this to
-- STDOUT with `\i 077-lead-contacts-template-backfill.sql` in psql
-- to see the residual NULL count after the update.
SELECT channel,
       COUNT(*) FILTER (WHERE template IS NULL)     AS still_null,
       COUNT(*) FILTER (WHERE template IS NOT NULL) AS filled,
       COUNT(*)                                     AS total
  FROM lead_contacts
 GROUP BY channel
 ORDER BY channel;
