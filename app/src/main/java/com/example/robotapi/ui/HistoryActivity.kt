package com.example.robotapi.ui

import android.os.Bundle
import android.view.Menu
import android.view.MenuItem
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.widget.SearchView
import androidx.recyclerview.widget.LinearLayoutManager
import com.example.robotapi.R
import com.example.robotapi.databinding.ActivityHistoryBinding
import com.example.robotapi.viewmodel.HistoryViewModel
import com.google.android.material.snackbar.Snackbar

class HistoryActivity : AppCompatActivity() {
    
    private lateinit var binding: ActivityHistoryBinding
    private val viewModel: HistoryViewModel by viewModels()
    private lateinit var adapter: HistoryAdapter
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityHistoryBinding.inflate(layoutInflater)
        setContentView(binding.root)
        
        setupToolbar()
        setupRecyclerView()
        observeViewModel()
    }
    
    private fun setupToolbar() {
        setSupportActionBar(binding.toolbar)
        supportActionBar?.setDisplayHomeAsUpEnabled(true)
        title = "聊天历史"
    }
    
    private fun setupRecyclerView() {
        adapter = HistoryAdapter(
            onItemClick = { message ->
                // 可以在这里添加查看详情的功能
                showSnackbar("点击了: ${message.message}")
            },
            onItemLongClick = { message ->
                // 长按删除
                viewModel.deleteMessage(message)
                showSnackbar("已删除消息")
            }
        )
        
        binding.recyclerView.apply {
            layoutManager = LinearLayoutManager(this@HistoryActivity)
            adapter = this@HistoryActivity.adapter
        }
    }
    
    private fun observeViewModel() {
        viewModel.messages.observe(this) { messages ->
            adapter.submitList(messages)
            binding.emptyView.visibility = if (messages.isEmpty()) android.view.View.VISIBLE else android.view.View.GONE
        }
        
        viewModel.messageCount.observe(this) { count ->
            supportActionBar?.subtitle = "共 $count 条记录"
        }
    }
    
    override fun onCreateOptionsMenu(menu: Menu): Boolean {
        menuInflater.inflate(R.menu.menu_history, menu)
        
        val searchItem = menu.findItem(R.id.action_search)
        val searchView = searchItem.actionView as SearchView
        
        searchView.setOnQueryTextListener(object : SearchView.OnQueryTextListener {
            override fun onQueryTextSubmit(query: String?): Boolean {
                query?.let { viewModel.searchMessages(it) }
                return true
            }
            
            override fun onQueryTextChange(newText: String?): Boolean {
                newText?.let { viewModel.searchMessages(it) }
                return true
            }
        })
        
        return true
    }
    
    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        return when (item.itemId) {
            android.R.id.home -> {
                onBackPressed()
                true
            }
            R.id.action_clear_all -> {
                viewModel.clearAllMessages()
                showSnackbar("已清空所有记录")
                true
            }
            R.id.action_export -> {
                viewModel.exportMessages()
                showSnackbar("导出功能开发中...")
                true
            }
            else -> super.onOptionsItemSelected(item)
        }
    }
    
    private fun showSnackbar(message: String) {
        Snackbar.make(binding.root, message, Snackbar.LENGTH_SHORT).show()
    }
}