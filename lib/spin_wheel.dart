import 'dart:math';
import 'package:flutter/material.dart';
import 'theme.dart';

// 转盘组件 - 带可见文字标签
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

    final double finalRotation = 5 + _random.nextDouble() * 3;

    _animation = Tween<double>(begin: 0, end: finalRotation).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.reset();
    _controller.forward().then((_) {
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
        // 顶部指针
        TrianglePointer(isDisabled: widget.isDisabled),

        const SizedBox(height: 8),

        // 转盘主体 - 带文字标签
        GestureDetector(
          onTap: _spin,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _animation.value * 2 * pi,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.isDisabled
                          ? AppColors.border
                          : AppColors.accent,
                      width: 2,
                    ),
                    boxShadow: widget.isDisabled
                        ? []
                        : [
                            BoxShadow(
                              color: AppColors.accent.withOpacity(0.15),
                              blurRadius: 24,
                              spreadRadius: 2,
                            ),
                          ],
                  ),
                  child: ClipOval(
                    child: CustomPaint(
                      size: const Size(220, 220),
                      painter: _WheelPainter(isDisabled: widget.isDisabled),
                      child: _WheelLabels(isDisabled: widget.isDisabled),
                    ),
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

// 转盘扇形绘制
class _WheelPainter extends CustomPainter {
  final bool isDisabled;

  _WheelPainter({required this.isDisabled});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 左半 = 不撸 (深色)
    final paintLeft = Paint()
      ..color = isDisabled ? AppColors.surfaceElevated : AppColors.surface
      ..style = PaintingStyle.fill;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      pi,
      true,
      paintLeft,
    );

    // 右半 = 撸 (带色)
    final paintRight = Paint()
      ..color = isDisabled
          ? AppColors.border
          : AppColors.accentSubtle.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi / 2,
      pi,
      true,
      paintRight,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 转盘文字标签
class _WheelLabels extends StatelessWidget {
  final bool isDisabled;

  const _WheelLabels({required this.isDisabled});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 不撸 - 左半部分
        Positioned(
          left: 30,
          top: 0,
          bottom: 0,
          child: Center(
            child: Text(
              '不撸',
              style: AppText.cardTitle.copyWith(
                fontSize: 22,
                color: isDisabled
                    ? AppColors.textMuted
                    : AppColors.accent,
              ),
            ),
          ),
        ),
        // 撸 - 右半部分
        Positioned(
          right: 30,
          top: 0,
          bottom: 0,
          child: Center(
            child: Text(
              '撸',
              style: AppText.cardTitle.copyWith(
                fontSize: 22,
                color: isDisabled
                    ? AppColors.border
                    : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// 三角形指针
class TrianglePointer extends StatelessWidget {
  final bool isDisabled;

  const TrianglePointer({super.key, required this.isDisabled});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(24, 14),
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

    // 描边
    final strokePaint = Paint()
      ..color = AppColors.background
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
