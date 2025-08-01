package com.example.robotapi.data

import android.os.Parcelable
import androidx.room.Entity
import androidx.room.PrimaryKey
import kotlinx.parcelize.Parcelize
import java.text.SimpleDateFormat
import java.util.*

@Entity(tableName = "chat_messages")
@Parcelize
data class ChatMessage(
    @PrimaryKey
    val id: String = UUID.randomUUID().toString(),
    val message: String,
    val response: String,
    val timestamp: Long = System.currentTimeMillis(),
    val apiUrl: String,
    val isSuccess: Boolean = true,
    val errorMessage: String? = null
) : Parcelable {
    
    fun getFormattedTime(): String {
        val date = Date(timestamp)
        val formatter = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault())
        return formatter.format(date)
    }
    
    fun getShortTime(): String {
        val date = Date(timestamp)
        val formatter = SimpleDateFormat("HH:mm", Locale.getDefault())
        return formatter.format(date)
    }
}