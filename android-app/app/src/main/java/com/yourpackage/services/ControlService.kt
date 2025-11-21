package com.yourpackage.services

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.GestureDescription
import android.graphics.Path
import android.os.Bundle
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import org.json.JSONObject

class ControlService : AccessibilityService() {
    private var webSocketService: WebSocketService? = null

    companion object {
        private const val TAG = "ControlService"
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.d(TAG, "ControlService已连接")
    }

    fun setWebSocketService(service: WebSocketService) {
        this.webSocketService = service
        // 监听控制指令
        setupCommandListener()
    }

    private fun setupCommandListener() {
        webSocketService?.setOnMessageListener { message ->
            try {
                val type = message.optString("type")
                val data = message.optJSONObject("data")
                
                when (type) {
                    "command" -> {
                        handleCommand(data)
                    }
                }
            } catch (e: Exception) {
                Log.e(TAG, "处理消息失败: ${e.message}")
            }
        }
    }

    private fun handleCommand(command: JSONObject?) {
        if (command == null) return

        val commandType = command.optString("type")
        Log.d(TAG, "执行指令: $commandType")

        when (commandType) {
            "click" -> {
                val x = command.optInt("x")
                val y = command.optInt("y")
                performClick(x, y)
            }
            "swipe" -> {
                val startX = command.optInt("startX")
                val startY = command.optInt("startY")
                val endX = command.optInt("endX")
                val endY = command.optInt("endY")
                val duration = command.optLong("duration", 500)
                performSwipe(startX, startY, endX, endY, duration)
            }
            "input" -> {
                val text = command.optString("text")
                performInput(text)
            }
            "back" -> {
                performGlobalAction(GLOBAL_ACTION_BACK)
            }
            "home" -> {
                performGlobalAction(GLOBAL_ACTION_HOME)
            }
            "recent" -> {
                performGlobalAction(GLOBAL_ACTION_RECENTS)
            }
        }
    }

    private fun performClick(x: Int, y: Int) {
        val path = Path().apply {
            moveTo(x.toFloat(), y.toFloat())
        }
        
        val gesture = GestureDescription.Builder()
            .addStroke(GestureDescription.StrokeDescription(path, 0, 100))
            .build()
        
        dispatchGesture(gesture, object : GestureResultCallback() {
            override fun onCompleted(gestureDescription: GestureDescription?) {
                Log.d(TAG, "点击完成: ($x, $y)")
            }

            override fun onCancelled(gestureDescription: GestureDescription?) {
                Log.w(TAG, "点击取消: ($x, $y)")
            }
        }, null)
    }

    private fun performSwipe(startX: Int, startY: Int, endX: Int, endY: Int, duration: Long) {
        val path = Path().apply {
            moveTo(startX.toFloat(), startY.toFloat())
            lineTo(endX.toFloat(), endY.toFloat())
        }
        
        val gesture = GestureDescription.Builder()
            .addStroke(GestureDescription.StrokeDescription(path, 0, duration))
            .build()
        
        dispatchGesture(gesture, object : GestureResultCallback() {
            override fun onCompleted(gestureDescription: GestureDescription?) {
                Log.d(TAG, "滑动完成: ($startX, $startY) -> ($endX, $endY)")
            }

            override fun onCancelled(gestureDescription: GestureDescription?) {
                Log.w(TAG, "滑动取消")
            }
        }, null)
    }

    private fun performInput(text: String) {
        // 查找可编辑的输入框
        val rootNode = rootInActiveWindow ?: return
        
        val editableNodes = rootNode.findAccessibilityNodeInfosByText("")
        for (node in editableNodes) {
            if (node.isEditable) {
                node.performAction(AccessibilityNodeInfo.ACTION_FOCUS)
                node.performAction(AccessibilityNodeInfo.ACTION_SET_TEXT, Bundle().apply {
                    putCharSequence(AccessibilityNodeInfo.ACTION_ARGUMENT_SET_TEXT_CHARSEQUENCE, text)
                })
                Log.d(TAG, "输入文本: $text")
                return
            }
        }
        
        // 如果没有找到可编辑节点，尝试使用键盘输入
        Log.w(TAG, "未找到可编辑输入框，尝试其他方式")
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        // 可以在这里监听无障碍事件
    }

    override fun onInterrupt() {
        Log.d(TAG, "ControlService中断")
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "ControlService销毁")
    }
}

