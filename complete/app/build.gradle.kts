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
@file:Suppress("UnstableApiUsage")

import com.android.build.api.artifact.ArtifactType
import com.android.build.api.variant.BuildConfigField
import java.io.FileInputStream
import java.util.*

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("kotlin-android-extensions")
    id("dagger.hilt.android.plugin")
    id("kotlin-kapt")
    id("androidx.navigation.safeargs.kotlin")
}

// Preparing Keystore information for bundle signing
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {

    onVariantProperties {

        // create the task to provide the git version.
        val gitVersionProvider = tasks.register<GitVersionTask>("${name}GitVersionProvider") {
            gitVersionOutputFile.set(
                File(project.buildDir, "intermediates/gitVersionProvider/output.txt")
            )
            outputs.upToDateWhen { false }
        }

        // create the task that transforms the manifest with that version
        val manifestUpdater = tasks.register<ManifestTransformerTask>("${name}ManifestUpdater") {
            gitInfoFile.set(gitVersionProvider.flatMap(GitVersionTask::gitVersionOutputFile))
        }

        // and wire things up with the Android Gradle Plugin
        artifacts.use(manifestUpdater)
            .wiredWithFiles(
                ManifestTransformerTask::mergedManifest,
                ManifestTransformerTask::updatedManifest
            )
            .toTransform(ArtifactType.MERGED_MANIFEST)

        buildConfigFields.put("GitVersion", gitVersionProvider.map { task ->
            BuildConfigField(
                "String",
                "\"${task.gitVersionOutputFile.get().asFile.readText(Charsets.UTF_8)}\"",
                "Git Version"
            )
        })
    }

    compileSdkVersion(Dependencies.compileSdkVersion)
    buildToolsVersion(Dependencies.buildToolsVersion)

    signingConfigs {
        register("release") {
            keyAlias(keystoreProperties["keyAlias"].toString())
            keyPassword(keystoreProperties["keyPassword"].toString())
            storeFile(file(keystoreProperties["storeFile"].toString()))
            storePassword(keystoreProperties["storePassword"].toString())
        }
    }

    buildTypes {
        named("release") {
            // stripe pub key
            buildConfigField(
                "String",
                "STRIPE_PUB_KEY",
                "\"${keystoreProperties["prod_stripe_pub_key"]}\""
            )
            // stripe pub secret
            buildConfigField(
                "String",
                "STRIPE_PUB_SECRET",
                "\"${keystoreProperties["prod_stripe_pub_secret"]}\""
            )

            // Enables code shrinking, obfuscation, and optimization for only
            // your project's release build type.
            isMinifyEnabled = true

            // Enables resource shrinking, which is performed by the
            // Android Gradle plugin.
            isShrinkResources = true

            // Includes the default ProGuard rules files that are packaged with
            // the Android Gradle plugin.
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )

            // Signing configuration
            setSigningConfig(signingConfigs["release"])
        }

        named("debug") {
            // stripe pub key
            buildConfigField(
                "String",
                "STRIPE_PUB_KEY",
                "\"${keystoreProperties["stripe_pub_key"]}\""
            )
            // stripe pub secret
            buildConfigField(
                "String",
                "STRIPE_PUB_SECRET",
                "\"${keystoreProperties["stripe_pub_secret"]}\""
            )

            isDebuggable = true
            setSigningConfig(signingConfigs["release"])
        }
    }

    defaultConfig {
        applicationId = Dependencies.packageName
        minSdkVersion(Dependencies.minSdkVersion)
        targetSdkVersion(Dependencies.targetSdkVersion)
        versionCode = Dependencies.versionCode
        versionName = Dependencies.versionName
        vectorDrawables.useSupportLibrary = true

        // archivesBaseName = "swan-wol"
        testInstrumentationRunner = "io.worldofluxury.SwanTestRunner"
        javaCompileOptions {
            annotationProcessorOptions {
                arguments(mapOf("room.schemaLocation" to "$projectDir/schemas"))
            }
        }

        // twitter key
        buildConfigField(
            "String",
            "TWITTER_CONSUMER_KEY",
            "\"${keystoreProperties["twitter_api_key"]}\""
        )
        // twitter secret
        buildConfigField(
            "String",
            "TWITTER_CONSUMER_SECRET",
            "\"${keystoreProperties["twitter_api_secret"]}\""
        )
    }

    aaptOptions {
        noCompress("tflite")
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_1_8.toString()
    }

    buildFeatures {
        dataBinding = true
        viewBinding = true
    }

    androidExtensions {
        isExperimental = true
    }

    lintOptions {
        isAbortOnError = false
    }

    sourceSets {
//        androidTest.java.srcDirs += "src/test-common/java"
//        test.java.srcDirs += "src/test-common/java"
//        test.assets.srcDirs += files("$projectDir/schemas".toString())
    }

    testOptions {
        unitTests {
            isIncludeAndroidResources = true
            isReturnDefaultValues = true
        }
    }

    hilt {
        enableTransformForLocalTests = true
    }

    configurations.all {
        resolutionStrategy.force("com.google.code.findbugs:jsr305:3.0.0")
    }

    packagingOptions {
        exclude("META-INF/DEPENDENCIES")
        exclude("META-INF/LICENSE")
        exclude("META-INF/LICENSE.txt")
        exclude("META-INF/license.txt")
        exclude("META-INF/NOTICE")
        exclude("META-INF/NOTICE.txt")
        exclude("META-INF/notice.txt")
        exclude("META-INF/ASL2.0")
        exclude("META-INF/AL2.0")
        exclude("META-INF/LGPL2.1")
        exclude("META-INF/*.kotlin_module")
    }
}

