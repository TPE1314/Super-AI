package com.example.robotapi.viewmodel

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.robotapi.data.ApiResponse
import com.example.robotapi.network.RetrofitClient
import com.example.robotapi.repository.ApiRepository
import kotlinx.coroutines.launch

class MainViewModel : ViewModel() {
    
    private val repository = ApiRepository(RetrofitClient.apiService)
    
    private val _isLoading = MutableLiveData<Boolean>()
    val isLoading: LiveData<Boolean> = _isLoading
    
    private val _response = MutableLiveData<ApiResponse>()
    val response: LiveData<ApiResponse> = _response
    
    private val _error = MutableLiveData<String>()
    val error: LiveData<String> = _error
    
    fun sendMessage(url: String, message: String) {
        if (message.isBlank()) {
            _error.value = "请输入消息内容"
            return
        }
        
        if (url.isBlank()) {
            _error.value = "请输入API地址"
            return
        }
        
        _isLoading.value = true
        _error.value = null
        
        viewModelScope.launch {
            try {
                val result = repository.sendMessage(url, message)
                result.fold(
                    onSuccess = { response ->
                        _response.value = response
                        _isLoading.value = false
                    },
                    onFailure = { exception ->
                        _error.value = exception.message ?: "未知错误"
                        _isLoading.value = false
                    }
                )
            } catch (e: Exception) {
                _error.value = e.message ?: "网络错误"
                _isLoading.value = false
            }
        }
    }
    
    fun clearResponse() {
        _response.value = null
        _error.value = null
    }
}