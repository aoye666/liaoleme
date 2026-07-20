import 'dart:convert';
import 'package:http/http.dart' as http;
import 'database_helper.dart';

/// 排行榜服务 - 预留接口，等待后端搭建
class LeaderboardService {
  static final LeaderboardService _instance = LeaderboardService._internal();
  factory LeaderboardService() => _instance;
  LeaderboardService._internal();

  // TODO: 替换为你的后端地址
  static const String _baseUrl = 'https://your-server.com/api';

  /// 健康检查 - 判断后端是否可用
  Future<bool> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/health'),
      ).timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// 获取排行榜数据
  Future<LeaderboardData?> fetchLeaderboard({int limit = 50}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/leaderboard?limit=$limit'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['code'] == 200) {
          return LeaderboardData.fromJson(json['data']);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// 计算本地用户统计数据（用于展示）
  Future<UserStats> calculateLocalStats() async {
    final db = DatabaseHelper();
    final records = await db.getAllCheckins();

    // 起飞次数 = 所有 count 总和
    int takeoffCount = 0;
    for (final r in records) {
      takeoffCount += (r['count'] as int? ?? 0);
    }

    // 计算使用天数和周数
    final totalDays = records.length;
    double takeoffRate = 0;
    if (totalDays > 0) {
      // 计算首次打卡到今天的天数
      final firstDate = DateTime.parse(records.first['date'] as String);
      final now = DateTime.now();
      final daysSinceFirst = now.difference(firstDate).inDays + 1;
      final weeks = (daysSinceFirst / 7).ceil();
      takeoffRate = weeks > 0 ? takeoffCount / weeks : 0;
    }

    // 最长连续打卡天数
    int maxStreak = 0;
    int currentStreak = 0;
    String? lastDate;

    for (final r in records) {
      final dateStr = r['date'] as String;
      if (lastDate == null) {
        currentStreak = 1;
      } else {
        final last = DateTime.parse(lastDate);
        final current = DateTime.parse(dateStr);
        final diff = current.difference(last).inDays;
        if (diff == 1) {
          currentStreak++;
        } else {
          currentStreak = 1;
        }
      }
      maxStreak = maxStreak > currentStreak ? maxStreak : currentStreak;
      lastDate = dateStr;
    }

    return UserStats(
      takeoffCount: takeoffCount,
      takeoffRate: double.parse(takeoffRate.toStringAsFixed(1)),
      maxStreak: maxStreak,
    );
  }
}

/// 用户统计数据
class UserStats {
  final int takeoffCount;   // 起飞次数
  final double takeoffRate; // 起飞频率（每周）
  final int maxStreak;      // 最长连续起飞数

  UserStats({
    required this.takeoffCount,
    required this.takeoffRate,
    required this.maxStreak,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      takeoffCount: json['takeoffCount'],
      takeoffRate: (json['takeoffRate'] as num).toDouble(),
      maxStreak: json['maxStreak'],
    );
  }
}

/// 排行榜条目
class LeaderboardEntry {
  final int rank;
  final String username;
  final int takeoffCount;
  final double takeoffRate;
  final int maxStreak;

  LeaderboardEntry({
    required this.rank,
    required this.username,
    required this.takeoffCount,
    required this.takeoffRate,
    required this.maxStreak,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'],
      username: json['username'],
      takeoffCount: json['takeoffCount'],
      takeoffRate: (json['takeoffRate'] as num).toDouble(),
      maxStreak: json['maxStreak'],
    );
  }
}

/// 排行榜完整数据
class LeaderboardData {
  final int myRank;
  final UserStats myStats;
  final List<LeaderboardEntry> leaderboard;

  LeaderboardData({
    required this.myRank,
    required this.myStats,
    required this.leaderboard,
  });

  factory LeaderboardData.fromJson(Map<String, dynamic> json) {
    return LeaderboardData(
      myRank: json['myRank'],
      myStats: UserStats.fromJson(json['myStats']),
      leaderboard: (json['leaderboard'] as List)
          .map((e) => LeaderboardEntry.fromJson(e))
          .toList(),
    );
  }
}