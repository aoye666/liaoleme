import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';
import 'dart:async';
import 'theme.dart';
import 'home_page.dart';
import 'debug_helper.dart';
import 'leaderboard_service.dart';
import 'user_service.dart';

// 全局通知插件实例
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// 排行榜服务可用状态（启动时检查，后端不可用则隐藏按钮）
bool leaderboardAvailable = false;

// ===== 主题状态管理 =====
// 自动模式：根据系统时间切换（>=20:00 暗色, >=06:00 亮色）
// 手动模式：用户点击按钮覆盖，1小时后恢复自动
class ThemeProvider extends ChangeNotifier {
  bool _autoMode = true;
  bool? _manualIsDark;  // null 表示未手动设置
  DateTime? _lastManualToggle;
  bool? _cachedIsDark;  // 上次通知时的 isDark 值，用于检测变化

  bool get isDark {
    if (_autoMode || _manualIsDark == null) {
      final hour = DateTime.now().hour;
      return hour >= 20 || hour < 6;
    }
    return _manualIsDark!;
  }

  bool get autoMode => _autoMode;

  Brightness get brightness => isDark ? Brightness.dark : Brightness.light;

  // 切换到相反主题
  void toggle() {
    _manualIsDark = !isDark;
    _autoMode = false;
    _lastManualToggle = DateTime.now();
    notifyListeners();
    DebugHelper.info('主题切换: ${_manualIsDark! ? "暗色" : "亮色"} (手动)');
  }

  // 恢复自动模式
  void setAutoMode() {
    _autoMode = true;
    _manualIsDark = null;
    _lastManualToggle = null;
    notifyListeners();
    DebugHelper.info('主题切换: 自动模式');
  }

  // 检查并更新自动模式下的主题（每分钟调用一次）
  void checkAutoUpdate() {
    // 手动模式下，检查是否已经过了1小时，恢复自动
    if (!_autoMode && _lastManualToggle != null) {
      final elapsed = DateTime.now().difference(_lastManualToggle!);
      if (elapsed.inMinutes >= 60) {
        _autoMode = true;
        _manualIsDark = null;
        _lastManualToggle = null;
      }
    }

    // 检查 isDark 是否发生变化，有变化才通知
    final current = isDark;
    if (_cachedIsDark != current) {
      _cachedIsDark = current;
      notifyListeners();
      DebugHelper.info('主题切换: ${current ? "暗色" : "亮色"} (自动)');
    }
  }
}

final themeProvider = ThemeProvider();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ===== 调试系统初始化（最先启动，记录全局流程） =====
  await DebugHelper.enable();
  DebugHelper.track('调试系统启动');
  DebugHelper.info('录了么 暗色/亮色模式切换版启动');
  DebugHelper.info('平台: ${Platform.isAndroid ? "Android" : "其他"}');

  // 初始化主题
  DebugHelper.info('当前模式: ${themeProvider.isDark ? "暗色" : "亮色"}');

  // 设置状态栏为透明，内容延伸到状态栏
  _updateSystemUI(themeProvider.brightness);

  // 定时检查主题更新（每分钟检查一次，整点自动切换）
  Timer.periodic(const Duration(minutes: 1), (_) {
    final wasDark = themeProvider.isDark;
    themeProvider.checkAutoUpdate();
    if (themeProvider.isDark != wasDark) {
      _updateSystemUI(themeProvider.brightness);
    }
  });

  // ---- 通知初始化 ----
  DebugHelper.track('开始初始化通知');
  try {
    await _initNotifications();
    DebugHelper.track('通知初始化完成');
  } catch (e) {
    DebugHelper.error('通知初始化失败: $e');
  }

  // ---- 用户服务初始化（生成设备ID）----
  DebugHelper.track('初始化用户服务');
  try {
    final systemUserId = await UserService.getSystemUserId();
    DebugHelper.info('设备ID: $systemUserId');
  } catch (e) {
    DebugHelper.error('用户服务初始化失败: $e');
  }

  // ---- 排行榜服务健康检查 ----
  DebugHelper.track('检查排行榜服务可用性');
  try {
    leaderboardAvailable = await LeaderboardService().checkHealth();
    DebugHelper.info('排行榜服务可用: $leaderboardAvailable');
  } catch (e) {
    DebugHelper.warn('排行榜服务检查失败: $e');
    leaderboardAvailable = false;
  }

  // ---- 启动完成 ----
  DebugHelper.track('进入主界面');
  runApp(const LiaoLeMeApp());
}

// 根据亮度更新系统状态栏样式
void _updateSystemUI(Brightness brightness) {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: brightness == Brightness.dark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: brightness == Brightness.dark ? AppColors.background : AppColorsLight.background,
      systemNavigationBarIconBrightness: brightness == Brightness.dark ? Brightness.light : Brightness.dark,
    ),
  );
}

// 初始化本地通知
Future<void> _initNotifications() async {
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings iosSettings =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const InitializationSettings initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  DebugHelper.track('notif: 调用 initialize');
  await flutterLocalNotificationsPlugin.initialize(initSettings);
  DebugHelper.track('notif: initialize 成功');

  // Android 通知渠道
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'liaoleme_daily',
    '每日打卡提醒',
    description: '每天定时提醒你打卡',
    importance: Importance.high,
    playSound: true,
  );

  final androidPlugin = flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  DebugHelper.track('notif: 创建通知渠道');
  await androidPlugin?.createNotificationChannel(channel);
  DebugHelper.track('notif: 渠道创建成功');

  // Android 13+ 运行时通知权限请求
  DebugHelper.track('notif: 请求通知权限（try）');
  try {
    if (Platform.isAndroid) {
      await androidPlugin?.requestNotificationsPermission();
      DebugHelper.track('notif: 权限请求完成');
    }
  } catch (e) {
    DebugHelper.warn('通知权限请求异常: $e');
  }

  // 调度每日通知
  DebugHelper.track('notif: 调度每日通知（try）');
  try {
    await scheduleDailyNotification();
    DebugHelper.track('notif: 通知调度成功');
  } catch (e) {
    DebugHelper.error('通知调度失败: $e');
  }
}

// 调度每日打卡通知（20:00）
// v18 只支持 periodicallyShow，不再有 showDailyAtTime 和 Time 类
Future<void> scheduleDailyNotification() async {
  const AndroidNotificationDetails androidDetails =
      AndroidNotificationDetails(
    'liaoleme_daily',
    '每日打卡提醒',
    channelDescription: '每天定时提醒你打卡',
    importance: Importance.high,
    priority: Priority.high,
    showWhen: true,
  );

  const NotificationDetails details = NotificationDetails(
    android: androidDetails,
  );

  try {
    await flutterLocalNotificationsPlugin.periodicallyShow(
      0,
      '录了么',
      '今天的结果是什么？来打个卡吧',
      RepeatInterval.daily,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
    DebugHelper.track('notif: periodicallyShow 成功');
  } catch (e) {
    DebugHelper.error('通知调度失败: $e');
    rethrow;
  }
}

// 应用根组件
class LiaoLeMeApp extends StatelessWidget {
  const LiaoLeMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeProvider,
      builder: (context, _) {
        // 主题变化时更新系统UI
        _updateSystemUI(themeProvider.brightness);
        return MaterialApp(
          title: '录了么',
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(themeProvider.brightness),
          home: const HomePage(),
        );
      },
    );
  }
}
