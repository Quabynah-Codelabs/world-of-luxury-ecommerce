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

package io.worldofluxury.repository

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.liveData
import androidx.paging.PagedList
import androidx.test.espresso.matcher.ViewMatchers.assertThat
import com.skydoves.whatif.whatIfNotNull
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.components.ApplicationComponent
import dagger.hilt.android.testing.HiltAndroidRule
import dagger.hilt.android.testing.HiltAndroidTest
import dagger.hilt.android.testing.UninstallModules
import io.worldofluxury.core.CoroutineTestRule
import io.worldofluxury.data.Product
import io.worldofluxury.data.User
import io.worldofluxury.database.dao.UserDao
import io.worldofluxury.module.RepositoryModule
import io.worldofluxury.repository.product.ProductRepository
import io.worldofluxury.repository.user.UserRepository
import io.worldofluxury.util.TestUtil
import io.worldofluxury.util.observeOnce
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.runBlockingTest
import org.hamcrest.core.IsEqual.equalTo
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import java.util.*
import javax.inject.Inject
import javax.inject.Singleton

/**
 *  @project World of Luxury
 *  @author Bilson Jr.
 *  @by Quabynah Codelabs LLC
 *  @since 08/08/2020 @ 05:40
 */
@ExperimentalCoroutinesApi
@HiltAndroidTest
@UninstallModules(RepositoryModule::class)
class TestUserRepository {

    @Module
    @InstallIn(ApplicationComponent::class)
    object TestRepositoryModule {

        @Singleton
        @Provides
        fun provideBackgroundThread(): CoroutineScope = CoroutineScope(Dispatchers.IO)

        @Singleton
        @Provides
        fun provideProductRepository(): ProductRepository = FakeProductRepository()

        @Singleton
        @Provides
        fun provideUserRepository(
            userDao: UserDao
        ): UserRepository = FakeUserRepository(userDao)
    }

    @get:Rule
    var coroutineTestRule = CoroutineTestRule()

    @get:Rule
    var hiltRule = HiltAndroidRule(this)

    @Inject
    lateinit var userRepository: UserRepository

    @Inject
    lateinit var productRepository: ProductRepository

    @Before
    fun setup() {
        hiltRule.inject()
    }

    @Test
    fun updateUserData() = coroutineTestRule.runBlockingTest {
        val testUser = TestUtil.createUser(UUID.randomUUID().toString())
        val newUsername = "Quabynah Jr."
        val user = testUser.copy(name = newUsername)
        userRepository.updateUser(user, MutableLiveData())
        userRepository.watchCurrentUser(MutableLiveData())
            .observeOnce { assertThat(user.name, equalTo(testUser.name)) }
    }

}

/**
 * Fake [UserRepository] implementation
 */
@Singleton
class FakeUserRepository @Inject constructor(
    private val userDao: UserDao
) :
    UserRepository {

    override fun watchCurrentUser(toastLiveData: MutableLiveData<String>): LiveData<User> =
        liveData {
            userDao.getUserById(UID).whatIfNotNull { emit(it) }
        }

    override fun updateUser(user: User, toastLiveData: MutableLiveData<String>) {
        userDao.insert(user)
    }
}

/**
 * Fake [ProductRepository] implementation
 */
@Singleton
class FakeProductRepository @Inject constructor() :
    ProductRepository {
    override fun watchFavorites(): LiveData<List<Product>> = liveData { }

    override fun watchAllProducts(
        category: String,
        toastLiveData: MutableLiveData<String>,
        page: Int
    ): LiveData<PagedList<Product>> = liveData { }

    override suspend fun addToCart(product: Product) {
        TODO("Not yet implemented")
    }

}

val UID = UUID.randomUUID().toString()