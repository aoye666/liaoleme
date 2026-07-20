import 'package:flutter/material.dart';
import 'theme.dart';
import 'leaderboard_service.dart';
import 'user_service.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  final LeaderboardService _service = LeaderboardService();
  LeaderboardData? _data;
  UserStats? _localStats;
  bool _isLoading = true;
  String? _error;
  String? _nickname;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await _service.fetchLeaderboard();
      final localStats = await _service.calculateLocalStats();
      final nickname = await UserService.getNickname();

      if (mounted) {
        setState(() {
          _data = data;
          _localStats = localStats;
          _nickname = nickname;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '加载失败，请稍后重试';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        backgroundColor: context.appColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('排行榜', style: AppText.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: context.appColors.textSecondary,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: context.appColors.accent,
                strokeWidth: 2,
              ),
            )
          : _error != null
              ? Center(
                  child: Text(_error!, style: AppText.body.copyWith(color: context.appColors.negative)),
                )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 我的排名卡片
          if (_data != null) ...[
            _buildMyRankCard(),
            const SizedBox(height: AppSpacing.xl),
          ] else if (_localStats != null) ...[
            _buildLocalStatsCard(),
            const SizedBox(height: AppSpacing.xl),
          ],

          // 排行榜标题
          if (_data != null) ...[
            Text(
              '排行榜',
              style: AppText.label.copyWith(
                color: context.appColors.textMuted,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _buildLeaderboardList(),
          ] else ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Text(
                  '排行榜服务暂不可用',
                  style: AppText.body.copyWith(color: context.appColors.textMuted),
                ),
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  // 我的排名卡片（有后端数据时）
  Widget _buildMyRankCard() {
    final stats = _data!.myStats;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.appColors.accentSubtle,
        borderRadius: AppShapes.borderRadius,
        border: Border.all(color: context.appColors.accent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _nickname ?? '我的排名',
                style: AppText.label.copyWith(color: context.appColors.textMuted),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: context.appColors.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '#${_data!.myRank}',
                  style: AppText.caption.copyWith(
                    color: context.appColors.background,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _buildStatItem('起飞次数', '${stats.takeoffCount}', '次'),
              _buildStatDivider(),
              _buildStatItem('起飞频率', '${stats.takeoffRate}', '次/周'),
              _buildStatDivider(),
              _buildStatItem('最长连续', '${stats.maxStreak}', '天'),
            ],
          ),
        ],
      ),
    );
  }

  // 本地统计卡片（无后端数据时）
  Widget _buildLocalStatsCard() {
    final stats = _localStats!;
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
          Text(
            '我的数据',
            style: AppText.label.copyWith(color: context.appColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              _buildStatItem('起飞次数', '${stats.takeoffCount}', '次'),
              _buildStatDivider(),
              _buildStatItem('起飞频率', '${stats.takeoffRate}', '次/周'),
              _buildStatDivider(),
              _buildStatItem('最长连续', '${stats.maxStreak}', '天'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String unit) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppText.numberSmall.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 2),
          Text(
            '$label($unit)',
            style: AppText.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 32,
      color: context.appColors.border,
    );
  }

  // 排行榜列表
  Widget _buildLeaderboardList() {
    final entries = _data!.leaderboard;
    return Container(
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppShapes.borderRadius,
        border: Border.all(color: context.appColors.border),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: entries.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: context.appColors.borderSubtle,
        ),
        itemBuilder: (context, index) {
          final entry = entries[index];
          return _buildLeaderboardItem(entry);
        },
      ),
    );
  }

  Widget _buildLeaderboardItem(LeaderboardEntry entry) {
    final isTop3 = entry.rank <= 3;
    final medal = entry.rank == 1 ? '🥇' : entry.rank == 2 ? '🥈' : entry.rank == 3 ? '🥉' : '';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          // 排名
          SizedBox(
            width: 40,
            child: isTop3
                ? Text(medal, style: const TextStyle(fontSize: 18))
                : Text(
                    '#${entry.rank}',
                    style: AppText.caption.copyWith(color: context.appColors.textMuted),
                  ),
          ),

          // 用户名
          Expanded(
            child: Text(
              entry.username,
              style: AppText.cardTitle,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // 起飞次数
          SizedBox(
            width: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${entry.takeoffCount}',
                  style: AppText.numberSmall.copyWith(fontSize: 14),
                ),
                Text(
                  '次数',
                  style: AppText.caption.copyWith(fontSize: 10),
                ),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // 起飞频率
          SizedBox(
            width: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${entry.takeoffRate}',
                  style: AppText.numberSmall.copyWith(fontSize: 14),
                ),
                Text(
                  '次/周',
                  style: AppText.caption.copyWith(fontSize: 10),
                ),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // 最长连续
          SizedBox(
            width: 50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${entry.maxStreak}',
                  style: AppText.numberSmall.copyWith(fontSize: 14),
                ),
                Text(
                  '连续',
                  style: AppText.caption.copyWith(fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}