-- 726 (2026-10-26) — A draft can go to several contacts at once.  Owner:
-- "we need an email in the league section ... that includes both teams
-- emails (all of them) and commissioner, explaining the situation" (our
-- U12 Boys double-booked Sun Nov 1, at KSC and at RUSC).
--
-- contact_email_drafts.contact_id stays the contact whose 📝 Draft it lives
-- under (the league director); everyone it goes To is a row here, that
-- contact included.  Send = one Gmail compose to all of them, a
-- club_contact_messages row each (mig 724).

CREATE TABLE IF NOT EXISTS contact_email_draft_recipients (
    draft_id   BIGINT NOT NULL REFERENCES contact_email_drafts(id) ON DELETE CASCADE,
    contact_id INT    NOT NULL REFERENCES club_contacts(id) ON DELETE CASCADE,
    PRIMARY KEY (draft_id, contact_id)
);
CREATE INDEX IF NOT EXISTS contact_email_draft_recipients_contact_idx ON contact_email_draft_recipients (contact_id);
COMMENT ON TABLE contact_email_draft_recipients IS 'mig 726: who a contact_email_drafts row goes To (its own contact_id included).';

INSERT INTO contact_email_draft_recipients (draft_id, contact_id)
SELECT d.id, d.contact_id FROM contact_email_drafts d
ON CONFLICT DO NOTHING;
