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
import androidx.core.view.doOnPreDraw
import androidx.core.view.updatePadding
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import androidx.navigation.fragment.navArgs
import com.google.android.material.transition.MaterialContainerTransform
import dagger.hilt.android.AndroidEntryPoint
import io.worldofluxury.R
import io.worldofluxury.binding.doOnApplyWindowInsets
import io.worldofluxury.data.Product
import io.worldofluxury.databinding.FragmentProductBinding
import io.worldofluxury.util.APP_TAG
import io.worldofluxury.viewmodel.ProductViewModel
import io.worldofluxury.viewmodel.UserViewModel
import io.worldofluxury.viewmodel.factory.ProductViewModelFactory
import io.worldofluxury.viewmodel.factory.UserViewModelFactory
import timber.log.Timber
import javax.inject.Inject

/**
 * Shows [Product] details
 */
@AndroidEntryPoint
class ProductFragment : Fragment() {
    private lateinit var binding: FragmentProductBinding

    @Inject
    lateinit var authViewModelFactory: UserViewModelFactory

    @Inject
    lateinit var productViewModelFactory: ProductViewModelFactory

    private val productViewModel by activityViewModels<ProductViewModel> { productViewModelFactory }
    private val authViewModel by activityViewModels<UserViewModel> { authViewModelFactory }

    private val args by navArgs<ProductFragmentArgs>()

    override fun onCreate(savedInstanceState: Bundle?) {
        sharedElementEnterTransition = MaterialContainerTransform().apply {
            duration = 300L
            isElevationShadowEnabled = true
            setAllContainerColors(requireContext().getColor(R.color.color_surface_secondary))
        }

        super.onCreate(savedInstanceState)
    }

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        Timber.tag(APP_TAG)
        // Inflate the layout for this fragment
        binding = FragmentProductBinding.inflate(layoutInflater)
        binding.run {
            lifecycleOwner = this@ProductFragment
            authViewModel = this@ProductFragment.authViewModel
            productViewModel = this@ProductFragment.productViewModel
            host = requireActivity()

            root.doOnApplyWindowInsets { v, insets, padding ->
                v.updatePadding(bottom = padding.bottom + insets.systemWindowInsetBottom)
            }

            // observe product
            this@ProductFragment.productViewModel.watchProductByID(args.product.id)
                .observe(viewLifecycleOwner, {
                    // update product in real-time
                    product = it
                })

            executePendingBindings()
        }
        return binding.root
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        postponeEnterTransition()
        view.doOnPreDraw { startPostponedEnterTransition() }
    }
}