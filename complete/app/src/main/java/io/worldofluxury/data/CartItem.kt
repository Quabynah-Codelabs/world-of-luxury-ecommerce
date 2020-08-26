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
import androidx.room.*
import com.squareup.moshi.JsonClass
import kotlinx.android.parcel.IgnoredOnParcel
import kotlinx.android.parcel.Parcelize

/**
 *  @project World of Luxury
 *  @author Bilson Jr.
 *  @by Quabynah Codelabs LLC
 *  @since 08/08/2020 @ 12:13
 */
@JsonClass(generateAdapter = true)
@Entity(
    tableName = "carts", foreignKeys = [
        ForeignKey(
            entity = Product::class,
            parentColumns = ["id"],
            childColumns = ["prod_id"],
            onDelete = ForeignKey.CASCADE
        )
    ], indices = [Index(value = ["prod_id"], name = "prod_id", unique = true)]
)
@Parcelize
data class CartItem(
    @ColumnInfo(name = "prod_id")
    @PrimaryKey
    val productId: String,
    val price: Double = 10.0,
    var units: Int = 1
) : Parcelable {

    @Ignore
    fun isNotEmpty(): Boolean = units >= 1

    companion object {
        /**
         * For recyclerview's adapter use
         * Helps to de-duplicate data in a list
         */
        val CART_DIFF: DiffUtil.ItemCallback<CartItem> =
            object : DiffUtil.ItemCallback<CartItem>() {
                override fun areItemsTheSame(oldItem: CartItem, newItem: CartItem): Boolean =
                    oldItem.productId == newItem.productId

                override fun areContentsTheSame(oldItem: CartItem, newItem: CartItem): Boolean =
                    oldItem == newItem
            }
    }

}