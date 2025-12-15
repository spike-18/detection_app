# Ultralytics and TensorFlow Lite rules
-keep class org.tensorflow.lite.** { *; }
-keep class com.ultralytics.** { *; }
-dontwarn org.tensorflow.**

# Optimize native libraries
-keepclassmembers class * {
    native <methods>;
}

# Fix for SnakeYAML / java.beans missing classes
-dontwarn java.beans.**
-dontwarn org.yaml.snakeyaml.**