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

package io.worldofluxury.viewmodel.factory

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import io.worldofluxury.database.dao.UserDao
import io.worldofluxury.preferences.PreferenceStorage
import io.worldofluxury.repository.product.ProductRepository
import io.worldofluxury.repository.user.UserRepository
import io.worldofluxury.view.LauncherViewModel
import io.worldofluxury.view.user.UserViewModel
import io.worldofluxury.viewmodel.AuthViewModel
import io.worldofluxury.viewmodel.ProductViewModel

@Suppress("UNCHECKED_CAST")
class AuthViewModelFactory(
    private val userDao: UserDao,
    private val userPrefs: PreferenceStorage
) : ViewModelProvider.Factory {
    override fun <T : ViewModel?> create(modelClass: Class<T>): T =
        AuthViewModel(userPrefs, userDao) as T
}

@Suppress("UNCHECKED_CAST")
class ProductViewModelFactory(
    private val repository: ProductRepository
) : ViewModelProvider.Factory {
    override fun <T : ViewModel?> create(modelClass: Class<T>): T =
        ProductViewModel(repository) as T
}

@Suppress("UNCHECKED_CAST")
class UserViewModelFactory(
    private val repository: UserRepository
) : ViewModelProvider.Factory {
    override fun <T : ViewModel?> create(modelClass: Class<T>): T =
        UserViewModel(repository) as T
}

@Suppress("UNCHECKED_CAST")
class LaunchViewModelFactory(
    private val prefs: PreferenceStorage
) : ViewModelProvider.Factory {
    override fun <T : ViewModel?> create(modelClass: Class<T>): T =
        LauncherViewModel(prefs) as T
}