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

package io.worldofluxury.module

import android.content.Context
import com.stripe.android.EphemeralKeyProvider
import com.stripe.android.PaymentSessionConfig
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.components.ApplicationComponent
import dagger.hilt.android.qualifiers.ApplicationContext
import io.worldofluxury.preferences.PreferenceStorage
import io.worldofluxury.util.payment.*
import io.worldofluxury.webservice.SwanWebService
import kotlinx.coroutines.CoroutineScope
import javax.inject.Singleton

@Module
@InstallIn(ApplicationComponent::class)
object PaymentModule {

    @Provides
    @Singleton
    fun provideShippingInfoValidator(): PaymentSessionConfig.ShippingInformationValidator =
        AppShippingInfoValidator()

    @Provides
    @Singleton
    fun provideShippingMethodsFactory(): PaymentSessionConfig.ShippingMethodsFactory =
        AppShippingMethodsFactory()

    @Provides
    @Singleton
    fun providePaymentUtil(
        @ApplicationContext context: Context,
        prefs: PreferenceStorage,
        validator: PaymentSessionConfig.ShippingInformationValidator,
        factory: PaymentSessionConfig.ShippingMethodsFactory,
        scope: CoroutineScope
    ): PaymentUtil = DefaultPaymentUtil(context, prefs, validator, factory, scope)

    @Provides
    @Singleton
    fun provideEphemeralKeyProvider(
        service: SwanWebService,
        scope: CoroutineScope
    ): EphemeralKeyProvider =
        AppEphemeralKeyProvider(service, scope)
}