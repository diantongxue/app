package com.yourpackage.services

import android.accessibilityservice.AccessibilityService
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import org.json.JSONArray
import org.json.JSONObject

class DataCollectorService : AccessibilityService() {
    private var webSocketService: WebSocketService? = null
    private var lastPageSource: String = ""

    companion object {
        private const val TAG = "DataCollectorService"
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.d(TAG, "DataCollectorService已连接")
    }

    fun setWebSocketService(service: WebSocketService) {
        this.webSocketService = service
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return

        when (event.eventType) {
            AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED,
            AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED -> {
                // 页面变化时采集数据
                collectPageData()
            }
        }
    }

    private fun collectPageData() {
        val rootNode = rootInActiveWindow ?: return
        
        try {
            // 提取页面数据
            val pageData = extractPageData(rootNode)
            
            // 生成页面源码的hash，避免重复发送
            val currentPageSource = pageData.toString()
            if (currentPageSource == lastPageSource) {
                return // 页面未变化，不发送
            }
            lastPageSource = currentPageSource

            // 通过WebSocket发送
            webSocketService?.sendCapturedData(pageData)
            
            Log.d(TAG, "页面数据已采集并发送")
        } catch (e: Exception) {
            Log.e(TAG, "采集页面数据失败: ${e.message}")
        }
    }

    private fun extractPageData(node: AccessibilityNodeInfo): JSONObject {
        val pageData = JSONObject()
        
        try {
            // 基本信息
            pageData.put("packageName", node.packageName?.toString() ?: "")
            pageData.put("className", node.className?.toString() ?: "")
            pageData.put("timestamp", System.currentTimeMillis())
            
            // 提取所有元素
            val elements = JSONArray()
            extractElements(node, elements, 0)
            pageData.put("elements", elements)
            
            // 提取所有文本
            val allText = extractAllText(node)
            pageData.put("text", allText)
            
            // 提取页面层次结构
            val hierarchy = buildHierarchy(node)
            pageData.put("hierarchy", hierarchy)
            
        } catch (e: Exception) {
            Log.e(TAG, "提取页面数据失败: ${e.message}")
        }
        
        return pageData
    }

    private fun extractElements(
        node: AccessibilityNodeInfo,
        elements: JSONArray,
        depth: Int
    ) {
        if (depth > 20) return // 限制深度，避免栈溢出
        
        try {
            val element = JSONObject()
            
            // 基本信息
            element.put("className", node.className?.toString() ?: "")
            element.put("text", node.text?.toString() ?: "")
            element.put("contentDescription", node.contentDescription?.toString() ?: "")
            element.put("resourceId", node.viewIdResourceName ?: "")
            
            // 位置信息
            val bounds = android.graphics.Rect()
            node.getBoundsInScreen(bounds)
            val boundsObj = JSONObject().apply {
                put("left", bounds.left)
                put("top", bounds.top)
                put("right", bounds.right)
                put("bottom", bounds.bottom)
                put("width", bounds.width())
                put("height", bounds.height())
            }
            element.put("bounds", boundsObj)
            
            // 状态信息
            element.put("clickable", node.isClickable)
            element.put("focusable", node.isFocusable)
            element.put("checkable", node.isCheckable)
            element.put("checked", node.isChecked)
            element.put("selected", node.isSelected)
            element.put("enabled", node.isEnabled)
            
            elements.put(element)
            
            // 递归处理子节点
            for (i in 0 until node.childCount) {
                node.getChild(i)?.let { child ->
                    extractElements(child, elements, depth + 1)
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "提取元素失败: ${e.message}")
        }
    }

    private fun extractAllText(node: AccessibilityNodeInfo): String {
        val textBuilder = StringBuilder()
        
        fun collectText(n: AccessibilityNodeInfo) {
            n.text?.let { textBuilder.append(it).append("\n") }
            n.contentDescription?.let { textBuilder.append(it).append("\n") }
            
            for (i in 0 until n.childCount) {
                n.getChild(i)?.let { collectText(it) }
            }
        }
        
        collectText(node)
        return textBuilder.toString()
    }

    private fun buildHierarchy(node: AccessibilityNodeInfo): JSONObject {
        val hierarchy = JSONObject()
        
        try {
            hierarchy.put("type", node.className?.toString() ?: "")
            hierarchy.put("text", node.text?.toString() ?: "")
            hierarchy.put("resourceId", node.viewIdResourceName ?: "")
            
            val children = JSONArray()
            for (i in 0 until node.childCount) {
                node.getChild(i)?.let { child ->
                    children.put(buildHierarchy(child))
                }
            }
            hierarchy.put("children", children)
        } catch (e: Exception) {
            Log.e(TAG, "构建层次结构失败: ${e.message}")
        }
        
        return hierarchy
    }

    override fun onInterrupt() {
        Log.d(TAG, "DataCollectorService中断")
    }

    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "DataCollectorService销毁")
    }
}

