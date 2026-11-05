package org.footballhome.texter;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.content.pm.ServiceInfo;
import android.net.ConnectivityManager;
import android.net.Network;
import android.net.NetworkCapabilities;
import android.net.NetworkInfo;
import android.os.Build;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.IBinder;
import android.os.PowerManager;
import android.telephony.SmsManager;

import org.json.JSONObject;

import java.util.ArrayList;

// Runs while FH Texter is on: checks in with Football Home every few
// seconds and sends the one text it is handed, from this phone's SIM.
// Football Home decides when a text is due (one click, one recipient,
// spaced and capped — phone_relay_policy, mig 667); this only carries it.
public class RelayService extends Service {
    static final String CHANNEL = "fh_texter";
    static final int NOTIFY_ID = 1;
    static final long POLL_MS = 6000;
    // Screen off: a little slower to spare the battery — still well inside
    // the 2 minutes after which Football Home calls the phone offline.
    static final long POLL_ASLEEP_MS = 15000;

    private HandlerThread thread;
    private Handler handler;
    private volatile boolean running;
    // v1.1: without it the CPU sleeps with the screen and check-ins stop
    // (10/24: offline from 4:38 PM with the phone on and the app "Ready").
    private PowerManager.WakeLock wake;
    private Boolean connected;   // last state shown, so the notification changes only when it does

    // v1.2: the app screen's Reconnect button.  11/5 the phone sat on
    // mobile data 7:40–9:21 AM unable to reach Football Home with no way
    // to kick it short of a reboot.
    static final String ACTION_RECONNECT = "org.footballhome.texter.RECONNECT";
    private ConnectivityManager.NetworkCallback netWatch;
    // One poll task, so a kick never starts a second check-in loop.
    private final Runnable pollTask = this::poll;

    static void start(Context c) {
        Intent i = new Intent(c, RelayService.class);
        if (Build.VERSION.SDK_INT >= 26) c.startForegroundService(i); else c.startService(i);
    }

    // Check in right now (and restart the service if Android killed it).
    static void reconnect(Context c) {
        Api.prefs(c).edit().remove("trouble").apply();
        Intent i = new Intent(c, RelayService.class).setAction(ACTION_RECONNECT);
        if (Build.VERSION.SDK_INT >= 26) c.startForegroundService(i); else c.startService(i);
    }

    // Which network the phone is on, and whether Android is keeping this
    // app off it — so "not reaching" says why instead of just "internet?".
    static String network(Context c) {
        ConnectivityManager cm = c.getSystemService(ConnectivityManager.class);
        if (cm == null) return "";
        Network n = cm.getActiveNetwork();
        NetworkCapabilities caps = n == null ? null : cm.getNetworkCapabilities(n);
        if (caps == null) return "No internet on the phone — turn on Wi-Fi or mobile data.";
        boolean wifi = caps.hasTransport(NetworkCapabilities.TRANSPORT_WIFI);
        String on = wifi ? "Wi-Fi" : caps.hasTransport(NetworkCapabilities.TRANSPORT_CELLULAR) ? "mobile data" : "the internet";
        @SuppressWarnings("deprecation")
        NetworkInfo info = cm.getActiveNetworkInfo();
        @SuppressWarnings("deprecation")
        boolean blocked = info != null && info.getDetailedState() == NetworkInfo.DetailedState.BLOCKED;
        if (blocked || (!wifi && cm.getRestrictBackgroundStatus() == ConnectivityManager.RESTRICT_BACKGROUND_STATUS_ENABLED))
            return "On " + on + ", but Android is blocking FH Texter's data. Tap \"Data settings\" → Mobile data → "
                    + "allow background data and allow while Data saver is on.";
        return "On " + on + ".";
    }

    static void stop(Context c) { c.stopService(new Intent(c, RelayService.class)); }

    @Override public IBinder onBind(Intent intent) { return null; }

