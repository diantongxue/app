package com.yourpackage.services

import android.app.Service
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.PixelFormat
import android.hardware.display.DisplayManager
import android.hardware.display.VirtualDisplay
import android.media.Image
import android.media.ImageReader
import android.media.projection.MediaProjection
import android.media.projection.MediaProjectionManager
import android.os.IBinder
import android.util.Base64
import android.util.Log
import java.io.ByteArrayOutputStream
import java.nio.ByteBuffer

class ScreenCaptureService : Service() {
    private var mediaProjection: MediaProjection? = null
    private var virtualDisplay: VirtualDisplay? = null
    private var imageReader: ImageReader? = null
    private var webSocketService: WebSocketService? = null
    private var isCapturing = false
    private var captureInterval = 200L // 默认200ms，约5fps

    companion object {
        private const val TAG = "ScreenCaptureService"
        private const val VIRTUAL_DISPLAY_NAME = "ScreenCapture"
        private const val VIRTUAL_DISPLAY_FLAGS = 
            DisplayManager.VIRTUAL_DISPLAY_FLAG_OWN_CONTENT_ONLY or
            DisplayManager.VIRTUAL_DISPLAY_FLAG_PUBLIC
    }

    override fun onCreate() {
        super.onCreate()
        Log.d(TAG, "ScreenCaptureService创建")
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "ScreenCaptureService启动")
        
        val resultCode = intent?.getIntExtra("resultCode", -1) ?: -1
        val data = intent?.getParcelableExtra<Intent>("data")
        
        if (resultCode != -1 && data != null) {
            startCapture(resultCode, data)
        }
        
        return START_STICKY
    }

    fun setWebSocketService(service: WebSocketService) {
        this.webSocketService = service
    }

    fun startCapture(resultCode: Int, data: Intent) {
        if (isCapturing) {
            Log.w(TAG, "屏幕录制已在进行中")
            return
        }

        try {
            val mediaProjectionManager = getSystemService(MEDIA_PROJECTION_SERVICE) as MediaProjectionManager
            mediaProjection = mediaProjectionManager.getMediaProjection(resultCode, data)
            
            val displayMetrics = resources.displayMetrics
            val width = displayMetrics.widthPixels
            val height = displayMetrics.heightPixels
            val density = displayMetrics.densityDpi

            // 创建ImageReader用于接收屏幕画面
            imageReader = ImageReader.newInstance(width, height, PixelFormat.RGBA_8888, 2)
            
            // 创建VirtualDisplay
            virtualDisplay = mediaProjection?.createVirtualDisplay(
                VIRTUAL_DISPLAY_NAME,
                width,
                height,
                density,
                VIRTUAL_DISPLAY_FLAGS,
                imageReader?.surface,
                null,
                null
            )

            // 开始捕获循环
            isCapturing = true
            startCaptureLoop()
            
            Log.d(TAG, "屏幕录制已启动: ${width}x${height}")
        } catch (e: Exception) {
            Log.e(TAG, "启动屏幕录制失败: ${e.message}")
            isCapturing = false
        }
    }

    private fun startCaptureLoop() {
        Thread {
            while (isCapturing) {
                try {
                    captureScreen()
                    Thread.sleep(captureInterval)
                } catch (e: Exception) {
                    Log.e(TAG, "捕获屏幕失败: ${e.message}")
                }
            }
        }.start()
    }

    private fun captureScreen() {
        val image = imageReader?.acquireLatestImage() ?: return
        
        try {
            val planes = image.planes
            val buffer = planes[0].buffer
            val pixelStride = planes[0].pixelStride
            val rowStride = planes[0].rowStride
            val rowPadding = rowStride - pixelStride * image.width

            val bitmap = Bitmap.createBitmap(
                image.width + rowPadding / pixelStride,
                image.height,
                Bitmap.Config.ARGB_8888
            )
            bitmap.copyPixelsFromBuffer(buffer)
            
            // 裁剪到实际尺寸
            val actualBitmap = Bitmap.createBitmap(bitmap, 0, 0, image.width, image.height)
            
            // 转换为Base64
            val base64Image = bitmapToBase64(actualBitmap)
            
            // 通过WebSocket发送
            webSocketService?.sendScreenFrame(base64Image)
            
            bitmap.recycle()
            actualBitmap.recycle()
        } catch (e: Exception) {
            Log.e(TAG, "处理屏幕画面失败: ${e.message}")
        } finally {
            image.close()
        }
    }

    private fun bitmapToBase64(bitmap: Bitmap): String {
        val outputStream = ByteArrayOutputStream()
        // 压缩图片以减少传输量
        bitmap.compress(Bitmap.CompressFormat.JPEG, 70, outputStream)
        val byteArray = outputStream.toByteArray()
        return Base64.encodeToString(byteArray, Base64.NO_WRAP)
    }

    fun stopCapture() {
        isCapturing = false
        virtualDisplay?.release()
        imageReader?.close()
        mediaProjection?.stop()
        virtualDisplay = null
        imageReader = null
        mediaProjection = null
        Log.d(TAG, "屏幕录制已停止")
    }

    fun setCaptureInterval(interval: Long) {
        this.captureInterval = interval
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onDestroy() {
        super.onDestroy()
        stopCapture()
        Log.d(TAG, "ScreenCaptureService销毁")
    }
}

