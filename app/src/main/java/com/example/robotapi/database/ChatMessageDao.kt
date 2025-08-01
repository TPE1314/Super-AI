package com.example.robotapi.database

import androidx.room.*
import com.example.robotapi.data.ChatMessage
import kotlinx.coroutines.flow.Flow

@Dao
interface ChatMessageDao {
    
    @Query("SELECT * FROM chat_messages ORDER BY timestamp DESC")
    fun getAllMessages(): Flow<List<ChatMessage>>
    
    @Query("SELECT * FROM chat_messages WHERE isSuccess = 1 ORDER BY timestamp DESC")
    fun getSuccessfulMessages(): Flow<List<ChatMessage>>
    
    @Query("SELECT * FROM chat_messages WHERE message LIKE '%' || :query || '%' OR response LIKE '%' || :query || '%' ORDER BY timestamp DESC")
    fun searchMessages(query: String): Flow<List<ChatMessage>>
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertMessage(message: ChatMessage)
    
    @Delete
    suspend fun deleteMessage(message: ChatMessage)
    
    @Query("DELETE FROM chat_messages")
    suspend fun deleteAllMessages()
    
    @Query("SELECT COUNT(*) FROM chat_messages")
    suspend fun getMessageCount(): Int
    
    @Query("SELECT * FROM chat_messages ORDER BY timestamp DESC LIMIT 1")
    suspend fun getLatestMessage(): ChatMessage?
}