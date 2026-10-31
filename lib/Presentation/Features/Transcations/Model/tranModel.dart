import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';

part 'tranModel.g.dart';

@HiveType(typeId: 0)
class TranItem extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String monthKey;
  @HiveField(2)
  final String type;
  @HiveField(3)
  final DateTime date;
  @HiveField(4)
  final double amount;
  @HiveField(5)
  final String wallet;
  @HiveField(6)
  final String category;
  @HiveField(7)
  final String note;
  @HiveField(8)
  final bool marked;
  @HiveField(9)
  final bool isSynced;

  TranItem({
    required this.id,
    required this.monthKey,
    required this.type,
    required this.date,
    required this.amount,
    required this.wallet,
    required this.category,
    required this.note,
    required this.marked,
    this.isSynced = true,
  });

  factory TranItem.fromDoc(DocumentSnapshot doc, {String? monthKey}) {
    final data = doc.data() as Map<String, dynamic>;
    final date = ((data['date'] as Timestamp?)?.toDate() ?? DateTime.now()).toLocal();
    final derivedMonthKey = "${date.year}-${date.month.toString().padLeft(2, '0')}";

    return TranItem(
      id: doc.id,
      monthKey: monthKey ?? (data['monthKey'] ?? derivedMonthKey),
      type: (data['type'] ?? '').toString(),
      date: date,
      amount: (data['amount'] is String)
          ? double.tryParse(data['amount']) ?? 0.0
          : (data['amount'] as num?)?.toDouble() ?? 0.0,
      wallet: (data['wallet'] ?? '').toString(),
      category: (data['category'] ?? '').toString(),
      note: (data['note'] ?? '').toString(),
      marked: data['marked'] ?? false,
      isSynced: true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'date': Timestamp.fromDate(date),
      'amount': amount,
      'wallet': wallet,
      'category': category,
      'note': note,
      'marked': marked,
      'monthKey': monthKey,
    };
  }

  TranItem copyWith({
    String? id,
    String? monthKey,
    String? type,
    DateTime? date,
    double? amount,
    String? wallet,
    String? category,
    String? note,
    bool? marked,
    bool? isSynced,
  }) {
    return TranItem(
      id: id ?? this.id,
      monthKey: monthKey ?? this.monthKey,
      type: type ?? this.type,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      wallet: wallet ?? this.wallet,
      category: category ?? this.category,
      note: note ?? this.note,
      marked: marked ?? this.marked,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
