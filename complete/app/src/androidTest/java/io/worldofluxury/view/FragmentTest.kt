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

package io.worldofluxury.view

import androidx.navigation.Navigation
import androidx.navigation.testing.TestNavHostController
import androidx.test.core.app.ApplicationProvider
import androidx.test.espresso.Espresso.onView
import androidx.test.espresso.action.ViewActions
import androidx.test.espresso.matcher.ViewMatchers.assertThat
import androidx.test.espresso.matcher.ViewMatchers.withId
import androidx.test.ext.junit.runners.AndroidJUnit4
import dagger.hilt.android.testing.HiltAndroidRule
import dagger.hilt.android.testing.HiltAndroidTest
import io.worldofluxury.R
import io.worldofluxury.core.CoroutineTestRule
import io.worldofluxury.util.launchFragmentInHiltContainer
import io.worldofluxury.view.welcome.WelcomeFragment
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.runBlockingTest
import org.hamcrest.core.IsEqual.equalTo
import org.junit.After
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import java.io.IOException

/**
 *  @project World of Luxury
 *  @author Bilson Jr.
 *  @since 07/08/2020 @ 17:39
 */
@ExperimentalCoroutinesApi
@HiltAndroidTest
//@RunWith(AndroidJUnit4::class)
class FragmentTest {

    @get:Rule
    var coroutinesTestRule = CoroutineTestRule()

    @get:Rule
    var hiltRule = HiltAndroidRule(this)

    @Before
    fun setup() {
        hiltRule.inject()
    }

    @After
    fun tearDown() {

    }

    @Test
    fun navFromWelcomeToLoginOrHome() = coroutinesTestRule.runBlockingTest {
        // Create a TestNavHostController
        val navController = TestNavHostController(
            ApplicationProvider.getApplicationContext()
        )
        navController.setGraph(R.navigation.wol_nav_graph)

        // Create a graphical FragmentScenario for the WelcomeScreen
        launchFragmentInHiltContainer<WelcomeFragment> {
            Navigation.setViewNavController(requireView(), navController)
        }

        onView(withId(R.id.get_started)).perform(ViewActions.click())
        assertThat(
            "Current destination is nav auth",
            navController.currentDestination?.id,
            equalTo(R.id.nav_auth)
        )
    }

}