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

package io.worldofluxury.view

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.view.View
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.app.ActivityOptionsCompat
import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.ViewModel
import androidx.lifecycle.liveData
import dagger.hilt.android.AndroidEntryPoint
import io.worldofluxury.binding.checkAllMatched
import io.worldofluxury.preferences.PreferenceStorage
import io.worldofluxury.preferences.UserSharedPreferences
import io.worldofluxury.util.APP_TAG
import io.worldofluxury.viewmodel.factory.LaunchViewModelFactory
import timber.log.Timber
import javax.inject.Inject

enum class LaunchDestination {
    ONBOARDING,
    MAIN_ACTIVITY
}

class LauncherViewModel @ViewModelInject constructor(private val prefs: UserSharedPreferences) :
    ViewModel(),
    PreferenceStorage by prefs {

    val launchDestination = liveData {
        val result = prefs.onboardingCompleted
        if (result) {
            emit(LaunchDestination.MAIN_ACTIVITY)
        } else {
            emit(LaunchDestination.ONBOARDING)
        }
    }

    fun completeOnboarding(v: View) {
        prefs.onboardingCompleted = true
        ActivityCompat.startActivity(
            v.context,
            Intent(v.context, MainActivity::class.java),
            ActivityOptionsCompat.makeScaleUpAnimation(
                v, 0,
                0, v.width, v.height
            ).toBundle()
        )
        ActivityCompat.finishAfterTransition(v.context as Activity)
    }
}

/**
 * A 'Trampoline' activity for sending users to an appropriate screen on launch.
 */
@AndroidEntryPoint
class LaunchActivity : AppCompatActivity() {
    @Inject
    lateinit var factory: LaunchViewModelFactory
    private val launcherViewModel by viewModels<LauncherViewModel> { factory }

    init {
        Timber.tag(APP_TAG)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        launcherViewModel.onboardingCompleted = false
        launcherViewModel.launchDestination.observe(this, { destination ->
            Timber.d("Current user id from prefs -> $destination")
            when (destination) {
                LaunchDestination.MAIN_ACTIVITY ->
                    startActivity(
                        Intent(this, MainActivity::class.java)
                    )

                else ->
                    startActivity(Intent(this, OnboardingActivity::class.java))
            }.checkAllMatched
            finish()
        })

    }
}