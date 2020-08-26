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

package io.worldofluxury.database.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import io.worldofluxury.data.CartItem
import kotlinx.coroutines.flow.Flow

/**
 *  @project World of Luxury
 *  @author Bilson Jr.
 *  @by Quabynah Codelabs LLC
 *  @since 08/08/2020 @ 12:16
 */
@Dao
interface CartDao {

    @Query("select * from carts order by prod_id asc")
    fun observeCartItems(): Flow<List<CartItem>>

    @Query("select * from carts order by prod_id asc")
    fun getCartItems(): List<CartItem>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertItemIntoCart(cartItem: CartItem)

    @Query("delete from carts where prod_id = :id")
    suspend fun deleteItemFromCart(id: String)

    @Query("delete from carts")
    suspend fun clearCartItems()

}