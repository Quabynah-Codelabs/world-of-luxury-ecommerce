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

import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.components.ApplicationComponent
import io.worldofluxury.core.LocalDataSource
import io.worldofluxury.core.RemoteDataSource
import io.worldofluxury.data.sources.ProductDataSource
import io.worldofluxury.data.sources.UserDataSource
import io.worldofluxury.data.sources.local.DefaultProductLocalDataSource
import io.worldofluxury.data.sources.local.DefaultUserLocalDataSource
import io.worldofluxury.data.sources.remote.DefaultProductRemoteDataSource
import io.worldofluxury.data.sources.remote.DefaultUserRemoteDataSource
import io.worldofluxury.database.dao.CartDao
import io.worldofluxury.database.dao.ProductDao
import io.worldofluxury.database.dao.UserDao
import io.worldofluxury.preferences.PreferenceStorage
import io.worldofluxury.webservice.SwanWebService
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import javax.inject.Singleton

/**
 *  @project World of Luxury
 *  @author Bilson Jr.
 *  @by Quabynah Codelabs LLC
 *  @since 12/08/2020 @ 21:56
 */
@Module
@InstallIn(ApplicationComponent::class)
object DataSourceModule {
    @Singleton
    @Provides
    fun provideBackgroundThread(): CoroutineScope = CoroutineScope(Dispatchers.IO)

    @Singleton
    @Provides
    @LocalDataSource
    fun provideProductLocalDataSource(
        dao: ProductDao,
        cartDao: CartDao,
        scope: CoroutineScope
    ): ProductDataSource =
        DefaultProductLocalDataSource(dao, cartDao, scope)

    @Singleton
    @Provides
    @RemoteDataSource
    fun provideProductRemoteDataSource(
        service: SwanWebService,
        scope: CoroutineScope
    ): ProductDataSource =
        DefaultProductRemoteDataSource(service, scope)

    @Singleton
    @Provides
    @LocalDataSource
    fun provideUserLocalDataSource(
        dao: UserDao,
        prefs: PreferenceStorage,
        scope: CoroutineScope
    ): UserDataSource = DefaultUserLocalDataSource(dao, prefs, scope)

    @Singleton
    @Provides
    @RemoteDataSource
    fun provideUserRemoteDataSource(
        service: SwanWebService,
        prefs: PreferenceStorage,
        scope: CoroutineScope
    ): UserDataSource = DefaultUserRemoteDataSource(service, prefs, scope)
}