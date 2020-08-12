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
import io.worldofluxury.data.Product
import io.worldofluxury.data.sources.ProductDataSource
import io.worldofluxury.data.sources.local.DefaultProductLocalDataSource
import io.worldofluxury.data.sources.remote.DefaultProductRemoteDataSource
import io.worldofluxury.repository.Repository
import io.worldofluxury.util.APP_TAG
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.collectLatest
import timber.log.Timber
import javax.inject.Inject

interface ProductRepository : Repository {

    fun watchFavorites(): LiveData<List<Product>>

    fun watchProductById(id: String): LiveData<Product>

    fun watchAllProducts(
        category: String,
        toastLiveData: MutableLiveData<String>,
        page: Int = 1
    ): LiveData<PagedList<Product>>

    suspend fun addToCart(product: Product)
}

/**
 * [Repository] for [ProductDataSource]
 */
class DefaultProductRepository @Inject constructor(
    @LocalDataSource
    private val localDataSource: DefaultProductLocalDataSource,
    @RemoteDataSource
    private val remoteDataSource: DefaultProductRemoteDataSource,
) : ProductRepository {

    init {
        Timber.tag(APP_TAG)
    }

    @ExperimentalCoroutinesApi
    override fun watchProductById(id: String): LiveData<Product> = liveData {
        emitSource(localDataSource.watchProductById(id).asLiveData())
        remoteDataSource.watchProductById(id)
            .collectLatest { product -> localDataSource.storeProduct(product) }
    }

    /**
     * fetch all favorited products
     */
    @ExperimentalCoroutinesApi
    override fun watchFavorites(): LiveData<List<Product>> = liveData {
        emitSource(localDataSource.watchFavorites().asLiveData())
        remoteDataSource.watchFavorites().collectLatest { products ->
            products.forEach { localDataSource.addToCart(it) }
        }
    }

    /**
     * fetch all products from [category]
     */
    @ExperimentalCoroutinesApi
    override fun watchAllProducts(
        category: String,
        toastLiveData: MutableLiveData<String>,
        page: Int
    ): LiveData<PagedList<Product>> =
        liveData {
            emitSource(localDataSource.watchAllProducts(category, toastLiveData, page).asLiveData())
            remoteDataSource.watchAllProducts(category, toastLiveData, page)
                .collectLatest { products -> products.forEach { localDataSource.storeProduct(it) } }
        }

    override suspend fun addToCart(product: Product) {
        localDataSource.addToCart(product)
        remoteDataSource.addToCart(product)
    }

}