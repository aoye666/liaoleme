import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'debug_helper.dart';

/// 数据库助手类 - 单例模式，全局共享数据库连接
/// 
/// 表结构 checkins:
/// - id: 自增主键
/// - date: 日期 (yyyy-MM-dd)
/// - method: 打卡方式 ('spin'=转盘, 'button'=按钮)
/// - result: 打卡结果 ('撸'/'不撸')
/// - count: 当日次数（仅在 isCheckedIn=true 且 hour>=20 时可编辑）
/// - timestamp: 打卡时间戳
class DatabaseHelper {
  // 单例模式
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  // 数据库实例（延迟初始化）
  static Database? _database;

  /// 获取数据库实例 - 首次调用时初始化
  /// 会自动设置 PRAGMA journal_mode=DELETE（避免 WAL 文件损坏问题）
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

  /// 初始化数据库 - 打开或创建数据库文件
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    String path = join(dbPath, 'liaoleme.db');
    DebugHelper.info('数据库路径: $path');
    DebugHelper.info('getDatabasesPath: $dbPath');
    return await openDatabase(
      path,
      version: 1,  // 数据库版本（用于未来迁移）
      onCreate: _onCreate,  // 首次创建表结构
      onConfigure: (db) async {
        // 设置日志模式：DELETE 模式（vs 默认 WAL）
        // 可以避免异常退出后 WAL 文件损坏导致的崩溃
        DebugHelper.track('DB: 配置日志模式为 DELETE');
        try {
          await db.rawQuery('PRAGMA journal_mode=DELETE');
          DebugHelper.track('DB: 日志模式配置完成');
        } catch (e) {
          DebugHelper.warn('DB: 日志模式配置失败（不影响使用）: $e');
        }
      },
    );
  }

  /// 创建表结构 - 首次创建数据库时执行
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
  // 如果日期已存在则覆盖（upsert 逻辑）
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
      conflictAlgorithm: ConflictAlgorithm.replace,  // 已存在则覆盖
    );
    DebugHelper.info('DB: insertCheckin 成功 id=$id');
    return id;
  }

  // 查询某一天的打卡记录
  // 返回该日期的记录，或 null（不存在）
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

  // 更新次数 - 用于用户手动调整今日次数
  // 返回受影响的行数（通常为1，日期不存在则为0）
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

  // 获取所有打卡记录 - 用于统计页面
  // 按日期升序排列（最早的最先）
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

  // 获取最近 n 天的打卡记录 - 用于热力图展示
  // days: 最近多少天（如 90 = 最近3个月）
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

  // 检查今天是否已打卡 - 用于首页状态判断
  Future<bool> isCheckedInToday() async {
    final today = _formatDate(DateTime.now());
    final record = await getCheckinByDate(today);
    return record != null;
  }

  // 工具方法：DateTime 转字符串 yyyy-MM-dd
  static String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
