import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme.dart';
import 'database_helper.dart';
import 'quote_section.dart';
import 'spin_wheel.dart';
import 'time_gated_input.dart';
import 'stats_page.dart';
import 'debug_helper.dart';
import 'debug_page.dart';
import 'leaderboard_page.dart';
import 'user_service.dart';
import 'auth_page.dart';
import 'main.dart' show themeProvider, leaderboardAvailable;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final DatabaseHelper _db = DatabaseHelper();

  // 动态颜色访问（根据当前主题亮度）
  AppThemeColors get _colors => context.appColors;

  // 状态变量
  bool _isCheckedIn = false;
  String? _checkinResult;
  String? _checkinMethod;
  bool _isSpinning = false;
  int _todayCount = 0;

  // 用户状态
  bool _isLoggedIn = false;
  String? _nickname;

  // 调试入口 — 标题连击计数
  int _titleTapCount = 0;
  DateTime? _lastTitleTap;

  // 时间门控：晚8点后
  bool get _isAfter8PM => DateTime.now().hour >= 20;

  // 动画控制器
  late AnimationController _entryController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    DebugHelper.track('HomePage.initState');

    // 入场动画
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );

    _loadTodayStatus().then((_) {
      _entryController.forward();
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
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

      await _loadUserStatus();
    } catch (e) {
      DebugHelper.error('加载今日状态失败: $e');
    }
  }

  Future<void> _loadUserStatus() async {
    try {
      final loggedIn = await UserService.isLoggedIn();
      final nickname = await UserService.getNickname();
      setState(() {
        _isLoggedIn = loggedIn;
        _nickname = nickname;
      });
    } catch (e) {
      DebugHelper.error('加载用户状态失败: $e');
    }
  }

  Future<void> _navigateToAuth() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AuthPage()),
    );
    if (result == true) {
      await _loadUserStatus();
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

      _showResultSnackbar(result);
    } catch (e) {
      DebugHelper.error('转盘保存失败: $e');
      if (mounted) {
        setState(() => _isSpinning = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('保存失败，请重试'),
            backgroundColor: _colors.negative,
          ),
        );
      }
    }
  }

  void _onButtonSelect(String result) async {
    DebugHelper.info('手动选择: $result');
    try {
      final today = _formatDate(DateTime.now());
      DebugHelper.track('打卡: 手动选择，开始写入数据库');
      await _db.insertCheckin(date: today, method: 'button', result: result);
      DebugHelper.track('打卡: 手动选择，写入完成');

      setState(() {
        _isCheckedIn = true;
        _checkinResult = result;
        _checkinMethod = 'button';
      });

      _showResultSnackbar(result);
    } catch (e) {
      DebugHelper.error('手动选择保存失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('保存失败，请重试'),
            backgroundColor: _colors.negative,
          ),
        );
      }
    }
  }

  void _showResultSnackbar(String result) {
    final isSuccess = result == '不撸';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(
              isSuccess ? '✓ ' : '✗ ',
              style: TextStyle(
                color: isSuccess ? _colors.accent : _colors.negative,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              isSuccess ? '克制成功，继续保持' : '记录已保存',
              style: TextStyle(color: _colors.textPrimary),
            ),
          ],
        ),
        backgroundColor: _colors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppShapes.borderRadius),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onCountChanged(int newCount) async {
    if (newCount < 0) return;
    DebugHelper.info('更新次数: $newCount');
    setState(() => _todayCount = newCount);
    try {
      final today = _formatDate(DateTime.now());
      await _db.updateCount(today, newCount);
      DebugHelper.track('次数更新完成');
    } catch (e) {
      DebugHelper.error('次数更新失败: $e');
    }
  }

  // 标题连击 — 调试入口
  void _onTitleTap() {
    final now = DateTime.now();
    if (_lastTitleTap == null ||
        now.difference(_lastTitleTap!) > const Duration(milliseconds: 500)) {
      _titleTapCount = 1;
    } else {
      _titleTapCount++;
    }
    _lastTitleTap = now;

    if (_titleTapCount >= 5) {
      _titleTapCount = 0;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DebugPage()),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _colors.background,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.lg),

                // 一言区域
                const QuoteSection(),

                const SizedBox(height: AppSpacing.xl),

                // 打卡区域标题
                _buildSectionHeader('今日打卡'),

                const SizedBox(height: AppSpacing.md),

                // 转盘
                _buildWheelCard(),

                const SizedBox(height: AppSpacing.md),

                // 手动选择按钮
                _buildManualButtons(),

                const SizedBox(height: AppSpacing.xl),

                // 次数输入
                _buildSectionHeader('次数记录'),
                const SizedBox(height: AppSpacing.md),
                TimeGatedInput(
                  isCheckedIn: _isCheckedIn,
                  isAfter8PM: _isAfter8PM,
                  currentCount: _todayCount,
                  onCountChanged: _onCountChanged,
                ),

                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // AppBar — 左对齐标题 + 右侧操作
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _colors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: GestureDetector(
        onTap: _onTitleTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo 图标
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _colors.accent,
                borderRadius: AppShapes.borderRadiusSm,
              ),
              child: Center(
                child: Text(
                  'L',
                  style: TextStyle(
                    color: _colors.background,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Text(
              '录了么',
              style: AppText.title,
            ),
          ],
        ),
      ),
      actions: [
        // 主题切换按钮
        _buildAppBarAction(
          icon: _colors.isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
          onPressed: () {
            themeProvider.toggle();
          },
        ),
        // 统计按钮
        _buildAppBarAction(
          icon: Icons.bar_chart_rounded,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StatsPage()),
            );
          },
        ),
        // 排行榜按钮（后端可用且已登录时才显示）
        if (leaderboardAvailable && _isLoggedIn)
          _buildAppBarAction(
            icon: Icons.leaderboard_rounded,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LeaderboardPage()),
              );
            },
          ),
        // 登录/用户按钮
        _buildAppBarAction(
          icon: _isLoggedIn ? Icons.person_rounded : Icons.login_rounded,
          onPressed: _navigateToAuth,
        ),
        // 调试按钮
        _buildAppBarAction(
          icon: Icons.bug_report_rounded,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DebugPage()),
            );
          },
        ),
        const SizedBox(width: AppSpacing.sm),
      ],
    );
  }

  Widget _buildAppBarAction({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppShapes.borderRadiusSm,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: _colors.textSecondary,
            size: 22,
          ),
        ),
      ),
    );
  }

  // 区域标题 — 左对齐，带微妙分割线
  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: AppText.label.copyWith(
            letterSpacing: 1.5,
            color: _colors.textMuted,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: 24,
          height: 2,
          decoration: BoxDecoration(
            color: _colors.accent,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    );
  }

  // 转盘卡片
  Widget _buildWheelCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: _colors.surface,
        borderRadius: AppShapes.borderRadius,
        border: Border.all(color: _colors.border),
        boxShadow: AppShadows.card(context.isDark),
      ),
      child: Column(
        children: [
          // 转盘组件
          SpinWheel(
            isDisabled: _isCheckedIn || _isSpinning,
            onSpinComplete: _onSpinComplete,
            onSpinStart: () => setState(() => _isSpinning = true),
          ),

          // 已打卡状态
          if (_isCheckedIn && _checkinMethod == 'spin') ...[
            const SizedBox(height: AppSpacing.lg),
            _buildCheckedInBadge(),
          ],
        ],
      ),
    );
  }

  // 手动选择按钮
  Widget _buildManualButtons() {
    return Row(
      children: [
        // 不撸按钮
        Expanded(
          child: _buildSelectButton(
            label: '不撸',
            isSelected: _isCheckedIn && _checkinResult == '不撸',
            isSuccess: true,
            onPressed: _isCheckedIn ? null : () => _onButtonSelect('不撸'),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        // 撸按钮
        Expanded(
          child: _buildSelectButton(
            label: '撸',
            isSelected: _isCheckedIn && _checkinResult == '撸',
            isSuccess: false,
            onPressed: _isCheckedIn ? null : () => _onButtonSelect('撸'),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectButton({
    required String label,
    required bool isSelected,
    required bool isSuccess,
    required VoidCallback? onPressed,
  }) {
    final Color activeColor = isSuccess ? _colors.accent : _colors.negative;
    final Color activeBg = isSuccess
        ? _colors.accentSubtle
        : _colors.negativeSubtle;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: Material(
        color: isSelected ? activeBg : _colors.surface,
        borderRadius: AppShapes.borderRadius,
        child: InkWell(
          onTap: onPressed,
          borderRadius: AppShapes.borderRadius,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            decoration: BoxDecoration(
              borderRadius: AppShapes.borderRadius,
              border: Border.all(
                color: isSelected
                    ? activeColor
                    : _colors.border,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: AppText.cardTitle.copyWith(
                  color: isSelected
                      ? activeColor
                      : (onPressed == null
                          ? _colors.textMuted
                          : _colors.textPrimary),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 已打卡标记
  Widget _buildCheckedInBadge() {
    final isSuccess = _checkinResult == '不撸';
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isSuccess
            ? _colors.accentSubtle
            : _colors.negativeSubtle,
        borderRadius: AppShapes.borderRadiusSm,
        border: Border.all(
          color: isSuccess ? _colors.accent : _colors.negative,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.info,
            size: 16,
            color: isSuccess ? _colors.accent : _colors.negative,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '已记录: $_checkinResult',
            style: AppText.caption.copyWith(
              color: isSuccess ? _colors.accent : _colors.negative,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
