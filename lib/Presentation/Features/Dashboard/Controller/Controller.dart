import 'dart:async';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../Data/Repository/DataRepository.dart';
import '../../Transcations/Model/tranModel.dart';
import 'package:flutter/material.dart';

class dashboardController extends GetxController {
  final DataRepository _repository = Get.find<DataRepository>();

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // Observables for UI
  final RxMap<String, double> thisMonthSummary = {"expense": 0.0, "income": 0.0, "saving": 0.0}.obs;
  final RxDouble todayExpense = 0.0.obs;
  final RxDouble totalSavingAllTime = 0.0.obs;
  final RxDouble thisMonthSavings = 0.0.obs;
  final RxDouble overallSavingOnly = 0.0.obs;
  final RxMap<String, double> categorySummary = <String, double>{}.obs;
  final RxList<TranItem> todayTransactions = <TranItem>[].obs;
  final RxList<double> weeklyAmounts = List.filled(7, 0.0).obs;
  final RxList<String> labels = <String>[].obs;
  final RxBool isLoading = true.obs;

  StreamSubscription? _hiveSub;

  @override
  void onInit() {
    super.onInit();
    
    // Initial data load
    _refreshDashboardData();

    // Listen to Hive changes for real-time updates
    _hiveSub = _repository.localDataSource.transactionsBox.watch().listen((_) {
      _refreshDashboardData();
    });
  }

  void _refreshDashboardData() {
    try {
      final allItems = _repository.getAllTransactions();
      final now = DateTime.now();
      
      // 1. Calculate this month summary
      double monthExpense = 0, monthIncome = 0, monthSaving = 0;
      for (var item in allItems) {
        if (item.date.year == now.year && item.date.month == now.month) {
          if (item.type == "Expense") monthExpense += item.amount;
          if (item.type == "Income") monthIncome += item.amount;
          if (item.type == "Saving") monthSaving += item.amount;
        }
      }
      thisMonthSummary.value = {"expense": monthExpense, "income": monthIncome, "saving": monthSaving};

      // 2. Today Expense
      double todayExp = 0;
      final todayItems = <TranItem>[];
      for (var item in allItems) {
        if (_isSameDay(item.date, now)) {
          if (item.type == "Expense") todayExp += item.amount;
          todayItems.add(item);
        }
      }
      todayExpense.value = todayExp;
      todayTransactions.assignAll(todayItems..sort((a, b) => b.date.compareTo(a.date)));

      // 3. Category Summary (Pie Chart) - Current Month Expense
      final catMap = <String, double>{};
      for (var item in allItems) {
        if (item.date.year == now.year && item.date.month == now.month && item.type == "Expense") {
          final cat = item.category.isEmpty ? "Uncategorized" : item.category;
          catMap[cat] = (catMap[cat] ?? 0) + item.amount;
        }
      }
      categorySummary.value = catMap;

      // 4. Weekly Data
      final weekMap = <String, double>{};
      final dateFormat = DateFormat('yyyy-MM-dd');
      for (int i = 0; i < 7; i++) {
        final day = now.subtract(Duration(days: 6 - i));
        weekMap[dateFormat.format(day)] = 0.0;
      }
      for (final item in allItems) {
        if (item.type == 'Expense') {
          final itemDate = dateFormat.format(item.date);
          if (weekMap.containsKey(itemDate)) {
            weekMap[itemDate] = weekMap[itemDate]! + item.amount;
          }
        }
      }
      weeklyAmounts.assignAll(weekMap.values.toList());
      labels.assignAll(weekMap.keys.map((d) => DateFormat.E().format(DateTime.parse(d))).toList());

      // 5. Savings
      double totalSav = 0;
      double currentMonthSav = 0;
      for (var item in allItems) {
        if (item.type == "Saving") {
          totalSav += item.amount;
          if (item.date.year == now.year && item.date.month == now.month) {
            currentMonthSav += item.amount;
          }
        }
      }
      totalSavingAllTime.value = totalSav;
      thisMonthSavings.value = currentMonthSav;
    } catch (e) {
      debugPrint("Error refreshing dashboard data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _hiveSub?.cancel();
    super.onClose();
  }

  int daysLeftInCurrentMonth() {
    final now = DateTime.now();
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    return lastDayOfMonth.difference(DateTime(now.year, now.month, now.day)).inDays + 1;
  }

  Future<void> deleteTransaction(TranItem item) async {
    await _repository.deleteTransaction(item);
    _refreshDashboardData();
  }
}
