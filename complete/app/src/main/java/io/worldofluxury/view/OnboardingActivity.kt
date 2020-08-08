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

import android.os.Bundle
import androidx.activity.viewModels
import androidx.lifecycle.lifecycleScope
import dagger.hilt.android.AndroidEntryPoint
import io.worldofluxury.R
import io.worldofluxury.base.DataBindingActivity
import io.worldofluxury.databinding.ActivityOnboardingBinding
import io.worldofluxury.util.APP_TAG
import io.worldofluxury.viewmodel.factory.LaunchViewModelFactory
import kotlinx.coroutines.delay
import timber.log.Timber
import javax.inject.Inject
import kotlin.random.Random

@AndroidEntryPoint
class OnboardingActivity : DataBindingActivity() {
    private val binding by binding<ActivityOnboardingBinding>(R.layout.activity_onboarding)

    @Inject
    lateinit var factory: LaunchViewModelFactory
    private val launcherViewModel by viewModels<LauncherViewModel> { factory }

    init {
        Timber.tag(APP_TAG)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        binding.run {
            lifecycleScope.launchWhenCreated {
                delay(2000)
                launcherViewModel.onboardingCompleted = Random.nextBoolean()
                Timber.d("Onboarding state -> ${launcherViewModel.onboardingCompleted}")
            }

            executePendingBindings()
        }
    }
}