plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.canhna_app"
    compileSdk = 35
    ndkVersion = "27.0.12077973" // Utilise la même version que ton local.properties

    defaultConfig {
        applicationId = "com.example.canhna_app"
        minSdk = 21
        targetSdk = 35
       // targetSdk = 21
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug") // à remplacer par release plus tard
        }
    }

    buildFeatures {
        viewBinding = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    configurations.all {
        resolutionStrategy {
            force("androidx.core:core-ktx:1.12.0")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("com.google.android.material:material:1.11.0"){
        because("Needed for Theme.MaterialComponents")
    }
    // autres dépendances Flutter gradle plugin auto-gérées
}
