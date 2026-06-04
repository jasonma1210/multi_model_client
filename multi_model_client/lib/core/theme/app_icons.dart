/// MJ Nexus 图标系统 - Lucide Icons 集成
/// 
/// 提供统一的图标访问接口，
/// 替换 Material Icons 和 Emoji。
/// 
/// @author JianMa
/// @version 1.0.0
library;

import 'package:flutter/material.dart';

/// 应用图标系统
/// 
/// 使用 Material Icons 作为基础，提供语义化的图标访问
/// 后续可无缝切换到 Lucide Icons
class AppIcons {
  AppIcons._();

  // =====================================================
  // 导航图标
  // =====================================================

  /// 会话
  static const IconData chat = Icons.chat_outlined;
  static const IconData chatFilled = Icons.chat;
  
  /// 模型
  static const IconData model = Icons.smart_toy_outlined;
  static const IconData modelFilled = Icons.smart_toy;
  
  /// 设置
  static const IconData settings = Icons.settings_outlined;
  static const IconData settingsFilled = Icons.settings;
  
  /// 记忆
  static const IconData memory = Icons.psychology_outlined;
  static const IconData memoryFilled = Icons.psychology;
  
  /// 知识库
  static const IconData knowledge = Icons.library_books_outlined;
  static const IconData knowledgeFilled = Icons.library_books;
  
  /// 语音
  static const IconData voice = Icons.record_voice_over_outlined;
  static const IconData voiceFilled = Icons.record_voice_over;
  
  /// 插件/技能
  static const IconData plugin = Icons.extension_outlined;
  static const IconData pluginFilled = Icons.extension;
  
  /// 下载
  static const IconData download = Icons.download_rounded;
  static const IconData downloadFilled = Icons.download;
  
  /// 商店
  static const IconData store = Icons.storefront_outlined;
  static const IconData storeFilled = Icons.storefront;

  // =====================================================
  // 操作图标
  // =====================================================

  /// 搜索
  static const IconData search = Icons.search;
  
  /// 添加
  static const IconData add = Icons.add_rounded;
  
  /// 删除
  static const IconData delete = Icons.delete_outline;
  static const IconData deleteFilled = Icons.delete;
  
  /// 编辑
  static const IconData edit = Icons.edit_outlined;
  static const IconData editFilled = Icons.edit;
  
  /// 分享
  static const IconData share = Icons.share_outlined;
  static const IconData shareFilled = Icons.share;
  
  /// 复制
  static const IconData copy = Icons.copy_outlined;
  static const IconData copyFilled = Icons.copy;
  
  /// 刷新
  static const IconData refresh = Icons.refresh_rounded;
  
  /// 关闭
  static const IconData close = Icons.close;
  
  /// 返回
  static const IconData back = Icons.arrow_back;
  
  /// 前进
  static const IconData forward = Icons.arrow_forward;
  
  /// 更多
  static const IconData more = Icons.more_vert;
  static const IconData moreHorizontal = Icons.more_horiz;

  // =====================================================
  // 文件类型图标
  // =====================================================

  /// PDF
  static const IconData pdf = Icons.picture_as_pdf;
  
  /// 文档
  static const IconData document = Icons.description_outlined;
  
  /// 表格
  static const IconData spreadsheet = Icons.table_chart_outlined;
  
  /// 图片
  static const IconData image = Icons.image_outlined;
  
  /// 音频
  static const IconData audio = Icons.audio_file_outlined;
  
  /// 视频
  static const IconData video = Icons.video_file_outlined;
  
  /// 通用文件
  static const IconData file = Icons.insert_drive_file_outlined;

  // =====================================================
  // 状态图标
  // =====================================================

  /// 成功
  static const IconData success = Icons.check_circle_outline_rounded;
  static const IconData successFilled = Icons.check_circle;
  
  /// 警告
  static const IconData warning = Icons.warning_amber_outlined;
  static const IconData warningFilled = Icons.warning_amber;
  
