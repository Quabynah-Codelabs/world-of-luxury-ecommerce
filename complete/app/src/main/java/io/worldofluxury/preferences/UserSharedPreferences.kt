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
import androidx.appcompat.app.AppCompatDelegate
import androidx.core.content.edit
import androidx.databinding.ObservableBoolean
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import io.worldofluxury.util.APP_THEME_KEY
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
    private val _liveTheme: MutableLiveData<Int> = MutableLiveData()
    val liveTheme: LiveData<Int> get() = _liveTheme

    val isLoggedIn: ObservableBoolean = ObservableBoolean(false)
    val isDarkMode: ObservableBoolean = ObservableBoolean(false)

    init {
        with(prefs.getString(USER_ID_KEY, null)) {
            isLoggedIn.set(!this.isNullOrEmpty())
            _liveUserId.postValue(this)
        }

        with(prefs.getBoolean(APP_THEME_KEY, false)) {
            isDarkMode.set(!this)
            _liveTheme.postValue(AppCompatDelegate.MODE_NIGHT_NO)
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

    fun updateTheme() {
        with(isDarkMode) {
            val mode =
                if (get()) AppCompatDelegate.MODE_NIGHT_NO else AppCompatDelegate.MODE_NIGHT_YES
            _liveTheme.postValue(mode)
            AppCompatDelegate.setDefaultNightMode(mode)
            set(mode == AppCompatDelegate.MODE_NIGHT_YES)
            prefs.edit {
                putBoolean(APP_THEME_KEY, get())
                apply()
            }
        }
    }

}