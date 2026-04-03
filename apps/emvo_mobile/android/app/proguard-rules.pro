# Flutter / engine
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Kotlin
-keepattributes *Annotation*, Signature, InnerClasses, EnclosingMethod
-dontwarn kotlin.**

# Gson / reflection (if used by plugins)
-keepattributes Signature
-keepattributes *Annotation*

# Rive (native / Kotlin runtime used by rive plugin)
-keep class com.rive.** { *; }
-keep class app.rive.** { *; }

# JSON serialization (Java interop / plugins)
-keep class * implements java.io.Serializable { *; }

# General (annotations, generics, stack traces in release)
-keepattributes Annotation
-keepattributes Signature
-keepattributes Exceptions
