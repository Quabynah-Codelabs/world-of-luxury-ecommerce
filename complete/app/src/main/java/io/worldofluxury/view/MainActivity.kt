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
import android.view.Menu
import android.view.MenuItem
import android.widget.Toast
import androidx.core.view.isVisible
import androidx.navigation.NavController
import androidx.navigation.NavHost
import androidx.navigation.NavHostController
import dagger.hilt.android.AndroidEntryPoint
import io.worldofluxury.R
import io.worldofluxury.base.DataBindingActivity
import io.worldofluxury.databinding.ActivityMainBinding
import io.worldofluxury.preferences.UserSharedPreferences
import io.worldofluxury.util.APP_TAG
import timber.log.Timber
import javax.inject.Inject

@AndroidEntryPoint
class MainActivity : DataBindingActivity(), NavHost {
    private val binding: ActivityMainBinding by binding(R.layout.activity_main)
    private var navController: NavController? = null

    @Inject
    lateinit var userSharedPrefs: UserSharedPreferences

    override fun onCreate(savedInstanceState: Bundle?) {
        Timber.tag(APP_TAG)
        // override theme to remove splash image from background
        setTheme(R.style.Theme_WorldOfLuxury)
        super.onCreate(savedInstanceState)

        binding.apply {
            lifecycleOwner = this@MainActivity
            prefs = userSharedPrefs
            try {
                NavHostController(this@MainActivity).apply {
                    addOnDestinationChangedListener { _, destination, _ ->
                        Timber.d("Current destination -> ${destination.label}")
                        with(themeFab) {
                            isVisible =
                                destination.id != R.id.nav_auth || destination.id != R.id.nav_welcome
                        }
                    }
                }.also { navController = it }
            } catch (e: Exception) {
                Timber.e(e)
            }
            executePendingBindings()
        }

        userSharedPrefs.liveTheme.observe(this, { state -> Timber.d("Theme state -> $state") })
    }

    override fun getNavController(): NavController = NavController(this)

    override fun onCreateOptionsMenu(menu: Menu?): Boolean {
        menuInflater.inflate(R.menu.toolbar_menu, menu)
        return userSharedPrefs.isLoggedIn.get()
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        when (item.itemId) {
            R.id.nav_search -> Toast.makeText(this, "Search", Toast.LENGTH_SHORT).show()

            R.id.show_filter -> Toast.makeText(this, "Not available", Toast.LENGTH_SHORT).show()
        }
        return super.onOptionsItemSelected(item)
    }

}