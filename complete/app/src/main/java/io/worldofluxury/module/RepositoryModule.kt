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
import io.worldofluxury.data.sources.local.DefaultProductLocalDataSource
import io.worldofluxury.data.sources.local.DefaultUserLocalDataSource
import io.worldofluxury.data.sources.remote.DefaultProductRemoteDataSource
import io.worldofluxury.data.sources.remote.DefaultUserRemoteDataSource
import io.worldofluxury.repository.Repository
import io.worldofluxury.repository.product.DefaultProductRepository
import io.worldofluxury.repository.product.ProductRepository
import io.worldofluxury.repository.user.DefaultUserRepository
import io.worldofluxury.repository.user.UserRepository
import javax.inject.Singleton

/**
 * [Module] for all [Repository] subclasses
 */
@Module
@InstallIn(ApplicationComponent::class)
object RepositoryModule {

    @Singleton
    @Provides
    fun provideProductRepository(
        @RemoteDataSource
        remoteDataSource: DefaultProductRemoteDataSource,
        @LocalDataSource
        localDataSource: DefaultProductLocalDataSource
    ): ProductRepository = DefaultProductRepository(localDataSource, remoteDataSource)

    @Singleton
    @Provides
    fun provideUserRepository(
        @RemoteDataSource
        remoteDataSource: DefaultUserRemoteDataSource,
        @LocalDataSource
        localDataSource: DefaultUserLocalDataSource
    ): UserRepository = DefaultUserRepository(localDataSource, remoteDataSource)

}