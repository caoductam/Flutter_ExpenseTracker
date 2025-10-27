import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense.dart';

class DatabaseService {
  static const String boxName = 'expenses';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ExpenseAdapter());
    await Hive.openBox<Expense>(boxName);
  }

  Box<Expense> getBox() {
    return Hive.box<Expense>(boxName);
  }

  Future<void> addExpense(Expense expense) async {
    final box = getBox();
    await box.put(expense.id, expense);
  }

  Future<void> deleteExpense(String id) async {
    final box = getBox();
    await box.delete(id);
  }

  Future<void> updateExpense(Expense expense) async {
    final box = getBox();
    await box.put(expense.id, expense);
  }

  List<Expense> getAllExpenses() {
    final box = getBox();
    return box.values.toList();
  }

  List<Expense> getExpensesByDateRange(DateTime start, DateTime end) {
    final expenses = getAllExpenses();
    return expenses.where((expense) {
      return expense.date.isAfter(start.subtract(const Duration(days: 1))) &&
          expense.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  double getTotalAmount() {
    final expenses = getAllExpenses();
    return expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  Map<String, double> getExpensesByCategory() {
    final expenses = getAllExpenses();
    Map<String, double> categoryTotals = {};

    for (var expense in expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    return categoryTotals;
  }
}
