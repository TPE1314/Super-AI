import asyncio
import logging
import json
from typing import Dict, Any, Optional
from datetime import datetime
import aiohttp

from telegram import Update, InlineKeyboardButton, InlineKeyboardMarkup
from telegram.ext import (
    Application, CommandHandler, MessageHandler, CallbackQueryHandler,
    filters, ContextTypes
)
from telegram.constants import ParseMode

from config import Config
from media_handler import MediaHandler

# 配置日志
logging.basicConfig(
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    level=getattr(logging, Config.LOG_LEVEL),
    filename=Config.LOG_FILE
)
logger = logging.getLogger(__name__)

class TelegramBot:
    """Telegram双向机器人主类"""
    
    def __init__(self):
        self.application = Application.builder().token(Config.BOT_TOKEN).build()
        self.media_handler = MediaHandler()
        self.user_sessions = {}  # 存储用户会话状态
        self.setup_handlers()
    
    def setup_handlers(self):
        """设置消息处理器"""
        # 命令处理器
        self.application.add_handler(CommandHandler("start", self.start_command))
        self.application.add_handler(CommandHandler("help", self.help_command))
        self.application.add_handler(CommandHandler("status", self.status_command))
        # self.application.add_handler(CommandHandler("upload", self.upload_command))
        # self.application.add_handler(CommandHandler("download", self.download_command))
        # self.application.add_handler(CommandHandler("list", self.list_command))
        # self.application.add_handler(CommandHandler("delete", self.delete_command))
        
        # 媒体消息处理器
        self.application.add_handler(MessageHandler(filters.PHOTO, self.handle_photo))
        self.application.add_handler(MessageHandler(filters.VIDEO, self.handle_video))
        self.application.add_handler(MessageHandler(filters.AUDIO, self.handle_audio))
        self.application.add_handler(MessageHandler(filters.Document.ALL, self.handle_document))
        
        # 文本消息处理器
        self.application.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, self.handle_text))
        
        # 回调查询处理器
        self.application.add_handler(CallbackQueryHandler(self.handle_callback))
        
        # 错误处理器
        self.application.add_error_handler(self.error_handler)
    
    async def start_command(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """处理 /start 命令"""
        user = update.effective_user
        welcome_message = f"""
🤖 欢迎使用多媒体Telegram机器人！

👤 用户ID: {user.id}
👤 用户名: {user.username or '未设置'}
📅 注册时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

📋 可用命令:
/help - 显示帮助信息
/upload - 上传文件
/download - 下载文件
/list - 列出文件
/status - 显示状态
/delete - 删除文件

💡 直接发送图片、视频、音频或文档即可上传！
        """
        
        keyboard = [
            [InlineKeyboardButton("📤 上传文件", callback_data="upload")],
            [InlineKeyboardButton("📥 下载文件", callback_data="download")],
            [InlineKeyboardButton("📋 文件列表", callback_data="list")],
            [InlineKeyboardButton("❓ 帮助", callback_data="help")]
        ]
        reply_markup = InlineKeyboardMarkup(keyboard)
        
        await update.message.reply_text(
            welcome_message,
            reply_markup=reply_markup,
            parse_mode=ParseMode.HTML
        )
    
    async def help_command(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """处理 /help 命令"""
        help_text = """
📚 <b>帮助信息</b>

<b>基本命令:</b>
• /start - 启动机器人
• /help - 显示此帮助信息
• /status - 显示机器人状态

<b>文件操作:</b>
• /upload - 上传文件
• /download - 下载文件
• /list - 列出所有文件
• /delete - 删除指定文件

<b>支持的文件类型:</b>
🖼️ 图片: JPG, PNG, GIF, WebP
🎥 视频: MP4, AVI, MOV, MKV, WebM
🎵 音频: MP3, WAV, OGG, M4A, FLAC
📄 文档: PDF, DOC, TXT, ZIP, RAR

<b>使用方法:</b>
1. 直接发送文件即可自动上传
2. 使用命令进行文件管理
3. 支持双向文件传输

💡 <i>提示: 文件大小限制为50MB</i>
        """
        
        await update.message.reply_text(help_text, parse_mode=ParseMode.HTML)
    
    async def status_command(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """处理 /status 命令"""
        stats = self.media_handler.get_media_stats()
        
        status_text = f"""
📊 <b>机器人状态</b>

📁 <b>文件统计:</b>
🖼️ 图片: {stats.get('photos', {}).get('count', 0)} 个
🎥 视频: {stats.get('videos', {}).get('count', 0)} 个
🎵 音频: {stats.get('audios', {}).get('count', 0)} 个
📄 文档: {stats.get('documents', {}).get('count', 0)} 个

💾 <b>存储信息:</b>
📁 上传目录: {Config.UPLOAD_FOLDER}
📏 最大文件大小: {Config.MAX_FILE_SIZE // (1024*1024)} MB

🔄 <b>运行状态:</b>
✅ 机器人运行中
⏰ 最后更新: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
        """
        
        await update.message.reply_text(status_text, parse_mode=ParseMode.HTML)
    
    async def handle_photo(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """处理图片消息"""
        await self._handle_media(update, context, 'photo')
    
    async def handle_video(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """处理视频消息"""
        await self._handle_media(update, context, 'video')
    
    async def handle_audio(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """处理音频消息"""
        await self._handle_media(update, context, 'audio')
    
    async def handle_document(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """处理文档消息"""
        await self._handle_media(update, context, 'document')
    
    async def _handle_media(self, update: Update, context: ContextTypes.DEFAULT_TYPE, media_type: str):
        """统一处理媒体文件"""
        try:
            # 获取文件信息
            if media_type == 'photo':
                file_obj = update.message.photo[-1]  # 获取最大尺寸的图片
                caption = update.message.caption or "图片"
            elif media_type == 'video':
                file_obj = update.message.video
                caption = update.message.caption or "视频"
            elif media_type == 'audio':
                file_obj = update.message.audio
                caption = update.message.caption or "音频"
            elif media_type == 'document':
                file_obj = update.message.document
                caption = update.message.caption or "文档"
            else:
                return
            
            # 下载文件
            file_data = await self._download_file(file_obj)
            if not file_data:
                await update.message.reply_text("❌ 文件下载失败")
                return
            
            # 保存文件
            filename = file_obj.file_name or f"{media_type}_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
            result = await self.media_handler.save_media(file_data, filename, media_type)
            
            if result['success']:
                # 发送成功消息
                success_text = f"""
✅ <b>文件上传成功！</b>

📁 <b>文件名:</b> {result['filename']}
📊 <b>文件大小:</b> {result['file_info']['size'] // 1024} KB
📁 <b>保存路径:</b> {result['file_path']}
                """
                
                if media_type == 'photo' and 'width' in result['file_info']:
                    success_text += f"\n🖼️ <b>图片尺寸:</b> {result['file_info']['width']}x{result['file_info']['height']}"
                
                await update.message.reply_text(success_text, parse_mode=ParseMode.HTML)
            else:
                await update.message.reply_text(f"❌ 文件保存失败: {result['error']}")
                
        except Exception as e:
            logger.error(f"处理{media_type}失败: {e}")
            await update.message.reply_text(f"❌ 处理{media_type}时发生错误")
    
    async def _download_file(self, file_obj) -> Optional[bytes]:
        """下载文件"""
        try:
            file_data = await file_obj.download_as_bytearray()
            return bytes(file_data)
        except Exception as e:
            logger.error(f"下载文件失败: {e}")
            return None
    
    async def handle_text(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """处理文本消息"""
        text = update.message.text
        user_id = update.effective_user.id
        
        # 检查用户会话状态
        if user_id in self.user_sessions:
            session = self.user_sessions[user_id]
            await self._handle_session(update, context, session, text)
        else:
            # 默认回复
            await update.message.reply_text(
                "💬 收到您的消息！\n\n"
                "使用 /help 查看可用命令，或直接发送文件进行上传。"
            )
    
    async def _handle_session(self, update: Update, context: ContextTypes.DEFAULT_TYPE, session: Dict, text: str):
        """处理用户会话"""
        if session['type'] == 'upload':
            # 处理上传会话
            await self._handle_upload_session(update, context, session, text)
        else:
            # 清除无效会话
            del self.user_sessions[update.effective_user.id]
            await update.message.reply_text("❌ 会话已过期，请重新开始")
    
    async def _handle_upload_session(self, update: Update, context: ContextTypes.DEFAULT_TYPE, session: Dict, text: str):
        """处理上传会话"""
        user_id = update.effective_user.id
        
        if text.lower() in ['取消', 'cancel', '退出']:
            del self.user_sessions[user_id]
            await update.message.reply_text("✅ 已取消上传模式")
            return
        
        await update.message.reply_text(
            "📤 上传模式已激活！\n\n"
            "请直接发送要上传的文件，或输入 '取消' 退出上传模式。"
        )
    
    async def handle_callback(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """处理回调查询"""
        query = update.callback_query
        await query.answer()
        
        if query.data == "upload":
            await self._start_upload_session(query)
        elif query.data == "download":
            await self._start_download_session(query)
        elif query.data == "list":
            await self._show_file_list(query)
        elif query.data == "help":
            await self._show_help(query)
    
    async def _start_upload_session(self, query):
        """开始上传会话"""
        user_id = query.from_user.id
        self.user_sessions[user_id] = {
            'type': 'upload',
            'step': 'waiting_file'
        }
        
        await query.edit_message_text(
            "📤 <b>上传模式已激活</b>\n\n"
            "请直接发送要上传的文件（图片、视频、音频或文档）\n\n"
            "💡 支持的文件类型请查看 /help 命令",
            parse_mode=ParseMode.HTML
        )
    
    async def _start_download_session(self, query):
        """开始下载会话"""
        # 这里可以实现文件下载功能
        await query.edit_message_text(
            "📥 <b>下载功能</b>\n\n"
            "目前支持通过 /list 命令查看文件列表\n\n"
            "💡 下载功能正在开发中...",
            parse_mode=ParseMode.HTML
        )
    
    async def _show_file_list(self, query):
        """显示文件列表"""
        stats = self.media_handler.get_media_stats()
        
        list_text = "📋 <b>文件列表</b>\n\n"
        for media_type, info in stats.items():
            if info['count'] > 0:
                list_text += f"📁 <b>{media_type.title()}:</b> {info['count']} 个文件\n"
        
        if not any(info['count'] > 0 for info in stats.values()):
            list_text += "📭 暂无文件"
        
        await query.edit_message_text(list_text, parse_mode=ParseMode.HTML)
    
    async def _show_help(self, query):
        """显示帮助信息"""
        help_text = """
📚 <b>帮助信息</b>

<b>基本操作:</b>
• 直接发送文件即可上传
• 使用 /help 查看详细帮助
• 使用 /status 查看机器人状态

<b>支持格式:</b>
🖼️ 图片: JPG, PNG, GIF, WebP
🎥 视频: MP4, AVI, MOV, MKV, WebM
🎵 音频: MP3, WAV, OGG, M4A, FLAC
📄 文档: PDF, DOC, TXT, ZIP, RAR

💡 <i>文件大小限制: 50MB</i>
        """
        
        await query.edit_message_text(help_text, parse_mode=ParseMode.HTML)
    
    async def error_handler(self, update: Update, context: ContextTypes.DEFAULT_TYPE):
        """错误处理器"""
        logger.error(f"更新 {update} 导致错误 {context.error}")
        if update and update.effective_message:
            await update.effective_message.reply_text(
                "❌ 处理消息时发生错误，请稍后重试"
            )
    
    async def start_polling(self):
        """开始轮询模式"""
        logger.info("启动机器人轮询模式...")
        await self.application.initialize()
        await self.application.start()
        await self.application.updater.start_polling()
        
        try:
            # 保持运行
            await asyncio.Event().wait()
        except KeyboardInterrupt:
            logger.info("收到停止信号，正在关闭机器人...")
        finally:
            await self.application.updater.stop()
            await self.application.stop()
            await self.application.shutdown()
    
    async def start_webhook(self):
        """启动Webhook模式"""
        logger.info("启动机器人Webhook模式...")
        await self.application.initialize()
        await self.application.start()
        await self.application.updater.start_webhook(
            listen="0.0.0.0",
            port=8443,
            url_path=Config.BOT_TOKEN,
            webhook_url=Config.WEBHOOK_URL
        )
        
        try:
            # 保持运行
            await asyncio.Event().wait()
        except KeyboardInterrupt:
            logger.info("收到停止信号，正在关闭机器人...")
        finally:
            await self.application.updater.stop_webhook()
            await self.application.stop()
            await self.application.shutdown()

async def main():
    """主函数"""
    if not Config.BOT_TOKEN:
        logger.error("未设置BOT_TOKEN环境变量")
        return
    
    bot = TelegramBot()
    
    # 根据配置选择启动模式
    if Config.WEBHOOK_URL:
        await bot.start_webhook()
    else:
        await bot.start_polling()

if __name__ == "__main__":
    asyncio.run(main())