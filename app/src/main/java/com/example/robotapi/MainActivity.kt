package com.example.robotapi

import android.os.Bundle
import android.view.View
import android.widget.Toast
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import com.example.robotapi.databinding.ActivityMainBinding
import com.example.robotapi.viewmodel.MainViewModel
import com.example.robotapi.viewmodel.UiState
import com.google.android.material.snackbar.Snackbar
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
        // 发送按钮点击事件
        binding.sendButton.setOnClickListener {
            val url = binding.apiUrlEditText.text.toString().trim()
            val message = binding.messageEditText.text.toString().trim()
            viewModel.sendMessage(url, message)
        }
        
        // 清除按钮点击事件
        binding.clearButton.setOnClickListener {
            viewModel.clearResponse()
            binding.messageEditText.text?.clear()
            showSnackbar("已清除内容")
        }
        
        // 重试按钮（如果有的话）
        binding.responseTextView.setOnLongClickListener {
            viewModel.retry()
            showSnackbar("正在重试...")
            true
        }
        
        // 添加输入监听
        binding.messageEditText.addTextChangedListener(object : android.text.TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {}
            override fun afterTextChanged(s: android.text.Editable?) {
                updateSendButtonState()
            }
        })
        
        binding.apiUrlEditText.addTextChangedListener(object : android.text.TextWatcher {
            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {}
            override fun afterTextChanged(s: android.text.Editable?) {
                updateSendButtonState()
            }
        })
    }
    
    private fun updateSendButtonState() {
        val url = binding.apiUrlEditText.text.toString().trim()
        val message = binding.messageEditText.text.toString().trim()
        binding.sendButton.isEnabled = url.isNotEmpty() && message.isNotEmpty()
    }
    
    private fun observeViewModel() {
        // 观察UI状态
        viewModel.uiState.observe(this) { state ->
            when (state) {
                is UiState.Idle -> {
                    binding.progressBar.visibility = View.GONE
                    binding.sendButton.isEnabled = true
                }
                is UiState.Loading -> {
                    binding.progressBar.visibility = View.VISIBLE
                    binding.sendButton.isEnabled = false
                }
                is UiState.Success -> {
                    binding.progressBar.visibility = View.GONE
                    binding.sendButton.isEnabled = true
                    showSnackbar("请求成功")
                }
                is UiState.Error -> {
                    binding.progressBar.visibility = View.GONE
                    binding.sendButton.isEnabled = true
                    showSnackbar("错误: ${state.message}")
                }
            }
        }
        
        // 观察加载状态
        viewModel.isLoading.observe(this) { isLoading ->
            binding.progressBar.visibility = if (isLoading) View.VISIBLE else View.GONE
            binding.sendButton.isEnabled = !isLoading
        }
        
        // 观察响应数据
        viewModel.response.observe(this) { response ->
            if (response != null) {
                binding.responseTextView.text = response.message
                binding.responseTextView.visibility = View.VISIBLE
                binding.clearButton.visibility = View.VISIBLE
                
                // 显示处理时间（如果有）
                response.processingTime?.let { time ->
                    showSnackbar("处理时间: ${time}ms")
                }
            } else {
                binding.responseTextView.visibility = View.GONE
                binding.clearButton.visibility = View.GONE
            }
        }
        
        // 观察错误信息
        viewModel.error.observe(this) { error ->
            if (error != null) {
                showSnackbar(error)
            }
        }
    }
    
    private fun showSnackbar(message: String) {
        Snackbar.make(binding.root, message, Snackbar.LENGTH_SHORT).show()
    }
    
    override fun onResume() {
        super.onResume()
        updateSendButtonState()
    }
}