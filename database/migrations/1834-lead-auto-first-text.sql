-- 1834 (2026-11-24) — 🎯 A new lead is texted straight away from the owner's phone.
-- Owner: "wait can we just have the fh texter text the lead right away? lol" · "leads should
-- immediately go into my contacts suing fh assisteatn and then we make the fh text".
--
-- The order, for each new ad lead (docs/lead-auto-text.md):
--   1. the phone is told a lead's contact is waiting (/api/phone-relay/device/next answers
--      contacts_now: true) and FH Assistant 1.7 syncs contacts at once, not at its 15 minutes;
--   2. once the phone has saved the lead's card (phone_contact_sync 'fh-lead-<id>') — or after
--      contact_wait_seconds, for an older app — the first-touch text is queued on FH Texter
--      under its own guardrails (daily cap, gap, STOP, 30-minute expiry);
--   3. when the phone reports it sent, a lead_contacts row (text / first-touch) is logged, so
--      the lead leaves the 🚦 New leads band.  A text that fails or expires leaves the lead on
--      the band for a person to handle.
-- Never: a lead from before this migration, one already contacted, a duplicate of a number
-- texted in the last 30 days, a number already on a club member, a STOPped number, a form
-- with no program wording, or between quiet_from and quiet_until (those wait for morning).
-- The forms ask no preferred method of contact (name, email, phone, best time), so every lead
-- with a mobile gets the text.

-- Which funnel a lead form belongs to — until now only a map inside leads.js (formLabel).
-- The server needs it to pick the program wording; leads.js still carries its copy.
CREATE TABLE IF NOT EXISTS lead_form_funnels (
    form_id text PRIMARY KEY,
    label   text NOT NULL
);
INSERT INTO lead_form_funnels (form_id, label) VALUES
    ('1668570657681917', 'PR Men'),
    ('2062202517690808', 'PR Men'),
    ('875990184755538', 'U23 Women'),
    ('1696381158350766', 'U23 Women'),
    ('1552835789741946', 'Brazil Men'),
    ('1333581472007910', 'Brazil Men'),
    ('1052472267432735', 'U23 Men'),
    ('1773598717166962', 'APSL / Liga 1'),
    ('3249608418562710', 'Youth (Grades 1–6)'),
    ('1704106777282059', 'Boys Club (Grades 1–6)'),
    ('1571742281184926', 'Girls Club (Grades 1–6)'),
    ('2471488896628970', 'Boys Club (Grades 1–6)'),
    ('1277787647463515', 'Youth (Grades 1–6)'),
    ('1008195014960429', 'Girls Club (Grades 1–6)'),
    ('1813864682814937', 'Club-Wide (All Programs)'),
    ('27218140947855660', 'Boys Club (K-12)'),
    ('3904012603227821', 'Girls Club (K-12)'),
    ('821845431008120', 'Men''s Club'),
    ('3929429224026650', 'Women''s Club'),
    ('1057769040350305', 'Women''s Club'),
    ('966641426206505', 'Boys Club (U11/U12)'),
    ('1666471931283440', 'Girls Club (U11/U12)'),
    ('1452427476902521', 'APSL Trials'),
    ('829329860110560', 'LIGA 1 Trials'),
    ('1063284936304533', 'APSL Trials'),
    ('1742374770183944', 'Youth (Grades 1–6)'),
    ('1765217041432039', 'Youth (Grades K–9)'),
    ('1112525488303663', 'Men''s Club'),
    ('1140646368374686', 'Women''s Club'),
    ('1104907468985240', 'Youth (Grades K–9)'),
    ('2156338988574123', 'Men''s Club'),
    ('1105264069085795', 'Women''s Club')
ON CONFLICT (form_id) DO NOTHING;

CREATE TABLE IF NOT EXISTS lead_auto_text_policy (
    id                   integer PRIMARY KEY DEFAULT 1 CHECK (id = 1),
    is_on                boolean NOT NULL DEFAULT true,
    sender_person_id     integer NOT NULL REFERENCES persons(id),   -- whose phone sends, and whose name signs
    quiet_from           time    NOT NULL DEFAULT '21:00',          -- America/New_York: nothing queued from here …
    quiet_until          time    NOT NULL DEFAULT '08:00',          -- … until here
    contact_wait_seconds integer NOT NULL DEFAULT 1200,             -- send anyway if the phone has not saved the contact by then
    started_at           timestamptz NOT NULL DEFAULT now(),        -- only leads that arrive after this
    note                 text
);
INSERT INTO lead_auto_text_policy (id, sender_person_id, note)
VALUES (1, 1, 'owner 2026-11-24: text a new lead right away, after the contact is on the phone')
ON CONFLICT (id) DO NOTHING;

