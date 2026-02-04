import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../Model/savingModel.dart';

class savingController extends GetxController {
  final RxString monthKey = ''.obs;

  @override
  void onInit() {
    super.onInit();
    setMonthFromDate(DateTime.now());
  }

  void setMonthFromDate(DateTime date) {
    monthKey.value =
    "${date.year}-${date.month.toString().padLeft(2, '0')}";
  }

  /// ✅ Monthly Savings = income - expense
  Stream<double> streamMonthlySaving() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    final key = monthKey.value;
    if (key.trim().isEmpty) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('monthly_transactions')
        .doc(key)
        .collection('items')
        .snapshots()
        .map((snap) {
      double income = 0.0;
      double expense = 0.0;

      for (final d in snap.docs) {
        final data = d.data();
        final type = (data['type'] ?? '').toString();

        final raw = data['amount'];
        final amount = (raw is String)
            ? double.tryParse(raw) ?? 0.0
            : (raw as num?)?.toDouble() ?? 0.0;

        if (type == "Income") income += amount;
        if (type == "Expense") expense += amount;
      }

      return income - expense; // ✅ monthly saving
    });
  }

  /// ✅ Overall Saving stored separately (first time => 0)
  Stream<double> streamOverallSaving() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('stats')
        .doc('summary')
        .snapshots()
        .map((doc) {
      if (!doc.exists) return 0.0;

      final data = doc.data() as Map<String, dynamic>;
      final raw = data['overallSaving'];

      final val = (raw is String)
          ? double.tryParse(raw) ?? 0.0
          : (raw as num?)?.toDouble() ?? 0.0;

      return val;
    });
  }

  /// ✅ Add to overall saving (creates doc if not exists)
  Future<void> addToOverallSaving(double amount) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('stats')
        .doc('summary');

    await ref.set({
      "overallSaving": FieldValue.increment(amount),
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// ✅ Remove means set to 0
  Future<void> resetOverallSaving() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('stats')
        .doc('summary');

    await ref.set({
      "overallSaving": 0,
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<List<MonthSaving>> streamAllMonthSavings() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    final monthsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('monthly_transactions');

    return monthsRef.snapshots().asyncMap((monthsSnap) async {
      final results = <MonthSaving>[];

      for (final monthDoc in monthsSnap.docs) {
        final mk = monthDoc.id;
        if (mk.trim().isEmpty) continue;

        final itemsSnap = await monthsRef
            .doc(mk)
            .collection('items')
            .get();

        double income = 0.0;
        double expense = 0.0;

        for (final d in itemsSnap.docs) {
          final data = d.data();
          final type = (data['type'] ?? '').toString();

          final raw = data['amount'];
          final amount = (raw is String)
              ? double.tryParse(raw) ?? 0.0
              : (raw as num?)?.toDouble() ?? 0.0;

          if (type == "Income") income += amount;
          if (type == "Expense") expense += amount;
        }

        results.add(MonthSaving(
          monthKey: mk,
          income: income,
          expense: expense,
        ));
      }

      // newest month first (YYYY-MM sorts lexicographically)
      results.sort((a, b) => b.monthKey.compareTo(a.monthKey));
      return results;
    });
  }


}