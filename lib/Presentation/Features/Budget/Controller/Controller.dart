import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sadid/Data/Repository/DataRepository.dart';
import 'package:sadid/Presentation/Features/Transcations/Model/tranModel.dart';
import '../Model/budgetModel.dart';

class BudgetStatus {
  final String category;
  final double limit;
  final double spent;
  final double percentage;

  BudgetStatus({
    required this.category,
    required this.limit,
    required this.spent,
    required this.percentage,
  });
}

class InsightsController extends GetxController {
  final DataRepository _repository = Get.find<DataRepository>();

  final RxString selectedMonthKey = "".obs;
  final RxString budgetMonthKey = "".obs; // For the "Add Budget" sheet
  final RxList<BudgetModel> budgets = <BudgetModel>[].obs;
  final RxList<BudgetStatus> budgetStatuses = <BudgetStatus>[].obs;

  // Toggle for View Mode
  final RxBool isAnalyticsMode = false.obs;

  // Chart Data
  final RxMap<String, double> categoryDistribution = <String, double>{}.obs;
  final RxList<Map<String, dynamic>> monthlyTrends = <Map<String, dynamic>>[].obs;

  final TextEditingController amountC = TextEditingController();
  final RxString selectedCategory = "".obs;

  // Computed: Over-budget categories for current selected month
  List<BudgetStatus> get overBudgetCategories => 
      budgetStatuses.where((s) => s.percentage > 1.0).toList();

  @override
  void onInit() {
    super.onInit();
    selectedMonthKey.value = _getMonthKey(DateTime.now());
    budgetMonthKey.value = selectedMonthKey.value;
    refreshData();
  }

  String _getMonthKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}";
  }

  void setMonth(DateTime date) {
    selectedMonthKey.value = _getMonthKey(date);
    refreshData();
  }

  void refreshData() {
    _loadBudgets();
    _calculateStatus();
    _calculateAnalytics();
  }

  void _loadBudgets() {
    final allBudgets = _repository.getAllBudgets();
    budgets.assignAll(
      allBudgets.where((b) => b.monthKey == selectedMonthKey.value).toList(),
    );
  }

  void _calculateStatus() {
    final transactions = _repository.getAllTransactions()
        .where((t) => t.monthKey == selectedMonthKey.value && t.type == "Expense")
        .toList();

    final statuses = <BudgetStatus>[];

    for (var budget in budgets) {
      final spent = transactions
          .where((t) => t.category == budget.category)
          .fold(0.0, (sum, t) => sum + t.amount);
      
      statuses.add(BudgetStatus(
        category: budget.category,
        limit: budget.amount,
        spent: spent,
        percentage: budget.amount > 0 ? (spent / budget.amount) : 0,
      ));
    }

    budgetStatuses.assignAll(statuses);
  }

  void _calculateAnalytics() {
    final allTransactions = _repository.getAllTransactions();
    
    // 1. Current Month Distribution
    final currentMonthTrans = allTransactions
        .where((t) => t.monthKey == selectedMonthKey.value && t.type == "Expense")
        .toList();

    final dist = <String, double>{};
    for (var t in currentMonthTrans) {
      final cat = t.category.isEmpty ? "Uncategorized" : t.category;
      dist[cat] = (dist[cat] ?? 0.0) + t.amount;
    }
    categoryDistribution.assignAll(dist);

    // 2. 6-Month Trend
    final trends = <Map<String, dynamic>>[];
    final now = DateTime.now();
    for (int i = 5; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i, 1);
      final mKey = _getMonthKey(date);
      final total = allTransactions
          .where((t) => t.monthKey == mKey && t.type == "Expense")
          .fold(0.0, (sum, t) => sum + t.amount);
      
      trends.add({
        "month": DateFormat('MMM').format(date),
        "amount": total,
      });
    }
    monthlyTrends.assignAll(trends);
  }

  Future<void> addOrUpdateBudget() async {
    if (selectedCategory.value.isEmpty || amountC.text.isEmpty) {
      Get.snackbar("Error", "Please select category and enter amount");
      return;
    }

    final amount = double.tryParse(amountC.text) ?? 0.0;
    if (amount <= 0) return;

    // Check if budget exists for THIS month and category
    final mKey = budgetMonthKey.value;
    final allBudgets = _repository.getAllBudgets();
    final existing = allBudgets.firstWhereOrNull(
      (b) => b.category == selectedCategory.value && b.monthKey == mKey
    );
    
    if (existing != null) {
       existing.amount = amount;
       await existing.save();
    } else {
      final newBudget = BudgetModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        category: selectedCategory.value,
        amount: amount,
        monthKey: mKey,
      );
      await _repository.saveBudget(newBudget);
    }

    amountC.clear();
    selectedCategory.value = "";
    refreshData();
    Get.back();
  }

  Future<void> deleteBudget(String id) async {
    await _repository.deleteBudget(id);
    refreshData();
  }
}
