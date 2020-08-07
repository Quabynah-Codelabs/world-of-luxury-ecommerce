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

package io.worldofluxury.binding

import android.annotation.SuppressLint
import android.view.View
import android.view.WindowManager
import android.widget.ImageView
import android.widget.TextView
import android.widget.Toast
import androidx.annotation.DrawableRes
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.widget.AppCompatImageView
import androidx.databinding.BindingAdapter
import androidx.lifecycle.LiveData
import androidx.navigation.findNavController
import com.bumptech.glide.load.engine.DiskCacheStrategy
import com.github.florent37.glidepalette.BitmapPalette
import com.github.florent37.glidepalette.GlidePalette
import com.google.android.material.card.MaterialCardView
import com.google.android.material.snackbar.Snackbar
import com.skydoves.rainbow.Rainbow
import com.skydoves.rainbow.RainbowOrientation
import com.skydoves.rainbow.color
import com.skydoves.whatif.whatIfNotNull
import io.worldofluxury.R
import io.worldofluxury.core.glide.GlideApp
import io.worldofluxury.data.User

@SuppressLint("SetTextI18n")
@BindingAdapter("user")
fun bindUser(view: TextView, user: LiveData<User>) {
    user.value.whatIfNotNull {
        view.text = "Hey, ${it.name.trim()}"
    }
}

@BindingAdapter("toast")
fun bindToast(view: View, text: LiveData<String>) {
    text.value.whatIfNotNull {
        Toast.makeText(view.context, it, Toast.LENGTH_LONG).show()
    }
}

@BindingAdapter("snackbar")
fun bindSnackBar(view: View, text: LiveData<String>) {
    text.value.whatIfNotNull {
        Snackbar.make(view, it, Snackbar.LENGTH_LONG).show()
    }
}

@BindingAdapter("randomImage")
fun bindRandomImage(imageView: ImageView, @DrawableRes src: Int) {
    imageView.setImageDrawable(imageView.resources.getDrawable(src, imageView.context.theme))
}

@BindingAdapter("url")
fun bindLoadImageUrl(view: AppCompatImageView, url: String?) {
    val context = view.context
    GlideApp.with(view.context)
        .load(url)
        .diskCacheStrategy(DiskCacheStrategy.AUTOMATIC)
        .listener(
            GlidePalette.with(url)
                .use(BitmapPalette.Profile.MUTED_LIGHT)
                .intoCallBack { palette ->
                    val light = palette?.lightVibrantSwatch?.rgb
                    val domain = palette?.dominantSwatch?.rgb
                    if (domain != null) {
                        if (light != null) {
                            Rainbow(view).palette {
                                +color(domain)
                                +color(light)
                            }.background(orientation = RainbowOrientation.TOP_BOTTOM)
                        } else {
                            view.setBackgroundColor(domain)
                        }
                        if (context is AppCompatActivity) {
                            context.window.apply {
                                addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS)
                                statusBarColor = domain
                            }
                        }
                    }
                }
                .crossfade(true))
        .into(view)
}

@BindingAdapter("avatar")
fun bindLoadAvatar(view: ImageView, url: String?) {
    GlideApp.with(view.context)
        .load(url)
        .diskCacheStrategy(DiskCacheStrategy.AUTOMATIC)
        .circleCrop()
        .placeholder(R.drawable.avatar_one)
        .error(R.drawable.avatar_two)
        .fallback(R.drawable.avatar_three)
        .listener(
            GlidePalette.with(url)
                .use(BitmapPalette.Profile.MUTED_LIGHT)
                .crossfade(true)
        )
        .into(view)
}

@BindingAdapter("paletteImage", "paletteCard")
fun bindLoadImagePalette(view: AppCompatImageView, url: String, paletteCard: MaterialCardView) {
    GlideApp.with(view.context)
        .load(url)
        .diskCacheStrategy(DiskCacheStrategy.AUTOMATIC)
        .listener(
            GlidePalette.with(url)
                .use(BitmapPalette.Profile.MUTED_LIGHT)
                .intoCallBack { palette ->
                    val rgb = palette?.dominantSwatch?.rgb
                    if (rgb != null) {
                        paletteCard.setCardBackgroundColor(rgb)
                    }
                }
                .crossfade(true))
        .into(view)
}

@BindingAdapter("paletteImage", "paletteView")
fun bindLoadImagePaletteView(view: AppCompatImageView, url: String, paletteView: View) {
    val context = view.context
    GlideApp.with(context)
        .load(url)
        .diskCacheStrategy(DiskCacheStrategy.AUTOMATIC)
        .listener(
            GlidePalette.with(url)
                .use(BitmapPalette.Profile.MUTED_LIGHT)
                .intoCallBack { palette ->
                    val light = palette?.lightVibrantSwatch?.rgb
                    val domain = palette?.dominantSwatch?.rgb
                    if (domain != null) {
                        if (light != null) {
                            Rainbow(paletteView).palette {
                                +color(domain)
                                +color(light)
                            }.background(orientation = RainbowOrientation.TOP_BOTTOM)
                        } else {
                            paletteView.setBackgroundColor(domain)
                        }
                        if (context is AppCompatActivity) {
                            context.window.apply {
                                addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS)
                                statusBarColor = domain
                            }
                        }
                    }
                }
                .crossfade(true))
        .into(view)
}

@BindingAdapter("gone")
fun bindGone(view: View, shouldBeGone: Boolean) {
    view.gone(shouldBeGone)
}

@BindingAdapter("onBackPressed")
fun bindOnBackPressed(view: View, finish: Boolean) {
    if (finish) {
        view.setOnClickListener {
            view.findNavController().popBackStack()
        }
    }
}