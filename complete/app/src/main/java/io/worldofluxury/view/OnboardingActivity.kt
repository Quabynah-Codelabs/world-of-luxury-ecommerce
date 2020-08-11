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

package io.worldofluxury.view

import android.os.Bundle
import android.view.View
import android.view.ViewGroup
import androidx.activity.viewModels
import androidx.viewpager.widget.PagerAdapter
import dagger.hilt.android.AndroidEntryPoint
import io.worldofluxury.R
import io.worldofluxury.base.DataBindingActivity
import io.worldofluxury.databinding.ActivityOnboardingBinding
import io.worldofluxury.databinding.ItemOnboardingBinding
import io.worldofluxury.util.APP_TAG
import io.worldofluxury.viewmodel.factory.LaunchViewModelFactory
import timber.log.Timber
import javax.inject.Inject

@AndroidEntryPoint
class OnboardingActivity : DataBindingActivity() {
    private val binding by binding<ActivityOnboardingBinding>(R.layout.activity_onboarding)

    @Inject
    lateinit var factory: LaunchViewModelFactory
    val launcherViewModel by viewModels<LauncherViewModel> { factory }

    init {
        Timber.tag(APP_TAG)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        binding.run {
            lifecycleOwner = this@OnboardingActivity
            vm = launcherViewModel
            host = this@OnboardingActivity

            // setup pager with indicator
            onboardingPager.adapter = OnboardingPagerAdapter(this@OnboardingActivity, 1)
            // this indicator does not have support for ViewPager2 so we use the old one
            indicator.setViewPager(onboardingPager)
            executePendingBindings()
        }

        launcherViewModel
    }
}

// adapter for onboarding view pager
class OnboardingPagerAdapter constructor(
    private val parent: OnboardingActivity,
    private val pages: Int
) :
    PagerAdapter() {
    override fun getCount(): Int = pages

    override fun isViewFromObject(view: View, `object`: Any): Boolean = view == `object`

    override fun instantiateItem(container: ViewGroup, position: Int): Any {
        val v: View = getPage(container, position)
        container.addView(v)
        return v
    }

    override fun destroyItem(container: ViewGroup, position: Int, `object`: Any) {
        container.removeView(`object` as View)
    }

    private fun getPage(container: ViewGroup, position: Int): View {
        val itemBinding = ItemOnboardingBinding.inflate(parent.layoutInflater)
        itemBinding.run {
            host = parent
            vm = parent.launcherViewModel
            executePendingBindings()
        }
        return itemBinding.root
    }

}