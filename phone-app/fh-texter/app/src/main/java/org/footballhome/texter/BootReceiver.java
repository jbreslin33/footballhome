package org.footballhome.texter;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

// After a restart, a paired phone is ready again without being opened.
public class BootReceiver extends BroadcastReceiver {
    @Override public void onReceive(Context context, Intent intent) {
        if (Intent.ACTION_BOOT_COMPLETED.equals(intent.getAction()) && Api.paired(context))
            RelayService.start(context);
    }
}
