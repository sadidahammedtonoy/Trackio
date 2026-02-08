import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../../Core/loading.dart';
import '../../../../Core/snakbar.dart';
import '../../Transcations/Model/tranModel.dart';

class editTransactionsController extends GetxController {
  final wallets = ["Cash", "Mobile Banking", "Bank", "Others"];
  final selectedWallet = "Cash".obs;
  final types = ["Expense", "Income", "Lent", "Borrow"];
  final selectedType = "Expense".obs;
  final selectedDate = DateTime.now().obs;
  final categories = <Map<String, dynamic>>[].obs;
  final selectedCategoryId = RxnString();
  TranItem? oldItem;
  TextEditingController amountController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  TextEditingController personNameController = TextEditingController();

  Future<void> assignValues(TranItem model) async {
    oldItem = model;
    await fetchCategories();
    selectedType.value = model.type;
    selectedDate.value = model.date;
    amountController.text = "${model.amount}";
    selectedWallet.value = model.wallet;
    noteController.text = model.note;
    if(model.type == "Lent" || model.type == "Borrow"){
      personNameController.text = model.category;
    }else{
      selectedCategoryId.value = model.category;
    }
  }

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

  Future<bool> editMonthlyTransaction({
    required TranItem oldItem,
    required TranItem updatedItem,
  }) async {
    AppLoader.show(message: "Updating transaction...".tr);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        AppSnackbar.show("User not logged in".tr);
        throw Exception("User not logged in");
      }

      // ✅ Recalculate monthKey from NEW date
      final newMonthKey =
          "${updatedItem.date.year}-${updatedItem.date.month.toString().padLeft(2, '0')}";

      final userMonthsRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('monthly_transactions');

      // 🔁 Same doc, just update fields (including monthKey if date changed)
      final ref = userMonthsRef
          .doc(oldItem.monthKey)        // stays in old month collection
          .collection('items')
          .doc(oldItem.id);

      final data = {
        "type": updatedItem.type,
        "date": Timestamp.fromDate(updatedItem.date),
        "amount": updatedItem.amount,
        "wallet": updatedItem.wallet,
        "category": updatedItem.category,
        "note": updatedItem.note.trim(),
        "marked": updatedItem.marked,
        "monthKey": newMonthKey, // ✅ updated if date month changed
        "updatedAt": FieldValue.serverTimestamp(),
      };

      await ref.update(data);

      // optional: touch parent month doc
      await userMonthsRef.doc(oldItem.monthKey).set({
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      AppLoader.hide();
      Get.back();
      AppSnackbar.show("Transaction updated successfully".tr);
      return true;
    } catch (e) {
      AppLoader.hide();
      AppSnackbar.show("Failed to update transaction".tr);
      return false;
    }
  }





}