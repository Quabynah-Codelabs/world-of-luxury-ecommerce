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

package io.worldofluxury.database

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.sqlite.db.SupportSQLiteDatabase
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager
import io.worldofluxury.data.Product
import io.worldofluxury.data.User
import io.worldofluxury.database.dao.ProductDao
import io.worldofluxury.database.dao.UserDao
import io.worldofluxury.util.APP_TAG
import io.worldofluxury.util.DATABASE_NAME
import io.worldofluxury.util.DATABASE_VERSION
import io.worldofluxury.worker.LoadProductsWorker
import timber.log.Timber

@Database(entities = [Product::class, User::class], version = DATABASE_VERSION, exportSchema = true)
abstract class AppDatabase : RoomDatabase() {

    abstract fun userDao(): UserDao

    abstract fun productDao(): ProductDao

    companion object {

        private fun appDatabaseCallback(context: Context) = object : RoomDatabase.Callback() {
            override fun onCreate(db: SupportSQLiteDatabase) {
                super.onCreate(db)
                Timber.tag(APP_TAG)
                Timber.d("Created Swan Database successfully")
                with(WorkManager.getInstance(context)) {
                    val worker = OneTimeWorkRequestBuilder<LoadProductsWorker>().build()
                    enqueue(worker)
                }
            }
        }

        @Volatile
        private var instance: AppDatabase? = null

        @JvmStatic
        fun get(context: Context): AppDatabase = instance ?: synchronized(this) {
            instance ?: Room
                .databaseBuilder(context, AppDatabase::class.java, DATABASE_NAME)
                .run {
                    fallbackToDestructiveMigration()
                    allowMainThreadQueries()
                    addCallback(appDatabaseCallback(context))
                }
                .build()
        }
    }
}