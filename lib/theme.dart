// 设计系统 - 基于 taste-skill 美学
// Design Reading: cold luxury dark-tech, zinc monochrome + emerald accent
// Dials: VARIANCE 8 / MOTION 6 / DENSITY 4

import 'package:flutter/material.dart';

// ===== 色板 (Zinc Cold Luxury) =====
// 中性基底：Zinc 系列，避免纯黑纯白
// 强调色：Emerald 单一定调，饱和度 < 80%
class AppColors {
  // 背景层级
  static const Color background = Color(0xFF0F0F0F);      // zinc-950 主背景
  static const Color surface = Color(0xFF18181B);         // zinc-900 卡片背景
  static const Color surfaceElevated = Color(0xFF27272A); // zinc-800 抬高层

  // 边框与分隔
  static const Color border = Color(0xFF3F3F46);          // zinc-700
  static const Color borderSubtle = Color(0xFF27272A);    // zinc-800 微妙边框

  // 文本层级
  static const Color textPrimary = Color(0xFFFAFAFA);     // zinc-50 主文本
  static const Color textSecondary = Color(0xFFA1A1AA);   // zinc-400 次文本
  static const Color textMuted = Color(0xFF71717A);       // zinc-500 弱化文本

  // 单一强调色 (Emerald)
  static const Color accent = Color(0xFF34D399);          // emerald-400
  static const Color accentMuted = Color(0xFF10B981);     // emerald-500 深调
  static const Color accentSubtle = Color(0xFF064E3B);    // emerald-900 背景调

  // 状态色
  static const Color negative = Color(0xFFF87171);        // red-400 仅用于错误
  static const Color negativeSubtle = Color(0xFF451A1A);  // red-950 背景调

  // 转盘专用
  static const Color wheelYes = Color(0xFFFAFAFA);        // 白/撸
  static const Color wheelNo = Color(0xFF18181B);         // 黑/不撸
}

// ===== 排版系统 =====
// 规则：Inter 风格无衬线，tight tracking，层次分明
// 数字使用等宽字体
class AppText {
  // Display / 大标题
  static const TextStyle display = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  // 页面标题
  static const TextStyle title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
    height: 1.3,
  );

  // 卡片标题
  static const TextStyle cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  // 正文
  static const TextStyle body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.6,
    letterSpacing: 0,
  );

  // 正文强调
  static const TextStyle bodyStrong = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  // 辅助文本
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    letterSpacing: 0.1,
  );

  // 数字（等宽）
  static const TextStyle number = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -1.0,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  // 数字小
  static const TextStyle numberSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  // 按钮文字
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.background,
    letterSpacing: 0.2,
  );

  // 标签/小标题
  static const TextStyle label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
    letterSpacing: 0.3,
  );
}

// ===== 形状系统 =====
// 规则：Shape Consistency Lock — 12px 圆角统一
class AppShapes {
  static const double radius = 12.0;
  static const double radiusSm = 8.0;
  static const double radiusLg = 16.0;

  static BorderRadius get borderRadius => BorderRadius.circular(radius);
  static BorderRadius get borderRadiusSm => BorderRadius.circular(radiusSm);
  static BorderRadius get borderRadiusLg => BorderRadius.circular(radiusLg);
}

// ===== 间距系统 =====
// 规则：基于 4px 网格，呼吸感优先
class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

// ===== 阴影系统 =====
// 规则：色调与背景统一，不用纯黑阴影
class AppShadows {
  static List<BoxShadow> get card => [
        BoxShadow(
          color: AppColors.background.withOpacity(0.4),
          blurRadius: 12,
          offset: const Offset(0, 2),
        ),
        BoxShadow(
          color: AppColors.background.withOpacity(0.2),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get elevated => [
        BoxShadow(
          color: AppColors.background.withOpacity(0.6),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ];
}

// ===== 主题数据 =====
ThemeData buildAppTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.accent,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      secondary: AppColors.accentMuted,
      surface: AppColors.surface,
      error: AppColors.negative,
      onPrimary: AppColors.background,
      onSurface: AppColors.textPrimary,
    ),
    fontFamily: 'Roboto',
    textTheme: const TextTheme(
      displayLarge: AppText.display,
      titleLarge: AppText.title,
      bodyLarge: AppText.body,
      bodyMedium: AppText.body,
      labelLarge: AppText.button,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,  // 左对齐，反默认
    ),
    cardTheme: CardTheme(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppShapes.borderRadius,
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surfaceElevated,
      contentTextStyle: const TextStyle(color: AppColors.textPrimary),
      shape: RoundedRectangleBorder(borderRadius: AppShapes.borderRadius),
      behavior: SnackBarBehavior.floating,
    ),
  );
}
