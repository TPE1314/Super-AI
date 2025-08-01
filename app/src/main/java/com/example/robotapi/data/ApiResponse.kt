package com.example.robotapi.data

import com.google.gson.annotations.SerializedName
import android.os.Parcelable
import kotlinx.parcelize.Parcelize

@Parcelize
data class ApiResponse(
    @SerializedName("message")
    val message: String,
    
    @SerializedName("timestamp")
    val timestamp: Long,
    
    @SerializedName("status")
    val status: String,
    
    @SerializedName("data")
    val data: Any? = null,
    
    @SerializedName("error")
    val error: String? = null,
    
    @SerializedName("requestId")
    val requestId: String? = null,
    
    @SerializedName("processingTime")
    val processingTime: Long? = null
) : Parcelable

sealed class ApiResult<out T> {
    data class Success<T>(val data: T) : ApiResult<T>()
    data class Error(val message: String, val code: Int? = null) : ApiResult<Nothing>()
    object Loading : ApiResult<Nothing>()
}