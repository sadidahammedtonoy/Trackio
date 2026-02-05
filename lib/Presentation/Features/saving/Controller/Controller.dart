import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../Core/loading.dart';
import '../../../../Core/snakbar.dart';
import '../Model/savingHistoryModel.dart';
import '../Model/savingModel.dart';
import '../View/addSavingSheet.dart';

class savingController extends GetxController {
  final RxString monthKey = ''.obs;
  final tabIndex = 0.obs; // 0 = Overview, 1 = History

  void changeTab(int i) => tabIndex.value = i;

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
  final RxList<MonthSaving> cachedMonths = <MonthSaving>[].obs;

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

  final amountC = TextEditingController();
  final sourceC = TextEditingController(); // from where this money came
  final noteC = TextEditingController();   // optional memory/note

  final selectedDate = DateTime.now().obs;

  final wallets = <String>["Cash", "Mobile Banking", "Bank", "Others"];
  final selectedWallet = "Cash".obs;

  // motivation (changes each open)
  final motivationTitle = "".obs;
  final motivationSubtitle = "".obs;

  final _motivations = const [
    {
      "t": "Save before you spend",
      "s": "Treat your savings like a bill you pay to yourself first.",
    },
    {
      "t": "Consistency beats intensity",
      "s": "Small, regular savings add up faster than rare big ones.",
    },
    {
      "t": "Turn goals into habits",
      "s": "When saving becomes routine, progress feels effortless.",
    },
    {
      "t": "Every amount counts",
      "s": "Even spare change moves you closer to your goals.",
    },
    {
      "t": "Make your money work",
      "s": "Plan your savings so your future has more options.",
    },
    {
      "t": "Protect your peace of mind",
      "s": "Savings give you freedom from sudden expenses.",
    },
    {
      "t": "Build momentum",
      "s": "The first step is the hardest—keep going after that.",
    },
    {
      "t": "Design your future",
      "s": "Your daily choices shape your financial tomorrow.",
    },
    {
      "t": "Less stress, more control",
      "s": "Having savings means fewer worries when plans change.",
    },
    {
      "t": "Reward your discipline",
      "s": "Celebrate every milestone, no matter how small.",
    },
    {
      "t": "Save with a purpose",
      "s": "Name your goal so each deposit feels meaningful.",
    },
    {
      "t": "Start where you are",
      "s": "You don’t need perfection—just begin today.",
    },
    {
      "t": "Choose progress today",
      "s": "A small decision now creates big impact later.",
    },
    {
      "t": "Grow your cushion",
      "s": "A stronger savings cushion brings confidence.",
    },
    {
      "t": "Your future deserves care",
      "s": "Put aside a little today for a better tomorrow.",
    },
  ];

  void _pickMotivation() {
    final i = Random().nextInt(_motivations.length);
    motivationTitle.value = _motivations[i]["t"]!;
    motivationSubtitle.value = _motivations[i]["s"]!;
  }

  DocumentReference<Map<String, dynamic>> _savingsRef(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(uid);
  }

  void openAddSavingSheet(BuildContext context) {
    // reset fields
    amountC.clear();
    sourceC.clear();
    noteC.clear();
    selectedDate.value = DateTime.now();
    selectedWallet.value = "Cash";

    // new motivation each time
    _pickMotivation();
    Get.to(AddSavingSheet(controller: Get.find<savingController>(),));

    // Get.bottomSheet(
    //   AddSavingSheet(controller: this),
    //   isScrollControlled: true,
    //   backgroundColor: Colors.transparent,
    // );
  }

  Future<void> addSaving() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      AppSnackbar.show("User not logged in");
      return;
    }

    final rawAmount = amountC.text.trim();
    final amount = double.tryParse(rawAmount.replaceAll(',', ''));

    if (amount == null || amount <= 0) {
      AppSnackbar.show("Please enter a valid amount.");
      return;
    }

    final source = sourceC.text.trim();
    if (source.isEmpty) {
      AppSnackbar.show("Please enter where this money came from.");
      return;
    }

    final note = noteC.text.trim();

    AppLoader.show(message: "Adding saving...");

    try {
      await _savingsRef(user.uid).collection('savings').doc('items').collection('list').add({
        "amount": amount,
        "date": Timestamp.fromDate(selectedDate.value),
        "wallet": selectedWallet.value,
        "source": source,
        "note": note.isEmpty ? null : note,
        "createdAt": FieldValue.serverTimestamp(),
      });

      AppLoader.hide();
      Get.back(); // close sheet
      AppSnackbar.show("Saving added successfully");
    } catch (e) {
      AppLoader.hide();
      AppSnackbar.show("Failed to add saving. Please try again.");
    }
  }

  final cachedSavings = <SavingItem>[].obs;

  CollectionReference<Map<String, dynamic>> _listRef(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('savings')
        .doc('items')
        .collection('list');
  }

  Stream<List<SavingItem>> streamAllSavings() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    return _listRef(user.uid)
        .orderBy("date", descending: true) // sort newest first
        .snapshots()
        .map((snap) {
      final list = snap.docs.map((d) => SavingItem.fromDoc(d)).toList();
      cachedSavings.assignAll(list); // cache latest
      return list;
    });
  }

  String friendlyError(Object e) {
    if (e is FirebaseException) {
      switch (e.code) {
        case "permission-denied":
          return "You don't have permission to view savings.";
        case "unauthenticated":
          return "Please login to view savings.";
        case "unavailable":
          return "No internet connection. Please try again.";
        case "failed-precondition":
          return "This action is not available right now.";
        default:
          return e.message ?? "Something went wrong. Please try again.";
      }
    }
    return "Something went wrong. Please try again.";
  }

  Stream<String> streamTotalSavingsText() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('savings')
        .doc('items')
        .collection('list')
        .snapshots()
        .map((snap) {
      double total = 0.0;

      for (final d in snap.docs) {
        final data = d.data();
        final raw = data['amount'];

        final amount = (raw is String)
            ? double.tryParse(raw) ?? 0.0
            : (raw as num?)?.toDouble() ?? 0.0;

        total += amount;
      }

      // ✅ return formatted string
      return total.toStringAsFixed(0); // or 2 decimals if you want
    });
  }









}