import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';

// 调试日志系统
class DebugHelper {
  static final DebugHelper _instance = DebugHelper._internal();
  factory DebugHelper() => _instance;
  DebugHelper._internal();

  static bool _enabled = false;
  static File? _logFile;
  static final _logs = <LogEntry>[];
  static final _streamController = StreamController<LogEntry>.broadcast();

  // 日志级别常量
  static const String LVL_DEBUG = 'DEBUG';
  static const String LVL_INFO = 'INFO';
  static const String LVL_WARN = 'WARN';
  static const String LVL_ERROR = 'ERROR';

  // 启动跟踪列表
  static final List<String> startupSteps = [];

  // 获取日志流
  static Stream<LogEntry> get stream => _streamController.stream;

  // 启用调试系统 - 在 main() 最开始调用
  static Future<void> enable() async {
    if (_enabled) return;
    _enabled = true;

    try {
      final dir = await getApplicationDocumentsDirectory();
      _logFile = File('${dir.path}/liaoleme_debug.log');
      await _logFile!.parent.create(recursive: true);

      final separator = '\n${'=' * 60}\n'
          '🚀 App 启动: ${DateTime.now()}\n'
          '${'=' * 60}\n';
      await _logFile!.writeAsString(separator, mode: FileMode.append);
    } catch (e) {
      print('[DebugHelper] 初始化失败: $e');
    }
  }

  // 记录启动步骤
  static void track(String step) {
    final entry = '[启动] $step';
    startupSteps.add(entry);
    _log(entry, LVL_DEBUG);
  }

  // 快捷方法
  static void info(String message) => _log(message, LVL_INFO);
  static void warn(String message) => _log(message, LVL_WARN);
  static void error(String message) => _log(message, LVL_ERROR);

  // 内部方法：记录日志
  static void _log(String message, String level) {
    if (!_enabled) return;

    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      message: message,
    );

    _logs.add(entry);
    if (_logs.length > 200) {
      _logs.removeAt(0);
    }

    print('[${entry.timeStr}] [$level] $message');
    _writeToFile(entry);
    _streamController.add(entry);
  }

  // 内部方法：写到文件
  static void _writeToFile(LogEntry entry) {
    if (_logFile == null) return;
    try {
      _logFile!.writeAsString(
        '[${entry.timeStr}] [${entry.level}] ${entry.message}\n',
        mode: FileMode.append,
      ).catchError((_) {});
    } catch (_) {}
  }

  // 获取完整日志文本
  static Future<String> getLogText() async {
    if (_logFile == null) return '（未启用）';
    try {
      if (await _logFile!.exists()) {
        return await _logFile!.readAsString();
      }
    } catch (_) {}
    return '（文件不可读）';
  }

  // 获取最近 N 条日志
  static List<LogEntry> getRecentLogs([int count = 50]) {
    if (_logs.length <= count) return List.from(_logs);
    return _logs.sublist(_logs.length - count);
  }

  // 获取日志文件大小
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

  // 清空日志
  static Future<void> clearLogs() async {
    _logs.clear();
    if (_logFile != null) {
      try {
        await _logFile!.writeAsString('');
      } catch (_) {}
    }
  }

  // 获取日志文件路径
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

// 单条日志数据模型
class LogEntry {
  final DateTime timestamp;
  final String level;
  final String message;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
  });

  // 格式化时间
  String get timeStr {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}.'
        '${timestamp.millisecond.toString().padLeft(3, '0')}';
  }
}
