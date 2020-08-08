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

package io.worldofluxury.view.welcome

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.fragment.app.Fragment
import androidx.navigation.navGraphViewModels
import dagger.hilt.android.AndroidEntryPoint
import io.worldofluxury.R
import io.worldofluxury.database.dao.ProductDao
import io.worldofluxury.databinding.FragmentWelcomeBinding
import io.worldofluxury.preferences.PreferenceStorage
import io.worldofluxury.util.APP_TAG
import io.worldofluxury.viewmodel.AuthViewModel
import io.worldofluxury.viewmodel.factory.AuthViewModelFactory
import timber.log.Timber
import javax.inject.Inject
import kotlin.random.Random

/**
 * Entry Point [Fragment] for our navigation system.
 *
 */
@AndroidEntryPoint
class WelcomeFragment : Fragment() {

    init {
        Timber.tag(APP_TAG)
    }

    private lateinit var binding: FragmentWelcomeBinding

    @Inject
    lateinit var authViewModelFactory: AuthViewModelFactory
    private val viewModel by navGraphViewModels<AuthViewModel>(R.id.wol_nav_graph) { authViewModelFactory }

    private val images = mutableListOf(
        R.drawable.world_of_luxury_one,
        R.drawable.world_of_luxury_two,
        R.drawable.world_of_luxury_three,
        R.drawable.world_of_luxury_four
    )

    @Inject
    lateinit var userPrefs: PreferenceStorage

    @Inject
    lateinit var productDao: ProductDao

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        // Inflate the layout for this fragment
        binding = DataBindingUtil.inflate(inflater, R.layout.fragment_welcome, container, false)
        binding.run {
            lifecycleOwner = this@WelcomeFragment
            vm = viewModel
            prefs = userPrefs

            val nextImageLocation = Random.nextInt(images.size)
            image = images[nextImageLocation]
            executePendingBindings()
        }
        return binding.root
    }

    /*override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)

        lifecycleScope.launchWhenStarted {
            userPrefs.save(null)
            try {
                requireActivity().assets.open(PRODUCT_JSON_FILENAME).use { inputStream ->
                    JsonReader(inputStream.reader()).use { jsonReader ->
                        val type = object : TypeToken<List<Product>>() {}.type
                        val list: List<Product> = Gson().fromJson(jsonReader, type)

                        productDao.insertAll(list.toMutableList())
                        Timber.d("Products added to database successfully")
                        ListenableWorker.Result.success()
                    }
                }
            } catch (ex: IOException) {
                Timber.e("Error adding products to database")
                ListenableWorker.Result.failure()
            }
        }
    }*/

}