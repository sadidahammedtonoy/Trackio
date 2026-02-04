import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../Transcations/Model/tranModel.dart';

class debtsController extends GetxController {
  final RxBool showBorrowInfo = false.obs;


// Cache
  final RxList<TranItem> cachedLentBorrow = <TranItem>[].obs;
  StreamSubscription<List<TranItem>>? _lentBorrowSub;

  @override
  void onInit() {
    super.onInit();

    _lentBorrowSub = streamLentBorrowTransactions().listen((list) {
      cachedLentBorrow.assignAll(list);
    });
  }

  @override
  void onClose() {
    _lentBorrowSub?.cancel();
    super.onClose();
  }

  Stream<List<TranItem>> streamLentBorrowTransactions() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    final monthsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('monthly_transactions');

    return monthsRef.snapshots().asyncMap((monthsSnap) async {
      final result = <TranItem>[];

      for (final monthDoc in monthsSnap.docs) {
        final mk = monthDoc.id;

        if (mk.trim().isEmpty) continue;

        final itemsSnap = await monthsRef
            .doc(mk)
            .collection('items')
            .get();

        for (final d in itemsSnap.docs) {
          final item = TranItem.fromDoc(d, monthKey: mk);

          if (item.type == "Lent" || item.type == "Borrow") {
            result.add(item);
          }
        }
      }

      // newest first
      result.sort((a, b) => b.date.compareTo(a.date));
      return result;
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

  Stream<Map<String, double>> streamTotalLentBorrow() {
    return streamLentBorrowTransactions().map((items) {
      double totalLent = 0.0;
      double totalBorrow = 0.0;

      for (final t in items) {
        if (t.type == "Lent") totalLent += t.amount;
        if (t.type == "Borrow") totalBorrow += t.amount;
      }

      final result = {
        "lent": totalLent,
        "borrow": totalBorrow,
        "net": totalLent - totalBorrow,
      };

      // ✅ cache latest result
      _cachedLentBorrow.assignAll(result);

      return result;
    }).startWith(_cachedLentBorrow); // 👈 return cached immediately
  }

  final RxMap<String, double> _cachedLentBorrow = <String, double>{
    "lent": 0.0,
    "borrow": 0.0,
    "net": 0.0,
  }.obs;





}