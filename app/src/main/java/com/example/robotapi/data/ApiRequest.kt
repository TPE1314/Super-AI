package com.example.robotapi.data

data class ApiRequest(
    val message: String,
    val timestamp: Long = System.currentTimeMillis(),
    val userId: String? = null,
    val sessionId: String? = null
)