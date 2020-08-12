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
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
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
import io.worldofluxury.database.dao.UserDao
import io.worldofluxury.preferences.PreferenceStorage
import io.worldofluxury.util.APP_TAG
import io.worldofluxury.view.auth.AuthFragment
import io.worldofluxury.view.welcome.WelcomeFragmentDirections
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

    private val gso: GoogleSignInOptions by lazy {
        GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
            .requestEmail()
            .requestIdToken(BuildConfig.GOOGLE_CLIENT_ID)
            .build()
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
            }
            setNegativeButton("Nope") { d, _ ->
                d.dismiss()
            }
        }.show()
    }

    // todo: implement twitter login
    fun twitterLogin() {

    }

    fun navLoginOrHome(view: View) {
        view.findNavController().navigate(
            if (userPrefs.isLoggedIn.get()) WelcomeFragmentDirections.actionNavWelcomeToNavHome()
            else WelcomeFragmentDirections.actionNavWelcomeToNavAuth()
        )
    }

    // sign in with google
    fun googleLogin(host: Activity, code: Int) {
        // Check for existing Google Sign In account, if the user is already signed in
        // the GoogleSignInAccount will be non-null.
        /*val lastSignedInAccount: GoogleSignInAccount? = GoogleSignIn.getLastSignedInAccount(host)
        lastSignedInAccount.whatIf({ account -> account == null }, {
            Timber.e("Last user account was null")
            val client = GoogleSignIn.getClient(host, gso)
            authState.value = AuthenticationState.AUTHENTICATING
            host.startActivityForResult(client.signInIntent, code)
        }, {
            // create user from google account
            val acct = lastSignedInAccount ?: return
            Timber.i("name -> ${acct.displayName}, email -> ${acct.email} & avatar -> ${acct.photoUrl}")
            val idTokenForServer = acct.idToken
            Timber.i("Token to be sent to server -> $idTokenForServer")
            try {
                val user =
                    User(acct.id!!, acct.displayName!!, acct.email, acct.photoUrl.toString())
                saveUser(user)
            } catch (e: Exception) {
                Timber.e(e)
                authState.value = AuthenticationState.ERROR
            }
        })*/
        val client = GoogleSignIn.getClient(host, gso)
        authState.value = AuthenticationState.AUTHENTICATING
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
                    authState.value = AuthenticationState.ERROR
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
                        authState.value = AuthenticationState.ERROR
                    }
                })
            } catch (e: Exception) {
                Timber.e(e)
                authState.value = AuthenticationState.ERROR
            }
        } else {
            Timber.e("Google auth failed")
            authState.value = AuthenticationState.ERROR
        }
    }


    fun saveUser(user: User) = launchInBackground{
        userDao.insert(user)
        currentUser.postValue(user)
        userPrefs.userId = user.id
        toastLiveData.postValue("Login was successful")
        authState.postValue(AuthenticationState.AUTHENTICATED)
    }
}