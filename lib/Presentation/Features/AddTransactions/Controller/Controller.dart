import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:sadid/Presentation/Features/AddTransactions/Model/addTransactionModel.dart';

class addTranscationsController extends GetxController {
  final wallets = ["Cash", "Mobile Banking", "Bank", "Others"];
  final selectedWallet = "Cash".obs;
  final types = ["Expense", "Income", "Saving", "Lent", "Borrow"];
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

  Future<String> addMonthlyTransaction({
    required addTranModel model,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in");

    // 🔑 Month key → 2026-01
    final monthKey =
        "${model.date.year}-${model.date.month.toString().padLeft(2, '0')}";

    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('monthly_transactions')
        .doc(monthKey)
        .collection('items')
        .doc(); // auto id

    await ref.set({
      "type": model.type,
      "date": Timestamp.fromDate(model.date),
      "amount": model.amount,
      "wallet": model.wallet,
      "category": model.category,
      "createdAt": FieldValue.serverTimestamp(),
    });

    return ref.id;
  }







  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    fetchCategories();
  }

}


// Future<String> addCategory({
//   required String name,
// }) async {
//   final user = FirebaseAuth.instance.currentUser;
//   if (user == null) throw Exception("User not logged in");
//
//   final cleanName = name.trim();
//   if (cleanName.isEmpty) throw Exception("Category name is empty");
//
//   final ref = FirebaseFirestore.instance
//       .collection('users')
//       .doc(user.uid)
//       .collection('categories')
//       .doc(); // auto id
//
//   await ref.set({
//     "name": cleanName,
//     "createdAt": FieldValue.serverTimestamp(),
//     "updatedAt": FieldValue.serverTimestamp(),
//   });
//
//   return ref.id;
// }
// ElevatedButton(onPressed: () async {
// await controller.addCategory(name: "Salary");
// await controller.fetchCategories();
// }
// , child: Text("Add Category"))