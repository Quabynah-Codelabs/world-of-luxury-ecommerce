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

import android.content.Context
import androidx.room.Room
import androidx.test.core.app.ApplicationProvider
import androidx.test.espresso.matcher.ViewMatchers.assertThat
import androidx.test.ext.junit.runners.AndroidJUnit4
import io.worldofluxury.database.AppDatabase
import io.worldofluxury.database.dao.ProductDao
import io.worldofluxury.database.dao.UserDao
import io.worldofluxury.util.APP_TAG
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.runBlockingTest
import org.hamcrest.core.IsEqual.equalTo
import org.junit.After
import org.junit.Before
import org.junit.Rule
import org.junit.Test
import org.junit.runner.RunWith
import timber.log.Timber
import java.io.IOException
import java.util.*

@ExperimentalCoroutinesApi
@RunWith(AndroidJUnit4::class)
class DatabaseTest {

    @get:Rule
    var coroutinesTestRule = CoroutineTestRule()

    private lateinit var userDao: UserDao
    private lateinit var productDao: ProductDao
    private lateinit var db: AppDatabase
    private lateinit var context: Context

    @Before
    fun setup() {
        Timber.tag(APP_TAG)
        context = ApplicationProvider.getApplicationContext()
        db = Room.inMemoryDatabaseBuilder(
            context, AppDatabase::class.java
        )
            .allowMainThreadQueries()
            .build()
        userDao = db.userDao()
        productDao = db.productDao()
    }

    @After
    @Throws(IOException::class)
    fun tearDown() {
        db.close()
    }

    // passed
    @Test
    @Throws(Exception::class)
    fun writeUserAndReadInId() = coroutinesTestRule.runBlockingTest {
        val uid = UUID.randomUUID().toString()
        val user = TestUtil.createUser(uid)
        // fixme: suspend functions causes test to fail with exception: job running without completion
        userDao.insert(user)

        // fixme: running live data on main thread
        val userById = userDao.getUserById(uid)
        assertThat(userById?.id, equalTo(uid))
    }

}