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

package io.worldofluxury.view.cart

import android.content.Intent
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import androidx.navigation.navGraphViewModels
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.skydoves.whatif.whatIfNotNull
import com.stripe.android.CustomerSession
import com.stripe.android.EphemeralKeyProvider
import com.stripe.android.PaymentSession
import dagger.hilt.android.AndroidEntryPoint
import io.worldofluxury.R
import io.worldofluxury.data.Product
import io.worldofluxury.databinding.FragmentCartBinding
import io.worldofluxury.databinding.ItemCartBinding
import io.worldofluxury.viewmodel.CheckoutProgress
import io.worldofluxury.viewmodel.PaymentViewModel
import io.worldofluxury.viewmodel.ProductViewModel
import io.worldofluxury.viewmodel.factory.PaymentViewModelFactory
import io.worldofluxury.viewmodel.factory.ProductViewModelFactory
import timber.log.Timber
import javax.inject.Inject

@AndroidEntryPoint
class CartFragment : Fragment() {

    private lateinit var binding: FragmentCartBinding

    private lateinit var adapter: CartItemsAdapter

    @Inject
    lateinit var factory: ProductViewModelFactory
    private val viewModel by navGraphViewModels<ProductViewModel>(R.id.wol_nav_graph) { factory }

    @Inject
    lateinit var paymentViewModelFactory: PaymentViewModelFactory
    private val paymentVM by navGraphViewModels<PaymentViewModel>(R.id.wol_nav_graph) { paymentViewModelFactory }

    @Inject
    lateinit var keyProvider: EphemeralKeyProvider

    private val paymentSession: PaymentSession by lazy(LazyThreadSafetyMode.SYNCHRONIZED) {
        PaymentSession(
            requireActivity(),
            paymentVM.paymentConfig
        )
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        CustomerSession.initCustomerSession(requireContext(), keyProvider)
    }

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        // Inflate the layout for this fragment
        binding = FragmentCartBinding.inflate(layoutInflater)
        binding.run {
            lifecycleOwner = this@CartFragment
            productViewModel = viewModel
            session = paymentSession
            paymentViewModel = paymentVM

            // setup recyclerview
            adapter = CartItemsAdapter(viewModel)
            favItemsList.adapter = adapter

            // observe products
            viewModel.favorites.observe(viewLifecycleOwner, { products ->
                Timber.i("Products -> $products")
                adapter.submitList(products)
                Timber.e("There are ${adapter.itemCount} items in this list")
            })

            // observe payment module support
            paymentVM.supportsPaymentModule.observe(
                viewLifecycleOwner, {
                    Timber.i("Payment module support -> $it")
                })

            // observe messages fro transaction
            viewModel.toastLiveData.observe(viewLifecycleOwner, {})

            // observe checkout state
            paymentVM.liveCheckoutProgress.observe(viewLifecycleOwner, { state ->
                Timber.i("Checkout state -> $state")
                when (state) {
                    CheckoutProgress.ON_SUCCESS -> {
                        viewModel.clearShoppingCart()
                    }
                    else -> {
                        /*do nothing*/
                    }
                }
            })

            executePendingBindings()
        }
        return binding.root
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        data.whatIfNotNull { paymentSession.handlePaymentData(requestCode, resultCode, it) }
    }

}

// adapter for recyclerview
class CartItemsAdapter constructor(private val viewModel: ProductViewModel) :
    ListAdapter<Product, CartItemViewHolder>(Product.PRODUCT_DIFF) {
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): CartItemViewHolder {
        val binding = ItemCartBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        return CartItemViewHolder(binding, viewModel)
    }

    override fun onBindViewHolder(holder: CartItemViewHolder, position: Int) {
        holder.bind(getItem(position))
    }

}

// viewholder for items
class CartItemViewHolder constructor(
    private val binding: ItemCartBinding,
    private val productViewModel: ProductViewModel
) : RecyclerView.ViewHolder(binding.root) {

    fun bind(item: Product) {
        binding.run {
            product = item
            viewModel = productViewModel
            executePendingBindings()
        }
    }

}