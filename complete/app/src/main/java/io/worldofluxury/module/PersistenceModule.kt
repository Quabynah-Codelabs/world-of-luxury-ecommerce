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

import android.content.Context
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.components.ApplicationComponent
import dagger.hilt.android.qualifiers.ApplicationContext
import io.worldofluxury.database.AppDatabase
import io.worldofluxury.database.dao.CartDao
import io.worldofluxury.database.dao.ProductDao
import io.worldofluxury.database.dao.UserDao
import io.worldofluxury.preferences.PreferenceStorage
import io.worldofluxury.preferences.UserSharedPreferences
import javax.inject.Singleton

@Module
@InstallIn(ApplicationComponent::class)
object PersistenceModule {

    @Provides
    @Singleton
    fun provideAppDatabase(@ApplicationContext context: Context): AppDatabase =
        AppDatabase.get(context)

    @Provides
    @Singleton
    fun provideProductDao(appDatabase: AppDatabase): ProductDao = appDatabase.productDao()

    @Provides
    @Singleton
    fun provideUserDao(appDatabase: AppDatabase): UserDao = appDatabase.userDao()

    @Provides
    @Singleton
    fun provideCartDao(appDatabase: AppDatabase): CartDao = appDatabase.cartDao()

    @Provides
    @Singleton
    fun provideUserSharedPreferences(@ApplicationContext context: Context): PreferenceStorage =
        UserSharedPreferences(context)
}