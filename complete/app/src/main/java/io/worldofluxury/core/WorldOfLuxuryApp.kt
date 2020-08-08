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

package io.worldofluxury.core

import android.os.StrictMode
import android.util.Log
import androidx.hilt.work.HiltWorkerFactory
import androidx.work.Configuration
import com.stripe.android.PaymentConfiguration
import dagger.hilt.android.HiltAndroidApp
import io.worldofluxury.BuildConfig
import io.worldofluxury.BuildConfig.DEBUG
import io.worldofluxury.preferences.PreferenceStorage
import javax.inject.Inject

@HiltAndroidApp
class WorldOfLuxuryApp : TestApp(), Configuration.Provider {
    @Inject
    lateinit var workerFactory: HiltWorkerFactory

    @Inject
    lateinit var prefs: PreferenceStorage

    override fun getWorkManagerConfiguration() =
        Configuration.Builder()
            .setWorkerFactory(workerFactory)
            .setMinimumLoggingLevel(Log.INFO)
            .build()

    override fun onCreate() {
        // Enable strict mode before Dagger creates graph
        if (DEBUG) enableStrictMode()
        super.onCreate()
        // Initialize Stripe payment SDK
        PaymentConfiguration.init(
            applicationContext,
            BuildConfig.STRIPE_PUB_KEY
        )

        // Setup app theme
        prefs.showCurrentTheme()
    }

    private fun enableStrictMode() {
        StrictMode.setThreadPolicy(
            StrictMode.ThreadPolicy.Builder()
                .detectDiskReads()
                .detectDiskWrites()
                .detectNetwork()
                .penaltyLog()
                .build()
        )
    }
}