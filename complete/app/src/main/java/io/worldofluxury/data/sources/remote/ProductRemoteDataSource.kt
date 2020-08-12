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

package io.worldofluxury.data.sources.remote

import androidx.lifecycle.MutableLiveData
import androidx.paging.PagedList
import com.skydoves.sandwich.onError
import com.skydoves.sandwich.onException
import com.skydoves.sandwich.onFailure
import com.skydoves.sandwich.onSuccess
import com.skydoves.whatif.whatIfNotNull
import io.worldofluxury.core.RemoteDataSource
import io.worldofluxury.data.Product
import io.worldofluxury.data.sources.ProductDataSource
import io.worldofluxury.webservice.SwanWebService
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.launch
import timber.log.Timber
import javax.inject.Inject

/**
 *  @project World of Luxury
 *  @author Bilson Jr.
 *  @by Quabynah Codelabs LLC
 *  @since 12/08/2020 @ 21:50
 */

class DefaultProductRemoteDataSource @RemoteDataSource @Inject constructor(
    private val service: SwanWebService,
    private val scope: CoroutineScope
) : ProductDataSource {

    @ExperimentalCoroutinesApi
    override fun watchFavorites(): Flow<List<Product>> = flow {
        service.getFavorites()
            .whatIfNotNull { apiResponse ->
                apiResponse.onSuccess {
                    // save data to local database
                    scope.launch { data.whatIfNotNull { emit(it.results) } }
                }
                apiResponse.onException {
                    Timber.e("An exception occurred while retrieving data from the favs web service endpoint -> $message")
                }
                apiResponse.onFailure {
                    Timber.e("Failed to retrieve data from the favs web service endpoint")
                }
                apiResponse.onError {
                    Timber.e("An error occurred while retrieving data from the favs web service endpoint -> $errorBody")
                }
            }
    }

    @ExperimentalCoroutinesApi
    override fun watchProductById(id: String): Flow<Product> = flow {
        service.getProductById(id)
            .whatIfNotNull { apiResponse ->
                apiResponse.onSuccess {
                    // save data to local database
                    scope.launch { data.whatIfNotNull { emit(it.results) } }
                }
                apiResponse.onException {
                    Timber.e("An exception occurred while retrieving data from the product web service endpoint -> $message")
                }
                apiResponse.onFailure {
                    Timber.e("Failed to retrieve data from the product web service endpoint")
                }
                apiResponse.onError {
                    Timber.e("An error occurred while retrieving data from the product web service endpoint -> $errorBody")
                }
            }
    }

    @ExperimentalCoroutinesApi
    override fun watchAllProducts(
        category: String,
        toastLiveData: MutableLiveData<String>,
        page: Int
    ): Flow<PagedList<Product>> = flow {
        service.getProducts(category, page)
            .whatIfNotNull { apiResponse ->
                apiResponse.onSuccess {
                    // save data to local database
                    scope.launch {
                        data.whatIfNotNull {
                            // todo: add pages list here
                        }
                    }
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
        service.addToCart(product)
            .whatIfNotNull { apiResponse ->
                apiResponse.onSuccess {
                    // save data to local database
                    Timber.e("Product(s) added to cart successfully")
                }
                apiResponse.onException {
                    Timber.e("An exception occurred while retrieving data from the product web service endpoint -> $message")
                }
                apiResponse.onFailure {
                    Timber.e("Failed to retrieve data from the product web service endpoint")
                }
                apiResponse.onError {
                    Timber.e("An error occurred while retrieving data from the product web service endpoint -> $errorBody")
                }
            }
    }

    override suspend fun storeProduct(product: Product) {
        /*not applicable: no products will be saved from the client's device to the cloud*/
    }

}