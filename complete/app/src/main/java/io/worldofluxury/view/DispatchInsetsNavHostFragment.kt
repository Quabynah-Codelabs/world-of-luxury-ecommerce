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

import android.os.Bundle
import android.view.View
import android.view.ViewGroup
import androidx.core.view.forEach
import androidx.navigation.fragment.NavHostFragment

/**
 *  @project World of Luxury
 *  @author Bilson Jr.
 *  @by Quabynah Codelabs LLC
 *  @since 08/08/2020 @ 00:00
 */
class DispatchInsetsNavHostFragment : NavHostFragment() {

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        view.setOnApplyWindowInsetsListener { v, insets ->
            // During fragment transitions, multiple fragment's view hierarchies can be added at the
            // same time. If one consumes window insets, the other might not be layed out properly.
            // To workaround that, make sure we dispatch the insets to all children, regardless of
            // how they are consumed.
            (v as? ViewGroup)?.forEach { child ->
                child.dispatchApplyWindowInsets(insets)
            }
            insets
        }
    }
}