package org.footballhome.texter;

import android.content.Context;
import android.content.SharedPreferences;

import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;

// Football Home's /api/phone-relay/device/* (mig 667).  The phone's token
// comes from pairing and is the only credential the app holds; it lives
// in this app's private preferences.  Call off the main thread.
final class Api {
    static final String BASE = "https://footballhome.org/api/phone-relay";
    static final String VERSION = "1.1";
    private static final String PREFS = "fh_texter";

    static final class Result {
        final int status;
        final JSONObject body;
        Result(int status, JSONObject body) { this.status = status; this.body = body; }
        boolean ok() { return status >= 200 && status < 300; }
        String error() { return body != null ? body.optString("error", "HTTP " + status) : "HTTP " + status; }
    }

    private Api() {}

    static SharedPreferences prefs(Context c) {
        return c.getSharedPreferences(PREFS, Context.MODE_PRIVATE);
    }

    static String token(Context c) { return prefs(c).getString("token", ""); }

    static boolean paired(Context c) { return !token(c).isEmpty(); }

    static void forget(Context c) { prefs(c).edit().remove("token").remove("first_name").apply(); }

    static Result post(Context c, String path, JSONObject body) {
        HttpURLConnection conn = null;
        try {
            conn = (HttpURLConnection) new URL(BASE + path).openConnection();
            conn.setRequestMethod("POST");
            conn.setConnectTimeout(10000);
            conn.setReadTimeout(15000);
            conn.setDoOutput(true);
            conn.setRequestProperty("Content-Type", "application/json");
            String token = token(c);
            if (!token.isEmpty()) conn.setRequestProperty("X-FH-Device", token);
            try (OutputStream out = conn.getOutputStream()) {
                out.write(body.toString().getBytes(StandardCharsets.UTF_8));
            }
            int status = conn.getResponseCode();
            InputStream in = status >= 400 ? conn.getErrorStream() : conn.getInputStream();
            String text = "";
            if (in != null) {
                ByteArrayOutputStream buf = new ByteArrayOutputStream();
                byte[] chunk = new byte[4096];
                int n;
                while ((n = in.read(chunk)) > 0) buf.write(chunk, 0, n);
                in.close();
                text = buf.toString("UTF-8");
            }
            JSONObject json = text.isEmpty() ? new JSONObject() : new JSONObject(text);
            return new Result(status, json);
        } catch (Exception e) {
            JSONObject err = new JSONObject();
            try { err.put("error", "no connection: " + e.getMessage()); } catch (Exception ignored) {}
            return new Result(0, err);
        } finally {
            if (conn != null) conn.disconnect();
        }
    }
}