CREATE TABLE IF NOT EXISTS lead_auto_text_states (
    code  text PRIMARY KEY,
    label text NOT NULL
);
INSERT INTO lead_auto_text_states (code, label) VALUES
    ('waiting', 'Waiting for the contact to reach the phone'),
    ('queued',  'Text queued on the phone'),
    ('sent',    'Text sent'),
    ('failed',  'Text failed or expired — contact by hand'),
    ('skipped', 'Not texted automatically')
ON CONFLICT (code) DO NOTHING;

CREATE TABLE IF NOT EXISTS lead_auto_texts (
    lead_id       integer PRIMARY KEY REFERENCES leads(id) ON DELETE CASCADE,
    state         text NOT NULL REFERENCES lead_auto_text_states(code),
    reason        text,
    body          text,
    relay_text_id bigint REFERENCES phone_relay_texts(id) ON DELETE SET NULL,
    created_at    timestamptz NOT NULL DEFAULT now(),
    queued_at     timestamptz,
    done_at       timestamptz
);
CREATE INDEX IF NOT EXISTS lead_auto_texts_open_idx ON lead_auto_texts (state) WHERE state IN ('waiting', 'queued');

-- The first-touch text for one lead, in the words the 📇 Contact popup uses
-- (message_templates lead_first_sms + lead_program).  NULL = no automatic text.
CREATE OR REPLACE FUNCTION fh_lead_first_text(p_lead_id integer, p_sender_person_id integer) RETURNS text
LANGUAGE plpgsql STABLE AS $$
DECLARE
    v_lead   leads%ROWTYPE;
    v_label  text;
    v_want   text;
    v_prog   text;
    v_body   text;
    v_first  text;
    v_sender text;
BEGIN
    SELECT * INTO v_lead FROM leads WHERE id = p_lead_id;
    IF NOT FOUND THEN RETURN NULL; END IF;
    SELECT label INTO v_label FROM lead_form_funnels WHERE form_id = v_lead.form_id;
    IF v_label IS NULL THEN RETURN NULL; END IF;
    -- The club-wide form pools every program; the lead's own answer says which (leads.js programInterestLabel).
    IF v_label = 'Club-Wide (All Programs)' THEN
        SELECT lower(f->'values'->>0) INTO v_want
          FROM jsonb_array_elements(CASE WHEN jsonb_typeof(v_lead.raw_fields) = 'array' THEN v_lead.raw_fields ELSE '[]'::jsonb END) f
         WHERE f->>'name' = 'program_interest' LIMIT 1;
        v_label := CASE WHEN v_want LIKE '%boys%' AND v_want LIKE '%girls%' THEN 'Youth (Grades 1–6)'
                        WHEN v_want LIKE '%boys%'  THEN 'Boys Club (Grades 1–6)'
                        WHEN v_want LIKE '%girls%' THEN 'Girls Club (Grades 1–6)'
                        WHEN v_want LIKE '%women%' THEN 'Women''s Club'
                        WHEN v_want LIKE '%men%'   THEN 'Men''s Club' END;
        IF v_label IS NULL THEN RETURN NULL; END IF;
    END IF;
    SELECT body INTO v_prog FROM message_templates
     WHERE kind = 'lead_program' AND tier = v_label AND is_active ORDER BY sort_order, id LIMIT 1;
    SELECT body INTO v_body FROM message_templates
     WHERE kind = 'lead_first_sms' AND tier IN (v_label, 'all') AND is_active ORDER BY (tier = 'all'), sort_order, id LIMIT 1;
    v_first := initcap(split_part(btrim(COALESCE(v_lead.name, '')), ' ', 1));
    SELECT btrim(COALESCE(first_name, '') || ' ' || COALESCE(last_name, '')) INTO v_sender FROM persons WHERE id = p_sender_person_id;
    IF COALESCE(v_prog, '') = '' OR COALESCE(v_body, '') = '' OR v_first = '' OR COALESCE(v_sender, '') = '' THEN RETURN NULL; END IF;
    v_body := replace(replace(replace(v_body, '{first}', v_first), '{coachFirst}', v_sender), '{program}', v_prog);
    IF v_body LIKE '%{%' THEN RETURN NULL; END IF;   -- a token this function does not know: leave it to a person
    RETURN v_body;
END $$;

