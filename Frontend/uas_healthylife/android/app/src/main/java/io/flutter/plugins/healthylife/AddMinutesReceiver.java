import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

public class AddMinutesReceiver extends BroadcastReceiver {
    private static final String TAG = "AddMinutesReceiver";

    @Override
    public void onReceive(Context context, Intent intent) {
        String action = intent.getAction();
        if (action != null && action.equals("android.intent.action.BOOT_COMPLETED")) {
            // Penjadwalan ulang alarm di sini setelah boot perangkat
            Log.d(TAG, "Device booted. Rescheduling alarms if needed.");
            // Di sini tambahkan logika untuk menetapkan ulang alarm jika diperlukan setelah boot
        } else if (action != null && action.equals("your_custom_action_for_alarm")) {
            // Menangani aksi alarm disini
            Log.d(TAG, "Received alarm action: " + action);
            // Di sini tambahkan logika untuk menangani aksi alarm yang diterima
        } else {
            // Aksi tidak dikenali
            Log.d(TAG, "Unknown action received: " + action);
        }
    }
}
