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

package io.worldofluxury.repository.product

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.asLiveData
import androidx.lifecycle.liveData
import androidx.paging.PagedList
import io.worldofluxury.core.LocalDataSource
import io.worldofluxury.core.RemoteDataSource
import io.worldofluxury.data.CartItem
import io.worldofluxury.data.Product
import io.worldofluxury.data.sources.ProductDataSource
import io.worldofluxury.repository.Repository
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.FlowPreview
import kotlinx.coroutines.flow.*
import timber.log.Timber
import javax.inject.Inject

interface ProductRepository : Repository {

    fun watchFavorites(): LiveData<List<Product>>

    fun watchFavoritesNonLive(): Flow<List<Product>> = flow {}

    fun watchProductById(id: String): LiveData<Product>

    fun watchAllProducts(
        category: String,
        toastLiveData: MutableLiveData<String>,
        page: Int = 1
    ): LiveData<PagedList<Product>>

    suspend fun addToCart(cartItem: CartItem)

    suspend fun clearCart()
}

/**
 * [Repository] for [ProductDataSource]
 */
class DefaultProductRepository @Inject constructor(
    @LocalDataSource
    private val localDataSource: ProductDataSource,
    @RemoteDataSource
    private val remoteDataSource: ProductDataSource,
) : ProductRepository {

    @FlowPreview
    @ExperimentalCoroutinesApi
    override fun watchProductById(id: String): LiveData<Product> = liveData {
        val liveProduct = localDataSource.watchProductById(id)
            .onCompletion { Timber.e(it, "watchProductById flow completed") }
            .flowOn(Dispatchers.IO)
            .asLiveData()
        emitSource(liveProduct)
        remoteDataSource.watchProductById(id).collectLatest {
            localDataSource.storeProduct(it)
        }
    }

    /**
     * fetch all favorited products
     */
    @ExperimentalCoroutinesApi
    override fun watchFavorites(): LiveData<List<Product>> = liveData {
        val liveFavs = localDataSource.watchFavorites()
            .flowOn(Dispatchers.IO)
            .onCompletion { Timber.e(it, "watchFavorites flow completed") }
            .asLiveData()

        emitSource(liveFavs)
        remoteDataSource.watchFavorites().collectLatest { items ->
            items.forEach { localDataSource.storeProduct(it) }
        }
    }

    override fun watchFavoritesNonLive(): Flow<List<Product>> = localDataSource.watchFavorites()

    /**
     * fetch all products from [category]
     */
    @ExperimentalCoroutinesApi
    override fun watchAllProducts(
        category: String,
        toastLiveData: MutableLiveData<String>,
        page: Int
    ): LiveData<PagedList<Product>> = liveData {
        val liveProducts = localDataSource.watchAllProducts(category, toastLiveData, page)
            .flowOn(Dispatchers.IO)
            .onCompletion { Timber.e(it, "watchAllProducts flow completed") }
            .asLiveData()
        emitSource(liveProducts)

        remoteDataSource.watchAllProductsNonPaged(category, toastLiveData, page)
            .collectLatest { value: List<Product> ->
                value.map { item -> localDataSource.storeProduct(item) }
            }
    }

    override suspend fun addToCart(cartItem: CartItem) {
        localDataSource.addToCart(cartItem)
        remoteDataSource.addToCart(cartItem)
    }

    override suspend fun clearCart() {
        localDataSource.clearCart()
        remoteDataSource.clearCart()
    }

}