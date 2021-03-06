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
import io.worldofluxury.view.product.ProductPagerFragment
import io.worldofluxury.viewmodel.ProductViewModel
import io.worldofluxury.viewmodel.UserViewModel
import io.worldofluxury.viewmodel.factory.ProductViewModelFactory
import io.worldofluxury.viewmodel.factory.UserViewModelFactory
import timber.log.Timber
import javax.inject.Inject

@AndroidEntryPoint
class HomeFragment : Fragment() {

    private lateinit var binding: HomeFragmentBinding

    @Inject
    lateinit var authViewModelFactory: UserViewModelFactory
    private val authVM by navGraphViewModels<UserViewModel>(R.id.wol_nav_graph) { authViewModelFactory }

    @Inject
    lateinit var productViewModelFactory: ProductViewModelFactory
    private val viewModel by navGraphViewModels<ProductViewModel>(R.id.wol_nav_graph) { productViewModelFactory }


    init {
        Timber.tag(APP_TAG)
    }

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        binding = HomeFragmentBinding.inflate(layoutInflater)
        binding.run {
            lifecycleOwner = this@HomeFragment
            vm = viewModel
            authViewModel = authVM

            // setup pager
            homePager.adapter = CategoriesViewPagerAdapter(requireActivity())
            TabLayoutMediator(
                homeTabs,
                homePager,
                true,
                true
            ) { tab, position -> tab.text = CATEGORIES[position] }.attach()
            executePendingBindings()

        }
        return binding.root
    }

}

class CategoriesViewPagerAdapter constructor(host: FragmentActivity) : FragmentStateAdapter(host) {
    override fun getItemCount(): Int = CATEGORIES.size

    override fun createFragment(position: Int): Fragment = ProductPagerFragment.newInstance(
        CATEGORIES[position]
    )
}