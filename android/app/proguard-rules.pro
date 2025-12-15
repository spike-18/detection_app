-keep class org.tensorflow.lite.** { *; }
-keep class com.ultralytics.** { *; }
-dontwarn org.tensorflow.**

# Optimize native libraries
-keepclassmembers class * {
    native <methods>;
}