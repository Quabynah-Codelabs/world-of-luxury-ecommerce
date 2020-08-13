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

package io.worldofluxury.view.help

import android.view.View
import android.widget.Toast
import androidx.hilt.lifecycle.ViewModelInject
import io.worldofluxury.base.LiveCoroutinesViewModel

class HelpViewModel @ViewModelInject constructor() : LiveCoroutinesViewModel() {

    fun updateApp(v: View) {
        // todo: update app
        Toast.makeText(
            v.context.applicationContext,
            "Update feature unavailable",
            Toast.LENGTH_SHORT
        ).show()
    }
}