    @Override public int onStartCommand(Intent intent, int flags, int startId) {
        Notification n = notification("Starting — connecting to Football Home…");
        if (Build.VERSION.SDK_INT >= 29) startForeground(NOTIFY_ID, n, ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC);
        else startForeground(NOTIFY_ID, n);
        if (running && intent != null && ACTION_RECONNECT.equals(intent.getAction())) {
            connected = null;   // say the fresh result either way
            kick();
        }
        if (!running) {
            running = true;
            PowerManager pm = getSystemService(PowerManager.class);
            if (pm != null && wake == null) {
                wake = pm.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "fhtexter:relay");
                wake.setReferenceCounted(false);
                wake.acquire();
            }
            thread = new HandlerThread("fh-texter");
            thread.start();
            handler = new Handler(thread.getLooper());
            handler.post(pollTask);
            watchNetwork();
        }
        return START_STICKY;
    }

    // Poll now instead of waiting out the 6s/15s gap.
    private void kick() {
        if (handler == null) return;
        handler.removeCallbacks(pollTask);
        handler.post(pollTask);
    }

    // Wi-Fi ↔ mobile data, or the internet coming back: check in at once.
    private void watchNetwork() {
        ConnectivityManager cm = getSystemService(ConnectivityManager.class);
        if (cm == null || netWatch != null) return;
        netWatch = new ConnectivityManager.NetworkCallback() {
            @Override public void onAvailable(Network n) { kick(); }
            @Override public void onLost(Network n) { kick(); }
        };
        try { cm.registerDefaultNetworkCallback(netWatch); } catch (Exception e) { netWatch = null; }
    }

    @Override public void onDestroy() {
        running = false;
        ConnectivityManager cm = getSystemService(ConnectivityManager.class);
        if (cm != null && netWatch != null) try { cm.unregisterNetworkCallback(netWatch); } catch (Exception ignored) {}
        netWatch = null;
        if (thread != null) thread.quitSafely();
        if (wake != null && wake.isHeld()) wake.release();
        wake = null;
        super.onDestroy();
    }

    private void poll() {
        if (!running) return;
        try {
            JSONObject hello = new JSONObject().put("app_version", Api.VERSION);
            Api.Result r = Api.post(this, "/device/next", hello);
            if (r.status == 401) {
                // Unpaired from the website (or a bad token): stop asking.
                Api.forget(this);
                update("Not paired — open FH Texter to pair again");
                running = false;
                stopSelf();
                return;
            }
            if (r.ok()) checkedIn(); else trouble(r.error());
            JSONObject text = r.ok() ? r.body.optJSONObject("text") : null;
            if (text != null) send(text.getLong("id"), text.getString("to"), text.getString("body"));
        } catch (Exception e) {
            trouble(e.getMessage());
        }
        PowerManager pm = getSystemService(PowerManager.class);
        boolean awake = pm == null || pm.isInteractive();
        if (running) {
            handler.removeCallbacks(pollTask);
            handler.postDelayed(pollTask, awake ? POLL_MS : POLL_ASLEEP_MS);
        }
    }

    // The app screen reads these to say "on and working" or since when not.
    private void checkedIn() {
        Api.prefs(this).edit().putLong("last_ok_at", System.currentTimeMillis()).remove("trouble").apply();
        if (!Boolean.TRUE.equals(connected)) {
            connected = true;
            update("✅ On — connected to Football Home");
        }
    }

    private void trouble(String why) {
        Api.prefs(this).edit().putString("trouble", why == null ? "no answer" : why).apply();
        if (!Boolean.FALSE.equals(connected)) {
            connected = false;
            long ok = Api.prefs(this).getLong("last_ok_at", 0);
            update("⚠ Can't reach Football Home" + (ok > 0 ? " since " + clock(ok) : "") + " — " + network(this)
                    + " Open FH Texter → Reconnect.");
        }
    }

    static String clock(long millis) {
        return java.text.DateFormat.getTimeInstance(java.text.DateFormat.SHORT).format(new java.util.Date(millis));
    }

    // Long texts go as one multipart SMS; the last part's sent / delivered
    // result stands for the whole text.
    private void send(long id, String to, String body) {
        if (checkSelfPermission(android.Manifest.permission.SEND_SMS) != PackageManager.PERMISSION_GRANTED) {
            // v1.2: say so instead of a bare "could not send" (Android
            // re-locks SMS for sideloaded apps after a reinstall).
            SmsResultReceiver.report(this, id, "failed", "SMS permission is off for FH Texter on the phone — open the app to fix");
            update("⚠ Can't send — open FH Texter and allow SMS");
            return;
        }
        try {
            SmsManager sms = Build.VERSION.SDK_INT >= 31 ? getSystemService(SmsManager.class) : SmsManager.getDefault();
            ArrayList<String> parts = sms.divideMessage(body);
            ArrayList<PendingIntent> sent = new ArrayList<>(), delivered = new ArrayList<>();
            for (int i = 0; i < parts.size(); i++) {
                boolean last = i == parts.size() - 1;
                sent.add(last ? SmsResultReceiver.intent(this, id, "sent") : null);
                delivered.add(last ? SmsResultReceiver.intent(this, id, "delivered") : null);
            }
            sms.sendMultipartTextMessage(to, null, parts, sent, delivered);
            update("✅ On — sent a text " + clock(System.currentTimeMillis()));
        } catch (Exception e) {
            SmsResultReceiver.report(this, id, "failed", "the phone could not send: " + e.getMessage());
        }
    }

    private void update(String line) {
        NotificationManager nm = getSystemService(NotificationManager.class);
        if (nm != null) nm.notify(NOTIFY_ID, notification(line));
    }

    private Notification notification(String line) {
        NotificationManager nm = getSystemService(NotificationManager.class);
        if (Build.VERSION.SDK_INT >= 26 && nm != null && nm.getNotificationChannel(CHANNEL) == null)
            nm.createNotificationChannel(new NotificationChannel(CHANNEL, "FH Texter", NotificationManager.IMPORTANCE_LOW));
        PendingIntent open = PendingIntent.getActivity(this, 0, new Intent(this, MainActivity.class),
                PendingIntent.FLAG_IMMUTABLE | PendingIntent.FLAG_UPDATE_CURRENT);
        Notification.Builder b = Build.VERSION.SDK_INT >= 26 ? new Notification.Builder(this, CHANNEL) : new Notification.Builder(this);
        return b.setSmallIcon(R.drawable.ic_texter)
                .setContentTitle("FH Texter")
                .setContentText(line)
                .setOngoing(true)
                .setContentIntent(open)
                .build();
    }
}
