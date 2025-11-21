# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.

# Keep WebSocket classes
-keep class io.socket.** { *; }
-keep class com.yourpackage.services.** { *; }

# Keep JSON classes
-keep class org.json.** { *; }

