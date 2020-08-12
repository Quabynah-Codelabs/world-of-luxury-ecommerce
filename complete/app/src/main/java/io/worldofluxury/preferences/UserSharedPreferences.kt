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
import androidx.lifecycle.MutableLiveData
import com.skydoves.whatif.whatIfNotNull
import dagger.hilt.android.qualifiers.ApplicationContext
import io.worldofluxury.util.*
import timber.log.Timber
import javax.inject.Inject
import javax.inject.Singleton
import kotlin.properties.ReadWriteProperty
import kotlin.reflect.KProperty

/**
 * Interface for [UserSharedPreferences]
 */
interface PreferenceStorage {

    var onboardingCompleted: Boolean
    var userId: String?
    var currentTheme: Int

    // observable variables
    val isLoggedIn: ObservableBoolean
    val isDarkMode: ObservableBoolean
    val isFeatureAvailable: ObservableBoolean

    // live variables
    val liveUserId: MutableLiveData<String>
    val liveOnboardingState: MutableLiveData<Boolean>
    val liveTheme: MutableLiveData<Int>

    fun updateTheme()
    fun showCurrentTheme()
}

/**
 * Implementation of [PreferenceStorage] for [SharedPreferences]
 */
@Singleton
class UserSharedPreferences @Inject constructor(@ApplicationContext context: Context) :
    PreferenceStorage {

    // init prefs
    private val prefs: Lazy<SharedPreferences> = lazy {
        context.applicationContext.getSharedPreferences(
            PREFS_NAME,
            Context.MODE_PRIVATE
        ).apply { registerOnSharedPreferenceChangeListener(changeListener) }
    }

    // init listener
    private val changeListener = SharedPreferences.OnSharedPreferenceChangeListener { _, key ->
        when (key) {
            USER_ID_KEY -> {
                liveUserId.value = userId
                isLoggedIn.set(!userId.isNullOrEmpty())
            }
            APP_THEME_KEY -> {
                liveTheme.value = currentTheme
                isDarkMode.set(currentTheme == AppCompatDelegate.MODE_NIGHT_YES)
                AppCompatDelegate.setDefaultNightMode(currentTheme)
            }
            ONBOARDING_KEY -> liveOnboardingState.value = onboardingCompleted
        }
    }

    override var onboardingCompleted: Boolean by BooleanPreference(prefs, ONBOARDING_KEY, false)
    override var userId: String? by StringPreference(prefs, USER_ID_KEY, "")

    // fixme: add support for follow system option in the future
    override var currentTheme: Int by IntPreference(
        prefs,
        APP_THEME_KEY,
        AppCompatDelegate.MODE_NIGHT_YES
    )
    override val liveUserId: MutableLiveData<String> = MutableLiveData()
    override val liveOnboardingState: MutableLiveData<Boolean> = MutableLiveData()
    override val liveTheme: MutableLiveData<Int> = MutableLiveData()

    override val isLoggedIn: ObservableBoolean = ObservableBoolean(!userId.isNullOrEmpty())
    override val isDarkMode: ObservableBoolean =
        ObservableBoolean(currentTheme == AppCompatDelegate.MODE_NIGHT_YES)
    override val isFeatureAvailable: ObservableBoolean = ObservableBoolean(true)

    // update theme
    override fun updateTheme() {
        val mode =
            if (isDarkMode.get()) AppCompatDelegate.MODE_NIGHT_NO else AppCompatDelegate.MODE_NIGHT_YES
        currentTheme = mode
    }

    // show the current theme
    override fun showCurrentTheme() {
        val mode =
            if (isDarkMode.get()) AppCompatDelegate.MODE_NIGHT_YES else AppCompatDelegate.MODE_NIGHT_NO
        AppCompatDelegate.setDefaultNightMode(mode)
    }

    init {
        Timber.tag(APP_TAG)
        Timber.i("UID -> $userId & theme -> $currentTheme & onboarding -> $onboardingCompleted & login -> ${isLoggedIn.get()}")
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
