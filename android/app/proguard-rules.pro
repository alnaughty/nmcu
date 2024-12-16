#Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class com.google.firebase.** { *; }
-keep class com.nomnomapp.nomnom.** { *; }
# Keep all MediaCodec-related classes
-keep class android.media.** { *; }

# Keep the HEVC codec classes (if they're specifically part of your implementation)
-keep class com.nomnomapp.nomnom.hevc.** { *; }
# Add any other rules for third-party libraries as needed
-keep class com.squareup.okhttp.** { *; }
-keep class com.google.firebase.** { *; }
-keep class androidx.lifecycle.** { *; }
# Prevent class and method name obfuscation
-keepnames class * {
    public <init>(...);
    public void *(...);
}

-keep @interface com.nomnom.nomnom.annotations.**