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

package io.worldofluxury.initializer

import android.content.Context
import androidx.startup.Initializer
import com.stripe.android.PaymentConfiguration
import io.worldofluxury.BuildConfig

/**
 *  @project World of Luxury
 *  @author Bilson Jr.
 *  @by Quabynah Codelabs LLC
 *  @since 09/08/2020 @ 10:57
 */
class StripeInitializer : Initializer<PaymentConfiguration> {
    override fun create(context: Context): PaymentConfiguration {
        // Initialize Stripe payment SDK
        PaymentConfiguration.init(
            context.applicationContext,
            BuildConfig.STRIPE_PUB_KEY
        )
        return PaymentConfiguration.getInstance(context)
    }

    override fun dependencies(): List<Class<out Initializer<*>>> = emptyList()
}