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

package io.worldofluxury.view.home

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import androidx.navigation.navGraphViewModels
import androidx.viewpager2.adapter.FragmentStateAdapter
import com.google.android.material.tabs.TabLayoutMediator
import dagger.hilt.android.AndroidEntryPoint
import io.worldofluxury.R
import io.worldofluxury.databinding.HomeFragmentBinding
import io.worldofluxury.util.APP_TAG
import io.worldofluxury.util.CATEGORIES
import io.worldofluxury.viewmodel.AuthViewModel
import io.worldofluxury.viewmodel.HomeViewModel
import io.worldofluxury.viewmodel.factory.AuthViewModelFactory
import timber.log.Timber
import javax.inject.Inject

@AndroidEntryPoint
class HomeFragment : Fragment() {

    private val viewModel by navGraphViewModels<HomeViewModel>(R.id.wol_nav_graph)
    private lateinit var binding: HomeFragmentBinding

    @Inject
    lateinit var authViewModelFactory: AuthViewModelFactory
    private val authVM by navGraphViewModels<AuthViewModel>(R.id.wol_nav_graph) { authViewModelFactory }

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        binding = DataBindingUtil.inflate(inflater, R.layout.home_fragment, container, false)
        binding.run {
            lifecycleOwner = this@HomeFragment
            vm = viewModel
            authViewModel = authVM
        }
        return binding.root
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        Timber.tag(APP_TAG)

        binding.run {
            homePager.adapter = CategoriesViewPagerAdapter(requireActivity())
            TabLayoutMediator(
                homeTabs,
                homePager,
                true,
                true
            ) { tab, position -> tab.text = CATEGORIES[position] }.attach()
            executePendingBindings()
        }
    }

}

class CategoriesViewPagerAdapter constructor(host: FragmentActivity) : FragmentStateAdapter(host) {
    override fun getItemCount(): Int = CATEGORIES.size

    override fun createFragment(position: Int): Fragment = ProductPagerFragment.newInstance(
        CATEGORIES[position]
    )
}