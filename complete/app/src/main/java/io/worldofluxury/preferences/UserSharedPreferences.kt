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

package io.worldofluxury.preferences

import android.content.Context
import androidx.core.content.edit
import androidx.databinding.ObservableBoolean
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import io.worldofluxury.util.PREFS_NAME
import io.worldofluxury.util.USER_ID_KEY

class UserSharedPreferences private constructor(context: Context) {

    companion object {
        @Volatile
        private var instance: UserSharedPreferences? = null

        @JvmStatic
        fun get(context: Context): UserSharedPreferences = instance ?: synchronized(this) {
            instance ?: UserSharedPreferences(context).also { instance = it }
        }
    }

    private val prefs by lazy {
        context.getSharedPreferences(
            PREFS_NAME,
            Context.MODE_PRIVATE
        )
    }

    private val _liveUserId: MutableLiveData<String> = MutableLiveData()
    val liveUserId: LiveData<String> get() = _liveUserId

    val isLoggedIn: ObservableBoolean = ObservableBoolean(false)

    init {
        with(prefs.getString(USER_ID_KEY, null)) {
            isLoggedIn.set(!this.isNullOrEmpty())
            _liveUserId.postValue(this)
        }
    }

    fun save(id: String?) {
        prefs.edit {
            putString(USER_ID_KEY, id)
            apply()
        }
        isLoggedIn.set(!id.isNullOrEmpty())
        _liveUserId.postValue(id)
    }

}