  /// 错误
  static const IconData error = Icons.error_outline_rounded;
  static const IconData errorFilled = Icons.error;
  
  /// 信息
  static const IconData info = Icons.info_outline;
  static const IconData infoFilled = Icons.info;
  
  /// 加载
  static const IconData loading = Icons.hourglass_empty;

  // =====================================================
  // 语音相关图标
  // =====================================================

  /// 麦克风
  static const IconData mic = Icons.mic;
  static const IconData micOff = Icons.mic_off;
  
  /// 扬声器
  static const IconData speaker = Icons.volume_up;
  static const IconData speakerOff = Icons.volume_off;
  
  /// 录音
  static const IconData record = Icons.fiber_manual_record;
  static const IconData stop = Icons.stop;

  // =====================================================
  // 媒体控制图标
  // =====================================================

  /// 播放
  static const IconData play = Icons.play_arrow;
  
  /// 暂停
  static const IconData pause = Icons.pause;
  
  /// 上一个
  static const IconData previous = Icons.skip_previous;
  
  /// 下一个
  static const IconData next = Icons.skip_next;

  // =====================================================
  // 专家技能图标（替换 Emoji）
  // =====================================================

  /// 设计
  static const IconData design = Icons.palette_outlined;
  
  /// 代码
  static const IconData code = Icons.code_outlined;
  
  /// AI
  static const IconData ai = Icons.auto_awesome;
  
  /// 营销
  static const IconData marketing = Icons.campaign_outlined;
  
  /// 产品
  static const IconData product = Icons.dashboard_outlined;
  
  /// 安全
  static const IconData security = Icons.shield_outlined;
  
  /// 数据
  static const IconData data = Icons.analytics_outlined;
  
  /// 写作
  static const IconData writing = Icons.edit_note;
  
  /// 教育
  static const IconData education = Icons.school_outlined;
  
  /// 游戏
  static const IconData gaming = Icons.sports_esports_outlined;
  
  /// 音乐
  static const IconData music = Icons.music_note_outlined;
  
  /// 法律
  static const IconData legal = Icons.gavel_outlined;
  
  /// 商业
  static const IconData business = Icons.business_outlined;
  
  /// 全球
  static const IconData global = Icons.language;
  
  /// 用户
  static const IconData user = Icons.person_outlined;
  
  /// 计算器
  static const IconData calculator = Icons.calculate_outlined;
  
  /// 时间
  static const IconData time = Icons.schedule_outlined;
  
  /// 灯泡（灵感）
  static const IconData lightbulb = Icons.lightbulb_outline;

  // =====================================================
  // 工具方法
  // =====================================================

  /// 根据专家领域获取图标
  static IconData getExpertIcon(String domain) {
    switch (domain.toLowerCase()) {
      case 'design':
      case 'ui/ux':
      case 'brand':
        return design;
      case 'engineering':
      case 'frontend':
      case 'backend':
      case 'devops':
        return code;
      case 'ai':
      case 'ml':
      case 'llm':
        return ai;
      case 'marketing':
      case 'social':
      case 'seo':
        return marketing;
      case 'product':
        return product;
      case 'security':
        return security;
      case 'data':
      case 'analytics':
        return data;
      case 'writing':
      case 'content':
        return writing;
      case 'education':
      case 'teaching':
        return education;
      case 'gaming':
        return gaming;
      case 'music':
        return music;
      case 'legal':
      case 'law':
        return legal;
      case 'business':
      case 'ecommerce':
        return business;
      case 'global':
      case 'international':
        return global;
      default:
        return user;
    }
  }

  /// 根据文件扩展名获取图标
  static IconData getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return pdf;
      case 'doc':
      case 'docx':
      case 'txt':
      case 'md':
        return document;
      case 'xls':
      case 'xlsx':
      case 'csv':
        return spreadsheet;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return image;
      case 'mp3':
      case 'wav':
      case 'aac':
        return audio;
      case 'mp4':
      case 'avi':
      case 'mov':
        return video;
      default:
        return file;
    }
  }
}
