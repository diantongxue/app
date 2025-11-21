package com.yourpackage.ui

import android.content.Intent
import android.media.projection.MediaProjectionManager
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.widget.Button
import android.widget.EditText
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.yourpackage.services.WebSocketService
import com.yourpackage.services.ScreenCaptureService

class MainActivity : AppCompatActivity() {
    private lateinit var webSocketService: WebSocketService
    private lateinit var screenCaptureService: ScreenCaptureService
    private lateinit var statusText: TextView
    private lateinit var serverUrlInput: EditText
    private lateinit var connectButton: Button
    private lateinit var startScreenCaptureButton: Button
    private lateinit var stopScreenCaptureButton: Button
    private lateinit var openSettingsButton: Button

    companion object {
        private const val REQUEST_MEDIA_PROJECTION = 1001
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // 使用布局资源ID（需要在编译时生成）
        // setContentView(R.layout.activity_main)
        
        // 临时使用代码创建布局
        val layout = android.widget.LinearLayout(this).apply {
            orientation = android.widget.LinearLayout.VERTICAL
            setPadding(32, 32, 32, 32)
        }

        statusText = TextView(this).apply {
            text = "未连接"
            textSize = 18f
            gravity = android.view.Gravity.CENTER
            setPadding(16, 16, 16, 16)
        }
        layout.addView(statusText)

        serverUrlInput = EditText(this).apply {
            hint = "服务器地址 (例如: http://192.168.1.100:3001)"
            textSize = 14f
            setPadding(12, 12, 12, 12)
        }
        layout.addView(serverUrlInput)

        connectButton = Button(this).apply {
            text = "连接服务器"
        }
        layout.addView(connectButton)

        startScreenCaptureButton = Button(this).apply {
            text = "开始屏幕录制"
        }
        layout.addView(startScreenCaptureButton)

        stopScreenCaptureButton = Button(this).apply {
            text = "停止屏幕录制"
        }
        layout.addView(stopScreenCaptureButton)

        val openSettingsButton = Button(this).apply {
            text = "打开无障碍设置"
        }
        layout.addView(openSettingsButton)

        setContentView(layout)

        // 初始化服务
        initializeServices()

        // 设置按钮事件
        connectButton.setOnClickListener { connectToServer() }
        startScreenCaptureButton.setOnClickListener { startScreenCapture() }
        stopScreenCaptureButton.setOnClickListener { stopScreenCapture() }
        openSettingsButton.setOnClickListener { openAccessibilitySettings() }
    }

    private fun initializeServices() {
        // 初始化WebSocket服务
        webSocketService = WebSocketService().apply {
            setDeviceId(Build.SERIAL)
            setOnConnectedListener {
                runOnUiThread {
                    statusText.text = "已连接"
                    connectButton.text = "断开连接"
                    Toast.makeText(this@MainActivity, "服务器连接成功", Toast.LENGTH_SHORT).show()
                }
            }
            setOnDisconnectedListener {
                runOnUiThread {
                    statusText.text = "未连接"
                    connectButton.text = "连接服务器"
                    Toast.makeText(this@MainActivity, "服务器连接断开", Toast.LENGTH_SHORT).show()
                }
            }
        }

        // 初始化屏幕录制服务
        screenCaptureService = ScreenCaptureService()
        screenCaptureService.setWebSocketService(webSocketService)
    }

    private fun connectToServer() {
        val url = serverUrlInput.text.toString().ifEmpty { "http://192.168.1.100:3001" }
        webSocketService.setServerUrl(url)
        
        if (webSocketService.isConnected()) {
            webSocketService.disconnect()
        } else {
            webSocketService.connect()
        }
    }

    private fun startScreenCapture() {
        val mediaProjectionManager = getSystemService(MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
        val intent = mediaProjectionManager.createScreenCaptureIntent()
        startActivityForResult(intent, REQUEST_MEDIA_PROJECTION)
    }

    private fun stopScreenCapture() {
        screenCaptureService.stopCapture()
        Toast.makeText(this, "屏幕录制已停止", Toast.LENGTH_SHORT).show()
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        
        if (requestCode == REQUEST_MEDIA_PROJECTION) {
            if (resultCode == RESULT_OK && data != null) {
                // 启动屏幕录制服务
                val serviceIntent = Intent(this, ScreenCaptureService::class.java).apply {
                    putExtra("resultCode", resultCode)
                    putExtra("data", data)
                }
                
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    startForegroundService(serviceIntent)
                } else {
                    startService(serviceIntent)
                }
                
                Toast.makeText(this, "屏幕录制已开始", Toast.LENGTH_SHORT).show()
            } else {
                Toast.makeText(this, "屏幕录制权限被拒绝", Toast.LENGTH_SHORT).show()
            }
        }
    }

    private fun openAccessibilitySettings() {
        val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
        startActivity(intent)
        Toast.makeText(this, "请开启ControlService和DataCollectorService", Toast.LENGTH_LONG).show()
    }

    override fun onDestroy() {
        super.onDestroy()
        webSocketService.disconnect()
        screenCaptureService.stopCapture()
    }
}

