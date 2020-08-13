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

package io.worldofluxury.webservice

import com.skydoves.sandwich.ApiResponse
import com.squareup.moshi.Json
import com.squareup.moshi.JsonClass
import io.worldofluxury.data.Product
import io.worldofluxury.data.User
import retrofit2.http.*

/**
 * Web service interface required to setup Retrofit
 * This serves as the app's endpoint to the database server
 */
interface SwanWebService {

    @POST("/products")
    @FormUrlEncoded
    suspend fun getProducts(
        @Field("category") category: String,
        @Field("page") page: Int
    ): ApiResponse<WebServiceResponse<List<Product>>>

    @GET("/users/cart")
    suspend fun getFavorites(): ApiResponse<WebServiceResponse<List<Product>>>

    @GET("/products/{id}")
    suspend fun getProductById(@Path("id") id: String): ApiResponse<WebServiceResponse<Product>>

    @GET("/users/{id}")
    suspend fun getUserById(@Path("id") userId: String?): ApiResponse<WebServiceResponse<User>>

    @PUT("/users/{id}")
    suspend fun updateUserProfile(@Body user: User): ApiResponse<WebServiceResponse<User>>

    @POST("/users/cart/new")
    suspend fun addToCart(@Body product: Product): ApiResponse<WebServiceResponse<List<Product>>>

    companion object {
        const val BASE_URL = "http://10.0.2.2:5000/"
    }
}

/**
 * Response from server
 */
@JsonClass(generateAdapter = true)
data class WebServiceResponse<T>(
    val results: T,
    val page: Long = 1,
    @Json(name = "total_pages")
    val totalPages: Long = 1
)