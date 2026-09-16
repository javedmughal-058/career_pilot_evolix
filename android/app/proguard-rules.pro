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

