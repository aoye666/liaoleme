import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

// 一言服务
class QuoteService {
  static final QuoteService _instance = QuoteService._internal();
  factory QuoteService() => _instance;
  QuoteService._internal();

  final Random _random = Random();

  // 本地兜底词库
  static const List<Map<String, String>> _fallbackQuotes = [
    {'text': '自律即自由', 'from': '本地'},
    {'text': '今天的克制是明天的力量', 'from': '本地'},
    {'text': '忍住不撸，你赢了', 'from': '本地'},
    {'text': '坚持就是胜利', 'from': '本地'},
    {'text': '一天不撸，十天不慌', 'from': '本地'},
    {'text': '自律给你真正的自由', 'from': '本地'},
    {'text': '控制欲望，掌控人生', 'from': '本地'},
    {'text': '不撸的一天是充实的一天', 'from': '本地'},
    {'text': '今天的决定决定明天的你', 'from': '本地'},
    {'text': '每天进步一点点', 'from': '本地'},
  ];

  // 从 API 获取一言，失败则使用本地兜底
  Future<Map<String, String>> fetchQuote() async {
    try {
      // Hitokoto 一言 API（免费，无需 Key）
      final response = await http.get(
        Uri.parse('https://v1.hitokoto.cn/?c=k&c=d&c=i&encode=json'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'text': data['hitokoto'] as String,
          'from': (data['from'] ?? '未知').toString(),
        };
      }
    } catch (e) {
      // 网络失败，使用本地兜底
    }

    // 兜底：随机返回本地一言
    final quote = _fallbackQuotes[_random.nextInt(_fallbackQuotes.length)];
    return quote;
  }
}
