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

package io.worldofluxury.repository.user

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.asLiveData
import io.worldofluxury.core.LocalDataSource
import io.worldofluxury.core.RemoteDataSource
import io.worldofluxury.data.User
import io.worldofluxury.data.sources.UserDataSource
import io.worldofluxury.repository.Repository
import kotlinx.coroutines.ExperimentalCoroutinesApi
import javax.inject.Inject
import javax.inject.Singleton

interface UserRepository : Repository {
    fun watchCurrentUser(toastLiveData: MutableLiveData<String>): LiveData<User?>

    fun updateUser(user: User)

    fun logout() {}
}

/**
 * [Repository] for [User] data source
 */
@Singleton
class DefaultUserRepository @Inject constructor(
    @LocalDataSource
    private val localDataSource: UserDataSource,
    @RemoteDataSource
    private val remoteDataSource: UserDataSource
) : UserRepository {

    @ExperimentalCoroutinesApi
    override fun watchCurrentUser(toastLiveData: MutableLiveData<String>): LiveData<User?> =
        localDataSource.watchCurrentUser(toastLiveData)
            /*remoteDataSource.watchCurrentUser(toastLiveData)
                .onStart { localDataSource.watchCurrentUser(toastLiveData) }
                .transformLatest { value ->
                    localDataSource.updateUser(value)
                    emit(value)
                }
                .flowOn(Dispatchers.IO)
                .onCompletion { Timber.e(it, "watchCurrentUser flow completed") }*/
            .asLiveData()

    override fun updateUser(user: User) {
        localDataSource.updateUser(user)
        remoteDataSource.updateUser(user)
    }

    override fun logout() = localDataSource.logout()
}