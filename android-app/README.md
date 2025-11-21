# Android App 项目

## 项目说明

这是手机客户端App，用于：
1. 连接后端服务器（WebSocket）
2. 屏幕录制和传输
3. 接收控制指令并执行
4. 采集页面数据并上传

## 技术栈

- Kotlin
- Android SDK 34 (Android 14)
- 最低支持: API 24 (Android 7.0)
- OkHttp 4.x
- Gson/Moshi

## 核心功能模块

### 1. WebSocketService
- 与服务器建立WebSocket连接
- 消息收发
- 断线重连

### 2. ScreenCaptureService
- 使用MediaProjection录制屏幕
- 画面编码（JPEG/H.264）
- 实时传输

### 3. ControlService (AccessibilityService)
- 接收控制指令
- 执行点击、滑动操作
- 文本输入

### 4. DataCollectorService (AccessibilityService)
- 监听页面变化
- 提取页面数据
- 格式化并上传

## 权限要求

1. 无障碍服务权限（必需）
2. 屏幕录制权限（必需）
3. 网络权限（必需）
4. 前台服务权限（必需）
5. 电池优化白名单（必需）

## 开发说明

使用Android Studio创建项目，然后参考以下结构组织代码：

```
app/src/main/java/com/yourpackage/
├── services/
│   ├── WebSocketService.kt
│   ├── ScreenCaptureService.kt
│   ├── ControlService.kt
│   └── DataCollectorService.kt
├── ui/
│   └── MainActivity.kt
└── utils/
    └── Logger.kt
```

## 连接配置

在App中配置服务器地址：
- 开发环境: `ws://192.168.1.100:3001` (替换为你的电脑IP)
- 生产环境: 根据实际情况配置

## 下一步

1. 在Android Studio中创建新项目
2. 配置依赖（OkHttp、Gson等）
3. 实现WebSocket连接
4. 实现屏幕录制
5. 实现控制功能
6. 实现数据采集

