import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sadid/Core/loading.dart';
import 'package:sadid/Core/snakbar.dart';
import 'package:sadid/Data/Repository/DataRepository.dart';
import 'package:sadid/Presentation/Features/AddTransactions/Model/addTransactionModel.dart';
import 'package:sadid/Presentation/Features/Budget/Controller/Controller.dart';
import 'package:sadid/Presentation/Features/Transcations/Model/tranModel.dart';
import 'package:uuid/uuid.dart';

class addTranscationsController extends GetxController {
  final wallets = ["Cash", "Mobile Banking", "Bank", "Others"];
  final selectedWallet = "Cash".obs;
  final types = ["Expense", "Income", "Lent", "Borrow"];
  final selectedType = "Expense".obs;
  final selectedDate = DateTime.now().obs;
  final categories = <Map<String, dynamic>>[].obs;
  final selectedCategoryId = RxnString();

  final DataRepository _repository = Get.find<DataRepository>();

  Future<void> fetchCategories() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('categories')
        .get();

    categories.value = snap.docs.map((d) => {"id": d.id, ...d.data()}).toList();

    // Safety: reset invalid selection
    if (selectedCategoryId.value != null) {
      final exists = categories.any((e) => e["id"] == selectedCategoryId.value);
      if (!exists) selectedCategoryId.value = null;
    }
  }

  Future<String?> addMonthlyTransaction({required addTranModel model}) async {
    AppLoader.show(message: "Adding transaction...".tr);

    try {
      final monthKey = "${model.date.year}-${model.date.month.toString().padLeft(2, '0')}";
      final amount = double.tryParse(model.amount) ?? 0.0;

      final tranItem = TranItem(
        id: const Uuid().v4(),
        monthKey: monthKey,
        type: model.type,
        date: model.date,
        amount: amount,
        wallet: model.wallet,
        category: model.category,
        note: model.note.trim(),
        marked: model.type == "Lent" || model.type == "Borrow",
        isSynced: false,
      );

      await _repository.saveTransaction(tranItem);

      // Refresh Budget status if needed
      if (Get.isRegistered<InsightsController>()) {
        Get.find<InsightsController>().refreshData();
      }

      AppLoader.hide();
      Get.back();
      AppSnackbar.show("Transaction added successfully".tr);

      return tranItem.id;
    } catch (e) {
      AppLoader.hide();
      AppSnackbar.show("Fail to add Transaction".tr);
      debugPrint("❌ Add Transaction Error: $e");
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
