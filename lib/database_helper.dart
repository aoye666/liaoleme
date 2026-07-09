import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'debug_helper.dart';

// 数据库助手类
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    DebugHelper.track('DB: 首次获取数据库实例');
    try {
      _database = await _initDatabase();
      DebugHelper.track('DB: 数据库打开成功');
      return _database!;
    } catch (e) {
      DebugHelper.error('数据库初始化失败: $e');
      _database = null;
      rethrow;
    }
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    String path = join(dbPath, 'liaoleme.db');
    DebugHelper.info('数据库路径: $path');
    DebugHelper.info('getDatabasesPath: $dbPath');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onConfigure: (db) async {
        DebugHelper.track('DB: 配置日志模式为 DELETE');
        await db.execute('PRAGMA journal_mode=DELETE');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    DebugHelper.track('DB: 创建表结构 (version=$version)');
    await db.execute('''
      CREATE TABLE checkins (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT UNIQUE NOT NULL,
        method TEXT NOT NULL,
        result TEXT NOT NULL,
        count INTEGER DEFAULT 0,
        timestamp INTEGER NOT NULL
      )
    ''');
    DebugHelper.track('DB: 表结构创建完成');
  }

  // 插入打卡记录
  Future<int> insertCheckin({
    required String date,
    required String method,
    required String result,
    int count = 0,
  }) async {
    DebugHelper.track('DB: insertCheckin(date=$date, method=$method, result=$result)');
    final db = await database;
    final id = await db.insert(
      'checkins',
      {
        'date': date,
        'method': method,
        'result': result,
        'count': count,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    DebugHelper.info('DB: insertCheckin 成功 id=$id');
    return id;
  }

  // 查询今日打卡记录
  Future<Map<String, dynamic>?> getCheckinByDate(String date) async {
    DebugHelper.track('DB: getCheckinByDate(date=$date)');
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'checkins',
      where: 'date = ?',
      whereArgs: [date],
    );
    DebugHelper.info('DB: getCheckinByDate 结果行数=${result.length}');
    return result.isEmpty ? null : result.first;
  }

  // 更新次数
  Future<int> updateCount(String date, int count) async {
    DebugHelper.info('DB: updateCount(date=$date, count=$count)');
    final db = await database;
    final affected = await db.update(
      'checkins',
      {'count': count},
      where: 'date = ?',
      whereArgs: [date],
    );
    DebugHelper.info('DB: updateCount 影响行数=$affected');
    return affected;
  }

  // 获取所有打卡记录（按日期升序）
  Future<List<Map<String, dynamic>>> getAllCheckins() async {
    DebugHelper.track('DB: getAllCheckins');
    final db = await database;
    final result = await db.query(
      'checkins',
      orderBy: 'date ASC',
    );
    DebugHelper.info('DB: getAllCheckins 返回 ${result.length} 条');
    return result;
  }

  // 获取最近 n 天的打卡记录
  Future<List<Map<String, dynamic>>> getRecentCheckins(int days) async {
    DebugHelper.info('DB: getRecentCheckins(days=$days)');
    final db = await database;
    final startDate = DateTime.now().subtract(Duration(days: days));
    final dateStr = _formatDate(startDate);
    DebugHelper.info('DB: 查询起始日期=$dateStr');
    final result = await db.query(
      'checkins',
      where: 'date >= ?',
      whereArgs: [dateStr],
      orderBy: 'date ASC',
    );
    DebugHelper.info('DB: getRecentCheckins 返回 ${result.length} 条');
    return result;
  }

  // 检查今天是否已打卡
  Future<bool> isCheckedInToday() async {
    final today = _formatDate(DateTime.now());
    final record = await getCheckinByDate(today);
    return record != null;
  }

  // 格式化日期为 yyyy-MM-dd
  static String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
