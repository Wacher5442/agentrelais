# Ignorer les classes manquantes pour ML Kit Text Recognition
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# Optionnel : Garder les classes ML Kit génériques
-keep class com.google.mlkit.** { *; }