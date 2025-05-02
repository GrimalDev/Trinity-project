# CardinalCommerce
-keep class com.cardinalcommerce.** { *; }
-dontwarn com.cardinalcommerce.**

# BouncyCastle
-keep class org.bouncycastle.** { *; }
-dontwarn org.bouncycastle.**

# Conscrypt
-keep class org.conscrypt.** { *; }
-dontwarn org.conscrypt.**

# OpenJSSE
-keep class org.openjsse.** { *; }
-dontwarn org.openjsse.**

# General SSL/Java security
-keep class javax.net.ssl.** { *; }
-keep class java.security.** { *; }
