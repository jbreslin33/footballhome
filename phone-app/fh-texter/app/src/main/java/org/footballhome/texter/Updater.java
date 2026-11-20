package org.footballhome.texter;

import android.app.Activity;
import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageInstaller;
import android.net.Uri;
import android.os.Build;
import android.provider.Settings;

import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;

// ⬆ One-tap updates (v1.5, mig 1619).  Owner 11/20: "can't we just have fh
// assistant in fuutre just do updates to itself or just click update lol".
// Android never lets a sideloaded app replace itself silently, so: the
// check-in says a newer build exists → "Update available" notification /
// button → this downloads the APK into a PackageInstaller session and
// Android shows its own Install screen.  Install keeps the pairing.
final class Updater {
    static final int NOTIFY_ID = 2;

    private Updater() {}

    static long myCode(Context c) {
        try {
            android.content.pm.PackageInfo pi = c.getPackageManager().getPackageInfo(c.getPackageName(), 0);
            return Build.VERSION.SDK_INT >= 28 ? pi.getLongVersionCode() : pi.versionCode;
        } catch (Exception e) { return 0; }
    }

    static boolean available(Context c) { return Api.prefs(c).getLong("update_code", 0) > myCode(c); }

    static String name(Context c) { return Api.prefs(c).getString("update_name", ""); }

    // From the check-in: remember it and say so once per version.
    static void offered(Context c, long code, String name, String url) {
        if (code <= myCode(c)) return;
        android.content.SharedPreferences p = Api.prefs(c);
        boolean fresh = p.getLong("update_code", 0) != code;
        p.edit().putLong("update_code", code).putString("update_name", name).putString("update_url", url).apply();
        if (!fresh) return;
        NotificationManager nm = c.getSystemService(NotificationManager.class);
        if (nm == null) return;
        PendingIntent open = PendingIntent.getActivity(c, 2,
                new Intent(c, MainActivity.class).putExtra("update", true).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
                PendingIntent.FLAG_IMMUTABLE | PendingIntent.FLAG_UPDATE_CURRENT);
        Notification.Builder b = Build.VERSION.SDK_INT >= 26 ? new Notification.Builder(c, RelayService.CHANNEL) : new Notification.Builder(c);
        nm.notify(NOTIFY_ID, b.setSmallIcon(R.drawable.ic_texter)
                .setContentTitle("FH Assistant " + name + " is ready")
                .setContentText("Tap to update — your pairing stays.")
                .setAutoCancel(true)
                .setContentIntent(open)
                .build());
    }

    // The Update button.  Returns a line for the screen.
    static String start(Activity a) {
        String url = Api.prefs(a).getString("update_url", "");
        if (url.isEmpty() || !available(a)) return "You're on the latest version.";
        if (Build.VERSION.SDK_INT >= 26 && !a.getPackageManager().canRequestPackageInstalls()) {
            try {
                a.startActivity(new Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES, Uri.parse("package:" + a.getPackageName())));
            } catch (Exception ignored) {}
            return "Allow \"Install unknown apps\" for FH Assistant (one time), then tap Update again.";
        }
        new Thread(() -> {
            String err = install(a, url);
            if (err != null) Api.prefs(a).edit().putString("update_trouble", err).apply();
        }).start();
        return "Downloading " + name(a) + "… Android will ask you to Install.";
    }

    private static String install(Context c, String url) {
        HttpURLConnection conn = null;
        try {
            PackageInstaller pi = c.getPackageManager().getPackageInstaller();
            PackageInstaller.SessionParams params = new PackageInstaller.SessionParams(PackageInstaller.SessionParams.MODE_FULL_INSTALL);
            params.setAppPackageName(c.getPackageName());
            int id = pi.createSession(params);
            try (PackageInstaller.Session s = pi.openSession(id)) {
                conn = (HttpURLConnection) new URL(url).openConnection();
                conn.setConnectTimeout(15000);
                conn.setReadTimeout(60000);
                if (conn.getResponseCode() != 200) return "download failed (HTTP " + conn.getResponseCode() + ")";
                try (InputStream in = conn.getInputStream(); OutputStream out = s.openWrite("fh-assistant", 0, -1)) {
                    byte[] buf = new byte[65536];
                    int n;
                    while ((n = in.read(buf)) > 0) out.write(buf, 0, n);
                    s.fsync(out);
                }
                int flags = PendingIntent.FLAG_UPDATE_CURRENT | (Build.VERSION.SDK_INT >= 31 ? PendingIntent.FLAG_MUTABLE : 0);
                PendingIntent done = PendingIntent.getBroadcast(c, id, new Intent(c, Result.class), flags);
                s.commit(done.getIntentSender());
            }
            return null;
        } catch (Exception e) {
            return "update failed: " + e.getMessage();
        } finally {
            if (conn != null) conn.disconnect();
        }
    }

    // Android's answer: show its Install screen, or why it failed.
    public static class Result extends BroadcastReceiver {
        @Override public void onReceive(Context c, Intent i) {
            int status = i.getIntExtra(PackageInstaller.EXTRA_STATUS, PackageInstaller.STATUS_FAILURE);
            if (status == PackageInstaller.STATUS_PENDING_USER_ACTION) {
                Intent confirm = i.getParcelableExtra(Intent.EXTRA_INTENT);
                if (confirm != null) {
                    confirm.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                    try { c.startActivity(confirm); } catch (Exception e) {
                        Api.prefs(c).edit().putString("update_trouble", "couldn't open the installer: " + e.getMessage()).apply();
                    }
                }
            } else if (status != PackageInstaller.STATUS_SUCCESS) {
                String msg = i.getStringExtra(PackageInstaller.EXTRA_STATUS_MESSAGE);
                Api.prefs(c).edit().putString("update_trouble", "Android said: " + (msg == null ? "failed" : msg)
                        + " — if Samsung Auto Blocker is on, turn it off and tap Update again.").apply();
            }
        }
    }
}
