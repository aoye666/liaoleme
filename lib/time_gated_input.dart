import 'package:flutter/material.dart';

// 时间门控次数输入组件
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
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '今日次数',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
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
        _buildCountButton(
          icon: Icons.remove,
          onPressed: currentCount > 0
              ? () => onCountChanged(currentCount - 1)
              : null,
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black26),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$currentCount',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        _buildCountButton(
          icon: Icons.add,
          onPressed: () => onCountChanged(currentCount + 1),
        ),
      ],
    );
  }

  // 锁定区域
  Widget _buildLockedArea() {
    String lockText;
    if (!isCheckedIn) {
      lockText = '请先完成打卡';
    } else {
      lockText = '晚8点后开放输入';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.lock_outline,
            size: 40,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            lockText,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
          if (isCheckedIn) ...[
            const SizedBox(height: 4),
            Text(
              '当前次数：$currentCount',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 次数加减按钮
  Widget _buildCountButton({
    required IconData icon,
    VoidCallback? onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: onPressed != null ? Colors.black : Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }
}
