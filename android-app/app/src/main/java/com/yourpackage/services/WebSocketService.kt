package com.yourpackage.services

import android.util.Log
import io.socket.client.IO
import io.socket.client.Socket
import org.json.JSONObject
import java.net.URISyntaxException

class WebSocketService {
    private var socket: Socket? = null
    private var serverUrl: String = "http://192.168.1.100:3001" // 默认服务器地址
    private var deviceId: String = ""
    
    private var onConnectedListener: (() -> Unit)? = null
    private var onDisconnectedListener: (() -> Unit)? = null
    private var onMessageListener: ((JSONObject) -> Unit)? = null

    fun setServerUrl(url: String) {
        this.serverUrl = url
    }

    fun setDeviceId(id: String) {
        this.deviceId = id
    }

    fun connect() {
        try {
            val opts = IO.Options().apply {
                transports = arrayOf("websocket", "polling")
                query = "deviceId=$deviceId"
            }
            
            socket = IO.socket(serverUrl, opts)
            
            socket?.on(Socket.EVENT_CONNECT) {
                Log.d("WebSocket", "连接成功")
                onConnectedListener?.invoke()
                
                // 发送注册信息
                registerDevice()
            }
            
            socket?.on(Socket.EVENT_DISCONNECT) {
                Log.d("WebSocket", "连接断开")
                onDisconnectedListener?.invoke()
            }
            
            socket?.on(Socket.EVENT_CONNECT_ERROR) { args ->
                Log.e("WebSocket", "连接错误: ${args[0]}")
            }
            
            socket?.on("message") { args ->
                val message = args[0] as? JSONObject
                message?.let {
                    Log.d("WebSocket", "收到消息: $it")
                    onMessageListener?.invoke(it)
                }
            }
            
            socket?.connect()
        } catch (e: URISyntaxException) {
            Log.e("WebSocket", "URL格式错误: ${e.message}")
        }
    }

    fun disconnect() {
        socket?.disconnect()
        socket = null
    }

    fun sendMessage(type: String, data: JSONObject) {
        val message = JSONObject().apply {
            put("type", type)
            put("deviceId", deviceId)
            put("data", data)
            put("timestamp", System.currentTimeMillis())
        }
        socket?.emit("message", message)
    }

    fun sendScreenFrame(imageData: String) {
        val data = JSONObject().apply {
            put("image", imageData)
            put("format", "base64_jpeg")
        }
        socket?.emit("screen_frame", data)
    }

    fun sendCapturedData(data: JSONObject) {
        socket?.emit("captured_data", data)
    }

    private fun registerDevice() {
        val deviceInfo = JSONObject().apply {
            put("name", android.os.Build.MODEL)
            put("model", android.os.Build.MODEL)
            put("brand", android.os.Build.BRAND)
            put("androidVersion", android.os.Build.VERSION.RELEASE)
            put("sdkVersion", android.os.Build.VERSION.SDK_INT)
        }
        socket?.emit("register", deviceInfo)
    }

    fun setOnConnectedListener(listener: () -> Unit) {
        this.onConnectedListener = listener
    }

    fun setOnDisconnectedListener(listener: () -> Unit) {
        this.onDisconnectedListener = listener
    }

    fun setOnMessageListener(listener: (JSONObject) -> Unit) {
        this.onMessageListener = listener
    }

    fun isConnected(): Boolean {
        return socket?.connected() == true
    }
}

