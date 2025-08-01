package com.example.robotapi.network

import com.example.robotapi.data.ApiRequest
import com.example.robotapi.data.ApiResponse
import retrofit2.Response
import retrofit2.http.Body
import retrofit2.http.POST
import retrofit2.http.Url

interface ApiService {
    @POST
    suspend fun sendMessage(
        @Url url: String,
        @Body request: ApiRequest
    ): Response<ApiResponse>
}