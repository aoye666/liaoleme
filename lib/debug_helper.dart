import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';

/// 调试日志系统
/// 应用启动全流程日志记录，崩溃后读日志定位问题
class DebugHelper {
  static final DebugHelper _instance = DebugHelper._internal();
  factory DebugHelper() => _instance;
  DebugHelper._internal();

  static bool _enabled = false;
  static File? _logFile;
  static final _logs = <LogEntry>[];
  static final _streamController = StreamController<LogEntry>.broadcast();

  /// 获取日志流（用于实时监听）
  static Stream<LogEntry> get stream => _streamController.stream;

  /// 日志级别
  static const String LVL_DEBUG = 'DEBUG';
  static const String LVL_INFO  = 'INFO';
  static const String LVL_WARN  = 'WARN';
  static const String LVL_ERROR = 'ERROR';

  /// 启动跟踪 — 记录启动每一步
  static final List<String> startupSteps = [];

  /// 启用调试系统
  static Future<void> enable() async {
    if (_enabled) return;
    _enabled = true;

    try {
      final dir = await getApplicationDocumentsDirectory();
      _logFile = File('${dir.path}/liaoleme_debug.log');

      // 保留最近3次启动日志，追加模式
      await _logFile!.parent.create(recursive: true);

      // 追加分割线标记新会话
      final separator = '\n${'=' * 60}\n'
          '🚀 新会话启动: ${DateTime.now()}\n'
          '${'=' * 60}\n';
      await _logFile!.writeAsString(separator, mode: FileMode.append);
    } catch (e) {
      // 日志系统本身不能崩，用 print 兜底
      print('[DebugHelper] 日志文件初始化失败: $e');
    }
  }

  /// 记录启动步骤（同步，不会 throw）
  static void track(String step) {
    final entry = '[启动] $step';
    startupSteps.add(entry);
    _log(entry, LVL_DEBUG);
  }

  /// 记录日志
  static void log(String message, {String level = LVL_DEBUG}) {
    _log(message, level);
  }

  static void info(String message) => _log(message, LVL_INFO);
  static void warn(String message) => _log(message, LVL_WARN);
  static void error(String message) => _log(message, LVL_ERROR);

  static void _log(String message, String level) {
    if (!_enabled) return;

    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      message: message,
    );

    _logs.add(entry);

    // 同时输出到 console
    print('[${entry.timeStr}] [$level] $message');
    if (level == 'ERROR') {
      print('[ERROR] $message');
    }

    // 写文件（异步非阻塞）
    _writeToFile(entry);

    // 广播给监听者
    _streamController.add(entry);
  }

  static void _writeToFile(LogEntry entry) {
    if (_logFile == null) return;
    try {
      _logFile!.writeAsString(
        '[${entry.timeStr}] [${entry.level}] ${entry.message}\n',
        mode: FileMode.append,
      ).catchError((_) {});
    } catch (_) {}
  }

  /// 获取完整日志文本
  static Future<String> getLogText() async {
    if (_logFile == null) return '（日志系统未启用）';
    try {
      if (await _logFile!.exists()) {
        return await _logFile!.readAsString();
      }
    } catch (_) {}
    return '（日志文件不可读）';
  }

  /// 获取最近 N 条内存日志
  static List<LogEntry> getRecentLogs([int count = 50]) {
    if (_logs.length <= count) return List.from(_logs);
    return _logs.sublist(_logs.length - count);
  }

  /// 获取日志文件大小
  static Future<String> getLogFileSize() async {
    if (_logFile == null) return '-';
    try {
      if (await _logFile!.exists()) {
        final size = await _logFile!.length();
        if (size < 1024) return '${size}B';
        if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)}KB';
        return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
      }
    } catch (_) {}
    return '-';
  }

  /// 清空日志
  static Future<void> clearLogs() async {
    _logs.clear();
    if (_logFile != null) {
      try {
        await _logFile!.writeAsString('');
      } catch (_) {}
    }
  }

  /// 获取日志文件路径
  static Future<String> getLogPath() async {
    if (_logFile != null) return _logFile!.path;
    try {
      final dir = await getApplicationDocumentsDirectory();
      return '${dir.path}/liaoleme_debug.log';
    } catch (_) {
      return '-';
    }
  }
}

/// 单条日志条目
class LogEntry {
  final DateTime timestamp;
  final String level;
  final String message;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
  });

  String get timeStr {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}.'
        '${timestamp.millisecond.toString().padLeft(3, '0')}';
  }
}
