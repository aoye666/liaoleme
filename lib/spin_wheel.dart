import 'dart:math';
import 'package:flutter/material.dart';

// 转盘组件
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
      duration: const Duration(seconds: 3),
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

    // 锁定全局状态
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
      // 初始状态：上半部分=不撸(黑)，下半部分=撸(白)
      // 顺时针旋转后，顶部指针指向的扇形判定结果
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
        TrianglePointer(
          isDisabled: widget.isDisabled,
        ),

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
                      color: widget.isDisabled ? Colors.grey[300]! : Colors.black,
                      width: 3,
                    ),
                    boxShadow: widget.isDisabled
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                  ),
                  child: ClipOval(
                    child: CustomPaint(
                      painter: _WheelPainter(isDisabled: widget.isDisabled),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // 提示文字
        _buildHintText(),
      ],
    );
  }

  Widget _buildHintText() {
    String text;
    Color color;
    if (widget.isDisabled) {
      text = '今日已打卡';
      color = Colors.grey[400]!;
    } else if (_isSpinning) {
      text = '转盘旋转中...';
      color = Colors.grey[600]!;
    } else {
      text = '点击开始';
      color = Colors.grey[600]!;
    }
    return Text(
      text,
      style: TextStyle(color: color, fontSize: 14),
    );
  }
}

// 顶部三角形指针
class TrianglePointer extends StatelessWidget {
  final bool isDisabled;

  const TrianglePointer({super.key, required this.isDisabled});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      height: 12,
      child: CustomPaint(
        painter: _TrianglePainter(isDisabled: isDisabled),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final bool isDisabled;

  _TrianglePainter({required this.isDisabled});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDisabled ? Colors.grey[400]! : Colors.black
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// 转盘绘制
class _WheelPainter extends CustomPainter {
  final bool isDisabled;

  _WheelPainter({required this.isDisabled});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 绘制两半扇形
    final paintBlack = Paint()
      ..color = isDisabled ? Colors.grey[300]! : Colors.black
      ..style = PaintingStyle.fill;

    final paintWhite = Paint()
      ..color = isDisabled ? Colors.grey[50]! : Colors.white
      ..style = PaintingStyle.fill;

    // 上半 - 黑（不撸）
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      pi,
      true,
      paintBlack,
    );

    // 下半 - 白（撸）
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi / 2,
      pi,
      true,
      paintWhite,
    );

    // 中间分割线
    final linePaint = Paint()
      ..color = isDisabled ? Colors.grey[200]! : Colors.black26
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      linePaint,
    );

    // 绘制文字
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // "不撸" (黑区白字)
    textPainter.text = TextSpan(
      text: '不撸',
      style: TextStyle(
        color: isDisabled ? Colors.grey[500]! : Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - radius / 3 - textPainter.height / 2,
      ),
    );

    // "撸"（白区黑字）
    textPainter.text = TextSpan(
      text: '撸',
      style: TextStyle(
        color: isDisabled ? Colors.grey[500]! : Colors.black,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy + radius / 4 - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
