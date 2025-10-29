import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/budget.dart';
import '../services/database_service.dart';
import '../constants/categories.dart';
import 'add_budget_screen.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({Key? key}) : super(key: key);

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _dbService = DatabaseService();
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  List<Budget> _budgets = [];

  @override
  void initState() {
    super.initState();
    _loadBudgets();
  }

  void _loadBudgets() {
    setState(() {
      _budgets = _dbService.getBudgetsByMonth(_selectedMonth, _selectedYear);
    });
  }

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
      _loadBudgets();
    });
  }

  void _navigateToAddBudget([Budget? budget]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddBudgetScreen(
          budget: budget,
          month: _selectedMonth,
          year: _selectedYear,
        ),
      ),
    );

    if (result == true) {
      _loadBudgets();
    }
  }

  void _deleteBudget(String id) async {
    await _dbService.deleteBudget(id);
    _loadBudgets();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã xóa ngân sách')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tính tổng ngân sách và đã chi
    double totalBudget = _budgets.fold(0, (sum, b) => sum + b.monthlyLimit);
    double totalSpent = 0;
    for (var budget in _budgets) {
      totalSpent += _dbService.getSpentAmount(
        budget.category,
        _selectedMonth,
        _selectedYear,
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý ngân sách')),
      body: Column(
        children: [
          // Month selector
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
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

          // Summary card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tổng ngân sách',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            '${NumberFormat('#,###').format(totalBudget)} đ',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Đã chi',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            '${NumberFormat('#,###').format(totalSpent)} đ',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: totalBudget > 0 ? (totalSpent / totalBudget) : 0,
                    backgroundColor: Colors.grey[300],
                    color: totalSpent > totalBudget ? Colors.red : Colors.blue,
                    minHeight: 10,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    totalBudget > 0
                        ? 'Còn lại: ${NumberFormat('#,###').format(totalBudget - totalSpent)} đ'
                        : 'Chưa có ngân sách',
                    style: TextStyle(
                      color: totalSpent > totalBudget
                          ? Colors.red
                          : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Budget list
          Expanded(
            child: _budgets.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Chưa có ngân sách cho tháng này',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () => _navigateToAddBudget(),
                          icon: const Icon(Icons.add),
                          label: const Text('Thêm ngân sách'),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _budgets.length,
                    itemBuilder: (context, index) {
                      final budget = _budgets[index];
                      final spent = _dbService.getSpentAmount(
                        budget.category,
                        _selectedMonth,
                        _selectedYear,
                      );
                      final percentage = budget.monthlyLimit > 0
                          ? (spent / budget.monthlyLimit * 100)
                          : 0;
                      final isExceeded = spent > budget.monthlyLimit;
                      final shouldAlert = percentage >= budget.alertThreshold;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () => _navigateToAddBudget(budget),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      ExpenseCategories.categories[budget
                                          .category],
                                      color: ExpenseCategories
                                          .categoryColors[budget.category],
                                      size: 28,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                budget.category,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              if (shouldAlert) ...[
                                                const SizedBox(width: 8),
                                                Icon(
                                                  Icons.warning,
                                                  color: isExceeded
                                                      ? Colors.red
                                                      : Colors.orange,
                                                  size: 20,
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${NumberFormat('#,###').format(spent)} / ${NumberFormat('#,###').format(budget.monthlyLimit)} đ',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Xóa ngân sách'),
                                            content: const Text(
                                              'Bạn có chắc muốn xóa ngân sách này?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text('Hủy'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  _deleteBudget(budget.id);
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Xóa'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                LinearProgressIndicator(
                                  value: percentage / 100,
                                  backgroundColor: Colors.grey[300],
                                  color: isExceeded
                                      ? Colors.red
                                      : shouldAlert
                                      ? Colors.orange
                                      : Colors.green,
                                  minHeight: 8,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${percentage.toStringAsFixed(1)}% đã sử dụng',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isExceeded
                                            ? Colors.red
                                            : Colors.grey[600],
                                        fontWeight: isExceeded
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    Text(
                                      isExceeded
                                          ? 'Vượt ${NumberFormat('#,###').format(spent - budget.monthlyLimit)} đ'
                                          : 'Còn ${NumberFormat('#,###').format(budget.monthlyLimit - spent)} đ',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isExceeded
                                            ? Colors.red
                                            : Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddBudget(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
