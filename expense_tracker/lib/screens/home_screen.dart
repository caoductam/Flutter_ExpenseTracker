import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../services/database_service.dart';
import '../constants/categories.dart';
import 'add_expense_screen.dart';
import 'statistics_screen.dart';
import 'budget_screen.dart';
import 'search_screen.dart';
import 'income_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _dbService = DatabaseService();
  List<Expense> _expenses = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  void _loadExpenses() {
    setState(() {
      _expenses = _dbService.getAllExpenses();
      _expenses.sort((a, b) => b.date.compareTo(a.date));
    });
  }

  void _deleteExpense(String id) async {
    await _dbService.deleteExpense(id);
    _loadExpenses();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã xóa chi tiêu')));
    }
  }

  void _navigateToAddExpense([Expense? expense]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExpenseScreen(expense: expense),
      ),
    );

    if (result == true) {
      _loadExpenses();
    }
  }

  Widget _buildExpenseTab() {
    final totalAmount = _expenses.fold<double>(
      0,
      (sum, expense) => sum + expense.amount,
    );

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade400, Colors.blue.shade700],
            ),
          ),
          child: Column(
            children: [
              const Text(
                'Tổng chi tiêu',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                '${NumberFormat('#,###').format(totalAmount)} VNĐ',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _expenses.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Chưa có chi tiêu nào',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _expenses.length,
                  itemBuilder: (context, index) {
                    final expense = _expenses[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: ExpenseCategories
                              .categoryColors[expense.category],
                          child: Icon(
                            ExpenseCategories.categories[expense.category],
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          expense.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(expense.category),
                            Text(
                              DateFormat('dd/MM/yyyy').format(expense.date),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        trailing: Text(
                          '${NumberFormat('#,###').format(expense.amount)} đ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.red,
                          ),
                        ),
                        onTap: () => _navigateToAddExpense(expense),
                        onLongPress: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Xóa chi tiêu'),
                              content: const Text(
                                'Bạn có chắc muốn xóa chi tiêu này?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Hủy'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    _deleteExpense(expense.id);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Xóa'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildExpenseTab();
      case 1:
        return const BudgetScreen();
      case 2:
        return StatisticsScreen();
      case 3:
        return const SearchScreen();
      case 4:
        return const IncomeScreen();
      default:
        return _buildExpenseTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expense Tracker App')),
      body: _buildBody(),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () => _navigateToAddExpense(),
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Chi tiêu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Ngân sách',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Thống kê',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Tìm kiếm'),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Thu nhập',
          ),
        ],
      ),
    );
  }
}
