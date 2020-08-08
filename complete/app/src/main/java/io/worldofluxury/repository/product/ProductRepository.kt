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
import androidx.lifecycle.liveData
import androidx.lifecycle.switchMap
import androidx.paging.PagedList
import androidx.paging.toLiveData
import com.skydoves.sandwich.onError
import com.skydoves.sandwich.onException
import com.skydoves.sandwich.onFailure
import com.skydoves.sandwich.onSuccess
import com.skydoves.whatif.whatIfNotNull
import io.worldofluxury.data.Product
import io.worldofluxury.data.toCartItem
import io.worldofluxury.database.dao.CartDao
import io.worldofluxury.database.dao.ProductDao
import io.worldofluxury.repository.Repository
import io.worldofluxury.util.APP_TAG
import io.worldofluxury.webservice.SwanWebService
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch
import timber.log.Timber
import javax.inject.Inject

interface ProductRepository : Repository {

    fun watchFavorites(): LiveData<List<Product>>

    fun watchAllProducts(
        category: String,
        toastLiveData: MutableLiveData<String>,
        page: Int = 1
    ): LiveData<PagedList<Product>>

    suspend fun addToCart(product: Product)
}

/**
 * [Repository] for [Product] data source
 */
class DefaultProductRepository @Inject constructor(
    private val webService: SwanWebService,
    private val dao: ProductDao,
    private val cartDao: CartDao,
    private val scope: CoroutineScope
) : ProductRepository {

    init {
        Timber.tag(APP_TAG)
    }

    /**
     * fetch all favorited products
     */
    override fun watchFavorites(): LiveData<List<Product>> = liveData {
        val data = cartDao.watchAllItems().switchMap { items ->
            val result = MutableLiveData<List<Product>>()
            val products = items.map { cartItem -> dao.getProductById(cartItem.productId) }
            result.postValue(products)
            result
        }
        emitSource(data)
    }

    /**
     * fetch all products from [category]
     */
    override fun watchAllProducts(
        category: String,
        toastLiveData: MutableLiveData<String>,
        page: Int
    ): LiveData<PagedList<Product>> =
        liveData {
            // return content from the local database
            emitSource(
                dao.watchAllProducts(category).toLiveData(pageSize = 5, initialLoadKey = page)
            )

            Timber.d("Fetching data from server...")
            // fetch products from server and update local database
            webService.getProducts(category, page)
                .whatIfNotNull { apiResponse ->
                    apiResponse.onSuccess {
                        // save data to local database
                        scope.launch { data.whatIfNotNull { dao.insertAll(it.results) } }
                    }
                    apiResponse.onException {
                        toastLiveData.postValue("Cannot retrieve products at this time")
                        Timber.e("An exception occurred while retrieving data from the products web service endpoint -> $message")
                    }
                    apiResponse.onFailure {
                        toastLiveData.postValue("Cannot retrieve products at this time")
                        Timber.e("Failed to retrieve data from the products web service endpoint")
                    }
                    apiResponse.onError {
                        toastLiveData.postValue("Cannot retrieve products at this time")
                        Timber.e("An error occurred while retrieving data from the products web service endpoint -> $errorBody")
                    }
                }
        }

    override suspend fun addToCart(product: Product) {
        val updatedProduct = product.copy(isFavorite = !product.isFavorite)
        dao.update(updatedProduct)
        val item = product.toCartItem()
        if (updatedProduct.isFavorite) cartDao.insert(item) else cartDao.delete(item.id)
    }

}