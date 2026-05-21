import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sadid/Presentation/Features/budgets/Model/budget_model.dart';

class BudgetsController extends GetxController {
  var totalBudget = 0.0.obs;
  var totalSpent = 0.0.obs;
  var budgets = <BudgetModel>[].obs;
  var selectedMonth = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    debounce(selectedMonth, (_) => fetchBudgetAndSpending(),
        time: const Duration(milliseconds: 300));
    fetchBudgetAndSpending();
  }

  void fetchBudgetAndSpending() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final monthStr = DateFormat('yyyy-MM').format(selectedMonth.value);
    final monthlyTransactionsDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('monthly_transactions')
        .doc(monthStr);

    final budgetCollection = monthlyTransactionsDoc.collection('budgets');
    final itemsCollection = monthlyTransactionsDoc.collection('items');

    totalBudget.value = 0.0;
    totalSpent.value = 0.0;
    budgets.value = [];

    budgetCollection.snapshots().listen((budgetSnapshot) {
      double currentTotalBudget = 0.0;
      List<BudgetModel> tempBudgets = [];
      List<String> allCategoriesInBudgets = [];

      for (var doc in budgetSnapshot.docs) {
        final data = doc.data();
        currentTotalBudget += (data['amount'] as num? ?? 0).toDouble();
        
        // --- Defensive Data Parsing ---
        final List<String> budgetCategories = [];
        if (data['categories'] is List) {
          for (var cat in data['categories']) {
            if (cat is String) {
              budgetCategories.add(cat);
            }
          }
        } else if (data['category'] is String) {
          budgetCategories.add(data['category']);
        }

        final String groupName = data['groupName'] as String? ?? (budgetCategories.isNotEmpty ? budgetCategories.first : 'Untitled Budget');
        // --- End of Defensive Parsing ---

        allCategoriesInBudgets.addAll(budgetCategories);
        
        tempBudgets.add(BudgetModel(
          id: doc.id,
          groupName: groupName,
          categories: budgetCategories,
          budget: (data['amount'] as num? ?? 0).toDouble(),
        ));
      }
      totalBudget.value = currentTotalBudget;

      if (allCategoriesInBudgets.isNotEmpty) {
        itemsCollection
            .where('type', isEqualTo: 'Expense')
            .where('category', whereIn: allCategoriesInBudgets.toSet().toList())
            .snapshots()
            .listen((transactionSnapshot) {
              double currentTotalSpent = 0.0;
              for (var budget in tempBudgets) {
                budget.spent = 0;
              }

              for (var doc in transactionSnapshot.docs) {
                final data = doc.data();
                final amount = (data['amount'] as num? ?? 0).toDouble();
                final category = data['category'];

                if (amount > 0 && category is String) {
                  currentTotalSpent += amount;
                  
                  final budget = tempBudgets.firstWhere(
                    (b) => b.categories.contains(category),
                    orElse: () => BudgetModel(id: '', groupName: '', categories: [], budget: 0)
                  );

                  if (budget.id.isNotEmpty) {
                    budget.spent += amount;
                  }
                }
              }
              totalSpent.value = currentTotalSpent;
              budgets.value = tempBudgets;
            });
      } else {
        totalSpent.value = 0.0;
        budgets.value = [];
      }
    });
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
      if (pickedDate != null && pickedDate != selectedMonth.value) {
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
            Expanded(
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
                if (tempDate != selectedMonth.value) {
                  selectedMonth.value = tempDate;
                }
                Get.back();
              },
            )
          ],
        ),
      ),
    );
  }

  Future<void> deleteBudget(String budgetId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final monthStr = DateFormat('yyyy-MM').format(selectedMonth.value);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('monthly_transactions')
        .doc(monthStr)
        .collection('budgets')
        .doc(budgetId)
        .delete();
  }
}
