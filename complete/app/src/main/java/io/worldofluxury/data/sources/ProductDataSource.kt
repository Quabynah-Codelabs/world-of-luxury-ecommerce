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

package io.worldofluxury.data.sources

import androidx.lifecycle.MutableLiveData
import androidx.paging.PagedList
import io.worldofluxury.data.Product
import kotlinx.coroutines.flow.Flow

/**
 *  @project World of Luxury
 *  @author Bilson Jr.
 *  @by Quabynah Codelabs LLC
 *  @since 12/08/2020 @ 21:54
 */
interface ProductDataSource : DataSource {
    fun watchFavorites(): Flow<List<Product>>

    fun watchProductById(id: String): Flow<Product>

    fun watchAllProducts(
        category: String,
        toastLiveData: MutableLiveData<String>,
        page: Int = 1
    ): Flow<PagedList<Product>>

    suspend fun addToCart(product: Product)

    suspend fun storeProduct(product: Product)
}