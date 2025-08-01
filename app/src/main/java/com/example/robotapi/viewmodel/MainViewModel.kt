package com.example.robotapi.viewmodel

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.robotapi.data.ApiResponse
import com.example.robotapi.data.ApiResult
import com.example.robotapi.network.RetrofitClient
import com.example.robotapi.repository.ApiRepository
import kotlinx.coroutines.launch
import kotlinx.coroutines.delay

class MainViewModel : ViewModel() {
    
    private val repository = ApiRepository(RetrofitClient.apiService)
    
    private val _uiState = MutableLiveData<UiState>()
    val uiState: LiveData<UiState> = _uiState
    
    private val _response = MutableLiveData<ApiResponse>()
    val response: LiveData<ApiResponse> = _response
    
    private val _error = MutableLiveData<String>()
    val error: LiveData<String> = _error
    
    private val _isLoading = MutableLiveData<Boolean>()
    val isLoading: LiveData<Boolean> = _isLoading
    
    // 添加重试机制
    private var retryCount = 0
    private val maxRetries = 3
    
    fun sendMessage(url: String, message: String) {
        // 输入验证
        if (!repository.isValidMessage(message)) {
            _error.value = "消息内容不能为空且长度不能超过1000字符"
            return
        }
        
        if (!repository.isValidUrl(url)) {
            _error.value = "请输入有效的API地址"
            return
        }
        
        _uiState.value = UiState.Loading
        _isLoading.value = true
        _error.value = null
        retryCount = 0
        
        viewModelScope.launch {
            try {
                val result = repository.sendMessage(url, message)
                
                when (result) {
                    is ApiResult.Success -> {
                        _response.value = result.data
                        _uiState.value = UiState.Success(result.data)
                        _isLoading.value = false
                        retryCount = 0 // 重置重试计数
                    }
                    is ApiResult.Error -> {
                        handleError(result.message, result.code)
                    }
                    is ApiResult.Loading -> {
                        _uiState.value = UiState.Loading
                    }
                }
            } catch (e: Exception) {
                handleError(e.message ?: "未知错误")
            }
        }
    }
    
    private fun handleError(message: String, code: Int? = null) {
        _error.value = message
        _uiState.value = UiState.Error(message, code)
        _isLoading.value = false
        
        // 自动重试机制
        if (retryCount < maxRetries && shouldRetry(code)) {
            retryCount++
            viewModelScope.launch {
                delay(1000 * retryCount) // 递增延迟
                // 这里可以重新发送请求
            }
        }
    }
    
    private fun shouldRetry(code: Int?): Boolean {
        // 网络错误或服务器错误时重试
        return code == null || code in 500..599 || code in 408..499
    }
    
    fun clearResponse() {
        _response.value = null
        _error.value = null
        _uiState.value = UiState.Idle
    }
    
    fun retry() {
        // 重新发送最后一次请求
        _uiState.value?.let { state ->
            if (state is UiState.Error) {
                // 这里可以重新发送请求
            }
        }
    }
}

sealed class UiState {
    object Idle : UiState()
    object Loading : UiState()
    data class Success(val data: ApiResponse) : UiState()
    data class Error(val message: String, val code: Int? = null) : UiState()
}