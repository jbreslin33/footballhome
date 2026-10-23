package org.footballhome.texter;

import android.app.Activity;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.telephony.SmsManager;

import org.json.JSONObject;

// Android's answer for a text this app sent — handed to the SmsManager as
// the sent / delivered intents — reported back to Football Home so the
// coach's screen reads sent ✓ / delivered ✓ / FAILED.
public class SmsResultReceiver extends BroadcastReceiver {
    static PendingIntent intent(Context c, long id, String kind) {
        Intent i = new Intent(c, SmsResultReceiver.class)
                .setAction("org.footballhome.texter." + kind + "." + id)
                .putExtra("id", id).putExtra("kind", kind);
        return PendingIntent.getBroadcast(c, (int) (id * 2 + ("sent".equals(kind) ? 0 : 1)), i,
                PendingIntent.FLAG_IMMUTABLE | PendingIntent.FLAG_UPDATE_CURRENT);
    }

    @Override public void onReceive(Context context, Intent intent) {
        long id = intent.getLongExtra("id", 0);
        String kind = intent.getStringExtra("kind");
        if (id <= 0 || kind == null) return;
        int code = getResultCode();
        String status, error = null;
        if ("delivered".equals(kind)) {
            status = "delivered";
        } else if (code == Activity.RESULT_OK) {
            status = "sent";
        } else {
            status = "failed";
            error = reason(code);
        }
        PendingResult pending = goAsync();
        final String s = status, e = error;
        new Thread(() -> {
            try { report(context, id, s, e); } finally { pending.finish(); }
        }).start();
    }

    static void report(Context c, long id, String status, String error) {
        try {
            JSONObject b = new JSONObject().put("id", id).put("status", status);
            if (error != null) b.put("error", error);
            Api.post(c, "/device/report", b);
        } catch (Exception ignored) {}
    }

    private static String reason(int code) {
        switch (code) {
            case SmsManager.RESULT_ERROR_NO_SERVICE: return "no phone signal";
            case SmsManager.RESULT_ERROR_RADIO_OFF: return "airplane mode is on";
            case SmsManager.RESULT_ERROR_NULL_PDU: return "the carrier refused the message";
            case SmsManager.RESULT_ERROR_GENERIC_FAILURE: return "the carrier didn't take it";
            default: return "error " + code;
        }
    }
}
