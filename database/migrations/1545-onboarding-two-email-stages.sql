-- 1545 (2026-11-19) — 🎓 two email stages (owner 11/19 "the first
-- submission is the clearances then yineska the hr lh person has them do
-- financials so we need to do like 2 email stages. lets focus to get them
-- past clearance steps and email then be ready to do the finance one").
--
--   onboarding_stages            per stage: who its ✉️ email goes to.
--                                volunteer (clearances) → the compliance
--                                director; paid (W-9, direct deposit) → HR
--                                (Yineska) — address not known yet, so the
--                                finance button says so until it is set.
--   person_onboarding_stage_sends  the last send per person per stage.
--
-- Also the words for the walk-through in the volunteer's popup (one step
-- at a time, "👉 Your next step") and the page's per-stage buttons.

CREATE TABLE IF NOT EXISTS onboarding_stages (
    stage          text PRIMARY KEY CHECK (stage IN ('volunteer', 'paid')),
    email_to       text,
    email_to_name  text NOT NULL DEFAULT '',
    sort_order     int  NOT NULL DEFAULT 0
);
INSERT INTO onboarding_stages (stage, email_to, email_to_name, sort_order) VALUES
  ('volunteer', (SELECT compliance_email FROM onboarding_policy WHERE id = 1), 'Compliance Director', 1),
  ('paid',      NULL, 'Yineska (HR)', 2)
ON CONFLICT (stage) DO NOTHING;

CREATE TABLE IF NOT EXISTS person_onboarding_stage_sends (
    person_id   integer NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
    stage       text    NOT NULL REFERENCES onboarding_stages(stage),
    emailed_at  timestamptz NOT NULL DEFAULT now(),
    emailed_by  integer REFERENCES users(id) ON DELETE SET NULL,
    PRIMARY KEY (person_id, stage)
);

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Onboarding', v.label, 'onboarding', v.tier, v.subject, v.body, v.sort_order, true, true, false
  FROM (VALUES
    ('Page — send clearances', 'act_send_volunteer', NULL, '✉️ Send clearances to compliance', 70),
    ('Page — send finance',    'act_send_paid',      NULL, '✉️ Send finance to HR', 71),
    ('Page — stage ready',     'stage_ready',        NULL, '🟢 Ready to send', 72),
    ('Page — finance no email', 'paid_no_email',     NULL, 'HR email not set yet', 73),
    ('Page — sent line stage', 'sent_line_stage',    NULL, '✉️ {stage} sent {when}', 74),
    ('Popup — next step',      'next_step',          NULL, '👉 Your next step', 75),
    ('Popup — later steps',    'later_steps',        NULL, 'Then', 76),
    ('Popup — tap to open',    'tap_open',           NULL, 'Open ›', 77),
    ('Popup — stage 1 done',   'volunteer_done',     NULL, '🎉 Clearances done! The club checks them and sends them to compliance. You''re cleared once they''re ✅.', 78),
    ('Popup — stage 2 done',   'paid_done',          NULL, '🎉 Pay paperwork done! The club sends it to HR.', 79),
    ('Email to HR (finance)',  'email_paid',         'Finance paperwork — {name}',
     'Hi {to_name},

Finance paperwork for {name}, who is copied on this email.

{list}

Thanks!', 80)
  ) AS v(label, tier, subject, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'onboarding' AND m.tier = v.tier);

-- The clearances email reads as clearances.
UPDATE message_templates SET subject = 'Clearances — {name}',
       body = 'Hi,

Clearances for {name} ({track}), who is copied on this email.

{list}

Thanks!', updated_at = now()
 WHERE kind = 'onboarding' AND tier = 'email_compliance';
