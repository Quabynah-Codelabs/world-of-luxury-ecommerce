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

package io.worldofluxury

import dagger.hilt.android.testing.HiltAndroidTest
import io.worldofluxury.core.CoroutineTestRule
import kotlinx.coroutines.ExperimentalCoroutinesApi
import org.junit.Rule

/**
 *  @project World of Luxury
 *  @author Bilson Jr.
 *  @since 07/08/2020 @ 17:39
 */
@ExperimentalCoroutinesApi
@HiltAndroidTest
class FragmentTest {

    @get:Rule
    var coroutinesTestRule = CoroutineTestRule()


}