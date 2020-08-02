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

import androidx.lifecycle.LiveData
import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import io.worldofluxury.data.Product

@Dao
interface ProductDao {

    @Query("select * from products order by id desc")
    fun getAllProducts(): LiveData<MutableList<Product>>

    @Query("select * from products where id = :id")
    fun getProductById(id: String): LiveData<Product?>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insertAll(items: MutableList<Product>)

}