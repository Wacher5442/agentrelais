package com.example.agent_relais

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import android.net.Uri
import android.annotation.SuppressLint
import android.os.Build
import android.telecom.TelecomManager
import androidx.annotation.RequiresApi


class MainActivity: FlutterActivity() {
    private val METHOD_CHANNEL = "battery_method_channel"
    private val EVENT_CHANNEL = "battery_event_channel"

    private val USSD_CHANNEL = "ussd_channel"
    private var batteryReceiver: BatteryReceiver? = null

    @RequiresApi(Build.VERSION_CODES.M)
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, USSD_CHANNEL)
        UssdAccessibilityService.methodChannel = channel

        // MethodChannel pour obtenir le niveau instantané
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getBatteryLevel" -> {
                    val batteryLevel = getBatteryLevel()
                    if (batteryLevel != -1) {
                        result.success(batteryLevel)
                    } else {
                        result.error("UNAVAILABLE", "Niveau de batterie non disponible", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        // EventChannel pour surveiller les changements en temps réel
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    startBatteryMonitoring(events)
                }

                override fun onCancel(arguments: Any?) {
                    stopBatteryMonitoring()
                }
            }
        )

        // Nouveau MethodChannel pour USSD
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "executeUssd" -> {
                    val code = call.argument<String>("code")
                    if (code != null) {
                        executeUssd(code, result)
                    } else {
                        result.error("INVALID_CODE", "Code USSD non fourni", null)
                    }
                }
                "hasUssdPermission" -> {
                    result.success(hasUssdPermission())
                }
                else -> result.notImplemented()
            }
        }
    }


    @SuppressLint("NewApi")
    private fun executeUssd(code: String, result: MethodChannel.Result) {
        try {
            val telecomManager = getSystemService(Context.TELECOM_SERVICE) as TelecomManager
            val uri = Uri.fromParts("tel", code, null)

            val bundle = android.os.Bundle().apply {
                putBoolean(TelecomManager.EXTRA_START_CALL_WITH_SPEAKERPHONE, false)
                putBoolean(TelecomManager.EXTRA_START_CALL_WITH_VIDEO_STATE, false)
            }

            telecomManager.placeCall(uri, bundle)
            result.success(true)

        } catch (e: SecurityException) {
            result.error("PERMISSION_DENIED", "Permission CALL_PHONE requise", null)
        } catch (e: Exception) {
            result.error("USSD_FAILED", "Échec USSD: ${e.message}", null)
        }
    }


    @RequiresApi(Build.VERSION_CODES.M)
    private fun hasUssdPermission(): Boolean {
        return checkSelfPermission(android.Manifest.permission.CALL_PHONE) ==
                android.content.pm.PackageManager.PERMISSION_GRANTED
    }

    // Gestion des permissions
    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        // Vous pouvez gérer ici les résultats des permissions
    }


    private fun getBatteryLevel(): Int {
        val batteryManager = applicationContext.getSystemService(Context.BATTERY_SERVICE) as BatteryManager
        return batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
    }

    private fun startBatteryMonitoring(events: EventChannel.EventSink?) {
        batteryReceiver = BatteryReceiver(events)
        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_BATTERY_CHANGED)
            addAction(Intent.ACTION_BATTERY_LOW)
            addAction(Intent.ACTION_BATTERY_OKAY)
            addAction(Intent.ACTION_POWER_CONNECTED)
            addAction(Intent.ACTION_POWER_DISCONNECTED)
        }
        applicationContext.registerReceiver(batteryReceiver, filter)
    }

    private fun stopBatteryMonitoring() {
        batteryReceiver?.let {
            applicationContext.unregisterReceiver(it)
            batteryReceiver = null
        }
    }

    inner class BatteryReceiver(private val events: EventChannel.EventSink?) : android.content.BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            when (intent?.action) {
                Intent.ACTION_BATTERY_CHANGED -> {
                    val level = intent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1)
                    val scale = intent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
                    val batteryPct = if (level != -1 && scale != -1) {
                        (level * 100 / scale.toFloat()).toInt()
                    } else -1

                    val status = intent.getIntExtra(BatteryManager.EXTRA_STATUS, -1)
                    val isCharging = status == BatteryManager.BATTERY_STATUS_CHARGING ||
                            status == BatteryManager.BATTERY_STATUS_FULL

                    val plugType = intent.getIntExtra(BatteryManager.EXTRA_PLUGGED, -1)
                    val chargeSource = when (plugType) {
                        BatteryManager.BATTERY_PLUGGED_AC -> "AC"
                        BatteryManager.BATTERY_PLUGGED_USB -> "USB"
                        BatteryManager.BATTERY_PLUGGED_WIRELESS -> "Wireless"
                        else -> "None"
                    }

                    val data = mapOf(
                        "level" to batteryPct,
                        "isCharging" to isCharging,
                        "chargeSource" to chargeSource,
                        "eventType" to "batteryChanged"
                    )
                    events?.success(data)
                }

                Intent.ACTION_BATTERY_LOW -> {
                    events?.success(mapOf("eventType" to "batteryLow"))
                }

                Intent.ACTION_BATTERY_OKAY -> {
                    events?.success(mapOf("eventType" to "batteryOkay"))
                }

                Intent.ACTION_POWER_CONNECTED -> {
                    events?.success(mapOf("eventType" to "powerConnected"))
                }

                Intent.ACTION_POWER_DISCONNECTED -> {
                    events?.success(mapOf("eventType" to "powerDisconnected"))
                }
            }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        stopBatteryMonitoring()
    }
}