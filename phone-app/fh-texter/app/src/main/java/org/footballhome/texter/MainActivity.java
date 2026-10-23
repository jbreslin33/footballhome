package org.footballhome.texter;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.graphics.Typeface;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.PowerManager;
import android.provider.Settings;
import android.text.InputFilter;
import android.text.InputType;
import android.view.Gravity;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;

import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

// The one screen: permissions, the pairing code from Football Home, and
// whether the phone is ready.  After pairing nobody needs to open it.
public class MainActivity extends Activity {
    private TextView status;
    private EditText code;
    private Button pair, battery, unpair;

    @Override protected void onCreate(Bundle saved) {
        super.onCreate(saved);
        int pad = dp(20);
        LinearLayout col = new LinearLayout(this);
        col.setOrientation(LinearLayout.VERTICAL);
        col.setPadding(pad, pad, pad, pad);

        TextView title = new TextView(this);
        title.setText("FH Texter");
        title.setTextSize(26);
        title.setTypeface(Typeface.DEFAULT_BOLD);
        col.addView(title);

        TextView about = new TextView(this);
        about.setText("Sends the texts you click Send on in Football Home, from this phone's number. "
                + "It never sends anything on its own. Keep this phone on and online.");
        about.setPadding(0, dp(6), 0, dp(14));
        col.addView(about);

        status = new TextView(this);
        status.setTextSize(17);
        status.setTypeface(Typeface.DEFAULT_BOLD);
        status.setPadding(0, 0, 0, dp(14));
        col.addView(status);

        code = new EditText(this);
        code.setHint("Code from Football Home (8 characters)");
        code.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_FLAG_CAP_CHARACTERS);
        code.setFilters(new InputFilter[]{new InputFilter.AllCaps(), new InputFilter.LengthFilter(9)});
        code.setTextSize(22);
        code.setGravity(Gravity.CENTER);
        col.addView(code);

        pair = button("Pair with Football Home", "#0284C7");
        pair.setOnClickListener(v -> doPair());
        col.addView(pair);

        battery = button("Let FH Texter run in the background", "#334155");
        battery.setOnClickListener(v -> askBattery());
        col.addView(battery);

        unpair = button("Unpair this phone", "#7F1D1D");
        unpair.setOnClickListener(v -> {
            RelayService.stop(this);
            Api.forget(this);
            refresh();
        });
        col.addView(unpair);

        ScrollView scroll = new ScrollView(this);
        scroll.addView(col);
        setContentView(scroll);
        askPermissions();
    }

    @Override protected void onResume() {
        super.onResume();
        refresh();
        if (Api.paired(this) && hasSms()) RelayService.start(this);
    }

    private void refresh() {
        boolean paired = Api.paired(this);
        if (!hasSms()) {
            status.setText("⚠ Allow \"Send SMS\" so it can send your texts.");
            status.setTextColor(Color.parseColor("#B45309"));
        } else if (paired) {
            String who = Api.prefs(this).getString("first_name", "");
            status.setText("✓ Ready" + (who.isEmpty() ? "" : " — paired to " + who) + ". You can close this app.");
            status.setTextColor(Color.parseColor("#15803D"));
        } else {
            status.setText("Not paired yet. On the computer, open Football Home → a text → Set up FH Texter, then type the code here.");
            status.setTextColor(Color.parseColor("#B45309"));
        }
        code.setVisibility(paired ? android.view.View.GONE : android.view.View.VISIBLE);
        pair.setVisibility(paired ? android.view.View.GONE : android.view.View.VISIBLE);
        unpair.setVisibility(paired ? android.view.View.VISIBLE : android.view.View.GONE);
        PowerManager pm = getSystemService(PowerManager.class);
        boolean free = pm != null && pm.isIgnoringBatteryOptimizations(getPackageName());
        battery.setVisibility(free ? android.view.View.GONE : android.view.View.VISIBLE);
    }

    private void doPair() {
        String c = code.getText().toString().replaceAll("[^A-Za-z0-9]", "").toUpperCase();
        if (c.length() != 8) { status.setText("The code is 8 letters and numbers."); return; }
        pair.setEnabled(false);
        status.setText("Pairing…");
        new Thread(() -> {
            String msg;
            boolean ok = false;
            try {
                JSONObject b = new JSONObject().put("code", c)
                        .put("name", Build.MANUFACTURER + " " + Build.MODEL).put("app_version", Api.VERSION);
                Api.Result r = Api.post(this, "/device/pair", b);
                if (r.ok()) {
                    Api.prefs(this).edit().putString("token", r.body.getString("token"))
                            .putString("first_name", r.body.optString("first_name", "")).apply();
                    ok = true;
                    msg = "";
                } else msg = r.error();
            } catch (Exception e) { msg = e.getMessage(); }
            final boolean done = ok;
            final String m = msg;
            runOnUiThread(() -> {
                pair.setEnabled(true);
                if (done) { RelayService.start(this); refresh(); }
                else status.setText("Couldn't pair: " + m);
            });
        }).start();
    }

    private void askPermissions() {
        List<String> want = new ArrayList<>();
        if (!hasSms()) want.add(Manifest.permission.SEND_SMS);
        if (Build.VERSION.SDK_INT >= 33 && checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED)
            want.add(Manifest.permission.POST_NOTIFICATIONS);
        if (!want.isEmpty()) requestPermissions(want.toArray(new String[0]), 1);
    }

    @Override public void onRequestPermissionsResult(int req, String[] perms, int[] results) {
        refresh();
        if (Api.paired(this) && hasSms()) RelayService.start(this);
    }

    // Without this, Android may pause the app while the phone sleeps and
    // texts would wait until you pick it up.
    private void askBattery() {
        Intent i = new Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS, Uri.parse("package:" + getPackageName()));
        try { startActivity(i); } catch (Exception e) { startActivity(new Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS)); }
    }

    private boolean hasSms() {
        return checkSelfPermission(Manifest.permission.SEND_SMS) == PackageManager.PERMISSION_GRANTED;
    }

    private Button button(String text, String color) {
        Button b = new Button(this);
        b.setText(text);
        b.setAllCaps(false);
        b.setTextColor(Color.WHITE);
        b.setBackgroundColor(Color.parseColor(color));
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, dp(52));
        lp.topMargin = dp(10);
        b.setLayoutParams(lp);
        return b;
    }

    private int dp(int v) { return Math.round(v * getResources().getDisplayMetrics().density); }
}
