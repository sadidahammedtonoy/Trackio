import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sadid/Presentation/Features/budgets/Model/budget_model.dart';

class BudgetsController extends GetxController {
  var totalBudget = 0.0.obs;
  var totalSpent = 0.0.obs;
  var budgets = <BudgetModel>[].obs;
  var selectedMonth = DateTime.now().obs;
  var isShowingPreviousMonths = false.obs;
  var isLoading = false.obs;

  StreamSubscription? _budgetSubscription;
  StreamSubscription? _itemsSubscription;
  int _fetchSessionId = 0;

  @override
  void onInit() {
    super.onInit();
    debounce(selectedMonth, (_) => fetchBudgetAndSpending(),
        time: const Duration(milliseconds: 300));
    fetchBudgetAndSpending();
  }

  @override
  void onClose() {
    _budgetSubscription?.cancel();
    _itemsSubscription?.cancel();
    super.onClose();
  }

  void fetchBudgetAndSpending() {
    _budgetSubscription?.cancel();
    _itemsSubscription?.cancel();
    final currentSession = ++_fetchSessionId;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    isLoading.value = true;
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

    _budgetSubscription = budgetCollection.snapshots().listen((budgetSnapshot) async {
      if (currentSession != _fetchSessionId) return;

      if (budgetSnapshot.docs.isNotEmpty) {
        // Current month has budgets!
        isShowingPreviousMonths.value = false;
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

          final String groupName = data['groupName'] as String? ??
              (budgetCategories.isNotEmpty ? budgetCategories.first : 'Untitled Budget');
          // --- End of Defensive Parsing ---

          allCategoriesInBudgets.addAll(budgetCategories);

          tempBudgets.add(BudgetModel(
            id: doc.id,
            groupName: groupName,
            categories: budgetCategories,
            budget: (data['amount'] as num? ?? 0).toDouble(),
            month: monthStr,
          ));
        }
        totalBudget.value = currentTotalBudget;

        if (allCategoriesInBudgets.isNotEmpty) {
          _itemsSubscription?.cancel();
          _itemsSubscription = itemsCollection
              .where('type', isEqualTo: 'Expense')
              .where('category', whereIn: allCategoriesInBudgets.toSet().toList())
              .snapshots()
              .listen((transactionSnapshot) {
            if (currentSession != _fetchSessionId) return;
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
                  orElse: () => BudgetModel(id: '', groupName: '', categories: [], budget: 0),
                );

                if (budget.id.isNotEmpty) {
                  budget.spent += amount;
                }
              }
            }
            totalSpent.value = currentTotalSpent;
            budgets.value = List.from(tempBudgets);
            isLoading.value = false;
          });
        } else {
          totalSpent.value = 0.0;
          budgets.value = List.from(tempBudgets);
          isLoading.value = false;
        }
      } else {
        // Current month has NO budgets!
        // Fetch budgets from previous months where budgets were set
        await _fetchPreviousMonthsBudgets(user.uid, monthStr, currentSession);
      }
    });
  }

  Future<void> _fetchPreviousMonthsBudgets(
      String uid, String currentMonthStr, int currentSession) async {
    try {
      final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
      final monthsSnap = await userRef.collection('monthly_transactions').get();

      final candidateMonths = <String>{};
      for (var doc in monthsSnap.docs) {
        if (doc.id.compareTo(currentMonthStr) < 0 && RegExp(r'^\d{4}-\d{2}$').hasMatch(doc.id)) {
          candidateMonths.add(doc.id);
        }
      }

      // Also check the previous 6 months in case parent docs were not explicitly set
      for (int i = 1; i <= 6; i++) {
        final prevDate = DateTime(selectedMonth.value.year, selectedMonth.value.month - i, 1);
        final key = DateFormat('yyyy-MM').format(prevDate);
        if (key.compareTo(currentMonthStr) < 0) {
          candidateMonths.add(key);
        }
      }

      final sortedMonths = candidateMonths.toList()..sort((a, b) => b.compareTo(a));

      // Query budget collections in parallel
      final checks = await Future.wait(
        sortedMonths.map((m) async {
          try {
            final snap = await userRef
                .collection('monthly_transactions')
                .doc(m)
                .collection('budgets')
                .get();
            return MapEntry(m, snap);
          } catch (_) {
            return null;
          }
        }),
      );

      if (currentSession != _fetchSessionId) return;

      final monthsWithBudgets = checks
          .whereType<MapEntry<String, QuerySnapshot<Map<String, dynamic>>>>()
          .where((e) => e.value.docs.isNotEmpty)
          .toList();

      if (monthsWithBudgets.isEmpty) {
        isShowingPreviousMonths.value = false;
        totalBudget.value = 0.0;
        totalSpent.value = 0.0;
        budgets.value = [];
        isLoading.value = false;
        return;
      }

      // Fetch expenses and compute spending for each month concurrently
      final monthResults = await Future.wait(
        monthsWithBudgets.map((entry) async {
          final monthKey = entry.key;
          final budgetDocs = entry.value.docs;

          final List<BudgetModel> monthBudgets = [];
          final List<String> monthCategories = [];

          for (var doc in budgetDocs) {
            final data = doc.data();
            final amount = (data['amount'] as num? ?? 0).toDouble();

            final List<String> budgetCategories = [];
            if (data['categories'] is List) {
              for (var cat in data['categories']) {
                if (cat is String) budgetCategories.add(cat);
              }
            } else if (data['category'] is String) {
              budgetCategories.add(data['category']);
            }

            final String groupName = data['groupName'] as String? ??
                (budgetCategories.isNotEmpty ? budgetCategories.first : 'Untitled Budget');

            monthCategories.addAll(budgetCategories);

            monthBudgets.add(BudgetModel(
              id: doc.id,
              groupName: groupName,
              categories: budgetCategories,
              budget: amount,
              month: monthKey,
            ));
          }

          if (monthCategories.isNotEmpty) {
            try {
              final itemsSnap = await userRef
                  .collection('monthly_transactions')
                  .doc(monthKey)
                  .collection('items')
                  .where('type', isEqualTo: 'Expense')
                  .get();

              for (var doc in itemsSnap.docs) {
                final data = doc.data();
                final amount = (data['amount'] as num? ?? 0).toDouble();
                final category = data['category'];

                if (amount > 0 && category is String) {
                  final b = monthBudgets.firstWhere(
                    (item) => item.categories.contains(category),
                    orElse: () => BudgetModel(id: '', groupName: '', categories: [], budget: 0),
                  );
                  if (b.id.isNotEmpty) {
                    b.spent += amount;
                  }
                }
              }
            } catch (e) {
              debugPrint("Error fetching items for $monthKey: $e");
            }
          }

          return monthBudgets;
        }),
      );

      if (currentSession != _fetchSessionId) return;

      final List<BudgetModel> allPreviousBudgets = [];
      double combinedTotalBudget = 0.0;
      double combinedTotalSpent = 0.0;

      for (var list in monthResults) {
        for (var b in list) {
          allPreviousBudgets.add(b);
          combinedTotalBudget += b.budget;
          combinedTotalSpent += b.spent;
        }
      }

      isShowingPreviousMonths.value = true;
      totalBudget.value = combinedTotalBudget;
      totalSpent.value = combinedTotalSpent;
      budgets.value = allPreviousBudgets;
      isLoading.value = false;
    } catch (e) {
      debugPrint("Error fetching previous months budgets: $e");
      if (currentSession == _fetchSessionId) {
        isShowingPreviousMonths.value = false;
        totalBudget.value = 0.0;
        totalSpent.value = 0.0;
        budgets.value = [];
        isLoading.value = false;
      }
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
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
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
                                shape:
                                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                                shape:
                                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  Future<void> deleteBudget(String budgetId, [String? month]) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final monthStr = month ?? DateFormat('yyyy-MM').format(selectedMonth.value);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('monthly_transactions')
        .doc(monthStr)
        .collection('budgets')
        .doc(budgetId)
        .delete();
    fetchBudgetAndSpending();
  }
}
