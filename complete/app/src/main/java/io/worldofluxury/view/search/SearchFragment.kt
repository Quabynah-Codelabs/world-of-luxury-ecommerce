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

package io.worldofluxury.view.search

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.navigation.navGraphViewModels
import dagger.hilt.android.AndroidEntryPoint
import io.worldofluxury.R
import io.worldofluxury.databinding.FragmentSearchBinding
import io.worldofluxury.viewmodel.ProductViewModel
import io.worldofluxury.viewmodel.factory.ProductViewModelFactory
import javax.inject.Inject

@AndroidEntryPoint
class SearchFragment : Fragment() {
    private lateinit var binding: FragmentSearchBinding

    @Inject
    lateinit var productViewModelFactory: ProductViewModelFactory

    private val viewModel by navGraphViewModels<ProductViewModel>(R.id.wol_nav_graph) { productViewModelFactory }


    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        binding = FragmentSearchBinding.inflate(layoutInflater)
        binding.run {
            lifecycleOwner = this@SearchFragment
            vm = viewModel
            executePendingBindings()
        }
        return binding.root
    }


}