import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';
import 'home_page.dart';

// 全局通知插件实例
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initNotifications();

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

  await flutterLocalNotificationsPlugin.initialize(initSettings);

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

  await androidPlugin?.createNotificationChannel(channel);

  // Android 13+ 运行时通知权限请求
  if (Platform.isAndroid) {
    await androidPlugin?.requestNotificationsPermission();
  }

  // 调度每日通知
  await scheduleDailyNotification();
}

// 调度每日打卡通知（20:00）
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

  await flutterLocalNotificationsPlugin.periodicallyShow(
    1,
    '撸了么提醒',
    '该打卡啦！来看看今天的自己吧',
    RepeatInterval.daily,
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
