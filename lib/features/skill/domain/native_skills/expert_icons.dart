/// 专家技能图标映射 - 替换 Emoji
/// 
/// 使用 Material Icons 替换所有 Emoji，
/// 提供统一的视觉语言。
/// 
/// @author JianMa
/// @version 1.0.0
library;

import 'package:flutter/material.dart';
import '../../../../core/theme/app_icons.dart';

/// 专家技能图标配置
class ExpertIconConfig {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const ExpertIconConfig({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

/// 专家技能图标映射表
class ExpertIcons {
  ExpertIcons._();

  // =====================================================
  // 设计领域
  // =====================================================

  /// 品牌策略专家
  static const brandStrategy = ExpertIconConfig(
    id: 'expert.design.brand_strategy',
    name: '品牌策略专家',
    icon: Icons.palette_outlined,
    color: Color(0xFFEC4899), // 粉色
  );

  /// UI/UX 设计专家
  static const uiuxDesign = ExpertIconConfig(
    id: 'expert.design.uiux',
    name: 'UI/UX 设计专家',
    icon: Icons.brush_outlined,
    color: Color(0xFF8B5CF6), // 紫色
  );

  /// 视觉传达专家
  static const visualDesign = ExpertIconConfig(
    id: 'expert.design.visual',
    name: '视觉传达专家',
    icon: Icons.color_lens_outlined,
    color: Color(0xFFF59E0B), // 黄色
  );

  // =====================================================
  // 工程技术领域
  // =====================================================

  /// 前端开发专家
  static const frontendDev = ExpertIconConfig(
    id: 'expert.engineering.frontend',
    name: '前端开发专家',
    icon: Icons.code_outlined,
    color: Color(0xFF3B82F6), // 蓝色
  );

  /// 后端开发专家
  static const backendDev = ExpertIconConfig(
    id: 'expert.engineering.backend',
    name: '后端开发专家',
    icon: Icons.storage_outlined,
    color: Color(0xFF22C55E), // 绿色
  );

  /// AI/ML 工程师
  static const aiMl = ExpertIconConfig(
    id: 'expert.engineering.ai_ml',
    name: 'AI/ML 工程师',
    icon: Icons.auto_awesome,
    color: Color(0xFF6366F1), // 靛蓝
  );

  /// DevOps 专家
  static const devops = ExpertIconConfig(
    id: 'expert.engineering.devops',
    name: 'DevOps 专家',
    icon: Icons.cloud_outlined,
    color: Color(0xFF06B6D4), // 天蓝
  );

  /// 安全专家
  static const security = ExpertIconConfig(
    id: 'expert.engineering.security',
    name: '安全专家',
    icon: Icons.shield_outlined,
    color: Color(0xFFEF4444), // 红色
  );

  /// 架构师
  static const architect = ExpertIconConfig(
    id: 'expert.engineering.architect',
    name: '架构师',
    icon: Icons.account_tree_outlined,
    color: Color(0xFF8B5CF6), // 紫色
  );

  /// 提示词工程师
  static const promptEngineer = ExpertIconConfig(
    id: 'expert.engineering.prompt_engineer',
    name: '提示词工程师',
    icon: Icons.chat_bubble_outline,
    color: Color(0xFFEC4899), // 粉色
  );

  /// 算法工程师
  static const algorithmEngineer = ExpertIconConfig(
    id: 'expert.engineering.algorithm',
    name: '算法工程师',
    icon: Icons.functions,
    color: Color(0xFFF97316), // 橙色
  );

  // =====================================================
  // 市场营销领域
  // =====================================================

  /// 内容创作专家
  static const contentCreation = ExpertIconConfig(
    id: 'expert.marketing.content',
    name: '内容创作专家',
    icon: Icons.edit_note,
    color: Color(0xFF22C55E), // 绿色
  );

  /// 社交媒体专家
  static const socialMedia = ExpertIconConfig(
    id: 'expert.marketing.social',
    name: '社交媒体专家',
    icon: Icons.share_outlined,
    color: Color(0xFF3B82F6), // 蓝色
  );

  /// SEO 专家
  static const seo = ExpertIconConfig(
    id: 'expert.marketing.seo',
    name: 'SEO 专家',
    icon: Icons.search,
    color: Color(0xFFF59E0B), // 黄色
  );

  /// 增长黑客
  static const growthHacker = ExpertIconConfig(
    id: 'expert.marketing.growth',
    name: '增长黑客',
    icon: Icons.trending_up,
    color: Color(0xFF22C55E), // 绿色
  );

  // =====================================================
  // 产品领域
  // =====================================================

  /// 产品经理
  static const productManager = ExpertIconConfig(
    id: 'expert.product.manager',
    name: '产品经理',
    icon: Icons.dashboard_outlined,
    color: Color(0xFF3B82F6), // 蓝色
  );

  /// 行为设计专家
  static const behaviorDesign = ExpertIconConfig(
    id: 'expert.product.behavior',
    name: '行为设计专家',
    icon: Icons.psychology_outlined,
    color: Color(0xFF8B5CF6), // 紫色
  );

  // =====================================================
  // 项目管理领域
  // =====================================================

  /// 敏捷教练
  static const agileCoach = ExpertIconConfig(
    id: 'expert.project.agile',
    name: '敏捷教练',
    icon: Icons.speed,
    color: Color(0xFF22C55E), // 绿色
  );

  // =====================================================
  // 质量测试领域
  // =====================================================

  /// 测试工程师
  static const qaEngineer = ExpertIconConfig(
    id: 'expert.qa.testing',
    name: '测试工程师',
    icon: Icons.bug_report_outlined,
    color: Color(0xFFEF4444), // 红色
  );

  // =====================================================
  // 运营支持领域
  // =====================================================

  /// 数据分析师
  static const dataAnalyst = ExpertIconConfig(
    id: 'expert.operations.data',
    name: '数据分析师',
    icon: Icons.analytics_outlined,
    color: Color(0xFF3B82F6), // 蓝色
  );

  /// 财务专家
  static const finance = ExpertIconConfig(
    id: 'expert.operations.finance',
    name: '财务专家',
    icon: Icons.account_balance_outlined,
    color: Color(0xFF22C55E), // 绿色
  );

  // =====================================================
  // 专业服务领域
  // =====================================================

  /// 法务专家
  static const legal = ExpertIconConfig(
    id: 'expert.professional.legal',
    name: '法务专家',
    icon: Icons.gavel_outlined,
    color: Color(0xFF6B7280), // 灰色
  );

  /// 招聘专家
  static const recruitment = ExpertIconConfig(
    id: 'expert.professional.recruitment',
    name: '招聘专家',
    icon: Icons.person_search_outlined,
    color: Color(0xFF3B82F6), // 蓝色
  );

  // =====================================================
  // 游戏开发领域
  // =====================================================

  /// 游戏设计师
  static const gameDesigner = ExpertIconConfig(
    id: 'expert.gaming.design',
    name: '游戏设计师',
    icon: Icons.sports_esports_outlined,
    color: Color(0xFFEC4899), // 粉色
  );

  /// 游戏性能优化
  static const gamePerformance = ExpertIconConfig(
    id: 'expert.gaming.performance',
    name: '游戏性能优化',
    icon: Icons.speed,
    color: Color(0xFFF59E0B), // 黄色
  );

  // =====================================================
  // 空间计算领域
  // =====================================================

  /// XR 开发专家
  static const xrDeveloper = ExpertIconConfig(
    id: 'expert.xr.development',
    name: 'XR 开发专家',
    icon: Icons.view_in_ar_outlined,
    color: Color(0xFF6366F1), // 靛蓝
  );

  // =====================================================
  // 创意内容领域
  // =====================================================

  /// 漫剧编导
  static const comicDirector = ExpertIconConfig(
    id: 'expert.creative.comic',
    name: '漫剧编导',
    icon: Icons.movie_outlined,
    color: Color(0xFFEC4899), // 粉色
  );

  /// 小说家
  static const novelist = ExpertIconConfig(
    id: 'expert.creative.novelist',
    name: '小说家',
    icon: Icons.book_outlined,
    color: Color(0xFF8B5CF6), // 紫色
  );

  // =====================================================
  // 教育学习领域
  // =====================================================

  /// 中小学老师
  static const teacher = ExpertIconConfig(
    id: 'expert.education.teacher',
    name: '中小学老师',
    icon: Icons.school_outlined,
    color: Color(0xFF22C55E), // 绿色
  );

  /// 外教英语
  static const englishTutor = ExpertIconConfig(
    id: 'expert.education.english',
    name: '外教英语',
    icon: Icons.language,
    color: Color(0xFF3B82F6), // 蓝色
  );

  // =====================================================
  // 工具方法
  // =====================================================

  /// 所有专家图标配置
  static const List<ExpertIconConfig> all = [
    brandStrategy,
    uiuxDesign,
    visualDesign,
    frontendDev,
    backendDev,
    aiMl,
    devops,
    security,
    architect,
    promptEngineer,
    algorithmEngineer,
    contentCreation,
    socialMedia,
    seo,
    growthHacker,
    productManager,
    behaviorDesign,
    agileCoach,
    qaEngineer,
    dataAnalyst,
    finance,
    legal,
    recruitment,
    gameDesigner,
    gamePerformance,
    xrDeveloper,
    comicDirector,
    novelist,
    teacher,
    englishTutor,
  ];

  /// 根据专家 ID 获取图标配置
  static ExpertIconConfig? getById(String id) {
    try {
      return all.firstWhere((config) => config.id == id);
    } catch (_) {
      return null;
    }
  }

  /// 根据专家名称获取图标配置
  static ExpertIconConfig? getByName(String name) {
    try {
      return all.firstWhere((config) => config.name == name);
    } catch (_) {
      return null;
    }
  }

  /// 获取默认图标配置
  static const defaultConfig = ExpertIconConfig(
    id: 'expert.default',
    name: '专家',
    icon: Icons.person_outlined,
    color: Color(0xFF6B7280),
  );
}
