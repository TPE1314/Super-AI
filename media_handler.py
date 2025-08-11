import os
import logging
from typing import Optional, Union, Dict, Any
from pathlib import Path
import aiofiles
from PIL import Image
import mimetypes
from config import Config

logger = logging.getLogger(__name__)

class MediaHandler:
    """处理各种类型的媒体文件"""
    
    def __init__(self):
        self.upload_folder = Path(Config.UPLOAD_FOLDER)
        self.upload_folder.mkdir(exist_ok=True)
        
        # 创建子目录
        (self.upload_folder / 'photos').mkdir(exist_ok=True)
        (self.upload_folder / 'videos').mkdir(exist_ok=True)
        (self.upload_folder / 'audios').mkdir(exist_ok=True)
        (self.upload_folder / 'documents').mkdir(exist_ok=True)
    
    async def save_media(self, file_data: bytes, filename: str, media_type: str) -> Dict[str, Any]:
        """保存媒体文件"""
        try:
            # 确定文件扩展名
            file_ext = self._get_file_extension(filename)
            
            # 验证文件类型
            if not self._is_supported_format(file_ext, media_type):
                return {
                    'success': False,
                    'error': f'不支持的文件格式: {file_ext}'
                }
            
            # 生成唯一文件名
            unique_filename = self._generate_unique_filename(filename)
            
            # 确定保存路径
            save_path = self._get_save_path(unique_filename, media_type)
            
            # 保存文件
            async with aiofiles.open(save_path, 'wb') as f:
                await f.write(file_data)
            
            # 获取文件信息
            file_info = await self._get_file_info(save_path, media_type)
            
            return {
                'success': True,
                'file_path': str(save_path),
                'filename': unique_filename,
                'file_info': file_info
            }
            
        except Exception as e:
            logger.error(f"保存媒体文件失败: {e}")
            return {
                'success': False,
                'error': str(e)
            }
    
    def _get_file_extension(self, filename: str) -> str:
        """获取文件扩展名"""
        return Path(filename).suffix.lower()
    
    def _is_supported_format(self, file_ext: str, media_type: str) -> bool:
        """检查是否为支持的文件格式"""
        if media_type == 'photo':
            return file_ext in Config.SUPPORTED_PHOTO_FORMATS
        elif media_type == 'video':
            return file_ext in Config.SUPPORTED_VIDEO_FORMATS
        elif media_type == 'audio':
            return file_ext in Config.SUPPORTED_AUDIO_FORMATS
        elif media_type == 'document':
            return file_ext in Config.SUPPORTED_DOCUMENT_FORMATS
        return False
    
    def _generate_unique_filename(self, filename: str) -> str:
        """生成唯一的文件名"""
        name, ext = os.path.splitext(filename)
        counter = 1
        unique_name = filename
        
        while Path(self.upload_folder / unique_name).exists():
            unique_name = f"{name}_{counter}{ext}"
            counter += 1
        
        return unique_name
    
    def _get_save_path(self, filename: str, media_type: str) -> Path:
        """获取保存路径"""
        if media_type == 'photo':
            return self.upload_folder / 'photos' / filename
        elif media_type == 'video':
            return self.upload_folder / 'videos' / filename
        elif media_type == 'audio':
            return self.upload_folder / 'audios' / filename
        elif media_type == 'document':
            return self.upload_folder / 'documents' / filename
        else:
            return self.upload_folder / filename
    
    async def _get_file_info(self, file_path: Path, media_type: str) -> Dict[str, Any]:
        """获取文件信息"""
        file_info = {
            'size': file_path.stat().st_size,
            'mime_type': mimetypes.guess_type(str(file_path))[0],
            'media_type': media_type
        }
        
        # 对于图片，获取尺寸信息
        if media_type == 'photo' and file_path.suffix.lower() in ['.jpg', '.jpeg', '.png', '.gif', '.webp']:
            try:
                with Image.open(file_path) as img:
                    file_info['width'] = img.width
                    file_info['height'] = img.height
                    file_info['format'] = img.format
            except Exception as e:
                logger.warning(f"无法获取图片信息: {e}")
        
        return file_info
    
    async def delete_media(self, file_path: str) -> bool:
        """删除媒体文件"""
        try:
            path = Path(file_path)
            if path.exists():
                path.unlink()
                return True
            return False
        except Exception as e:
            logger.error(f"删除文件失败: {e}")
            return False
    
    def get_media_stats(self) -> Dict[str, Any]:
        """获取媒体文件统计信息"""
        stats = {}
        for media_type in ['photos', 'videos', 'audios', 'documents']:
            folder = self.upload_folder / media_type
            if folder.exists():
                files = list(folder.glob('*'))
                stats[media_type] = {
                    'count': len(files),
                    'total_size': sum(f.stat().st_size for f in files if f.is_file())
                }
        return stats