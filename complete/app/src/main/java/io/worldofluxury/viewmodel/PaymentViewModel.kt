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

package io.worldofluxury.viewmodel

import androidx.hilt.lifecycle.ViewModelInject
import androidx.lifecycle.MutableLiveData
import com.stripe.android.PaymentSession
import io.worldofluxury.base.LiveCoroutinesViewModel
import io.worldofluxury.base.launchInBackground
import io.worldofluxury.repository.product.ProductRepository
import io.worldofluxury.util.payment.PaymentUtil

/**
 *  @project World of Luxury
 *  @author Bilson Jr.
 *  @by Quabynah Codelabs LLC
 *  @since 25/08/2020 @ 15:47
 */

enum class CheckoutProgress { IDLE, ON_START, ON_ERROR, ON_SUCCESS }

class PaymentViewModel @ViewModelInject constructor(
    repository: ProductRepository,
    paymentUtil: PaymentUtil
) :
    LiveCoroutinesViewModel(),
    PaymentUtil by paymentUtil, ProductRepository by repository {

    val toastLiveData: MutableLiveData<String> = MutableLiveData()
    val liveCheckoutProgress: MutableLiveData<CheckoutProgress> =
        MutableLiveData(CheckoutProgress.IDLE)

    fun checkout(session: PaymentSession) =
        launchInBackground {
            performCheckout(
                watchFavoritesNonLive(),
                liveCheckoutProgress,
                toastLiveData,
                session
            )
        }
}