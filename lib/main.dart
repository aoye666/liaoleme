import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';
import 'home_page.dart';
import 'debug_helper.dart';

// 全局通知插件实例
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ===== 调试系统初始化（最先启动，记录全局流程） =====
  await DebugHelper.enable();
  DebugHelper.track('调试系统启动');
  DebugHelper.info('撸了么 v2026.07.08.2333 启动');
  DebugHelper.info('平台: ${Platform.isAndroid ? "Android" : "其他"}');

  // ---- 通知初始化 ----
  DebugHelper.track('开始初始化通知');
  DebugHelper.info('通知版本: flutter_local_notifications');
  try {
    await _initNotifications();
    DebugHelper.track('通知初始化完成');
  } catch (e) {
    DebugHelper.error('通知初始化失败: $e');
  }

  // ---- 启动完成 ----
  DebugHelper.track('进入主界面');
  runApp(const LiaoLeMeApp());
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
// 使用 showDailyAtTime 替代 periodicallyShow
// 后者在部分 Android 设备上会触发 Java 泛型序列化 bug (Missing type parameter)
Future<void> scheduleDailyNotification() async {
  const AndroidNotificationDetails androidDetails =
      AndroidNotificationDetails(
    'liaoleme_daily',
    '每日打卡提醒',
    channelDescription: '每天20:00提醒你打卡',
    importance: Importance.high,
    priority: Priority.high,
  );

  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
  );

  // showDailyAtTime 使用不同的内部调度路径，避免泛型序列化问题
  await flutterLocalNotificationsPlugin.showDailyAtTime(
    1,
    '撸了么提醒',
    '该打卡啦！来看看今天的自己吧',
    const Time(20, 0, 0),
    notificationDetails,
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
  );
}

class LiaoLeMeApp extends StatelessWidget {
  const LiaoLeMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '撸了么',
      debugShowCheckedModeBanner: false,
      theme: _buildBlackWhiteTheme(),
      home: const HomePage(),
    );
  }

  // 黑白配色主题
  ThemeData _buildBlackWhiteTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.grey,
      scaffoldBackgroundColor: Colors.grey[100],

      colorScheme: ColorScheme.light(
        primary: Colors.black,
        secondary: Colors.grey[700]!,
        surface: Colors.white,
        error: Colors.grey[600]!,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        ),
      ),

      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black26),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black, width: 2),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: Colors.grey[300],
        thickness: 1,
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),

      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.black87),
        bodyMedium: TextStyle(color: Colors.black87),
        titleLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
      ),

      iconTheme: const IconThemeData(
        color: Colors.black54,
      ),
    );
  }
}
