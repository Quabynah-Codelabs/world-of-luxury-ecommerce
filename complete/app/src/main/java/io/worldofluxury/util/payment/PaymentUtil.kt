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

import android.content.Context
import android.os.Parcelable
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.liveData
import com.skydoves.whatif.whatIfNotNull
import com.squareup.moshi.Json
import com.squareup.moshi.JsonClass
import com.stripe.android.PaymentSession
import com.stripe.android.PaymentSessionConfig
import com.stripe.android.PaymentSessionData
import com.stripe.android.model.Address
import com.stripe.android.model.PaymentMethod
import com.stripe.android.model.ShippingInformation
import com.stripe.android.model.ShippingMethod
import com.stripe.android.view.ShippingInfoWidget
import dagger.hilt.android.qualifiers.ApplicationContext
import io.worldofluxury.data.Product
import io.worldofluxury.preferences.PreferenceStorage
import io.worldofluxury.util.APP_TAG
import io.worldofluxury.viewmodel.CheckoutProgress
import kotlinx.android.parcel.Parcelize
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers.Main
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch
import timber.log.Timber
import java.util.*
import javax.inject.Inject

/**
 *  @project World of Luxury
 *  @author Bilson Jr.
 *  @by Quabynah Codelabs LLC
 *  @since 22/08/2020 @ 00:59
 */
interface PaymentUtil {
    val supportsPaymentModule: LiveData<Boolean>
    val paymentConfig: PaymentSessionConfig

    suspend fun performCheckout(
        items: Flow<List<Product>>,
        checkoutProgress: MutableLiveData<CheckoutProgress>,
        toastLiveData: MutableLiveData<String>,
        session: PaymentSession
    )
}

// data class for API version sent to server-side
@Parcelize
@JsonClass(generateAdapter = true)
data class ApiVersioningRequest(@Json(name = "api_version") val version: String) : Parcelable

// app shipping validator
class AppShippingInfoValidator : PaymentSessionConfig.ShippingInformationValidator {
    override fun getErrorMessage(shippingInformation: ShippingInformation): String =
        "A Ghanaian address is required for ${shippingInformation.address?.country}"

    override fun isValid(shippingInformation: ShippingInformation): Boolean =
        Locale.getDefault().country == shippingInformation.address?.country
}

// app shipping methods factory
class AppShippingMethodsFactory : PaymentSessionConfig.ShippingMethodsFactory {
    override fun create(shippingInformation: ShippingInformation): List<ShippingMethod> = listOf(
        ShippingMethod(
            label = "UPS Ground",
            identifier = "ups-ground",
            detail = "Arrives in 3-5 days",
            amount = 0,
            currency = Currency.getInstance(Locale.getDefault())
        )
    )
}

// payment session listener
class AppPaymentSessionListener(
    private val totalSum: Double,
    private val checkoutProgress: MutableLiveData<CheckoutProgress>,
    private val toastLiveData: MutableLiveData<String>
) : PaymentSession.PaymentSessionListener {

    init {
        Timber.tag(APP_TAG)
        Timber.i("Total price of items in cart -> $totalSum")
    }

    override fun onCommunicatingStateChanged(isCommunicating: Boolean) {
        Timber.i("Payment session communication established? $isCommunicating")
    }

    override fun onError(errorCode: Int, errorMessage: String) {
        Timber.e("An error occurred while making payment -> $errorMessage")
        toastLiveData.postValue("An error occurred during payment")
    }

    override fun onPaymentSessionDataChanged(data: PaymentSessionData) {
        Timber.i("Making a total payment of -> ${data.cartTotal}")

        if (data.useGooglePay) {
            // using Google Pay
        } else {
            // using card
            data.paymentMethod.let { method ->
                // display information about the current payment method
                method?.whatIfNotNull { paymentMethod -> Timber.i("Payment method used -> ${paymentMethod.card?.brand}") }
            }
        }

        if (data.isPaymentReadyToCharge) {
            // use the data to complete the charge

            // send response
            checkoutProgress.postValue(CheckoutProgress.ON_SUCCESS)
            toastLiveData.postValue("Checkout completed")
        }
    }

}

/**
 * Implementation of [PaymentUtil]
 */
class DefaultPaymentUtil @Inject constructor(
    @ApplicationContext private val context: Context,
    prefs: PreferenceStorage,
    validator: PaymentSessionConfig.ShippingInformationValidator,
    shippingMethodsFactory: PaymentSessionConfig.ShippingMethodsFactory,
    scope: CoroutineScope
) : PaymentUtil, PreferenceStorage by prefs, CoroutineScope by scope {

    // payment session config
    override val paymentConfig: PaymentSessionConfig = PaymentSessionConfig.Builder()
        // hide phone & state fields
        .setHiddenShippingInfoFields(
            ShippingInfoWidget.CustomizableShippingField.Phone,
            ShippingInfoWidget.CustomizableShippingField.State
        )
        // make address line 2 optional
        .setOptionalShippingInfoFields(ShippingInfoWidget.CustomizableShippingField.Line2)
        // address to pre-populate the shipping info form
        .setPrepopulatedShippingInfo(
            ShippingInformation(
                Address.Builder()
                    .setLine1("2 Danso St")
                    .setCity("Dansoman")
                    .setState("DC")
                    .setCountry("GH")
                    .setPostalCode("00233")
                    .build(),
                "Quabynah Bilson",
                "0554635701"
            )
        )
        // collect shipping info
        .setShippingInfoRequired(true)
        // collect shipping method
        .setShippingMethodsRequired(true)
        // set payment methods (card only)
        .setPaymentMethodTypes(listOf(PaymentMethod.Type.Card))
        // allow addresses
        .setAllowedShippingCountryCodes(setOf("GH", "US"))
        // shipping info validator
        .setShippingInformationValidator(validator)
        // shipping methods factory
        .setShippingMethodsFactory(shippingMethodsFactory)
        .setShouldShowGooglePay(true)
        // shows Google Pay as an option
        .build()

    override val supportsPaymentModule: LiveData<Boolean>
        get() = liveData {
            // check payment api integration & update flow
            emit(true)
        }

    override suspend fun performCheckout(
        items: Flow<List<Product>>,
        checkoutProgress: MutableLiveData<CheckoutProgress>,
        toastLiveData: MutableLiveData<String>,
        session: PaymentSession
    ) = coroutineScope {
        items.collectLatest {
            var sum = 0.00
            it.forEach { product ->
                sum += product.price
            }
            // start
            checkoutProgress.postValue(CheckoutProgress.ON_START)
            launch(Main) {
                session.init(AppPaymentSessionListener(sum, checkoutProgress, toastLiveData))
                // simulate transaction
                session.presentPaymentMethodSelection()
            }
        }
    }

}