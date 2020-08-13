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

package io.worldofluxury.data.sources.remote

import androidx.lifecycle.MutableLiveData
import com.skydoves.sandwich.onError
import com.skydoves.sandwich.onException
import com.skydoves.sandwich.onFailure
import com.skydoves.sandwich.onSuccess
import com.skydoves.whatif.whatIfNotNull
import io.worldofluxury.data.User
import io.worldofluxury.data.sources.UserDataSource
import io.worldofluxury.preferences.PreferenceStorage
import io.worldofluxury.webservice.SwanWebService
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow
import kotlinx.coroutines.launch
import timber.log.Timber
import javax.inject.Inject

/**
 *  @project World of Luxury
 *  @author Bilson Jr.
 *  @by Quabynah Codelabs LLC
 *  @since 12/08/2020 @ 23:50
 */
class DefaultUserRemoteDataSource @Inject constructor(
    service: SwanWebService,
    prefs: PreferenceStorage,
    private val scope: CoroutineScope
) : UserDataSource, SwanWebService by service, PreferenceStorage by prefs {

    override fun watchCurrentUser(toastLiveData: MutableLiveData<String>): Flow<User> = flow {
        val uid = userId ?: return@flow
        getUserById(uid)
            .whatIfNotNull { response ->
                with(response) {
                    onError {
                        toastLiveData.postValue("Cannot get user data at this time")
                        Timber.e("An error occurred while retrieving user data -> $errorBody")
                    }

                    onException {
                        toastLiveData.postValue("Cannot get user data at this time")
                        Timber.e("An exception occurred while retrieving user data -> $message")
                    }

                    onFailure {
                        toastLiveData.postValue("Cannot get user data at this time")
                        Timber.e("Failed occurred while retrieving user data")
                    }

                    // save data to the local database
                    onSuccess {
                        Timber.i("User retrieved successfully")
                        scope.launch {
                            data.whatIfNotNull {
                                emit(it.results)
                            }
                        }
                    }
                }
            }
    }

    override fun updateUser(user: User) {
        scope.launch {
            updateUserProfile(user).whatIfNotNull { response ->
                with(response) {
                    onError {
                        Timber.e("An error occurred while updating user data -> $errorBody")
                    }

                    onException {
                        Timber.e("An exception occurred while updating user data -> $message")
                    }

                    onFailure {
                        Timber.e("Failed occurred while updating user data")
                    }

                    // save data to the local database
                    onSuccess {
                        Timber.i("User updated successfully")
                    }
                }
            }
        }
    }

}