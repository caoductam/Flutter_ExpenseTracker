import 'package:hive/hive.dart';

part 'budget.g.dart';

@HiveType(typeId: 1)
class Budget extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String category;

  @HiveField(2)
  late double monthlyLimit;

  @HiveField(3)
  late int month;

  @HiveField(4)
  late int year;

  @HiveField(5)
  late bool alertEnabled;

  @HiveField(6)
  late double alertThreshold; // % để cảnh báo (vd: 80 = cảnh báo khi đạt 80%)

  Budget({
    required this.id,
    required this.category,
    required this.monthlyLimit,
    required this.month,
    required this.year,
    this.alertEnabled = true,
    this.alertThreshold = 80,
  });
}
