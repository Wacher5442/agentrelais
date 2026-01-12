package com.example.agent_relais

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent
import io.flutter.plugin.common.MethodChannel

class UssdAccessibilityService : AccessibilityService() {

    companion object {
        var methodChannel: MethodChannel? = null
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event?.eventType == AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED ||
            event?.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {

            val textList = event.text
            if (textList != null && textList.isNotEmpty()) {
                val response = textList.joinToString(" ")

                if (response.isNotEmpty()) {
                    // Envoie la réponse au Flutter via MethodChannel
                    methodChannel?.invokeMethod("onUssdResponse", response)
                }
            }
        }
    }

    override fun onInterrupt() {}
}
