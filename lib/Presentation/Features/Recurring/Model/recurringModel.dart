import 'package:cloud_firestore/cloud_firestore.dart';
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
  final String type; // Expense / Income / Lent / Borrow
  @HiveField(4)
  final String wallet;
  @HiveField(5)
  final String note;
  @HiveField(6)
  final String frequency; // Daily / Weekly / Monthly / One-time (Scheduled)
  @HiveField(7)
  final String lastExecutedMonthKey; 
  @HiveField(8)
  final bool isActive;
  @HiveField(9)
  final DateTime? nextExecutionDate; // Used for Scheduled or next run

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
    this.nextExecutionDate,
  });

  factory RecurringModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RecurringModel(
      id: doc.id,
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      category: data['category'] ?? '',
      type: data['type'] ?? 'Expense',
      wallet: data['wallet'] ?? 'Cash',
      note: data['note'] ?? '',
      frequency: data['frequency'] ?? 'Monthly',
      lastExecutedMonthKey: data['lastExecutedMonthKey'] ?? '',
      isActive: data['isActive'] ?? true,
      nextExecutionDate: data['nextExecutionDate'] != null 
          ? (data['nextExecutionDate'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'category': category,
      'type': type,
      'wallet': wallet,
      'note': note,
      'frequency': frequency,
      'lastExecutedMonthKey': lastExecutedMonthKey,
      'isActive': isActive,
      'nextExecutionDate': nextExecutionDate != null ? Timestamp.fromDate(nextExecutionDate!) : null,
    };
  }

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
    DateTime? nextExecutionDate,
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
      nextExecutionDate: nextExecutionDate ?? this.nextExecutionDate,
    );
  }
}
