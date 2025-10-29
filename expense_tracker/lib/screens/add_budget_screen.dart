import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/budget.dart';
import '../services/database_service.dart';
import '../constants/categories.dart';

class AddBudgetScreen extends StatefulWidget {
  final Budget? budget;
  final int month;
  final int year;

  const AddBudgetScreen({
    Key? key,
    this.budget,
    required this.month,
    required this.year,
  }) : super(key: key);

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _dbService = DatabaseService();

  String _selectedCategory = 'Ăn uống';
  bool _alertEnabled = true;
  double _alertThreshold = 80;

  @override
  void initState() {
    super.initState();
    if (widget.budget != null) {
      _selectedCategory = widget.budget!.category;
      _amountController.text = widget.budget!.monthlyLimit.toString();
      _alertEnabled = widget.budget!.alertEnabled;
      _alertThreshold = widget.budget!.alertThreshold;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _saveBudget() async {
    if (_formKey.currentState!.validate()) {
      final budget = Budget(
        id:
            widget.budget?.id ??
            '${_selectedCategory}_${widget.month}_${widget.year}',
        category: _selectedCategory,
        monthlyLimit: double.parse(_amountController.text),
        month: widget.month,
        year: widget.year,
        alertEnabled: _alertEnabled,
        alertThreshold: _alertThreshold,
      );

      if (widget.budget == null) {
        await _dbService.addBudget(budget);
      } else {
        await _dbService.updateBudget(budget);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.budget == null ? 'Thêm ngân sách' : 'Sửa ngân sách'),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _saveBudget),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Tháng ${widget.month}/${widget.year}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Danh mục',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: ExpenseCategories.categories.keys.map((String category) {
                // Kiểm tra xem category đã có ngân sách chưa
                final existingBudget = _dbService.getBudget(
                  category,
                  widget.month,
                  widget.year,
                );
                final hasExisting =
                    existingBudget != null &&
                    existingBudget.id.isNotEmpty &&
                    (widget.budget == null ||
                        widget.budget!.category != category);

                return DropdownMenuItem(
                  value: category,
                  enabled: !hasExisting,
                  child: Row(
                    children: [
                      Icon(
                        ExpenseCategories.categories[category],
                        color: ExpenseCategories.categoryColors[category],
                      ),
                      const SizedBox(width: 10),
                      Text(category),
                      if (hasExisting) ...[
                        const SizedBox(width: 8),
                        const Text(
                          '(Đã có)',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
              onChanged: widget.budget == null
                  ? (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    }
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Ngân sách hàng tháng',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.account_balance_wallet),
                suffix: Text('VNĐ'),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập số tiền';
                }
                if (double.tryParse(value) == null) {
                  return 'Số tiền không hợp lệ';
                }
                if (double.parse(value) <= 0) {
                  return 'Số tiền phải lớn hơn 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Cài đặt cảnh báo',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Bật cảnh báo'),
              subtitle: const Text('Nhận thông báo khi vượt ngưỡng'),
              value: _alertEnabled,
              onChanged: (value) {
                setState(() {
                  _alertEnabled = value;
                });
              },
            ),
            if (_alertEnabled) ...[
              const SizedBox(height: 16),
              Text(
                'Cảnh báo khi đạt ${_alertThreshold.toInt()}%',
                style: const TextStyle(fontSize: 14),
              ),
              Slider(
                value: _alertThreshold,
                min: 50,
                max: 100,
                divisions: 10,
                label: '${_alertThreshold.toInt()}%',
                onChanged: (value) {
                  setState(() {
                    _alertThreshold = value;
                  });
                },
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Bạn sẽ nhận cảnh báo khi chi tiêu đạt ${_alertThreshold.toInt()}% ngân sách',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
