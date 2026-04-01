import 'package:hive/hive.dart';

part 'budgetModel.g.dart';

@HiveType(typeId: 6)
class BudgetModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String category;

  @HiveField(2)
  double amount; // The limit

  @HiveField(3)
  final String monthKey; // e.g. "2024-04"

  BudgetModel({
    required this.id,
    required this.category,
    required this.amount,
    required this.monthKey,
  });
}
