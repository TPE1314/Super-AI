import os
from dotenv import load_dotenv

# 加载环境变量
load_dotenv()

class Config:
    # Telegram Bot配置
    BOT_TOKEN = os.getenv('BOT_TOKEN')
    WEBHOOK_URL = os.getenv('WEBHOOK_URL', '')
    
    # 数据库配置（可选）
    DATABASE_URL = os.getenv('DATABASE_URL', 'sqlite:///bot.db')
    
    # 文件存储配置
    UPLOAD_FOLDER = os.getenv('UPLOAD_FOLDER', './uploads')
    MAX_FILE_SIZE = int(os.getenv('MAX_FILE_SIZE', 50 * 1024 * 1024))  # 50MB
    
    # 日志配置
    LOG_LEVEL = os.getenv('LOG_LEVEL', 'INFO')
    LOG_FILE = os.getenv('LOG_FILE', 'bot.log')
    
    # 安全配置
    ALLOWED_USERS = os.getenv('ALLOWED_USERS', '').split(',') if os.getenv('ALLOWED_USERS') else []
    ADMIN_USER_ID = int(os.getenv('ADMIN_USER_ID', 0))
    
    # 多媒体支持配置
    SUPPORTED_PHOTO_FORMATS = ['.jpg', '.jpeg', '.png', '.gif', '.webp']
    SUPPORTED_VIDEO_FORMATS = ['.mp4', '.avi', '.mov', '.mkv', '.webm']
    SUPPORTED_AUDIO_FORMATS = ['.mp3', '.wav', '.ogg', '.m4a', '.flac']
    SUPPORTED_DOCUMENT_FORMATS = ['.pdf', '.doc', '.docx', '.txt', '.zip', '.rar']