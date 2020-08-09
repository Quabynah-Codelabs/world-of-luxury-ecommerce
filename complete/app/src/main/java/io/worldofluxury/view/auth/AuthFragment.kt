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

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import androidx.navigation.fragment.findNavController
import com.skydoves.whatif.whatIfNotNull
import dagger.hilt.android.AndroidEntryPoint
import io.worldofluxury.R
import io.worldofluxury.binding.showSnackBar
import io.worldofluxury.databinding.AuthFragmentBinding
import io.worldofluxury.util.APP_TAG
import io.worldofluxury.viewmodel.AuthViewModel
import io.worldofluxury.viewmodel.factory.AuthViewModelFactory
import timber.log.Timber
import javax.inject.Inject

@AndroidEntryPoint
class AuthFragment : Fragment() {
    private lateinit var binding: AuthFragmentBinding
    private val navController by lazy { findNavController() }

    @Inject
    lateinit var authViewModelFactory: AuthViewModelFactory
    private val viewModel by activityViewModels<AuthViewModel> { authViewModelFactory }

    init {
        Timber.tag(APP_TAG)
    }

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        binding = DataBindingUtil.inflate(inflater, R.layout.auth_fragment, container, false)
        binding.run {
            lifecycleOwner = this@AuthFragment
            vm = viewModel
            executePendingBindings()
        }
        return binding.root
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)

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
                navController.navigate(AuthFragmentDirections.actionNavAuthToNavHome())
            }

            signUpButton.setOnClickListener {
                it.showSnackBar("This option is currently unavailable")
            }

            twitterButton.setOnClickListener {
                /*TODO: Add Twitter login here */
                viewModel.login("q@g.co", "1234").observe(viewLifecycleOwner, { uid ->
                    uid.whatIfNotNull {
                        Timber.d("WorldOfLuxury: User id -> $it")
                    }
                })
            }

            googleButton.setOnClickListener { /*TODO: Add Google login here */ }
        }
    }

}