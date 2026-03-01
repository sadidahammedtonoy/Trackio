import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:sadid/Core/loading.dart';
import '../../../../Core/snakbar.dart';
import '../../Transcations/Model/tranModel.dart';

class debtsController extends GetxController {
  final RxBool showBorrowInfo = false.obs;

  // Search logic
  final RxBool isSearchVisible = false.obs;
  final RxString searchQuery = ''.obs;

  void toggleSearch() {
    isSearchVisible.value = !isSearchVisible.value;
    if (!isSearchVisible.value) {
      searchQuery.value = '';
    }
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

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

    // Listen months list (realtime)
    return monthsRef.snapshots().switchMap((monthsSnap) {
      final monthDocs = monthsSnap.docs;

      if (monthDocs.isEmpty) return Stream.value(<TranItem>[]);

      // For each month, listen to its items (realtime)
      final itemStreams = monthDocs.map((m) {
        final mk = m.id;
        if (mk.trim().isEmpty) return Stream.value(<TranItem>[]);

        return monthsRef
            .doc(mk)
            .collection('items')
            .snapshots()
            .map((itemsSnap) {
          return itemsSnap.docs
              .map((d) => TranItem.fromDoc(d, monthKey: mk))
              .where((item) => item.type == "Lent" || item.type == "Borrow")
              .toList();
        });
      }).toList();

      // Combine all months items -> one list
      return CombineLatestStream.list<List<TranItem>>(itemStreams).map((lists) {
        final all = <TranItem>[];
        for (final l in lists) {
          all.addAll(l);
        }

        all.sort((a, b) => b.date.compareTo(a.date)); // newest first
        return all;
      });


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

  final RxMap<String, double> _cachedLentBorrow = <String, double>{
    "lent": 0.0,
    "borrow": 0.0,
    "net": 0.0,
  }.obs;

  Stream<Map<String, double>> streamTotalLentBorrow() {
    return streamLentBorrowTransactions()
        .map((items) {
      double totalLent = 0.0;
      double totalBorrow = 0.0;

      for (final t in items) {
        if (t.marked) continue;
        if (t.type == "Lent") totalLent += t.amount;
        if (t.type == "Borrow") totalBorrow += t.amount;
      }

      final result = {
        "lent": totalLent,
        "borrow": totalBorrow,
        "net": totalLent - totalBorrow,
      };

      _cachedLentBorrow.assignAll(result);
      return result;
    })
        .startWith(_cachedLentBorrow);
  }


  Future<bool> toggleTransactionMarked({
    required String monthKey,
    required String transactionId,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        AppSnackbar.show("User not logged in".tr);
        return false;
      }
      Get.back();

      AppLoader.show();

      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('monthly_transactions')
          .doc(monthKey)
          .collection('items')
          .doc(transactionId);

      final snap = await docRef.get();
      if (!snap.exists) {
        AppLoader.hide();
        AppSnackbar.show("Transaction not found".tr);
        return false;
      }

      final data = snap.data()!;
      final bool isMarked = (data["marked"] ?? false) == true;
      final bool newValue = !isMarked;

      await docRef.update({
        "marked": newValue,
        "markedAt": newValue ? FieldValue.serverTimestamp() : null,
        "updatedAt": FieldValue.serverTimestamp(),
      });

      AppLoader.hide();
      AppSnackbar.show(
        newValue ? "Marked as completed".tr : "Marked as pending".tr,
      );

      return true;
    } catch (e) {
      AppLoader.hide();
      AppSnackbar.show("Failed to update transaction".tr);
      return false;
    }
  }

}
