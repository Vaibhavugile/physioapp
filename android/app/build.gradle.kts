
import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")

    // Firebase Google Services
    id("com.google.gms.google-services")

    id("kotlin-android")

    // Flutter Gradle plugin
    id("dev.flutter.flutter-gradle-plugin")
}

// Load signing configuration
val keystoreProperties = Properties()

val keystorePropertiesFile =
    rootProject.file("key.properties")

if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use {
        keystoreProperties.load(it)
    }
}

android {

    // Keep the existing namespace unchanged.
    namespace = "com.physiohomey.app"

    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // Retain the existing patient application ID as default.
        applicationId = "com.physiohomey.app"

        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // TWO SEPARATE ANDROID APPLICATIONS
    flavorDimensions += "app"

    productFlavors {

        create("patient") {
            dimension = "app"

            applicationId = "com.physiohomey.app"

            resValue(
                "string",
                "app_name",
                "PhysioAtHome"
            )
        }

        create("physio") {
            dimension = "app"

            applicationId = "com.physiohomey.partner"

            resValue(
                "string",
                "app_name",
                "PhysioAtHome Partner"
            )
        }
    }

    // Release signing
    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias =
                    keystoreProperties["keyAlias"] as String?

                keyPassword =
                    keystoreProperties["keyPassword"] as String?

                storeFile =
                    keystoreProperties["storeFile"]
                        ?.let { file(it as String) }

                storePassword =
                    keystoreProperties["storePassword"] as String?
            }
        }
    }

    buildTypes {
        release {
            signingConfig =
                signingConfigs.getByName("release")

            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}
