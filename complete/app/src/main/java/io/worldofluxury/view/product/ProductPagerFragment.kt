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
import androidx.core.os.bundleOf
import androidx.databinding.DataBindingUtil
import androidx.fragment.app.Fragment
import androidx.fragment.app.viewModels
import androidx.navigation.findNavController
import androidx.navigation.fragment.FragmentNavigatorExtras
import androidx.paging.PagedListAdapter
import androidx.recyclerview.widget.RecyclerView
import androidx.recyclerview.widget.StaggeredGridLayoutManager
import com.google.android.material.transition.Hold
import com.google.android.material.transition.platform.MaterialElevationScale
import com.skydoves.whatif.whatIfNotNull
import dagger.hilt.android.AndroidEntryPoint
import io.worldofluxury.R
import io.worldofluxury.data.Product
import io.worldofluxury.databinding.FragmentProductPagerBinding
import io.worldofluxury.databinding.ItemProductBinding
import io.worldofluxury.util.APP_TAG
import io.worldofluxury.util.ARG_CATEGORY
import io.worldofluxury.view.home.HomeFragmentDirections
import io.worldofluxury.viewmodel.ProductViewModel
import io.worldofluxury.viewmodel.factory.ProductViewModelFactory
import timber.log.Timber
import javax.inject.Inject


/**
 * A simple [Fragment] subclass.
 * Use the [ProductPagerFragment.newInstance] factory method to
 * create an instance of this fragment.
 */
@AndroidEntryPoint
class ProductPagerFragment : Fragment() {
    private var category: String? = null
    private lateinit var binding: FragmentProductPagerBinding

    @Inject
    lateinit var productViewModelFactory: ProductViewModelFactory

    private val viewModel by viewModels<ProductViewModel> { productViewModelFactory }

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        // Inflate the layout for this fragment
        binding =
            DataBindingUtil.inflate(inflater, R.layout.fragment_product_pager, container, false)
        binding.run {
            lifecycleOwner = this@ProductPagerFragment
            executePendingBindings()
        }
        return binding.root
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        Timber.tag(APP_TAG)

        // Setup adapter
        val productsAdapter = ProductsGridAdapter(viewModel)

        // Observe live data
        arguments.whatIfNotNull { bundle ->
            category = bundle.getString(ARG_CATEGORY)
            Timber.d("Category -> $category")
            category.whatIfNotNull { s ->
                viewModel.watchProductsLiveData(s)
                    .observe(viewLifecycleOwner, productsAdapter::submitList)
            }
        }

        // Setup recyclerview
        binding.run {
            with(productsGrid) {
                adapter = productsAdapter
                layoutManager = StaggeredGridLayoutManager(2, StaggeredGridLayoutManager.VERTICAL)
                setHasFixedSize(true)
            }
        }
    }

    companion object {
        @JvmStatic
        fun newInstance(category: String) =
            ProductPagerFragment().apply {
                arguments = bundleOf(ARG_CATEGORY to category)
            }
    }
}


class ProductsGridAdapter(private val viewModel: ProductViewModel) :
    PagedListAdapter<Product, ProductViewHolder>(Product.PRODUCT_DIFF) {
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ProductViewHolder {
        val binding = ItemProductBinding.inflate(
            LayoutInflater.from(parent.context),
            parent,
            false
        )
        return ProductViewHolder(binding, viewModel)
    }

    override fun onBindViewHolder(holder: ProductViewHolder, position: Int) {
        val product = getItem(position)
        product.whatIfNotNull { holder.bind(it) }
    }

}

class ProductViewHolder(
    private val binding: ItemProductBinding,
    private val viewModel: ProductViewModel
) :
    RecyclerView.ViewHolder(binding.root) {

    fun bind(item: Product) {
        binding.run {
            product = item
            vm = viewModel
            root.setOnClickListener {
                if(it.context is Fragment) {
                    with(it.context as Fragment) {
                        exitTransition = Hold().apply {
                            duration = 300L
                        }

                        reenterTransition = MaterialElevationScale(true).apply {
                            duration = 350L
                        }

                    }
                }
                val extras = FragmentNavigatorExtras(binding.productImage to item.id)
                it.findNavController()
                    .navigate(HomeFragmentDirections.actionNavHomeToNavProduct(item), extras)
            }
            executePendingBindings()
        }
    }

}