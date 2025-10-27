import 'package:flutter/material.dart';

class ExpenseCategories {
  static const Map<String, IconData> categories = {
    'Ăn uống': Icons.restaurant,
    'Đi lại': Icons.directions_car,
    'Mua sắm': Icons.shopping_cart,
    'Giải trí': Icons.movie,
    'Sức khỏe': Icons.medical_services,
    'Giáo dục': Icons.school,
    'Hóa đơn': Icons.receipt,
    'Khác': Icons.more_horiz,
  };

  static const Map<String, Color> categoryColors = {
    'Ăn uống': Colors.orange,
    'Đi lại': Colors.blue,
    'Mua sắm': Colors.pink,
    'Giải trí': Colors.purple,
    'Sức khỏe': Colors.red,
    'Giáo dục': Colors.green,
    'Hóa đơn': Colors.brown,
    'Khác': Colors.grey,
  };
}
