import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'theme.dart';
import 'debug_helper.dart';
import 'database_helper.dart';

// 调试信息页 - taste-skill 设计重构
class DebugPage extends StatefulWidget {
  const DebugPage({super.key});

  @override
  State<DebugPage> createState() => _DebugPageState();
}

class _DebugPageState extends State<DebugPage> {
  final DatabaseHelper _db = DatabaseHelper();

  // 日志
  List<LogEntry> _logs = [];
  bool _autoScroll = true;

  // 数据库信息
  String _dbInfo = '加载中...';

  // 日志文件
  String _logFilePath = '';
  String _logFileSize = '';

  StreamSubscription<LogEntry>? _subscription;

  @override
  void initState() {
    super.initState();
    _refresh();

    // 实时监听新日志
    _subscription = DebugHelper.stream.listen((entry) {
      if (mounted) {
        setState(() {
          _logs.add(entry);
          if (_logs.length > 200) {
            _logs = _logs.sublist(_logs.length - 200);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    // 加载日志
    _logs = DebugHelper.getRecentLogs(200);

    // 加载数据库信息
    await _loadDbInfo();

    // 日志文件信息
    _logFilePath = await DebugHelper.getLogPath();
    _logFileSize = await DebugHelper.getLogFileSize();

    if (mounted) setState(() {});
  }

  Future<void> _loadDbInfo() async {
    try {
      final allRecords = await _db.getAllCheckins();
      final startSteps = DebugHelper.startupSteps;

      _dbInfo = '✅ 数据库正常\n'
          '总记录数: ${allRecords.length}\n'
          '启动步骤: ${startSteps.length}步';

      if (allRecords.isNotEmpty) {
        final first = allRecords.first;
        final last = allRecords.last;
        _dbInfo += '\n最早记录: ${first['date']}';
        _dbInfo += '\n最新记录: ${last['date']}';

        // 统计不撸/撸
        final noCount = allRecords.where((r) => r['result'] == '不撸').length;
        final yesCount = allRecords.where((r) => r['result'] == '撸').length;
        _dbInfo += '\n不撸: $noCount / 撸: $yesCount';
      }
    } catch (e) {
      _dbInfo = '❌ 数据库异常: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.negativeSubtle,
                borderRadius: AppShapes.borderRadiusSm,
              ),
              child: const Center(
                child: Icon(
                  Icons.bug_report,
                  size: 14,
                  color: AppColors.negative,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Text('调试面板', style: AppText.title),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: AppColors.textSecondary,
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 20),
            color: AppColors.textSecondary,
            onPressed: _refresh,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // 数据库状态卡片
          _buildSectionCard(
            title: '数据库状态',
            icon: Icons.storage_rounded,
            child: Text(
              _dbInfo,
              style: AppText.body.copyWith(
                fontFamily: 'monospace',
                fontSize: 13,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // 日志文件信息
          _buildSectionCard(
            title: '日志文件',
            icon: Icons.description_rounded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _logFilePath,
                  style: AppText.caption.copyWith(fontFamily: 'monospace'),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '大小: $_logFileSize',
                  style: AppText.caption,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // 实时日志
          _buildSectionCard(
            title: '实时日志 (${_logs.length})',
            icon: Icons.article_rounded,
            action: TextButton(
              onPressed: () {
                // 复制日志到剪贴板
                final logText = _logs
                    .map((l) => '[${l.timeStr}] [${l.level}] ${l.message}')
                    .join('\n');
                Clipboard.setData(ClipboardData(text: logText));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('日志已复制到剪贴板'),
                    backgroundColor: AppColors.accent,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppShapes.borderRadius,
                    ),
                  ),
                );
              },
              child: Text(
                '复制',
                style: AppText.caption.copyWith(color: AppColors.accent),
              ),
            ),
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: AppShapes.borderRadiusSm,
                border: Border.all(color: AppColors.border),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.sm),
                itemCount: _logs.length,
                itemBuilder: (context, index) {
                  final log = _logs[index];
                  return _buildLogItem(log);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
    Widget? action,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppShapes.borderRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.textMuted),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: AppText.label.copyWith(
                  color: AppColors.textMuted,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              if (action != null) action,
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }

  Widget _buildLogItem(LogEntry log) {
    Color levelColor;
    switch (log.level) {
      case 'ERROR':
        levelColor = AppColors.negative;
        break;
      case 'WARN':
        levelColor = Colors.orange;
        break;
      case 'INFO':
        levelColor = AppColors.accent;
        break;
      default:
        levelColor = AppColors.textMuted;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 时间戳
          Text(
            log.timeStr,
            style: AppText.caption.copyWith(
              fontFamily: 'monospace',
              fontSize: 10,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // 级别标签
          Container(
            width: 36,
            alignment: Alignment.centerRight,
            child: Text(
              log.level,
              style: AppText.caption.copyWith(
                fontFamily: 'monospace',
                fontSize: 10,
                color: levelColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // 消息内容
          Expanded(
            child: Text(
              log.message,
              style: AppText.caption.copyWith(
                fontFamily: 'monospace',
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
