plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // Set your app's namespace here (matches your app package)
    namespace = "com.example.lifesaver"  
    
    // Use Flutter's compileSdkVersion
    compileSdk = flutter.compileSdkVersion

    // Set the NDK version plugin requires
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // Make sure applicationId matches your namespace/package
        applicationId = "com.example.lifesaver"
        
        // Flutter SDK minSdk and targetSdk versions
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Use debug signing for now to enable flutter run --release
            signingConfig = signingConfigs.getByName("debug")
            
            // Configure minifying or shrinking as needed (optional)
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}