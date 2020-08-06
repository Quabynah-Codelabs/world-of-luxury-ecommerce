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
import androidx.core.content.res.ResourcesCompat
import androidx.core.view.isVisible
import androidx.navigation.NavController
import androidx.navigation.NavDestination
import androidx.navigation.fragment.NavHostFragment
import androidx.navigation.fragment.findNavController
import dagger.hilt.android.AndroidEntryPoint
import io.worldofluxury.R
import io.worldofluxury.base.DataBindingActivity
import io.worldofluxury.binding.gone
import io.worldofluxury.databinding.ActivityMainBinding
import io.worldofluxury.preferences.UserSharedPreferences
import io.worldofluxury.util.APP_TAG
import io.worldofluxury.view.home.HomeFragmentDirections
import timber.log.Timber
import javax.inject.Inject

@AndroidEntryPoint
class MainActivity : DataBindingActivity(), NavController.OnDestinationChangedListener {
    // binding main activity lazily
    val binding: ActivityMainBinding by binding(R.layout.activity_main)
    private lateinit var controller: NavController

    @Inject
    lateinit var userPrefs: UserSharedPreferences

    // destinations which do not require the theme FAB
    private val excludedFabDestinations by lazy {
        listOf(
            R.id.nav_auth,
            R.id.nav_welcome,
            R.id.nav_search,
            R.id.nav_checkout,
            R.id.nav_fav,
            R.id.nav_help,
            R.id.nav_history
        )
    }

    @Inject
    lateinit var userSharedPrefs: UserSharedPreferences

    override fun onCreate(savedInstanceState: Bundle?) {
        Timber.tag(APP_TAG)
        // override theme to remove splash image from background
        setTheme(R.style.Theme_WorldOfLuxury)
        super.onCreate(savedInstanceState)
        binding.run {
            lifecycleOwner = this@MainActivity
            prefs = userSharedPrefs
            setSupportActionBar(bottomAppBar)
            with(supportFragmentManager.findFragmentById(R.id.nav_host_fragment) as NavHostFragment) {
                controller = findNavController()
                controller.addOnDestinationChangedListener(this@MainActivity)
                Timber.d("Controller -> ${controller.currentDestination}")
            }
            executePendingBindings()
        }

        userSharedPrefs.liveTheme.observe(this, { state -> Timber.d("Theme state -> $state") })
    }

    override fun onCreateOptionsMenu(menu: Menu?): Boolean {
        menuInflater.inflate(R.menu.toolbar_menu, menu)
        return userSharedPrefs.isLoggedIn.get()
    }

    override fun onPrepareOptionsMenu(menu: Menu?): Boolean {
        // customize the theme icon
        val themeMenuItem = menu?.findItem(R.id.toggle_theme)
        if (themeMenuItem != null) {
            with(themeMenuItem) {
                isVisible = userPrefs.isLoggedIn.get()
                val themeIcon =
                    if (userPrefs.isDarkMode.get()) R.drawable.ic_twotone_sun else R.drawable.ic_twotone_moon
                icon = ResourcesCompat.getDrawable(resources, themeIcon, theme)
            }
        }
        return super.onPrepareOptionsMenu(menu)
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        when (item.itemId) {
            R.id.nav_search -> controller.navigate(HomeFragmentDirections.actionNavHomeToNavSearch())

            R.id.toggle_theme -> {
                userPrefs.updateTheme()

                // this prompts the menu to be laid out again
                invalidateOptionsMenu()
            }
        }
        return super.onOptionsItemSelected(item)
    }

    override fun onDestinationChanged(
        controller: NavController,
        destination: NavDestination,
        arguments: Bundle?
    ) {
        Timber.d("Current destination -> ${destination.label}")
        with(binding.scanImageFab) {
            if (excludedFabDestinations.contains(destination.id)) hide()
            else show()
        }
        with(binding.bottomAppBar) {
            gone(excludedFabDestinations.contains(destination.id))
            if (isVisible) performShow()
        }
    }

}