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

package io.worldofluxury.binding

import android.view.View
import com.google.android.material.snackbar.Snackbar
import io.worldofluxury.util.PASSWORD_LENGTH

/**
 * shows a [Snackbar] message
 */
fun View.showSnackBar(message: String) = Snackbar.make(this, message, Snackbar.LENGTH_SHORT).show()

/**
 * checks the length of password
 */
fun String.isTooShort(): Boolean = this.length < PASSWORD_LENGTH

/**
 * adds  a new [item] to the existing list of [T]
 */
fun <T> MutableList<T>.addIfDoesNotExist(item: T) {
    if (!this.contains(item)) add(item)
}

///** Returns a [LiveData] of any object*/
//fun <T> T.toLiveData(): LiveData<T> {
//    val liveData = MutableLiveData<T>()
//    liveData.postValue(this)
//    return liveData
//}