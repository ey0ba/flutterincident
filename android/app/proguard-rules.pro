# Flutter-specific rules
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# Prevent obfuscation of specific classes or libraries
-keep class com.example.** { *; }  # Replace with your app's package if needed

# Rules for commonly used libraries
-keepattributes *Annotation*
-keepattributes InnerClasses
-keepattributes Signature
-dontwarn javax.annotation.**

# Flutter secure storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-dontwarn com.it_nomads.fluttersecurestorage.**

# Any other third-party library rules
-dontwarn com.google.errorprone.annotations.**
-dontwarn javax.annotation.**
-dontwarn org.codehaus.mojo.**

-keep public class com.google.android.play.core.splitcompat.SplitCompatApplication
-keepclassmembers class * {
    public static <fields>;
    public static <methods>;
}

