import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetModel {
  final String id;
  final String category;
  final double limit;
  final String monthKey; // format: YYYY-MM

  BudgetModel({
    required this.id,
    required this.category,
    required this.limit,
    required this.monthKey,
  });

  factory BudgetModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BudgetModel(
      id: doc.id,
      category: data['category'] ?? '',
      limit: (data['limit'] as num?)?.toDouble() ?? 0.0,
      monthKey: data['monthKey'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'limit': limit,
      'monthKey': monthKey,
    };
  }
}

class BudgetStatus {
  final String category;
  final double limit;
  final double spent;

  BudgetStatus({
    required this.category,
    required this.limit,
    required this.spent,
  });

  double get percentage => limit > 0 ? spent / limit : 0.0;
}
