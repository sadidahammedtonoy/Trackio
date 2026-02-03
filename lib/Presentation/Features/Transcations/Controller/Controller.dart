import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Model/tranModel.dart';

class transactionsController extends GetxController {

  final RxString monthKey = ''.obs;
  final RxString selectedMonth = ''.obs;


  // ✅ month filter toggle: null = ALL months
  final RxnString selectedMonthKey = RxnString(null);

  void setMonthFromDate(DateTime date) {
    monthKey.value = "${date.year}-${date.month.toString().padLeft(2, '0')}";
  }

  void selectMonth(String? key) {
    // null => show ALL transactions
    selectedMonthKey.value = key;
  }

  final RxList<TranItem> cachedAllItems = <TranItem>[].obs;
  final RxList<TranItem> cachedMonthItems = <TranItem>[].obs;

  StreamSubscription<List<TranItem>>? _allSub;
  StreamSubscription<List<TranItem>>? _monthSub;

  @override
  void onInit() {
    super.onInit();

    // Keep "all items" hot
    _allSub = streamAllItems().listen((list) {
      cachedAllItems.assignAll(list);
    });

    // Keep "month items" hot (will update when selectedMonthKey changes too)
    ever(selectedMonthKey, (_) {
      _monthSub?.cancel();
      _monthSub = streamMonthlyItems().listen((list) {
        cachedMonthItems.assignAll(list);
      });
    });

    // initial month subscription
    _monthSub = streamMonthlyItems().listen((list) {
      cachedMonthItems.assignAll(list);
    });
  }

  @override
  void onClose() {
    _allSub?.cancel();
    _monthSub?.cancel();
    super.onClose();
  }

  /// ✅ Use this in UI so it doesn’t flicker
  Stream<List<TranItem>> streamTxnForUI() {
    final isAll = selectedMonthKey.value == null;
    return isAll ? streamAllItems() : streamMonthlyItems();
  }

  /// ✅ Cached fallback for UI
  List<TranItem> cachedTxnForUI() {
    final isAll = selectedMonthKey.value == null;
    return isAll ? cachedAllItems : cachedMonthItems;
  }

  // ✅ Existing (month basis)
  Stream<List<TranItem>> streamMonthlyItems() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    // IMPORTANT: decide which month you want to load
    final key = selectedMonthKey.value ?? monthKey.value;

    if (key.trim().isEmpty) {
      // debug
      print("❌ streamMonthlyItems monthKey empty!");
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('monthly_transactions')
        .doc(key)
        .collection('items')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((d) => TranItem.fromDoc(d, monthKey: key))
        .toList());
  }


  // ✅ NEW: stream ALL months (reads every month doc and merges items)
  Stream<List<TranItem>> streamAllItems() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    final monthsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('monthly_transactions');

    return monthsRef.snapshots().asyncMap((monthsSnap) async {
      final all = <TranItem>[];

      print("✅ months count = ${monthsSnap.docs.length}");

      for (final monthDoc in monthsSnap.docs) {
        final mk = monthDoc.id; // ✅ THIS is the month key

        if (mk.trim().isEmpty) continue;

        final itemsSnap = await monthsRef
            .doc(mk)
            .collection('items')
            .orderBy('date', descending: true)
            .get();

        all.addAll(
          itemsSnap.docs.map((d) => TranItem.fromDoc(d, monthKey: mk)),
        );
      }

      all.sort((a, b) => b.date.compareTo(a.date));
      return all;
    });
  }

  // ✅ Month dropdown options
  Stream<List<String>> streamMonthKeys() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('monthly_transactions')
        .snapshots()
        .map((snap) {
      final keys = snap.docs.map((d) => d.id).toList();
      keys.sort((a, b) => b.compareTo(a)); // newest first
      return keys;
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

}

