import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';
import 'theme.dart';
import 'home_page.dart';
import 'debug_helper.dart';

// 全局通知插件实例
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 设置状态栏为透明，内容延伸到状态栏
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // ===== 调试系统初始化（最先启动，记录全局流程） =====
  await DebugHelper.enable();
  DebugHelper.track('调试系统启动');
  DebugHelper.info('撸了么 v2026.07.09 taste-skill 重构版启动');
  DebugHelper.info('平台: ${Platform.isAndroid ? "Android" : "其他"}');

  // ---- 通知初始化 ----
  DebugHelper.track('开始初始化通知');
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
      '撸了么',
      '今天的结果是什么？来打个卡吧',
      RepeatInterval.daily,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
    DebugHelper.track('notif: periodicallyShow 成功');
  } catch (e) {
    DebugHelper.error('通知调度失败: $e');
  }
}

// 应用根组件
class LiaoLeMeApp extends StatelessWidget {
  const LiaoLeMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '撸了么',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const HomePage(),
    );
  }
}
