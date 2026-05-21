import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sadid/Core/loading.dart';
import '../../../../Core/snakbar.dart';

class AddBudgetController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController remarkController = TextEditingController();

  var selectedMonth = DateTime.now().obs;
  var selectedCategories = <String>[].obs;
  var categories = [].obs;
  var budgetId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    if (Get.arguments != null) {
      budgetId.value = Get.arguments['budgetId'];
      final categoryArg = Get.arguments['category'];
      if (categoryArg is String) {
        selectedCategories.add(categoryArg);
        groupNameController.text = categoryArg;
      }
      amountController.text = Get.arguments['amount'].toString();
    }
  }

  void fetchCategories() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('categories')
          .snapshots()
          .listen((snapshot) {
        categories.value = snapshot.docs.map((doc) => doc.data()).toList();
      });
    }
  }

  void toggleCategory(String categoryName) {
    if (budgetId.value.isNotEmpty) {
      AppSnackbar.show("Category cannot be changed when editing a budget.");
      return;
    }
    if (selectedCategories.contains(categoryName)) {
      selectedCategories.remove(categoryName);
    } else {
      selectedCategories.add(categoryName);
    }
  }

  void saveOrUpdateBudget() async {
    if (!formKey.currentState!.validate() || selectedCategories.isEmpty) {
      if (selectedCategories.isEmpty) AppSnackbar.show("Please select at least one category");
      return;
    }

    AppLoader.show();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      final String monthStr = DateFormat('yyyy-MM').format(selectedMonth.value);
      final budgetCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('monthly_transactions')
          .doc(monthStr)
          .collection('budgets');

      if (budgetId.value.isEmpty) {
        final allBudgetsSnapshot = await budgetCollection.get();
        for (var doc in allBudgetsSnapshot.docs) {
          final data = doc.data();
          if (data == null) continue;

          final List<String> existingCategories = [];
          if (data['categories'] is List) {
            for (var cat in data['categories']) {
              if (cat is String) existingCategories.add(cat);
            }
          } else if (data['category'] is String) {
            existingCategories.add(data['category']);
          }

          for (String newCat in selectedCategories) {
            if (existingCategories.contains(newCat)) {
              throw Exception("Category '$newCat' is already part of another budget for this month.");
            }
          }
        }
      }

      final groupName = selectedCategories.length > 1 ? groupNameController.text.trim() : selectedCategories.first;
      final budgetData = {
        'amount': double.parse(amountController.text),
        'month': monthStr,
        'categories': selectedCategories.toList(),
        'groupName': groupName,
        'remark': remarkController.text,
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (budgetId.value.isNotEmpty) {
        await budgetCollection.doc(budgetId.value).update(budgetData);
      } else {
        await budgetCollection.add(budgetData);
      }

      // --- SUCCESS PATH ---
      AppLoader.hide();
      Get.back();
      final successMessage = budgetId.value.isNotEmpty ? "Budget updated successfully" : "Budget added successfully";
      AppSnackbar.show(successMessage);

    } catch (e) {
      // --- FAILURE PATH ---
      AppLoader.hide();
      final errorMessage = e.toString().replaceFirst(RegExp(r'^Exception: '), '');
      AppSnackbar.show(errorMessage);
    }
  }

  void selectMonth(BuildContext context) {
    if (Get.theme.platform == TargetPlatform.iOS) {
      _showIOSMonthPicker(context);
    } else {
      _showAndroidMonthPicker(context);
    }
  }

  void _showAndroidMonthPicker(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: selectedMonth.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialDatePickerMode: DatePickerMode.year,
    ).then((pickedDate) {
      if (pickedDate != null) {
        selectedMonth.value = pickedDate;
      }
    });
  }

  void _showIOSMonthPicker(BuildContext context) {
    DateTime tempDate = selectedMonth.value;
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 300,
        color: Colors.white,
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: CupertinoDatePicker(
                initialDateTime: selectedMonth.value,
                mode: CupertinoDatePickerMode.date,
                onDateTimeChanged: (picked) {
                  tempDate = picked;
                },
              ),
            ),
            CupertinoButton(
              child: const Text('OK'),
              onPressed: () {
                selectedMonth.value = tempDate;
                Get.back();
              },
            )
          ],
        ),
      ),
    );
  }
}
