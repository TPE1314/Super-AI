package com.example.robotapi

import android.os.Bundle
import android.view.View
import android.widget.Toast
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import com.example.robotapi.databinding.ActivityMainBinding
import com.example.robotapi.viewmodel.MainViewModel
import kotlinx.coroutines.launch

class MainActivity : AppCompatActivity() {
    
    private lateinit var binding: ActivityMainBinding
    private val viewModel: MainViewModel by viewModels()
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)
        
        setupUI()
        observeViewModel()
    }
    
    private fun setupUI() {
        binding.sendButton.setOnClickListener {
            val url = binding.apiUrlEditText.text.toString().trim()
            val message = binding.messageEditText.text.toString().trim()
            viewModel.sendMessage(url, message)
        }
        
        binding.clearButton.setOnClickListener {
            viewModel.clearResponse()
            binding.messageEditText.text?.clear()
        }
    }
    
    private fun observeViewModel() {
        viewModel.isLoading.observe(this) { isLoading ->
            binding.progressBar.visibility = if (isLoading) View.VISIBLE else View.GONE
            binding.sendButton.isEnabled = !isLoading
        }
        
        viewModel.response.observe(this) { response ->
            if (response != null) {
                binding.responseTextView.text = response.message
                binding.responseTextView.visibility = View.VISIBLE
                binding.clearButton.visibility = View.VISIBLE
            } else {
                binding.responseTextView.visibility = View.GONE
                binding.clearButton.visibility = View.GONE
            }
        }
        
        viewModel.error.observe(this) { error ->
            if (error != null) {
                Toast.makeText(this, error, Toast.LENGTH_LONG).show()
            }
        }
    }
}