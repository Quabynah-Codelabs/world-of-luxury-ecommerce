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
import androidx.databinding.ObservableField
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import io.worldofluxury.util.APP_TAG
import io.worldofluxury.util.APP_THEME_KEY
import io.worldofluxury.util.PREFS_NAME
import io.worldofluxury.util.USER_ID_KEY
import timber.log.Timber

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
    val isFeatureAvailable: ObservableBoolean = ObservableBoolean(true)
    val userId: ObservableField<String> = ObservableField()

    init {
        Timber.tag(APP_TAG)
        with(prefs.getString(USER_ID_KEY, null)) {
            Timber.d("User id -> $this")
            isLoggedIn.set(!this.isNullOrEmpty())
            userId.set(this)
            _liveUserId.postValue(this)
        }

        with(prefs.getBoolean(APP_THEME_KEY, false)) {
            isDarkMode.set(this)
            val mode =
                if (this) AppCompatDelegate.MODE_NIGHT_NO else AppCompatDelegate.MODE_NIGHT_YES
            _liveTheme.postValue(mode)
            AppCompatDelegate.setDefaultNightMode(mode)
        }

        // todo: enable feature support for image scanning
    }

    // save user id
    fun save(id: String?) {
        prefs.edit {
            putString(USER_ID_KEY, id)
            apply()
        }
        isLoggedIn.set(!id.isNullOrEmpty())
        userId.set(id)
        _liveUserId.postValue(id)
    }

    // update theme
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