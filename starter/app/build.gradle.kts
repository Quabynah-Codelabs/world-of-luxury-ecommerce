/*
 * Copyright (c) 2020.
 * Designed and developed by @quabynah_codelabs (Dennis Bilson)
 *
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("androidx.navigation.safeargs.kotlin")
}

android {
    compileSdkVersion(Dependencies.compileSdkVersion)
    buildToolsVersion(Dependencies.buildToolsVersion)

    defaultConfig {
        applicationId = Dependencies.packageName
        minSdkVersion(Dependencies.minSdkVersion)
        targetSdkVersion(Dependencies.targetSdkVersion)
        versionCode = Dependencies.versionCode
        versionName = Dependencies.versionName

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        named("release") {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_1_8.toString()
    }
}

dependencies {
    // kotlin
    implementation("org.jetbrains.kotlin:kotlin-stdlib:${Dependencies.kotlin}")
    implementation("androidx.core:core-ktx:${Dependencies.coreKtxVersion}")

    // android components
    implementation("androidx.appcompat:appcompat:${Dependencies.appCompatVersion}")
    implementation("com.google.android.material:material:${Dependencies.materialVersion}")
    implementation("androidx.constraintlayout:constraintlayout:${Dependencies.constraintVersion}")
    implementation("androidx.legacy:legacy-support-v4:${Dependencies.legacySupportVersion}")
    implementation("androidx.lifecycle:lifecycle-livedata-ktx:${Dependencies.lifecycleVersion}")
    implementation("androidx.lifecycle:lifecycle-viewmodel-ktx:${Dependencies.lifecycleVersion}")

    // navigation
    implementation("androidx.navigation:navigation-fragment-ktx:${Dependencies.navVersion}")
    implementation("androidx.navigation:navigation-ui-ktx:${Dependencies.navVersion}")

    // testing
    testImplementation("junit:junit:${Dependencies.junitVersion}")
    androidTestImplementation("androidx.test.ext:junit:${Dependencies.androidxTestJunit}")
    androidTestImplementation("androidx.test.espresso:espresso-core:${Dependencies.espressoVersion}")

    // Navigation
    androidTestImplementation("androidx.navigation:navigation-testing:${Dependencies.navVersion}")
}