dependencies {

    // kotlin
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk7:${Dependencies.kotlin}")

    // android supports
    implementation("com.google.android.material:material:${Dependencies.materialVersion}")
    implementation("androidx.constraintlayout:constraintlayout:${Dependencies.constraintVersion}")

    // architecture components
    implementation("androidx.fragment:fragment-ktx:${Dependencies.fragmentVersion}")
    debugImplementation("androidx.fragment:fragment-testing:${Dependencies.fragmentVersion}")
    implementation("androidx.lifecycle:lifecycle-extensions:${Dependencies.lifecycleVersion}")
    implementation("androidx.lifecycle:lifecycle-livedata-ktx:${Dependencies.lifecycleVersion}")
    implementation("androidx.lifecycle:lifecycle-viewmodel-ktx:${Dependencies.lifecycleVersion}")
    implementation("androidx.lifecycle:lifecycle-viewmodel-savedstate:${Dependencies.lifecycleVersion}")
    implementation("androidx.paging:paging-runtime-ktx:${Dependencies.pagingVersion}")
    implementation("androidx.room:room-runtime:${Dependencies.roomVersion}")
    implementation("androidx.room:room-ktx:${Dependencies.roomVersion}")
    kapt("androidx.room:room-compiler:${Dependencies.roomVersion}")
    implementation("androidx.legacy:legacy-support-v4:1.0.0")
    implementation("androidx.navigation:navigation-fragment-ktx:${Dependencies.navVersion}")
    implementation("androidx.navigation:navigation-ui-ktx:${Dependencies.navVersion}")
    androidTestImplementation("androidx.navigation:navigation-testing:${Dependencies.navVersion}")
    implementation("androidx.work:work-runtime-ktx:${Dependencies.workVersion}")
    androidTestImplementation("androidx.work:work-testing:${Dependencies.workVersion}")
    androidTestImplementation("androidx.paging:paging-common-ktx:${Dependencies.pagingVersion}")
    androidTestImplementation("androidx.arch.core:core-testing:${Dependencies.archComponentVersion}")

    // startup
    implementation("androidx.startup:startup-runtime:${Dependencies.startupVersion}")

    // dagger
    implementation("com.google.dagger:dagger:${Dependencies.daggerVersion}")
    implementation("com.google.dagger:hilt-android:${Dependencies.daggerHiltAndroidVersion}")
    implementation("com.google.dagger:hilt-android-testing:${Dependencies.daggerHiltAndroidVersion}")
    implementation("androidx.hilt:hilt-common:${Dependencies.daggerHiltVersion}")
    implementation("androidx.hilt:hilt-lifecycle-viewmodel:${Dependencies.daggerHiltVersion}")
    implementation("androidx.hilt:hilt-work:${Dependencies.daggerHiltVersion}")
    kapt("androidx.hilt:hilt-compiler:${Dependencies.daggerHiltVersion}")
    kapt("com.google.dagger:dagger-compiler:${Dependencies.daggerVersion}")
    kapt("com.google.dagger:hilt-android-compiler:${Dependencies.daggerHiltAndroidVersion}")
    kapt("androidx.hilt:hilt-compiler:${Dependencies.daggerHiltVersion}")
    androidTestImplementation("com.google.dagger:hilt-android-testing:${Dependencies.daggerHiltAndroidVersion}")
    kaptAndroidTest("com.google.dagger:hilt-android-compiler:${Dependencies.daggerHiltAndroidVersion}")

    // network
    implementation("com.github.skydoves:sandwich:${Dependencies.sandwichVersion}")
    implementation("com.squareup.retrofit2:retrofit:${Dependencies.retrofitVersion}")
    androidTestImplementation("com.squareup.retrofit2:retrofit-mock:${Dependencies.retrofitVersion}")
    androidTestImplementation("com.squareup.spoon:spoon-client:1.3.1")
    implementation("com.squareup.retrofit2:converter-moshi:${Dependencies.retrofitVersion}")
    implementation("com.squareup.okhttp3:logging-interceptor:${Dependencies.okhttpVersion}")
    testImplementation("com.squareup.okhttp3:mockwebserver:${Dependencies.okhttpVersion}")
    androidTestImplementation("com.squareup.okhttp3:mockwebserver:${Dependencies.okhttpVersion}")

    // moshi
    implementation("com.squareup.moshi:moshi-kotlin:${Dependencies.moshiVersion}")
    implementation("com.squareup.moshi:moshi-kotlin-codegen:${Dependencies.moshiVersion}")

    // gson
    implementation("com.google.code.gson:gson:${Dependencies.gsonVersion}")

    // tensorflow
    // implementation("org.tensorflow:tensorflow-lite:0.0.0-nightly") { changing = true }
    // implementation("org.tensorflow:tensorflow-lite-gpu:0.0.0-nightly") { changing = true }
    // implementation("org.tensorflow:tensorflow-lite-support:0.0.0-nightly") { changing = true }

    // twitter
    implementation("com.twitter.sdk.android:twitter:${Dependencies.twitterVersion}")

    // google
    implementation("com.google.android.gms:play-services-auth:${Dependencies.googleVersion}")

    // stripe
    implementation("com.stripe:stripe-android:${Dependencies.stripeVersion}")

    // coroutines
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:${Dependencies.coroutinesVersion}")
    testImplementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:${Dependencies.coroutinesVersion}")
    testImplementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:${Dependencies.coroutinesVersion}")
    androidTestImplementation("org.jetbrains.kotlinx:kotlinx-coroutines-test:${Dependencies.coroutinesVersion}")

    // glide
    implementation("com.github.bumptech.glide:glide:${Dependencies.glideVersion}")
    kapt("com.github.bumptech.glide:compiler:${Dependencies.glideVersion}")
    implementation("com.github.florent37:glidepalette:${Dependencies.glidePaletteVersion}")

    // whatIf
    implementation("com.github.skydoves:whatif:${Dependencies.whatIfVersion}")

    // gradation
    implementation("com.github.skydoves:rainbow:${Dependencies.rainbowVersion}")

    // debugging
    implementation("com.jakewharton.timber:timber:${Dependencies.timberVersion}")

    // page indicator
    implementation("com.pacioianu.david:ink-page-indicator:${Dependencies.pageIndicatorVersion}")

    // unit test
    testImplementation("junit:junit:${Dependencies.junitVersion}")
    testImplementation("com.nhaarman.mockitokotlin2:mockito-kotlin:${Dependencies.mockitoKotlinVersion}")
    testImplementation("org.mockito:mockito-inline:${Dependencies.mockitoInlineVersion}")
    testImplementation("org.robolectric:robolectric:${Dependencies.robolectricVersion}")
    androidTestImplementation("androidx.test:core:${Dependencies.androidxTest}")
    androidTestImplementation("com.google.truth:truth:${Dependencies.truthVersion}")
    androidTestImplementation("androidx.test.ext:junit:${Dependencies.androidxTestJunit}")
    androidTestImplementation("com.android.support.test:runner:${Dependencies.androidTestRunner}")
    androidTestImplementation("androidx.test.espresso:espresso-core:${Dependencies.espressoVersion}")
}

kapt {
    useBuildCache = true
    generateStubs = true
    strictMode = true
}