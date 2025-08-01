package com.example.robotapi

import android.content.Intent
import android.os.Bundle
import android.view.Menu
import android.view.MenuItem
import android.view.View
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import com.example.robotapi.data.ChatMessage
import com.example.robotapi.databinding.ActivityMainBinding
import com.example.robotapi.ui.HistoryActivity
import com.example.robotapi.viewmodel.HistoryViewModel
import com.example.robotapi.viewmodel.MainViewModel
import com.example.robotapi.viewmodel.UiState
import com.google.android.material.snackbar.Snackbar
import kotlinx.coroutines.launch

class MainActivity : AppCompatActivity() {
    
    private lateinit var binding: ActivityMainBinding
    private val viewModel: MainViewModel by viewModels()
    private val historyViewModel: HistoryViewModel by viewModels()
    
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
                    
                    // 保存到历史记录
                    saveToHistory(state.data)
                }
                is UiState.Error -> {
                    binding.progressBar.visibility = View.GONE
                    binding.sendButton.isEnabled = true
                    showSnackbar("错误: ${state.message}")
                    
                    // 保存错误记录
                    saveErrorToHistory(state.message)
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
    
    private fun saveToHistory(response: com.example.robotapi.data.ApiResponse) {
        val url = binding.apiUrlEditText.text.toString().trim()
        val message = binding.messageEditText.text.toString().trim()
        
        val chatMessage = ChatMessage(
            message = message,
            response = response.message,
            apiUrl = url,
            isSuccess = true
        )
        
        // 保存到历史记录
        historyViewModel.addMessage(chatMessage)
    }
    
    private fun saveErrorToHistory(errorMessage: String) {
        val url = binding.apiUrlEditText.text.toString().trim()
        val message = binding.messageEditText.text.toString().trim()
        
        val chatMessage = ChatMessage(
            message = message,
            response = "",
            apiUrl = url,
            isSuccess = false,
            errorMessage = errorMessage
        )
        
        // 保存到历史记录
        historyViewModel.addMessage(chatMessage)
    }
    
    override fun onCreateOptionsMenu(menu: Menu): Boolean {
        menuInflater.inflate(R.menu.menu_main, menu)
        return true
    }
    
    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        return when (item.itemId) {
            R.id.action_history -> {
                startActivity(Intent(this, HistoryActivity::class.java))
                true
            }
            R.id.action_settings -> {
                showSnackbar("设置功能开发中...")
                true
            }
            else -> super.onOptionsItemSelected(item)
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