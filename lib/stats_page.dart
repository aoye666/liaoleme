import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
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
    final records = await _db.getRecentCheckins(90);
    setState(() {
      _records = records;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          '数据统计',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(),
                  const SizedBox(height: 16),
                  _buildHeatmapCard(),
                  const SizedBox(height: 16),
                  _buildLineChartCard(),
                ],
            ),
          ),
    );
    }

  // 统计卡片
  Widget _buildSummaryCard() {
    final totalDays = _records.length;
    final noCount = _records.where((r) => r['result'] == '不撸').length;
    final yesCount = _records.where((r) => r['result'] == '撸').length;
    final totalTimes = _records.fold<int>(0, (sum, r) => sum + (r['count'] as int? ?? 0));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '近90天总览',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('天数', '$totalDays'),
              _buildStatItem('不撸', '$noCount'),
              _buildStatItem('撸', '$yesCount'),
              _buildStatItem('总次数', '$totalTimes'),
            ],
          ),
          if (totalDays > 0) ...[
            const SizedBox(height: 16),
            Text(
              '克制率: ${(noCount / totalDays * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
      ],
    );
  }

  // 热力图卡片
  Widget _buildHeatmapCard() {
    return Container(
      width: double.infinity,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'GitHub 风格热力图',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '近90天打卡记录  ·  颜色深浅表示次数',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
          const SizedBox(height: 16),
          _buildHeatmapGrid(),
          const SizedBox(height: 12),
          _buildHeatmapLegend(),
        ],
      ),
    );
  }

  Widget _buildHeatmapGrid() {
    final DateTime now = DateTime.now();

    // 日期 → 记录映射
    final Map<String, Map<String, dynamic>> recordMap = {
      for (var r in _records) r['date'] as String: r
    };

    // 生成近90天的格子（周一至周日排列）
    final List<Widget> cells = [];
    final DateTime startDate = now.subtract(const Duration(days: 89));

    // 补前列空白（对齐到周一）
    final int startWeekday = startDate.weekday;
    for (int i = 1; i < startWeekday; i++) {
      cells.add(const SizedBox(width: 18, height: 18));
    }

    // 补实际日期格子
    for (int i = 0; i < 90; i++) {
      final DateTime date = startDate.add(Duration(days: i));
      final String dateStr = _formatDate(date);
      final record = recordMap[dateStr];

      Color cellColor;
      bool isToday = dateStr == _formatDate(now);

      if (record != null) {
        final count = (record['count'] as int?) ?? 0;
        final result = record['result'] as String;
        if (result == '不撸') {
          cellColor = count == 0 ? Colors.grey[300]! : Colors.green[300]!;
        } else {
          cellColor = count == 0 ? Colors.grey[400]! : Colors.red[200]!;
        }
      } else if (date.isAfter(now)) {
        cellColor = Colors.transparent;
      } else {
        cellColor = Colors.grey[200]!;
      }

      cells.add(
        Tooltip(
          message: record != null
              ? '$dateStr | ${record['result']} | 次数:${(record['count'] as int?) ?? 0}'
              : dateStr,
          child: Container(
            width: 18,
            height: 18,
            margin: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: cellColor,
              borderRadius: BorderRadius.circular(4),
              border: isToday
                  ? Border.all(color: Colors.black, width: 2)
                  : Border.all(color: Colors.black.withOpacity(0.08)),
            ),
          ),
        ),
      );
    }

    return Wrap(
      children: cells.map((w) => SizedBox(width: 22, height: 22, child: w)).toList(),
    );
  }

  Widget _buildHeatmapLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('少 ', style: TextStyle(fontSize: 10, color: Colors.grey)),
        ..._buildLegendCell(Colors.grey[200]!),
        ..._buildLegendCell(Colors.grey[300]!),
        ..._buildLegendCell(Colors.green[300]!),
        ..._buildLegendCell(Colors.red[200]!),
        const Text(' 多', style: TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  List<Widget> _buildLegendCell(Color color) {
    return [
      Container(
        width: 14,
        height: 14,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    ];
  }

  // 折线图卡片
  Widget _buildLineChartCard() {
    final spots = _buildLineChartSpots();

    return Container(
      width: double.infinity,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '近30天趋势',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '每日次数变化',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: spots.isEmpty
                ? Center(child: Text('暂无数据', style: TextStyle(color: Colors.grey)))
                : _buildLineChart(spots),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _buildLineChartSpots() {
    if (_records.isEmpty) return [];

    final spots = <FlSpot>[];
    final now = DateTime.now();
    final Map<String, Map<String, dynamic>> recordMap = {
      for (var r in _records) r['date'] as String: r
    };

    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = _formatDate(date);
      final record = recordMap[dateStr];
      final count = (record?['count'] as int?) ?? 0;
      spots.add(FlSpot((29 - i).toDouble(), count.toDouble()));
    }

    return spots;
  }

  Widget _buildLineChart(List<FlSpot> spots) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey[200]!,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 30,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: TextStyle(fontSize: 10, color: Colors.grey[500]),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 5,
              getTitlesWidget: (value, meta) {
                if (value.toInt() % 5 == 0 && value.toInt() < 30) {
                  final date = DateTime.now().subtract(Duration(days: 29 - value.toInt()));
                  return Text(
                    DateFormat('M/d').format(date),
                    style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.black,
            barWidth: 2,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                radius: 3,
                color: Colors.black,
                strokeWidth: 0,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.black.withOpacity(0.05),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
