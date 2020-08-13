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
import androidx.lifecycle.*
import androidx.navigation.findNavController
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import com.google.android.gms.common.api.ApiException
import com.google.android.material.dialog.MaterialAlertDialogBuilder
import com.skydoves.whatif.whatIf
import io.worldofluxury.BuildConfig
import io.worldofluxury.base.LiveCoroutinesViewModel
import io.worldofluxury.base.launchInBackground
import io.worldofluxury.data.User
import io.worldofluxury.preferences.PreferenceStorage
import io.worldofluxury.repository.user.UserRepository
import io.worldofluxury.util.APP_TAG
import io.worldofluxury.view.welcome.WelcomeFragmentDirections
import timber.log.Timber

enum class AuthenticationState {
    NONE, AUTHENTICATED
}

/**
 * Main [ViewModel] for the [UserRepository]
 */
class UserViewModel @ViewModelInject constructor(
    userPrefs: PreferenceStorage,
    repository: UserRepository
) : LiveCoroutinesViewModel(), PreferenceStorage by userPrefs, UserRepository by repository {

    private val gso: GoogleSignInOptions by lazy {
        GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
            .requestEmail()
            .requestIdToken(BuildConfig.GOOGLE_CLIENT_ID)
            .build()
    }

    val toastLiveData: MutableLiveData<String> = MutableLiveData()
    val currentUser: LiveData<User?> = repository.watchCurrentUser(toastLiveData)
    val authState: LiveData<AuthenticationState> = currentUser.switchMap { user ->
        if (user == null) liveData { emit(AuthenticationState.NONE) }
        else liveData { emit(AuthenticationState.AUTHENTICATED) }
    }

    // sign out
    fun signOut(v: View) {
        MaterialAlertDialogBuilder(v.context).apply {
            setTitle("Confirmation required")
            setMessage("Do you wish to sign out?")
            setPositiveButton("Yeah") { d, _ ->
                // logout user & delete data
                logout()
                d.dismiss()
            }
            setNegativeButton("Nope") { d, _ ->
                d.dismiss()
            }
        }.show()
    }

    // navigate to home or auth
    fun navLoginOrHome(view: View) {
        view.findNavController().navigate(
            if (isLoggedIn.get()) WelcomeFragmentDirections.actionNavWelcomeToNavHome()
            else WelcomeFragmentDirections.actionNavWelcomeToNavAuth()
        )
    }

    // sign in with google
    fun googleLogin(host: Activity, code: Int) {
        val client = GoogleSignIn.getClient(host, gso)
        host.startActivityForResult(client.signInIntent, code)
    }

    // get user data from login
    fun getUserFromGoogleSignInResult(resultCode: Int, data: Intent?) {
        Timber.tag(APP_TAG)
        if (resultCode == Activity.RESULT_OK) {
            try {
                val signedInAccountFromIntent = GoogleSignIn.getSignedInAccountFromIntent(data)
                val signInAccount =
                    signedInAccountFromIntent.getResult(ApiException::class.java)
                Timber.i("Account signed in as -> ${signInAccount?.idToken}")
                signInAccount.whatIf({ account -> account == null }, {
                    Timber.e("User account was null")
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
                    }
                })
            } catch (e: Exception) {
                Timber.e(e)
            }
        } else {
            Timber.e("Google auth failed")
        }
    }

    // save user data locally
    private fun saveUser(user: User) = launchInBackground {
        userId = user.id
        Timber.e("User id -> $userId")
        updateUser(user)
    }
}