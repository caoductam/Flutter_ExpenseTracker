import 'package:hive/hive.dart';

part 'income.g.dart';

@HiveType(typeId: 2)
class Income extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String source; // Nguồn thu nhập

  @HiveField(2)
  late double amount;

  @HiveField(3)
  late DateTime date;

  @HiveField(4)
  late String category; // Loại thu nhập

  @HiveField(5)
  String? note;

  Income({
    required this.id,
    required this.source,
    required this.amount,
    required this.date,
    required this.category,
    this.note,
  });
}
