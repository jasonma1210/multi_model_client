# ProGuard rules for MJ Nexus

# ============================================================
# Flutter / Dart
# ============================================================
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# ============================================================
# flutter_local_notifications 插件（必须保留 Kotlin 类）
# ============================================================
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# ============================================================
# Google Play Core (Flutter Play Store 组件所需)
# ============================================================
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

# ============================================================
# Google ML Kit Text Recognition
# 忽略多语言文字识别的可选类（按需加载，不需要则忽略）
# ============================================================
-keep class com.google.mlkit.vision.text.chinese.** { *; }
-keep class com.google.mlkit.vision.text.devanagari.** { *; }
-keep class com.google.mlkit.vision.text.japanese.** { *; }
-keep class com.google.mlkit.vision.text.korean.** { *; }

# ============================================================
# Keep ML Kit core classes
# ============================================================
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

# ============================================================
# Keep native methods
# ============================================================
-keepclasseswithmembernames class * {
    native <methods>;
}