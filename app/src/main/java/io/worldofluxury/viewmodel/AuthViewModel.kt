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
import androidx.hilt.Assisted
import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import io.worldofluxury.base.LiveCoroutinesViewModel
import io.worldofluxury.binding.isTooShort
import io.worldofluxury.preferences.UserSharedPreferences
import io.worldofluxury.view.auth.AuthFragment
import kotlinx.coroutines.delay
import timber.log.Timber
import java.util.*
import javax.inject.Inject
import kotlin.random.Random


/**
 * Main [ViewModel] for the [AuthFragment]
 */
class AuthViewModel @ViewModelInject constructor(
    @Assisted private val savedStateHandle: SavedStateHandle
) :
    LiveCoroutinesViewModel() {
    @Inject
    lateinit var userPrefs: UserSharedPreferences

    companion object {
        const val SAVED_AUTH_STATE = "saved-auth-state-key"
    }

    enum class AuthenticationState {
        NONE, AUTHENTICATING, AUTHENTICATED, ERROR
    }

    val authState: MutableLiveData<AuthenticationState> get() = MutableLiveData(AuthenticationState.NONE)
    val snackbarLiveData: MutableLiveData<String> = MutableLiveData()

    init {
        Timber.d("HomeViewModel initialized...")
        savedStateHandle.set(SAVED_AUTH_STATE, AuthenticationState.NONE)
    }

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
        if (Random.nextBoolean()) {
            val uid = UUID.randomUUID().toString()
            userPrefs.save(uid)
            userId.postValue(uid)
            snackbarLiveData.postValue("Login was successful")
            authState.postValue(AuthenticationState.AUTHENTICATED)
        } else {
            authState.postValue(AuthenticationState.ERROR)
            userPrefs.save(null)
            userId.postValue(null)
            snackbarLiveData.postValue("Sorry, we couldn't complete this process")
        }

        // Send live data to observer
        userId
    }

}