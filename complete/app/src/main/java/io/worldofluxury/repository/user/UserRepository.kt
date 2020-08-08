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
import androidx.lifecycle.liveData
import androidx.lifecycle.switchMap
import com.skydoves.sandwich.onError
import com.skydoves.sandwich.onException
import com.skydoves.sandwich.onFailure
import com.skydoves.sandwich.onSuccess
import com.skydoves.whatif.whatIfNotNull
import io.worldofluxury.data.User
import io.worldofluxury.database.dao.UserDao
import io.worldofluxury.preferences.PreferenceStorage
import io.worldofluxury.repository.Repository
import io.worldofluxury.util.APP_TAG
import io.worldofluxury.webservice.SwanWebService
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch
import timber.log.Timber
import javax.inject.Inject

/**
 * [Repository] for [User] data source
 */
class UserRepository @Inject constructor(
    private val dao: UserDao,
    private val prefs: PreferenceStorage,
    private val webService: SwanWebService,
    private val scope: CoroutineScope
) : Repository {

    init {
        Timber.tag(APP_TAG)
    }

    // checks for the login state of the current user.
    // fetches the live user instance by converting the user id live data to a live
    // user object.
    fun watchCurrentUser(toastLiveData: MutableLiveData<String>): LiveData<User> = liveData {
        if (!prefs.isLoggedIn.get()) return@liveData
        // get live user instance
        val user: LiveData<User> = prefs.liveUserId.switchMap { dao.watchUserById(it) }
        // pass it to live data
        emitSource(user)

        // perform network call for user data
        webService.getUserById(prefs.userId).whatIfNotNull { response ->
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
                    scope.launch {
                        data.whatIfNotNull {
                            dao.insert(it.results)
                        }
                    }
                }

            }
        }

    }

}