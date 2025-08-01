package com.example.robotapi.repository

import com.example.robotapi.data.ApiRequest
import com.example.robotapi.data.ApiResponse
import com.example.robotapi.data.ApiResult
import com.example.robotapi.network.ApiService
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.coroutines.withTimeout
import retrofit2.Response
import java.net.SocketTimeoutException
import java.net.UnknownHostException

class ApiRepository(private val apiService: ApiService) {
    
    suspend fun sendMessage(url: String, message: String): ApiResult<ApiResponse> {
        return withContext(Dispatchers.IO) {
            try {
                // 添加超时处理
                withTimeout(30000) { // 30秒超时
                    val request = ApiRequest(message = message)
                    val response = apiService.sendMessage(url, request)
                    
                    if (response.isSuccessful) {
                        response.body()?.let {
                            ApiResult.Success(it)
                        } ?: ApiResult.Error("Empty response")
                    } else {
                        ApiResult.Error("HTTP ${response.code()}: ${response.message()}", response.code())
                    }
                }
            } catch (e: SocketTimeoutException) {
                ApiResult.Error("请求超时，请检查网络连接")
            } catch (e: UnknownHostException) {
                ApiResult.Error("无法连接到服务器，请检查网络")
            } catch (e: Exception) {
                ApiResult.Error(e.message ?: "未知错误")
            }
        }
    }
    
    // 验证URL格式
    fun isValidUrl(url: String): Boolean {
        return try {
            android.util.Patterns.WEB_URL.matcher(url).matches()
        } catch (e: Exception) {
            false
        }
    }
    
    // 验证消息内容
    fun isValidMessage(message: String): Boolean {
        return message.trim().isNotEmpty() && message.length <= 1000
    }
}