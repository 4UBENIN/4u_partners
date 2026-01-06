# For U Partners - ProGuard Rules
# Keep notification sounds and Firebase messaging working in release builds

# Preserve Firebase Cloud Messaging classes
-keep class com.google.firebase.messaging.** { *; }
-keep class com.google.firebase.iid.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.messaging.**

# Preserve flutter_local_notifications plugin
-keep class com.dexterous.** { *; }
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Keep notification channel and sound resources
-keep class androidx.core.app.NotificationCompat** { *; }
-keep class android.app.NotificationChannel { *; }
-keep class android.media.AudioAttributes { *; }

# Preserve raw resources (critical for notification sounds)
-keepclassmembers class **.R$* {
    public static <fields>;
}
-keep class **.R$raw { *; }

# Keep notification data classes
-keepclassmembers class * {
    @com.google.firebase.messaging.RemoteMessage$MessagePayload <fields>;
}

# Preserve reflection used by Firebase
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Preserve sound file references
-keep class com.foru.driverapp.R$raw { *; }

# Don't obfuscate notification payload data
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
