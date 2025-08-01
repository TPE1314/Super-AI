package com.example.robotapi.repository

import com.example.robotapi.data.ApiRequest
import com.example.robotapi.data.ApiResponse
import com.example.robotapi.network.ApiService
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import retrofit2.Response

class ApiRepository(private val apiService: ApiService) {
    
    suspend fun sendMessage(url: String, message: String): Result<ApiResponse> {
        return withContext(Dispatchers.IO) {
            try {
                val request = ApiRequest(message = message)
                val response = apiService.sendMessage(url, request)
                
                if (response.isSuccessful) {
                    response.body()?.let {
                        Result.success(it)
                    } ?: Result.failure(Exception("Empty response"))
                } else {
                    Result.failure(Exception("HTTP ${response.code()}: ${response.message()}"))
                }
            } catch (e: Exception) {
                Result.failure(e)
            }
        }
    }
}