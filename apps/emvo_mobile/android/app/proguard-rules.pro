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

# Flutter deferred components reference Play Core; app does not ship it — suppress R8 errors.
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task

# For in_app_review / Play Core Ktx missing classes
-dontwarn com.google.android.gms.**
-dontwarn com.google.android.play.core.ktx.**

# Firebase (Auth / Core) — keep generic signatures for JNI / reflection
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.internal.firebase_auth.** { *; }
