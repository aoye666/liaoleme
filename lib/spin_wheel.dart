import 'dart:math';
import 'package:flutter/material.dart';
import 'theme.dart';

// 转盘组件 - taste-skill 设计重构
// 黑白配色保留，但使用 zinc 调色板，更柔和
class SpinWheel extends StatefulWidget {
  final bool isDisabled;
  final Function(String) onSpinComplete;
  final VoidCallback onSpinStart;

  const SpinWheel({
    super.key,
    required this.isDisabled,
    required this.onSpinComplete,
    required this.onSpinStart,
  });

  @override
  State<SpinWheel> createState() => _SpinWheelState();
}

class _SpinWheelState extends State<SpinWheel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final Random _random = Random();
  bool _isSpinning = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2800),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _spin() {
    if (widget.isDisabled || _isSpinning) return;

    widget.onSpinStart();
    setState(() => _isSpinning = true);

    // 随机旋转 5-8 圈 + 随机停止位置
    final double finalRotation = 5 + _random.nextDouble() * 3;

    _animation = Tween<double>(begin: 0, end: finalRotation).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.reset();
    _controller.forward().then((_) {
      // 根据最终停止位置判定结果
      final double normalizedRotation = finalRotation % 1.0;
      final String result = normalizedRotation < 0.5 ? '不撸' : '撸';

      setState(() => _isSpinning = false);
      widget.onSpinComplete(result);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 顶部指针（指向转盘）
        TrianglePointer(isDisabled: widget.isDisabled),

        const SizedBox(height: 4),

        // 转盘主体
        GestureDetector(
          onTap: _spin,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _animation.value * 2 * pi,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.isDisabled
                          ? AppColors.border
                          : AppColors.textPrimary,
                      width: 2,
                    ),
                    boxShadow: widget.isDisabled
                        ? []
                        : [
                            BoxShadow(
                              color: AppColors.textPrimary.withOpacity(0.1),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                  ),
                  child: CustomPaint(
                    painter: _WheelPainter(isDisabled: widget.isDisabled),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // 提示文字
        Text(
          widget.isDisabled ? '今日已打卡' : '点击转盘开始',
          style: AppText.caption.copyWith(
            color: widget.isDisabled
                ? AppColors.textMuted
                : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// 转盘绘制器
class _WheelPainter extends CustomPainter {
  final bool isDisabled;

  _WheelPainter({required this.isDisabled});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 上半部分 = 不撸 (zinc-900 深)
    final paintTop = Paint()
      ..color = isDisabled ? AppColors.surfaceElevated : AppColors.wheelNo
      ..style = PaintingStyle.fill;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      pi,
      true,
      paintTop,
    );

    // 下半部分 = 撸 (zinc-50 浅)
    final paintBottom = Paint()
      ..color = isDisabled ? AppColors.border : AppColors.wheelYes
      ..style = PaintingStyle.fill;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi / 2,
      pi,
      true,
      paintBottom,
    );

    // 中心圆点
    final centerDot = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 6, centerDot);

    // 分隔线
    final linePaint = Paint()
      ..color = AppColors.accent.withOpacity(0.5)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(center.dx, center.dy - radius + 4),
      Offset(center.dx, center.dy + radius - 4),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 三角形指针
class TrianglePointer extends StatelessWidget {
  final bool isDisabled;

  const TrianglePointer({super.key, required this.isDisabled});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(20, 12),
      painter: _TrianglePainter(isDisabled: isDisabled),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final bool isDisabled;

  _TrianglePainter({required this.isDisabled});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDisabled ? AppColors.border : AppColors.accent
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
