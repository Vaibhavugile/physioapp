import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")

    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration

    id("kotlin-android")

    // The Flutter Gradle Plugin must be applied after
    // the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

////////////////////////////////////////////////////////////
/// LOAD KEY.PROPERTIES
////////////////////////////////////////////////////////////

val keystoreProperties = Properties()

val keystorePropertiesFile =
    rootProject.file("key.properties")

if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use {
        keystoreProperties.load(it)
    }
}

android {

    ////////////////////////////////////////////////////////////
    /// APP PACKAGE
    ////////////////////////////////////////////////////////////

    namespace = "com.physiohomey.app"

    compileSdk = flutter.compileSdkVersion

    ndkVersion = flutter.ndkVersion

    ////////////////////////////////////////////////////////////
    /// JAVA CONFIGURATION
    ////////////////////////////////////////////////////////////

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    ////////////////////////////////////////////////////////////
    /// KOTLIN CONFIGURATION
    ////////////////////////////////////////////////////////////

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    ////////////////////////////////////////////////////////////
    /// DEFAULT CONFIG
    ////////////////////////////////////////////////////////////

    defaultConfig {

        applicationId = "com.physiohomey.app"

        minSdk = flutter.minSdkVersion

        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode

        versionName = flutter.versionName
    }

    ////////////////////////////////////////////////////////////
    /// RELEASE SIGNING CONFIGURATION
    ////////////////////////////////////////////////////////////

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

    ////////////////////////////////////////////////////////////
    /// BUILD TYPES
    ////////////////////////////////////////////////////////////

    buildTypes {

        release {

            //////////////////////////////////////////////////////
            /// USE YOUR RELEASE KEYSTORE
            //////////////////////////////////////////////////////

            signingConfig =
                signingConfigs.getByName("release")

            //////////////////////////////////////////////////////
            /// RELEASE SETTINGS
            //////////////////////////////////////////////////////

            isMinifyEnabled = false

            isShrinkResources = false
        }
    }
}

////////////////////////////////////////////////////////////
/// FLUTTER
////////////////////////////////////////////////////////////

flutter {
    source = "../.."
}