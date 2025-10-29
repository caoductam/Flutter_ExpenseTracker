import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/income.dart';
import '../services/database_service.dart';
import '../constants/income_categories.dart';
import 'add_income_screen.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({Key? key}) : super(key: key);

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
  final _dbService = DatabaseService();
  List<Income> _incomes = [];

  @override
  void initState() {
    super.initState();
    _loadIncomes();
  }

  void _loadIncomes() {
    setState(() {
      _incomes = _dbService.getAllIncomes();
      _incomes.sort((a, b) => b.date.compareTo(a.date));
    });
  }

  void _deleteIncome(String id) async {
    await _dbService.deleteIncome(id);
    _loadIncomes();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã xóa thu nhập')));
    }
  }

  void _navigateToAddIncome([Income? income]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddIncomeScreen(income: income)),
    );

    if (result == true) {
      _loadIncomes();
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalIncome = _incomes.fold<double>(
      0,
      (sum, income) => sum + income.amount,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thu nhập'),
        // backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade400, Colors.green.shade700],
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'Tổng thu nhập',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  '${NumberFormat('#,###').format(totalIncome)} VNĐ',
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
            child: _incomes.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Chưa có thu nhập nào',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _incomes.length,
                    itemBuilder: (context, index) {
                      final income = _incomes[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: IncomeCategories
                                .categoryColors[income.category],
                            child: Icon(
                              IncomeCategories.categories[income.category],
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            income.source,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(income.category),
                              Text(
                                DateFormat('dd/MM/yyyy').format(income.date),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          trailing: Text(
                            '${NumberFormat('#,###').format(income.amount)} đ',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.green,
                            ),
                          ),
                          onTap: () => _navigateToAddIncome(income),
                          onLongPress: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Xóa thu nhập'),
                                content: const Text(
                                  'Bạn có chắc muốn xóa thu nhập này?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Hủy'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _deleteIncome(income.id);
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddIncome(),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
}
