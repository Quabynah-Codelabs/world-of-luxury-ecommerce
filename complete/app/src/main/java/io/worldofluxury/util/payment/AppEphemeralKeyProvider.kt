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

package io.worldofluxury.util.payment

import com.skydoves.sandwich.onError
import com.skydoves.sandwich.onException
import com.skydoves.sandwich.onFailure
import com.skydoves.sandwich.onSuccess
import com.skydoves.whatif.whatIfNotNull
import com.stripe.android.EphemeralKeyProvider
import com.stripe.android.EphemeralKeyUpdateListener
import io.worldofluxury.webservice.SwanWebService
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import timber.log.Timber
import javax.inject.Inject

/**
 *  @project World of Luxury
 *  @author Bilson Jr.
 *  @by Quabynah Codelabs LLC
 *  @since 25/08/2020 @ 14:02
 */
class AppEphemeralKeyProvider @Inject constructor(
    service: SwanWebService,
    scope: CoroutineScope
) : EphemeralKeyProvider, SwanWebService by service, CoroutineScope by scope {

    override fun createEphemeralKey(
        apiVersion: String,
        keyUpdateListener: EphemeralKeyUpdateListener
    ) {
        launch {
            createEphemeralKey(ApiVersioningRequest(version = apiVersion))
                .whatIfNotNull { apiResponse ->
                    apiResponse.onSuccess {
                        data.whatIfNotNull {
                            launch(Dispatchers.Main) {
                                keyUpdateListener.onKeyUpdate(it.results)
                            }
                        }
                    }
                    apiResponse.onError {
                        Timber.e("An exception occurred while creating ephemeral key -> $errorBody")
                        launch(Dispatchers.Main) {
                            keyUpdateListener.onKeyUpdateFailure(
                                statusCode.code,
                                errorBody.toString()
                            )
                        }
                    }
                    apiResponse.onException {
                        Timber.e("An exception occurred while creating ephemeral key -> $message")
                        launch(Dispatchers.Main) {
                            keyUpdateListener.onKeyUpdateFailure(404, message.toString())
                        }
                    }
                    apiResponse.onFailure {
                        Timber.e("An exception occurred while creating ephemeral key")
                        launch(Dispatchers.Main) {
                            keyUpdateListener.onKeyUpdateFailure(
                                404,
                                "An exception occurred while creating ephemeral key"
                            )
                        }
                    }
                }
        }
    }
}