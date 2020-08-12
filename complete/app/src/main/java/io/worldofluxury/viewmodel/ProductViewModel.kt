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

package io.worldofluxury.viewmodel

import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.paging.PagedList
import io.worldofluxury.base.LiveCoroutinesViewModel
import io.worldofluxury.base.launchInBackground
import io.worldofluxury.data.Product
import io.worldofluxury.repository.product.ProductRepository
import io.worldofluxury.util.APP_TAG
import timber.log.Timber

/**
 * Main [ViewModel] for all [Product]s
 */
class ProductViewModel @ViewModelInject constructor(
    private val repository: ProductRepository
) : LiveCoroutinesViewModel() {

    val toastLiveData: MutableLiveData<String> = MutableLiveData()
    val favorites: LiveData<List<Product>> = launchOnViewModelScope { repository.watchFavorites() }

    init {
        Timber.tag(APP_TAG)
        Timber.d("ProductViewModel initialized...")
    }

    fun watchProductsLiveData(category: String): LiveData<PagedList<Product>> =
        launchOnViewModelScope { repository.watchAllProducts(category, toastLiveData) }

    fun addToCart(item: Product) =
        launchInBackground { repository.addToCart(item) }

    fun watchProductById(id: String) = launchOnViewModelScope { repository.watchProductById(id) }
}