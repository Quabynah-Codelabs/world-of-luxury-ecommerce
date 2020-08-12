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

import android.content.Intent
import android.os.Bundle
import android.view.Menu
import android.view.MenuItem
import android.view.View
import android.widget.Toast
import androidx.activity.viewModels
import androidx.appcompat.app.ActionBarDrawerToggle
import androidx.core.content.res.ResourcesCompat
import androidx.core.view.GravityCompat
import androidx.core.view.isVisible
import androidx.core.view.updatePadding
import androidx.drawerlayout.widget.DrawerLayout
import androidx.navigation.NavController
import androidx.navigation.NavDestination
import androidx.navigation.fragment.NavHostFragment
import androidx.navigation.fragment.findNavController
import androidx.navigation.ui.setupWithNavController
import androidx.recyclerview.widget.RecyclerView
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.common.api.ApiException
import com.skydoves.whatif.whatIf
import dagger.hilt.android.AndroidEntryPoint
import io.worldofluxury.R
import io.worldofluxury.base.DataBindingActivity
import io.worldofluxury.binding.doOnApplyWindowInsets
import io.worldofluxury.binding.gone
import io.worldofluxury.binding.navigationItemBackground
import io.worldofluxury.data.User
import io.worldofluxury.databinding.ActivityMainBinding
import io.worldofluxury.databinding.DrawerHeaderBinding
import io.worldofluxury.util.APP_TAG
import io.worldofluxury.util.HeightTopWindowInsetsListener
import io.worldofluxury.util.NoopWindowInsetsListener
import io.worldofluxury.viewmodel.AuthViewModel
import io.worldofluxury.viewmodel.factory.AuthViewModelFactory
import io.worldofluxury.widget.SpaceDecoration
import timber.log.Timber
import javax.inject.Inject

@AndroidEntryPoint
class MainActivity : DataBindingActivity(), NavController.OnDestinationChangedListener {
    // binding main activity lazily
    val binding: ActivityMainBinding by binding(R.layout.activity_main)
    private lateinit var controller: NavController

    @Inject
    lateinit var authViewModelFactory: AuthViewModelFactory
    private val authVM by viewModels<AuthViewModel> { authViewModelFactory }

    override fun onCreate(savedInstanceState: Bundle?) {
        Timber.tag(APP_TAG)
        super.onCreate(savedInstanceState)
        binding.run {
            lifecycleOwner = this@MainActivity
            vm = authVM
            setSupportActionBar(bottomAppBar)
            with(supportFragmentManager.findFragmentById(R.id.nav_host_fragment) as NavHostFragment) {
                controller = findNavController()
                controller.addOnDestinationChangedListener(this@MainActivity)
            }
            setSupportActionBar(bottomAppBar)

            // setup drawer
            with(drawer) {
                val toggler = ActionBarDrawerToggle(
                    this@MainActivity,
                    this,
                    bottomAppBar,
                    R.string.nav_app_bar_open_drawer_description,
                    R.string.nav_app_bar_navigate_up_description
                )
                toggler.syncState()
                addDrawerListener(toggler)
            }


            // apply window insets
            drawerContainer.setOnApplyWindowInsetsListener { v, insets ->
                // Let the view draw it's navigation bar divider
                v.onApplyWindowInsets(insets)

                // Consume any horizontal insets and pad all content in. There's not much we can do
                // with horizontal insets
                v.updatePadding(
                    left = insets.systemWindowInsetLeft,
                    right = insets.systemWindowInsetRight
                )
                insets.replaceSystemWindowInsets(
                    0, insets.systemWindowInsetTop,
                    0, insets.systemWindowInsetBottom
                )
            }

            // setup content insets
            content.systemUiVisibility = View.SYSTEM_UI_FLAG_LAYOUT_STABLE or
                    View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN or
                    View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
            // Make the content ViewGroup ignore insets so that it does not use the default padding
            content.setOnApplyWindowInsetsListener(NoopWindowInsetsListener)
            bottomAppBar.doOnApplyWindowInsets { v, insets, padding ->
                v.updatePadding(bottom = padding.bottom + insets.systemWindowInsetBottom)
            }
            navHostFragment.doOnApplyWindowInsets { v, insets, padding ->
                v.updatePadding(top = padding.top + insets.systemWindowInsetTop)
            }

            // setup status bar insets
            statusBarScrim.setOnApplyWindowInsetsListener(HeightTopWindowInsetsListener)

            // observe theme
            authVM.liveTheme.observe(
                this@MainActivity,
                { state -> Timber.d("Theme state -> $state") })

            // setup header in drawer navigation view
            val headerBinding: DrawerHeaderBinding =
                DrawerHeaderBinding.inflate(layoutInflater)
            headerBinding.run {
                Timber.d("Binding for header started")
                val menuView =
                    findViewById<RecyclerView>(R.id.design_navigation_view)?.apply {
                        addItemDecoration(SpaceDecoration())
                    }
                root.doOnApplyWindowInsets { v, insets, padding ->
                    v.updatePadding(top = padding.top + insets.systemWindowInsetTop)
                    // NavigationView doesn't dispatch insets to the menu view, so pad the bottom here.
                    menuView?.updatePadding(bottom = insets.systemWindowInsetBottom)
                }
                executePendingBindings()
            }

            authVM.authState.observe(this@MainActivity, { state ->
                Timber.d("State -> $state")

                val isAuthenticated = state == AuthViewModel.AuthenticationState.AUTHENTICATED

                // header
                headerBinding.root.setOnClickListener {
                    drawer.closeDrawers()
                    controller.navigate(if (isAuthenticated) R.id.nav_user else R.id.nav_auth)
                }

                // update menu based on user login state
                sidebar.run {
                    // add item background for sidebar
                    itemBackground = navigationItemBackground(this@MainActivity)
                    this.setupWithNavController(controller)

                    // set menu items visibility
                    menu.findItem(R.id.nav_cart).isVisible = isAuthenticated
                    menu.findItem(R.id.nav_user).isVisible = isAuthenticated
                }

                // re-layout the options menu for our bottom nav
                invalidateOptionsMenu()

                // attach header to sidebar
                if (sidebar.headerCount == 0) sidebar.addHeaderView(headerBinding.root)
            })

            // observe current user
            authVM.currentUser.observe(this@MainActivity, {
                headerBinding.vm = authVM
            })
            executePendingBindings()
        }
    }

