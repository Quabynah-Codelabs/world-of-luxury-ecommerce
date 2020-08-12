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

package io.worldofluxury.view.auth

import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import androidx.navigation.fragment.findNavController
import com.twitter.sdk.android.core.*
import com.twitter.sdk.android.core.identity.TwitterAuthClient
import com.twitter.sdk.android.core.models.User
import dagger.hilt.android.AndroidEntryPoint
import io.worldofluxury.R
import io.worldofluxury.binding.checkAllMatched
import io.worldofluxury.databinding.AuthFragmentBinding
import io.worldofluxury.util.APP_TAG
import io.worldofluxury.viewmodel.AuthViewModel
import io.worldofluxury.viewmodel.factory.AuthViewModelFactory
import retrofit2.Call
import retrofit2.Response
import timber.log.Timber
import javax.inject.Inject

@AndroidEntryPoint
class AuthFragment : Fragment() {
    private lateinit var binding: AuthFragmentBinding
    private val navController by lazy { findNavController() }
    private val twitterAuthClient: TwitterAuthClient? by lazy { TwitterAuthClient() }

    @Inject
    lateinit var authViewModelFactory: AuthViewModelFactory
    private val viewModel by activityViewModels<AuthViewModel> { authViewModelFactory }

    init {
        Timber.tag(APP_TAG)
    }

    private val twitterAuthCallback = object : Callback<TwitterSession?>() {
        override fun success(result: Result<TwitterSession?>?) {
            val session = result?.data
            getTwitterData(session)
        }

        override fun failure(exception: TwitterException?) {
            Timber.e(exception)
        }
    }

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        binding = DataBindingUtil.inflate(inflater, R.layout.auth_fragment, container, false)
        binding.run {
            lifecycleOwner = this@AuthFragment
            vm = viewModel

            // Observe login state
            viewModel.authState.observe(viewLifecycleOwner, { state ->
                with(state) {
                    when (this) {
                        AuthViewModel.AuthenticationState.ERROR -> {

                        }
                        AuthViewModel.AuthenticationState.AUTHENTICATED -> {
                            navController.navigate(AuthFragmentDirections.actionNavAuthToNavHome())
                        }
                        AuthViewModel.AuthenticationState.AUTHENTICATING -> {
                        }
                        AuthViewModel.AuthenticationState.NONE -> {
                        }
                        else -> {

                        }
                    }
                }
            })

            binding.run {
                signInButton.setOnClickListener {
                    // sign in as guest
                    navController.navigate(AuthFragmentDirections.actionNavAuthToNavHome())
                }

                twitterButton.setOnClickListener {

                    val activeSession = TwitterCore.getInstance().sessionManager.activeSession
                    if (activeSession == null) {
                        twitterAuthClient?.authorize(requireActivity(), twitterAuthCallback)
                    } else
                        getTwitterData(activeSession)

                }

                googleButton.setOnClickListener {
                    viewModel.googleLogin(requireActivity(), RC_GOOGLE)
                }
            }

            executePendingBindings()
        }
        return binding.root
    }

    // get twitter data from session
    private fun getTwitterData(session: TwitterSession?) {
        if (session == null) {
            Timber.e("Twitter session is null")
            return
        }

        // get user credentials from session
        with(TwitterApiClient(session)) {
            val verifyCredentials = accountService.verifyCredentials(true, false, true)
            verifyCredentials.enqueue(object : retrofit2.Callback<User?> {
                override fun onResponse(call: Call<User?>, response: Response<User?>) {
                    val user = response.body()
                    val name = user?.name
                    val email = user?.email
                    val profileImageUrl = user?.profileImageUrl

                    // log user
                    Timber.i("Twitter user -> name: $name, email: $email, avatar: $profileImageUrl")

                    // todo: save user to viewModel
                }

                override fun onFailure(call: Call<User?>, t: Throwable) {
                    Timber.e(t)
                }
            })
        }

    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        when (requestCode) {
            RC_GOOGLE -> viewModel.getUserFromGoogleSignInResult(resultCode, data)

            else -> {
                /*do nothing*/
            }
        }.checkAllMatched
        twitterAuthClient?.onActivityResult(requestCode, resultCode, data)
    }

    companion object {
        const val RC_GOOGLE = 123
    }

}