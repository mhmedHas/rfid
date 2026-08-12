# حفظ جميع ملفات الـ SDK الخاصة بـ RFID
-keep class com.uhf.api.** { *; }
-dontwarn com.uhf.api.**

# حفظ Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# حفظ Flutter
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# حفظ جميع الكلاسات المستخدمة عبر الـ Reflection
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes SourceFile,LineNumberTable

# تجنب إزالة الكود المستخدم في الـ MethodChannel
-keep class com.example.alarm.** { *; }

# دعم USB Serial
-keep class com.hoho.android.usbserial.** { *; }
-dontwarn com.hoho.android.usbserial.**