-- 541 (2026-10-07) — #contacts: the club's people into the operator's phone.
-- Owner: "a contacts page where i can click a button and get an import of
-- all contacts into my phone that are members or leads etc." / "if
-- someone was imported already it would ignore them?"
--
-- The page builds one vCard file (.vcf) the phone imports in one go.
-- Phones do not de-duplicate a vCard import, so the server keeps its own
-- log: contact_exports records each contact an operator exported with a
-- fingerprint of its numbers and emails.  The button defaults to "new
-- since your last export"; a contact whose numbers or emails changed since
-- shows as "changed"; "everything" is there for a fresh phone.  Nothing
-- about the contacts themselves is stored here — the groups are read live
-- (board teams, parents, coaches, club staff, leads, opponent contacts).
CREATE TABLE IF NOT EXISTS contact_exports (
    id                  BIGSERIAL PRIMARY KEY,
    exported_by_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    kind                TEXT NOT NULL CHECK (kind IN ('person', 'lead', 'club_contact')),
    ref_id              BIGINT NOT NULL,
    fingerprint         TEXT NOT NULL,          -- md5 of the numbers + emails exported
    exported_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS contact_exports_user_ref_idx ON contact_exports (exported_by_user_id, kind, ref_id, exported_at DESC);
COMMENT ON TABLE contact_exports IS 'Who each operator has already exported to their phone from #contacts (mig 541), with a fingerprint of the numbers/emails at the time.';

CREATE OR REPLACE FUNCTION pg_temp.set_tpl(p_tier text, p_label text, p_body text, p_sort int)
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
  UPDATE message_templates SET body = p_body, label = p_label, sort_order = p_sort, is_active = true, updated_at = now()
   WHERE kind = 'contacts' AND tier = p_tier;
  IF NOT FOUND THEN
    INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
    VALUES ('Contacts', p_label, 'contacts', p_tier, NULL, p_body, p_sort, true, true, false);
  END IF;
END $$;
SELECT pg_temp.set_tpl('tile_title', 'Picker tile — title',       'Contacts', 840);
SELECT pg_temp.set_tpl('tile_sub',   'Picker tile — line under',  'Members, parents, coaches, leads and opponent contacts into your phone in one tap', 841);
SELECT pg_temp.set_tpl('title',      'Page title',                '📇 Contacts', 842);
SELECT pg_temp.set_tpl('subtitle',   'Page subtitle',
  'Pick the groups, tap the button, open the file your phone downloads and choose Add All Contacts. Each card is filed under Lighthouse 1893 with the person''s role and team in the note. The page remembers what you have exported, so the default is only people new to your phone; phones do not merge a second import themselves.', 843);
SELECT pg_temp.set_tpl('group_members',   'Group — adult players',        'Members', 844);
SELECT pg_temp.set_tpl('group_parents',   'Group — parents of youth',     'Parents', 845);
SELECT pg_temp.set_tpl('group_coaches',   'Group — coaches',              'Coaches', 846);
SELECT pg_temp.set_tpl('group_staff',     'Group — club staff',           'Staff', 847);
SELECT pg_temp.set_tpl('group_leads',     'Group — leads',                'Leads', 848);
SELECT pg_temp.set_tpl('group_opponents', 'Group — opponent contacts',    'Opponents', 849);
SELECT pg_temp.set_tpl('scope_new',       'Scope pill — new',             'New since my last export', 850);
SELECT pg_temp.set_tpl('scope_changed',   'Scope pill — changed',         'Changed since', 851);
SELECT pg_temp.set_tpl('scope_all',       'Scope pill — everything',      'Everything', 852);
SELECT pg_temp.set_tpl('button',          'Export button ({n})',          '📲 Add {n} to my phone', 853);
SELECT pg_temp.set_tpl('button_none',     'Export button — nothing',      'Nothing to add', 854);
SELECT pg_temp.set_tpl('count_line',      'Line under pills ({new} {changed} {all})', '{new} new · {changed} changed · {all} in all', 855);
SELECT pg_temp.set_tpl('done',            'After an export ({n})',        'Downloaded {n} contacts — open the file and tap Add All Contacts.', 856);
SELECT pg_temp.set_tpl('last_export',     'Last export line ({when} {n})', 'Last export {when}, {n} contacts.', 857);
SELECT pg_temp.set_tpl('never',           'No export yet',                'Nothing exported from this login yet.', 858);
SELECT pg_temp.set_tpl('note_member',     'vCard note — member ({teams})',   'Member · {teams}', 859);
SELECT pg_temp.set_tpl('note_parent',     'vCard note — parent ({kids})',    'Parent of {kids}', 860);
SELECT pg_temp.set_tpl('note_coach',      'vCard note — coach ({teams})',    'Coach · {teams}', 861);
SELECT pg_temp.set_tpl('note_staff',      'vCard note — staff',              'Club staff', 862);
SELECT pg_temp.set_tpl('note_lead',       'vCard note — lead ({since})',     'Lead since {since}', 863);
SELECT pg_temp.set_tpl('note_opponent',   'vCard note — opponent ({club} {role})', '{club} · {role}', 864);
SELECT pg_temp.set_tpl('org',             'vCard organisation',           'Lighthouse 1893 SC', 865);
SELECT pg_temp.set_tpl('filename',        'Downloaded file name',         'lighthouse-1893-contacts.vcf', 866);
