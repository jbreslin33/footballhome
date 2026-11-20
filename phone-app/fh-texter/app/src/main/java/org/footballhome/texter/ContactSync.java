package org.footballhome.texter;

import android.Manifest;
import android.content.ContentProviderOperation;
import android.content.ContentResolver;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.net.Uri;
import android.provider.ContactsContract;
import android.provider.ContactsContract.CommonDataKinds.Email;
import android.provider.ContactsContract.CommonDataKinds.Note;
import android.provider.ContactsContract.CommonDataKinds.Organization;
import android.provider.ContactsContract.CommonDataKinds.Phone;
import android.provider.ContactsContract.CommonDataKinds.StructuredName;
import android.provider.ContactsContract.Data;
import android.provider.ContactsContract.PhoneLookup;
import android.provider.ContactsContract.RawContacts;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.Set;

// 👤 Every Football Home contact into the Google account picked on the app
// screen (v1.4, mig 1617).  Owner 11/20: "an app that takes all leads and
// members pickup and regular and adds them to my phone contacts(google)" +
// "i just want all contacts … i dont' think we need to group them".
//
// POST /api/contacts/device/pending hands over the cards that are new or
// changed for this phone; each is written into the Google account (Android
// syncs it up to Google Contacts) and acked, so the next run only gets what
// changed.  A contact this app created is rewritten from the card; one that
// was already on the phone (matched by number or email) only gets the
// numbers / emails / note it lacked — the owner's own edits are never lost.
// Nothing is ever deleted.  Call off the main thread.
final class ContactSync {
    static final String GOOGLE = "com.google";
    private static final int BATCH = 200;
    private static final int MAX_BATCHES = 20;

    private ContactSync() {}

    static boolean hasPermission(Context c) {
        return c.checkSelfPermission(Manifest.permission.WRITE_CONTACTS) == PackageManager.PERMISSION_GRANTED
            && c.checkSelfPermission(Manifest.permission.READ_CONTACTS) == PackageManager.PERMISSION_GRANTED;
    }

    static String account(Context c) { return Api.prefs(c).getString("contacts_account", ""); }

    static boolean ready(Context c) { return hasPermission(c) && !account(c).isEmpty() && Api.paired(c); }

    // One run: pull every changed card (in batches), write, ack.  Returns
    // how many were written, or -1 when it could not run.
    static synchronized int run(Context c) {
        if (!ready(c)) return -1;
        SharedPreferences p = Api.prefs(c);
        String acct = account(c);
        int written = 0;
        try {
            for (int i = 0; i < MAX_BATCHES; i++) {
                JSONObject ask = new JSONObject().put("limit", BATCH).put("first", i == 0);
                Api.Result r = Api.postUrl(c, Api.ROOT + "/contacts/device/pending", ask);
                if (!r.ok()) { p.edit().putString("contacts_trouble", r.error()).apply(); return written > 0 ? written : -1; }
                JSONArray cards = r.body.optJSONArray("contacts");
                if (cards == null || cards.length() == 0) break;
                JSONArray done = new JSONArray();
                for (int k = 0; k < cards.length(); k++) {
                    JSONObject card = cards.getJSONObject(k);
                    try {
                        write(c, acct, card);
                        done.put(new JSONObject().put("uid", card.getString("uid")).put("fp", card.getString("fp")));
                        written++;
                    } catch (Exception e) {
                        p.edit().putString("contacts_trouble", "couldn't save " + card.optString("first") + ": " + e.getMessage()).apply();
                    }
                }
                Api.postUrl(c, Api.ROOT + "/contacts/device/ack", new JSONObject().put("done", done));
                if (r.body.optInt("remaining", 0) <= 0) break;
            }
            p.edit().putLong("contacts_last_at", System.currentTimeMillis()).remove("contacts_trouble").apply();
            if (written > 0) p.edit().putInt("contacts_written", p.getInt("contacts_written", 0) + written).apply();
            return written;
        } catch (Exception e) {
            p.edit().putString("contacts_trouble", e.getMessage() == null ? "error" : e.getMessage()).apply();
            return written > 0 ? written : -1;
        }
    }

