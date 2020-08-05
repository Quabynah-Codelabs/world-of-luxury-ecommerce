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

package io.worldofluxury.view.product

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.fragment.app.Fragment
import androidx.navigation.navGraphViewModels
import dagger.hilt.android.AndroidEntryPoint
import io.worldofluxury.R
import io.worldofluxury.data.Product
import io.worldofluxury.databinding.FragmentProductBinding
import io.worldofluxury.util.APP_TAG
import io.worldofluxury.viewmodel.AuthViewModel
import io.worldofluxury.viewmodel.ProductViewModel
import io.worldofluxury.viewmodel.factory.AuthViewModelFactory
import io.worldofluxury.viewmodel.factory.ProductViewModelFactory
import timber.log.Timber
import javax.inject.Inject

@AndroidEntryPoint
class ProductFragment : Fragment() {
    private lateinit var binding: FragmentProductBinding

    @Inject
    lateinit var authViewModelFactory: AuthViewModelFactory

    @Inject
    lateinit var productViewModelFactory: ProductViewModelFactory

    private val viewModel by navGraphViewModels<ProductViewModel>(R.id.wol_nav_graph) { productViewModelFactory }
    private val authVM by navGraphViewModels<AuthViewModel>(R.id.wol_nav_graph) { authViewModelFactory }

//     private val args by navArgs<NavArgs>()

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        Timber.tag(APP_TAG)
        // Inflate the layout for this fragment
        binding = DataBindingUtil.inflate(inflater, R.layout.fragment_product, container, false)
        binding.run {
            lifecycleOwner = this@ProductFragment
            product = arguments?.getParcelable("product") as? Product
            authViewModel = authVM
            productViewModel = viewModel
            executePendingBindings()
        }
        return binding.root
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)

        binding.run {
            /*container.setOnScrollChangeListener { _, _, scrollY, _, _ ->
                if (scrollY != 0) addToBag.shrink()
                else addToBag.extend()
            }*/
        }
    }


}