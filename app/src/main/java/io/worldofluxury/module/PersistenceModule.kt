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

package io.worldofluxury.module

import android.app.Application
import android.content.Context
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.sqlite.db.SupportSQLiteDatabase
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.components.ApplicationComponent
import io.worldofluxury.database.AppDatabase
import io.worldofluxury.database.dao.ProductDao
import io.worldofluxury.preferences.UserSharedPreferences
import io.worldofluxury.util.DATABASE_NAME
import io.worldofluxury.worker.LoadProductsWorker
import timber.log.Timber
import javax.inject.Singleton

@Module
@InstallIn(ApplicationComponent::class)
object PersistenceModule {

    private fun appDatabaseCallback(context: Context) = object : RoomDatabase.Callback() {
        override fun onCreate(db: SupportSQLiteDatabase) {
            super.onCreate(db)
            Timber.d("Created Swan Database successfully")
            with(WorkManager.getInstance(context)) {
                val worker = OneTimeWorkRequestBuilder<LoadProductsWorker>().build()
                enqueue(worker)
            }
        }
    }

    @Provides
    @Singleton
    fun provideAppDatabase(application: Application): AppDatabase {
        return Room
            .databaseBuilder(application, AppDatabase::class.java, DATABASE_NAME)
            .run {
                fallbackToDestructiveMigration()
                allowMainThreadQueries()
                addCallback(appDatabaseCallback(application.baseContext))
            }
            .build()
    }

    @Provides
    @Singleton
    fun provideProductDao(appDatabase: AppDatabase): ProductDao = appDatabase.productDao()

    @Provides
    @Singleton
    fun provideUserSharedPreferences(application: Application): UserSharedPreferences =
        UserSharedPreferences.get(application.baseContext)
}