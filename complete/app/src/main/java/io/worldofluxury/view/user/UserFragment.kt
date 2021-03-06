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

package io.worldofluxury.view.user

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import dagger.hilt.android.AndroidEntryPoint
import io.worldofluxury.databinding.UserFragmentBinding
import io.worldofluxury.viewmodel.UserViewModel
import io.worldofluxury.viewmodel.factory.UserViewModelFactory
import timber.log.Timber
import javax.inject.Inject

@AndroidEntryPoint
class UserFragment : Fragment() {
    private lateinit var binding: UserFragmentBinding


    @Inject
    lateinit var modelFactory: UserViewModelFactory
    private val viewModel by activityViewModels<UserViewModel> { modelFactory }

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        binding = UserFragmentBinding.inflate(layoutInflater)
        binding.run {
            lifecycleOwner = this@UserFragment
            vm = viewModel
            executePendingBindings()
        }
        return binding.root
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        viewModel.currentUser.observe(viewLifecycleOwner, { user -> Timber.d("User is -> $user") })
    }

}