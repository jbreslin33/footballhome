package org.footballhome.texter;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ServiceInfo;
import android.os.Build;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.IBinder;
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

    private HandlerThread thread;
    private Handler handler;
    private volatile boolean running;

    static void start(Context c) {
        Intent i = new Intent(c, RelayService.class);
        if (Build.VERSION.SDK_INT >= 26) c.startForegroundService(i); else c.startService(i);
    }

    static void stop(Context c) { c.stopService(new Intent(c, RelayService.class)); }

    @Override public IBinder onBind(Intent intent) { return null; }

    @Override public int onStartCommand(Intent intent, int flags, int startId) {
        Notification n = notification("Ready — sends what you click Send on in Football Home");
        if (Build.VERSION.SDK_INT >= 29) startForeground(NOTIFY_ID, n, ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC);
        else startForeground(NOTIFY_ID, n);
        if (!running) {
            running = true;
            thread = new HandlerThread("fh-texter");
            thread.start();
            handler = new Handler(thread.getLooper());
            handler.post(this::poll);
        }
        return START_STICKY;
    }

    @Override public void onDestroy() {
        running = false;
        if (thread != null) thread.quitSafely();
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
            JSONObject text = r.ok() ? r.body.optJSONObject("text") : null;
            if (text != null) send(text.getLong("id"), text.getString("to"), text.getString("body"));
        } catch (Exception e) {
            update("Problem: " + e.getMessage());
        }
        if (running) handler.postDelayed(this::poll, POLL_MS);
    }

    // Long texts go as one multipart SMS; the last part's sent / delivered
    // result stands for the whole text.
    private void send(long id, String to, String body) {
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
            update("Sent a text " + java.text.DateFormat.getTimeInstance(java.text.DateFormat.SHORT).format(new java.util.Date()));
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
