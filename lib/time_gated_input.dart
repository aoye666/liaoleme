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
        color: AppColors.surface,
        borderRadius: AppShapes.borderRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题行
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '今日次数',
                style: AppText.cardTitle,
              ),
              if (canInput)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentSubtle,
                    borderRadius: AppShapes.borderRadiusSm,
                  ),
                  child: Text(
                    '可编辑',
                    style: AppText.caption.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          if (canInput)
            _buildInputArea()
          else
            _buildLockedArea(),
        ],
      ),
    );
  }

  // 可输入区域
  Widget _buildInputArea() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 减少按钮
        _buildCountButton(
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
            color: AppColors.surfaceElevated,
            borderRadius: AppShapes.borderRadiusSm,
            border: Border.all(color: AppColors.border),
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
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Material(
      color: onPressed != null
          ? AppColors.accent
          : AppColors.surfaceElevated,
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
                ? AppColors.background
                : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  // 锁定区域
  Widget _buildLockedArea() {
    String lockText;
    String lockSubtext;
    IconData lockIcon;

    if (!isCheckedIn) {
      lockText = '请先完成打卡';
      lockSubtext = '打卡后即可记录次数';
      lockIcon = Icons.lock_outline_rounded;
    } else {
      lockText = '晚8点后开放';
      lockSubtext = '当前时间未到 20:00';
      lockIcon = Icons.schedule_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated.withOpacity(0.5),
        borderRadius: AppShapes.borderRadiusSm,
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          Icon(
            lockIcon,
            size: 28,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            lockText,
            style: AppText.bodyStrong.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            lockSubtext,
            style: AppText.caption,
          ),
        ],
      ),
    );
  }
}
