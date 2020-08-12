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
import android.os.Parcelable
import android.view.View
import android.view.ViewGroup
import androidx.activity.viewModels
import androidx.core.view.updatePadding
import androidx.viewpager.widget.PagerAdapter
import dagger.hilt.android.AndroidEntryPoint
import io.worldofluxury.R
import io.worldofluxury.base.DataBindingActivity
import io.worldofluxury.binding.doOnApplyWindowInsets
import io.worldofluxury.databinding.ActivityOnboardingBinding
import io.worldofluxury.databinding.ItemOnboardingBinding
import io.worldofluxury.util.APP_TAG
import io.worldofluxury.viewmodel.factory.LaunchViewModelFactory
import kotlinx.android.parcel.Parcelize
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

            root.doOnApplyWindowInsets { v, insets, _ ->
                // Add padding to the bottom here
                v.updatePadding(bottom = insets.systemWindowInsetBottom)
            }

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
    val items = OnBoardingItem.ITEMS

    override fun getCount(): Int = items.size

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
        val currentItem = items[position]

        val itemBinding = ItemOnboardingBinding.inflate(parent.layoutInflater)
        itemBinding.run {
            host = parent
            vm = parent.launcherViewModel
            item = currentItem
            executePendingBindings()
        }
        return itemBinding.root
    }

}

@Parcelize
data class OnBoardingItem constructor(
    val title: String,
    val description: String,
    val imageUrl: String?,
    val imgCredit: String = "https://unsplash.com/photos/Xn7GvimQrk8",
) :
    Parcelable {

    companion object {
        val ITEMS = mutableListOf(
            OnBoardingItem(
                "Get started with our clothing experts",
                "Invite your friends to join the community and save money on your next order",
                "https://images.unsplash.com/photo-1513094735237-8f2714d57c13?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=600&q=60"
            ),
            OnBoardingItem(
                "It's a \"add-to-cart\" kinda cool day",
                "A bargain ain't a bargain until it's something you need",
                "https://images.unsplash.com/photo-1475998893297-4da48a6e037d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=600&q=60"
            ),
            OnBoardingItem(
                "Hurry up right now until its too late",
                "The odds of going to the shop for a loaf of bread",
                "https://images.unsplash.com/photo-1495121605193-b116b5b9c5fe?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=600&q=60"
            )
        )
    }

}