    override fun onCreateOptionsMenu(menu: Menu?): Boolean {
        menuInflater.inflate(R.menu.toolbar_menu, menu)
        return true
    }

    override fun onPrepareOptionsMenu(menu: Menu?): Boolean {
        menu?.findItem(R.id.nav_search)?.isVisible = authVM.isLoggedIn.get()
        // customize the theme icon
        val themeMenuItem = menu?.findItem(R.id.toggle_theme)
        if (themeMenuItem != null) {
            with(themeMenuItem) {
                val themeIcon =
                    if (authVM.isDarkMode.get()) R.drawable.ic_twotone_sun else R.drawable.ic_twotone_moon
                icon = ResourcesCompat.getDrawable(resources, themeIcon, theme)
            }
        }
        return super.onPrepareOptionsMenu(menu)
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        when (item.itemId) {
            R.id.nav_search -> controller.navigate(item.itemId)

            R.id.toggle_theme -> {
                authVM.updateTheme()

                // this prompts the menu to be laid out again
                invalidateOptionsMenu()
            }
        }
        return super.onOptionsItemSelected(item)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (resultCode == RESULT_OK) {
            // pass down any activity result to the fragments
            supportFragmentManager.fragments.forEach {
                it.onActivityResult(
                    requestCode,
                    resultCode,
                    data
                )
            }

            with(authVM) {
                try {
                    val signedInAccountFromIntent = GoogleSignIn.getSignedInAccountFromIntent(data)
                    val signInAccount =
                        signedInAccountFromIntent.getResult(ApiException::class.java)
                    signInAccount.whatIf({ account -> account == null }, {
                        Timber.e("User account was null")
                        authState.value = AuthViewModel.AuthenticationState.ERROR
                    }, {
                        // create user from google account
                        val acct = signInAccount ?: return
                        Timber.i("name -> ${acct.displayName}, email -> ${acct.email} & avatar -> ${acct.photoUrl}")
                        val idTokenForServer = acct.idToken
                        Timber.i("Token to be sent to server -> $idTokenForServer")
                        try {
                            val user =
                                User(
                                    acct.id!!,
                                    acct.displayName!!,
                                    acct.email,
                                    acct.photoUrl.toString()
                                )
                            saveUser(user)
                        } catch (e: Exception) {
                            Timber.e(e)
                            authState.value = AuthViewModel.AuthenticationState.ERROR
                        }
                    })
                } catch (e: Exception) {
                    Timber.e(e)
                    authState.value = AuthViewModel.AuthenticationState.ERROR
                }
            }
        } else {
            Timber.e("Google auth failed")
            authVM.authState.value = AuthViewModel.AuthenticationState.ERROR
            super.onActivityResult(requestCode, resultCode, data)
        }

    }

    override fun onDestinationChanged(
        controller: NavController,
        destination: NavDestination,
        arguments: Bundle?
    ) {
        Timber.d("Current destination -> ${destination.label}")
        val shouldBeGone = EXCLUDED_DESTINATIONS.contains(destination.id)
        with(binding.drawer) {
            val lockMode = if (shouldBeGone) {
                DrawerLayout.LOCK_MODE_LOCKED_CLOSED
            } else {
                DrawerLayout.LOCK_MODE_UNLOCKED
            }
            setDrawerLockMode(lockMode)
        }
        with(binding.scanImageFab) {
            setOnClickListener {
                Toast.makeText(
                    this@MainActivity,
                    "Feature unavailable",
                    Toast.LENGTH_SHORT
                ).show()
            }
            if (EXCLUDED_FAB_DESTINATIONS.contains(destination.id)) hide()
            else show()
        }
        with(binding.bottomAppBar) {
            gone(shouldBeGone)
            if (isVisible) performShow()
        }
    }

    override fun onBackPressed() {
        with(binding.drawer) {
            when {
                isDrawerOpen(GravityCompat.START) -> closeDrawers()
                else -> super.onBackPressed()
            }
        }
    }

    companion object {
        // destinations which do not require the theme FAB
        private val EXCLUDED_DESTINATIONS = setOf(
            R.id.nav_auth,
            R.id.nav_welcome,
            R.id.nav_checkout,
            R.id.nav_product
        )

        private val EXCLUDED_FAB_DESTINATIONS = setOf(
            R.id.nav_auth,
            R.id.nav_welcome,
            R.id.nav_checkout,
            R.id.nav_help,
            R.id.nav_product,
            R.id.nav_user
        )
    }
}
