package com.example.robotapi.data

import com.google.gson.annotations.SerializedName
import android.os.Parcelable
import kotlinx.parcelize.Parcelize

@Parcelize
data class ApiRequest(
    @SerializedName("message")
    val message: String,
    
    @SerializedName("timestamp")
    val timestamp: Long = System.currentTimeMillis(),
    
    @SerializedName("userId")
    val userId: String? = null,
    
    @SerializedName("sessionId")
    val sessionId: String? = null,
    
    @SerializedName("deviceInfo")
    val deviceInfo: DeviceInfo? = null,
    
    @SerializedName("appVersion")
    val appVersion: String = "1.0.0"
) : Parcelable

@Parcelize
data class DeviceInfo(
    @SerializedName("platform")
    val platform: String = "Android",
    
    @SerializedName("version")
    val version: String = android.os.Build.VERSION.RELEASE,
    
    @SerializedName("model")
    val model: String = android.os.Build.MODEL,
    
    @SerializedName("manufacturer")
    val manufacturer: String = android.os.Build.MANUFACTURER
) : Parcelable