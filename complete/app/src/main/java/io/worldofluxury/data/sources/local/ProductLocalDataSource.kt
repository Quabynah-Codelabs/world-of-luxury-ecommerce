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

package io.worldofluxury.data.sources.local

import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.asFlow
import androidx.paging.PagedList
import androidx.paging.toLiveData
import io.worldofluxury.data.Product
import io.worldofluxury.data.sources.ProductDataSource
import io.worldofluxury.data.toCartItem
import io.worldofluxury.database.dao.CartDao
import io.worldofluxury.database.dao.ProductDao
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flowOn
import kotlinx.coroutines.flow.onCompletion
import kotlinx.coroutines.flow.transformLatest
import kotlinx.coroutines.launch
import timber.log.Timber
import javax.inject.Inject

/**
 *  @project World of Luxury
 *  @author Bilson Jr.
 *  @by Quabynah Codelabs LLC
 *  @since 12/08/2020 @ 21:51
 */

class DefaultProductLocalDataSource @Inject constructor(
    private val dao: ProductDao,
    private val cartDao: CartDao,
    private val scope: CoroutineScope
) : ProductDataSource {

    @ExperimentalCoroutinesApi
    override fun watchFavorites(): Flow<List<Product>> =
        cartDao.watchAllItems()
            .transformLatest { cartItems ->
                val products = cartItems.map { dao.getProductById(it.productId) }
                emit(products)
            }
            .flowOn(Dispatchers.IO)
            .onCompletion {
                Timber.i("watchFavorites flow completed")
            }

    @ExperimentalCoroutinesApi
    override fun watchProductById(id: String): Flow<Product> =
        dao.watchProductById(id).onCompletion { Timber.i("watchProductById flow completed") }

    @ExperimentalCoroutinesApi
    override fun watchAllProducts(
        category: String,
        toastLiveData: MutableLiveData<String>,
        page: Int
    ): Flow<PagedList<Product>> =
        dao.watchAllProducts(category).toLiveData(pageSize = 10, initialLoadKey = page).asFlow()
            .onCompletion { Timber.i("watchAllProducts flow completed") }

    override suspend fun addToCart(product: Product) {
        scope.launch {
            val updatedProduct = product.copy(isFavorite = !product.isFavorite)
            dao.update(updatedProduct)
            val item = product.toCartItem()
            if (updatedProduct.isFavorite) cartDao.insert(item) else cartDao.delete(item.id)
        }
    }

    override suspend fun storeProduct(product: Product) {
        scope.launch { dao.insert(product) }
    }

}