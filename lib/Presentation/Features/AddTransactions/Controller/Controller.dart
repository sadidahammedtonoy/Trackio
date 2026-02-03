import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sadid/Core/loading.dart';
import 'package:sadid/Core/snakbar.dart';
import 'package:sadid/Presentation/Features/AddTransactions/Model/addTransactionModel.dart';

class addTranscationsController extends GetxController {
  final wallets = ["Cash", "Mobile Banking", "Bank", "Others"];
  final selectedWallet = "Cash".obs;
  final types = ["Expense", "Income", "Lent", "Borrow"];
  final selectedType = "Expense".obs;
  final selectedDate = DateTime.now().obs;
  final categories = <Map<String, dynamic>>[].obs;
  final selectedCategoryId = RxnString();



  Future<void> fetchCategories() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('categories')
        .get();

    categories.value = snap.docs
        .map((d) => {
      "id": d.id,
      ...d.data(),
    })
        .toList();

    // Safety: reset invalid selection
    if (selectedCategoryId.value != null) {
      final exists =
      categories.any((e) => e["id"] == selectedCategoryId.value);
      if (!exists) selectedCategoryId.value = null;
    }
  }

  Future<String?> addMonthlyTransaction({
    required addTranModel model,
  }) async {
    AppLoader.show(message: "Adding transaction...");

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      final monthKey =
          "${model.date.year}-${model.date.month.toString().padLeft(2, '0')}";

      final monthRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('monthly_transactions')
          .doc(monthKey);

      await monthRef.set({
        "monthKey": monthKey,
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final ref = monthRef.collection('items').doc();

      await ref.set({
        "type": model.type,
        "date": Timestamp.fromDate(model.date),
        "amount": model.amount,
        "wallet": model.wallet,
        "category": model.category,
        "note": (model.note).trim(),
        "monthKey": monthKey,
        "createdAt": FieldValue.serverTimestamp(),
      });

      AppLoader.hide();
      Get.back();
      AppSnackbar.show("Transaction added successfully");

      return ref.id;
    } catch (e) {
      AppLoader.hide();
      AppSnackbar.show("Fail to add Transaction");
      return null;
    }
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    fetchCategories();
  }

}