import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme.dart';
import 'quote_service.dart';

// 随机一言组件 - taste-skill 设计重构
// 更克制的卡片设计，左对齐排版
class QuoteSection extends StatefulWidget {
  const QuoteSection({super.key});

  @override
  State<QuoteSection> createState() => _QuoteSectionState();
}

class _QuoteSectionState extends State<QuoteSection>
    with SingleTickerProviderStateMixin {
  String _quote = '';
  String _from = '';
  bool _isLoading = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final QuoteService _quoteService = QuoteService();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _loadQuote();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadQuote() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _formatDate(DateTime.now());
    final savedDate = prefs.getString('quote_date');
    final savedQuote = prefs.getString('quote_content');
    final savedFrom = prefs.getString('quote_from');

    if (savedDate == today && savedQuote != null) {
      // 今日已缓存
      setState(() {
        _quote = savedQuote;
        _from = savedFrom ?? '';
        _isLoading = false;
      });
      _animController.forward();
    } else {
      // 新的一天，获取新的一言
      final result = await _quoteService.fetchQuote();
      await prefs.setString('quote_date', today);
      await prefs.setString('quote_content', result['text']!);
      await prefs.setString('quote_from', result['from']!);
      setState(() {
        _quote = result['text']!;
        _from = result['from']!;
        _isLoading = false;
      });
      _animController.forward();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildSkeleton();
    }

    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: context.appColors.surface,
          borderRadius: AppShapes.borderRadius,
          border: Border.all(color: context.appColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图标 + 标签行
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: context.appColors.accentSubtle,
                    borderRadius: AppShapes.borderRadiusSm,
                  ),
                  child: Center(
                    child: Text(
                      '✦',
                      style: TextStyle(
                        color: context.appColors.accent,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '每日一言',
                  style: AppText.label.copyWith(
                    color: context.appColors.accent,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // 引用文本
            Text(
              _quote,
              style: AppText.body.copyWith(
                color: context.appColors.textPrimary,
                fontSize: 16,
                height: 1.7,
                letterSpacing: 0.2,
              ),
            ),

            if (_from.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              // 来源
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 1,
                    color: context.appColors.border,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    _from,
                    style: AppText.caption.copyWith(
                      color: context.appColors.textMuted,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 骨架屏
  Widget _buildSkeleton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppShapes.borderRadius,
        border: Border.all(color: context.appColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: context.appColors.surfaceElevated,
                  borderRadius: AppShapes.borderRadiusSm,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                width: 60,
                height: 12,
                decoration: BoxDecoration(
                  color: context.appColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            height: 16,
            decoration: BoxDecoration(
              color: context.appColors.surfaceElevated,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Container(
            width: 200,
            height: 16,
            decoration: BoxDecoration(
              color: context.appColors.surfaceElevated,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
