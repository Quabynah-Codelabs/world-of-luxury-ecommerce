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
import android.content.SharedPreferences
import androidx.annotation.WorkerThread
import androidx.appcompat.app.AppCompatDelegate
import androidx.core.content.edit
import androidx.databinding.ObservableBoolean
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import com.skydoves.whatif.whatIfNotNull
import dagger.hilt.android.qualifiers.ApplicationContext
import io.worldofluxury.util.*
import timber.log.Timber
import javax.inject.Inject
import javax.inject.Singleton
import kotlin.properties.ReadWriteProperty
import kotlin.reflect.KProperty

interface PreferenceStorage {
    var onboardingCompleted: Boolean
    var userId: String?
    var currentTheme: Int

}

@Singleton
class UserSharedPreferences @Inject constructor(@ApplicationContext context: Context) :
    PreferenceStorage {

    private val prefs: Lazy<SharedPreferences> = lazy {
        context.applicationContext.getSharedPreferences(
            PREFS_NAME,
            Context.MODE_PRIVATE
        ).apply { registerOnSharedPreferenceChangeListener(changeListener) }
    }

    private val changeListener = SharedPreferences.OnSharedPreferenceChangeListener { _, key ->
        when (key) {
            USER_ID_KEY -> _liveUserId.value = userId
            APP_THEME_KEY -> {
                _liveTheme.value = currentTheme
                AppCompatDelegate.setDefaultNightMode(currentTheme)
            }
            ONBOARDING_KEY -> _onboardingState.value = onboardingCompleted
        }
    }

    private val _liveUserId: MutableLiveData<String> = MutableLiveData()
    private val _onboardingState: MutableLiveData<Boolean> = MutableLiveData()
    private val _liveTheme: MutableLiveData<Int> = MutableLiveData()


    val liveUserId: LiveData<String> get() = _liveUserId
    val liveTheme: LiveData<Int> get() = _liveTheme
    val liveOnboardingState: LiveData<Boolean> get() = _onboardingState

    override var onboardingCompleted: Boolean by BooleanPreference(prefs, ONBOARDING_KEY, false)
    override var userId: String? by StringPreference(prefs, USER_ID_KEY, "")
    override var currentTheme: Int by IntPreference(
        prefs,
        APP_THEME_KEY,
        AppCompatDelegate.MODE_NIGHT_NO
    )

    val isLoggedIn: ObservableBoolean = ObservableBoolean(false)

    //    val userId: ObservableField<String> = ObservableField()
    val isDarkMode: ObservableBoolean = ObservableBoolean(false)
    val isFeatureAvailable: ObservableBoolean = ObservableBoolean(true)

    init {
        Timber.tag(APP_TAG)
        with(prefs.value.getString(USER_ID_KEY, null)) {
            Timber.d("User id -> $this")
            isLoggedIn.set(!this.isNullOrEmpty())
//            userId.set(this)
            _liveUserId.postValue(this)
        }

        with(prefs.value.getBoolean(APP_THEME_KEY, false)) {
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
        prefs.value.edit {
            putString(USER_ID_KEY, id)
            apply()
        }
        isLoggedIn.set(!id.isNullOrEmpty())
//        userId.set(id)
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
            prefs.value.edit {
                putBoolean(APP_THEME_KEY, get())
                apply()
            }
        }
    }

}


class BooleanPreference(
    private val preferences: Lazy<SharedPreferences>,
    private val name: String,
    private val defaultValue: Boolean
) : ReadWriteProperty<Any, Boolean> {

    @WorkerThread
    override fun getValue(thisRef: Any, property: KProperty<*>): Boolean {
        return preferences.value.getBoolean(name, defaultValue)
    }

    override fun setValue(thisRef: Any, property: KProperty<*>, value: Boolean) {
        preferences.value.edit { putBoolean(name, value) }
    }
}

class StringPreference(
    private val preferences: Lazy<SharedPreferences>,
    private val name: String,
    private val defaultValue: String
) : ReadWriteProperty<Any, String?> {

    @WorkerThread
    override fun getValue(thisRef: Any, property: KProperty<*>): String {
        return preferences.value.getString(name, defaultValue) ?: defaultValue
    }

    override fun setValue(thisRef: Any, property: KProperty<*>, value: String?) {
        preferences.value.edit { putString(name, value) }
    }
}

class IntPreference(
    private val preferences: Lazy<SharedPreferences>,
    private val name: String,
    private val defaultValue: Int
) : ReadWriteProperty<Any, Int?> {

    @WorkerThread
    override fun getValue(thisRef: Any, property: KProperty<*>): Int {
        return preferences.value.getInt(name, defaultValue)
    }

    override fun setValue(thisRef: Any, property: KProperty<*>, value: Int?) {
        preferences.value.edit { value.whatIfNotNull { putInt(name, it) } }
    }
}
