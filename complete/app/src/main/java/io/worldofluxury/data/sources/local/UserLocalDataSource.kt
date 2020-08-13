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

package io.worldofluxury.data.sources.local

import androidx.lifecycle.MutableLiveData
import io.worldofluxury.data.User
import io.worldofluxury.data.sources.UserDataSource
import io.worldofluxury.database.dao.UserDao
import io.worldofluxury.preferences.PreferenceStorage
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.launch
import javax.inject.Inject

/**
 *  @project World of Luxury
 *  @author Bilson Jr.
 *  @by Quabynah Codelabs LLC
 *  @since 12/08/2020 @ 23:49
 */

class DefaultUserLocalDataSource @Inject constructor(
    dao: UserDao,
    prefs: PreferenceStorage,
    private val scope: CoroutineScope
) : UserDataSource, UserDao by dao, PreferenceStorage by prefs {

    override fun watchCurrentUser(toastLiveData: MutableLiveData<String>): Flow<User?> =
        getUserById(userId)

    override fun updateUser(user: User) {
        scope.launch {
            insert(user)
        }
    }

    override fun logout() {
        scope.launch {
            delete(userId)
            userId = null
        }
    }

}