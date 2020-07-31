package io.worldofluxury

import android.os.Bundle
import dagger.hilt.android.AndroidEntryPoint
import io.worldofluxury.base.DataBindingActivity
import io.worldofluxury.databinding.ActivityMainBinding


@AndroidEntryPoint
class MainActivity : DataBindingActivity() {
    private val binding: ActivityMainBinding by binding(R.layout.activity_main)

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding.apply {
            lifecycleOwner = this@MainActivity
        }
    }
}