package com.example.robotapi.data

data class ApiResponse(
    val message: String,
    val timestamp: Long,
    val status: String,
    val data: Any? = null,
    val error: String? = null
)