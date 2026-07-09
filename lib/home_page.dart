import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';
import 'quote_section.dart';
import 'spin_wheel.dart';
import 'time_gated_input.dart';
import 'stats_page.dart';
import 'debug_helper.dart';
import 'debug_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseHelper _db = DatabaseHelper();
  
  // 状态变量
  bool _isCheckedIn = false;
  String? _checkinResult;
  String? _checkinMethod;
  bool _isSpinning = false;
  int _todayCount = 0;
  
  // 调试入口 — 标题连击计数
  int _titleTapCount = 0;
  DateTime? _lastTitleTap;
  
  // 时间门控：晚8点后
  bool get _isAfter8PM => DateTime.now().hour >= 20;

  @override
  void initState() {
    super.initState();
    DebugHelper.track('HomePage.initState');
    _loadTodayStatus();
  }

  Future<void> _loadTodayStatus() async {
    DebugHelper.track('_loadTodayStatus: 开始加载');
    try {
      final today = _formatDate(DateTime.now());
      DebugHelper.info('查询今日记录: date=$today');
      final record = await _db.getCheckinByDate(today);
      
      if (record != null) {
        DebugHelper.info('今日已打卡: result=${record['result']}, method=${record['method']}, count=${record['count']}');
        setState(() {
          _isCheckedIn = true;
          _checkinResult = record['result'];
          _checkinMethod = record['method'];
          _todayCount = record['count'] ?? 0;
        });
        DebugHelper.track('_loadTodayStatus: 已打卡');
      } else {
        DebugHelper.info('今日未打卡');
        DebugHelper.track('_loadTodayStatus: 未打卡');
      }
    } catch (e) {
      DebugHelper.error('加载今日状态失败: $e');
      // 数据库异常降级：保持空状态，用户仍然可以正常打卡
    }
  }

  void _onSpinComplete(String result) async {
    DebugHelper.info('转盘结果: $result');
    try {
      final today = _formatDate(DateTime.now());
      DebugHelper.track('打卡: 转盘，开始写入数据库');
      await _db.insertCheckin(date: today, method: 'spin', result: result);
      DebugHelper.track('打卡: 转盘，写入完成');
      
      setState(() {
        _isSpinning = false;
        _isCheckedIn = true;
        _checkinResult = result;
        _checkinMethod = 'spin';
      });
      
      _showResultDialog(result);
    } catch (e) {
      DebugHelper.error('转盘保存失败: $e');
      if (mounted) {
        setState(() => _isSpinning = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('保存失败，请重试')),
        );
      }
    }
  }

  void _onButtonSelect(String result) async {
    DebugHelper.info('手动选择: $result');
    try {
      final today = _formatDate(DateTime.now());
      DebugHelper.track('打卡: 手动按钮，开始写入数据库');
      await _db.insertCheckin(date: today, method: 'button', result: result);
      DebugHelper.track('打卡: 手动按钮，写入完成');
      
      setState(() {
        _isCheckedIn = true;
        _checkinResult = result;
        _checkinMethod = 'button';
      });
      
      _showResultDialog(result);
    } catch (e) {
      DebugHelper.error('手动保存失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('保存失败，请重试')),
        );
      }
    }
  }

  void _showResultDialog(String result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          result == '不撸' ? '🎉 太棒了！' : '💪 没关系',
          style: const TextStyle(color: Colors.black87),
        ),
        content: Text(
          result == '不撸' 
              ? '恭喜你成功克制住了！\n今天的你又是强大的自己！' 
              : '没关系，明天继续努力！\n重要的是不放弃！',
          style: const TextStyle(color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              '确定',
              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateCount(int count) async {
    DebugHelper.info('更新次数: $count');
    try {
      final today = _formatDate(DateTime.now());
      await _db.updateCount(today, count);
      setState(() => _todayCount = count);
      DebugHelper.track('次数更新成功: $count');
    } catch (e) {
      DebugHelper.error('次数更新失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: GestureDetector(
          onTap: () {
            final now = DateTime.now();
            // 1秒内连续点击才计数
            if (_lastTitleTap != null &&
                now.difference(_lastTitleTap!) < const Duration(seconds: 1)) {
              _titleTapCount++;
            } else {
              _titleTapCount = 1;
            }
            _lastTitleTap = now;

            // 连击5次进入调试页
            if (_titleTapCount >= 5) {
              _titleTapCount = 0;
              DebugHelper.info('🛠️ 调试入口触发');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DebugPage()),
              );
            }
          },
          child: const Text(
            '撸了么',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StatsPage()),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const QuoteSection(),
            _buildCheckinSection(),
            TimeGatedInput(
              isCheckedIn: _isCheckedIn,
              isAfter8PM: _isAfter8PM,
              currentCount: _todayCount,
              onCountChanged: _updateCount,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckinSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '今日打卡',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 20),
          
          SpinWheel(
            isDisabled: _isCheckedIn || _isSpinning,
            onSpinComplete: _onSpinComplete,
            onSpinStart: () => setState(() => _isSpinning = true),
          ),
          
          const SizedBox(height: 24),
          
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey[300])),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('或者', style: TextStyle(color: Colors.grey[500])),
              ),
              Expanded(child: Divider(color: Colors.grey[300])),
            ],
          ),
          
          const SizedBox(height: 24),
          
          Row(
            children: [
              Expanded(
                child: _buildCheckinButton(
                  label: '不撸',
                  color: Colors.black,
                  isDisabled: _isCheckedIn || _isSpinning,
                  onPressed: () => _onButtonSelect('不撸'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCheckinButton(
                  label: '撸了',
                  color: Colors.grey[700]!,
                  isDisabled: _isCheckedIn || _isSpinning,
                  onPressed: () => _onButtonSelect('撸'),
                ),
              ),
            ],
          ),
          
          if (_isCheckedIn) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _checkinResult == '不撸' ? Icons.check_circle : Icons.info,
                    color: _checkinResult == '不撸' ? Colors.green : Colors.orange,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '今日已打卡：$_checkinResult',
                    style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCheckinButton({
    required String label,
    required Color color,
    required bool isDisabled,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey[300],
        disabledForegroundColor: Colors.grey[500],
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: isDisabled ? 0 : 2,
      ),
      child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
