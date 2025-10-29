import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/database_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _dbService = DatabaseService();
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth += delta;
      if (_selectedMonth > 12) {
        _selectedMonth = 1;
        _selectedYear++;
      } else if (_selectedMonth < 1) {
        _selectedMonth = 12;
        _selectedYear--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Dữ liệu tháng hiện tại
    final monthIncome = _dbService.getTotalIncomeByMonth(
      _selectedMonth,
      _selectedYear,
    );
    final monthExpense = _dbService.getTotalExpenseByMonth(
      _selectedMonth,
      _selectedYear,
    );
    final monthBalance = monthIncome - monthExpense;

    // Dữ liệu tổng
    final totalIncome = _dbService.getTotalIncome();
    final totalExpense = _dbService.getTotalAmount();
    final totalBalance = totalIncome - totalExpense;

    // Dữ liệu 6 tháng gần nhất
    final monthlyComparison = _dbService.getMonthlyComparison(6);

    return Scaffold(
      appBar: AppBar(title: const Text('Tổng quan tài chính')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Month selector
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => _changeMonth(-1),
                  ),
                  Text(
                    'Tháng $_selectedMonth/$_selectedYear',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () => _changeMonth(1),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Balance Card tháng hiện tại
          Card(
            elevation: 4,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: monthBalance >= 0
                      ? [Colors.green.shade400, Colors.green.shade700]
                      : [Colors.red.shade400, Colors.red.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Số dư tháng này',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${NumberFormat('#,###').format(monthBalance)} VNĐ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Colors.white54),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Icon(Icons.arrow_downward, color: Colors.white),
                          const SizedBox(height: 8),
                          const Text(
                            'Thu nhập',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${NumberFormat('#,###').format(monthIncome)} đ',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(height: 50, width: 1, color: Colors.white54),
                      Column(
                        children: [
                          const Icon(Icons.arrow_upward, color: Colors.white),
                          const SizedBox(height: 8),
                          const Text(
                            'Chi tiêu',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${NumberFormat('#,###').format(monthExpense)} đ',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Tổng quan toàn bộ
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tổng quan toàn bộ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryRow(
                    'Tổng thu nhập',
                    totalIncome,
                    Colors.green,
                    Icons.trending_up,
                  ),
                  const Divider(height: 24),
                  _buildSummaryRow(
                    'Tổng chi tiêu',
                    totalExpense,
                    Colors.red,
                    Icons.trending_down,
                  ),
                  const Divider(height: 24),
                  _buildSummaryRow(
                    'Tổng số dư',
                    totalBalance,
                    totalBalance >= 0 ? Colors.green : Colors.red,
                    Icons.account_balance_wallet,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Biểu đồ cột 6 tháng
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Xu hướng 6 tháng gần nhất',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 250,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: _getMaxValue(monthlyComparison) * 1.2,
                        minY: _getMinValue(monthlyComparison) * 1.2,
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final monthKey = monthlyComparison.keys
                                  .toList()
                                  .reversed
                                  .toList()[group.x.toInt()];
                              return BarTooltipItem(
                                '$monthKey\n${NumberFormat('#,###').format(rod.toY)} đ',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final monthKey = monthlyComparison.keys
                                    .toList()
                                    .reversed
                                    .toList()[value.toInt()];
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    monthKey,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 50,
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  NumberFormat.compact().format(value),
                                  style: const TextStyle(fontSize: 10),
                                );
                              },
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval:
                              _getMaxValue(monthlyComparison) / 5,
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: _createBarGroups(monthlyComparison),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegend(Colors.green, 'Dương'),
                      const SizedBox(width: 20),
                      _buildLegend(Colors.red, 'Âm'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String title,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                '${NumberFormat('#,###').format(amount)} VNĐ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }

  List<BarChartGroupData> _createBarGroups(Map<String, double> data) {
    final sortedKeys = data.keys.toList().reversed.toList();
    return List.generate(sortedKeys.length, (index) {
      final value = data[sortedKeys[index]]!;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value,
            color: value >= 0 ? Colors.green : Colors.red,
            width: 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }

  double _getMaxValue(Map<String, double> data) {
    if (data.isEmpty) return 1000000;
    final max = data.values.reduce((a, b) => a > b ? a : b);
    return max > 0 ? max : 1000000;
  }

  double _getMinValue(Map<String, double> data) {
    if (data.isEmpty) return 0;
    final min = data.values.reduce((a, b) => a < b ? a : b);
    return min < 0 ? min : 0;
  }
}
