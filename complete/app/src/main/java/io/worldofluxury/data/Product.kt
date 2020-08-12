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

package io.worldofluxury.data

import android.os.Parcelable
import androidx.recyclerview.widget.DiffUtil
import androidx.room.Entity
import androidx.room.Ignore
import androidx.room.PrimaryKey
import com.squareup.moshi.Json
import com.squareup.moshi.JsonClass
import io.worldofluxury.util.CATEGORIES
import kotlinx.android.parcel.Parcelize

/**
 * Product data model
 */
@Entity(tableName = "products")
@Parcelize
@JsonClass(generateAdapter = true)
data class Product(
    @PrimaryKey val id: String,
    val name: String,
    val description: String,
    val price: Double,
    @Json(name = "currency_id")
    val currencyId: String = "USD",
    @Json(name = "currency_format")
    val currencyFormat: String = "$",
    @Json(name = "shippable")
    val isFreeShipping: Boolean = false,
    val category: String = CATEGORIES[5],
    @Json(name = "photo_url")
    val photoUrl: String? = null,
    @Json(name = "favorite")
    var isFavorite: Boolean = false
) : Parcelable {

    @Ignore
    fun getFormattedPrice(): String = "$currencyFormat $price"

    companion object {
        /**
         * For recyclerview's adapter use
         * Helps to de-duplicate data in a list
         */
        val PRODUCT_DIFF: DiffUtil.ItemCallback<Product> =
            object : DiffUtil.ItemCallback<Product>() {
                override fun areItemsTheSame(oldItem: Product, newItem: Product): Boolean =
                    oldItem.id == newItem.id

                override fun areContentsTheSame(oldItem: Product, newItem: Product): Boolean =
                    oldItem == newItem
            }
    }
}

/**
 * Converts a [Product] into a [CartItem]
 */
fun Product.toCartItem(): CartItem = CartItem(productId = id, price = price)