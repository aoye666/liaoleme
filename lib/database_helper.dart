import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// 数据库助手类
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    try {
      _database = await _initDatabase();
      return _database!;
    } catch (e) {
      // 数据库初始化失败时清空缓存，允许重试
      _database = null;
      rethrow;
    }
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'liaoleme.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onConfigure: (db) async {
        // 使用 DELETE 日志模式，防止异常退出导致 WAL 文件损坏
        await db.execute('PRAGMA journal_mode=DELETE');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
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
  }

  // 插入打卡记录
  Future<int> insertCheckin({
    required String date,
    required String method,
    required String result,
    int count = 0,
  }) async {
    final db = await database;
    return await db.insert(
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
  }

  // 查询今日打卡记录
  Future<Map<String, dynamic>?> getCheckinByDate(String date) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'checkins',
      where: 'date = ?',
      whereArgs: [date],
    );
    return result.isEmpty ? null : result.first;
  }

  // 更新次数
  Future<int> updateCount(String date, int count) async {
    final db = await database;
    return await db.update(
      'checkins',
      {'count': count},
      where: 'date = ?',
      whereArgs: [date],
    );
  }

  // 获取所有打卡记录（按日期升序）
  Future<List<Map<String, dynamic>>> getAllCheckins() async {
    final db = await database;
    return await db.query(
      'checkins',
      orderBy: 'date ASC',
    );
  }

  // 获取最近 n 天的打卡记录
  Future<List<Map<String, dynamic>>> getRecentCheckins(int days) async {
    final db = await database;
    final startDate = DateTime.now().subtract(Duration(days: days));
    final dateStr = _formatDate(startDate);
    return await db.query(
      'checkins',
      where: 'date >= ?',
      whereArgs: [dateStr],
      orderBy: 'date ASC',
    );
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
