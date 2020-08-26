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

package io.worldofluxury.worker

import android.content.Context
import androidx.hilt.Assisted
import androidx.hilt.work.WorkerInject
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import com.google.gson.stream.JsonReader
import io.worldofluxury.data.Product
import io.worldofluxury.database.dao.ProductDao
import io.worldofluxury.util.APP_TAG
import io.worldofluxury.util.PRODUCT_JSON_FILENAME
import kotlinx.coroutines.coroutineScope
import timber.log.Timber
import java.io.IOException

class LoadProductsWorker @WorkerInject constructor(
    @Assisted appContext: Context,
    @Assisted workerParams: WorkerParameters,
    private val productDao: ProductDao
) : CoroutineWorker(appContext, workerParams) {

    init {
        Timber.tag(APP_TAG)
    }

    override suspend fun doWork(): Result = coroutineScope {

        try {
            applicationContext.assets.open(PRODUCT_JSON_FILENAME).use { inputStream ->
                JsonReader(inputStream.reader()).use { jsonReader ->
                    val type = object : TypeToken<List<Product>>() {}.type
                    val list: List<Product> = Gson().fromJson(jsonReader, type)

                    productDao.insertAllProducts(list.toMutableList())
                    Timber.d("Products added to database successfully")
                    Result.success()
                }
            }
        } catch (ex: IOException) {
            Timber.e("Error adding products to database")
            Result.failure()
        }
    }
}