package com.example.robotapi.viewmodel

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.viewModelScope
import com.example.robotapi.data.ChatMessage
import com.example.robotapi.database.AppDatabase
import kotlinx.coroutines.launch

class HistoryViewModel(application: Application) : AndroidViewModel(application) {
    
    private val database = AppDatabase.getDatabase(application)
    private val dao = database.chatMessageDao()
    
    private val _messages = MutableLiveData<List<ChatMessage>>()
    val messages: LiveData<List<ChatMessage>> = _messages
    
    private val _messageCount = MutableLiveData<Int>()
    val messageCount: LiveData<Int> = _messageCount
    
    private var currentSearchQuery = ""
    
    init {
        loadMessages()
        loadMessageCount()
    }
    
    private fun loadMessages() {
        viewModelScope.launch {
            dao.getAllMessages().collect { messages ->
                _messages.value = messages
            }
        }
    }
    
    private fun loadMessageCount() {
        viewModelScope.launch {
            val count = dao.getMessageCount()
            _messageCount.value = count
        }
    }
    
    fun searchMessages(query: String) {
        currentSearchQuery = query
        viewModelScope.launch {
            if (query.isEmpty()) {
                dao.getAllMessages().collect { messages ->
                    _messages.value = messages
                }
            } else {
                dao.searchMessages(query).collect { messages ->
                    _messages.value = messages
                }
            }
        }
    }
    
    fun deleteMessage(message: ChatMessage) {
        viewModelScope.launch {
            dao.deleteMessage(message)
            loadMessageCount()
        }
    }
    
    fun clearAllMessages() {
        viewModelScope.launch {
            dao.deleteAllMessages()
            loadMessageCount()
        }
    }
    
    fun exportMessages() {
        // TODO: 实现导出功能
        viewModelScope.launch {
            val messages = dao.getAllMessages()
            // 这里可以添加导出到文件的功能
        }
    }
    
    fun addMessage(message: ChatMessage) {
        viewModelScope.launch {
            dao.insertMessage(message)
            loadMessageCount()
        }
    }
}