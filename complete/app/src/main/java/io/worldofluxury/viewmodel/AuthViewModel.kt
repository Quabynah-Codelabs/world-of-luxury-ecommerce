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
import android.util.Patterns
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.navigation.Navigation.findNavController
import androidx.navigation.findNavController
import com.google.android.material.dialog.MaterialAlertDialogBuilder
import io.worldofluxury.R
import io.worldofluxury.base.LiveCoroutinesViewModel
import io.worldofluxury.base.launchInBackground
import io.worldofluxury.binding.isTooShort
import io.worldofluxury.data.User
import io.worldofluxury.database.dao.UserDao
import io.worldofluxury.preferences.PreferenceStorage
import io.worldofluxury.util.APP_TAG
import io.worldofluxury.view.auth.AuthFragment
import io.worldofluxury.view.home.HomeFragmentDirections
import io.worldofluxury.view.welcome.WelcomeFragmentDirections
import kotlinx.coroutines.delay
import timber.log.Timber


/**
 * Main [ViewModel] for the [AuthFragment]
 */
class AuthViewModel @ViewModelInject constructor(
    private val userPrefs: PreferenceStorage,
    private val userDao: UserDao
) :
    LiveCoroutinesViewModel(), PreferenceStorage by userPrefs {

    enum class AuthenticationState {
        NONE, AUTHENTICATING, AUTHENTICATED, ERROR
    }

    val authState: MutableLiveData<AuthenticationState> = MutableLiveData(AuthenticationState.NONE)
    val toastLiveData: MutableLiveData<String> = MutableLiveData()
    val currentUser: MutableLiveData<User> = MutableLiveData()

    init {
        Timber.tag(APP_TAG)
        if (userPrefs.isLoggedIn.get()) {
            authState.value = AuthenticationState.AUTHENTICATED
            launchInBackground {
                currentUser.postValue(
                    userDao.getUserById(userPrefs.userId)
                        .apply { Timber.d("Found user -> ${this?.name}") })
            }
        }
    }

    // sign out
    fun logout(v: View) {
        MaterialAlertDialogBuilder(v.context).apply {
            setTitle("Confirmation required")
            setMessage("Do you wish to sign out?")
            setPositiveButton("Yeah") { d, _ ->
                d.dismiss()

                // clear user id from prefs
                userPrefs.userId = null
                // update live data
                currentUser.postValue(null)
                // update auth state
                authState.postValue(AuthenticationState.NONE)
                // navigate to login screen
                if (v.context is AppCompatActivity)
                    findNavController(v.context as Activity, R.id.nav_host_fragment).navigate(
                        HomeFragmentDirections.actionNavHomeToNavAuth()
                    )
            }
            setNegativeButton("Nope") { d, _ ->
                d.dismiss()
            }
        }.show()
    }

    // todo: implement twitter login
    fun twitterLogin(v: View) {

    }

    // TODO: Implement login
    fun login(email: String, password: String) = launchOnViewModelScope<String> {
        // Create live object
        val userId = MutableLiveData<String>()

        // Validate email & password (should be longer than 6 characters)
        if (!Patterns.EMAIL_ADDRESS.matcher(email).matches() || password.isTooShort()) {
            authState.postValue(AuthenticationState.ERROR)
            toastLiveData.postValue("There is a problem with your credentials. Please check and try again")
            return@launchOnViewModelScope userId
        }

        // Begin login process
        authState.postValue(AuthenticationState.AUTHENTICATING)
        toastLiveData.postValue("Signing you in...")

        // Simulate network call
        delay(3500)

        // Complete login process
        val uid = "6dda2be7-11c5-44e5-b552-f22fa7ad8a4c"
        userPrefs.userId = uid
        userId.postValue(uid)
        val user = User(
            uid,
            "Quabynah",
            "quabynahdennis@gmail.com",
            "https://images.unsplash.com/photo-1514222709107-a180c68d72b4?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60"
        )
        userDao.insert(user)
        currentUser.postValue(user)
        toastLiveData.postValue("Login was successful")
        authState.postValue(AuthenticationState.AUTHENTICATED)

        // Send live data to observer
        userId
    }


    fun navLoginOrHome(view: View) {
        view.findNavController().navigate(
            if (userPrefs.isLoggedIn.get()) WelcomeFragmentDirections.actionNavWelcomeToNavHome()
            else WelcomeFragmentDirections.actionNavWelcomeToNavAuth()
        )
    }

    // navigate to login or cart
    fun navLoginOrCart(view: View) {
        val context = view.context
        if (authState.value == AuthenticationState.AUTHENTICATED) {
            view.findNavController().navigate(HomeFragmentDirections.actionNavHomeToNavCart())
        } else {
            MaterialAlertDialogBuilder(context).apply {
                setTitle("Oops...")
                setMessage("Sign in to start shopping with ${context.getString(R.string.app_name)}")
                setPositiveButton("Sign in") { d, _ ->
                    d.dismiss()
                    view.findNavController()
                        .navigate(HomeFragmentDirections.actionNavHomeToNavAuth())
                }
                setNegativeButton("Cancel") { d, _ ->
                    d.dismiss()
                }
            }.show()
        }
    }

}