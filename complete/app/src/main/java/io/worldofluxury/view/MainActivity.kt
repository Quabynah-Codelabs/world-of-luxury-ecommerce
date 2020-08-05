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
import androidx.core.view.isVisible
import androidx.lifecycle.lifecycleScope
import androidx.navigation.Navigation
import androidx.navigation.findNavController
import androidx.navigation.ui.setupActionBarWithNavController
import dagger.hilt.android.AndroidEntryPoint
import io.worldofluxury.R
import io.worldofluxury.base.DataBindingActivity
import io.worldofluxury.databinding.ActivityMainBinding
import io.worldofluxury.preferences.UserSharedPreferences
import io.worldofluxury.util.APP_TAG
import kotlinx.coroutines.delay
import timber.log.Timber
import javax.inject.Inject


@AndroidEntryPoint
class MainActivity : DataBindingActivity() {
    private val binding: ActivityMainBinding by binding(R.layout.activity_main)

    @Inject
    lateinit var userSharedPrefs: UserSharedPreferences

    override fun onCreate(savedInstanceState: Bundle?) {
        Timber.tag(APP_TAG)
        super.onCreate(savedInstanceState)
        binding.apply {
            lifecycleOwner = this@MainActivity
            prefs = userSharedPrefs
            lifecycleScope.launchWhenCreated {
                delay(850)
                findNavController(R.id.nav_host_fragment).run {
                    addOnDestinationChangedListener { _, destination, _ ->
                        with(themeFab) {
                            isVisible =
                                destination.id != R.id.nav_auth || destination.id != R.id.nav_welcome
                        }
                    }
                }
            }
            executePendingBindings()
        }

        userSharedPrefs.liveTheme.observe(this, { state -> Timber.d("Theme state -> $state") })
    }
}