-- One step, run each time the sender's phone checks in (every 6 s): enrol new leads, queue
-- the texts whose contact is on the phone, log the ones that went.  TRUE = a lead's contact
-- is still to reach this phone (the app syncs contacts now).
CREATE OR REPLACE FUNCTION fh_lead_auto_text_step(p_device_id integer) RETURNS boolean
LANGUAGE plpgsql AS $$
DECLARE
    v_pol    lead_auto_text_policy%ROWTYPE;
    v_relay  phone_relay_policy%ROWTYPE;
    v_user   integer;
    v_now    time := (now() AT TIME ZONE 'America/New_York')::time;
    v_quiet  boolean;
    v_today  integer;
    r        record;
    v_text   bigint;
BEGIN
    SELECT * INTO v_pol FROM lead_auto_text_policy WHERE id = 1;
    IF NOT FOUND OR NOT v_pol.is_on THEN RETURN false; END IF;
    IF NOT EXISTS (SELECT 1 FROM phone_relay_devices d WHERE d.id = p_device_id AND d.person_id = v_pol.sender_person_id AND d.revoked_at IS NULL) THEN
        RETURN false;
    END IF;
    SELECT * INTO v_relay FROM phone_relay_policy LIMIT 1;
    SELECT id INTO v_user FROM users WHERE person_id = v_pol.sender_person_id ORDER BY id LIMIT 1;

    -- 1. New leads → waiting, or skipped with the reason.
    INSERT INTO lead_auto_texts (lead_id, state, reason, body)
    SELECT l.id,
           CASE WHEN x.why IS NULL THEN 'waiting' ELSE 'skipped' END, x.why,
           CASE WHEN x.why IS NULL THEN x.body END
      FROM leads l
      CROSS JOIN LATERAL (SELECT right(regexp_replace(COALESCE(l.phone, ''), '[^0-9]', '', 'g'), 10) AS digits) d
      CROSS JOIN LATERAL (SELECT fh_lead_first_text(l.id, v_pol.sender_person_id) AS body) b
      CROSS JOIN LATERAL (SELECT CASE
               WHEN length(d.digits) <> 10 THEN 'no mobile number'
               WHEN EXISTS (SELECT 1 FROM sms_opt_outs o WHERE o.phone_digits = d.digits
                               AND NOT EXISTS (SELECT 1 FROM sms_opt_ins i WHERE i.phone_digits = d.digits AND i.consented_at > o.received_at))
                    THEN 'they replied STOP'
               WHEN EXISTS (SELECT 1 FROM person_phones pp WHERE right(regexp_replace(COALESCE(pp.phone_number, ''), '[^0-9]', '', 'g'), 10) = d.digits)
                    THEN 'the number is already on someone in the club'
               WHEN EXISTS (SELECT 1 FROM leads o JOIN lead_contacts c ON c.lead_id = o.id
                             WHERE o.id <> l.id AND c.channel = 'text' AND c.sent_at > (now() AT TIME ZONE 'UTC') - interval '30 days'
                               AND right(regexp_replace(COALESCE(o.phone, ''), '[^0-9]', '', 'g'), 10) = d.digits)
                    THEN 'this number was texted in the last 30 days'
               WHEN EXISTS (SELECT 1 FROM leads o JOIN lead_auto_texts a ON a.lead_id = o.id
                             WHERE o.id <> l.id AND a.state IN ('waiting', 'queued', 'sent')
                               AND right(regexp_replace(COALESCE(o.phone, ''), '[^0-9]', '', 'g'), 10) = d.digits)
                    THEN 'another lead with this number is already being texted'
               WHEN b.body IS NULL THEN 'no first-touch wording for this form'
             END AS why, b.body) x
     WHERE l.created_at > v_pol.started_at
       AND l.dead_at IS NULL AND l.converted_at IS NULL
       AND EXISTS (SELECT 1 FROM lead_form_funnels f WHERE f.form_id = l.form_id)
       AND NOT EXISTS (SELECT 1 FROM lead_contacts c WHERE c.lead_id = l.id)
       AND NOT EXISTS (SELECT 1 FROM lead_auto_texts a WHERE a.lead_id = l.id)
    ON CONFLICT (lead_id) DO NOTHING;

    -- 2. Someone got there first, or the lead is closed: stand down.
    UPDATE lead_auto_texts a SET state = 'skipped', reason = 'contacted by hand first', done_at = now()
     WHERE a.state = 'waiting'
       AND (EXISTS (SELECT 1 FROM lead_contacts c WHERE c.lead_id = a.lead_id)
            OR EXISTS (SELECT 1 FROM leads l WHERE l.id = a.lead_id AND (l.dead_at IS NOT NULL OR l.converted_at IS NOT NULL)));

    -- 2b. One text per number: the same person on two forms (or twice on one) is texted once.
    UPDATE lead_auto_texts a SET state = 'skipped', reason = 'another lead with this number is already being texted', done_at = now()
      FROM leads l
     WHERE a.state = 'waiting' AND l.id = a.lead_id
       AND EXISTS (SELECT 1 FROM lead_auto_texts o JOIN leads ol ON ol.id = o.lead_id
                    WHERE o.lead_id <> a.lead_id
                      AND (o.state IN ('queued', 'sent') OR (o.state = 'waiting' AND o.lead_id < a.lead_id))
                      AND right(regexp_replace(COALESCE(ol.phone, ''), '[^0-9]', '', 'g'), 10)
                        = right(regexp_replace(COALESCE(l.phone, ''), '[^0-9]', '', 'g'), 10));

    -- 3. Queue the ones whose contact is on this phone (or that waited long enough) — not at night.
    v_quiet := CASE WHEN v_pol.quiet_from > v_pol.quiet_until THEN v_now >= v_pol.quiet_from OR v_now < v_pol.quiet_until
                    ELSE v_now >= v_pol.quiet_from AND v_now < v_pol.quiet_until END;
    IF NOT v_quiet THEN
        PERFORM pg_advisory_xact_lock(667, v_pol.sender_person_id);   -- the relay's own lock: cap and gap cannot race
        FOR r IN
            SELECT a.lead_id, a.body, l.phone FROM lead_auto_texts a JOIN leads l ON l.id = a.lead_id
             WHERE a.state = 'waiting'
               AND (EXISTS (SELECT 1 FROM phone_contact_sync s WHERE s.device_id = p_device_id AND s.uid = 'fh-lead-' || a.lead_id)
                    OR a.created_at < now() - make_interval(secs => v_pol.contact_wait_seconds))
             ORDER BY a.created_at
        LOOP
            SELECT count(*) INTO v_today FROM phone_relay_texts t
             WHERE t.sender_person_id = v_pol.sender_person_id AND t.status <> 'expired'
               AND (t.created_at AT TIME ZONE 'America/New_York')::date = (now() AT TIME ZONE 'America/New_York')::date;
            EXIT WHEN v_today >= v_relay.daily_cap;   -- stays waiting; tomorrow, or by hand from the band
            INSERT INTO phone_relay_texts (device_id, sender_person_id, to_phone, body, purpose, not_before)
            VALUES (p_device_id, v_pol.sender_person_id,
                    '+1' || right(regexp_replace(r.phone, '[^0-9]', '', 'g'), 10), r.body, 'lead_auto:' || r.lead_id,
                    GREATEST(now(), COALESCE((SELECT max(t.not_before) FROM phone_relay_texts t WHERE t.device_id = p_device_id
                                                AND t.status IN ('queued', 'sending', 'sent', 'delivered')), now() - interval '1 day')
                                    + make_interval(secs => v_relay.min_gap_seconds)))
            RETURNING id INTO v_text;
            UPDATE lead_auto_texts SET state = 'queued', relay_text_id = v_text, queued_at = now() WHERE lead_id = r.lead_id;
        END LOOP;
    END IF;

    -- 4. What the phone reported: sent → the touch is logged (the lead leaves the band); failed / expired → by hand.
    FOR r IN
        SELECT a.lead_id, a.body, t.status FROM lead_auto_texts a JOIN phone_relay_texts t ON t.id = a.relay_text_id
         WHERE a.state = 'queued' AND t.status IN ('sent', 'delivered', 'failed', 'expired')
    LOOP
        IF r.status IN ('sent', 'delivered') THEN
            INSERT INTO lead_contacts (lead_id, channel, contacted_by, message_body, status, template)
            VALUES (r.lead_id, 'text', v_user, r.body, 'sent', 'first-touch');
            UPDATE lead_auto_texts SET state = 'sent', done_at = now() WHERE lead_id = r.lead_id;
        ELSE
            UPDATE lead_auto_texts SET state = 'failed', reason = 'the phone did not send it (' || r.status || ')', done_at = now() WHERE lead_id = r.lead_id;
        END IF;
    END LOOP;
    UPDATE lead_auto_texts SET state = 'failed', reason = 'the queued text is gone', done_at = now() WHERE state = 'queued' AND relay_text_id IS NULL;

    RETURN EXISTS (SELECT 1 FROM lead_auto_texts a WHERE a.state = 'waiting'
                      AND NOT EXISTS (SELECT 1 FROM phone_contact_sync s WHERE s.device_id = p_device_id AND s.uid = 'fh-lead-' || a.lead_id));
END $$;
