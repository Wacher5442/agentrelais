package com.example.agent_relais
import android.telecom.Connection
import android.telecom.ConnectionRequest
import android.telecom.ConnectionService
import android.telecom.PhoneAccountHandle
import android.os.Build
import androidx.annotation.RequiresApi
import io.flutter.plugin.common.MethodChannel

@RequiresApi(Build.VERSION_CODES.M)
class UssdService : ConnectionService() {
    companion object {
        var ussdResponse: String? = null
        var methodChannel: MethodChannel? = null
        var currentConnection: UssdConnection? = null
    }

    override fun onCreateOutgoingConnection(
        connectionManagerPhoneAccount: PhoneAccountHandle?,
        request: ConnectionRequest
    ): Connection {
        val connection = UssdConnection()
        currentConnection = connection
        return connection
    }

    class UssdConnection : Connection() {
        override fun onStateChanged(state: Int) {
            when (state) {
                Connection.STATE_DIALING -> {
                    // USSD en cours de composition
                    methodChannel?.invokeMethod("onUssdState", "dialing")
                }
                Connection.STATE_ACTIVE -> {
                    // USSD actif
                    methodChannel?.invokeMethod("onUssdState", "active")
                }
                Connection.STATE_DISCONNECTED -> {
                    // USSD terminé, récupérer la réponse
                    methodChannel?.invokeMethod("onUssdResponse", ussdResponse ?: "")
                    destroy()
                }
            }
        }

        override fun onDisconnect() {
            super.onDisconnect()
            destroy()
        }
    }
}