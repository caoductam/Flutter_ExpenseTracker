import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../services/database_service.dart';
import '../constants/categories.dart';
import 'add_expense_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _dbService = DatabaseService();
  final _searchController = TextEditingController();

  List<Expense> _filteredExpenses = [];
  String? _selectedCategory;
  DateTime? _startDate;
  DateTime? _endDate;
  double? _minAmount;
  double? _maxAmount;

  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _searchExpenses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchExpenses() {
    setState(() {
      _filteredExpenses = _dbService.filterByMultipleCriteria(
        searchQuery: _searchController.text,
        category: _selectedCategory,
        startDate: _startDate,
        endDate: _endDate,
        minAmount: _minAmount,
        maxAmount: _maxAmount,
      );
      _filteredExpenses.sort((a, b) => b.date.compareTo(a.date));
    });
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategory = null;
      _startDate = null;
      _endDate = null;
      _minAmount = null;
      _maxAmount = null;
      _searchExpenses();
    });
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _searchExpenses();
      });
    }
  }

  void _showAmountRangeDialog() {
    final minController = TextEditingController(
      text: _minAmount?.toString() ?? '',
    );
    final maxController = TextEditingController(
      text: _maxAmount?.toString() ?? '',
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Khoảng giá'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: minController,
              decoration: const InputDecoration(
                labelText: 'Từ',
                prefixIcon: Icon(Icons.attach_money),
                suffix: Text('VNĐ'),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: maxController,
              decoration: const InputDecoration(
                labelText: 'Đến',
                prefixIcon: Icon(Icons.attach_money),
                suffix: Text('VNĐ'),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _minAmount = double.tryParse(minController.text);
                _maxAmount = double.tryParse(maxController.text);
                _searchExpenses();
              });
              Navigator.pop(context);
            },
            child: const Text('Áp dụng'),
          ),
        ],
      ),
    );
  }

  int get _activeFilterCount {
    int count = 0;
    if (_selectedCategory != null) count++;
    if (_startDate != null || _endDate != null) count++;
    if (_minAmount != null || _maxAmount != null) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = _filteredExpenses.fold<double>(
      0,
      (sum, expense) => sum + expense.amount,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm kiếm chi tiêu'),
        actions: [
          if (_activeFilterCount > 0)
            IconButton(
              icon: const Icon(Icons.clear_all),
              tooltip: 'Xóa bộ lọc',
              onPressed: _clearFilters,
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tên, danh mục...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _searchExpenses();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => _searchExpenses(),
            ),
          ),

          // Filter toggle button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _showFilters = !_showFilters;
                      });
                    },
                    icon: Icon(
                      _showFilters ? Icons.filter_alt_off : Icons.filter_alt,
                    ),
                    label: Text(
                      _activeFilterCount > 0
                          ? 'Bộ lọc ($_activeFilterCount)'
                          : 'Bộ lọc',
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filters section
          if (_showFilters) ...[
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lọc theo:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),

                  // Category filter
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Danh mục',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Tất cả'),
                      ),
                      ...ExpenseCategories.categories.keys.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Row(
                            children: [
                              Icon(
                                ExpenseCategories.categories[category],
                                size: 20,
                                color:
                                    ExpenseCategories.categoryColors[category],
                              ),
                              const SizedBox(width: 8),
                              Text(category),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                        _searchExpenses();
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  // Date range filter
                  OutlinedButton.icon(
                    onPressed: _selectDateRange,
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      _startDate != null && _endDate != null
                          ? '${DateFormat('dd/MM/yyyy').format(_startDate!)} - ${DateFormat('dd/MM/yyyy').format(_endDate!)}'
                          : 'Chọn khoảng thời gian',
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  if (_startDate != null || _endDate != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _startDate = null;
                            _endDate = null;
                            _searchExpenses();
                          });
                        },
                        child: const Text('Xóa'),
                      ),
                    ),
                  const SizedBox(height: 12),

                  // Amount range filter
                  OutlinedButton.icon(
                    onPressed: _showAmountRangeDialog,
                    icon: const Icon(Icons.attach_money),
                    label: Text(
                      _minAmount != null || _maxAmount != null
                          ? '${_minAmount != null ? NumberFormat('#,###').format(_minAmount) : '0'} - ${_maxAmount != null ? NumberFormat('#,###').format(_maxAmount) : '∞'} đ'
                          : 'Chọn khoảng giá',
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                  if (_minAmount != null || _maxAmount != null)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _minAmount = null;
                            _maxAmount = null;
                            _searchExpenses();
                          });
                        },
                        child: const Text('Xóa'),
                      ),
                    ),
                ],
              ),
            ),
          ],

          // Results summary
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tìm thấy ${_filteredExpenses.length} kết quả',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Tổng: ${NumberFormat('#,###').format(totalAmount)} đ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Results list
          Expanded(
            child: _filteredExpenses.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Không tìm thấy kết quả',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredExpenses.length,
                    itemBuilder: (context, index) {
                      final expense = _filteredExpenses[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
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
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddExpenseScreen(expense: expense),
                              ),
                            );
                            if (result == true) {
                              _searchExpenses();
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
