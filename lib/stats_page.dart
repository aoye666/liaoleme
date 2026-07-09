import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'theme.dart';
import 'database_helper.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  final DatabaseHelper _db = DatabaseHelper();
  List<Map<String, dynamic>> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final records = await _db.getRecentCheckins(90);
      if (mounted) {
        setState(() {
          _records = records;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('加载统计数据失败: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('加载失败，请稍后重试'),
            backgroundColor: context.appColors.negative,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.background,
      appBar: AppBar(
        backgroundColor: context.appColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text('数据统计', style: AppText.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: context.appColors.textSecondary,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: context.appColors.accent,
                strokeWidth: 2,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildHeatmapCard(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildLineChartCard(),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
    );
  }

  // 统计总览卡片
  Widget _buildSummaryCard() {
    final totalDays = _records.length;
    final noCount = _records.where((r) => r['result'] == '不撸').length;
    final yesCount = _records.where((r) => r['result'] == '撸').length;
    final totalTimes = _records.fold<int>(0, (sum, r) => sum + (r['count'] as int? ?? 0));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppShapes.borderRadius,
        border: Border.all(color: context.appColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '近90天总览',
            style: AppText.label.copyWith(
              color: context.appColors.textMuted,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 四个指标横排
          Row(
            children: [
              _buildStatItem('打卡', '$totalDays', '天'),
              _buildStatDivider(),
              _buildStatItem('不撸', '$noCount', '天'),
              _buildStatDivider(),
              _buildStatItem('撸', '$yesCount', '天'),
              _buildStatDivider(),
              _buildStatItem('次数', '$totalTimes', '次'),
            ],
          ),

          // 成功率条
          if (totalDays > 0) ...[
            const SizedBox(height: AppSpacing.lg),
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: context.appColors.surfaceElevated,
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: noCount / totalDays,
                child: Container(
                  decoration: BoxDecoration(
                    color: context.appColors.accent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '成功率 ${(noCount * 100 / totalDays).toStringAsFixed(1)}%',
              style: AppText.caption.copyWith(color: context.appColors.accent),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String unit) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppText.numberSmall.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 2),
          Text(
            '$label($unit)',
            style: AppText.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 32,
      color: context.appColors.border,
    );
  }

  // 热力图卡片
  Widget _buildHeatmapCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppShapes.borderRadius,
        border: Border.all(color: context.appColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '打卡热力图',
            style: AppText.label.copyWith(
              color: context.appColors.textMuted,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 热力图网格
          _buildHeatmapGrid(),

          const SizedBox(height: AppSpacing.md),

          // 图例
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildLegendItem('无记录', context.appColors.surfaceElevated),
              const SizedBox(width: AppSpacing.sm),
              _buildLegendItem('不撸', context.appColors.accent),
              const SizedBox(width: AppSpacing.sm),
              _buildLegendItem('撸', context.appColors.border),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeatmapGrid() {
    // 过去 12 周 = 84 天
    final daysToShow = 84;
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: daysToShow - 1));

    // 构建日期->记录的映射
    final recordMap = <String, Map<String, dynamic>>{};
    for (final r in _records) {
      recordMap[r['date'] as String] = r;
    }

    // 计算起始星期偏移（让第一行从周一开始）
    final startWeekday = startDate.weekday % 7; // 0=Sun

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellSize = (constraints.maxWidth - 7 * 2) / 8; // 8 columns with gap
        final rows = <Widget>[];

        // 星期标签行
        final weekdayLabels = ['一', '二', '三', '四', '五', '六', '日'];
        rows.add(
          Row(
            children: [
              SizedBox(width: cellSize + 2), // 左侧空白
              ...weekdayLabels.map((d) => SizedBox(
                    width: cellSize + 2,
                    child: Center(
                      child: Text(d, style: AppText.caption),
                    ),
                  )),
            ],
          ),
        );

        // 日期网格
        final totalCells = startWeekday + daysToShow;
        final rowCount = (totalCells / 7).ceil();

        for (int row = 0; row < rowCount; row++) {
          final cells = <Widget>[];

          for (int col = 0; col < 7; col++) {
            final index = row * 7 + col - startWeekday;

            if (index < 0 || index >= daysToShow) {
              cells.add(SizedBox(width: cellSize, height: cellSize));
            } else {
              final date = startDate.add(Duration(days: index));
              final dateStr =
                  '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
              final record = recordMap[dateStr];

              cells.add(
                Container(
                  width: cellSize,
                  height: cellSize,
                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: _getHeatmapColor(record),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }
          }

          rows.add(
            Row(
              children: [
                SizedBox(width: cellSize + 2), // 左侧空白
                ...cells,
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rows,
        );
      },
    );
  }

  Color _getHeatmapColor(Map<String, dynamic>? record) {
    if (record == null) return context.appColors.surfaceElevated;
    final result = record['result'] as String;
    if (result == '不撸') return context.appColors.accent;
    return context.appColors.border; // 撸 = 微妙灰色
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppText.caption),
      ],
    );
  }

  // 折线图卡片
  Widget _buildLineChartCard() {
    // 按日期聚合次数
    final Map<String, int> dateCountMap = {};
    for (final r in _records) {
      final date = r['date'] as String;
      dateCountMap[date] = (dateCountMap[date] ?? 0) + (r['count'] as int? ?? 0);
    }

    // 取最近 30 天
    final now = DateTime.now();
    final spots = <FlSpot>[];
    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final count = dateCountMap[dateStr] ?? 0;
      spots.add(FlSpot((29 - i).toDouble(), count.toDouble()));
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.appColors.surface,
        borderRadius: AppShapes.borderRadius,
        border: Border.all(color: context.appColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '近30天次数趋势',
            style: AppText.label.copyWith(
              color: context.appColors.textMuted,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: context.appColors.borderSubtle,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      interval: 7,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < spots.length) {
                          final date = now.subtract(Duration(days: 29 - idx));
                          return Text(
                            '${date.month}/${date.day}',
                            style: AppText.caption.copyWith(fontSize: 10),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: AppText.caption.copyWith(fontSize: 10),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: context.appColors.accent,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 3,
                          color: context.appColors.accent,
                          strokeWidth: 0,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: context.appColors.accent.withOpacity(0.1),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => context.appColors.surfaceElevated,
                    getTooltipItems: (spots) => spots.map((spot) {
                      return LineTooltipItem(
                        '${spot.y.toInt()} 次',
                        AppText.caption.copyWith(color: context.appColors.textPrimary),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
