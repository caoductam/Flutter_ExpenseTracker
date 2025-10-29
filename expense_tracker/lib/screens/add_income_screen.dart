import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/income.dart';
import '../services/database_service.dart';
import '../constants/income_categories.dart';

class AddIncomeScreen extends StatefulWidget {
  final Income? income;

  const AddIncomeScreen({Key? key, this.income}) : super(key: key);

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _sourceController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _dbService = DatabaseService();

  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Lương';

  @override
  void initState() {
    super.initState();
    if (widget.income != null) {
      _sourceController.text = widget.income!.source;
      _amountController.text = widget.income!.amount.toString();
      _noteController.text = widget.income!.note ?? '';
      _selectedDate = widget.income!.date;
      _selectedCategory = widget.income!.category;
    }
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveIncome() async {
    if (_formKey.currentState!.validate()) {
      final income = Income(
        id: widget.income?.id ?? DateTime.now().toString(),
        source: _sourceController.text,
        amount: double.parse(_amountController.text),
        date: _selectedDate,
        category: _selectedCategory,
        note: _noteController.text.isEmpty ? null : _noteController.text,
      );

      if (widget.income == null) {
        await _dbService.addIncome(income);
      } else {
        await _dbService.updateIncome(income);
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
        title: Text(widget.income == null ? 'Thêm thu nhập' : 'Sửa thu nhập'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _saveIncome),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _sourceController,
              decoration: const InputDecoration(
                labelText: 'Nguồn thu nhập',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.source),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập nguồn thu nhập';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Số tiền',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
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
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Loại thu nhập',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: IncomeCategories.categories.keys.map((String category) {
                return DropdownMenuItem(
                  value: category,
                  child: Row(
                    children: [
                      Icon(
                        IncomeCategories.categories[category],
                        color: IncomeCategories.categoryColors[category],
                      ),
                      const SizedBox(width: 10),
                      Text(category),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Ngày',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  DateFormat('dd/MM/yyyy').format(_selectedDate),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Ghi chú (tùy chọn)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}
