// 设计系统 - 基于 taste-skill 美学
// Design Reading: cold luxury dark-tech, zinc monochrome + emerald accent
// Dials: VARIANCE 8 / MOTION 6 / DENSITY 4

import 'package:flutter/material.dart';

// ===== 暗色色板 (Zinc Cold Luxury) =====
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

// ===== 亮色色板 =====
// 暖白背景 + 深灰文字，保持 Emerald 强调色
class AppColorsLight {
  // 背景层级
  static const Color background = Color(0xFFFAFAFA);      // 暖白主背景
  static const Color surface = Color(0xFFFFFFFF);         // 纯白卡片
  static const Color surfaceElevated = Color(0xFFF4F4F5); // zinc-100 抬高层

  // 边框与分隔
  static const Color border = Color(0xFFD4D4D8);          // zinc-300
  static const Color borderSubtle = Color(0xFFE4E4E7);    // zinc-200 微妙边框

  // 文本层级
  static const Color textPrimary = Color(0xFF18181B);     // zinc-900 主文本
  static const Color textSecondary = Color(0xFF52525B);   // zinc-600 次文本
  static const Color textMuted = Color(0xFFA1A1AA);       // zinc-400 弱化文本

  // 单一强调色 (Emerald) - 保持不变
  static const Color accent = Color(0xFF10B981);          // emerald-500
  static const Color accentMuted = Color(0xFF059669);     // emerald-600 深调
  static const Color accentSubtle = Color(0xFFD1FAE5);    // emerald-100 背景调

  // 状态色
  static const Color negative = Color(0xFFDC2626);        // red-600 错误
  static const Color negativeSubtle = Color(0xFFFEE2E2);  // red-100 背景调

  // 转盘专用
  static const Color wheelYes = Color(0xFF18181B);        // 深/撸
  static const Color wheelNo = Color(0xFFFAFAFA);         // 白/不撸
}

