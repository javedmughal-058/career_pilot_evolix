# Keep Flutter embedding and generated plugin entry points.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugins.GeneratedPluginRegistrant { *; }

# Keep app entry point.
-keep class com.evolixtechnologies.careerpilot.MainActivity { *; }

# Keep Firebase/Google Play Billing model members that are commonly used by reflection/serialization.
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class com.android.billingclient.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**
-dontwarn com.android.billingclient.**

# Keep Kotlin metadata used by Kotlin-based Android plugins.
-keep class kotlin.Metadata { *; }
-keepattributes Signature,InnerClasses,EnclosingMethod,*Annotation*

# Flutter references Play Core split-install classes for deferred components.
# This app does not use deferred components, so suppress missing-class warnings during R8.
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
