pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val path = properties.getProperty("flutter.sdk")
        require(path != null) { "flutter.sdk not set in local.properties" }
        val gradlePath = file("$path/packages/flutter_tools/gradle")
        require(gradlePath.isDirectory) {
            """
            Flutter SDK path is invalid or incomplete.
            android/local.properties has: flutter.sdk=$path
            Expected directory does not exist: ${gradlePath.absolutePath}

            Fix: point flutter.sdk to your Flutter SDK root (the folder containing bin/flutter).
            - Run from app dir: flutter pub get  (to let Flutter write the path)
            - Or run: flutter doctor -v  (to see your SDK path), then edit android/local.properties
            """.trimIndent()
        }
        path
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.9.1" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

include(":app")
