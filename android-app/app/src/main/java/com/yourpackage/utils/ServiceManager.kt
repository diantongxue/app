package com.yourpackage.utils

import android.content.Context
import android.util.Log
import com.yourpackage.services.WebSocketService
import com.yourpackage.services.ScreenCaptureService
import com.yourpackage.services.ControlService
import com.yourpackage.services.DataCollectorService

class ServiceManager(private val context: Context) {
    private var webSocketService: WebSocketService? = null
    private var screenCaptureService: ScreenCaptureService? = null

    companion object {
        private const val TAG = "ServiceManager"
    }

    fun initialize() {
        // 初始化WebSocket服务
        webSocketService = WebSocketService().apply {
            setDeviceId(android.os.Build.SERIAL)
        }

        // 初始化屏幕录制服务
        screenCaptureService = ScreenCaptureService().apply {
            setWebSocketService(webSocketService!!)
        }

        Log.d(TAG, "服务管理器已初始化")
    }

    fun getWebSocketService(): WebSocketService? {
        return webSocketService
    }

    fun getScreenCaptureService(): ScreenCaptureService? {
        return screenCaptureService
    }

    fun connectToServer(url: String) {
        webSocketService?.setServerUrl(url)
        webSocketService?.connect()
    }

    fun disconnectFromServer() {
        webSocketService?.disconnect()
    }

    fun startScreenCapture(resultCode: Int, data: android.content.Intent) {
        screenCaptureService?.startCapture(resultCode, data)
    }

    fun stopScreenCapture() {
        screenCaptureService?.stopCapture()
    }

    fun cleanup() {
        webSocketService?.disconnect()
        screenCaptureService?.stopCapture()
        webSocketService = null
        screenCaptureService = null
    }
}

