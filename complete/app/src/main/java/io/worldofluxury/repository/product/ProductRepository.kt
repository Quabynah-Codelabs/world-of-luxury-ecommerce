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

import androidx.annotation.VisibleForTesting
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.liveData
import com.skydoves.sandwich.onError
import com.skydoves.sandwich.onException
import com.skydoves.sandwich.onFailure
import com.skydoves.sandwich.onSuccess
import com.skydoves.whatif.whatIfNotNull
import io.worldofluxury.data.Product
import io.worldofluxury.database.dao.ProductDao
import io.worldofluxury.repository.Repository
import io.worldofluxury.util.APP_TAG
import io.worldofluxury.webservice.SwanWebService
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch
import timber.log.Timber
import javax.inject.Inject

/**
 * [Repository] for [Product] data source
 */
class ProductRepository @Inject constructor(
    private val webService: SwanWebService,
    private val dao: ProductDao,
    private val scope: CoroutineScope
) : Repository {

    init {
        Timber.tag(APP_TAG)
    }

    /**
     * fetch all products from [category]
     */
    @VisibleForTesting
    fun watchAllProducts(
        category: String,
        toastLiveData: MutableLiveData<String>,
        page: Long = 1
    ): LiveData<List<Product>> =
        liveData {
            // return content from the local database
            emitSource(dao.watchAllProducts(category))

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

    suspend fun addToCart(product: Product): Unit =
        TODO("create a cart data model & dao and add product ids")

    suspend fun update(product: Product) = dao.update(product)

}