# 录了么 — 每日打卡 App

> 一个帮你自律的黑白风每日打卡应用

## 功能特点

- 🎡 **随机转盘** — 每天转动转盘决定今天是「撸」还是「不撸」
- 👆 **平行选择** — 转盘和按钮二选一完成打卡
- 🔒 **时间门控** — 次数输入仅在打卡完成后 + 20:00 后开放
- 📊 **数据统计** — GitHub 风格热力图 + 折线图展示打卡记录
- 🔔 **每日提醒** — 每天 20:00 自动推送打卡提醒
- 📝 **随机一言** — 每日一言毒鸡汤激励自己
- 🐛 **调试面板** — 点击标题栏的 🐞 按钮查看启动日志和数据库状态

## 技术栈

- **Flutter** — 跨平台 UI 框架
- **SQLite (sqflite)** — 本地数据库存储
- **fl_chart** — 统计图表
- **flutter_local_notifications** — 每日提醒
- **Hitokoto API** — 一言服务

## 安装

从 GitHub Releases 下载最新的 APK：

```
https://github.com/aoye666/liaoleme/releases/latest
```

## 开发

### 环境要求

- Flutter SDK >= 3.7.0
- Android SDK

### 运行

```bash
cd liaoleme
flutter pub get
flutter run
```

### 构建 APK

```bash
flutter build apk --release
```

## 调试日志

应用内置调试系统，启动时自动记录每一步操作。

### 查看日志

1. 在首页点击标题栏右侧的 🐞 小虫图标
2. 或连续点击标题「录了么」5次（1秒内）

调试面板显示：
- 📊 数据库状态（记录数、最后更新时间）
- 🚀 启动步骤（从 app 启动到主界面加载的全流程）
- 📝 实时日志（最近 200 条）
- 📁 日志文件路径和大小

### 导出日志

在调试面板点击「复制完整日志」按钮，将完整日志（包括历史会话）复制到剪贴板，然后发给我排查问题。

### 日志文件位置

```
appDocumentsDirectory/liaoleme_debug.log
```

Android 设备上通常是：
```
/data/user/0/com.example.liaoleme/files/liaoleme_debug.log
```

## 项目结构

```
lib/
├── main.dart           # 入口、通知初始化、黑白主题
├── home_page.dart      # 首页、转盘/按钮打卡、次数输入
├── database_helper.dart # SQLite 数据库操作
├── debug_helper.dart   # 调试日志系统
├── debug_page.dart     # 调试信息面板
├── stats_page.dart     # 数据统计（热力图+折线图）
├── quote_section.dart  # 随机一言组件
├── spin_wheel.dart     # 转盘动画组件
├── time_gated_input.dart # 时间门控次数输入
└── quote_service.dart  # 一言 API 服务
```

## License

MIT License
