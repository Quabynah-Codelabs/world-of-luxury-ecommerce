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

package io.worldofluxury.viewmodel

import android.app.Activity
import android.content.Intent
import android.view.View
import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.ViewModel
import androidx.lifecycle.liveData
import io.worldofluxury.BuildConfig
import io.worldofluxury.preferences.PreferenceStorage
import io.worldofluxury.view.MainActivity
import kotlinx.coroutines.delay

/**
 *  @project World of Luxury
 *  @author Bilson Jr.
 *  @by Quabynah Codelabs LLC
 *  @since 22/08/2020 @ 01:15
 */

enum class LaunchDestination {
    ONBOARDING,
    MAIN_ACTIVITY
}

class LauncherViewModel @ViewModelInject constructor(private val prefs: PreferenceStorage) :
    ViewModel(),
    PreferenceStorage by prefs {

    init {
        if (BuildConfig.DEBUG) prefs.onboardingCompleted = false
    }

    val launchDestination = liveData {
        val result = prefs.onboardingCompleted
        if (result) {
            emit(LaunchDestination.MAIN_ACTIVITY)
        } else {
            emit(LaunchDestination.ONBOARDING)
        }
    }

    // simulate loading resources from server
    val loadingResourcesLiveData = liveData {
        emit(true)
        delay(3500)
        emit(false)
    }

    fun completeOnboarding(v: View, host: Activity) {
        prefs.onboardingCompleted = true
        host.startActivity(
            Intent(v.context, MainActivity::class.java)/*,
            ActivityOptions.makeSceneTransitionAnimation(host).toBundle()*/
        )
        host.finish()
    }
}