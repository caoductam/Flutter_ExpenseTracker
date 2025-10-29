import 'package:flutter/material.dart';

class IncomeCategories {
  static const Map<String, IconData> categories = {
    'Lương': Icons.work,
    'Thưởng': Icons.card_giftcard,
    'Đầu tư': Icons.trending_up,
    'Kinh doanh': Icons.business,
    'Freelance': Icons.laptop,
    'Cho thuê': Icons.home,
    'Lãi ngân hàng': Icons.account_balance,
    'Khác': Icons.more_horiz,
  };

  static const Map<String, Color> categoryColors = {
    'Lương': Colors.blue,
    'Thưởng': Colors.purple,
    'Đầu tư': Colors.green,
    'Kinh doanh': Colors.orange,
    'Freelance': Colors.teal,
    'Cho thuê': Colors.indigo,
    'Lãi ngân hàng': Colors.cyan,
    'Khác': Colors.grey,
  };
}
