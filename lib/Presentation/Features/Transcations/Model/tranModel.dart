import 'package:cloud_firestore/cloud_firestore.dart';

class TranItem {
  final String id;
  final String monthKey;
  final String type;
  final DateTime date;
  final double amount;
  final String wallet;
  final String category;
  final String note;

  TranItem({
    required this.id,
    required this.monthKey,
    required this.type,
    required this.date,
    required this.amount,
    required this.wallet,
    required this.category,
    required this.note,
  });

  factory TranItem.fromDoc(DocumentSnapshot doc, {required String monthKey}) {
    final data = doc.data() as Map<String, dynamic>;
    return TranItem(
      id: doc.id,
      monthKey: monthKey,
      type: (data['type'] ?? '').toString(),
      date: ((data['date'] as Timestamp?)?.toDate() ?? DateTime.now()).toLocal(),
      amount: (data['amount'] is String)
          ? double.tryParse(data['amount']) ?? 0.0
          : (data['amount'] as num?)?.toDouble() ?? 0.0,
      wallet: (data['wallet'] ?? '').toString(),
      category: (data['category'] ?? '').toString(),
      note: (data['note'] ?? '').toString(),
    );
  }
}