    // ── one card ──────────────────────────────────────────────────────────
    private static void write(Context c, String acct, JSONObject card) throws Exception {
        ContentResolver cr = c.getContentResolver();
        SharedPreferences p = Api.prefs(c);
        String uid = card.getString("uid");
        long raw = p.getLong("c:" + uid, -1);
        boolean ours = p.getBoolean("o:" + uid, false);
        if (raw > 0 && !alive(cr, raw)) { raw = -1; ours = false; }
        if (raw <= 0) {
            raw = adopt(cr, acct, card);           // already on the phone?
            ours = false;
        }
        ArrayList<ContentProviderOperation> ops = new ArrayList<>();
        if (raw <= 0) {
            ops.add(ContentProviderOperation.newInsert(RawContacts.CONTENT_URI)
                    .withValue(RawContacts.ACCOUNT_TYPE, GOOGLE)
                    .withValue(RawContacts.ACCOUNT_NAME, acct).build());
            addRows(ops, -1, card, null, null, true);
            android.content.ContentProviderResult[] res = cr.applyBatch(ContactsContract.AUTHORITY, ops);
            long id = Long.parseLong(res[0].uri.getLastPathSegment());
            p.edit().putLong("c:" + uid, id).putBoolean("o:" + uid, true).apply();
            return;
        }
        if (ours) {
            // Ours: the card is the truth — replace what we wrote.
            String sel = Data.RAW_CONTACT_ID + "=? AND " + Data.MIMETYPE + " IN (?,?,?,?,?)";
            ops.add(ContentProviderOperation.newDelete(Data.CONTENT_URI)
                    .withSelection(sel, new String[]{String.valueOf(raw), StructuredName.CONTENT_ITEM_TYPE,
                            Phone.CONTENT_ITEM_TYPE, Email.CONTENT_ITEM_TYPE, Organization.CONTENT_ITEM_TYPE,
                            Note.CONTENT_ITEM_TYPE}).build());
            addRows(ops, raw, card, null, null, true);
        } else {
            // Theirs: only what it lacks.
            addRows(ops, raw, card, values(cr, raw, Phone.CONTENT_ITEM_TYPE, Phone.NORMALIZED_NUMBER, Phone.NUMBER),
                    values(cr, raw, Email.CONTENT_ITEM_TYPE, Email.ADDRESS, null), false);
            if (values(cr, raw, Note.CONTENT_ITEM_TYPE, Note.NOTE, null).isEmpty() && !card.optString("note").isEmpty())
                ops.add(row(raw).withValue(Data.MIMETYPE, Note.CONTENT_ITEM_TYPE).withValue(Note.NOTE, card.optString("note")).build());
        }
        if (!ops.isEmpty()) cr.applyBatch(ContactsContract.AUTHORITY, ops);
        p.edit().putLong("c:" + uid, raw).putBoolean("o:" + uid, ours).apply();
    }

    // full = name / org / note too (a contact we own); else just the
    // numbers and emails not already there.
    private static void addRows(ArrayList<ContentProviderOperation> ops, long raw, JSONObject card,
                                Set<String> havePhones, Set<String> haveEmails, boolean full) throws Exception {
        if (full) {
            ops.add(row(raw).withValue(Data.MIMETYPE, StructuredName.CONTENT_ITEM_TYPE)
                    .withValue(StructuredName.GIVEN_NAME, card.optString("first"))
                    .withValue(StructuredName.FAMILY_NAME, card.optString("last")).build());
            String org = card.optString("org"), title = card.optString("title");
            if (!org.isEmpty() || !title.isEmpty())
                ops.add(row(raw).withValue(Data.MIMETYPE, Organization.CONTENT_ITEM_TYPE)
                        .withValue(Organization.COMPANY, org).withValue(Organization.TITLE, title).build());
            if (!card.optString("note").isEmpty())
                ops.add(row(raw).withValue(Data.MIMETYPE, Note.CONTENT_ITEM_TYPE).withValue(Note.NOTE, card.optString("note")).build());
        }
        JSONArray phones = card.optJSONArray("phones");
        for (int i = 0; phones != null && i < phones.length(); i++) {
            String n = phones.getString(i);
            if (havePhones != null && (havePhones.contains(n) || havePhones.contains(digits(n)))) continue;
            ops.add(row(raw).withValue(Data.MIMETYPE, Phone.CONTENT_ITEM_TYPE)
                    .withValue(Phone.NUMBER, n).withValue(Phone.TYPE, Phone.TYPE_MOBILE).build());
        }
        JSONArray emails = card.optJSONArray("emails");
        for (int i = 0; emails != null && i < emails.length(); i++) {
            String e = emails.getString(i);
            if (haveEmails != null && haveEmails.contains(e.toLowerCase())) continue;
            ops.add(row(raw).withValue(Data.MIMETYPE, Email.CONTENT_ITEM_TYPE)
                    .withValue(Email.ADDRESS, e).withValue(Email.TYPE, Email.TYPE_OTHER).build());
        }
    }

