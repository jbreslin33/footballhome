# 🎯 A new lead is texted straight away (mig 1834)

Owner, 2026-11-24: "wait can we just have the fh texter text the lead right away? lol" ·
"leads should immediately go into my contacts suing fh assisteatn and then we make the fh text".

## The order

1. A lead arrives from an ad form (`leads`).
2. The owner's phone checks in (`POST /api/phone-relay/device/next`, every 6 s). Each check-in
   runs `fh_lead_auto_text_step(device)`, which enrols the lead in `lead_auto_texts`
   (`waiting`) with its first-touch text already written, and the reply carries
   `contacts_now: true`.
3. FH Assistant 1.7 syncs contacts at once on `contacts_now` (older apps: at their next
   15 minutes). The lead's card is acked into `phone_contact_sync` as `fh-lead-<id>`.
4. The next check-in queues the text on FH Texter (`phone_relay_texts`, purpose
   `lead_auto:<lead id>`) under the relay's own guardrails — daily cap, gap between texts,
   30-minute expiry. If the contact never arrives, the text goes anyway after
   `contact_wait_seconds` (20 minutes).
5. The phone reports it sent → a `lead_contacts` row (text / `first-touch`) is logged, so
   the lead leaves the 🚦 New leads band. Failed or expired → state `failed`; the lead stays
   on the band for a person.

## Who is not texted (state `skipped`, with the reason)

A lead from before the feature (`lead_auto_text_policy.started_at`), one already contacted,
no mobile, a STOPped number, a number already on someone in the club, a number texted in the
last 30 days or shared with a lead already being texted, a form with no funnel
(`lead_form_funnels`) or no program wording. Nothing is queued between `quiet_from` and
`quiet_until` (9 PM – 8 AM Eastern): those wait for morning.

The ad forms ask no preferred method of contact (name, email, phone, best time), so every
lead with a mobile gets the text.

## The words

`fh_lead_first_text(lead, sender)` = `message_templates` `lead_first_sms` with `{first}`,
`{coachFirst}` (the sender's name) and `{program}` (`lead_program`, tier = the form's funnel
label; the club-wide form reads the lead's `program_interest` answer). Same words as the
📇 Contact popup's Touch 1 text. An unknown token → no automatic text.

## Switches (rows, changed by migration)

`lead_auto_text_policy`: `is_on`, `sender_person_id`, `quiet_from` / `quiet_until`,
`contact_wait_seconds`, `started_at`. Off = `UPDATE lead_auto_text_policy SET is_on = false`.

## Owed

`lead_form_funnels` duplicates the form → funnel map inside `frontend/js/screens/leads.js`
(`formLabel`). A new lead form needs a row here too, until leads.js reads the table.
