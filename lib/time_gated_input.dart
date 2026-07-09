import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';

// 时间门控次数输入组件 - taste-skill 设计重构
class TimeGatedInput extends StatelessWidget {
  final bool isCheckedIn;
  final bool isAfter8PM;
  final int currentCount;
  final Function(int) onCountChanged;

  const TimeGatedInput({
    super.key,
    required this.isCheckedIn,
    required this.isAfter8PM,
    required this.currentCount,
    required this.onCountChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool canInput = isCheckedIn && isAfter8PM;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppShapes.borderRadius,
        border: Border.all(color: context.appColors.border),
      ),
      child: Column(
        children: [
          // 标题
          Row(
            children: [
              Icon(
                Icons.numbers,
                color: context.appColors.accent,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '今日次数',
                style: AppText.cardTitle.copyWith(
                  color: context.appColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            canInput ? '20:00后可记录' : '打卡后开放',
            style: AppText.caption.copyWith(
              color: context.appColors.textMuted,
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          if (canInput)
            _buildInputArea(context)
          else
            _buildLockedArea(context),
        ],
      ),
    );
  }

  // 可输入区域
  Widget _buildInputArea(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 减少按钮
        _buildCountButton(
          context: context,
          icon: Icons.remove,
          onPressed: currentCount > 0
              ? () {
                  HapticFeedback.lightImpact();
                  onCountChanged(currentCount - 1);
                }
              : null,
        ),

        // 数字显示
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: context.appColors.surfaceElevated,
            borderRadius: AppShapes.borderRadiusSm,
            border: Border.all(color: context.appColors.border),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Text(
              '$currentCount',
              key: ValueKey(currentCount),
              style: AppText.number,
            ),
          ),
        ),

        // 增加按钮
        _buildCountButton(
          context: context,
          icon: Icons.add,
          onPressed: () {
            HapticFeedback.lightImpact();
            onCountChanged(currentCount + 1);
          },
        ),
      ],
    );
  }

  Widget _buildCountButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Material(
      color: onPressed != null
          ? context.appColors.accent
          : context.appColors.surfaceElevated,
      borderRadius: AppShapes.borderRadiusSm,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppShapes.borderRadiusSm,
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 20,
            color: onPressed != null
                ? context.appColors.background
                : context.appColors.textMuted,
          ),
        ),
      ),
    );
  }

  // 锁定区域
  Widget _buildLockedArea(BuildContext context) {
    String lockText;
    String lockSubtext;
    IconData lockIcon;

    if (!isCheckedIn) {
      lockText = '先打卡才能输入次数';
      lockSubtext = '点击上方按钮完成打卡';
      lockIcon = Icons.lock_outline;
    } else {
      lockText = '晚上8点后开放';
      lockSubtext = '20:00 - 23:59 可记录';
      lockIcon = Icons.schedule;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.appColors.surfaceElevated.withOpacity(0.5),
        borderRadius: AppShapes.borderRadiusSm,
        border: Border.all(color: context.appColors.borderSubtle),
      ),
      child: Column(
        children: [
          Icon(
            lockIcon,
            color: context.appColors.textMuted,
            size: 28,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            lockText,
            style: AppText.body.copyWith(
              color: context.appColors.textMuted,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            lockSubtext,
            style: AppText.caption.copyWith(
              color: context.appColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
