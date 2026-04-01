import 'package:hive/hive.dart';

part 'recurringModel.g.dart';

@HiveType(typeId: 3)
class RecurringModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final double amount;
  @HiveField(2)
  final String category;
  @HiveField(3)
  final String type; // Expense / Income
  @HiveField(4)
  final String wallet;
  @HiveField(5)
  final String note;
  @HiveField(6)
  final String frequency; // Daily / Weekly / Monthly
  @HiveField(7)
  final String lastExecutedMonthKey; // "2024-05"
  @HiveField(8)
  final bool isActive;

  RecurringModel({
    required this.id,
    required this.amount,
    required this.category,
    required this.type,
    required this.wallet,
    required this.note,
    required this.frequency,
    required this.lastExecutedMonthKey,
    this.isActive = true,
  });

  RecurringModel copyWith({
    String? id,
    double? amount,
    String? category,
    String? type,
    String? wallet,
    String? note,
    String? frequency,
    String? lastExecutedMonthKey,
    bool? isActive,
  }) {
    return RecurringModel(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      type: type ?? this.type,
      wallet: wallet ?? this.wallet,
      note: note ?? this.note,
      frequency: frequency ?? this.frequency,
      lastExecutedMonthKey: lastExecutedMonthKey ?? this.lastExecutedMonthKey,
      isActive: isActive ?? this.isActive,
    );
  }
}
