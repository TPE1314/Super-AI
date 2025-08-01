package com.example.robotapi.ui

import android.view.LayoutInflater
import android.view.ViewGroup
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.example.robotapi.data.ChatMessage
import com.example.robotapi.databinding.ItemHistoryBinding

class HistoryAdapter(
    private val onItemClick: (ChatMessage) -> Unit,
    private val onItemLongClick: (ChatMessage) -> Unit
) : ListAdapter<ChatMessage, HistoryAdapter.ViewHolder>(ChatMessageDiffCallback()) {
    
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        val binding = ItemHistoryBinding.inflate(
            LayoutInflater.from(parent.context),
            parent,
            false
        )
        return ViewHolder(binding)
    }
    
    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        holder.bind(getItem(position))
    }
    
    inner class ViewHolder(private val binding: ItemHistoryBinding) : 
        RecyclerView.ViewHolder(binding.root) {
        
        init {
            binding.root.setOnClickListener {
                val position = adapterPosition
                if (position != RecyclerView.NO_POSITION) {
                    onItemClick(getItem(position))
                }
            }
            
            binding.root.setOnLongClickListener {
                val position = adapterPosition
                if (position != RecyclerView.NO_POSITION) {
                    onItemLongClick(getItem(position))
                }
                true
            }
        }
        
        fun bind(message: ChatMessage) {
            binding.apply {
                messageText.text = message.message
                responseText.text = message.response
                timeText.text = message.getShortTime()
                apiUrlText.text = message.apiUrl
                
                // 设置状态图标
                statusIcon.setImageResource(
                    if (message.isSuccess) {
                        android.R.drawable.ic_dialog_info
                    } else {
                        android.R.drawable.ic_dialog_alert
                    }
                )
                
                // 设置错误信息（如果有）
                errorText.text = message.errorMessage
                errorText.visibility = if (message.errorMessage != null) {
                    android.view.View.VISIBLE
                } else {
                    android.view.View.GONE
                }
            }
        }
    }
    
    private class ChatMessageDiffCallback : DiffUtil.ItemCallback<ChatMessage>() {
        override fun areItemsTheSame(oldItem: ChatMessage, newItem: ChatMessage): Boolean {
            return oldItem.id == newItem.id
        }
        
        override fun areContentsTheSame(oldItem: ChatMessage, newItem: ChatMessage): Boolean {
            return oldItem == newItem
        }
    }
}