import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sadid/Core/loading.dart';
import 'package:sadid/Core/snakbar.dart';
import 'package:sadid/Presentation/Features/AddTransactions/Model/addTransactionModel.dart';

class addTranscationsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final wallets = ["Cash", "Mobile Banking", "Bank", "Others"];
  final selectedWallet = "Cash".obs;
  final types = ["Expense", "Income", "Lent", "Borrow"];
  final selectedType = "Expense".obs;
  final selectedDate = DateTime.now().obs;
  final categories = <Map<String, dynamic>>[].obs;
  final selectedCategoryId = RxnString();

  String get _uid => _auth.currentUser?.uid ?? "";

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    if (_uid.isEmpty) return;
    final snap = await _firestore.collection('users').doc(_uid).collection('categories').get();
    categories.value = snap.docs.map((d) => {"id": d.id, ...d.data()}).toList();
  }

  Future<String?> addMonthlyTransaction({required addTranModel model}) async {
    if (_uid.isEmpty) return null;
    AppLoader.show(message: "Adding transaction...".tr);

    try {
      final monthKey = "${model.date.year}-${model.date.month.toString().padLeft(2, '0')}";
      final amount = double.tryParse(model.amount) ?? 0.0;

      // 1. Ensure the month document exists (used for aggregation logic)
      final monthRef = _firestore.collection('users').doc(_uid).collection('monthly_transactions').doc(monthKey);
      await monthRef.set({"updatedAt": FieldValue.serverTimestamp()}, SetOptions(merge: true));

      // 2. Add item to 'items' sub-collection (Matches debts.dart logic)
      final docRef = monthRef.collection('items').doc();
      final tranData = {
        'type': model.type,
        'date': Timestamp.fromDate(model.date),
        'amount': amount,
        'wallet': model.wallet,
        'category': model.category,
        'note': model.note.trim(),
        'marked': model.type == "Lent" || model.type == "Borrow" ? false : true,
        'monthKey': monthKey, // Redundant but helpful for simple queries
      };

      await docRef.set(tranData);

      AppLoader.hide();
      Get.back();
      AppSnackbar.show("Transaction added successfully".tr);
      return docRef.id;
    } catch (e) {
      AppLoader.hide();
      AppSnackbar.show("Fail to add Transaction".tr);
      debugPrint("❌ Add Transaction Error: $e");
      return null;
    }
  }
}
