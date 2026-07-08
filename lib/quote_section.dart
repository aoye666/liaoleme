import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'quote_service.dart';

// 随机一言组件
class QuoteSection extends StatefulWidget {
  const QuoteSection({super.key});

  @override
  State<QuoteSection> createState() => _QuoteSectionState();
}

class _QuoteSectionState extends State<QuoteSection> {
  String _quote = '加载中...';
  String _from = '';
  final QuoteService _quoteService = QuoteService();

  @override
  void initState() {
    super.initState();
    _loadQuote();
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
      });
    } else {
      // 新的一天，获取新的一言
      final result = await _quoteService.fetchQuote();
      await prefs.setString('quote_date', today);
      await prefs.setString('quote_content', result['text']!);
      await prefs.setString('quote_from', result['from']!);
      setState(() {
        _quote = result['text']!;
        _from = result['from']!;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
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
            '📜',
            style: TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 12),
          Text(
            _quote,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _from.isNotEmpty ? '— $_from' : '— 每日一话',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
