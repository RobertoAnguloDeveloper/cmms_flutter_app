# Previous rules
-keep class com.google.crypto.tink.** { *; }
-keep class javax.annotation.** { *; }
-keep class com.google.errorprone.annotations.** { *; }

# Rules for OkHttp
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
-dontwarn org.conscrypt.**
-keepnames class okhttp3.internal.publicsuffix.PublicSuffixDatabase

# Rules for Joda Time
-keep class org.joda.time.** { *; }
-dontwarn org.joda.time.**

# Keep JSON classes
-keepattributes Signature
-keepattributes *Annotation*

# Additional rules for missing classes
-dontwarn javax.naming.**
-dontwarn org.ietf.jgss.**
-keep class javax.naming.** { *; }
-keep class org.ietf.jgss.** { *; }

# Flutter Secure Storage rules
-keep class com.google.crypto.tink.subtle.** { *; }
-keep class com.google.crypto.tink.integration.android.** { *; }
-dontwarn com.google.crypto.tink.**