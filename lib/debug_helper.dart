import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';

/// 调试日志系统
/// 应用启动全流程日志记录，崩溃后读日志定位问题
/// 
/// 使用方式：
/// 1. 在 main.dart 最开头调用 `await DebugHelper.enable()` 启用日志
/// 2. 用 `DebugHelper.track('步骤名')` 记录启动关键节点
/// 3. 用 `DebugHelper.info/warn/error('消息')` 记录运行日志
/// 4. 在 debug_page.dart 查看实时日志和启动步骤
/// 
/// 日志文件路径：`appDocumentsDirectory/liaoleme_debug.log`
class DebugHelper {
  // 单例模式
  static final DebugHelper _instance = DebugHelper._internal();
  factory DebugHelper() => _instance;
  DebugHelper._internal();

  // 是否已启用
  static bool _enabled = false;
  // 日志文件句柄
  static File? _logFile;
  // 内存中的日志（最多200条，用于实时显示）
  static final _logs = <LogEntry>[];
  // 日志流（用于 debug_page 实时监听）
  static final _streamController = StreamController<LogEntry>.broadcast();

  /// 获取日志流（用于实时监听调试页面）
  static Stream<LogEntry> get stream => _streamController.stream;

  /// 日志级别常量
  static const String LVL_DEBUG = 'DEBUG'; // 调试信息
  static const String LVL_INFO  = 'INFO';   // 一般信息
  static const String LVL_WARN  = 'WARN';   // 警告
  static const String LVL_ERROR = 'ERROR';  // 错误

  /// 启动跟踪列表 - 记录 app 启动的每一步
  static final List<String> startupSteps = [];

  /// 启用调试系统 - 应在 main() 最开始调用
  static Future<void> enable() async {
    if (_enabled) return; // 防止重复初始化
    _enabled = true;

    try {
      final dir = await getApplicationDocumentsDirectory();
      _logFile = File('${dir.path}/liaoleme_debug.log');

      // 确保目录存在
      await _logFile!.parent.create(recursive: true);

      // 追加分隔线标记新会话开始
      final separator = '\n${'=' * 60}\n'
          '🚀 撸了呢 App 启动会话: ${DateTime.now()}\n'
          '${'=' * 60}\n';
      await _logFile!.writeAsString(separator, mode: FileMode.append);
      print('[DebugHelper] 日志系统已启用: ${_logFile!.path}');
    } catch (e) {
      // 日志系统本身不能崩，用 print 兜底
      print('[DebugHelper] 日志文件初始化失败: $e');
    }
  }

  /// 记录启动步骤 - 用于追踪 app 启动流程
  /// 例如：DebugHelper.track('通知初始化完成')
  static void track(String step) {
    final entry = '[启动] $step';
    startupSteps.add(entry);
    _log(entry, LVL_DEBUG);
  }

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

  /// 快捷方法：记录一般信息（绿色文字）
  static void info(String message) => _log(message, LVL_INFO);

  /// 快捷方法：记录警告（橙色文字）
  static void warn(String message) => _log(message, LVL_WARN);

  /// 快捷方法：记录错误（红色文字）
  static void error(String message) => _log(message, LVL_ERROR);

  /// 内部方法：真正记录日志
  /// 会同时输出到控制台、写文件、广播给监听者
  static void _log(String message, String level) {
    if (!_enabled) return;

    // 构建日志条目
    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      message: message,
    );

    // 添加到内存日志（最多200条，超过删旧的）
    _logs.add(entry);
    if (_logs.length > 200) {
      _logs.removeAt(0);
    }

    // 输出到控制台
    print('[${entry.timeStr}] [$level] $message');

    // 写文件（异步非阻塞）
    _writeToFile(entry);

    // 广播给监听者（debug_page 实时显示）
    _streamController.add(entry);
  }

  /// 内部方法：写日志到文件（非阻塞）
  static void _writeToFile(LogEntry entry) {
    if (_logFile == null) return;
    try {
      _logFile!.writeAsString(
        '[${entry.timeStr}] [${entry.level}] ${entry.message}\n',
        mode: FileMode.append,
      ).catchError((_) {});
    } catch (_) {}
  }

  /// 获取完整日志文本 - 用于复制完整日志到剪贴板
  /// 返回日志文件的全部内容
  static Future<String> getLogText() async {
    if (_logFile == null) return '（日志系统未启用）';
    try {
      if (await _logFile!.exists()) {
        return await _logFile!.readAsString();
      }
    } catch (_) {}
    return '（日志文件不可读）';
  }

  /// 获取最近 N 条内存日志 - 用于 debug_page 实时显示
  /// 默认返回最近50条
  static List<LogEntry> getRecentLogs([int count = 50]) {
    if (_logs.length <= count) return List.from(_logs);
    return _logs.sublist(_logs.length - count);
  }

  /// 获取日志文件大小 - 用于 debug_page 显示
  /// 返回格式：123B / 4.5KB / 1.2MB 等
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

  /// 清空日志文件 - 用户手动清理时调用
  /// 注意：只清空文件，不清空内存日志（_logs）
  static Future<void> clearLogs() async {
    _logs.clear();
    if (_logFile != null) {
      try {
        await _logFile!.writeAsString('');
      } catch (_) {}
    }
  }

  /// 获取日志文件路径 - 用于 debug_page 显示
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

/// 单条日志条目 - 数据模型
class LogEntry {
  // 日志时间戳
  final DateTime timestamp;
  // 日志级别：DEBUG/INFO/WARN/ERROR
  final String level;
  // 日志消息内容
  final String message;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
  });

  /// 获取格式化的时间字符串 HH:mm:ss.SSS
  String get timeStr {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}.'
        '${timestamp.millisecond.toString().padLeft(3, '0')}';
  }
}
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
