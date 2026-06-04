plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.multimodel.client.multi_model_client"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlin {
        jvmToolchain(17)
    }

    defaultConfig {
        applicationId = "com.multimodel.client.multi_model_client"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // 确保 Kotlin 编译插件的 Kotlin 类
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        debug {
            // Debug 构建也启用 multidex，确保所有类都能被编译
            multiDexEnabled = true
        }
    }

    // 确保 Kotlin 编译完整
    packaging {
        jniLibs {
            useLegacyPackaging = true
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Google Play Core
    implementation("com.google.android.play:core:1.10.3")
    // Kotlin 标准库
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.9.24")
    // 强制使用统一版本，解决 background_downloader 的 WorkManager 初始化问题
    implementation("androidx.work:work-runtime-ktx:2.8.1")
}