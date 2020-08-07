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

import android.util.Patterns
import android.view.View
import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.navigation.findNavController
import com.google.android.material.dialog.MaterialAlertDialogBuilder
import io.worldofluxury.R
import io.worldofluxury.base.LiveCoroutinesViewModel
import io.worldofluxury.binding.isTooShort
import io.worldofluxury.data.User
import io.worldofluxury.database.dao.UserDao
import io.worldofluxury.preferences.UserSharedPreferences
import io.worldofluxury.util.APP_TAG
import io.worldofluxury.view.auth.AuthFragment
import io.worldofluxury.view.home.HomeFragmentDirections
import io.worldofluxury.view.welcome.WelcomeFragmentDirections
import kotlinx.coroutines.delay
import timber.log.Timber
import java.util.*


/**
 * Main [ViewModel] for the [AuthFragment]
 */
class AuthViewModel @ViewModelInject constructor(
    private val userPrefs: UserSharedPreferences,
    private val userDao: UserDao
) :
    LiveCoroutinesViewModel() {

    enum class AuthenticationState {
        NONE, AUTHENTICATING, AUTHENTICATED, ERROR
    }

    val authState: MutableLiveData<AuthenticationState> = MutableLiveData(AuthenticationState.NONE)
    val snackbarLiveData: MutableLiveData<String> = MutableLiveData()
    val currentUser: MutableLiveData<User> = MutableLiveData()

    init {
        Timber.tag(APP_TAG)
        Timber.d("AuthViewModel initialized...")
        val isLoggedIn = userPrefs.isLoggedIn.get()
        if (isLoggedIn) authState.value = AuthenticationState.AUTHENTICATED
    }

    // TODO: Implement login
    fun login(email: String, password: String) = launchOnViewModelScope<String> {
        // Create live object
        val userId = MutableLiveData<String>()

        // Validate email & password (should be longer than 6 characters)
        if (!Patterns.EMAIL_ADDRESS.matcher(email).matches() || password.isTooShort()) {
            authState.postValue(AuthenticationState.ERROR)
            snackbarLiveData.postValue("There is a problem with your credentials. Please check and try again")
            return@launchOnViewModelScope userId
        }

        // Begin login process
        authState.postValue(AuthenticationState.AUTHENTICATING)
        snackbarLiveData.postValue("Signing you in...")

        // Simulate network call
        delay(3500)

        // Complete login process
//        if (Random.nextBoolean()) {
        val uid = "6dda2be7-11c5-44e5-b552-f22fa7ad8a4c"
        userPrefs.save(uid)
        userId.postValue(uid)
        val user = User(
            uid,
            "Quabynah",
            "quabynahdennis@gmail.com",
            "https://images.unsplash.com/photo-1514222709107-a180c68d72b4?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=500&q=60"
        )
        userDao.insert(user)
        currentUser.postValue(user)
        snackbarLiveData.postValue("Login was successful")
        authState.postValue(AuthenticationState.AUTHENTICATED)
//        } else {
//            authState.postValue(AuthenticationState.ERROR)
//            userPrefs.save(null)
//            userId.postValue(null)
//            snackbarLiveData.postValue("Sorry, we couldn't complete this process")
//        }

        // Send live data to observer
        userId
    }


    fun navLoginOrHome(view: View) {
        view.findNavController().navigate(
            if (authState.value == AuthenticationState.AUTHENTICATED) WelcomeFragmentDirections.actionNavWelcomeToNavHome()
            else WelcomeFragmentDirections.actionNavWelcomeToNavAuth()
        )
    }

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