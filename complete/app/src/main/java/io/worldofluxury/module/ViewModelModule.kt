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

import androidx.lifecycle.ViewModel
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.components.ApplicationComponent
import io.worldofluxury.database.dao.UserDao
import io.worldofluxury.preferences.PreferenceStorage
import io.worldofluxury.repository.product.ProductRepository
import io.worldofluxury.repository.user.UserRepository
import io.worldofluxury.viewmodel.factory.AuthViewModelFactory
import io.worldofluxury.viewmodel.factory.LaunchViewModelFactory
import io.worldofluxury.viewmodel.factory.ProductViewModelFactory
import io.worldofluxury.viewmodel.factory.UserViewModelFactory
import javax.inject.Singleton

/**
 * [Module] for [ViewModel]s
 */
@Module
@InstallIn(ApplicationComponent::class)
object ViewModelModule {

    @Singleton
    @Provides
    fun provideAuthViewModelProvider(
        userDao: UserDao,
        prefs: PreferenceStorage
    ): AuthViewModelFactory =
        AuthViewModelFactory(userDao, prefs)

    @Singleton
    @Provides
    fun provideProductViewModelProvider(
        repository: ProductRepository
    ): ProductViewModelFactory = ProductViewModelFactory(repository)

    @Singleton
    @Provides
    fun provideUserViewModelProvider(
        repository: UserRepository
    ): UserViewModelFactory = UserViewModelFactory(repository)

    @Singleton
    @Provides
    fun provideLaunchViewModelProvider(
        prefs: PreferenceStorage
    ): LaunchViewModelFactory = LaunchViewModelFactory(prefs)


}