import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense.dart';
import '../models/budget.dart';
import '../models/income.dart';
import 'package:intl/intl.dart';

class DatabaseService {
  static const String boxName = 'expenses';
  static const String budgetBoxName = 'budgets';
  static const String incomeBoxName = 'incomes'; // Thêm box income

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ExpenseAdapter());
    Hive.registerAdapter(BudgetAdapter());
    Hive.registerAdapter(IncomeAdapter());
    await Hive.openBox<Expense>(boxName);
    await Hive.openBox<Budget>(budgetBoxName);
    await Hive.openBox<Income>(incomeBoxName);
  }

  // Budget methods
  Box<Budget> getBudgetBox() {
    return Hive.box<Budget>(budgetBoxName);
  }

  Future<void> addBudget(Budget budget) async {
    final box = getBudgetBox();
    await box.put(budget.id, budget);
  }

  Future<void> updateBudget(Budget budget) async {
    final box = getBudgetBox();
    await box.put(budget.id, budget);
  }

  Future<void> deleteBudget(String id) async {
    final box = getBudgetBox();
    await box.delete(id);
  }

  Budget? getBudget(String category, int month, int year) {
    final box = getBudgetBox();
    return box.values.firstWhere(
      (b) => b.category == category && b.month == month && b.year == year,
      orElse: () => Budget(
        id: '',
        category: category,
        monthlyLimit: 0,
        month: month,
        year: year,
      ),
    );
  }

  List<Expense> getAllExpenses() {
    final box = Hive.box<Expense>(boxName);
    return box.values.toList();
  }

  List<Budget> getAllBudgets() {
    final box = getBudgetBox();
    return box.values.toList();
  }

  List<Budget> getBudgetsByMonth(int month, int year) {
    final budgets = getAllBudgets();
    return budgets.where((b) => b.month == month && b.year == year).toList();
  }

  // Expense by month and category
  List<Expense> getExpensesByMonthAndCategory(
    int month,
    int year,
    String category,
  ) {
    final expenses = getAllExpenses();
    return expenses.where((expense) {
      return expense.date.month == month &&
          expense.date.year == year &&
          expense.category == category;
    }).toList();
  }

  double getSpentAmount(String category, int month, int year) {
    final expenses = getExpensesByMonthAndCategory(month, year, category);
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  double getRemainingBudget(String category, int month, int year) {
    final budget = getBudget(category, month, year);
    if (budget == null || budget.id.isEmpty) return 0;

    final spent = getSpentAmount(category, month, year);
    return budget.monthlyLimit - spent;
  }

  bool isBudgetExceeded(String category, int month, int year) {
    return getRemainingBudget(category, month, year) < 0;
  }

  double getBudgetUsagePercentage(String category, int month, int year) {
    final budget = getBudget(category, month, year);
    if (budget == null || budget.id.isEmpty || budget.monthlyLimit == 0)
      return 0;

    final spent = getSpentAmount(category, month, year);
    return (spent / budget.monthlyLimit * 100).clamp(0, 100);
  }

  bool shouldShowAlert(String category, int month, int year) {
    final budget = getBudget(category, month, year);
    if (budget == null || budget.id.isEmpty || !budget.alertEnabled)
      return false;

    final percentage = getBudgetUsagePercentage(category, month, year);
    return percentage >= budget.alertThreshold;
  }

  // Thêm vào trong class DatabaseService

  Box<Expense> getExpenseBox() {
    return Hive.box<Expense>(boxName);
  }

  Future<void> addExpense(Expense expense) async {
    final box = getExpenseBox();
    await box.put(expense.id, expense);
  }

  Future<void> updateExpense(Expense expense) async {
    final box = getExpenseBox();
    await box.put(expense.id, expense);
  }

  Future<void> deleteExpense(String id) async {
    final box = getExpenseBox();
    await box.delete(id);
  }

  // Trả về tổng số tiền đã chi tiêu
  double getTotalAmount() {
    final expenses = getAllExpenses();
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }

  // Trả về map: {category: tổng tiền của category đó}
  Map<String, double> getExpensesByCategory() {
    final expenses = getAllExpenses();
    final Map<String, double> data = {};
    for (var expense in expenses) {
      data[expense.category] = (data[expense.category] ?? 0) + expense.amount;
    }
    return data;
  }

  // Search and filter methods
  List<Expense> searchExpenses(String query) {
    if (query.isEmpty) return getAllExpenses();

    final expenses = getAllExpenses();
    final lowerQuery = query.toLowerCase();

    return expenses.where((expense) {
      return expense.title.toLowerCase().contains(lowerQuery) ||
          expense.category.toLowerCase().contains(lowerQuery) ||
          (expense.note?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  List<Expense> filterByCategory(String category) {
    final expenses = getAllExpenses();
    return expenses.where((e) => e.category == category).toList();
  }

  List<Expense> filterByAmountRange(double min, double max) {
    final expenses = getAllExpenses();
    return expenses.where((e) => e.amount >= min && e.amount <= max).toList();
  }

  List<Expense> filterByMultipleCriteria({
    String? searchQuery,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
  }) {
    var expenses = getAllExpenses();

    // Search query
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final lowerQuery = searchQuery.toLowerCase();
      expenses = expenses.where((e) {
        return e.title.toLowerCase().contains(lowerQuery) ||
            e.category.toLowerCase().contains(lowerQuery) ||
            (e.note?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();
    }

    // Category filter
    if (category != null && category.isNotEmpty) {
      expenses = expenses.where((e) => e.category == category).toList();
    }

    // Date range filter
    if (startDate != null) {
      expenses = expenses
          .where(
            (e) => e.date.isAfter(startDate.subtract(const Duration(days: 1))),
          )
          .toList();
    }
    if (endDate != null) {
      expenses = expenses
          .where((e) => e.date.isBefore(endDate.add(const Duration(days: 1))))
          .toList();
    }

    // Amount range filter
    if (minAmount != null) {
      expenses = expenses.where((e) => e.amount >= minAmount).toList();
    }
    if (maxAmount != null) {
      expenses = expenses.where((e) => e.amount <= maxAmount).toList();
    }

    return expenses;
  }

  // ========== INCOME METHODS ==========

  Box<Income> getIncomeBox() {
    return Hive.box<Income>(incomeBoxName);
  }

  Future<void> addIncome(Income income) async {
    final box = getIncomeBox();
    await box.put(income.id, income);
  }

  Future<void> deleteIncome(String id) async {
    final box = getIncomeBox();
    await box.delete(id);
  }

  Future<void> updateIncome(Income income) async {
    final box = getIncomeBox();
    await box.put(income.id, income);
  }

  List<Income> getAllIncomes() {
    final box = getIncomeBox();
    return box.values.toList();
  }

  List<Income> getIncomesByDateRange(DateTime start, DateTime end) {
    final incomes = getAllIncomes();
    return incomes.where((income) {
      return income.date.isAfter(start.subtract(const Duration(days: 1))) &&
          income.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  List<Income> getIncomesByMonth(int month, int year) {
    final incomes = getAllIncomes();
    return incomes.where((income) {
      return income.date.month == month && income.date.year == year;
    }).toList();
  }

  double getTotalIncome() {
    final incomes = getAllIncomes();
    return incomes.fold(0, (sum, income) => sum + income.amount);
  }

  double getTotalIncomeByMonth(int month, int year) {
    final incomes = getIncomesByMonth(month, year);
    return incomes.fold(0, (sum, income) => sum + income.amount);
  }

  Map<String, double> getIncomesByCategory() {
    final incomes = getAllIncomes();
    Map<String, double> categoryTotals = {};

    for (var income in incomes) {
      categoryTotals[income.category] =
          (categoryTotals[income.category] ?? 0) + income.amount;
    }

    return categoryTotals;
  }

  // ========== BALANCE METHODS ==========

  double getBalance() {
    return getTotalIncome() - getTotalAmount();
  }

  double getBalanceByMonth(int month, int year) {
    final income = getTotalIncomeByMonth(month, year);
    final expenses = getExpensesByMonthAndCategory(month, year, '');
    final expense = expenses.fold<double>(0, (sum, e) => sum + e.amount);
    return income - expense;
  }

  // Statistics cho dashboard
  Map<String, double> getMonthlyComparison(int months) {
    Map<String, double> comparison = {};
    final now = DateTime.now();

    for (int i = 0; i < months; i++) {
      final targetDate = DateTime(now.year, now.month - i, 1);
      final monthKey = DateFormat('MM/yyyy').format(targetDate);

      final monthIncome = getTotalIncomeByMonth(
        targetDate.month,
        targetDate.year,
      );
      final monthExpenses = getExpensesByMonth(
        targetDate.month,
        targetDate.year,
      ).fold<double>(0, (sum, e) => sum + e.amount);

      comparison[monthKey] = monthIncome - monthExpenses;
    }

    return comparison;
  }

  List<Expense> getExpensesByMonth(int month, int year) {
    final expenses = getAllExpenses();
    return expenses.where((expense) {
      return expense.date.month == month && expense.date.year == year;
    }).toList();
  }

  double getTotalExpenseByMonth(int month, int year) {
    final expenses = getExpensesByMonth(month, year);
    return expenses.fold(0, (sum, expense) => sum + expense.amount);
  }
}
