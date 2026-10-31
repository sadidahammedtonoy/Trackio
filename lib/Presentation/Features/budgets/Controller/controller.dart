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
    _showCustomMonthPicker(context);
  }

  void _showIOSMonthPicker(BuildContext context) {
    _showCustomMonthPicker(context);
  }

  void _showCustomMonthPicker(BuildContext context) {
    final bool tablet = MediaQuery.of(context).size.shortestSide >= 600;
    int tempYear = selectedMonth.value.year;
    int tempMonth = selectedMonth.value.month;

    final List<String> monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    Get.dialog(
      StatefulBuilder(
        builder: (ctx, setState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(
              horizontal: tablet ? 200 : 32,
              vertical: 60,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.shade50,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left_rounded, size: 28),
                            onPressed: () => setState(() => tempYear--),
                          ),
                          Text(
                            '$tempYear',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right_rounded, size: 28),
                            onPressed: () => setState(() => tempYear++),
                          ),
                        ],
                      ),
                    ),

                    // Month Grid
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 12,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 1.4,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemBuilder: (_, i) {
                          final isSelected = tempMonth == i + 1;
                          final isCurrentMonth = DateTime.now().year == tempYear &&
                              DateTime.now().month == i + 1;
                          return GestureDetector(
                            onTap: () => setState(() => tempMonth = i + 1),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.deepPurple
                                    : isCurrentMonth
                                        ? Colors.deepPurple.withValues(alpha: 0.08)
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: isCurrentMonth && !isSelected
                                    ? Border.all(color: Colors.deepPurple.withValues(alpha: 0.4))
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                monthNames[i],
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Actions
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: Get.back,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Text(
                                'Cancel'.tr,
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                selectedMonth.value = DateTime(tempYear, tempMonth, 1);
                                Get.back();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Text('Apply'.tr),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