    // A data row for an existing raw contact, or for the one inserted first in this batch.
    private static ContentProviderOperation.Builder row(long raw) {
        ContentProviderOperation.Builder b = ContentProviderOperation.newInsert(Data.CONTENT_URI);
        return raw > 0 ? b.withValue(Data.RAW_CONTACT_ID, raw) : b.withValueBackReference(Data.RAW_CONTACT_ID, 0);
    }

    private static boolean alive(ContentResolver cr, long raw) {
        try (Cursor q = cr.query(RawContacts.CONTENT_URI, new String[]{RawContacts._ID},
                RawContacts._ID + "=? AND " + RawContacts.DELETED + "=0", new String[]{String.valueOf(raw)}, null)) {
            return q != null && q.moveToFirst();
        }
    }

    // The raw contact in this Google account that already has one of the
    // card's numbers or emails (a reinstall, or someone saved by hand).
    private static long adopt(ContentResolver cr, String acct, JSONObject card) throws Exception {
        Set<Long> contacts = new HashSet<>();
        JSONArray phones = card.optJSONArray("phones");
        for (int i = 0; phones != null && i < phones.length(); i++) {
            Uri u = Uri.withAppendedPath(PhoneLookup.CONTENT_FILTER_URI, Uri.encode(phones.getString(i)));
            try (Cursor q = cr.query(u, new String[]{PhoneLookup._ID}, null, null, null)) {
                while (q != null && q.moveToNext()) contacts.add(q.getLong(0));
            }
        }
        JSONArray emails = card.optJSONArray("emails");
        for (int i = 0; emails != null && i < emails.length(); i++) {
            try (Cursor q = cr.query(Data.CONTENT_URI, new String[]{Data.CONTACT_ID},
                    Data.MIMETYPE + "=? AND lower(" + Email.ADDRESS + ")=?",
                    new String[]{Email.CONTENT_ITEM_TYPE, emails.getString(i).toLowerCase()}, null)) {
                while (q != null && q.moveToNext()) contacts.add(q.getLong(0));
            }
        }
        for (long contactId : contacts) {
            try (Cursor q = cr.query(RawContacts.CONTENT_URI, new String[]{RawContacts._ID},
                    RawContacts.CONTACT_ID + "=? AND " + RawContacts.ACCOUNT_TYPE + "=? AND "
                            + RawContacts.ACCOUNT_NAME + "=? AND " + RawContacts.DELETED + "=0",
                    new String[]{String.valueOf(contactId), GOOGLE, acct}, null)) {
                if (q != null && q.moveToFirst()) return q.getLong(0);
            }
        }
        return -1;
    }

    private static Set<String> values(ContentResolver cr, long raw, String mime, String col, String col2) {
        Set<String> out = new HashSet<>();
        String[] cols = col2 == null ? new String[]{col} : new String[]{col, col2};
        try (Cursor q = cr.query(Data.CONTENT_URI, cols, Data.RAW_CONTACT_ID + "=? AND " + Data.MIMETYPE + "=?",
                new String[]{String.valueOf(raw), mime}, null)) {
            while (q != null && q.moveToNext()) {
                for (int i = 0; i < cols.length; i++) {
                    String v = q.getString(i);
                    if (v == null) continue;
                    out.add(mime.equals(Email.CONTENT_ITEM_TYPE) ? v.toLowerCase() : v);
                    if (mime.equals(Phone.CONTENT_ITEM_TYPE)) out.add(digits(v));
                }
            }
        }
        return out;
    }

    private static String digits(String n) {
        String d = n.replaceAll("[^0-9]", "");
        return d.length() == 11 && d.startsWith("1") ? d.substring(1) : d;
    }
}
