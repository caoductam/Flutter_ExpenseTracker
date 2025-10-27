import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../services/database_service.dart';
import '../constants/categories.dart';

class StatisticsScreen extends StatelessWidget {
  final _dbService = DatabaseService();

  StatisticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categoryData = _dbService.getExpensesByCategory();
    final totalAmount = _dbService.getTotalAmount();

    return Scaffold(
      appBar: AppBar(title: const Text('Thống kê')),
      body: categoryData.isEmpty
          ? const Center(child: Text('Chưa có dữ liệu thống kê'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'Tổng chi tiêu',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${NumberFormat('#,###').format(totalAmount)} VNĐ',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'Chi tiêu theo danh mục',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 250,
                          child: PieChart(
                            PieChartData(
                              sections: _createPieChartSections(
                                categoryData,
                                totalAmount,
                              ),
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                              borderData: FlBorderData(show: false),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Chi tiết theo danh mục',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...categoryData.entries.map((entry) {
                          final percentage = (entry.value / totalAmount * 100);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Icon(
                                  ExpenseCategories.categories[entry.key],
                                  color: ExpenseCategories
                                      .categoryColors[entry.key],
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry.key,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        '${NumberFormat('#,###').format(entry.value)} VNĐ (${percentage.toStringAsFixed(1)}%)',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  List<PieChartSectionData> _createPieChartSections(
    Map<String, double> categoryData,
    double total,
  ) {
    return categoryData.entries.map((entry) {
      final percentage = (entry.value / total * 100);
      return PieChartSectionData(
        color: ExpenseCategories.categoryColors[entry.key],
        value: entry.value,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }
}
