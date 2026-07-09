import 'package:flutter/material.dart';
import 'dart:async';
import 'debug_helper.dart';
import 'database_helper.dart';

/// 调试信息页
/// 展示启动日志、数据库状态、设备信息
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
  String _notifInfo = '加载中...';
  String _deviceInfo = '';
  
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
    
    // 加载设备信息
    _loadDeviceInfo();
    
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
        
        // 统计
        final noCount = allRecords.where((r) => r['result'] == '不撸').length;
        final yesCount = allRecords.where((r) => r['result'] == '撸').length;
        _dbInfo += '\n不撸: $noCount / 撸: $yesCount';
      }
    } catch (e) {
      _dbInfo = '❌ 数据库异常: $e';
    }
  }

  void _loadDeviceInfo() {
    final buffer = StringBuffer();
    buffer.writeln('Android: ${const bool.hasEnvironment('android')}');
    _deviceInfo = buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E), // 深色背景
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213E),
        title: const Text(
          '🐛 调试面板',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              _autoScroll ? Icons.vertical_align_bottom : Icons.vertical_align_center,
              color: Colors.white70,
            ),
            onPressed: () => setState(() => _autoScroll = !_autoScroll),
            tooltip: '自动滚动',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: _refresh,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // 状态概览卡片
          _buildCard(
            '📊 数据库状态',
            _dbInfo,
            iconColor: _dbInfo.startsWith('✅') ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 8),
          
          // 日志信息
          _buildCard(
            '📁 日志文件',
            '路径: $_logFilePath\n大小: $_logFileSize',
            iconColor: Colors.cyan,
          ),
          const SizedBox(height: 8),

          // 启动步骤
          _buildStartupSteps(),
          const SizedBox(height: 8),

          // 日志列表
          _buildLogList(),
          const SizedBox(height: 8),

          // 底部操作按钮
          _buildActions(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCard(String title, String content, {Color iconColor = Colors.white}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              color: iconColor.withOpacity(0.9),
              fontSize: 13,
              fontFamily: 'monospace',
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartupSteps() {
    final steps = DebugHelper.startupSteps;
    if (steps.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🚀 启动步骤',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...List.generate(steps.length, (i) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${i + 1}.',
                    style: TextStyle(
                      color: Colors.green[300],
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      steps[i],
                      style: TextStyle(
                        color: Colors.green[200],
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLogList() {
    if (_logs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '📝 实时日志',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${_logs.length}条',
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...List.generate(
            _logs.length > 100 ? 100 : _logs.length,
            (i) {
              final log = _logs[_logs.length - (_logs.length > 100 ? 100 : _logs.length) + i];
              Color levelColor;
              switch (log.level) {
                case 'ERROR':
                  levelColor = Colors.red[300]!;
                  break;
                case 'WARN':
                  levelColor = Colors.orange[300]!;
                  break;
                case 'INFO':
                  levelColor = Colors.cyan[300]!;
                  break;
                default:
                  levelColor = Colors.grey[400]!;
              }
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 1),
                child: Text(
                  '[${log.timeStr}] [${log.level}] ${log.message}',
                  style: TextStyle(
                    color: levelColor,
                    fontSize: 11,
                    fontFamily: 'monospace',
                    height: 1.4,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              await DebugHelper.clearLogs();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('日志已清空')),
                );
                _refresh();
              }
            },
            icon: const Icon(Icons.delete_outline, size: 16),
            label: const Text('清空日志'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red[300],
              side: BorderSide(color: Colors.red[300]!),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              final text = await DebugHelper.getLogText();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('已复制到剪贴板（${text.length}字符）')),
                );
                // 用 SnackBar action 来提供复制
              }
            },
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('查看完整日志'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.cyan[300],
              side: BorderSide(color: Colors.cyan[300]!),
            ),
          ),
        ),
      ],
    );
  }
}
