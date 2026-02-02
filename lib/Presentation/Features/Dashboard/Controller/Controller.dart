import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../Transcations/Model/tranModel.dart';

class dashboardController extends GetxController {

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _monthKeyFromDate(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}";

  Stream<Map<String, double>> streamThisMonthSummary() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    final thisMonthKey = _monthKeyFromDate(DateTime.now());

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('monthly_transactions')
        .doc(thisMonthKey)
        .collection('items')
        .snapshots()
        .map((snap) {
      double expense = 0, income = 0, saving = 0;

      for (final d in snap.docs) {
        final data = d.data();
        final type = (data['type'] ?? '').toString();

        final raw = data['amount'];
        final amount = (raw is String)
            ? double.tryParse(raw) ?? 0.0
            : (raw as num?)?.toDouble() ?? 0.0;

        if (type == "Expense") expense += amount;
        if (type == "Income") income += amount;
        if (type == "Saving") saving += amount;
      }

      return {
        "expense": expense,
        "income": income,
        "saving": saving,
      };
    });
  }

  Stream<double> streamTodayExpense() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    final thisMonthKey = _monthKeyFromDate(DateTime.now());
    final now = DateTime.now();

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('monthly_transactions')
        .doc(thisMonthKey)
        .collection('items')
        .snapshots()
        .map((snap) {
      double total = 0;

      for (final doc in snap.docs) {
        final data = doc.data();

        final type = (data['type'] ?? '').toString();
        if (type != "Expense") continue;

        final ts = data['date'];
        final date = (ts is Timestamp) ? ts.toDate().toLocal() : null;
        if (date == null) continue;

        if (!_isSameDay(date, now)) continue;

        final raw = data['amount'];
        final amount = (raw is String)
            ? double.tryParse(raw) ?? 0.0
            : (raw as num?)?.toDouble() ?? 0.0;

        total += amount;
      }

      return total;
    });
  }

  Stream<List<TranItem>> streamAllItems() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    final monthsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('monthly_transactions');

    return monthsRef.snapshots().asyncMap((monthsSnap) async {
      final all = <TranItem>[];

      for (final monthDoc in monthsSnap.docs) {
        final itemsSnap = await monthsRef
            .doc(monthDoc.id)
            .collection('items')
            .orderBy('date', descending: true)
            .get();

        all.addAll(
          itemsSnap.docs.map(
                (d) => TranItem.fromDoc(d, monthKey: monthDoc.id),
          ),
        );
      }

      // newest first
      all.sort((a, b) => b.date.compareTo(a.date));
      return all;
    });
  }

  Stream<double> streamTotalSavingAllTime() {
    return streamAllItems().map((items) {
      double totalSaving = 0.0;

      for (final t in items) {
        if (t.type == "Saving") {
          totalSaving += t.amount;
        }
      }

      return totalSaving;
    });
  }

  final RxnString selectedMonthKey = RxnString(null);

  void selectMonth(String? key) {
    selectedMonthKey.value = key;
  }

  Stream<List<TranItem>> streamSelectedMonthItems() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    final key = selectedMonthKey.value;

    // null => all months
    if (key == null) return streamAllItems();

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('monthly_transactions')
        .doc(key)
        .collection('items')
        .snapshots()
        .map(
          (snap) => snap.docs
          .map((d) => TranItem.fromDoc(d, monthKey: key))
          .toList(),
    );
  }

  // ✅ Expense-by-category (pie chart data)
  Stream<Map<String, double>> streamCategorySummary() {
    return streamSelectedMonthItems().map((items) {
      final map = <String, double>{};

      for (final t in items) {
        if (t.type != "Expense") continue; // expense-only pie
        final cat = t.category.trim().isEmpty ? "Uncategorized" : t.category.trim();
        map[cat] = (map[cat] ?? 0) + t.amount;
      }

      return map;
    });
  }

  Stream<List<TranItem>> streamTodayTransactions() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    final today = DateTime.now();

    bool isSameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;

    final monthsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('monthly_transactions');

    return monthsRef.snapshots().asyncMap((monthsSnap) async {
      final todayItems = <TranItem>[];

      for (final monthDoc in monthsSnap.docs) {
        final itemsSnap = await monthsRef
            .doc(monthDoc.id)
            .collection('items')
            .get();

        for (final d in itemsSnap.docs) {
          final item = TranItem.fromDoc(d, monthKey: monthDoc.id);

          if (isSameDay(item.date, today)) {
            todayItems.add(item);
          }
        }
      }

      // newest first
      todayItems.sort((a, b) => b.date.compareTo(a.date));
      return todayItems;
    });
  }

  Future<bool> deleteMonthlyTransaction({
    required String monthKey,
    required String transactionId,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      final monthRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('monthly_transactions')
          .doc(monthKey);

      // ✅ delete item
      await monthRef.collection('items').doc(transactionId).delete();

      // ✅ touch parent doc so month snapshot changes (important for streamAllItems)
      await monthRef.set({
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      debugPrint("❌ Delete failed: $e");
      return false;
    }
  }

  Stream<double> streamOverallSavingOnly() {
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

      return (raw is String)
          ? double.tryParse(raw) ?? 0.0
          : (raw as num?)?.toDouble() ?? 0.0;
    });
  }









}