// ===== 排版系统 =====
// 规则：Inter 风格无衬线，tight tracking，层次分明
// 数字使用等宽字体
// 注：颜色不在此处硬编码，由 ThemeData.textTheme 统一控制
class AppText {
  // Display / 大标题
  static const TextStyle display = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: null,  // 由 ThemeData 控制
    letterSpacing: -0.5,
    height: 1.2,
  );

  // 页面标题
  static const TextStyle title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: null,
    letterSpacing: -0.3,
    height: 1.3,
  );

  // 卡片标题
  static const TextStyle cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: null,
    letterSpacing: -0.2,
  );

  // 正文
  static const TextStyle body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: null,
    height: 1.6,
    letterSpacing: 0,
  );

  // 正文强调
  static const TextStyle bodyStrong = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: null,
    height: 1.5,
  );

  // 辅助文本
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: null,
    letterSpacing: 0.1,
  );

  // 数字（等宽）
  static const TextStyle number = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: null,
    letterSpacing: -1.0,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  // 数字小
  static const TextStyle numberSmall = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: null,
    letterSpacing: -0.3,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  // 按钮文字
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.background,  // 按钮文字颜色不变（深色背景按钮）
    letterSpacing: 0.2,
  );

  // 标签/小标题
  static const TextStyle label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: null,
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
  static List<BoxShadow> card(bool isDark) => [
        BoxShadow(
          color: (isDark ? AppColors.background : AppColorsLight.background).withOpacity(isDark ? 0.4 : 0.08),
          blurRadius: 12,
          offset: const Offset(0, 2),
        ),
        BoxShadow(
          color: (isDark ? AppColors.background : AppColorsLight.background).withOpacity(isDark ? 0.2 : 0.04),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> elevated(bool isDark) => [
        BoxShadow(
          color: (isDark ? AppColors.background : AppColorsLight.background).withOpacity(isDark ? 0.6 : 0.12),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ];
}

// ===== 动态颜色访问 =====
// 根据亮度返回对应色板中的颜色
class AppThemeColors {
  final bool isDark;
  AppThemeColors(this.isDark);

  Color get background => isDark ? AppColors.background : AppColorsLight.background;
  Color get surface => isDark ? AppColors.surface : AppColorsLight.surface;
  Color get surfaceElevated => isDark ? AppColors.surfaceElevated : AppColorsLight.surfaceElevated;
  Color get border => isDark ? AppColors.border : AppColorsLight.border;
  Color get borderSubtle => isDark ? AppColors.borderSubtle : AppColorsLight.borderSubtle;
  Color get textPrimary => isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;
  Color get textSecondary => isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;
  Color get textMuted => isDark ? AppColors.textMuted : AppColorsLight.textMuted;
  Color get accent => isDark ? AppColors.accent : AppColorsLight.accent;
  Color get accentMuted => isDark ? AppColors.accentMuted : AppColorsLight.accentMuted;
  Color get accentSubtle => isDark ? AppColors.accentSubtle : AppColorsLight.accentSubtle;
  Color get negative => isDark ? AppColors.negative : AppColorsLight.negative;
  Color get negativeSubtle => isDark ? AppColors.negativeSubtle : AppColorsLight.negativeSubtle;
  Color get wheelYes => isDark ? AppColors.wheelYes : AppColorsLight.wheelYes;
  Color get wheelNo => isDark ? AppColors.wheelNo : AppColorsLight.wheelNo;
}

// ===== BuildContext 扩展 =====
// 在 widgets 中通过 context.appColors 获取当前主题色
extension AppThemeContext on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  AppThemeColors get appColors => AppThemeColors(isDark);
}

// ===== 主题数据 =====
ThemeData buildAppTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final colors = AppThemeColors(isDark);

  return ThemeData(
    brightness: brightness,
    scaffoldBackgroundColor: colors.background,
    primaryColor: colors.accent,
    colorScheme: isDark
        ? const ColorScheme.dark(
            primary: AppColors.accent,
            secondary: AppColors.accentMuted,
            surface: AppColors.surface,
            error: AppColors.negative,
            onPrimary: AppColors.background,
            onSurface: AppColors.textPrimary,
            onSecondary: AppColors.textPrimary,
          )
        : const ColorScheme.light(
            primary: AppColorsLight.accent,
            secondary: AppColorsLight.accentMuted,
            surface: AppColorsLight.surface,
            error: AppColorsLight.negative,
            onPrimary: AppColorsLight.background,
            onSurface: AppColorsLight.textPrimary,
            onSecondary: AppColorsLight.textPrimary,
          ),
    fontFamily: 'Roboto',
    textTheme: TextTheme(
      displayLarge: AppText.display.copyWith(color: colors.textPrimary),
      displayMedium: AppText.title.copyWith(color: colors.textPrimary),
      titleLarge: AppText.title.copyWith(color: colors.textPrimary),
      titleMedium: AppText.cardTitle.copyWith(color: colors.textPrimary),
      bodyLarge: AppText.body.copyWith(color: colors.textSecondary),
      bodyMedium: AppText.body.copyWith(color: colors.textSecondary),
      bodySmall: AppText.caption.copyWith(color: colors.textMuted),
      labelLarge: AppText.button.copyWith(color: isDark ? AppColors.background : AppColorsLight.background),
      labelMedium: AppText.label.copyWith(color: colors.textMuted),
      headlineMedium: AppText.number.copyWith(color: colors.textPrimary),
      headlineSmall: AppText.numberSmall.copyWith(color: colors.textPrimary),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: colors.background,
      foregroundColor: colors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,  // 左对齐，反默认
    ),
    cardTheme: CardTheme(
      color: colors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppShapes.borderRadius,
        side: BorderSide(color: colors.border, width: 1),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: colors.surfaceElevated,
      contentTextStyle: TextStyle(color: colors.textPrimary),
      shape: RoundedRectangleBorder(borderRadius: AppShapes.borderRadius),
      behavior: SnackBarBehavior.floating,
    ),
    iconTheme: IconThemeData(color: colors.textMuted),
    dividerColor: colors.border,
  );
}
