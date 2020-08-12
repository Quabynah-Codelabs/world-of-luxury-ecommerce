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

import androidx.test.espresso.matcher.ViewMatchers.assertThat
import dagger.hilt.android.testing.HiltAndroidRule
import dagger.hilt.android.testing.HiltAndroidTest
import io.worldofluxury.core.CoroutineTestRule
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.delay
import kotlinx.coroutines.test.runBlockingTest
import org.hamcrest.core.IsEqual.equalTo
import org.junit.After
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import java.io.IOException
import java.util.*
import javax.inject.Inject

/**
 *  @project World of Luxury
 *  @author Bilson Jr.
 *  @by Quabynah Codelabs LLC
 *  @since 08/08/2020 @ 04:28
 *
 *  Test for [PreferenceStorage]
 */
@HiltAndroidTest
@ExperimentalCoroutinesApi
class PreferenceStorageTest {
    @get:Rule
    var coroutinesTestRule = CoroutineTestRule()

    @get:Rule
    var hiltRule = HiltAndroidRule(this)

    @Before
    fun setup() {
        hiltRule.inject()
    }

    @After
    @Throws(IOException::class)
    fun tearDown() {

    }

    @Inject
    lateinit var prefs: PreferenceStorage

    @Test
    fun saveUserIdAndRetrieveValue() = coroutinesTestRule.runBlockingTest {
        // create user id
        val uid = UUID.randomUUID().toString()
        // save to prefs
        prefs.userId = uid
        // simulate delay
        delay(5000)
        // verify data has been saved
        assertThat(uid, equalTo(prefs.userId))
    }

}