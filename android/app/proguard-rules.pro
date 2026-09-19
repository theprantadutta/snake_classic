# R8 rules for the release build.
#
# Play Console scored release 54 at a 14% optimisation / 15% obfuscation /
# 14% shrinking rate. The cause was this file: it kept whole SDK packages
# with "-keep class <pkg>.** { *; }", and "com.google.android.gms.**" alone
# pinned 13,800 classes, 62% of the DEX, that R8 could otherwise have
# inlined, merged, renamed or dropped. Every one of those SDKs ships its own
# consumer rules inside its AAR (play-services-basement 17, play-services-ads
# 4, firebase-auth 1, billing 5, openiap-google 3), and Firebase is built for
# R8 full mode, so the blanket keeps protected nothing that was not already
# protected. Only rules with a documented reason remain below.

# ---------------------------------------------------------------------------
# Flutter. No rules needed: the engine marks its JNI entry points with @Keep
# (honoured by proguard-android-optimize.txt) and the Flutter Gradle plugin
# keeps every FlutterPlugin implementation (flutter_proguard_rules.pro).
# ---------------------------------------------------------------------------

# Google Play Core (deferred components / split install) — referenced by the
# Flutter embedding but not shipped in this app.
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

# ---------------------------------------------------------------------------
# Readable stack traces in the crash reporter (Sentry, previously Firebase
# Crashlytics). Still required after the swap: the R8 mapping file is uploaded
# by `dart run sentry_dart_plugin` rather than by the Crashlytics Gradle
# plugin, but these attributes must survive shrinking either way for the
# retrace to line up, and custom exception types keep their names so a report
# says what was thrown.
# ---------------------------------------------------------------------------
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# ---------------------------------------------------------------------------
# flutter_local_notifications — uses Gson to (de)serialize scheduled
# notification details. R8 full mode strips the generic TypeToken signatures
# and crashes on scheduled/rescheduled notifications without these keeps
# (the rules the plugin's README asks for).
# ---------------------------------------------------------------------------
-keep class com.dexterous.** { *; }
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.stream.** { *; }
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Keep native methods
-keepclassmembers class * {
    native <methods>;
}

# Keep Parcelables
-keepclassmembers class * implements android.os.Parcelable {
    static ** CREATOR;
}

# Keep Serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# ---------------------------------------------------------------------------
# Google Play Billing + flutter_inapp_purchase (OpenIAP). Both AARs ship
# their own consumer rules: billing keeps its AIDL and proxy activities,
# openiap-google keeps dev.hyo.openiap.models.** for its JSON bridge. The
# Flutter plugin class itself is a FlutterPlugin and is kept by the Flutter
# Gradle plugin. Nothing to add beyond silencing optional references.
# ---------------------------------------------------------------------------
-dontwarn dev.hyo.**
-dontwarn io.github.hyochan.**
